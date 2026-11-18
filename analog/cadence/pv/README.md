# Physical verification and extraction (`analog/cadence/pv`)

This directory holds batch DRC, LVS and parasitic extraction for the `sar_adc`
cells and the ADC macro. It also produces the netlists the AMS flow simulates
and the macro's hand-off views for the digital flow. Everything runs headless
on the Cadence box; run `source ~/.bashrc` first to get the licence and tool paths.

| Script | Does |
|---|---|
| `run_lvs.sh <LIB> <CELL>` | strmout → GDS, `si` → CDL, then Pegasus LVS. Exits 0 only on MATCH. `--rc` also writes the Quantus input. `--cdl-only` only netlists. `--blackbox SUBCELL` compares a subcell by its pins only, and `--exclude-hcell SUBCELL` compares it flattened into its parent (see below). |
| `run_drc.sh <LIB> <CELL>` | strmout + Pegasus DRC. `violations.txt` separates REAL rules from density/fill rules (CDR/CDRW), which only chip fill can meet. |
| `run_pex.sh <LIB> <CELL>` | LVS `--rc` → Quantus (`rc_coupled`, ground `vss`) → OA view `av_extracted` → `<CELL>.pex.scs`. Takes `--blackbox`, `--exclude-hcell` and `--filter-source` too. Run it on our own cells only: Hee's and Jaime's cells already have an `av_extracted` view of their own, which it would overwrite. |
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
| `carray_8b` | Hee | 19 Oct (`vtop` on the right edge, `vssa` plane as the pin) + plane slots (19 Nov) | MATCH, 324 unit caps | clean |
| `cdac_8b` | Hee | 20 Oct (switch inside, `vref` pin) | MATCH | clean |
| `bootstrap_sw` | Jaime | moved into `sar_adc`; Hee's 20 Oct schematic on `inv_lvt`; narrower via stack (19 Nov) | MATCH | clean |
| `trim` | Erick | `Erick_dev` (9 Oct) | MATCH 7/7, `sarcta__C0` black-boxed | clean |
| `comparator_core` | Erick | `Erick_dev` (9 Oct) + n-well fix | MATCH 17/17, `sarcta__C0` black-boxed | clean |
| `comparator` (wrapper) | — | generated | MATCH 17/17 | none of its own |
| **`sar_afe`**, `sar_afe_r`, `sar_afe_b` (ADC macro) | — | generated | **MATCH, all three** | clean |

The fixes to the team's cells are commits on their branches in the PR stack:
- **Inverter:** a poly rectangle at (0.345, 1.875)–(0.675, 2.145) encloses the input contact (licon.8/8a). Hee's 19 Oct inverter still needs it; with it, `cdac_8b` is clean too.
- **Comparator:** an n-well rectangle at (1.75, 11.885)–(16.05, 13.245) merges the six Vdd PMOS wells.
- **Bootstrapped switch (19 Nov):** the via stack from the boost capacitors' top-plate strap (met4) down to met2 has 2 × 2 cuts instead of 3 × 2. See [below](#the-shuttles-decks-and-the-solid-metal-guideline-19-nov-2026).
- **Capacitor array (19 Nov):** the met2 `vssa` plane has five more slots, so that no solid met2 square above 30 µm fits. See below as well.

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

**Extraction** (`run_pex.sh sar_adc sar_afe --filter-source "C (CP)"`, rc_coupled):

- Devices: 656 MIM caps and 98 FETs (fingers and multipliers expanded).
- Parasitics: 13.1k C and 10.2k R (12.2k and 10.3k before the 19 Nov slots in the `vssa` plane).
- MOM caps: the trims' 36 MOM unit caps are extracted from their metal (1.00 fF each between the plates, plus the plates' strays); the netlist has no ideal capacitor. See below.

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

## The shuttle's decks and the solid-metal guideline (19 Nov 2026)

ChipFoundry's precheck runs its own KLayout deck on the chip (`sky130A_mr.drc`
of `cf-precheck`, once for FEOL and once for BEOL;
`ASIC_ours/openframe/signoff/run_precheck_native.sh` has the command lines), and
its design review asks for no solid metal wider than 30 µm. The PDK's Pegasus
deck checks neither, so the macro's GDS is also checked on its own. Two layout
items came out of that, both fixed by SKILL in batch, each with the smallest
change that clears it:

**`MR_capm.SP.2` in `bootstrap_sw`.** The rule measures from a MIM capacitor's
bottom plate as the deck draws it (capm grown by 0.14 µm) to any met3 that does
not touch that plate, and wants 1.2 µm. The via stack that takes the boost
capacitors' top-plate net (`vbsh`) from its met4 strap down to met2 had its
met3 pad 0.75 µm from the plate of the nearest capacitor. The stack now has
2 × 2 cuts instead of 3 × 2:

| In `bootstrap_sw` | Before | After |
|---|---|---|
| `M2M3_C` and `M3M4_C` (standard vias, net `vbsh`) | origin (0.66, 19.13), 3 columns, x enclosure 0.1 | origin (0.435, 19.13), 2 columns, x enclosure 0.075 |
| Their pads on met2, met3 and met4 | x 0.06–1.26, y 18.68–19.59 | x 0.06–0.81, y 18.68–19.59 |
| The met3 patch under each via | (0.06, 18.675)–(1.26, 19.59) | (0.06, 18.675)–(0.81, 19.59) |

A standard via's parameters can't be changed in place, so the two vias were
deleted and created again, on the same net, in the same route objects and with
their patches as children. The stack has 0.6 Ω more, in series with the boost
switches.

**The met2 `vssa` plane of `carray_8b`.** The plane is the shield under the
capacitor array: one polygon of 156.31 × 156.825 µm, drawn on met2 drawing and
again as the `vssa` pin, over the unit cells' own met2 shields. It already had
seven slots open to its bottom edge, in the gaps between unit-cell columns, for
the bit lines' met2 risers; a 76.4 µm square of solid metal fitted in it. The
gap after every third column now has a slot from the bottom edge up to
y = 129.52 (the top of unit row 14), 1.0 µm wide, on the centre line of the gap:

| In `carray_8b` (both polygons, 36 points before and 56 after) | Slot |
|---|---|
| New, columns 2/3, 5/6 and 14/15 | x 24.91–25.91, x 51.31–52.31 and x 130.51–131.51, y 0–129.52 |
| The riser slot of columns 8/9 (x 76.51–79.91, y 0–94.32) | carries on as x 77.71–78.71 up to y = 129.52 |
| The riser slot of columns 11/12 (x 102.91–106.31, y 0–32.72) | carries on as x 104.11–105.11 up to y = 129.52 |

- The plane is still one polygon: six strips of at most 25.4 µm, joined by its top 27.305 µm, where `cdac_8b`'s `vssa` wiring meets it.
- The slots lie where only the cell-to-cell links cross (bottom-plate met3, and the top plate's met4 in five places). Every unit capacitor keeps its own met2 shield, and a slot stays 1.5 µm clear of it.
- Slots as wide as the gap (3.4 µm, as the riser slots are) were tried first. In the extraction they put 8.4 fF of each top plate onto the substrate; the 1.0 µm slots put 0.5 fF.

| Check | Before | After |
|---|---|---|
| ChipFoundry FEOL deck, each variant's GDS | 1 (`MR_capm.SP.2`) | 0 |
| ChipFoundry BEOL deck, each variant's GDS | 0 | 0 |
| Largest solid square on met2 | 76.4 µm | 27.3 µm |
| Largest solid square on li1 / met1 / met3 / met4 / met5 | 0.8 / 1.8 / 6.9 / 4.4 / 1.6 µm | the same |
| Pegasus DRC, real violations: `bootstrap_sw`, `carray_8b`, `cdac_8b`, `sar_afe` | 0 | 0, and the same density/fill rules |
| Pegasus LVS: the same cells, `sar_afe` with the black box and with the filter | MATCH | MATCH |

The largest solid square is measured in KLayout: a square of side s fits where
the merged layer, shrunk by s/2, is not empty.

**The extraction of `sar_afe`, before and after** (parasitic capacitance of a
net to all other nets, P side / N side):

| Net | Before | After |
|---|---|---|
| Top plates `vtopp` / `vtopn` | 860.7 / 859.6 fF | 854.7 / 854.5 fF (−0.7 / −0.6 %) |
| Bottom plate, bit 7 | 915.7 / 914.6 fF | 910.7 / 910.5 fF (−0.5 %) |
| Bit 6 | 460.8 / 460.5 fF | 458.9 / 458.7 fF (−0.4 %) |
| Bit 5 | 236.4 / 236.3 fF | 234.2 / 234.1 fF (−1.0 / −0.9 %) |
| Bit 4 | 126.5 / 126.6 fF | 125.8 / 125.9 fF (−0.6 %) |
| Bits 3 to 0 and the dummy | 74.2, 38.4, 24.6, 16.4 and 17.3 fF | within 0.2 % |

The devices are the same 656 MIM caps and 98 FETs, with the same sizes on the
same nets, and no net's total moves by more than 1 %. What the top plates lose
is capacitance to the plane (`vtopp` to `vss`: 184.7 to 178.4 fF).

**One mixed-signal run on the new extraction**, the chip's `sar_adc` RTL around
the extracted macro at the board's clock (100 ns, `adc_clkdiv` 4,
`adc_samplediv` 8, 52 conversions compared with the ideal model):

| Extraction | Code error | Gain error | Carry-over of the previous sample |
|---|---|---|---|
| Before the fixes | −1..+2 LSB | +2.35 % | +0.11 % |
| After | −1..+2 LSB | +2.10 % | +0.12 % |

Spectre finishes without errors and the firmware test passes in both. The fit
over 52 samples does not resolve much less than this difference: on the same
run, two extractions that differ only in the comparator's trim capacitors
gave +2.18 % and +2.35 %.

The extracted views of `bootstrap_sw` and `carray_8b` kept in the library
(`av_extracted`, `bsw_extracted`) are their owners' own and predate these fixes.

## The trim's MOM unit cap: black box for LVS, layout metal for extraction

The comparator's trim builds each bit's capacitance from `sarcta__C0`, a single-layer
met2 finger (MOM) unit cap, 1.58 x 4.7 um: 8/4/2/1/1 units per bit plus 2
dummies, all inside `sarct__trim_array`. Its schematic is an ideal 1.25 fF
capacitor, and no device rule extracts a capacitor from plain metal. The two
flows therefore treat it differently, and both LVS runs must MATCH.

**LVS (sign-off):** `run_lvs.sh ... --blackbox sarcta__C0` adds
`lvs_black_box sarcta__C0 -source_layout` to the deck, the same setting as
the cell's own LVS run. Every unit's two terminals must connect to the right nets on
both sides, so the bit wiring of the array is checked, where an ignored ideal
cap would skip it.

**Extraction:** `run_pex.sh ... --filter-source "C (CP)"`, and no black box.
`lvs_filter_device C (CP) -open -source` drops the ideal capacitor from the
schematic side, so the unit's fingers are ordinary metal on its two nets and
Quantus extracts their capacitance and resistance like any other wire. The
netlist then has no ideal capacitor to count twice. This comparison does not
check the array's wiring (an open finger is only a floating piece of metal to
it); the black-box run above does.

Until 18 Nov 2026 the extraction used the black box as well. The units were
then netlisted from the schematic as ideal 1.25 fF and their own metal was
left out. What the layout has instead (Quantus typical, the only corner the
PDK ships; pattern-based extraction, not a field solver):

| Per array | Ideal, as netlisted before | From the layout |
|---|---|---|
| Unit, plate to plate | 1.25 fF | 1.00 fF |
| Bits 4..0 | 10.0 / 5.0 / 2.5 / 1.25 / 1.25 fF | 8.03 / 4.00 / 2.01 / 1.00 / 1.00 fF |
| Common plate (`net2`/`net3`) to the supplies, dummies excluded | 2.3 fF | 3.8 fF |
| Switched plate of bit 4 to the supplies and other nets | 4.1 fF | 5.0 fF |

The comparator's trim step and range follow (extracted comparator alone,
Spectre, tt, 27 C, 1.8 V, common mode 0.9 V):

| | Ideal units | Layout units |
|---|---|---|
| One unit (code 1) | 4.0 mV | 2.8 mV |
| Full scale (code 31), `trima` / `trimb` | +49 / -48 mV | +36 / -35 mV |
| Decision delay, 10 mV overdrive, trim 0 / trim 31 both sides | 1.95 / 2.53 ns | 1.97 / 2.37 ns |

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
