# Chip sign-off: GDS stream-out, merge, DRC and metal fill

This directory turns a routed Innovus database of `nanosoc_chip_pads` into a
merged chip GDS. It also writes the LVS netlists and runs Pegasus DRC with the
sky130 deck, before and after metal fill. Everything runs in batch on the
Cadence box. Run `source ~/.bashrc` first to get the licence and tool paths.

```
routed DB ──stream_out.tcl──► <top>.gds  (+ .pg.v, .pg_nophys.v, .def.gz)
                                  │
                                  ├─ check_gds.py           (KLayout: layers, empty masters, pin access)
                                  ├─ run_chip_drc.sh        (Pegasus DRC; classify_drc.py splits by location)
                                  └─ run_fill.sh            (FILLGEN; merge_fill.py; DRC again)
```

| File | Does |
|---|---|
| `run_stream_out.sh <db> <out> [VAR=value…]` | Runs `stream_out.tcl` in Innovus, then `check_gds.py`. Exits with the check's status. |
| `stream_out.tcl` | Reads the DB and writes the merged GDS, two PG netlists, a DEF and `masters.txt`. Puts a top-level label on each supply port. |
| `sky130_stream.map` | Innovus layer map from tech-LEF layer names to sky130 GDS layer/datatype numbers. |
| `check_gds.py` | KLayout checks on a GDS: top cell, empty or undefined masters, layers outside the PDK layermap, instance counts, labels, pin-access spot checks. |
| `run_chip_drc.sh <gds> <top> <out>` | Pegasus 23.2 DRC with `sky130_rev_0.0_2.12.drc.pvl`. Writes `counts.txt`, `violations.txt` and `breakdown.txt`. |
| `classify_drc.py` | Sorts every result of a real rule by where it is: top-level routing, std-cell, our routing on an IP cell, or inside the IP. |
| `density_report.py <drc_dir>…` | Failing density windows and the worst density value of each density check, side by side for several runs. |
| `run_fill.sh <gds> <top> <out>` | `fillgen.v08.pvl` fill, then `merge_fill.py`, `check_gds.py` and DRC of the filled GDS. |
| `merge_fill.py` | FILLGEN GDS_flow steps 3a and 3b, done in KLayout. |
| `lib_sample.py` | Copies one placement of each named master out of a chip GDS into a small GDS. DRC of that file shows which results a library or IP cell has on its own. |

The LVS scripts in this directory (`run_chip_lvs.sh`, `chip_lvs_*.py`,
`def_pg_labels.py`, `gds_top_texts.py`) belong to the LVS flow. They read
`<top>.gds` and `<top>.pg.v` from a stream-out directory.

Run output goes outside the repo, in `$RUNS/<tag>/`, where `RUNS` is any
directory you choose (`export RUNS=...`). No script overwrites an earlier run:
give each run a new directory.

## What you need

- **Tools** (all on the Cadence box):

  | Tool | Location | Licence |
  |---|---|---|
  | Innovus 22.1 | `/opt/cadence/installs/DDI221/bin`; `run_stream_out.sh` puts it on `PATH` | yes |
  | Pegasus 23.2 | `/opt/cadence/installs/PEGASUS232/tools/bin/pegasus`; override with `PEGASUS_BIN` | yes |
  | KLayout 0.28 or newer, batch mode `klayout -b -r` | `/usr/bin/klayout` | no |
  | `python3` | | no |

  Don't use `klayout -z`: it silently does nothing.
- **Licence:** `CDS_LIC_FILE` comes from `~/.bashrc`, and the server is
  reachable only over the university VPN. A dropped VPN shows up as `LMF-10096`
  or "Fail to find any innovus license". `run_stream_out.sh` then exits 3 and
  `run_chip_drc.sh` exits 2; reconnect and rerun.
- **PDKs:**
  - open PDK `/opt/pdk/sky130A` (`PDK_ROOT`);
  - SRAM macros `/opt/pdk/sram_macros` (`SRAM_ROOT`);
  - Cadence sky130 port `$SKY130`, default `/opt/pdk/cadence_SKY130/sky130_release_0.1.0`. It holds the DRC deck, the FILLGEN deck and the layermap.
- **Space and memory:**
  - A chip run directory takes about 2.5 GB: the filled GDS is 1.7 GB and the zipped fill 0.36 GB.
  - Pegasus needs under 3 GB at `-dp 8`.
  - The scripts still wait for 20 GB available (DRC) or 16 GB (fill), because the box is shared.

## Running it

Run from the repo root of a checkout, after `source ~/.bashrc`:

```sh
S=$PWD/ASIC_ours/Cadence/signoff        # absolute: setup_env.sh (below) changes directory
R=$RUNS/<tag>              # new directory per run; nothing is overwritten
DB=<routed Innovus DB directory>         # e.g. the route stage's write_db output; only read
# A DB whose constraints use $ACCELERATOR_DIR (e.g. one archived by the P&R
# flow) needs the flow environment: run the stream-out as
#   ( source ASIC_ours/Cadence/scripts/setup_env.sh && $S/run_stream_out.sh $DB $R/stream )

$S/run_stream_out.sh $DB $R/stream                                                         # ~1 min
$S/run_chip_drc.sh   $R/stream/nanosoc_chip_pads.gds nanosoc_chip_pads $R/drc_unfilled     # ~1 min
$S/run_fill.sh       $R/stream/nanosoc_chip_pads.gds nanosoc_chip_pads $R/fill --before $R/drc_unfilled   # ~8 min
```

1. **Stream-out.** `run_stream_out.sh` streams the DB, then runs
   `check_gds.py`. It exits 0 only when the check passes.
   - Read `stream/check_gds.txt`. The last line must be `RESULT PASS`.
   - Look at its `MACRO` lines: they list each hard macro's pins that no
     top-level routing or via touches.
   - `VAR=value` arguments go to `stream_out.tcl`, for example
     `EXTRA_GDS=/path/x.gds` for a master with no known GDS, `LABEL_PORTS=0`,
     `TOP=name` or `CPUS=4`.
   - The DB isn't modified: the port labels are added in memory only, and
     there is no `write_db`.
2. **DRC on the unfilled GDS.**
   - Read `drc_unfilled/violations.txt` first: one line per rule, REAL rules
     split by location.
   - `breakdown.txt` gives coordinates to look at.
   - `density_values.txt` gives the density numbers.
   - **Options:** `--dp N` (default 8); `--max-results N` (default 5000 per
     rule in the ASCII database; the summary counts every result anyway);
     `--min-free-gb G` (default 20).
   - **Exit status:**
     - 0: every real violation is inside IP layout;
     - 1: real violations in our routing or the std-cell area;
     - 2: tool, licence or usage error.
3. **Fill, then DRC of the filled GDS.**
   - `fill/check_gds.txt` must pass.
   - `fill/drc_filled/violations.txt` lists the violations after fill.
   - `fill/density_before_after.txt` compares the density before and after.
   - **Options:** `--no-fix` keeps the raw fill-deck output (see "Repairs"
     below); `--no-drc` skips the DRC.

A run directory then looks like this:

```
<tag>/stream/        nanosoc_chip_pads.gds, .pg.v, .pg_nophys.v, .def.gz, masters.txt,
                     merge_list.txt, port_labels.txt, check_gds.txt, innovus.log
<tag>/drc_unfilled/  violations.txt, breakdown.txt, counts.txt, density_values.txt,
                     nanosoc_chip_pads.drc.sum, .drc_errors.ascii, pegasus.log, mem.log, *.rdb
<tag>/fill/          nanosoc_chip_pads.fill.gds.gz, nanosoc_chip_pads.filled.gds, fill.log,
                     merge_fill.log, check_gds.txt, density_before_after.txt, drc_filled/
```

**Viewing results.** Open the GDS in KLayout with the PDK's layer properties
(`klayout -l /opt/pdk/sky130A/libs.tech/klayout/tech/sky130A.lyp <gds>`). For
markers, load `<top>.drc_errors.ascii` in the Marker Browser, or open the run
in the Pegasus GUI.

**IP cells on their own.** To show that a rule fires inside an IP cell
whatever the surroundings, copy that cell out and check it alone:

```sh
klayout -b -r $S/lib_sample.py -rd gds=$R/stream/nanosoc_chip_pads.gds -rd out=$R/lib/lib_sample.gds \
        -rd cells=sky130_sram_8kbyte_1rw_32x2048_8,sar_afe,sky130_ef_io__corner_pad
$S/run_chip_drc.sh $R/lib/lib_sample.gds lib_sample $R/lib/drc --no-classify
```

## Stream-out

### Layer map (`sky130_stream.map`)

The GDS numbers come from the PDK layermap,
`$SKY130/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap`.

| Innovus object | GDS |
|---|---|
| li1 / met1…met5 `NET`, `SPNET`, `VIA` (via enclosures) | 67…72 / 20 (drawing) |
| mcon, via, via2, via3, via4 `VIA` | 67…71 / 44 |
| top-level `PIN` shapes | drawing **and** 67…72 / 16 (pin) |
| `NAME …/PIN` and `TEXT` labels | 67…72 / 5 (label) |
| Innovus metal fill `FILL` (none today) | 67…72 / 99 (fill) |

**Not mapped, so not written at all:**
- `DIEAREA`. The 22 Sep stream had it on 129/0. 235/4 (prBoundary) would trip
  the deck's `x.prBndry` warning, and the pad ring with its corner pads already
  spans the die.
- `COMP`. The 22 Sep stream wrote instance outlines on 128/0 and
  instance-name text on 127/0.
- `LEFOBS` and `LEFPIN`. These only apply with `-output_macros`, which isn't
  used: every master comes from a merged GDS.
- Net-name text.

`write_stream_check_map_file` is on. The log section "objects exist in innovus
database, but they are not mapped" must stay empty, and on d0923 it is.

### Merge list

`stream_out.tcl` works out the merge list from the masters that are actually
placed (`masters.txt` records the GDS each master comes from):

| Masters | GDS |
|---|---|
| `sky130_fd_sc_hd__*`, `sky130_ef_sc_hd__*` | `sky130_fd_sc_hd.gds` |
| `sky130_ef_io__<cell>` with a GDS file of its own (`gpiov2_pad_wrapped`, the `connect_*`/`disconnect_*` slices) | `sky130_ef_io__<cell>.gds` + `sky130_ef_io.gds` + `sky130_fd_io.gds` |
| other `sky130_ef_io__*` cells (power pads, corner, `com_bus_slice_*` IO fillers) | `sky130_ef_io.gds` + `sky130_fd_io.gds` |
| `sky130_ef_io__analog_*` | `sky130_ef_io__analog.gds` + `sky130_fd_io.gds` |
| `sky130_fd_io__*` | `sky130_fd_io.gds` |
| `sky130_sram_8kbyte_1rw_32x2048_8` | the SRAM macro GDS |
| `sar_afe`, `sar_afe_r`, `sar_afe_b` | `ASIC_ours/macros/sar_afe/<cell>.gds`, only when placed |

- **Why `sky130_fd_io.gds` comes along:** the `sky130_ef_io` pads instantiate
  `sky130_fd_io__*` cells (`top_gpiov2`, `overlay_*`, `top_power_*`…) that are
  defined only there.
- **Unknown masters:** a master with no known GDS stops the script. Pass it
  with `EXTRA_GDS` (or the whole list with `MERGE_GDS`).
- **Name clashes:** there are none among these libraries. `sar_afe` prefixes
  its subcells with `sar_afe__`.
- **Units:** all merge files are 1000 DBU/µm, and so is the output
  (`-unit 1000`).

### Port labels

LVS reads only top-level labels (`text_depth -primary`). The labels come from
two places:

- **Placed signal ports.** Innovus places each one on its pad's `PAD`/`P_PAD`
  pin, and the map's `NAME met5/PIN` line labels it on 72/5.
- **Supply ports, and any signal port Innovus left unplaced.**
  `stream_out.tcl` adds a label with `create_text`, in this order:
  1. On the IO cell's `*_PAD` pin on the port's net (e.g. `VCCD_PAD`,
     `VDDA_PAD`), at the centre of the pin's largest met5 rectangle.
  2. Failing that, on the port's own pad-ring bus inside the first four IO
     cells on that net (met5, else met4). `VDD` goes on `VCCD`, `VSS` on
     `VSSD`, and any other port on the bus of the same name.
     - Other buses that Innovus tied to the same net (`VCCHIB`, `VSWITCH`,
       `VSSIO_Q`…) aren't labelled; that is LVS's business.
     - A port with no IO pin on its net gets no label (`NO_IO_PIN` in
       `port_labels.txt`). On the afe DB these are `VDDIO_Q`, `VSSIO_Q`,
       `VSSA`, `VSWITCH` and `VCCHIB`.

`port_labels.txt` lists every port and where its label went. `check_gds.py`
checks that each label sits on drawing metal of its layer.

### Netlists

- `<top>.pg.v` = `write_netlist -include_pg -include_phys_insts -exclude_leaf_cells`:
  PG ports, plus the physical instances (fillers, taps, decaps). LVS needs those,
  because the fillers and taps carry the well and substrate ties.
- `<top>.pg_nophys.v`: the same without the physical instances.

Neither netlist defines leaf cells. Without `-exclude_leaf_cells` Innovus
writes an empty `module` for every std cell, pad and macro, which LVS would
take as the cell's contents.

## check_gds.py

```sh
klayout -b -r check_gds.py -rd gds=<gds> -rd top=<cell> [-rd masters=masters.txt] [-rd pincheck=1] [-rd json=out.json]
```

**FAIL** (exit 1):
- more than one top cell;
- dbu not 0.001;
- ghost cells (referenced but never defined);
- empty masters placed in the top cell (the 22 Sep stream had 173);
- any layer/datatype not in the PDK layermap, in the top cell or in an Innovus via cell;
- junk 127/0, 128/0 or 129/0;
- a master missing from the GDS, or placed a different number of times from what `masters.txt` says;
- a label that doesn't sit on metal.

**Allowed:**
- 236/0, the open-PDK std-cell boundary marker. It's in the std-cell masters and isn't in the Cadence layermap.
- `sky130_fd_pr__gendlring__example_559591418081`: an empty subcell that is empty in `sky130_fd_io.gds` itself.

**`pincheck=1`** (WARN only):
- Std-cell signal pins: the share reached by routing. A pin counts as reached
  if it has a routing mcon (from an Innovus via cell) on the pin's li1, or
  top-level met1 or via1 on the cell's own met1 strap for that pin (e.g.
  `dfrtp` `RESET_B`, `dfstp` `SET_B`). On both DBs 99.9 % are reached; the rest
  are unused outputs (`conb_1/HI`).
- Std-cell met1 power pins: every 25th logic cell is checked against the top-level met1 rails.
- Hard-macro pins (class `block_*`): whether each pin's own metal is touched by top-level routing or by a top-level via cut.

## DRC (`run_chip_drc.sh`, `classify_drc.py`)

### Setup

- **Pegasus 23.2,** as in `analog/cadence/pv/run_drc.sh`. 24.1 has deck
  problems; see `analog/cadence/pv/README.md`.
- **Deck:** `$SKY130/Sky130_DRC/sky130_rev_0.0_2.12.drc.pvl`, unmodified.
- **Control file:** `drc_CTL.pvl` overrides only the deck's `mycell`
  placeholders (layout path, primary cell, summary, results database,
  `max_results`), as in the PDK's `GDS_flow/drc_CTL.pvl`.
- **Hierarchy:** the run is hierarchical. The 650k filler instances cost
  nothing, and the whole chip takes about 30 s with `-dp 8`.

### Result counts

- **Summary:** each `RULECHECK` line gives two numbers. The first counts
  hierarchical results (one per cell definition, capped at `max_results`), the
  second counts every placement. `counts.txt` records `<rule> <hier> <flat>`.
- **REAL vs DENSITY/FILL:** density/fill are the windowed `*.local.*` and
  `*.global.*` checks plus the `*.fill.*` rules on fill shapes. Every other
  rule, including the other `CDR.*` rules, is REAL.

### Location classes (`classify_drc.py`)

Every hierarchical result of a REAL rule goes into one class:

| Class | Meaning |
|---|---|
| `top-level` | centred outside IP cells, touching top-level routing or vias on the rule's layers |
| `std-cell` | centred outside IP cells, touching no top-level shape: std-cell internals or abutment |
| `ip+top` | centred in an IO pad / SRAM / macro, touching our routing or vias |
| `ip-internal` | centred in an IP cell and touching no top-level shape: the IP's own layout |

- **Front-end rules** (wells, diff, poly, licon, implants) can never be
  `top-level`, because Innovus draws only li1…met5 and their cuts.
- **Output:**
  - `breakdown.txt`: example coordinates for each rule and class.
  - `violations.txt`: one line per rule.
  - `density.txt`: the density/fill rules with results.
  - `density_values.txt` (from `density_report.py`): the failing windows and the worst density value of each check.

## Fill (`run_fill.sh`, `merge_fill.py`)

The script follows `$SKY130/Sky130_FILLGEN/GDS_flow` (FILLGEN v08):

1. **Fill generation:** Pegasus runs `fillgen.v08.pvl` with the example's
   `fill_CTL.pvl` (`CELLNAME` set to the top cell). It writes
   `<top>.fill.gds.gz`, with top cell `<top>_FILL`:
   - diff, poly, li1 and met1–met5 fill on xx/99;
   - poly/diff fill as arrays of the placeholder cells `poly_diff_{3,10,25}_FILL`.
2. **Steps 3a and 3b, in KLayout** (`merge_fill.py`). The user guide describes
   doing these by hand when Pegasus Design Review isn't used:
   - **3a:** every reference to a placeholder now points at
     `poly_diff_{3,10,25}_FILLCELL` from `poly_diff_3_10_25.gds.gz`.
   - **3b:** `<top>_FILL` is placed at (0,0) in `<top>`, and the result is
     written to `<top>.filled.gds`.
3. **Checks:** `check_gds.py` runs on the filled GDS, then
   `run_chip_drc.sh` → `drc_filled/`, and finally
   `density_report.py <before> drc_filled` → `density_before_after.txt`.

**Limits:**
- **No seal ring:** the user guide wants fill run "at the chip level with
  seal ring properly placed". The chip has no seal ring (`SEALID`, 81/1), so
  the fill area is the whole drawn extent.
- **Unconditional fill:** the deck fills every free spot on every layer,
  including the free space inside the IO pads and between SRAM structures.
  Only poly fill is density-driven.

### Repairs to the fill deck's output (`merge_fill.py`, on by default)

On d0923 the deck's own output broke two of its fill rules:

- **`x.1b` (off-grid):** 2094 poly-fill squares (66/99) were off the 5 nm
  grid. `merge_fill.py` removes them. Removing fill can lower poly density, but
  it can't create a spacing error.
- **`diff.fill.3` (diff fill longer than 25 µm):** the filler-row pass draws
  diff-fill strips (65/99) up to a whole row long; 5198 merged strips were
  over 25 µm. Each one is cut into equal pieces of at most 24.5 µm, with
  0.5 µm gaps (diff fill to diff fill spacing is 0.4 µm), on the 5 nm grid.

`--no-fix` keeps the raw output.

## Rules that flag the libraries themselves

`lib_sample.py` copied one placement of each master out of the d0923 GDS, and
`run_chip_drc.sh` checked them on their own. The same rules fire there, so
these results belong to the library cells, not to our layout:

| Library cell | Rules |
|---|---|
| `sky130_sram_8kbyte_1rw_32x2048_8` | `licon.4a`, `licon.4b`, `licon.6`, `licon.14b`, `CDR.mcon.cover.1`, `difftap.2c`, `difftap.5b`, `difftap.7`, `hvtp.4`, `psd.8`, `CDR.psd.2`, `nwell.6`, `x.prBndry`, `CDRW.x.8`, `CDR.m2.2` (1) |
| IO pads | `CDRW.m2.3a` (`gpiov2_pad_wrapped`); `m1.res`…`m5.res` (`corner_pad`, `vccd_lvc_clamped_pad`); `x.prBndry` (235/4 in every pad) |
| `sky130_fd_sc_hd` | `CDR.li.5` (`a2111oi_1`, `nor2_2`, `nor2b_2`, `o2111a_1`), `licon.8a` (`a2111oi_0`) |

- **SRAM:** the deck's README says `licon.4a`, `licon.4b` and `mcon.cover.1`
  inside `areaid.ce` are SRAM-specific, and its configurator has an
  "Alternate SRAM Rules" switch for them. `CDRW.x.8` is the warning that
  `areaid.ce` is used at all.
- **Std cells:** `nwell.4` and `nwell.ntap` fire on every std-cell master
  that stands alone. In the chip they come back only where no tap cell sits in
  the row. `sky130_fd_sc_hd` cells are tapless and need
  `sky130_fd_sc_hd__tapvpwrvgnd_1`.

## Stream-out, DRC and fill results

### d0923 (the 23 Sep routed DB; no ADC macro)

Run directory: `$RUNS/d0923/`.

**Stream-out** (`stream/`) took 37 s in Innovus and produced a 175 MB GDS.
`check_gds.py` passes:
- 175 masters, all merged and placed as often as in Innovus;
- 0 empty masters and 0 ghost cells;
- no layer outside the layermap apart from the std cells' 236/0;
- 54 port labels, all on met5;
- 99.9 % of std-cell signal pins are reached by routing (106417 of 106496); the rest are unused outputs such as `conb_1/HI`;
- 2120 of 2120 sampled std-cell rails sit on met1.

**SRAM pins:** each SRAM shows 96 of 129 pins reached. The missing 33 are
`dout1[31:0]` (port 1, unused) and `vssd1`: no top-level shape or via touches
the SRAM's `vssd1` ring in d0923.

**DRC:**

| | Unfilled (`drc_unfilled/`) | Filled + repairs (`fill_fix/drc_filled/`) |
|---|---|---|
| Pegasus 23.2, `-dp 8` | 29 s, worker peak 0.25 GB | 3 min 34 s, worker peak 0.83 GB, ~2.6 GB in total |
| GDS | 175 MB | 1.73 GB (23.7 M fill shapes) |
| Metal density (m1–m5, global + local) | all fail (m1 19 %, m2 11 %, m3 6 %, m4 14 %, m5 19 % global) | **all pass** |
| `CDR.diff.local.low` | 2009 windows | 30 windows, worst 27.1 % (limit 28 %) |
| `CDRW.poly.local.low` | 1303 windows | 983 windows |
| `CDRW.li.global.min` | 12.5 % | 31.4 % (limit 33 %) |

**Real rules with results outside the IP layout.** They are the same before
and after fill; fill adds none.

| Rule | Class | Count | Cause |
|---|---|---|---|
| `nwell.4`, `nwell.ntap` | std-cell | 168 hier / 720k flat | no well-tap cells anywhere in d0923 |
| `CDR.li.1c`, `CDR.li.3a`, `CDR.li.3b`, `CDR.li.3c` | ip+top | thousands | d0923's power plan drew 1.8 µm **li1** stripes every 100 µm, across the SRAMs. Today's `power_plan.tcl` uses met4/met5. |
| `CDR.m1.2` | top-level | 5 | metal spacing in the routing |
| `CDR.m2.2` | top-level | 12 | metal spacing in the routing |
| `CDR.m3.2` | top-level | 18 | metal spacing in the routing |
| `CDR.via3.1`, `CDR.via3.5`, `CDR.x.2.via3` | ip+top | 32 each | Innovus via3 overlapping the SRAM's own via3 on a `vccd1` pin |
| `CDR.via3.2` | ip+top | 16 | same cause |
| `CDR.li.5` | std-cell | 21 | library-internal (see above) |
| `licon.8a` | std-cell | 1 | library-internal (see above) |

### afe (flow_4 route `nanosoc_chip_pads_ready`, with the `sar_afe` macro)

Run directory: `$RUNS/afe/`.

**What's in the DB:** `sar_afe` at (281.345, 281.345) R0, 185k well taps,
599 IO fillers and 4 connect slices, and a core filled with decaps.

**Stream-out** (`stream/`) took 40 s and produced a 209 MB GDS.
`check_gds.py` passes:
- 205 masters, 0 empty masters, 0 ghost cells;
- `sar_afe` and its 82 subcells are identical to `ASIC_ours/macros/sar_afe/sar_afe.gds`;
- **36 of 36 `sar_afe` pins** are touched by top-level routing or vias;
- 81 labels, all on metal;
- 99.9 % of std-cell signal pins are reached;
- each SRAM shows 97 of 129 pins reached; the missing ones are `dout1[*]` only.

**DRC:**

| | Unfilled (`drc_unfilled/`) | Filled, li1 fill left out (`fill_noli/drc_filled/`) |
|---|---|---|
| Pegasus 23.2, `-dp 8` | 32 s | 3 min 20 s, worker peak 0.76 GB |
| GDS | 209 MB | 1.62 GB |
| Metal density (m1–m5, global + local) | all fail | **all pass** |
| `CDR.diff.local.low` | 844 windows, worst 13.3 % | 38 windows, worst 26.8 % |
| `CDRW.poly.local.high` (≤ 38 %) | 1157 windows, worst 64.5 % | 1349 windows, worst 64.5 % |
| `CDRW.li.global.max` | pass | pass |

- **Why li1 fill is left out:** with li1 fill (`fill/`), `CDRW.li.global.max`
  fails at 63.6 % (limit 62 %). The decaps already put li1 over its 33 %
  minimum, so `--drop-fill 67` drops the li1 fill.
- **High poly density:** the decap-filled core causes it (336k `decap_12`,
  173k `decap_4`). Fill can't lower density; P&R has to use fewer decaps.

**Real rules with results outside the IP layout.** They are the same before
and after fill.

| Rule | Class | Count | Cause |
|---|---|---|---|
| `CDR.m5.1` (met5 width) | top-level | 13 | met5 power segments overlapping by only 20 nm at jogs: next to the SRAMs' right edge (x ≈ 1139; y ≈ 2202, 2803, 3507) and at (403.5, 3507.7) |
| `CDR.m5.2` (met5 spacing) | top-level | 11 | same cause |
| `CDR.via3.1`, `CDR.via3.5`, `CDR.x.2.via3` | ip+top | 56 each | Innovus via3 on the SRAM's own via3 on its `vccd1` ring, near (2307.6, 2521) |
| `CDR.via3.2` | ip+top | 40 | same cause |
| `CDR.li.5` | std-cell | 27 | library-internal; reproduced on lone `a2111oi_1`, `a22oi_2`, `a21oi_4`, `xor2_4`, `o41ai_2` |
| `licon.8a` | std-cell | 1 | library-internal (`a2111oi_0`) |

- **Gone since d0923:** `nwell.4` and `nwell.ntap` (taps are in now),
  d0923's li1 stripes, and the m1–m3 spacing errors.
- **IP-internal rules:** the same as d0923, plus `x.prBndry` in the new IO
  cells (`vdda`/`vssa` pads, `com_bus_slice_*`, the connect slice).
- **`sar_afe` checked alone:** no real violations.

### flow6 (P&R flow_6: decaps at 40 % density, IO fillers, well taps)

Run directory: `$RUNS/flow6/`. The DB
(`flow_6_archive/dbs/nanosoc_chip_pads_signoff`) was read after sourcing
`ASIC_ours/Cadence/scripts/setup_env.sh`.

**Stream-out** produced a 209 MB GDS. `check_gds.py` passes:
- 200 masters, 0 empty;
- `sar_afe` identical to the macro GDS, with 36 of 36 pins reached;
- each SRAM has 97 of 129 pins reached (only `dout1[*]` missing);
- 99.9 % of std-cell signal pins reached;
- 93 labels, all on metal.

**DRC:**

| | Unfilled (`drc_unfilled/`, 40 s) | Filled (`fill/drc_filled/`, 3 min 45 s) |
|---|---|---|
| Metal and li1 density | all fail (li1 28.3 %) | **all pass** |
| `CDRW.poly.local.high` | pass | pass |
| `CDR.diff.local.low` | 2009 windows, worst 11.1 % | 38 windows, worst 26.8 % (limit 28 %) |

All 38 remaining diff windows lie over the SRAMs. Diff fill isn't allowed
inside `areaid.ce`, so these windows are limited by the SRAM layout.

**Real rules outside the IP layout.** They are the same before and after fill.

| Rule | Class | Count | Cause |
|---|---|---|---|
| `CDR.via3.1`, `CDR.via3.5`, `CDR.x.2.via3` | ip+top | 18 each | M3M4 stacks (VIA24) overlapping the SRAM's own via3 (`contact_22`) at 6 SRAM ring corners: (1135, 2270/2520/3630) and (2307.3, 1160/2270/3630) |
| `CDR.via3.2` | ip+top | 15 | the same kind of stack ending 30 nm outside the SRAM edge, at 5 more corners: x ≈ 410.97, y 1160/2269/2520/3629, and (2307.2, 2520.6) |
| `CDR.li.5` | std-cell | 19 | library-internal |
| `licon.8a` | std-cell | 1 | library-internal |

### flow7 (P&R flow_7: no M3M4 stacks at the SRAM ring corners)

Run directory: `$RUNS/flow7/`. The DB is
`flow_7_archive/dbs/nanosoc_chip_pads_signoff`.

- **Stream-out:** 209 MB GDS. `check_gds.py` passes with 198 masters and
  0 empty. `sar_afe` is identical to the macro GDS and all 36 of its pins are
  reached; each SRAM has 97 of 129 pins reached (only `dout1[*]` missing);
  99.9 % of std-cell signal pins are reached.
- **Unfilled DRC (40 s):** all via3 corner results are gone. `CDRW.poly.local.high` passes.
- **After fill:** every density rule passes except `CDR.diff.local.low`,
  with 38 windows at worst 26.8 % against a 28 % limit. All 38 windows lie
  mostly over the SRAMs, where diff fill isn't allowed (`areaid.ce`).
- **Real rules outside the IP layout:** only `CDR.li.5` (16) and
  `licon.8a` (1). Both come from inside the std cells (`a2111oi_1`, `a22oi_2`,
  `nor2_2`, `nor2b_2`, `o2111a_1`; `a2111oi_0`). Fill adds none.

## LVS (`run_chip_lvs.sh`)

Chip-level LVS with Pegasus 23.2 and the sky130 deck from
`analog/cadence/pv/lvs_deck.sh` (the PDK deck plus our three fixes; see
`analog/cadence/pv/README.md` for why 23.2 and not 24.1). The layout is the
merged chip GDS. The source is the Innovus PG netlist, read by Pegasus as
Verilog, with the libraries' transistor netlists as its leaf cells.

```
<top>.gds ───────────────────────────────────────────────┐
<top>.pg.v ──chip_lvs_src.py──► src/netlist.v (Verilog)  ├─► pegasus -lvs ──► <top>.lvsrpt.cls
             (+ libraries)  ──► src/source.cdl (CDL)     │      deck.pvl      chip_lvs_digest.py
lvs_deck.sh + chip options ──► deck.pvl ─────────────────┘                    digest.txt
```

```sh
S=ASIC_ours/Cadence/signoff
R=$RUNS/<tag>
$S/run_chip_lvs.sh $R/stream/nanosoc_chip_pads.gds $R/stream/nanosoc_chip_pads.pg.v \
    nanosoc_chip_pads $R/lvs/run1 --pg-labels-def $R/stream/nanosoc_chip_pads.def.gz
```

The script prints `Run Result : MATCH|MISMATCH` and a digest (also in
`digest.txt`), and exits 0 only on MATCH. A full chip takes about 30 s and
2.3 GB with `--dp 8`, because the std cells are compared once per cell type
and the big macros are black boxes. It waits until `free -g` shows the run's
memory plus 8 GB available (`--mem-gb`, default 10).

| File | Does |
|---|---|
| `run_chip_lvs.sh <gds> <v> <top> <outdir> [opts]` | Builds the source set and the deck, runs Pegasus, prints the digest. `--help` lists the options. |
| `chip_lvs_src.py` | Scans the Verilog (`src/verilog_scan.txt`: masters, PG connections, constants), writes the Verilog copy Pegasus reads and the leaf-cell CDL. |
| `chip_lvs_digest.py <cls>` | Digest of the comparison report: cells that do not match, statistics that differ after reduction, shorts and opens, mismatched nets and instances by kind, label shorts, extraction warnings. |
| `chip_lvs_nets.py <spi> <top> CELL…` | From the extracted layout netlist: the top-level net (label or number) on every pin of every placement of CELL, cross-referenced to the other listed cells. |
| `def_pg_labels.py <def>` | One `add_text` per supply net on a DEF core-ring wire. |
| `gds_top_texts.py` | Lists a cell's texts (stdlib GDS reader); with `--one-per-net`/`--none-per-net` it writes `add_text` rules that drop duplicate supply texts. |

### How the source is fed to Pegasus

The deck gets `schematic_path <netlist.v> verilog -supply0 VSS -supply1 VDD` and
`schematic_path <source.cdl> cdl`. Pegasus binds the Verilog instances by pin
name to the CDL subcircuits, so no Verilog-to-CDL conversion is needed. The
`-supply0/-supply1` options map any `1'b0`/`1'b1` to the core supplies.

`src/netlist.v` is a copy of the Innovus netlist with these changes, all
listed in `src/verilog_scan.txt`:
- Empty library-cell modules are dropped, because they would shadow the CDL. The
  stream-out writes `-exclude_leaf_cells`, so this does nothing for its netlists.
- `--pad-ring` (default): an IO-cell ring pin (VCCD VSSD VDDIO VSSIO VDDIO_Q
  VSSIO_Q VDDA VSSA VSWITCH VCCHIB) that the netlist leaves open is put on
  the net the netlist uses for that ring elsewhere. In the layout the abutted
  IO cells make each ring bus one net, but Innovus writes only the pins it was
  told to connect. The corner pads are the usual case.
- `--tie-bulk` (default): a std-cell VPB/VNB that the netlist leaves open is put
  on that cell's own VPWR/VGND. This is what `power_plan.tcl`'s
  `connect_global_net` intends, but Innovus misses it on cells added after it,
  such as the CTS and optimisation buffers and `conb_1`.

`src/source.cdl` includes:
- `stdcells.cdl`: the PDK `sky130_fd_sc_hd.cdl` and the `sky130_ef_sc_hd`
  decap/fill SPICE, normalised for the Cadence deck:
  - the `sky130_fd_pr__` prefix is dropped;
  - `special_nfet_01v8` becomes `nfet_01v8` and `special_pfet_01v8_hvt` becomes `pfet_01v8_hvt` (flops, latches);
  - unit-less W/L get "u", and only W, L and M are kept.
  - `diode_2` gets the diode the layout has (the PDK CDL leaves it out), with the
    deck's property names and units (`a` in µm², `p` in µm).
- `blackbox.cdl`: a pin-only subcircuit for each black box. Pins come from the
  LEF, except `sar_afe*`: its GDS pin text is `ctln<0>`, so the stub keeps the
  macro CDL's `<>` names under `*.BUSDELIMITER <`.
- With `--full sar_afe`: the macro's own CDL (`macros/sar_afe/sar_afe.cdl`).

### Chip options added to the deck

- `lvs_filter_device R(res_generic_po) -short -source`: `conb_1` ties HI/LO
  through poly that the deck does not extract as a resistor, so in the
  layout HI is VPWR and LO is VGND. The two source resistors are shorted to
  match. The extraction report's "Different labels … HI/LO" warnings for
  `conb_1` are this.
- `lvs_spice yes -cull_primitive_subcircuits`: fill and tap cells have no
  devices and vanish from the layout netlist, so they are dropped from the
  source too.
- `lvs_power_name`/`lvs_ground_name` for the chip supplies, `lvs_find_shorts yes`
  (it writes the path between two shorted labels to `<top>.lvsrpt.shorts`),
  and larger report limits.
- Black boxes, IO-cell pin rules and supply texts (below).

### Black boxes

By default, every IO cell in the netlist, the OpenRAM SRAM and `sar_afe*` are
compared as black boxes (`--bb-default`). The default type is
`lvs_black_box -black` with `lvs_black_box_port_depth -all`: the cell's
contents are not extracted, and a port is the pin shape under the cell's own
pin text. Only the connections to the pins are compared. The pin shape may be
at any depth, as in `xres4v2`, whose met4 pins are in subcells.

The IO cells need these rules (`src/deck_pins.pvl`, `pg_texts.pvl`):
- `AMUXBUS_A/B` are not compared. They are unused here, and in the power pads
  the PDK's met4 text sits 0.055 µm off the metal, so no port forms.
- On each supply pad, `lvs_join_nets <pad> X Y -source_layout` for the pins
  that the cell connects inside:
  - the bond pad to its ring bus, for example `VCCD` and `VCCD_PAD`;
  - for VDDIO/VSSIO pads, also the quiet rail: `VDDIO` with `VDDIO_Q`;
  - the padframe connect slices: `VCCHIB` with `VCCD` and `VSWITCH` with
    `VDDIO` (`connect_vcchib_vccd_and_vswitch_vddio_slice_20um`), and `VDDA`
    with `VDDIO` and `VSSA` with `VSSIO` (`connect_vdda_vddio_and_vssa_vssio_slice_20um`).

  The pairs are read from the ef_io CDL's own comments, such as "(connects
  P_PAD and VDDIO_Q to VDDIO)" and "filler that connects VCCHIB and VCCD as
  well as VSWITCH and VDDIO". A `-black` box does not see these
  connections, so they are joined in the layout and in the pin-only source
  stub. In the unit test, the run without the join mismatches and the run with
  it matches, whether the netlist puts the bond pad on its own port or on the
  ring net.
- Supply texts: the layout keeps one text per supply port. With
  `--pg-labels-def`, the GDS's own supply texts (one per supply pad) are
  replaced by one `add_text` per supply on a DEF core-ring wire. A supply with
  no DEF special wire keeps its first GDS text.
  - With several texts of one name on bond pads that are separate nets at
    extraction time, Pegasus rejects all but one ("Top level port name … already used").
  - A text on the core ring lets `lvs_find_shorts` trace a VDD–VSS short
    through the core grid.
  - The other bond pads still join through the ring and the pad joins, so a
    broken ring shows up as unmatched nets.
  - A supply port that has no text in the GDS or the DEF is compared as a net
    only (`lvs_delete_cell_pin <top> <port> -source`). These are the IO-ring
    rails that the UPF exports as ports but no pad or wire names, such as
    `VSWITCH` and `VCCHIB`. Without this rule Pegasus reports a pin mismatch
    (unit test `port0` vs `port1`).

`--soft-bb` uses plain `lvs_black_box`: contents extracted, ignored in the
comparison. It gives extra unnamed pins (substrate and wells crossing the
cell edge) and thousands of "Malformed device" errors from the IO cells' HV
and ESD devices, which the deck does not recognise.

Transistor level (`--full`), tried with a test layout of the macros
(`$RUNS/lvs-unit/macro`):
- `--full sar_afe` works (run `full-afe3`, MATCH). Inside the chip comparison
  `sar_afe` and its subcells match at transistor level: `cdac_8b`, `inverter`,
  `bootstrap_sw`, `mim_cap_adc`, `trim` and `comparator`. The trim's MOM unit
  cap `sar_afe__sarcta__C0` is black-boxed, as in the macro's own LVS.
- `--full sram` is not usable: the OpenRAM subcells have no supply-pin text,
  and the bit cells give subtype errors. The SRAM stays a black box; OpenRAM
  signs it off.
- IO cells at transistor level: the deck cannot extract their devices (see
  `--soft-bb` above).

### Checks that the setup is right (unit tests)

- **Std cells** (`$RUNS/lvs-unit/stdlib`): all 431 cell types
  except the tap cells, placed apart in one GDS, against a Verilog netlist
  through `run_chip_lvs.sh`. 424 of the 426 cells compared match, with W/L
  checked. The two that don't are `probe_p_8` and `probec_p_8`: they contain
  a met5 probe resistor, and the chip doesn't use them.
- **Macros and pads** (`…/lvs-unit/macro`, run `bb4`): `sar_afe`, the SRAM,
  the gpio, analog and vccd pads as black boxes, with Verilog bus pins and the
  supply-pad join. Result: MATCH.

### Netlist variant

LVS needs `<top>.pg.v`, with the physical instances. The decaps have
devices, and the taps and fillers belong to the well ties. Fills and taps
drop out by the cull rule above. `<top>.pg_nophys.v` works only if the layout
has no decaps.

### Diagnostics

- `--no-bulk-pins`: std-cell VPB/VNB are not compared. This shows the
  signal and supply wiring apart from the well and substrate ties.
- `chip_lvs_nets.py <top>.spi <top> sar_afe sky130_ef_io__analog_pad`: shows
  which layout net each pin of a macro or pad is on.

### Known classes of mismatch

| Class | Kind | How it shows |
|---|---|---|
| Missing well taps | real | Every std cell's VPB (n-well) and VNB (substrate) on nets of their own instead of VDD/VSS, hundreds of extra layout nets; `--no-bulk-pins` makes it go away |
| Routing short between two signal nets | real | "SHORTS AND OPENS": one layout net, two or more schematic nets; the DEF routes overlap |
| Supply short | real | Label short in `<top>.lvsrpt.shorts` with the polygon path; instances then show `VGND: VDD`, and the supply pads stay unmatched |
| Pad ring not continuous (no IO fillers) | real | Ring-bus pins of the IO cells on many separate layout nets (`chip_lvs_nets.py`) |
| Supply-port text missing | setup, handled | A UPF supply port with no text anywhere is compared as a net (`lvs_delete_cell_pin <top> <port> -source`) |
| Macro supply pin not wired | real | An OPEN entry with a layout net inside the macro's cluster (`X0/85`); `chip_lvs_nets.py` shows the pin alone on that net |
| Netlist supply ties that contradict the UPF | netlist | One source net is several layout nets, each a separate UPF supply. In afe the IO cells' VSSA and VSSIO_Q pins are on VSS in the netlist, while the layout keeps the VSSA ring and VSSIO(_Q) separate |
| conb_1 HI/LO | setup, handled | Extraction warnings only |
| Netlist without VPB/VNB or ring pins on some instances | setup, handled | `--tie-bulk`, `--pad-ring` (counts in `verilog_scan.txt`) |
| Several texts per supply | setup, handled | Extraction errors "Top level port name … already used" without the supply-text rules |
| `sar_afe` pins `ctln<0>` vs `ctln[0]` | setup, handled | Black box "extra pins" without the `<>` stub |

### LVS results

**d0923** (the 23 Sep routed reference DB, no macro; `$RUNS/d0923/lvs/run11`;
diagnostic `run8-nobulk`; 30 s, 2.3 GB): **MISMATCH**. 170 of 171 cells match:
every std-cell type, the SRAM and the IO black boxes. All the top cell's
mismatches are real defects of that database:

- **VDD–VSS short.** The tie-low net `LTIE_PD_TOP_LTIE_23_LONET` (a `conb_1`,
  driving pad control pins) runs on met3 at y = 2317.425. There it crosses the
  met3 landing of a VDD stripe's via stack: via3 at (2002.105, 2317.265), which
  is not part of that net's DEF route. Through the `conb_1` LO poly this joins
  VDD to VSS (path in `nanosoc_chip_pads.lvsrpt.shorts`). The `VGND: VDD`
  instance mismatches and the 16 unmatched supply pads follow from it.
- **22 signal–signal shorts** ("SHORTS AND OPENS"). For the three checked
  against the DEF, the two nets' routes overlap on met1, for example
  `n_3691`/`n_4642` at (1717.855, 2819.545).
- **No well taps** in the database. The std-cell n-wells and the substrate are
  not on VDD/VSS, which gives about 320 extra layout nets. Without VPB/VNB in
  the comparison, the unmatched nets drop from 368/34 to 48/34.
- **Pad ring not continuous.** The pads sit 142–179 µm apart with no IO filler,
  so each ring bus of the 58 IO cells is 7–10 separate layout nets.
- **The netlist itself is inconsistent.** It ties every IO cell's `VDDIO_Q`/`VSSIO_Q`
  to VDD/VSS, but the VDDIO/VSSIO pads connect them to VDDIO/VSSIO inside. So
  the source alone joins VDD with VDDIO and VSS with VSSIO: 40 source ports
  instead of 42.

**afe, flow_1 route DB** (superseded; own stream `$RUNS/afe-pre`,
LVS `afe-pre/lvs/run1`, 28 s): **MISMATCH**. 182 of 183 cells match: every
std-cell type, plus the black boxes `sar_afe`, the SRAM and every IO cell. The
real defects it found were fixed in flow_3:

- **VDD–VSS short through an SRAM.** Over the SRAMs, the vertical VDD/VSS
  stripes dropped to li1: 31 `NEW li1 … SHAPE STRIPE` segments in the DEF.
  The SRAM's own li1 bridges a VDD and a VSS stripe, at
  `control_logic_rw/delay_chain/pinv_15`, y = 2253. The cause was an empty
  macro blockage list in `power_plan.tcl`.
- **`vinp`/`vinn` open at the analog pads.** The PDK LEF of
  `sky130_ef_io__analog_pad` has P_CORE = met3 x 24.72–49.72, but the GDS
  metal spans only 27.72–46.72. Innovus landed both routes in the 3 µm
  margin, 1.7–2.3 µm off the metal (`chip_lvs_nets.py`: `vinp`/`vinn` alone on
  nets of their own). flow_3 reads a corrected LEF from
  `ASIC_ours/Cadence/inputs/sky130_ef_io__analog_pad.lef`.
- **No followpin rails.** The DEF has no FOLLOWPIN or COREWIRE wires, so the
  std-cell VPWR/VGND rails are not on the power grid.
- **About 32,700 std-cell internal nodes touched by routing**, for example a
  clock net on the clk-bar node of `dfrtp_1`. pnr's `verify_drc` of the same DB
  agrees: 6994 shorts, 6017 of them on li1.

An intermediate stream of flow_4's route DB (`$RUNS/afe-route4`)
had every IO filler at orientation N, which shorted the ring rails on the
S, E and W rows. The DB behind `GDS_READY afe` places them per side.

**afe** (the DB behind `GDS_READY afe`, `nanosoc_chip_pads_ready`, with
`sar_afe`; `$RUNS/afe/lvs/run1`; 37 s, 2.5 GB): **MISMATCH**.

- **Cells:** 201 of 202 match: every std-cell type (well taps and decaps
  included), and the black boxes `sar_afe`, the SRAM and every IO cell, filler
  and connect slice.
- **Shorts and opens:** no VDD–VSS or other supply short, no signal shorts, no
  signal opens.
- **Pass 2** (`run3-full-afe`, `--full sar_afe`): `sar_afe` and all its
  subcells also match at transistor level inside the chip.

The one top-cell OPEN entry has two causes:

- **Real: the four SRAMs' `vssd1` are not connected.** On each SRAM's `vssd1`
  ring, the only top-level shapes are Innovus via stacks at two ring corners,
  which join the SRAM's own met3 and met4 rings to each other. No VSS wire
  reaches the ring. `vccd1` is on VDD.
- **Netlist: VSSA and VSSIO_Q.** The netlist puts every IO cell's VSSA and
  VSSIO_Q pin on VSS. The layout keeps the VSSA ring separate, and the VSSIO
  pads tie VSSIO_Q to VSSIO, which matches the UPF's separate supplies. With
  those pins on VSSA/VSSIO_Q (`run2-diag-upf`), the SRAM `vssd1` opens are the
  only difference left, and the ports match 46:46.

Macro connectivity, read from the extraction (`chip_lvs_nets.py`):

| `sar_afe` pin | Layout net |
|---|---|
| `vinp` | P_CORE of `uPAD_ADC_VINP` (P_PAD = port `ADC_VINP`) |
| `vinn` | P_CORE of `uPAD_ADC_VINN` (P_PAD = port `ADC_VINN`) |
| `vdd` | VDD |
| `vss` | VSS |
| `vdda`, `vref` | VDDA |

Each IO ring bus is one layout net over all 667 IO cells. VCCD is on VDD,
VSSD on VSS, and VCCHIB on VDD through the connect slices. VDDIO, VSSIO and
VDDA carry their own labels. VDDIO_Q, VSSIO_Q, VSSA and VSWITCH are one
unlabelled net each.

**flow6** (pnr's clean full run, `flow_6_archive/dbs/nanosoc_chip_pads_signoff`;
`$RUNS/flow6/lvs/run1`; 34 s, 2.4 GB): **MATCH**.
- 195 of 195 cells match with the standard black boxes. `--full sar_afe`
  (`run2-full-afe`) also gives MATCH: 203 of 203 cells, the macro at
  transistor level.
- **SRAMs:** all four `vccd1` are on VDD and all four `vssd1` on VSS.
- **IO ring:** each bus is one net over the 667 IO cells. VCCD is on VDD and
  VSSD on VSS. VDDIO, VSSIO, VDDA, VSSA, VDDIO_Q and VSSIO_Q are separate
  nets, as in the UPF. VCCHIB is on VDD and VSWITCH is joined to VDDIO by the
  connect slices.
- **Macro pins:** as in the afe table.
- **Netlist fills:** the netlist now carries VPB/VNB itself (0 filled). The
  only pins still filled are the two analog pads' 10 ring pins each. Without
  the fill (`run3-no-autofill`) the result is MISMATCH, with 20 floating
  source nets.

**flow7** (pnr's clean full run without the SRAM-corner via3 stacks;
`$RUNS/flow7/lvs/run1`; 35 s, 2.4 GB): **MATCH**.
- 193 of 193 cells match. `--full sar_afe` (`run2-full-afe`) gives MATCH,
  201 of 201 cells.
- The SRAM, IO ring and macro nets are as in flow6 (`run1/pin_nets.txt`).
- **Netlist fills:** VPB/VNB 0. The IO ring fill is still needed for the two
  analog pads (`run3-no-autofill` gives MISMATCH, 20 floating source nets).

**flow8** (re-synthesised with `inputs/sky130_ef_io__analog_pad.lib`, which declares the analog
pads' ring supplies as pg pins; `$RUNS/flow8/lvs/run1`; 34 s, 2.4 GB): **MATCH**.
- 193 of 193 cells match. `--full sar_afe` gives MATCH, 201 of 201 cells.
- **Netlist fills no longer needed:** the netlist now carries every IO ring
  pin, the analog pads' included (0 filled), and VPB/VNB (0). The control run
  without the fills (`run3-no-autofill`) also gives MATCH.
- The SRAM, IO ring and macro nets are as in flow6 and flow7 (`run1/pin_nets.txt`).
