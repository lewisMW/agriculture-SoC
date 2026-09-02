# Executive Summary

**3 Sep 2026 — rerouted to the consolidated `sar_adc` library.** The AMS flow
(`sar_ams.flist`, `analog_views/`, `run_wrapper_ams.sh`) now reads every
behavioural cell from `analog/cadence/sar_adc` (Hee's clean-up), with the
integration fixes ported into that library's views (commit "sar_adc: port the
AMS-integration fixes", cherry-pickable onto `analog-sky130-clean-up`). Renames
to know: `cap_array_8b` → `carray_8b`, `capacitor_adc` → `mim_cap_adc`. The
committed `spice/sky130_cells.scs` still uses subckt `cap_array_8b`;
`amsd_sky130_all.scs` binds `carray_8b` to it by name until the netlists are
regenerated from `sar_adc` (update `netlist_sky130.il` to `doNL("sar_adc" ...)`
for `inverter`/`carray_8b` when doing so). The per-branch notes below predate
this and refer to the old `notech`/`sky130_analog_lib` paths.

Branch fix-ups:

## analog-sky130-dev (Hee) — cap_array_8b, cdac_8b, inverter (54e94e6)

- cap_array_8b MSB is one cap short. Layout has 127 unit caps on vbottom<7> (CC7.18 missing); schematic says m=128. Causes ~−1 LSB DNL at code 128. Fix one side so they agree.
- Don't rename inverter pins (GND IN OUT VDD) — the behavioural view has been renamed to match.
- cap_array_8b needs a cu parameter, or drop #(.cu(cu)) from cdac_8b. Currently elaboration fails without it. Dropping it is cleaner — it has no physical meaning in layout.
- Confirm sky130 cdac_8b is not meant to be swapped wholesale. It has no sampling switch and different pin names. We swap leaf cells only.
- DRC density violations (CDR/CDRW) are expected standalone — no action.

## bootstrap-sw — bootstrap_sw, inv_lvt (0d8dd22)

- Port out is declared dir=input — should be output. AMS binding uses port directions.
- Back-to-back conversions produce alternating samples 60–90 LSB low. RTC-spaced conversions are clean. Suspect the 4×53 fF boost caps can't recharge in the trigger interval. Characterise in bootstrap_sw_tb (probe vbsh/vbsl under rapid en), then publish a minimum conversion interval or strengthen the precharge. But also, not yet ruled out: wrapper FSM re-asserting adc_en too early.
- Un-nest bootstrap_switch_lib — it currently sits inside sky130_analog_lib/. Make it a sibling or merge the cells in.
- Add a switch_adc cell = one bootstrap_sw instance, pins p n ctrl vdd vss (ctrl→en, p→in, n→out). Removes a wrapper from our glue.
- Re-Check&Save to clear stale "floating net" results in the OA — the live data is fine, they mislead.

## Erick_branch — Comparator, Trim (5845df0)

- Trim instances bind to a library named SoC that doesn't exist. Netlisting fails (OSSHNL-366). Re-bind I0/I1 to sky130_analog_lib. Cannot be fixed in cds.lib — Cadence rejects two library names sharing a directory.
- Output polarity is inverted. Latch pulls the winner low, so Vp > Vn → Out_P LOW; sr_latch/sarlogic expect outp = 1. With natural wiring the SAR rails (0x00/0xff). Fix by renaming pins or adding output inverters.
- Trima trims the Vn side, not Vp (I0 → net2 = NM2 drain). Calibration pushes offset the wrong way. Swap.
- Trim uses ideal capacitor c=1.25f, not sky130 devices. Extraction measured ~1.10 fF in-context. Use sarcta__C0/sarct__trim_array or update the value.
- Rename Comparator → comparator, pins to lowercase (Vp→vp, Out_P→outp, Trima→trima…). Spectre subckt names are case-insensitive, so you can't keep both spellings.
- Keep Comparator_tb_AMS — right place for offset/trim characterisation.

## Everyone

- One flat sky130_analog_lib. No nested libraries, no SoC references.
- Rule for swappable cells: every view of a cell shares the same name, ports and parameters. All our wrappers exist where that's broken.
- Commit an in-repo cds.lib so netlisting works from a clean checkout.

## Integration (us, after the above merge)

- Confirm all 8 cells in one library, DRC clean, LVS MATCH.
- Regenerate netlists: virtuoso -nograph < AMS/netlist_sky130.il.
- Acceptance test: regenerated sky130_cells.scs contains no hand-written wrappers — no aliases, no injected cu, no outp/outn cross.
- Rebase ams-integration, drop the now-unneeded compensations.
- Re-run all 6 tests with EXTRA_DEFINES=+define+SENSING_CHECK. Clean iff no SENSING_CHECK FAIL in the log.
- Expect: mid-code DNL improves, cross removed, calibration direction correct, fifo_drain/sensing_driver stop failing.

## Two traps to know

- A passing firmware test does not mean the ADC works. The tests only check the FIFO is non-empty — a run with every code 0x00 still printed Test Passed!. Always grep SENSING_CHECK FAIL, and for swaps check Spectre's circuit inventory shows bsim4/capacitor and no worklib__<cell>__vams__*.
- The amsd block must be a source file (XRUN_EXTRA_SRC), never -analogcontrol. Passed the wrong way it's silently ignored — the run passes and the design is still fully behavioural.

Full detail, with the file-by-file coupling table, is in agriculture_soc_main/AMS/INTEGRATION.md.

# Demo

## Setup

```bash
cd ~/agriculture-SoC
git fetch origin
git checkout sky130-ams-integration
```

Not needed for the demo as sky130_cells.scs is committed, but you can regenerate netlists with:
```bash
cd ~/agriculture-SoC && git fetch origin
# 1. Extract the analog branches. PIN THE COMMITS — branch tips move and the
#    generated netlists change with them. These are the exact commits that
#    produced the committed AMS/spice/sky130_cells.scs:
#      54e94e6  analog-sky130-dev : cap_array_8b, cdac_8b, inverter
#      0d8dd22  bootstrap-sw      : bootstrap_sw, inv_lvt
#      5845df0  Erick_branch      : Comparator, Trim
for c in 54e94e6 0d8dd22 5845df0; do
  d=/tmp/$c; rm -rf $d; mkdir -p $d
  git archive $c analog | tar -x -C $d
done

# 2. Erick's Comparator binds Trim to a phantom "SoC" library — give it its own
#    directory (Cadence refuses two lib names on one path)
L=/tmp/5845df0/analog/cadence/sky130/SoC/sky130_analog_lib
rm -rf /tmp/soclib && mkdir -p /tmp/soclib
cp -r $L/data.dm $L/.oalib /tmp/soclib/ && ln -s $L/Trim /tmp/soclib/Trim

# 3. cds.lib (note: '#' comments only — '//' silently breaks DEFINEs).
#    Comparator/Trim are on 5845df0; cap_array_8b/cdac_8b/inverter are on
#    54e94e6 — point sky130_analog_lib at whichever you are netlisting.
mkdir -p /tmp/oaread && cd /tmp/oaread
cat > cds.lib <<'EOF'
INCLUDE $SKY130/cds.lib
DEFINE sky130_analog_lib /tmp/5845df0/analog/cadence/sky130/SoC/sky130_analog_lib
DEFINE SoC /tmp/soclib
DEFINE bootstrap_switch_lib /tmp/0d8dd22/analog/cadence/sky130/SoC/sky130_analog_lib/bootstrap_switch_lib
EOF

# 4. Netlist
virtuoso -nograph < ~/agriculture-SoC/agriculture_soc_main/AMS/netlist_sky130.il
```

## The demo — four acts, ~6 minutes

```bash
cd ~/agriculture-SoC/nanosoc
export SOCLABS_PROJECT_DIR=$PWD ARM_IP_LIBRARY_PATH=/opt/arm
source env/dependency_env.sh
```

### Act 1 — digital baseline (~10 s). Same SoC, dummy ADC.

```bash
make -C nanosoc_tech run_xr TESTNAME=adc_trigger_test ACCELERATOR=yes TOOL_CHAIN=gcc
```
Point at: Test Passed! — Cortex-M0 boots, runs compiled C, reads the peripheral.

### Act 2 — behavioural AMS (~15 s). Spectre now in the loop.

```bash
make -C nanosoc_tech run_xr TESTNAME=adc_trigger_test ACCELERATOR=yes TOOL_CHAIN=gcc \
     SAR_AMS_INCLUDE=yes
```
Point at: spectre completes with 0 errors — a real SAR algorithm with an analog solver, driven by firmware.

### Act 3 — real sky130 silicon (~20 s). The headline.

```bash
make -C nanosoc_tech run_xr TESTNAME=adc_trigger_test ACCELERATOR=yes TOOL_CHAIN=gcc \
     SAR_AMS_INCLUDE=yes \
     XRUN_EXTRA_SRC=$ACCELERATOR_DIR/AMS/amsd_sky130_all.scs \
     AMS_ACF=$ACCELERATOR_DIR/AMS/acf_sky130.scs \
     EXTRA_DEFINES=+define+SENSING_DEBUG
```
Point at two things in the log:

Circuit inventory:  bsim4 75   capacitor 36   resistor 52
                    (no worklib__*__vams__*_behavioral)
— proof it's actual transistors and MIM caps, not models.

fifo_push data=0x75 … 0x7e … 0x86 … 0x9e … 0xab … 0xb7 … 0xb5 …
— the CPU reading codes that trace the input sine.

### Act 4 — the verification story (~4½ min). This is the part that impresses engineers.

```bash
bash $ACCELERATOR_DIR/AMS/run_sky130_suite.sh
```
Runs a deliberately-broken configuration first, then all 6 firmware tests.

Point at, in order:
1. Negative control: 23 SENSING_CHECK FAIL lines — and the firmware still says Test Passed!. The tests only check the FIFO is non-empty, so a dead ADC passes. That's why the checker exists.
2. Then 4 tests clean, and fifo_drain_test / sensing_driver_test fail with 6 checks each — alternating samples 60–90 LSB low. A real design finding: the bootstrap switch's boost caps can't recharge between back-to-back conversions. RTC-spaced conversions are fine.

That's the strongest thing you have to show: the flow found a genuine analog defect through a firmware test.

# sky130 AMS integration guide

How to get the three analog branches into a state where the SAR ADC simulates
at device level from the nanosoc firmware tests, and what each branch owner
needs to fix first.

Status at time of writing: **it already works**, but only because the AMS glue
compensates for structural problems on the analog branches. The goal of the
polish is to remove every compensation, so the swap becomes a plain view
selection.

Verified working configuration (2026-08-04): all 6 firmware tests run against
sky130 devices for the sampling switch, capacitor array, bit drivers, comparator
and trim arrays. Spectre 0 errors / 0 warnings on every test. Codes track the
input sine and agree with the behavioural model to 1-2 LSB.

---

## 0. The one rule that makes this tidy

**All views of a cell must share a name, a port list and a parameter list.**

Every hand-written wrapper in `AMS/spice/sky130_cells.scs` exists because that
rule is broken somewhere. The acceptance test for the polish is simple:

> After the branches are fixed, regenerating `sky130_cells.scs` must produce a
> file containing **only Cadence-generated content and no hand-written
> wrappers**.

Two Cadence facts that constrain the naming, both learned the hard way:

- **Spectre subcircuit names are case-insensitive.** `Comparator` and
  `comparator` are the same cell, so a wrapper named one around the other is a
  self-reference (`amsspice: *Error: Recursive subcircuit call loop found`).
- **Cadence refuses two library names pointing at the same directory**
  (`path already belongs to LIB ...`), so a mis-bound library reference cannot
  be papered over with an alias in `cds.lib`. It has to be fixed in the data.

---

## 1. Branch `analog-sky130-dev` (Hee) — cap_array_8b, cdac_8b, inverter

### Bugs

1. **`cap_array_8b` MSB is one unit cap short.** The layout-derived CDL of
   2026-08-04 contains **127** unit caps on `vbottom<7>` (`CC7.18` is absent);
   per-bit counts are 1/2/4/8/16/32/64/**127** + 1 dummy = 255 instead of 256.
   The *schematic* netlists to `m=128`. Schematic and layout therefore disagree.
   Effect: MSB weight 127C instead of 128C, i.e. roughly **-1 LSB DNL at the
   mid-code (128) transition** plus a small gain error.
   *Action:* decide which is correct, fix the other, and confirm LVS passes.

2. **`cap_array_8b` LVS has never completed** — the run directory exists but no
   `.lvsResults` was committed. It is very likely failing on (1).
   *Action:* run to clean.

3. **`cdac_8b` has layout but no DRC or LVS run at all.**
   *Action:* run both.

4. DRC on `inverter` and `cap_array_8b` reports only `CDR.*`/`CDRW.*` **density**
   rules (1 result each). That is expected for a small cell in isolation and is
   resolved by chip-level fill — no action beyond confirming it at chip level.

### Interface work needed for clean swapping

5. **Do not change the `inverter` pin names.** They are `GND IN OUT VDD`, and
   the behavioural `adc_primitives_lib/inverter` veriloga has been renamed to
   match (see §4). Renaming either side now re-breaks the pair.

6. **`cap_array_8b` needs a `cu` parameter, or `cdac_8b` must stop passing one.**
   The behavioural `cdac_8b` instantiates `cap_array_8b #(.cu(cu))`, but the
   sky130 view has no parameters, which fails elaboration with
   `*E,CUTMIP: Too many module instance parameter assignments`.
   *Action, pick one:*
   - add an unused `cu` CDF parameter to the sky130 `cap_array_8b`, **or**
   - drop `#(.cu(cu))` from `cdac_8b` and let the behavioural view use its own
     default (preferred — the parameter has no physical meaning in layout).
   Until then the AMS glue injects `parameters cu=1f` by hand.

7. **The sky130 `cdac_8b` is not interchangeable with the behavioural one** and
   probably should not be. It contains no sampling switch, and its pins are
   `out<7:0>/bottom<7:0>/top/dummy/vdd/vss` versus the behavioural
   `vin/vout/sample/ctl/ctl_dum/vdd/vss`. The flow deliberately swaps **leaf
   cells only** and keeps the behavioural `cdac_8b` as the structural parent.
   *Action:* confirm that is the intent, and if so note it in the library so
   nobody tries to bind `cdac_8b` wholesale.

---

## 2. Branch `bootstrap-sw` — bootstrap_sw, inv_lvt

### Bugs

1. **Port `out` is declared `dir=input`.** All three signal pins (`en`, `in`,
   `out`) are inputs; `out` is the switch output. Harmless in pure SPICE, but
   the AMS elaborator uses port directions when binding, so it must be fixed.

2. **No DRC or LVS run on `bootstrap_sw` or `inv_lvt`**, although layout exists
   for `bootstrap_sw`.
   *Action:* run both.

3. **Design finding — back-to-back conversions fail.** With the real switch
   bound, conversions triggered back-to-back produce **alternating samples
   60-90 LSB low**, recovering on the next conversion:

   ```
   fifo_drain_test:     0x91 -> 0x52 -> 0x9a -> 0x3f -> 0x99 -> 0x56 -> 0x8c
   sensing_driver_test: 0x81 -> 0x3f ...  0xa5 -> 0x67 ...  0x97 -> 0x59
   ```

   RTC-spaced conversions (`adc_autonomous_test`, 16 samples per burst) are
   completely clean, so it is specific to the short trigger interval used by
   `fifo_drain_test` and `sensing_driver_test` (16 triggers with only the
   firmware's `settle()` between them).

   Most likely cause: `M2` precharges the boost node `vbsl` to `vss` while
   `enb` is high, and the 4 x 53.28 fF boost capacitors need longer to recharge
   than the trigger interval allows. A partly-restored boost gives `Ms` weak
   gate drive, high `ron`, and an incompletely charged CDAC — hence a low code,
   with the next conversion correct again.

   *Not yet separated from a second candidate:* the wrapper FSM re-asserting
   `adc_en` before the analog has settled. The way to tell them apart is to
   probe `vbsh`/`vbsl` in `bootstrap_sw_tb` (the Maestro TB already exists)
   while pulsing `en` rapidly.

   *Action:* characterise, then either publish a **minimum conversion interval**
   for the block or strengthen the precharge / enlarge the boost network.

4. Stale checker results are stored in the OA data listing floating `vdd`,
   `vss`, `enb` and several internal nets. The live database is fine — every
   device terminal resolves — so these are leftovers from an earlier
   Check&Save. *Action:* re-Check&Save to clear them, so nobody else loses time
   investigating.

### Structural work

5. **`bootstrap_switch_lib` is nested inside `sky130_analog_lib/`.** A library
   inside another library is a trap and complicates every `cds.lib`.
   *Action:* move the cells into `sky130_analog_lib`, or make the library a
   sibling directory.

6. **Add a `switch_adc` cell** whose schematic is a single `bootstrap_sw`
   instance, with pins named exactly `p n ctrl vdd vss` to match
   `adc_analog_lib/switch_adc` (mapping `ctrl->en`, `p->in`, `n->out`). That
   turns the swap into a native view selection and deletes the alias wrapper
   the AMS glue currently carries.

---

## 3. Branch `Erick_branch` — Comparator, Trim

### Bugs

1. **`Trim` instances are bound to a library named `SoC`.** Netlisting fails
   with `OSSHNL-366 ... invalid placed master 'SoC/Trim/symbol'`, because
   `Trim` actually lives in `sky130_analog_lib`. This cannot be fixed from
   `cds.lib` (see §0). *Action:* re-bind the two instances (`I0`, `I1`) to
   `sky130_analog_lib`.

2. **Output polarity is inverted relative to the behavioural convention.** The
   latch precharges `Out_P`/`Out_N` high (`PM4`/`PM0` on `Clk` low) and pulls
   the **winner** low during evaluate, so `Vp > Vn` drives `Out_P` **LOW**. The
   behavioural comparator, `sr_latch` and `sarlogic` all expect `outp = 1` when
   `vp > vn`. With the natural mapping the SAR inverts every bit decision and
   walks to a rail — measured codes were `0xff, 0x00, 0x00, ...`.
   *Action:* fix in the schematic, either by swapping the pin names or by adding
   output inverters. Until then the AMS glue crosses `outp`/`outn`, which is a
   testbench-side compensation and easy to misread later.

3. **`Trima` trims the `Vn` side, not `Vp`.** `I0` (Trima) attaches to `net2`,
   which is `NM2`'s drain — the `Vn` input branch. The behavioural model applies
   `trima` to the `vp` side. Conversion still works, but calibration pushes the
   offset the wrong way. *Action:* swap so `Trima` acts on `Vp`.

4. **`Trim` uses ideal capacitors.** The cells are spectre `capacitor c=1.25f`
   devices, not sky130 MIM/MOM. 1.25 fF is the design-intent value; extraction
   of `sarct__trim_array` measured **~1.10 fF/cap in-context** (about 12 % lower,
   because in-array fringe terminates on neighbouring bottom plates). This sets
   comparator offset-trim resolution directly.
   *Action:* use `sarcta__C0`/`sarct__trim_array`, or update the value to the
   extracted one.

5. **No DRC or LVS results for `Comparator` or `Trim`**, although both have
   layout. *Action:* run both.

### Interface work

6. **Rename `Comparator` to `comparator` and its pins to lowercase** so it
   matches `adc_analog_lib/comparator`:
   `Vp/Vn/Clk/Vdd/Vss -> vp/vn/clk/vdd/vss`, `Out_P/Out_N -> outp/outn`,
   `Trima/Trimb -> trima/trimb`. That deletes the alias wrapper.
   **Note:** because Spectre subckt names are case-insensitive you cannot keep
   both spellings — pick `comparator`.

7. `Comparator_tb_AMS` is a good addition — keep it. It is the right place to
   characterise offset and trim range, which the CPU tests cannot do.

---

## 4. What we hold on our side (do not merge until 1-3 are in)

Already on `ams-integration` (commit `439751b`):

- `sar.vams` netlist fixes (four real bugs: `.trim`->`.trima` on two instances,
  `compn_out`->`comp_outn`, `reg`->`wire` on FSM-driven outputs, missing `rstn`
  input declaration).
- `accelerator_subsystem.v` — APB wires were declared *after* the instance using
  them; Xcelium rejects this (23 errors) where other tools tolerated it.
- Firmware build fixes: `TOOL_CHAIN ?=` so `TOOL_CHAIN=gcc` works;
  `BOOTROM_TOOL_CHAIN ?= ds5` so a gcc build does not silently overflow the
  1 KB boot ROM (a gcc bootloader is ~3.1 KB and `bootrom_gen.py` truncates
  without complaint); stale `adc_trigger_test.hex` removed from git.
- `xr` simulator target and the `AMS`/`SAR_AMS_INCLUDE` hooks.
- `dependency_env.sh` honours a preset `ARM_IP_LIBRARY_PATH` (it is `/opt/arm`
  on the Cadence machine, not the committed macOS path).

Uncommitted, and **coupled to the branch fixes above**:

| file | coupling |
|---|---|
| `adc_primitives_lib/inverter/veriloga.va` | ports renamed to `GND/IN/OUT/VDD` to match §1.5 |
| `adc_analog_lib/switch_adc/verilog.vams` | gained `vdd`/`vss` to match §2.6 |
| `adc_top_lib/cdac_8b/verilog.vams` | instantiations updated for both of the above |
| `AMS/spice/sky130_cells.scs` | wrappers disappear as §1.6, §2.6, §3.2, §3.6 land |
| `AMS/sar_ams_shim.vams` | `RSRC=0` now the real switch provides impedance |
| `Wrapper/adc_apb_wrapper_rev2.v` | `SENSING_CHECK` analog-plausibility checker |
| `makefile`, `makefile.simulate` | `SAR_AMS_FLIST`, `XRUN_EXTRA_SRC` hooks |

---

## 5. Which AMS files are actually necessary

Answering directly: **most stay, but `sky130_cells.scs` should end up purely
generated, and the staged configs become optional.**

Keep, permanently:

- `netlist_sky130.il` — the OA -> Spectre netlisting procedure. This becomes
  *more* important after the merge, not less: with one library it is a single
  command, and it is the only thing that keeps the netlists honest. Nobody
  should hand-write analog netlists again.
- `spice/sky130_cells.scs` — keep committed (so the flow works without a
  Virtuoso licence) but it must become 100 % generated. Right now it carries a
  `bootstrap_sw` subckt wrapper, a `switch_adc` alias, a `comparator` alias with
  a deliberate `outp`/`outn` cross, and an injected `parameters cu=1f`. Each of
  those maps to a numbered action above; when they are all done, regenerate and
  the file should contain only Cadence output plus the two `subckt` wrappers for
  cells that were netlisted as top-level.
- `sar_ams_shim.vams` — testbench glue (supplies, differential stimulus, ADC
  clock divider). Not replaceable by any branch fix; it is the analog testbench.
- `sar_ams.flist` — source list.
- `analog_views/*.vams` — symlinks giving the OA `veriloga.va` files a `.vams`
  extension, because `xrun` will not recognise `.va`. Needed as long as any cell
  stays behavioural.
- `acf.scs` and `acf_sky130.scs` — two analysis/solver profiles. Both needed:
  device-level requires `errpreset=conservative`, behavioural does not.
  (Ablation showed `gmin` and `maxstep` are *not* needed, and
  `max_minstep_nonconv` actively does not help — do not re-add them.)
- `run_wrapper_ams.sh` — standalone wrapper-level TB, much faster than a CPU
  test for flow debugging.

Optional / prunable after the polish:

- `amsd_sky130_inv.scs`, `amsd_sky130_cdac.scs`, `amsd_sky130_full.scs` — the
  staged abstraction ladder (inverter only / + CDAC / + switch). Only
  `amsd_sky130_all.scs` is needed for the end goal. They are tiny and they are
  how you bisect when a swap breaks, so I would keep at least one intermediate,
  but there is no need for all three long-term.

---

## 6. Final integration steps (after 1-3 are merged)

1. **Confirm one flat library.** `sky130_analog_lib` should contain
   `inverter`, `cap_array_8b`, `cdac_8b`, `bootstrap_sw`, `inv_lvt`,
   `switch_adc`, `comparator`, `Trim` — every one with schematic + symbol +
   layout, DRC clean apart from density, and LVS MATCH. No nested libraries, no
   references to a `SoC` library.

2. **Commit an in-repo `cds.lib`** that defines the libraries relative to the
   repo root, so netlisting works from a clean checkout without hand-editing.

3. **Regenerate the netlists** on the Cadence machine:
   ```
   virtuoso -nograph < agriculture_soc_main/AMS/netlist_sky130.il
   ```
   Then reassemble `AMS/spice/sky130_cells.scs`. **Acceptance test:** no
   hand-written wrappers left except the `subckt` wrappers for top-level-
   netlisted cells. In particular the `outp`/`outn` cross must be gone.

4. **Rebase `ams-integration`** and drop the compensations that the branch fixes
   made unnecessary (the alias wrappers, the injected `cu`, possibly the
   `switch_adc` `vdd`/`vss` additions if a native `switch_adc` cell exists).

5. **Re-run the suite with checks on:**
   ```
   make -C nanosoc_tech run_xr TESTNAME=<test> ACCELERATOR=yes TOOL_CHAIN=gcc \
        SAR_AMS_INCLUDE=yes \
        XRUN_EXTRA_SRC=$ACCELERATOR_DIR/AMS/amsd_sky130_all.scs \
        AMS_ACF=$ACCELERATOR_DIR/AMS/acf_sky130.scs \
        EXTRA_DEFINES=+define+SENSING_CHECK
   ```
   for `adc_trigger_test adc_autonomous_test fifo_drain_test rtc_time_test
   pslverr_test sensing_driver_test`. A run is clean iff the log contains no
   `SENSING_CHECK FAIL` line.

6. **Expected changes after the fixes**, useful as a sanity check:
   - MSB cap fixed -> mid-code DNL improves; codes shift slightly near 128.
   - Polarity fixed -> the `outp`/`outn` cross is removed and codes stay correct.
   - Trim side fixed -> calibration moves offset in the intended direction.
   - Boost recharge fixed -> `fifo_drain_test` and `sensing_driver_test` stop
     reporting `SENSING_CHECK FAIL`.

---

## 7. Two things worth remembering about this flow

**A passing firmware test does not mean the ADC works.** The sensing tests only
assert that the FIFO becomes non-empty; a run with every code stuck at `0x00`
still printed `Test Passed!`. That is why `SENSING_CHECK` exists, and it was
verified against a deliberately broken configuration (23 failures caught while
the firmware still reported success). Always check for `SENSING_CHECK FAIL`, and
for cell swaps also check the Spectre **circuit inventory** in the log: the
device primitives (`bsim4`, `capacitor`) must appear and the corresponding
`worklib__<cell>__vams__*_behavioral` entries must be gone.

**The `amsd` block must be passed to `xrun` as a source file** (via
`XRUN_EXTRA_SRC`), never through `-analogcontrol`. Supplied the wrong way it is
silently ignored: the run passes, and the design is still entirely behavioural.
`-analogcontrol` carries only the analysis statement.
