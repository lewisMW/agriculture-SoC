# sar_afe: the ADC's analog front end as a hard macro

This macro is the analog half of the 8-bit SAR ADC. It contains Hee's two
capacitor DACs (`cdac_8b`: an 8-bit MIM-capacitor array, its bit-driver
inverters and Jaime's bootstrapped sampling switch) and Erick's comparator. The digital half is the SAR state machine (`sarlogic`) plus an SR
latch. That part is ordinary RTL and goes into the chip netlist next to the
macro (see [Connecting the SAR logic](#connecting-the-sar-logic)).

There are three placement variants of the same circuit, so an ADC can sit
anywhere along the bottom of the core with short analog inputs:

| Cell | Size (µm) | Analog inputs | Digital pins | For a macro at the chip's |
|---|---|---|---|---|
| `sar_afe` | 260.0 × 429.32 | left edge (met3) | right edge (met3) | **bottom-left**: inputs from the left pad row |
| `sar_afe_r` | 260.0 × 429.32 | right edge (met3) | left edge (met3) | bottom-right: inputs from the right pad row |
| `sar_afe_b` | 429.32 × 260.0 | bottom edge (met3) | top edge (met2) | bottom, mid-chip: inputs from the bottom pad row |

`sar_afe_r` is `sar_afe` mirrored, and `sar_afe_b` is `sar_afe` rotated by 90°.
Inside they are the same layout, so they have the same parasitics and the same
`.lib` timing. Only the edge pins and the supply straps differ.

Everything here is generated from the Virtuoso library `analog/cadence/sar_adc`
by `analog/cadence/pv/macro/export_macro.sh`. Don't edit these files;
regenerate them (see [Regenerating](#regenerating)).

| File (`CELL` = one of the three) | Use |
|---|---|
| `CELL.lef` | Innovus: append to `lef_file_list`, after the tech LEF |
| `CELL__<corner>.lib` | Genus and Innovus. There is one file per corner of `nanosoc_chip_pads.mmmc`: `ss_100C_1v60`, `ff_100C_1v95`, `tt_100C_1v80`, plus `tt_025C_1v80`. |
| `CELL.gds` | `write_stream -merge`. Every subcell is renamed `CELL__<name>`, so nothing collides with the standard-cell, SRAM or IO GDS, or with another variant. |
| `CELL.v` | Port list only, for simulation and LEC. **Don't read it into Genus**: the cell comes from the `.lib`. |
| `CELL.cdl` | LVS source netlist, with subcells renamed as in the GDS. Chip LVS can also black-box the macro, because it is signed off on its own. |

## The macro (`sar_afe`)

From bottom to top: the supply buses, Hee's N-side `cdac_8b`, a 12 µm gap,
the P-side `cdac_8b` (mirrored, so both cells' input and top-plate corners
face the gap), and the supply buses again. `vinp`/`vinn` come in from the
left edge straight to each CDAC's input corner. Erick's comparator sits to
the right of the CDACs, level with the gap, rotated so its inputs face them.
Every digital line runs to the right edge, so the SAR logic belongs to the
macro's right.

- **LEF settings:** `CLASS BLOCK`, origin at the bottom-left corner, `SYMMETRY X Y`.
- **Coordinates:** all values below are in µm from the macro origin.

| Pins | Layer | Position |
|---|---|---|
| `vinp`, `vinn` | met3 | left edge, y = 221.81 and 207.51 (0.4 wide) |
| `ctlp[0..7]` | met3 | right edge, y = 328.10, 329.46, 336.94, 319.94, 353.26, 311.78, 302.94, 294.10 |
| `sample` | met3 | right edge, y = 253.30 |
| `trima[i]`, i = 0..4 | met3 | right edge, y = 236.98 + 1.36·i |
| `outn` | met3 | right edge, y = 217.94 |
| `outp` | met3 | right edge, y = 211.82 |
| `clk` | met3 | right edge, y = 207.06 |
| `trimb[i]`, i = 0..4 | met3 | right edge, y = 192.10 − 1.36·i |
| `ctln[0..7]` | met3 | right edge, y = 101.66, 100.30, 92.82, 109.14, 75.82, 117.30, 126.14, 134.98 |
| `vss` | met4 | full-height straps, x 1–5 and 255–259 |
| `vdda` | met4 | full-height straps, x 7–11 and 249–253 |
| `vref` | met4 | full-height straps, x 13–17 and 243–247 |
| `vdd` | met4 | full-height straps, x 19–23 and 237–241 |

- **Signal pins:** 0.6 × 0.4 µm met3 stubs touching the edge. The digital pins are centred on the `sky130_fd_sc_hd` met3 tracks (0.34 + 0.68·k from the macro origin), so place the macro at a y that is a multiple of 0.68 µm from the core's track origin, and at an x that is a multiple of 0.46 µm. The `ctl` pins come straight across from each CDAC's bit drivers, so they are in Hee's driver order, not bit order; P&R connects them by name.
- **Supplies:**
  - `vdd` powers the comparator.
  - `vdda` powers the bootstrapped sampling switches. Connect it to the analog supply `VDDA` of the `PD_ANALOG` domain, or to `VDD` if the chip uses one supply.
  - `vref` is the CDAC reference: Hee's bit-driver inverters set the DAC levels from it. It is new (20 Oct) and is meant to be a separate, heavily decoupled reference: a pad of its own with an off-chip capacitor, or a quiet net with decap next to the macro. Until that exists it can share `VDDA`.
  - `vss` is the one ground. The CDACs' `vssa` is tied to it inside the macro, because both sit on the same p-substrate.
  - Each supply's two straps are joined inside the macro by a met3 bus below and above the CDACs.
- **Obstructions:** li1 through met4 are obstructed over the whole macro, except at the pins. met5 is obstructed only over x 210.49–234.63, y 204.18–209.78 (the comparator's clock). The chip's met5 stripes may therefore cross the rest of the macro and drop vias onto the met4 supply straps, which is how the SRAMs are powered.
- **Antenna areas:** gate and diffusion areas are in the LEF, taken from the transistor-level netlist.
- **Pin capacitances:** in the `.lib`. Each value is the gate capacitance plus the wire capacitance from the Quantus extraction. `ctlp`/`ctln` are 9–10 fF and the trims 10–12 fF. `clk` is 28 fF, and `sample` 58 fF: it runs inside each `cdac_8b` to its switch.
- **Sampling load:** `vinp` and `vinn` each sample **8.19 pF** of CDAC through the bootstrapped switch. The input pad and sensor must drive that.

### `sar_afe_r` and `sar_afe_b`

- **`sar_afe_r`:** every pin of `sar_afe` at x → 260 − x. The analog inputs are on the right edge and the digital pins on the left edge. The met5 obstruction is x 25.37–49.51, y 204.18–209.78.
- **`sar_afe_b`** (429.32 × 260):
  - **Analog inputs:** `vinp`/`vinn` are met3 stubs on the bottom edge, at x = 207.51 and 221.81.
  - **Digital pins:** met2 stubs on the top edge:
    - `ctlp[0..7]` at x 76.06–135.22 on the left;
    - `sample`, `trima`, `outn`, `outp`, `clk` and `trimb` in the middle, x 176.02–242.66;
    - `ctln[0..7]` at x 294.34–353.50 on the right.
  - **Supplies:** the supply pins are full-width **horizontal** met4 bands along the top and bottom edges. Counted from each edge: `vss` y 1–5 / 255–259, `vdda` y 7–11 / 249–253, `vref` y 13–17 / 243–247, `vdd` y 19–23 / 237–241.
  - **Powering it:** use a block ring whose left/right sides are met5 and whose top/bottom sides are met4, so that each band's ends can be joined across the inner rings. This is the reverse of the ring for the other two variants.
  - **met5 obstruction:** x 219.55–225.15, y 210.49–234.63.

## Placing it on the chip

Daniel's current floorplan (`ASIC_ours/Cadence/scripts/floorplan.tcl` on
`sky130-flow-fixes`) has a 2920 × 3520 µm core with the four SRAMs in its
upper corners, which leaves the free space along the bottom of the core.

- **The ADC:** put `sar_afe` at the bottom-left of the core, in R0, a few µm inside the core edges, for example:
  ```tcl
  set c [get_db current_design .core_bbox]
  set x [expr {[lindex $c 0 0] + 0.46 * 44}]
  set y [expr {[lindex $c 0 1] + 0.68 * 30}]
  place_inst <adc>/u_afe [list $x $y] r0 -fixed
  create_place_halo -insts <adc>/u_afe -halo_deltas {9.6 9.6 9.6 9.6}
  create_route_halo -insts <adc>/u_afe -space 4.8 -bottom_layer met1 -top_layer met4
  ```
- **The SAR logic:** goes to its right, nearest the `outp`/`outn`/`clk` pins (y ≈ 207–218 above the macro origin).
- **Analog input pads:** the two belong at the bottom of the left pad row, level with `vinp`/`vinn` (about 207–222 µm above the macro's bottom edge), so the inputs run straight in on met3.
  - In `nanosoc_io_plan.io` the bottom of that row is `uPAD_VDDIO_1`, `VSSIO_1`, `VDD_1`, `VSS_1`, then `P0_15` and `P1_00`. Take the analog pads from there.
  - The VDDA/VSSA pads already in `nanosoc_chip_pads.v` aren't in the IO plan yet; they belong next to the macro too.
- **Extra ADCs:** `sar_afe_b` along the bottom edge takes its inputs from the bottom pad row; `sar_afe_r` at the bottom-right takes them from the right pad row.

## Hooking it into `ASIC_ours/Cadence`

1. **`config.tcl`** (for each variant used):
   ```tcl
   set sar_afe_dir [file normalize ../../macros/sar_afe]
   lappend lef_file_list $sar_afe_dir/sar_afe.lef
   lappend lib_search_path_list $sar_afe_dir
   lappend syn_lib_list sar_afe__tt_025C_1v80.lib
   ```
2. **`nanosoc_chip_pads.mmmc`**: add the matching corner to each library set:
   - `sar_afe__ss_100C_1v60.lib` → `default_libset_max`
   - `sar_afe__ff_100C_1v95.lib` → `default_libset_min`
   - `sar_afe__tt_100C_1v80.lib` → `typical_libset`
3. **`floorplan.tcl`**: place it as above.
4. **`power_plan.tcl`**:
   ```tcl
   connect_global_net VDD  -type pg_pin -pin_base_name vdd  -inst_base_name <adc>/u_afe
   connect_global_net VDDA -type pg_pin -pin_base_name vdda -inst_base_name <adc>/u_afe   ;# or VDD
   connect_global_net VREF -type pg_pin -pin_base_name vref -inst_base_name <adc>/u_afe   ;# or VDDA for now
   connect_global_net VSS  -type pg_pin -pin_base_name vss  -inst_base_name <adc>/u_afe
   ```
   - Add the instance to `power_stripes_all_macros`, so the met4 stripes go around it. The met5 stripes can cross it.
   - Then join the strap ends with `route_special -connect {block_pin ...} -block_pin use_lef`, or with a block ring.
   - **UPF:** the macro sits in `PD_TOP`, with two extra supply pins: `vdda` on `VDDA`, and `vref` on its own reference supply (or `VDDA` until there is one).
5. **Stream-out**: add `sar_afe.gds` (and any other variant's GDS) to the `-merge` list.
6. **The ADC's RTL and the two analog pads.** `sar_adc` and the analog-input
   plumbing to `nanosoc_chip` (`ADC_VINP`/`ADC_VINN`) are already in the RTL.
   What's left is in Daniel's files:
   - **`constraints.sdc`:** after its `create_clock` lines, add
     `source $::env(ACCELERATOR_DIR)/ADC/sar_adc.sdc`
     (the ADC's generated clocks, the latch's loop break and the clock-domain crossing; header of that file).
   - **`nanosoc_chip_pads.v`:**
     - two ports, `inout wire ADC_VINP, ADC_VINN`;
     - two wires, `pad_adc_vinp` and `pad_adc_vinn`;
     - `.ADC_VINP(pad_adc_vinp), .ADC_VINN(pad_adc_vinn)` on `u_nanosoc_chip`;
     - two pads: `sky130_ef_io__analog_pad uPAD_ADC_VINP (.P_PAD(ADC_VINP), .P_CORE(pad_adc_vinp));`, and the same for VINN.
   - **Libraries:** add `sky130_ef_io__analog_stubs.lib` to `IO_PAD_DRIVER` and to each MMMC corner.
   - **IO plan:** place the two pads facing the macro's analog edge; for `sar_afe` that is the bottom of the left pad row.
   - **Innovus:** don't buffer these two nets.

### Checked in Innovus

The hook-up was checked on the Cadence box on 20 Oct 2026, with Innovus 22.1
and the `sky130_fd_sc_hd` PDK this flow uses (`analog/cadence/pv/macro/innovus_smoke/`).

**Setup:**
- One die (core 1500 × 800 µm) with all three variants along its bottom: `sar_afe` at the bottom-left, `sar_afe_b` in the middle, `sar_afe_r` at the bottom-right.
- Each macro's digital pins are buffered to top-edge IOs. `vinp`/`vinn` go to IOs on the die edge the macro's analog side faces.
- Power: core rings, met4 stripes kept off the macros, met5 stripes across them, block rings, `route_special` to the block pins, and separate `VDDA` and `VREF` nets.

**Results:**
- NanoRoute routed all 186 signal nets with **0 DRC and 0 process-antenna violations**.
- No supply pin of any macro is left unconnected (`VDDA` and `VREF` reach every macro's straps).
- `check_connectivity` lists only the harness's own items: the buffers' `VNB` body pins, stripe ends at the macros' met5 obstruction, and ring segments the harness leaves open.

To rerun: `MACRO_OUT=<this dir> innovus -stylus -no_gui -batch -files smoke.tcl`.

## Connecting the SAR logic

`sar_adc` (`agriculture_soc_main/ADC/sar_adc.v`) is the synthesisable ADC that
replaces `dummy_adc` in `adc_apb_wrapper_rev2.v`, with the same digital ports
(`clk rstn en cal valid result`) plus `vinp`/`vinn`:

```
sar_adc
 ├ clock divider   PCLK → ADC clock (CLK_DIV)
 ├ sarlogic        the FSM (analog/cadence/sar_adc/sarlogic, Hee's 10-cycle version)
 │                 sample, ctlp[7:0], ctln[7:0], trima/trimb[4:0], clkc → sar_afe
 ├ SR latch        two sky130_fd_sc_hd__nand2, dont_touch:
 │                   q  = NAND(outn, qn)    q is comp
 │                   qn = NAND(outp, q)
 └ sar_afe         this macro (clkc → clk)
```

**The latch must be a NAND (active-low) latch.** The comparator resets both
outputs **high** whenever its `clk` is low. On the rising edge exactly one
output falls: `outn` falls when the comparator's vp > vn, which sets `comp`.
The NAND latch holds that decision through the reset, so `sarlogic` samples a
stable `comp`. The instance names for the physical flow (`u_afe`, `u_latch`,
`u_logic`) are in `sar_adc.v`'s header. The constraints and the pad hook-up
are step 6 above.

## Status (20 Oct 2026)

- **Built on Hee's 20 Oct `cdac_8b`,** which carries the bootstrapped switch itself and passes LVS and DRC on its own (with PR 2's inverter poly fix).
- **LVS: MATCH** for all three cells.
  - Pegasus 23.2 with the patched PDK deck.
  - The trim's MOM unit cap `sarcta__C0` is black-boxed. `cdac_8b` is now an ordinary subcell; it no longer has to be compared flattened. See `analog/cadence/pv/README.md`.
- **DRC:** no real violations. Density and fill rules come from chip-level fill.
- **Parasitic extraction:** Quantus RC, 98 FETs and 656 MIM caps, 12.9k C and 10.6k R. Its ports are identical to the schematic netlist's.
- **Simulation:** the six firmware tests run in Xcelium AMS with the chip's `sar_adc` RTL and this macro, as its schematic and as its Quantus extraction.
  - All six pass, with Spectre clean, and the negative control fails as it should.
  - At the chip's ADC clock the codes match an ideal model sample by sample: within 1 LSB as a schematic and 2 LSB extracted, on all 112 samples.
  - The step check still flags the same few samples as before the rebuild, because the suite clocks the ADC three times faster than the chip and two tests alias the test tone. See `agriculture_soc_main/AMS/INTEGRATION.md`.
- **Open items:**
  - The timing arcs and corner scaling are estimates until the comparator is characterised.
  - **Back-to-back conversions, extracted:** a +3 % gain error at the chip's clock for a conversion within 10 µs of the previous one; after a longer idle it is +0.65 %, and the schematic has +0.3 %. The 20 Oct rebuild didn't change it, so neither the old top-plate route nor the supply wiring is the cause. The switch's boost recharge is the leading candidate (`agriculture_soc_main/AMS/INTEGRATION.md`).
  - **Calibration diverges.** `sarlogic` assumes that raising `trima` raises the `vinp` side, but the macro lowers it. The fix goes in `sarlogic`, or as a `trima`/`trimb` cross in `sar_adc`.
  - **Two conversions per trigger.** `wrapper_control_2` holds `en` until the synchronised `valid` arrives. Harmless, but it doubles the ADC's power.
  - **`vref` decoupling:** how much, and whether on-chip or through a pad, is still to be decided.

## Regenerating

On the Cadence box, from `analog/cadence/pv` (`source ~/.bashrc` first):

```
for c in sar_afe sar_afe_r sar_afe_b; do
  ./run_lvs.sh sar_adc $c --blackbox sarcta__C0
done
./run_pex.sh sar_adc sar_afe --blackbox sarcta__C0
./macro/export_macro.sh            # writes this directory, all three cells
```

The layouts come from `macro/afe_lay.il` (`AFE_VARIANT=l|r|b`) and the
schematics from `macro/afe_sch.il`, which also adds any new supply pin to the
existing symbols (`m1SymAddPin` in `macro/schgen.il`).
