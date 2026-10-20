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

## Results (20 Oct 2026, Pegasus 23.2, patched deck)

| Cell | Owner | Version | LVS | Real DRC (density/fill excluded) |
|---|---|---|---|---|
| `inverter` | Hee | 19 Oct + poly fix | MATCH | clean |
| `mim_cap_adc` | Hee | PR #130 | MATCH | clean |
| `carray_8b` | Hee | 19 Oct (`vtop` on the right edge, `vssa` plane as the pin) | MATCH, 324 unit caps | clean |
| `cdac_8b` | Hee | 20 Oct (switch inside, `vref` pin) | MATCH | clean |
| `bootstrap_sw` | Jaime | moved into `sar_adc`; Hee's 20 Oct schematic on `inv_lvt` | MATCH | clean |
| `trim` | Erick | `Erick_dev` (9 Oct) | MATCH 7/7, `sarcta__C0` black-boxed | clean |
| `comparator_core` | Erick | `Erick_dev` (9 Oct) + n-well fix | MATCH 17/17, `sarcta__C0` black-boxed | clean |
| `comparator` (wrapper) | — | generated | MATCH 17/17 | none of its own |
| **`sar_afe`**, `sar_afe_r`, `sar_afe_b` (ADC macro) | — | generated | **MATCH, all three** | clean |

The fixes to the team's cells are commits on their branches in the PR stack:
- **Inverter:** a poly rectangle at (0.345, 1.875)–(0.675, 2.145) encloses the input contact (licon.8/8a). Hee's 19 Oct inverter still needs it; with it, `cdac_8b` is clean too.
- **Comparator:** an n-well rectangle at (1.75, 11.885)–(16.05, 13.245) merges the six Vdd PMOS wells.

Two earlier fixes are no longer needed: Hee's 19 Oct `carray_8b` makes the
whole `vssa` plane its pin, and his 20 Oct `bootstrap_sw` schematic points its
inverter back at `inv_lvt` himself.

### The ADC macro

`sar_afe` is the ADC's analog front end as one hard macro, 260 × 429.32 µm,
for the chip's bottom-left corner. From bottom to top:
- **Supply buses:** one met3 bus per supply, joining that supply's left and right straps.
- **Hee's two `cdac_8b`:** each is a `carray_8b`, its 9 bit-driver inverters and Jaime's bootstrapped switch. N sits at the bottom and P above it, mirrored, so both cells' input and top-plate corners face a 12 µm gap. The analog inputs come in from the left edge straight to those corners.
- **Supply buses** again.

Erick's comparator sits to the right of the CDACs, level with the gap, rotated
so its inputs face them. `macro/afe_lay.il` generates the layouts and
`macro/afe_sch.il` the schematics; the layout script reads the leaf cells'
pin positions from their layouts.

- **Digital pins** (ctlp/ctln, sample, clk, trima/trimb, outp/outn): met3 stubs on the right edge, on the `sky130_fd_sc_hd` met3 tracks. Each CDAC's `ctl` pins (on its right edge) run straight across.
- **Analog inputs** (vinp/vinn): met3 stubs on the left edge.
- **Supplies:** eight full-height met4 straps. From each edge inward they are `vss`, `vdda` (the switches), `vref` (the CDAC reference: Hee's bit drivers) and `vdd` (the comparator). Each CDAC's supply pins, on its outer edge, drop onto the buses; its `vssa` is tied to `vss`.
- **met5:** used only by the comparator's clock.
- **Variants:** `sar_afe_r` is `sar_afe` mirrored (inputs on the right), and `sar_afe_b` is `sar_afe` rotated by 90° (inputs at the bottom, digital pins as met2 on the top edge, supply bands along its top and bottom). All three share the schematic and the internal layout.

**`cdac_8b` is an ordinary subcell now.** Until 20 Oct its schematic held the
switch and its layout didn't, so the macro placed the switch beside it and
LVS compared `cdac_8b` flattened (`--exclude-hcell cdac_8b`). Hee's 20 Oct
layout has the switch and matches its schematic on its own, so the macro is
compared hierarchically and the option is gone from the macro's commands.

**Symbols:** `afe_sch.il` regenerates the schematics. A supply pin added
later (`vdda` on 18 Oct, `vref` on 20 Oct) is added to the existing symbols by
`m1SymAddPin` (`macro/schgen.il`), because `schViewToView` can't overwrite a
symbol in batch mode.

`macro/export_macro.sh` writes the views for the digital flow
(`ASIC_ours/macros/sar_afe/README.md`).

**Extraction** (`run_pex.sh sar_adc sar_afe --blackbox sarcta__C0`, rc_coupled):

- Devices: 656 MIM caps and 98 FETs (fingers and multipliers expanded).
- Parasitics: 12.9k C and 10.6k R.
- MOM caps: the trims' 36 MOM unit caps stay as black boxes, netlisted from their schematic (1.25 fF each).

The netlist (~1.5 MB) is **not committed**; regenerate it. Its ports must match the schematic netlist's exactly, and the script checks this.

**AMS regression** (`AMS/run_afe_suite.sh sch|pex`, 20 Oct): the six firmware
tests run the chip's own `sar_adc` RTL around the macro. With both the
schematic and the extracted macro, all six pass, Spectre is clean, the
`SENSING_CHECK` counts are the same as before the rebuild, and the negative
control gives 23 FAILs.

The remaining `SENSING_CHECK` step failures don't point to an ADC defect:
- the suite clocks the ADC three times faster than the chip will;
- the triggers of two tests alias the test tone.

At the chip's ADC clock the macro matches an ideal model per sample: within
1 LSB as a schematic and 2 LSB extracted. In the extraction, a conversion
within 10 µs of the previous one carries a +3 % gain error that conversions
after a longer idle don't have (+0.65 %); the rebuild didn't change it.
Details are in `agriculture_soc_main/AMS/INTEGRATION.md`.

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
