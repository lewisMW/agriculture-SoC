# Executive Summary

**20 Oct 2026: the macro is rebuilt on Hee's final `cdac_8b`, with its own
`vref`. Accuracy is unchanged: within 1 LSB as a schematic and 2 LSB
extracted at the chip's ADC clock.**

- **Cells:** Hee's `cdac_8b` now carries the bootstrapped switch and passes LVS against its own schematic. Its bit drivers run from a separate `vref` (the CDAC reference, to be heavily decoupled) and the switch from `vdda`. `carray_8b` has `vtop` on its right edge and its whole `vssa` plane as the pin. The inverter keeps PR 2's poly fix.
- **Floorplan:** N at the bottom and P above it, mirrored, so both cells' input and top-plate corners face a 12 µm gap; the macro no longer places switches of its own. 260 × 429.32 µm. See `ASIC_ours/macros/sar_afe/README.md`.
- **`vref`:** a macro pin of its own, with straps and buses. `sar_adc`, `ADC/sim/sar_afe_model.v`, the `sar_afe` Verilog-AMS view and both netlists carry it, and the shim supplies it with its own decoupling (`CDEC_REF`, 10 pF like the other rails for now). The behavioural `cdac_8b` still has one supply, which the macro's Verilog-AMS view takes from `vref`.
- **LVS:** MATCH for all three cells, with `cdac_8b` as an ordinary subcell (no more `--exclude-hcell`). **DRC:** no real violations.
- **Extraction:** 98 FETs, 656 MIM caps, 12.9k C, 10.6k R.

Results, 20 Oct, on the exact tree of the rebuilt stack:
- **Suite** (`ADC_CLK_DIV` 4, as the suite runs it): with the schematic macro (75 BSIM4, 692 C) and the extracted macro (98 BSIM4, 13.6k C), 6/6 firmware PASS and Spectre 0 errors and 0 warnings. The `SENSING_CHECK` counts are exactly those of 18 Oct (schematic: adc_autonomous 1, fifo_drain 6, sensing_driver 8; extracted: adc_trigger 1, adc_autonomous 1, fifo_drain 7, sensing_driver 8). The negative control gives 23 FAILs in both.
- **At the chip's ADC clock** (`ADC_CLK_DIV` 12, per sample against the ideal model, 112 samples of adc_trigger, adc_autonomous and fifo_drain):
  - Schematic: −1..+1 LSB; fit gain +0.30 %, offset +0.09 LSB.
  - Extracted: −2..+2 LSB; fit gain +2.55 %, offset +0.06 LSB.
  - Split by the time since the previous conversion, as on 19 Oct: within 10 µs (90 samples) +3.03 %, after a longer idle (22) +0.65 %; on 19 Oct +3.0 % and +0.4 %. The rebuild re-routed the top plate, rewired every supply and separated `vref`, and the effect didn't move, so it isn't in that wiring. The switch's boost recharge is still the leading candidate.

**18 Oct 2026: the macro is rebuilt for the chip's bottom-left corner,
on the team's own cells.** *(Superseded by the 20 Oct entry above for the
cells, the floorplan and the supplies.)*

- **Floorplan** (the team's sketch):
  - Hee's two `cdac_8b` are stacked on the left, used exactly as Hee drew them.
  - Jaime's two bootstrap switches and Erick's comparator sit in a column to their right.
  - The analog inputs enter from the left edge, and every digital pin is on the right edge, facing the SAR logic.
  - `sar_afe_r` (mirrored) and `sar_afe_b` (rotated, inputs at the bottom) are the same layout. See `ASIC_ours/macros/sar_afe/README.md`.
- **Cells:**
  - Hee's PR #130: `cdac_8b`, `carray_8b` with a real `vssa` pin, the `inverter` with its licon.8 fix, and the 10-cycle `sarlogic`.
  - Jaime's switch, with its schematic back on `inv_lvt`.
  - Erick's comparator and trim, with the n-well fix.
- **New supply pin `vdda`:** the CDAC reference (Hee's bit-driver inverters) and the switches, as Hee's `cdac_8b` schematic has it. The `sar_afe` Verilog-AMS view and both netlists carry it, and the shim supplies it.
- **LVS:** MATCH for all three cells. Hee's `cdac_8b` is compared flattened: its schematic contains the switch, its layout doesn't.
- **DRC:** only `cdac_8b`'s own two rules remain.
- **Extraction:** 98 FETs, 656 MIM caps, 13.9k C, 10.4k R.

Results, 18 Oct, on the exact `stack/ams-integration` tree (shim → `sar_adc` → `sar_afe` bound to its netlist; `ADC_CLK_DIV` 4, as the suite runs it):
- **Schematic macro:** 6/6 firmware PASS, Spectre 0 errors and 0 warnings, 75 BSIM4 and 692 capacitors. `SENSING_CHECK` reports adc_autonomous 1, fifo_drain 6 and sensing_driver 8, and is clean on the rest. These are the same counts the old macro gave with the same RTL, so the rebuild changes nothing here. The negative control gives 23 FAILs.
- **Extracted macro:** 6/6 firmware PASS, Spectre 0 errors and 0 warnings, 98 BSIM4 and 14.6k capacitors, with no behavioural front-end cells. `SENSING_CHECK` reports adc_trigger 1, adc_autonomous 1, fifo_drain 7 and sensing_driver 8 (13 Oct: 0/0/9/5), and is clean on rtc_time and pslverr. The negative control gives 23 FAILs.
- **What the FAILs mean:** they are not an ADC defect; see the next section.

**18–19 Oct 2026: the AMS suite runs the chip's own ADC RTL. At the chip's
ADC clock the macro matches an ideal model to 1 LSB as a schematic and 2 LSB
extracted.**

- **Same RTL as the chip:**
  - `sar_ams_shim` now instantiates `agriculture_soc_main/ADC/sar_adc.v`, the synthesisable ADC that replaces `dummy_adc` in `adc_apb_wrapper_rev2`. It contains the clock divider, Hee's 10-cycle `sarlogic` (PR #130), the NAND comparator latch (two sky130 nand2) and `sar_afe`.
  - The shim only provides the supplies (now with `vdda`) and the sine. The behavioural `sar` and `sr_latch` are no longer used.
  - Plain-digital simulation uses `ADC/sim/sar_afe_model.v` instead of `dummy_adc`. It is an ideal charge-redistribution model driven by the same 5 kHz sine.
- **A reference code for every sample:**
  - The digital timing is identical in all three configurations, so each FIFO sample can be compared at the same time stamp (`EXTRA_DEFINES=+define+SENSING_DEBUG`).
  - `AMS/cmp_codes.py IDEAL_LOG AMS_LOG ...` pairs the samples and fits the error as offset, gain and lag.
  - The behavioural views (`run_afe_suite.sh beh`) give exactly the model's codes on all 170 samples of four tests.
- **Schematic macro, as the suite runs it** (`ADC_CLK_DIV` 4 at the 100 MHz FAST_SIM clock):
  - 6/6 firmware PASS. Spectre reports 0 errors and 0 warnings; the inventory is 75 BSIM4 and 692 capacitors.
  - `SENSING_CHECK` reports adc_autonomous 1, fifo_drain 6 and sensing_driver 8, and is clean on the other three. The negative control gives 23 FAILs.
  - Against the model the codes are 33 LSB low to 8 LSB high (mean about 9 LSB low), and read 0x3F where the model gives 0x47 to 0x60.
- **Schematic macro at the chip's ADC clock** (`ADC_CLK_DIV` 12: a 240 ns sar_clk period, as 33 MHz / 8 on the chip):
  - It is within ±1 LSB of the model on all 147 samples of adc_autonomous, fifo_drain and sensing_driver.
  - So the 0x3F trough and the low codes come from running the ADC three times faster than the chip will. For these large errors this supersedes the bootstrap-recharge explanation of 6 and 13 Oct.
  - At `ADC_CLK_DIV` 12, sensing_driver_test fails its own "FIFO empty after clear" check, because the firmware assumes a conversion takes no more cycles than at 4.
  - To reproduce, add `-defparam nanosoc_tb.u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_exp.u_ss_accelerator.sensor_wrapper.ADC_CLK_DIV=12` to `XRUN_EXTRA_SRC`.
- **Extracted macro at the chip's ADC clock** (19 Oct, same tree and settings; adc_trigger, adc_autonomous and fifo_drain):
  - Firmware PASS, Spectre 0 errors and 0 warnings. `SENSING_CHECK` is clean on adc_trigger and adc_autonomous. fifo_drain's 11 FAILs are the aliasing ones, the same 11 as the model's.
  - Against the model the codes are −2 to +2 LSB on all 112 samples, with no 0x3F anywhere. The trough samples (0x46 to 0x5d) are within 1 LSB.
  - **Back-to-back conversions carry a +3.0 % gain error.** That covers adc_trigger, adc_autonomous and the start of fifo_drain, 90 samples. The codes spread up to 2 LSB away from mid-scale. Conversions after an idle (fifo_drain's 22 sparse samples) show +0.4 %, and the schematic shows +0.3 % either way.
  - So something in the layout recovers slowly between conversions about 2 µs apart. `sarlogic` gives every conversion the same one-cycle sample phase, so only the history differs.
  - Ruled out: the `vdda` wiring (about 190 Ω to the bit drivers, a 2 mV drop), and a static top-plate capacitance, which the idle samples would show too.
  - One candidate is the switch's boost recharge. The next step is a standalone run of the extracted macro with back-to-back conversions, probing the boost nodes, the top plates and the bit-driver supplies.
- **`SENSING_CHECK` on fifo_drain and sensing_driver:**
  - The model and the behavioural views fail it too, with 11 and 12 FAILs.
  - These tests trigger about every 108 µs and 42 µs, which aliases the 5 kHz sine, so consecutive samples are up to 113 LSB apart.
  - With a 500 Hz sine (`-defparam ...sensor_wrapper.u_adc.FIN_HZ=500`) the model passes both tests. The schematic at `ADC_CLK_DIV` 4 then fails sensing_driver twice, at the 0x3F trough.
  - The step check is therefore weak in both directions. Comparing each sample with the model's code is the stronger check.
- **Open, found while wiring the RTL:**
  - **Calibration diverges.** `sarlogic` assumes that raising `trima` raises the `vinp` side, but the macro lowers it (see "`Trima` trims the `Vn` side" below). The fix goes in `sarlogic`, or as a `trima`/`trimb` cross in `sar_adc`.
  - **Two conversions per trigger.** `wrapper_control_2` holds `en` until the synchronised `valid` arrives. Harmless, but it doubles the ADC's power.

**13 Oct 2026: the macro is rebuilt on the team's latest cells and handed to
the digital flow.**

- **Cells:** `sar_afe` now uses Erick's own LVS-clean comparator and trim (`Erick_dev`, 9 Oct) and Hee's cap array, MIM cap and inverter layouts (PR #130, 12 Oct).
- **MOM caps:** the trim's MOM unit cap is compared as a black box in LVS. The netlists therefore carry 36 `sarcta__C0` units (1.25 fF each) where the 6 Oct netlists had 10 ideal trim caps.
- **LVS:** MATCH 34/34 at every level.
- **DRC:** only two leaf-cell items remain, both with their owners: comparator n-well spacing and inverter licon.8.
- **Hand-off:** the pins were reworked for P&R. vinp/vinn are met4 pins on the top edge, and vdd/vss are full-height met4 straps. The hand-off views (GDS, LEF, a Liberty file per corner, and the Verilog port list) are in `ASIC_ours/macros/sar_afe`; see its README.

Results, 13 Oct, with the same suite and checks as 6 Oct:
- **Schematic macro:** 6/6 firmware PASS. `SENSING_CHECK` reports fifo_drain 7 and sensing_driver 6 and is clean on the other four tests, which is identical to 6 Oct.
- **Extracted macro:** 6/6 firmware PASS. Spectre reports 0 errors and 0 warnings on every test. The inventory is 98 BSIM4 and 14.4k capacitors (MIM, MOM units and parasitics), with no behavioural front-end cells. `SENSING_CHECK` reports fifo_drain 9 and sensing_driver 5 and is clean on the rest, which is identical to 6 Oct. The negative control gives 23 FAILs.

**6 Oct 2026: the whole analog front end is one macro, `sar_adc/sar_afe`.**
`sar.vams` now instantiates `sar_afe`. This is the analog content that used
to sit in `sar`: two `cdac_8b` (bootstrapped switch, `carray_8b`, bit drivers)
and the `comparator`. `sarlogic` and `sr_latch` stay digital. The AMS flow now
makes a single swap, `config cell=sar_afe use=spice`, to one of two
*generated* netlists. There are no hand-written wrappers left:

| Config | Netlist bound to `sar_afe` | Made by |
|---|---|---|
| (none) | behavioural views | — |
| `amsd_sky130_afe_sch.scs` | `spice/sar_afe.sch.scs`: schematic, transistor level | `analog/cadence/pv/netlist_spectre.sh sar_adc sar_afe` |
| `amsd_sky130_afe_pex.scs` | `spice/sar_afe.pex.scs`: Quantus RC extraction of the LVS-clean macro layout (not committed, ~1.5 MB) | `analog/cadence/pv/run_pex.sh sar_adc sar_afe` |

Run all 6 firmware tests with `SENSING_CHECK` using
`AMS/run_afe_suite.sh sch|pex|beh`. `NEG=1` first runs a negative control
(outp/outn swapped at the macro ports), which must produce FAILs. The macro's
layout, schematic and LVS/DRC/PEX flow are described in
`analog/cadence/pv/README.md`.

Results, 6 Oct:
- **Schematic macro:** 6/6 firmware PASS. `SENSING_CHECK` is clean on
  adc_trigger, adc_autonomous, rtc_time and pslverr. fifo_drain (7) and
  sensing_driver (6) show the known bootstrap-recharge jumps on back-to-back
  conversions (the 0x3F signature). The negative control gives 23 FAILs.
- **Extracted macro (the M1 sign-off):** 6/6 firmware PASS. Spectre reports
  0 errors and 0 warnings on every test; the inventory is 98 BSIM4, 13.6k C
  and 11.4k R, with no behavioural front-end cells. `SENSING_CHECK` is clean
  on the same four tests; fifo_drain (9) and sensing_driver (5) show the same
  recharge jumps as the schematic run. The negative control gives 23 FAILs
  while the firmware still says "Test Passed!". The suite takes about 50 min
  (about 20x the schematic).
- Remaining analog finding, unchanged: the bootstrap switch's boost caps
  don't recharge between back-to-back conversions (see the bootstrap-sw
  section below and the 0x3F trough). It is the open item for M3, not a
  regression. **18 Oct:** superseded. The suite clocks the ADC three times
  faster than the chip, and at the chip's rate there is no such failure (see
  the top).

What changed under the AMS flow on 6 Oct:
- main merged in. The inverter's views now use (out, in, vdd, vss), so the
  leaf-level `amsd_sky130_all.scs` + `spice/sky130_cells.scs` no longer bind
  correctly. They are marked superseded and kept for history only.
- Erick's Comparator/Trim moved into `sar_adc` as `comparator_core`/`trim`.
  The 6 Oct runs used a local LVS repair of the 28 Sep cells. Erick's own
  fix of 9 Oct replaced that repair, which was never merged (see 13 Oct).
- `sar_adc/comparator` has a schematic and layout that wrap the core under
  the behavioural pin names. Two crosses are now *in the design*, not in AMS
  glue: outp ← Out_N (the latch pulls the winner low), and trima ← Trimb
  (the trim that lowers vp loads net3).

**3 Sep 2026 — rerouted to the consolidated `sar_adc` library.** The AMS flow
(`sar_ams.flist`, `analog_views/`, `run_wrapper_ams.sh`) now reads every
behavioural cell from `analog/cadence/sar_adc` (Hee's clean-up), with the
integration fixes ported into that library's views (commit "sar_adc: port the
AMS-integration fixes", cherry-pickable onto `analog-sky130-clean-up`). Renames
to know: `cap_array_8b` → `carray_8b`, `capacitor_adc` → `mim_cap_adc`. The
subckt in `spice/sky130_cells.scs` was renamed to `carray_8b` by hand (AMSD
needs `config cell=` to match the subckt name; `portmap` does not rename);
regenerating from `sar_adc/carray_8b` produces the same name (update
`netlist_sky130.il` to `doNL("sar_adc" ...)` for `inverter`/`carray_8b`).
Verified 3 Sep: all four demo Acts bit-identical to the 4 Aug baseline.
Gotchas found on the way: `xrun -ams` cannot parse SystemVerilog (`-ams` and
`-sv` are mutually exclusive), so the generated `bootrom.sv` must stay
Verilog-2001; and non-interactive shells on the Cadence box need
`LANG=en_US.UTF-8` or `filelist_compile.py` dies on the `©` in flist headers.
The per-branch notes below predate this and refer to the old
`notech`/`sky130_analog_lib` paths.

Branch fix-ups:

## analog-sky130-dev (Hee) — cap_array_8b, cdac_8b, inverter (54e94e6)

- cap_array_8b MSB is one cap short. Layout has 127 unit caps on vbottom<7> (CC7.18 missing); schematic says m=128. Causes ~−1 LSB DNL at code 128. Fix one side so they agree.
- Don't rename inverter pins (GND IN OUT VDD) — the behavioural view has been renamed to match.
- cap_array_8b needs a cu parameter, or drop #(.cu(cu)) from cdac_8b. Currently elaboration fails without it. Dropping it is cleaner — it has no physical meaning in layout.
- Confirm sky130 cdac_8b is not meant to be swapped wholesale. It has no sampling switch and different pin names. We swap leaf cells only.
- DRC density violations (CDR/CDRW) are expected standalone — no action.

## bootstrap-sw — bootstrap_sw, inv_lvt (0d8dd22)

- Port out is declared dir=input — should be output. AMS binding uses port directions.
- Back-to-back conversions produce alternating samples 60–90 LSB low. RTC-spaced conversions are clean. Suspect the 4×53 fF boost caps can't recharge in the trigger interval. Characterise in bootstrap_sw_tb (probe vbsh/vbsl under rapid en), then publish a minimum conversion interval or strengthen the precharge. But also, not yet ruled out: wrapper FSM re-asserting adc_en too early. **18 Oct:** neither; the suite clocks the ADC three times faster than the chip (see the top).
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
2. Then 4 tests clean, and fifo_drain_test / sensing_driver_test fail with 6 checks each — alternating samples 60–90 LSB low. A real design finding: the bootstrap switch's boost caps can't recharge between back-to-back conversions. RTC-spaced conversions are fine. (**18 Oct:** superseded. The suite clocks the ADC three times faster than the chip; at the chip's rate these samples are within 2 LSB of the ideal model. See the top.)

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

3. **Design finding — back-to-back conversions fail.** (**18 Oct:**
   superseded; see the top. The suite clocks the ADC three times faster than
   the chip, and at the chip's rate back-to-back conversions are within 2 LSB
   of the ideal model.) With the real switch
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
