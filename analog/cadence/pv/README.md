# Physical verification and extraction (`analog/cadence/pv`)

This directory holds batch DRC, LVS and parasitic extraction for the `sar_adc`
cells and the ADC macro. It also produces the netlists the AMS flow simulates
and the macro's hand-off views for the digital flow. Everything runs headless
on the Cadence box; run `source ~/.bashrc` first to get the licence and tool paths.

| Script | Does |
|---|---|
| `run_lvs.sh <LIB> <CELL>` | strmout → GDS, `si` → CDL, then Pegasus LVS. Exits 0 only on MATCH. `--rc` also writes the Quantus input. `--cdl-only` only netlists. `--blackbox SUBCELL` compares a subcell by its pins only, and `--exclude-hcell SUBCELL` compares it flattened into its parent (see below). |
| `run_drc.sh <LIB> <CELL>` | strmout + Pegasus DRC. `violations.txt` separates REAL rules from density/fill rules (CDR/CDRW), which only chip fill can meet. |
| `run_pex.sh <LIB> <CELL>` | LVS `--rc` → Quantus (`rc_coupled`, ground `vss`) → OA view `av_extracted` → `<CELL>.pex.scs`. Takes `--blackbox` and `--exclude-hcell` too. Run it on our own cells only: Hee's and Jaime's cells already have an `av_extracted` view of their own, which it would overwrite. |
| `netlist_spectre.sh <LIB> <CELL> <OUT> [views]` | Spectre netlist of a cell as `subckt <CELL> … ends`, with its children. |
| `lvs_deck.sh` | Prints the PDK LVS deck with our fixes applied (below). The deck itself isn't committed; the script generates it from `$SKY130`. |
| `rebind_moved.il` | After Erick's cells are copied from `sky130_analog_lib` into `sar_adc`, points their references at the copies and runs Check-and-Save. |
| `macro/` | SKILL that generates the ADC macro and its two placement variants: schematics (`schgen.il`, `afe_sch.il`), the comparator wrapper (`cmp_lay.il`) and the layouts (`afe_lay.il`, `AFE_VARIANT=l\|r\|b`). |
| `macro/export_macro.sh` | Writes the hand-off views (GDS, LEF, Liberty, Verilog, CDL) of `sar_afe`, `sar_afe_r` and `sar_afe_b` to `ASIC_ours/macros/sar_afe`. |
| `macro/innovus_smoke/` | Innovus smoke test of those views with `sky130_fd_sc_hd`: all three variants along the bottom of one die. |

Outputs go to `runs/` (gitignored).

## Results (18 Oct 2026, Pegasus 23.2, patched deck)

| Cell | Owner | Version | LVS | Real DRC (density/fill excluded) |
|---|---|---|---|---|
| `inverter` | Hee | PR #130 + poly fix | MATCH 4/4 | clean |
| `mim_cap_adc` | Hee | PR #130 | MATCH | clean |
| `carray_8b` | Hee | PR #130 + vssa pin fix | MATCH 11/11, 324 unit caps | clean |
| `cdac_8b` | Hee | PR #130 | compared flattened in the macro (below) | CDR.m1.1 ×9 (bit-driver inputs), CDR.li.5 ×4 (row-end taps) |
| `bootstrap_sw` | Jaime | moved into `sar_adc` (PR #130), schematic re-pointed to `inv_lvt` | MATCH 5/5 | clean |
| `trim` | Erick | `Erick_dev` (9 Oct) | MATCH 7/7, `sarcta__C0` black-boxed | clean |
| `comparator_core` | Erick | `Erick_dev` (9 Oct) + n-well fix | MATCH 17/17, `sarcta__C0` black-boxed | clean |
| `comparator` (wrapper) | — | generated | MATCH 17/17 | none of its own |
| **`sar_afe`**, `sar_afe_r`, `sar_afe_b` (ADC macro) | — | generated | **MATCH, all three** | none of their own; only `cdac_8b`'s above |

The fixes to the team's cells are commits on their branches in the PR stack:
- **Inverter:** a poly rectangle at (0.345, 1.875)–(0.675, 2.145) encloses the input contact.
- **Array:** the `vssa` pin is a real 0.3 × 0.3 µm pin instead of a 15 nm speck.
- **Switch:** Jaime's schematic is restored, with its inverter pointing at the moved `inv_lvt`.
- **Comparator:** an n-well rectangle at (1.75, 11.885)–(16.05, 13.245) merges the six Vdd PMOS wells.

`cdac_8b`'s two DRC items are Hee's to fix: his cell is used exactly as he
drew it.

### The ADC macro

`sar_afe` is the ADC's analog front end as one hard macro, 229.5 × 372 µm,
for the chip's bottom-left corner. From left to right:
- **Supply straps:** the left-hand set.
- **Hee's two `cdac_8b`:** each is a `carray_8b` with its 9 bit-driver inverters. They are stacked with a 10 µm gap that the analog inputs enter from the left edge.
- **One column:** Jaime's bootstrap switch, Erick's comparator (rotated so its inputs face the arrays) and the other switch.
- **Supply straps:** the right-hand set.

`macro/afe_lay.il` generates the layouts and `macro/afe_sch.il` the
schematics; the layout script reads the leaf cells' pin positions from their
layouts.

- **Digital pins** (ctlp/ctln, sample, clk, trima/trimb, outp/outn): met3 stubs on the right edge, on the `sky130_fd_sc_hd` met3 tracks.
- **Analog inputs** (vinp/vinn): met3 stubs on the left edge.
- **Supplies:** six full-height met4 straps. From each edge inward they are `vss`, `vdda` (the CDAC reference and the switches, as in Hee's `cdac_8b` schematic) and `vdd` (the comparator).
- **met5:** used only by the comparator's clock and the switches' supply runs.
- **Variants:** `sar_afe_r` is `sar_afe` mirrored (inputs on the right), and `sar_afe_b` is `sar_afe` rotated by 90° (inputs at the bottom, digital pins as met2 on the top edge, supply bands along its top and bottom). All three share the schematic and the internal layout.

**`cdac_8b` is compared flattened** (`--exclude-hcell cdac_8b`). Hee's
`cdac_8b` schematic contains the bootstrap switch, but its layout doesn't: in
the macro the switch sits beside it, as in the floorplan sketch. So
`cdac_8b` can't be a correspondence point of its own. With
`lvs_exclude_hcell`, Pegasus compares its contents as part of the macro,
which checks every device and connection all the same. Two more quirks of
the cell, as of 18 Oct:
- **Stale `vout` stub:** its `vout` stub sits where the array's `vtop` pin was before Hee's 12 Oct change, and it now touches the array's `vssa` plane. The macro joins the array's `vtop` riser itself and leaves the stub alone, so the stub is just part of `vss`.
- **Pin names:** its layout pins are named `vdd`/`vss`, while the schematic's are `vdda`/`vssa`.

`macro/export_macro.sh` writes the views for the digital flow
(`ASIC_ours/macros/sar_afe/README.md`).

**Extraction** (`run_pex.sh sar_adc sar_afe --blackbox sarcta__C0 --exclude-hcell cdac_8b`, rc_coupled):

- Devices: 656 MIM caps and 98 FETs (fingers and multipliers expanded).
- Parasitics: 13.9k C and 10.4k R.
- MOM caps: the trims' 36 MOM unit caps stay as black boxes, netlisted from their schematic (1.25 fF each).

The netlist (~1.5 MB) is **not committed**; regenerate it. Its ports must match the schematic netlist's exactly, and the script checks this.

## The trim's MOM unit cap is compared as a black box

Erick's trim builds each bit's capacitance from `sarcta__C0`, a metal-finger
(MOM) unit cap: 8/4/2/1/1 units per bit plus 2 dummies, all inside
`sarct__trim_array`. No device rule extracts a capacitor from plain metal. So
`run_lvs.sh --blackbox sarcta__C0` adds `lvs_black_box sarcta__C0 -source_layout`
to the deck, which is the same setting as Erick's LVS run.

With the black box, every unit's two terminals must connect to the right nets on
both sides. The bit wiring of the array is therefore checked, where an ideal
`lvsIgnore` cap would skip it. In extraction, the black-box units are netlisted
from the schematic (1.25 fF nominal; the July in-context extraction measured
about 1.10 fF), and the wiring around them is extracted.

## The PDK LVS deck needs three fixes (`lvs_deck.sh`)

These are fixes to `$SKY130/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl` as shipped.

1. **met2 pins never attach.** The deck has `attach met3_pin met2` where it should have `attach met2_pin met2`. Labels on met2 pins never attach, so a met2-pinned cell has 0 layout pins.
2. **MIM caps crash Pegasus 24.1.** MIM caps (`cap_mim_m3__base`) take l/w from `angle` edge layers, passed to the device as auxiliary layers. On Pegasus 24.1, any cell containing capm aborts with "Internal error during runset evaluation". This is the crash Hee and Jaime hit; it was bisected on 6 Oct.
   - The fix derives l = perimeter/4 and w = area/l, which is exact for square caps. Every MIM cap in the SAR is square.
   - A non-square cap fails the L/W check rather than passing.
3. **Parallel caps lose their l/w.** Parallel caps were merged with no rule for l/w, so both sides read `<missing>` and the cell fails; the bootstrap switch's 4 boost caps hit this. The fix is `lvs_reduce no -parallel_caps`.

**Use Pegasus 23.2.** Even with the fixes, 24.1 attaches each pin label to two
co-located nets and reports false opens. Hee's `carray_8b` matches on 23.2 and
mismatches on 24.1, with the same GDS, CDL and deck. The scripts default to
`/opt/cadence/installs/PEGASUS232`; override it with `PEGASUS_BIN`.

## Batch CDL netlisting

`si -batch` fails with `OSSHNL-411 … SKILL error while formatting devices`
unless `si.env` defines the full set of variables the CDL Out form writes:
`shrinkFACTOR`, `checkScale`, `pinMAP`, `preserveDIO`, `checkDIOAREA`,
`checkDIOPERI`, `checkCAPPERI`, and so on. It also needs `CDS_Netlisting_Mode=Analog`.
`run_lvs.sh` writes all of them.

A schematic edited without Check-and-Save fails with `OSSHNL-109 … modified
since the last extraction`. The GUI netlister doesn't complain, but `si` does;
open the cell, run Check-and-Save, and save it (`rebind_moved.il` does this for
Erick's cells).

## Quantus

The port ships `quantus/extraction/typical` and `extview.trp`, but no technology
library and no `corner.defs`. `run_pex.sh` assembles both in its run directory.

Extracted-view output also needs `-cdl_out_map_directory`, which is the LVS
run's `si` directory. The normal Spectre netlister then netlists the OA
extracted view, so devices come out with the model names the sky130 model files
define (`nfet_01v8`, `cap_mim_m3_1 l= w=`). Parasitics are plain
`capacitor`/`resistor`.
