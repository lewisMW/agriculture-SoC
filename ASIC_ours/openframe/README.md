# nanosoc in the ChipFoundry OpenFrame wrapper (experiment)

OpenFrame is ChipFoundry's bare-padframe template for SKY130: the frame supplies
the pad ring, the user gets a 3166.63 x 4766.63 um area and 44 GPIO pads, and the
user design must be a block called `openframe_project_wrapper` with the template's
exact port list and pin positions. This directory places the SKY130 nanosoc chip
(the `chip-afe-pnr` design) in that wrapper with the Cadence flow, to see how it
fits and what changes it needs. It is an experiment, not a tape-out database.

Sources: `chipfoundry/openframe_user_project` (wrapper RTL, DEF template, LEFs,
OpenLane config) and `chipfoundry/CF_gpio_config` (pad-configuration block), both
Apache-2.0; `chipfoundry/cf-precheck` for the submission checks.

## What is here

| Path | Content |
| --- | --- |
| `rtl/openframe_project_wrapper.v` | the template's port list around `nanosoc_chip_cfg` + `nanosoc_chip`, one `CF_gpio_config` per pad |
| `rtl/CF_gpio_config.v` | ChipFoundry's pad-configuration block, unchanged |
| `rtl/sl_sram_dffram.v` | `sl_sram` with ChipFoundry's pre-hardened DFFRAM blocks (see "Memories") |
| `rtl/sl_ahb_sram_hold.v` | `sl_ahb_sram` for blocks built with the DFFRAM compiler: a bridge that holds the address (see "Memories") |
| `fetch_dffram.sh` | fetches the pre-hardened DFFRAM blocks into `ip/` (not in git) |
| `Cadence/inputs/openframe_pins.def` | the template's 887 pins, each on its own net (derived from the template DEF) |
| `Cadence/inputs/openframe_project_wrapper.upf` | one power domain on vccd1/vssd1; vdda1/vssa1 and ADC_VREF for the ADC macro |
| `Cadence/inputs/constraints.sdc` | the chip constraints with the pad-cell paths replaced by `gpio_in`/`gpio_out` |
| `Cadence/inputs/v*_connection.lef`, `.gds` | the frame's power-connection blocks (from the template, unchanged) |
| `Cadence/scripts/` | `config.tcl`, `floorplan.tcl`, `power_plan.tcl` for the wrapper; the rest copied from `ASIC_ours/Cadence/scripts` |
| `signoff/` | GDS stream-out, LVS and ChipFoundry's layout checks for the wrapper (see "Sign-off") |
| `cf/` | inputs for ChipFoundry's own LVS (see "Sign-off") |
| `sim/` | gate-level simulation of the routed wrapper, and RTL simulation of the wrapper in the same frame model (see "Gate-level simulation") |
| `sw/` | `small_puts.c` and `openframe.ld`, for building programs for the real memory sizes (see "Firmware size"); `bootrom/`, the boot ROM, and `mkflashimg.py` (see "Booting from the board's flash") |

The generic stage scripts are the usual `nanosoc/asic_flow/Cadence/*.tcl`.

## Pad map

Laid out for ChipFoundry's Caravel development board, which takes an OpenFrame
chip unchanged (their knowledge-base article "OpenFrame I/O Mapping"). On that
board GPIO 1-4 go to the FTDI chip's SPI lines, 5 and 6 to its UART behind
switches, 36 and 37 to the SPI flash's IO2 and IO3, 38 to the clock generator,
39-42 to the flash's CSB, CLK, IO0 and IO1, and 43 to the LED. GPIO 0 and 7-35
reach header pins only.

| GPIO | Edge | Function | On the board |
| --- | --- | --- | --- |
| 38 | bottom | CLK | the clock generator, 10 MHz |
| 5, 6 | right | P1[4], P1[5]: UART2 RXD, TXD when P1[7] is high (HOSTIO4 data 1, 2 when low) | the FTDI's UART, so program output can arrive over USB |
| 0 | right | P1[0]: FT1248 MISO, an input that is low when the host has data, or HOSTIO4 req1, an output. The pad has its pull-up while the chip does not drive it | header pin, for the host adapter |
| 7, 8, 9, 10 | right | P1[1], P1[2], P1[3], P1[6]: the rest of the host link (FT1248 clock, data, select; HOSTIO4 req2, ack, data 0, data 3) | header pins, for the host adapter |
| 11 | right | P1[7]: host-link mode strap, 0 HOSTIO4, 1 FT1248 + UART2. Input with the pad's pull-up, so 1 unless tied low; P1[7] cannot drive it | header pin |
| 39, 40, 41, 42 | bottom | P1[8], P1[9], P1[10], P1[11]. The CSB pad has its pull-up while nothing drives it | the flash's CSB, CLK, IO0 (to the flash), IO1 (from it) |
| 36, 37 | left | P1[13], P1[14] | the flash's IO2, IO3: its write-protect and hold inputs in plain SPI mode |
| 14 | right | FLASH_PROG: input with the pad's pull-down. High holds the chip in reset and passes the FTDI's SPI lines straight to the flash | header pin: tie high to program the flash |
| 1-4 | right | P0[12..15]; with FLASH_PROG high, 1 is the flash's IO1 coming back (SDO) and 2, 3, 4 (SDI, CSB, SCK) go on to the flash | the FTDI's SPI lines: leave them inputs while the FTDI drives |
| 23 | top | P1[12] | header pin |
| 24-35 | left | P0[0..11] | header pins |
| 43 | bottom | P1[15] | the LED |
| 18, 19 | top | TEST, SE: inputs with the pad's pull-down, low unless driven | header pins |
| 20, 21 | top | SWDCK (pull-down), SWDIO | header pins, for a debug probe |
| 15, 16, 17 | top | ADC_VREF, ADC_VINP, ADC_VINN (`analog_io`) | header pins |
| 12, 13, 22 | right, top | unused: analog mode, input buffer off | header pins |

Why this way:

- **Nothing the chip needs at a fixed level can float.** TEST, SE, SWDCK and
  FLASH_PROG have the pad's pull-down; the mode strap has its pull-up, and so
  has the host link's "host has data" input whenever the chip is not driving that
  pin. A board with nothing on the header pins therefore starts in FT1248 +
  UART2 mode, with a host link that sees no data. The flash's select (GPIO 39)
  is treated the same way: a Caravel chip always drives that pin, so the board
  need not pull it up, and here it would float while the chip is in reset or
  P1[8] is an input. (GPIO 0 and 39 are the two pads not configured by a
  `CF_gpio_config`: none of its modes is "output, or input with a pull". Their
  drive-mode bit follows the output enable, which changes with the mode strap
  for GPIO 0 and when the boot ROM or a program takes or releases the flash for
  GPIO 39.)
- **The program can live in the board's flash** ("Booting from the board's
  flash"). The flash's six pins are port bits, all in the upper byte of port 1, so
  the boot ROM (and any program) can drive them with single masked writes.
- **The flash can be written from the board's USB port.** An OpenFrame chip has
  no housekeeping SPI, which is how a Caravel board's FTDI reaches the flash. With
  FLASH_PROG high the wrapper connects the FTDI's four SPI pads to the flash's
  pads directly (four multiplexers at the pads), and holds the chip in reset.
- **The host link is on header pins**, because it needs an adapter the board does
  not have: HOSTIO4 is seven wires, and in FT1248 mode the chip drives the clock
  and select, as the board's FTDI does on its SPI lines. Only the two UART pins
  line up with something on the board, and they are placed on it.
- **The pads next to the three analog ones** (14 on one side, 18-21 on the
  other) carry signals that do not toggle in normal operation.
- The three analog pads are the top-edge pads nearest the frame's `vdda1` (right
  edge) and `vssa1` (top edge) pins; the ADC macro sits in that corner.

**The ADC's supply is the frame's `vdda1`, and the macro's devices are 1.8 V.**
On the development board `vdda1` comes out on header J11 pin 16, beside the
3.3 V pins (26, 27); the 1.8 V pins are 22 and 23. Wire pin 16 to 1.8 V. A jumper
to the neighbouring 3.3 V pin puts 3.3 V on 1.8 V transistors.

Reset is the frame's `resetb_l` ANDed with its power-on reset `porb_l` and with
FLASH_PROG low. `porb_h`, `por_l`, `resetb_h`, `gpio_in_h`, `mask_rev` and
`analog_noesd_io` are unused.

To check against the board before relying on it: which of GPIO 5 and 6 the FTDI
transmits on (taken here as Caravel's convention, the chip receiving on 5), the
LED's polarity, and that port pins the firmware leaves as inputs have pulls: a
bidirectional pad has no pull of its own. One of them matters with no host
adapter fitted: GPIO 8, the host link's data line, which the chip reads as "the
host cannot take a character" when it is high. Characters a program sends to the
stream port (the SoC Labs `UartPutc`) then wait for ever. A pull-down on GPIO 8
lets them drain; a program meant to run alone should print on UART2.

## Running

```
./fetch_dffram.sh                  # once: the memory blocks, into ip/ (not in git)
cd Cadence/scripts
export CDS_LIC_FILE=port@host      # as for the chip flow
./run_flow.sh                      # inputs, synthesis, place, CTS, route, DRC repair
./run_flow.sh synth                # stop after synthesis
./run_flow.sh pnr                  # place and route only
OF_MEM=compiler_dff ./run_flow.sh  # another memory set (see "Memories"); default prebuilt
```


`run_flow.sh` is the chip flow's script: each stage is its own Genus/Innovus
process. About 10 minutes of synthesis and 20 minutes of place and route.

## How it differs from the chip-level flow

- No pad ring, no IO libraries, no level shifter, POR or reference pad cells: the
  frame owns the pads. Each used pad gets a `CF_gpio_config`, which wires the pad's
  static configuration pins to the frame's `gpio_loopback_one/zero` constants. An
  output that synthesis reduces to a constant (`gpio_oeb[1]`: P1[1] is always an
  output) is put on the same constants in `floorplan.tcl`; Innovus would otherwise
  tie that port straight to the ground net and never route it.
- Die, core rows and all 887 pins come from the template DEF. The pins reach 2 um
  beyond the die edge by design, so `check_drc` runs with the `out_of_die` rule off
  (`route_setup.tcl`, `route_drc.tcl`; the setting is not stored in the database).
- Power grid as the template has it: 20 um core rings, 6.4 um stripes every 40 um
  (met4 vertical, met5 horizontal), `vccd1_connection`/`vssd1_connection` at the
  template's positions. The standard-cell rails are drawn by `route_special` and
  their via stacks by `update_power_vias`: about 100k stacks in seconds, where one
  `route_special` call for both would need over an hour.
- SRAM rows at lly = 13.16 (mod 40) so that the met5 straps feeding each SRAM pass
  between the grid's horizontal stripes.
- ADC macro in the top right corner. `vdda1` enters from the right-edge pin (met3
  across the core ring, then met5 to the block ring, so that no standard-cell rail
  loses its vias), `vssa1` from the top-edge pin (met3), `vdd` from the `vccd1` grid.
  The reference comes in on pad 15: net `analog_io[15]` is declared a power net and
  the macro's `vref` pin is moved onto it (`config.tcl`, `power_plan.tcl`).
- All supply nets get `skip_routing`: NanoRoute otherwise joins each supply port to
  the nearest rail with a minimum-width signal wire.
- Constraints: clocks on `gpio_in[38]`/`gpio_in[39]`, `SAR_ADC_SOURCE` set to match,
  and the removal check from the asynchronous `resetb_l` is a false path like its
  recovery check.
- `nanosoc/asic_flow/Cadence/1_synthesis.tcl` gained two things any pad-less block
  needs: `lp_check_nonfatal` (config.tcl) lets the low-power rule checks report
  without stopping, and the `uPAD*` dont_touch is skipped when there are no pads.

## Result (10 Nov 2026, Genus/Innovus 22.10)

This is the first version, with the four OpenRAM macros. The results with DFFRAM
memories are under "Memories".

| | |
| --- | --- |
| Synthesis | 23,535 cells, 3.56 mm2 with the four SRAMs and the ADC macro, +9.0 ns slack at 30 ns |
| After place and route | 26,088 logic instances, 2.4 % of the 14.5 mm2 core; plus 296,773 well taps, 276,352 decaps, 903,499 fill cells |
| Setup, post-route | WNS +0.239 ns, TNS 0 |
| Hold, post-route | WNS +0.112 ns, no violating path |
| Design-rule violations in timing | 60 max-transition (worst 36 ps over), 1 max-fanout |
| `check_drc` | 6 markers, none in the design: the frame's `vccd1`/`vssd1` pins against the met3 obstruction of the connection blocks they sit in |
| `check_connectivity` | no open signal net; 16 expected markers: the 10 frame supplies this design does not use, and the three spare pins each of `vdda1` and `vssa1` |

This is the second run of the day, with the unused pads in analog mode and the
power-on reset added. The first (pull-down unused pads, reset pad only) gave 23,534
cells, 26,035 logic instances, setup +0.020 ns and hold +0.060 ns with the same
`check_drc` and connectivity markers. The worst path is register-to-register in
both runs (the reset paths have 4.7 ns of slack), so the slack differs because the
placement and optimisation came out differently, not because of the added gate.

The frame's `vccd1`/`vssd1` pins show as unconnected in Innovus: the connection
blocks' GDS joins them to the core ring, and their LEF holds only an obstruction.
LVS on the merged GDS confirms the join (below).

## Sign-off

`signoff/` wraps the chip flow's scripts (`ASIC_ours/Cadence/signoff`, whose README
explains them) for the wrapper. Run output goes outside the repo, in any directory
`$R`:

```
signoff/run_stream_out.sh $R/stream                    # merged GDS + netlists, ~1 min
../Cadence/signoff/run_chip_drc.sh $R/stream/openframe_project_wrapper.gds \
        openframe_project_wrapper $R/drc               # Pegasus DRC, ~1 min
signoff/run_lvs.sh $R/stream $R/lvs/run1               # Pegasus LVS, ~1.5 min
signoff/lvs_port_ties.py $R/stream/openframe_project_wrapper.pg.v \
        $R/lvs/run1/openframe_project_wrapper.lvsrpt.shorts
CF_PRECHECK=<cf-precheck checkout> GOLDEN=<openframe_project_wrapper_empty.gds> \
signoff/run_precheck_native.sh $R/stream/openframe_project_wrapper.gds $R/precheck

# ChipFoundry's own precheck (needs Docker and their `cf` tool):
signoff/make_cf_project.sh $R/stream <project_dir>     # their template's layout
cf setup --only-pdk --project-root <project_dir>       # once: their PDK copy
cf precheck --project-root <project_dir>
```

For the ChipFoundry run, stream out with
`PDK_ROOT=<project_dir>/dependencies/pdks/sky130A`: their LVS compares against their
PDK copy's standard-cell netlists, and five cells (`conb_1` among them) differ in
layout from older PDK copies. The LEFs are identical, so place and route is
unaffected.

- **Stream-out** is the chip's, plus the two connection blocks' GDS and the die box
  on 235/4 (prBoundary), which ChipFoundry's density check takes as the chip area.
  The GDS is 230 MB (23 MB gzipped) with one top cell.
- **LVS** uses the frame's supply names. Each frame supply has several pins on the
  wrapper's edge that the frame joins outside it, so texts of one supply name count
  as one net; the core grid has no text of its own and gets its name only through
  the metal from a frame pin.
- **Port ties.** Each pad's static configuration ports are wired straight to that
  pad's `gpio_loopback_one`/`zero` port, with no device on the wire. Pegasus cannot
  compare such wires: it lists them as label shorts and still reports MATCH.
  `lvs_port_ties.py` compares them with the netlist's `assign` statements.
- **`run_precheck_native.sh`** runs the checks of ChipFoundry's precheck that need
  only KLayout and Magic, with cf-precheck's own decks and command lines, without
  Docker. Run one check at a time on a shared machine (`klayout_beol` holds 9 GB).
- **`make_cf_project.sh`** lays a stream-out out as ChipFoundry's template does,
  with the inputs in `cf/` that their Magic/netgen LVS needs:
  - `lvs_config.json`: the SRAM and the ADC macro as abstracts (black boxes), the
    connection blocks flattened, and `"EXTRACT_TYPE": "analog"` as in their
    template, which joins same-named top-level supply pins. Without that line the
    core supplies come out as `vccd1_uq0` and nothing downstream finds them.
  - `macros_blackbox.v`: port-only modules for the two macros. They must be Verilog
    with bus ranges; a SPICE stub gets the buses reversed.
  - the flat netlist (`.pg.flat.v`): their hierarchy check compares the netlist's
    module hierarchy with the layout's, and the layout is flat.
  - `cf_relabel_gds.py`: the ADC macro's bus texts are `ctln<7>` in its GDS and
    their tools need `ctln[7]`; the submitted GDS is a copy with those 52 texts
    changed and nothing else.
  - `cvc.power.openframe_project_wrapper`: cf-precheck's default plus four lines
    that declare the macros' outputs as driven. With it their electrical-rule
    check (CVC) reports 0 errors; without it, 516 floating inputs, which are
    exactly the gates fed by the black boxes' outputs. cf-precheck 1.3.7 does not
    read a project power file, so in the precheck the 516 remain as a warning
    that does not fail the check; the file is for running CVC by hand.

### Sign-off result (10 Nov 2026)

| | |
| --- | --- |
| Stream-out, `check_gds.py` | PASS: 208 masters, none empty; 913 pin labels, all on metal; 36 of 36 ADC macro pins and every used SRAM pin reached by routing |
| Perimeter against ChipFoundry's empty wrapper | identical outside the die boundary on met2 and met3, drawing and pin |
| Pegasus DRC (Cadence sky130 deck), before fill | nothing in our routing: 15 rules fire only inside the SRAM macro, `CDR.li.5` and `licon.8a` only inside standard cells, as on the chip |
| Density, before fill | every maximum passes; the minimum-density rules fail (met1 19.8 %, met2 9.6 %, met3 3.9 %, met4 27.1 %, met5 25.9 %), as expected without metal fill |
| Pegasus LVS | MATCH, 201 of 201 cells; SRAMs and ADC macro as black boxes |
| Supplies in the extracted layout | core grid and SRAMs on `vccd1`/`vssd1` (through the connection blocks); ADC macro `vdd` on `vccd1`, `vdda` on `vdda1`, `vss` on `vssa1`, `vref` on `analog_io[15]`, `vinp`/`vinn` on `analog_io[16]`/`[17]` |
| Port ties | PASS: 507 ties in 88 groups (two constants for each of 44 pads), the same in netlist and layout |

ChipFoundry's checks. The same outcomes from the native run (cf-precheck of 28 Oct
2026, KLayout 0.30.9) and from `cf precheck` in their container (cf-precheck 1.3.7);
LVS and the output-enable check only in the container:

| Check | Result |
| --- | --- |
| `topcell_check`, `illegal_cellname_check` | PASS |
| `xor` against `openframe_project_wrapper_empty` | PASS, 0 differences |
| `klayout_feol` | FAIL, 29: 28 inside the SRAM macro (`MR_psdm.SP.1` 25, `MR_licon.SP.6` 3), 1 inside the ADC macro (`MR_capm.SP.2`) |
| `klayout_beol` | FAIL, 522, all inside the SRAM macro (`MR_mcon.CON.10` 520, `m2.2` 2) |
| `klayout_offgrid` | PASS |
| `klayout_met_min_ca_density` | PASS: clear area li1 65.4 %, met1 80.1 %, met2 90.4 %, met3 96.1 %, met4 72.8 %, met5 74.1 % (minimum 40 %) |
| `klayout_pin_label_purposes_overlapping_drawing`, `klayout_zeroarea`, `spike_check` | PASS |
| `lvs` | PASS: hierarchy check passed, "Circuits match uniquely", SRAMs and ADC macro as abstracts; 49 min, of which Magic's single-threaded extraction of 1.5 M instances is most |
| `oeb` | PASS |

ChipFoundry's own unmodified template passes `lvs` and `oeb` in the same container
in about a minute, which is a useful first test of an installation.

Nothing is flagged in the routing or the standard cells. The two failures are in
macros:

- **SRAM.** `sky130_sram_8kbyte_1rw_32x2048_8` (OpenRAM) has contacts not covered by
  li1 in its replica columns and bit cells, implant spacings under 0.38 um in its
  delay chain and predecoders, and one met2 spacing. The Cadence deck reports the
  same rules inside the macro with the same counts (`CDR.mcon.cover.1` 520,
  `CDR.psd.2` 25, `CDR.m2.2` 1). ChipFoundry's deck has an
  `sram_exclude` switch for the implant rules, which their precheck leaves off, and
  no exemption for the contact rule, so this macro cannot pass their precheck as it
  runs today. Their knowledge base offers their own SRAM through their IP manager
  (`CF_SRAM_1024x32`). Whether they waive OpenRAM-internal results is a question for
  ChipFoundry.
- **ADC macro.** In `sar_afe__bootstrap_sw` a separate met3 via landing at local
  (0.06-1.26, 18.675-19.59) is 0.75 um from the bottom plate of the top MIM capacitor
  as the deck defines it (capm outline grown by 0.14 um); the deck wants 1.2 um
  between a bottom plate and any met3 not connected to it. The landing is 0.89 um
  from the capm itself, so the deck's 0.5 um rule for capm against unrelated met3
  passes, and the Cadence deck does not flag the spot.

## Gate-level simulation

`sim/` runs the routed netlist under the SoC Labs testbench with Xcelium. The
testbench (`nanosoc_tb_GATE.v`), the software build, the program upload over the
host link and the pass message are those of the RTL simulation (`make run_xr`), so
the two logs compare line for line.

```
# 1. netlist and SDF from the routed database (Innovus, about a minute)
innovus -stylus -no_gui -batch -execute "set DB <signoff db>; set OUT $R/simnet" \
        -files sim/write_sim_netlist.tcl
# 2. simulate (seconds)
sim/run_gl_sim.sh $R/simnet $R/sim_gl hello            # unit-delay cells, power-aware
sim/run_gl_sim.sh $R/simnet $R/sim_gl_sdf hello sdf    # the netlist's delays (slow corner), 30 ns clock
SMALL_SW=1 sim/run_gl_sim.sh $R/simnet $R/sim_gl adc_trigger_test   # a project test, built to fit
# 3. the same with the memory blocks as their gate netlists and their own SDF
#    (pre-hardened DFFRAM only; ./fetch_dffram.sh --sim first; about a minute for hello)
MEM_GATES=1 SDF_CORNER=slow sim/run_gl_sim.sh $R/simnet $R/sim_mem hello sdf
MEM_GATES=1 SDF_CORNER=fast SMALL_SW=1 MAKE_ARGS=PROJ_SW_DIR=$PWD/sw/testcodes \
        sim/run_gl_sim.sh $R/simnet $R/sim_mem of_mem_test sdf
# one memory block on its own, gate netlist + SDF, random traffic
sim/run_dffram_gl_unit.sh $R/unit 512 slow
# 4. the board's flash (see "Booting from the board's flash"): the program in the
#    flash only; written through the chip first; and with no host connected
FLASH=boot sim/run_gl_sim.sh $R/simnet $R/sim_flash hello
FLASH=prog sim/run_gl_sim.sh $R/simnet $R/sim_prog hello
FLASH=boot NOHOST=1 sim/run_gl_sim.sh $R/simnet $R/sim_nohost hello
# 5. any of these on the wrapper's RTL in place of a netlist (no netlist directory needed)
RTL=1 FLASH=boot sim/run_gl_sim.sh - $R/sim_rtl hello
```

`SDF_CORNER` is `slow` (the default), `typical` or `fast`: the SDF holds the three
as each delay's three values.

`SMALL_SW=1` builds the program as "Firmware size" describes; without it a project
test needs `MAKE_ARGS=TOOL_CHAIN=gcc` and is too large for the instruction memory.

| File | Does |
| --- | --- |
| `write_sim_netlist.tcl` | Flat netlist with power pins on every cell (no fill, tap or decap cells) and an SDF file with the fast, typical and slow corners as each delay's three values. Flat, so that no module name can clash with a testbench model: the hierarchical netlist still has modules named like RTL ones. |
| `nanosoc_chip_pads_openframe.v` | A module called `nanosoc_chip_pads`, which is what the testbench instantiates: the netlist inside a model of ChipFoundry's frame (44 pads, loopback constants, reset pad, power-on reset). It preloads the instruction memory from `image.hex` as the RTL run's preload does, and checks every pad's static configuration against the pad map once reset is over. |
| `openframe_gl.flist` | The file list: testbench and verification IP, the frame model, the netlist, the standard-cell, SRAM and ADC models. |
| `spiflash_model.v` | A model of the board's SPI flash, on GPIO 36, 37 and 39-42 in the frame model: read, program, erase, ID, power-down. |
| `openframe_rtl.flist`, `genus_flist_to_xrun.py`, `openframe_project_wrapper_rtl.sv` | For `RTL=1`: the same testbench and frame model around the wrapper's RTL, from the file list synthesis reads. |
| `sdf_flat_names.py` | Rewrites the SDF's instance names for the flat netlist (below). |
| `run_gl_sim.sh` | Runs it. Exits 0 only if the test passed, the frame model reported no error and, with `sdf`, the whole SDF was applied. |
| `dffram_gl_preload.py` | For `MEM_GATES=1`: writes the tasks that put a word into, or read it from, the 32 storage latches that hold it in a DFFRAM block's gate netlist. |
| `tb_dffram_gl.v`, `run_dffram_gl_unit.sh` | One DFFRAM block on its own as gate netlist plus SDF, against a reference array. |
| `../sw/testcodes/of_mem_test/` | A test program that writes and reads the data memory and both expansion memories with every kind of access (the other programs write a few words of stack). |

Things that are easy to get wrong:

- **The SDF and the flat netlist name instances differently.** Innovus writes
  `u_a/g123` with `/` as hierarchy divider; the flat netlist has one escaped name
  `\u_a/g123 `. Xcelium then finds none of those instances, gives one warning per
  block (`SDFINF`, four in all) and leaves 99.5 % of the cells at zero delay. The
  run still starts and then fails in confusing ways. `sdf_flat_names.py` escapes
  the dividers; `run_gl_sim.sh` fails if any `SDFINF` remains.
- **Power pins.** Without `-include_pg` Innovus still writes power pins for the
  cells that came from synthesis, and none for the ones it added itself. The netlist
  is therefore written with `-include_pg` and simulated with the `USE_POWER_PINS`
  cell models, which also checks every cell's supply connection.
- **The testbench's clock is fixed at 20 ns.** With `sdf` the script makes a copy
  of the testbench with a 30 ns clock, the period the design is constrained to.
- **Timing violations at synchronisers are expected.** The host link's inputs are
  asynchronous to the clock, so the first flop of their synchronisers reports
  setup and hold violations. The run uses `xrun -nonotifier`, which reports
  violations without corrupting state.

### Gate-level result (11 Nov 2026, Xcelium 24.09)

| Run | Result |
| --- | --- |
| RTL `hello` (baseline) | passes at 92.8 us |
| Gate level, unit delay, `hello` | passes; host-link and UART output byte-identical to the RTL run; all 44 pads configured as the pad map says |
| Gate level, SDF (typical, 1.8 V, 100 C), 30 ns clock, `hello` | passes at 267.8 us; 97.5 % of path delays and all timing checks annotated; 146 timing violations, all on the first flop of the host link's two data synchronisers |
| Gate level, `adc_trigger_test`, default build (12 kbytes) | **does not run: the program does not fit** (below) |
| Gate level, unit delay, `adc_trigger_test`, small build (1.3 kbytes, 16 Nov) | **loads and boots, then never ends: the ADC's control logic is never reset** (below) |
| The same with the control logic's 47 flops given their reset values until the first `sar_clk` edge | passes at 656.5 us; all four output logs byte-identical to the RTL run |

**The memories are half the size the RTL says.** Each of the four memory regions
is declared 16 kbytes (`*_RAM_ADDR_W = 14`), but the SKY130 `sl_sram` wrapper
(`nanosoc/asic_lib_tech/sram/SKY130/verilog/sl_sram.v`) instantiates one 8 kbyte
macro and leaves the top address bit unconnected, so the upper half of each region
mirrors the lower half. `hello` is 1 kbyte and runs. `adc_trigger_test` built with
gcc is 12 kbytes: it passes at RTL, where the preload replaces the instruction
memory with a 16 kbyte ROM model, and cannot run on the netlist. Whatever replaces
the OpenRAM macros should be sized from the software, and the wrapper should stop
the build when the macro is smaller than the region.

**The ADC's control logic has no working reset (found 16 Nov 2026).** `sarlogic`
(`analog/cadence/sar_adc/sarlogic/functional/verilog.v`) is clocked by `sar_clk`,
which `sar_adc` divides from the system clock with flops that are reset
asynchronously, so `sar_clk` stands still for as long as reset is asserted. Commit
bf3fd66 changed `sarlogic`'s reset from asynchronous
(`always @(posedge clk or negedge rstn)`) to synchronous (`always @(posedge clk)`).
A synchronous reset needs a clock edge while reset is low, and there is none, so the
block is never reset. In the netlist its 47 flops have no reset pin
(`dfxtp`, where the divider's four are `dfrtn`), and in the gate-level run `sample`,
`ctlp`, `ctln` and the comparator clock stay unknown for the whole test, which then
waits for a conversion for ever. RTL simulation does not show it, because `sarlogic`
also has an `initial` block that sets the same registers at time zero. On silicon
the flops would power up in an arbitrary state, and some states never leave:
`state` 6 or 7 (the `case` has no default), conversion with `mask` zero, calibration
with `trim_mask` zero. Giving the flops their reset values until the first `sar_clk`
edge, which is what the asynchronous reset did, makes the test pass (third row
above; the forcing was a temporary file, not part of `sim/`). The fix belongs in the
RTL: the asynchronous reset back, or a reset held until `sar_clk` has run.

Also found on the way: the ADC's behavioural model
(`agriculture_soc_main/ADC/sim/sar_afe_model.v`) did not compile with
`USE_POWER_PINS`, because an internal variable had the same name as the `vref`
port. The variable is now `vref_v` (and so is the one reference to it in
`ADC/tb/sar_adc_tb.v`).

Not covered at the time: the slow and fast corners (the SDF then was the typical
view only; see "Whole-chip simulation with the memories as gates" for all three),
the upper halves of P0 and P1 (the testbench connects bits 7..0 only), the debug
port beyond what `hello` uses, the ADC test with SDF delays, and the other project
tests.

### Firmware size (16 Nov 2026)

The test programs are small; the C library is what fills the memory. Image size
(code plus initialised data, gcc 10.3, Cortex-M0), built in place with the tests'
own makefiles and only `GNU_CC_FLAGS` replaced:

| Program | Default (`-O3`, full newlib) | Small build |
| --- | --- | --- |
| `adc_trigger_test` | 12,072 | 1,272 |
| `adc_autonomous_test` | 4,968 | 2,224 |
| `fifo_drain_test` | 4,948 | 2,228 |
| `rtc_time_test` | 3,444 | 1,400 |
| `sensing_driver_test` | 5,384 | 2,636 |
| `fault_recovery_test` | 3,884 | 1,856 |
| `pslverr_test` | 5,072 | 2,244 |

The small build is `-Os --specs=nano.specs -ffunction-sections -fdata-sections
-Wl,--gc-sections` plus `sw/small_puts.c` on the compile line. In
`adc_trigger_test` the steps give 12,072 -> 12,020 (`-Os`) -> 4,848 (newlib-nano)
-> 4,144 (unused sections dropped) -> 1,272 (`small_puts.c`): the program calls
`puts()`, and the library's `puts()` brings buffered stdio and `malloc` with it,
9 kbytes of code and 2 kbytes of data in full newlib. `main` itself is 128 bytes.
The other tests already print through their own UART routines
(`sensing_print.h`), which is why they start smaller.

RAM use of every small build is under 150 bytes of data plus the 512-byte stack,
and no heap. The small `adc_trigger_test` passes the RTL simulation with the same
output as the default build; the only difference in the accelerator access log is
the FIFO status it reads, because it reaches that read sooner.

So an instruction memory of 4 kbytes holds any of these with room to spare, and a
data memory of 1 kbyte is enough. What is still to settle before sizing the
memories from this is the size of the application the chip is meant to run, which
these tests only indicate.

`sw/openframe.ld` (18 Nov) is a linker script for exactly these sizes: 4 kbyte at
address 0, 1 kbyte at 0x30000000, the stack growing down from the top of the data
memory, 384 bytes kept free for it. A program that does not fit is a link error.
`sim/run_gl_sim.sh` uses it for the small build. With the SoC Labs script
(64 kbyte and 15 kbyte) the programs ran here only because addresses wrap, which
happened to put the stack at the top of the 1 kbyte memory.

## Memories (16 Nov 2026)

ChipFoundry does not accept OpenRAM macros, so the four 8 kbyte OpenRAM blocks are
replaced by DFFRAM: memory made of standard cells only. `OF_MEM` (environment,
read by `Cadence/scripts/config.tcl`; the same value for synthesis and for place
and route) picks the set:

| `OF_MEM` | Blocks | imem / dmem / expram_l / expram_h | Macro area |
| --- | --- | --- | --- |
| `prebuilt` (default) | ChipFoundry's pre-hardened OL-DFFRAM blocks (github.com/efabless/OL-DFFRAM, Apache-2.0, commit 8aaa518; `./fetch_dffram.sh`) | 4 k (2 x DFFRAM512x32) / 1 k (DFFRAM256x32) / 512 (DFFRAM128x32) / 512 = 6 kbyte | 3.71 mm2 |
| `compiler_latch`, `compiler_dff` | built here with the DFFRAM compiler (github.com/AUCOHL/DFFRAM, commit ba52684), latch or flip-flop storage | 4 k (RAM1024) / 2 k / 2 k / 2 k (RAM512) = 10 kbyte | 4.28 mm2 (latch), 4.84 mm2 (flip-flop) |

The four OpenRAM macros were 3.22 mm2 for a nominal 32 kbyte (81.5 kbit/mm2).

The region sizes are no longer hidden: `config.tcl` writes them to
`Cadence/outputs/of_mem_config.vh`, `rtl/openframe_project_wrapper.v` sets them on
`nanosoc_system` with `defparam` (`nanosoc_chip` passes no parameters down), and the
memory wrapper stops elaboration for a size it has no macro for.

### The blocks

| Block | Size (um) | Area | Density | Clock to Do0, slow corner | Inputs sampled |
| --- | --- | --- | --- | --- | --- |
| OpenRAM 8 kbyte (for comparison) | 1110.5 x 723.9 | 0.804 mm2 | 81.5 kbit/mm2 | | |
| DFFRAM512x32, pre-hardened, 2 kbyte | 1199.2 x 1031.7 | 1.237 mm2 | 13.2 kbit/mm2 | 7.8 ns | falling and rising edge |
| DFFRAM256x32, pre-hardened, 1 kbyte | 1152.8 x 535.6 | 0.617 mm2 | 13.3 kbit/mm2 | 11.6 ns | falling and rising edge |
| DFFRAM128x32, pre-hardened, 512 byte | 551.1 x 561.8 | 0.310 mm2 | 13.2 kbit/mm2 | 6.7 ns | falling and rising edge |
| RAM512, compiler, latch, 2 kbyte | 811.0 x 1052.6 | 0.854 mm2 | 19.2 kbit/mm2 | 17.8 ns | falling and rising edge |
| RAM512, compiler, flip-flop, 2 kbyte | 917.7 x 1052.6 | 0.966 mm2 | 17.0 kbit/mm2 | 16.5 ns | rising edge |
| RAM1024, compiler, latch, 4 kbyte | 1618.3 x 1060.8 | 1.717 mm2 | 19.1 kbit/mm2 | 25.0 ns | falling and rising edge |
| RAM1024, compiler, flip-flop, 4 kbyte | 1831.7 x 1060.8 | 1.943 mm2 | 16.9 kbit/mm2 | 24.6 ns | rising edge |

- All three pre-hardened blocks pass ChipFoundry's FEOL, BEOL, off-grid and
  zero-area decks with 0 violations (the OpenRAM macro had 550). Their standard
  cells are geometrically identical to the ones in ChipFoundry's PDK copy.
- The compiler's blocks pass the same decks on their own (FEOL, BEOL, off-grid; 0
  violations for the 2 kbyte and the 4 kbyte block in both variants). KLayout
  0.30.9 crashed twice on these decks with several threads, once after writing a
  complete report; `THREADS=2` avoided it.
- The compiler's README quotes 26 kbit/mm2 for its blocks at every size. Built
  here (LibreLane 2.4.2, its pinned PDK) the latch blocks come out at 19.1-19.2,
  the 2 kbyte and the 4 kbyte block alike. The README figure is out of date, not
  something this build missed:
  - It is a macro-level figure (the table gives width by height, 792.6 x 786.1 um
    for 2 kbyte) and was entered in September 2022.
  - The macros in the compiler's own latest release (2025.11.10) are at 19 as
    well: 406.2 x 525.0 um for 512 byte (19.2) and 809.6 x 533.1 um for 1 kbyte
    (19.0), the README's width and about 35 % more height.
  - Between the two, in early 2023, the compiler's 32-word block was reorganised
    for timing into two 16-word halves, each with its own row of output
    registers. In the 2 kbyte latch block built here every 16 words (8 rows of
    storage) are followed by two partly used rows of output buffers and
    registers and three rows holding two or three buffers each, filled to full
    width with decap. Decap and fill are 0.215 mm2, a quarter of the block.
  - There is nothing to turn: the block's size is whatever the compiler's own
    placer produces (cells cover 74 % of the core as a result, not as a
    target), and its only options are the halo, 1.2 % of the block, and a
    minimum height.
  - Storage rows alone, with their gates and taps, are at 29 kbit/mm2 for
    latches and 26 for flip-flops, so a flip-flop block could not reach the
    README figure with no periphery at all.
  - That this build's cell area (0.628 mm2 for 2 kbyte) is close to the README's
    macro area (0.623 mm2) is a coincidence.

  A 2 kbyte block took 25 minutes, a 4 kbyte block 50; all four finished with 0
  DRC errors and a clean LVS in the compiler's own flow, and with antenna
  violations it does not repair (61 to 295 nets per block).
- The compiler's blocks are slow: a 4 kbyte block needs 25 ns from clock to data
  at the slow corner, and its data input has to hold for 7.5 to 8 ns after the
  clock.
- Latch storage is written while the clock is low, so the latch blocks check
  their address, enable, write-enable and data inputs against the FALLING clock
  edge as well: those paths get half a period.
- The two smaller pre-hardened blocks have old-format timing libraries: no clock
  flag on CLK, and all three "corners" state 1.60 V and 100 C with nearly the same
  clock-to-output delay. Their hold numbers are not to be relied on.

**The compiler's blocks are not drop-in synchronous RAMs.** They keep an output
register per 16 words and select among those registers with the address pins as
they are at that moment (`models/ram/model.v`: the output muxes take `A0` itself).
Read data is only right while that read's address is still on the pins. An AHB
bridge for a synchronous SRAM presents the next address in the cycle in which it
takes the previous read's data, so a read into another 16-word block returns that
block's register, which holds zero. With the standard bridge on a compiler block,
930 of 2,196 random reads return wrong data (`sim/tb_sl_ahb_sram_hold.v`, control
run). ChipFoundry's pre-hardened blocks register the select inside the macro and
do not have this.

`rtl/sl_ahb_sram_hold.v` is the bridge for the compiler's blocks: it latches each
transfer, holds address, data and controls on the macro until the access is over
and takes the read data into its own register. A read costs two wait states, a
write one. With it the same test passes: 2,196 reads, 1,804 writes, 3,217 of the
transfers back to back, 0 failures, for both block sizes.

### Using a block in the layout

- The LEFs declare no symmetry: Innovus places the blocks unrotated only
  (`place_inst ... my` fails, and without a check the block stays at the origin).
- Supplies are vertical met4 straps across the block and nothing on met5. The
  grid's horizontal met5 stripes run over the blocks and `add_stripes` drops a
  via4 on every strap they cross; the grid's own met4 stripes stop at each block.
  `power_plan.tcl` requires at least one via per strap and net.
- Signal routing is kept off met4 over the blocks (`create_route_blockage
  -except_pg_nets`). The LEFs leave met4 free between the straps; NanoRoute used
  it to reach the data pins and left one short that three repair passes did not
  remove.
- Stream-out takes the standard-cell library GDS first: the blocks carry their own
  copies of the standard cells under the same names.
- Signals are also kept off met3 over the 512 byte block, apart from the strip
  where its right-edge pins are: see "Dev-board pad map and clock registers".

### Result with the pre-hardened blocks (`OF_MEM=prebuilt`)

The final build: cells on the PDK's DRC-exclude list excluded from synthesis on,
50 ps hold margin in routing, the RTC's clock constrained.

| Step | Result |
| --- | --- |
| Synthesis | the three region sizes elaborate as `sl_sram_AW12`, `AW10`, `AW9`; no cell of the DRC-exclude list |
| Place and route, 30 ns | 27,745 instances; setup WNS +0.048 ns, hold WNS +0.050 ns, recovery +4.88 ns; no violating path; `clk1hz` has a clock tree of 35 sinks |
| Post-route DRC (Innovus) | 6 markers, all the frame-pin ones of the reference run |
| Stream-out | PASS, 0 warnings; every macro pin touched by routing |
| Pegasus LVS | MATCH, 215 cells; the DFFRAM blocks and the ADC macro as black boxes; port ties PASS (88 groups) |
| Gate level, unit delay | `hello` and `adc_trigger_test` pass, output identical to RTL |
| Gate level, SDF, 30 ns clock | both pass, output identical to RTL, 0 timing violations reported |
| ChipFoundry FEOL deck, whole chip | 1 violation: `MR_capm.SP.2` in the ADC macro (known, with the analog team). The OpenRAM version had 29. |
| ChipFoundry BEOL deck | PASS, 0 violations (the OpenRAM version: 522) |
| ChipFoundry off-grid, pin-label, zero-area, spike, top cell, cell names | PASS |
| ChipFoundry density (clear area) | PASS: li1 58.9 %, m1 79.2 %, m2 94.1 %, m3 96.1 %, m4 72.9 %, m5 67.2 % |
| ChipFoundry XOR against the empty frame | PASS, 0 differences |
| ChipFoundry's own LVS and OEB, in their container (cf-precheck 1.3.7) | LVS PASS (58 min), OEB PASS; the DFFRAM blocks and the ADC macro as abstracts |

On the build before it (the same without the RTC clock constraint), the same
decks and ChipFoundry's container LVS and OEB gave the same results, and in
addition:

| Step | Result |
| --- | --- |
| Gate level, unit delay, the other project tests (small builds) | `rtc_time_test`, `fifo_drain_test`, `adc_autonomous_test`, `fault_recovery_test`, `pslverr_test`: all pass, output identical to the RTL run of the same build |
| Gate level, SDF | passes; 36 removal violations on the RTC counter's flops (below) |
| `sensing_driver_test` | fails with the small build, at RTL and identically on the netlist; passes at RTL with the default build (below) |

And on the build before that (194 cells of the DRC-exclude list still in it, six
`and2_0` swapped by ECO), the same decks and ChipFoundry's container LVS and OEB
with the same results.

**The 1 Hz RTC clock is not constrained.** `clk1hz` is divided from the system
clock by a counter in `nanosoc/system/src/accelerator_subsystem.v` and clocks the
RTC's counter and its reset synchroniser. No constraint file defines a clock on
it, so static timing analysis sees no clock on those 60 flops (`check_timing`:
68 "clock not found where clock is expected", `report_timing` to them: "no
constrained timing paths"), checks nothing there and builds no clock tree: the
net is buffered like data. In the SDF simulation of the build before the final one the counter's reset is
released 0.48 ns after its clock edge where the flop needs 0.59 ns (36 removal
violations, at the two reset releases of the run); in the other builds the same
unchecked paths happened to come out wide enough. A hold or removal failure does
not depend on the clock rate. With the clock defined in a scratch timing session
on the routed database,

```
create_generated_clock -name clk1hz -source [get_ports {gpio_in[38]}] -divide_by 100 \
    [get_pins <...>u_ss_accelerator_clk1hz_reg_reg/Q]
set_clock_groups -asynchronous -group [get_clocks clk1hz] -group [get_clocks clk]
set_propagated_clock [get_clocks clk1hz]
```

static timing analysis sees the same thing as the simulation: removal -0.099 ns on
the counter's reset, hold +0.089 ns, set-up and recovery wide. The constraint is
now in `Cadence/inputs/constraints.sdc` (with the divide ratio as a variable, see
the next paragraph), and the final build was made with it: `clk1hz` gets its own
clock tree, timing is met and the SDF simulation reports no violation. The
chip-level constraints (`ASIC_ours/Cadence/inputs/constraints.sdc`) have the same
block since the clock-register change below.

**The 1 Hz divider is still at its simulation value.** The same file sets
`localparam CLK1HZ_DIV = 32'd50`, with the comment "this value is sim-friendly.
For real hardware set it to (HCLK_hz / 2)". Every netlist built so far, here and
in the chip-level flow, therefore has an RTC tick of the system clock divided by
100 (333 kHz at 33.3 MHz), not 1 Hz. It is a `localparam`, so nothing outside the
file can override it. The value for silicon and a way to keep the simulation
value for tests (a parameter or a define) have to be decided before tape-out.
(Done since: the divide is now a register, see "Dev-board pad map and clock
registers".)

**Cells with known DRC problems were in use.** The first FEOL run on this layout
reported three `npc.2` errors (NPC spacing 0.16 um, 0.27 um needed), each where a
`sky130_fd_sc_hd__and2_0` stood left of a `decap_12`. `and2_0` is on the PDK's
list of cells with known DRC problems (open_pdks,
`libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells`), which this flow never
applied: 200 instances of listed cells were in the design. They only show with
ChipFoundry's copy of the standard cells, which their LVS needs.
`Cadence/scripts/dont_use.tcl` now marks the 53 listed cells unusable in Genus and
in every Innovus stage, and the final build has none. The build before it, on
which ChipFoundry's decks were run, still held 194 listed cells in positions the
deck does not object to; its six `and2_0` were swapped by ECO.

**`sensing_driver_test` clears the FIFO while a conversion may still be under
way.** Built the default way (5.4 kbyte, `-O3`, full newlib) it passes at RTL.
Built small (2.6 kbyte, see "Firmware size") the same source fails at RTL: "FIFO
not empty after clear", and five samples drained after four triggers. The netlist
gives exactly the same output, so this is neither the memories nor the layout.

Traced at RTL with the peripheral's own trace (`EXTRA_DEFINES=+define+SENSING_DEBUG`).
Autonomous polling is on from reset, so with the simulation's RTC divider a
conversion starts every 500 clocks and delivers its sample 85 or 89 clocks later
(which of the two depends on the phase of the ADC's divided clock). The
test turns polling off and writes `fifo_clear` 8 clocks after that, then waits.
Turning polling off stops new conversions; it does not stop one already started,
and that one's sample lands in the FIFO after the clear:

| Build | Last autonomous trigger | Its sample reaches the FIFO | `fifo_clear` | Result |
| --- | --- | --- | --- | --- |
| small | 79,546 ns | 80,436 ns | 80,016 ns, 42 clocks before the sample | one stray sample; fails |
| default | 99,546 ns | 100,436 ns | 100,816 ns, 38 clocks after the sample | passes |

So the default build passes by 38 clocks, and any change in how long start-up
takes (compiler options, memory wait states, the text printed first) moves the
clear in or out of that window of up to 89 clocks in each 500. The settle delay in the test
is on the wrong side of the clear. With `sensing_delay(CONV_SETTLE)` moved to
between `sensing_polling_disable()` and `sensing_clear_fifo()` the small build
passes (checked at RTL, in a copy of the test; the test in the repository is
unchanged). The same order matters to any firmware that pauses polling and then
clears the FIFO, so it may belong in the driver rather than in each caller. On
silicon the window is the same number of clocks in every polling period, which
makes it rare, not absent.

The half-period input checks of the latch blocks are met at 30 ns: in the first
routed build the worst one (CPU address register to the instruction memory's
`A0`) had 12.2 ns of logic, the block's 5.2 ns set-up and a clock that reaches
the block 2.2 ns after it reaches the CPU.

### Whole-chip simulation with the memories as gates (16 Nov 2026)

The pre-hardened blocks store their bits in latches, written through gated
clocks during the low half of the clock and read through tri-state lines. The
DFFRAM compiler's README marks the SKY130 latch variant silicon-proven and adds
that this "does not imply that you should use it without whole-system,
timing-annotated simulation". The gate-level runs above had models in place of
the memories, and their SDF was the typical corner only. So, on the final build:

- `MEM_GATES=1` puts ChipFoundry's gate netlist of each block (OL-DFFRAM
  `hdl/gl`) in place of the model, and gives each of the five block instances
  ChipFoundry's SDF for that block at the corner being run. The rest of the chip
  has the Innovus SDF for the same corner. 30 ns clock.
- 99.1 % of the path delays are annotated (the rest are edge-specific paths the
  PDK's cell models do not have, as before), and every setup/hold (125,888) and
  recovery/removal (3,907) check. ChipFoundry's SDF carries no pulse-width
  checks for the blocks' cells, which keep the cell models' defaults.
- The chip-level wire delay to a block's pin and the block's own wire delay
  behind the pin add up, as they should (probed on the clock of one block:
  0.044 ns to the pin, 0.101 ns to the first cell inside, the block's SDF giving
  0.057 ns for that wire).
- The program is deposited into the instruction memory's latches once reset has
  made every block's write enables low, and read back from them before the
  processor starts (`sim/dffram_gl_preload.py`).

| Test | Slow | Typical | Fast |
| --- | --- | --- | --- |
| `hello` | passes | passes | passes |
| `adc_trigger_test` | passes | | passes |
| `of_mem_test` (below) | passes | passes | passes |
| `rtc_time_test` | passes | | |
| `fault_recovery_test` | passes | | |
| `adc_autonomous_test` | passes | | |
| `fifo_drain_test` | passes | | |
| `pslverr_test` | passes | | |
| `hello` with a 16 ns clock (control) | does not boot, as expected | | |

- Host-link, UART and accelerator logs are byte-identical to the earlier run
  with memory models (`hello`, `adc_trigger_test`) or to the RTL run of the same
  program (the others), with one kind of exception: three programs print an RTC
  reading that is one count away from the RTL run's (`rtc_time_test` 0x11A5 for
  0x11A4, `pslverr_test` 0xDE7 for 0xDE8, `adc_autonomous_test` 0x6E for 0x6F).
  `rtc_time_test` run again with memory models gives the same value as with the
  gates, so this comes with the delays and the 30 ns clock, not with the
  memories; the unit-delay runs matched RTL exactly.
- Timing violations reported: none at the slow and typical corners. At the fast
  corner only on the first flop of the host link's data synchroniser, whose
  input is asynchronous to the clock.
- `sensing_driver_test` was not run: it fails for the reason given above.

**`of_mem_test`** (`sw/testcodes/of_mem_test`) exists because the other programs
write a few words of stack and nothing else. It writes words, single byte lanes
and halfwords and reads them back, on both expansion memories (all 128 words of
each), the free part of the data memory (64 words) and the instruction memory:
its 32 interrupt vectors, saved and restored, and its top 256 words. The
instruction memory matters most: on the chip a program gets into it by writes
over the host link, and the simulation's deposit goes around that path.

**The blocks on their own** (`sim/run_dffram_gl_unit.sh`: one block as gate
netlist with its SDF, the preload read back, 6000 random cycles, every word
checked at the end):

| Block | Inputs change 3 ns after the rising edge (30 ns clock) | Inputs change 0.05 to 0.1 ns after it | Inputs change 12 ns after it |
| --- | --- | --- | --- |
| DFFRAM128x32 | passes, slow and fast | passes | fails (slow) |
| DFFRAM256x32 | passes, slow and fast | fails (fast: 2975 of 3395 checks) | not run |
| DFFRAM512x32 | passes, slow and fast | fails (slow: 1838 of 4163; fast: 1308) | fails (slow: 2170 of 4163) |

So the two requirements in the blocks' timing libraries are real ones: the
inputs must hold for a time after the rising edge (0.4 ns fast, up to 1.4 ns
slow in the 512-word block's library), and must be there some nanoseconds
before the falling edge. Static timing checks both on every path into the
blocks, and the whole-chip runs agree with it. A bus that changes its outputs
on the clock edge with no delay would corrupt the two larger blocks.

What this does not show: it is three corners with ChipFoundry's SDF for the
blocks taken as given, not a replacement for the static timing; the write path
of the lower instruction-memory block is exercised on 32 words only; and the
compiler-built blocks have not been run this way.

### Result with the compiler's latch blocks (`OF_MEM=compiler_latch`, 10 kbyte)

One RAM1024 and three RAM512 behind `sl_ahb_sram_hold.v`; 4.28 mm2 of memory.

| Step | Result |
| --- | --- |
| Place and route, 30 ns | 25,881 instances; setup met (the worst check is a latch time-borrowing check on the 4 kbyte block's address, at 0.000 ns; flop-to-flop +0.077 ns), hold WNS +0.005 ns, recovery +4.69 ns |
| Post-route DRC (Innovus) | the 6 frame-pin markers only |
| Stream-out | PASS; 4 warnings: the compiler's GDS labels its internal nets, which the pin check counts as pins |
| Pegasus LVS | MATCH, 208 cells, the memory blocks and the ADC macro as black boxes; port ties PASS. Run on a copy of the GDS in which the blocks keep only their pin labels (`signoff/gds_pin_texts_only.py`); with the compiler's 31,000 to 62,000 internal labels per block the black boxes get the wrong ports and the run reports a mismatch. |
| Gate level, unit delay | `hello` and `adc_trigger_test` pass, output identical to RTL; they take 1.4 and 1.8 times as long as with single-cycle memories, which is the wait states |
| Gate level, SDF, 30 ns clock | both pass; the program output is identical, the boot monitor's echo of the last host-link command is three characters short (`] 0x50c1ab04` for `]<#> 0x50c1ab04`), see below |

### Result with the compiler's flip-flop blocks (`OF_MEM=compiler_dff`, 10 kbyte)

The same four blocks with flip-flop storage; 4.84 mm2 of memory.

| Step | Result |
| --- | --- |
| Place and route, 30 ns | 26,302 instances; setup WNS +0.042 ns (the 4 kbyte block's data out into the bridge's read register), recovery +3.68 ns; hold WNS -0.007 ns on one path in the debug logic, nothing to do with the memories |
| Post-route DRC (Innovus) | the 6 frame-pin markers only |
| Stream-out, Pegasus LVS | stream-out PASS (same 4 label warnings); LVS MATCH, 212 cells, on the pin-labels-only copy; port ties PASS |
| Gate level, unit delay | `hello` and `adc_trigger_test` pass, output identical to RTL |
| Gate level, SDF, 30 ns clock | both pass, 0 timing violations reported; the same three characters missing from the boot monitor's echo |

**The three missing characters.** With SDF delays, both compiler-block versions
print `] 0x50c1ab04` where every other run prints `]<#> 0x50c1ab04`, in the debug
controller's reply to the testbench's last scripted command (`C 201`) before the
program starts. The program's own output is identical in all runs. The `<#>` is
not part of the reply: the debug controller wraps any character the CPU prints
while it is in command mode in `<` `>` (`socdebug_adp_control.v`, state
`ADP_STDOUT`), and `#` is the first character the boot code prints. In the other
runs the first boot gets as far as that `#` before `C 201` restarts the CPU; here
it does not, the boot code being slower through the holding bridge (its stack is
in the data memory). So the likely reading is a harmless race between the
testbench's script and the first boot. It was not confirmed in a waveform, and it
does not appear with unit delays at a 20 ns or a 30 ns clock.

The memory models in these runs (`sim/dffram_pg_models.v`) reproduce the blocks'
live-address output select, so the passing tests do exercise the holding bridge.

## Dev-board pad map and clock registers (16 Nov 2026, evening)

One rebuild with three changes: the pad map above, three clock registers in the
sensing peripheral, and two fixes to the flow that the rebuild itself showed to
be needed.

### The clock registers

| Register | Offset | Reset | Does |
| --- | --- | --- | --- |
| `adc_clkdiv` | 0x110 | 4 | system-clock cycles per half period of the ADC clock (8 bits; 0 also means 4). Was the parameter `ADC_CLK_DIV`. |
| `adc_samplediv` | 0x114 | 0 | the same, but only while the ADC is in its sampling state; 0 means "as `adc_clkdiv`". Lengthens the time the sampling switch is closed without slowing the bit decisions. |
| `rtc_prescale` | 0x22C | 5,000,000 | system-clock cycles per half period of the RTC's 1 Hz tick: half the clock frequency in Hz. Was `localparam CLK1HZ_DIV = 50`. The reset value is for the development board's 10 MHz clock since 18 Nov (16,666,667, for 33.33 MHz, in the build described here). |

- `sar_adc` has two new ports for the first two; its divider compares with `>=`
  and reads `sample` back from `sarlogic`, which is unchanged. With both ports at
  0 the block behaves as before.
- The constraints are for the fastest setting of each divider (`sar_adc.sdc`:
  half period of one clock; `clk1hz`: divide by 2), which covers every slower
  one. Timing is met at 30 ns with them.
- Change the two ADC registers only while the ADC is idle.
- A program that counts RTC seconds in simulation writes
  `SENSING_RTC_PRESCALE_FAST` (50) to `rtc_prescale` first: the four tests that
  do have that line now, and `clock_ctrl_test` checks all three registers.
- ADC testbench (`sar_adc_tb`, new section 7): 1830 checks pass. At every setting
  tried (half periods of 2, 4, 9 and 255 clocks, sampling stretched to 20 and
  255 or shortened to 3) the clock period, the sampling time and the code are
  the expected ones.

### What the rebuild showed

- **A short at the 512 byte block's pins.** The first run ended with one met3
  short between two wires going to an expansion memory's top-edge pins, which
  three repair passes did not clear, and a 57 ps hold violation on the net the
  repair had rerouted. The block's LEF leaves 12 um of met3 free just inside its
  top edge and the router used that strip to reach 39 pins sideways.
  `floorplan.tcl` now keeps signals off met3 over that block, apart from the
  strip at its right edge where its met3 pins are. The rerun routed clean.
- **Process antennas had never been checked.** `check_process_antenna` on that
  first run gave 11 violations, seven on the wrapper's own input pins (a long
  met2 run from the pin to the first gate, with only that gate on the net inside
  the wrapper). The build described as final under "Memories" has seven.
  ChipFoundry's precheck has no antenna check. `route_setup.tcl` now lets
  NanoRoute insert diodes (`sky130_fd_sc_hd__diode_2`), and the last flow stage
  writes `reports/antenna_06_signoff.rpt`. The rerun has no violation and 82
  diode cells.

### Result

| Step | Result |
| --- | --- |
| Place and route, 30 ns | setup WNS +0.018 ns, hold WNS +0.051 ns |
| Post-route DRC (Innovus) | the 6 frame-pin markers only |
| Process antennas | no violations |
| Stream-out | PASS, 0 warnings |
| Pegasus LVS | MATCH, 220 cells; port ties PASS (88 groups) |
| RTL, the seven project tests and `clock_ctrl_test` | all pass |
| Gate level, unit delay: the same eight, `hello`, `of_mem_test` | all pass; the eight's logs identical to their RTL runs |
| Gate level, SDF, memories as gates, 30 ns | `hello` at slow, typical and fast; `adc_trigger_test`, `of_mem_test` and `clock_ctrl_test` at slow and fast; `rtc_time_test` at slow: all pass, no timing violation reported at any corner, logs identical to the RTL runs |
| ChipFoundry FEOL deck | 1 violation: `MR_capm.SP.2` in the ADC macro (known) |
| ChipFoundry's other decks | BEOL 0 violations; off-grid, top cell, cell names, density (clear area li1 58.9 %, m1 79.1 %, m2 94.1 %, m3 96.1 %, m4 72.9 %, m5 67.2 %), pin labels, zero-area, spike: PASS; XOR against the empty frame: 0 differences |
| ChipFoundry's own LVS and OEB, in their container (cf-precheck 1.3.7) | LVS PASS (53 min), OEB PASS; the DFFRAM blocks and the ADC macro as abstracts |

### The RTC reading that differs by one

Three tests print an RTC reading one count away from the RTL run's when they run
on the netlist with SDF (see "Whole-chip simulation with the memories as gates").
It is not a timing problem:

- The three SDF corners agree with each other (`rtc_time_test`: 0x11A5 at slow,
  typical and fast), and RTL and the unit-delay netlist agree with each other
  (0x11A4, at a 20 ns and at a 30 ns clock).
- The program's timeline is not the same in the two kinds of run: the host link
  is asynchronous to the clock, and the same test ends about 350 clocks apart. A
  tick is 100 clocks, so a read can land on either side of one.
- Timed as the synchronous paths they physically are (the tick is divided from
  the system clock; the constraints declare the two asynchronous), the paths
  between the two domains meet setup by 21 ns and hold by 0.2 ns in both
  directions on the routed layout.
- With the prescaler register the difference is gone: the tick now starts when
  the program writes `rtc_prescale`, so it is aligned to the program and not to
  the host link, and `rtc_time_test` on this build prints the same reading at
  RTL and on the netlist with SDF.

## Booting from the board's flash (18 Nov 2026)

The instruction memory is RAM. Until now a host had to upload the program after
every power-up (the simulations preload it). The chip can now start on its own:
the boot ROM copies the program from the development board's SPI flash, and the
flash can be written from the board's USB port.

### What the boot ROM does

`sw/bootrom/of_boot.c` replaces the SoC Labs boot loader in this build only
(`run_flow.sh` builds it and synthesis reads it last; the project's own
`system/src/bootrom` is untouched, so the pad-ring flow keeps the SoC Labs ROM).
It is 832 bytes of the 2 kbyte ROM. At every reset it:

1. sets up the stream port and, with the mode strap high, UART2 at 38,400 baud
   for a 10 MHz clock (the SoC Labs loader does the same with a divider for
   240 MHz);
2. reads the first 16 bytes of the flash, through port pins P1[8..11] (plain SPI,
   commands 0xAB and 0x03), and if they are a valid header copies the program
   that follows them to the instruction memory, summing it;
3. clears REMAP and starts the program in the instruction memory.

| Flash holds | Reset was | The ROM |
| --- | --- | --- |
| nothing valid (an erased flash reads all ones) | any | starts what the instruction memory holds, as before |
| a program | power-on, the reset pin, FLASH_PROG released | copies it, checks the sum, starts it |
| a program whose sum is wrong | the same | stops with "flash: BAD SUM" (the instruction memory is then half written) |
| a program | the system's own: SYSRESETREQ from a debugger or the program, watchdog, lockup (`RSTINFO` not 0) | does not copy: starts what the instruction memory holds |
| a program | any, with 0x50494B53 in the data memory's first word (0x30000000) | does not copy |

The last two rows keep the other ways of loading a program working with a
programmed flash on the board. A debugger loads the instruction memory and
resets with SYSRESETREQ. A host on the host link resets the system with ADP's
reset bit, which the reset-cause register does not record: it writes that one
word as well as the program before it lets the reset go.

The header is `"NSOC"`, the length in bytes, the 32-bit sum of the program's
words, and the length inverted. `sw/mkflashimg.py PROGRAM.bin --bin flash.bin`
makes the flash contents from a program linked for address 0.

A 4 kbyte program takes about 1.2 million clock cycles to load: 0.12 s at
10 MHz (measured in simulation: 286 clock cycles a byte).

Messages (`nanosoc OpenFrame boot`, `flash: loaded` and so on) go to the stream
port and, in FT1248 + UART2 mode, to UART2: the board's USB serial port, GPIO 6.
The stream port stops taking characters when no host is connected, and the SoC
Labs loader would wait there for ever. This ROM gives a character 20,000 polls
(about 25 ms at 10 MHz, measured in simulation) and then leaves the stream port
alone.

### Writing the flash

With FLASH_PROG (GPIO 14) high the chip is in reset and the wrapper passes four
pads straight through: the FTDI's CSB (GPIO 3), SCK (4) and SDI (2) to the
flash's CSB (39), CLK (40) and IO0 (41), and the flash's IO1 (42) back to the
FTDI's SDO (1). The flash is then an ordinary SPI flash on the FTDI's SPI port.
Letting FLASH_PROG go starts the chip from what was written.

Not tried on hardware: which programming tool the board's FTDI wiring suits
(anything that drives an FTDI's SPI pins and speaks the standard flash commands
should do), and the pass-through at speed. Its delay is constrained to 15 ns
each way inside the chip.

### A program on its own

Two things differ when no host is connected:

- **Where it prints.** `UartPutc` in the SoC Labs retarget code writes to the
  stream port and waits while it is full. With no host the port drains only if
  GPIO 8 (the link's data line) is low; fit a pull-down there, or print on UART2.
- **Pins left as inputs** need a level from the board: a bidirectional pad has
  no pull.

## Sensing interrupt, reset values, and the rebuild (18 and 19 Nov 2026)

### Sensing interrupt

| Register | Offset | Reset | Does |
| --- | --- | --- | --- |
| `irq_enable` | 0x118 | 0 | bit 0: interrupt while the FIFO holds a sample; bit 1: interrupt while the FIFO is full |

The interrupt is level and registered: it falls three clock cycles after the
read of `measurement_lo` that removes the condition. It is `EXP_IRQ[0]` of the
accelerator subsystem, the processor's interrupt 11 (`EXP0_Handler`); the other
three lines stay low. `sensing_irq_test` checks the register, that nothing
interrupts with both bits clear, that each of three conversions wakes the
processor from WFI exactly once, and that with bit 1 alone the interrupt waits
for the sixteenth sample.

The RTC prescaler's reset value is now 5,000,000, for the board's 10 MHz clock,
and `adc_samplediv` resets to 8: with the extracted ADC in the mixed-signal
flow a 240 ns sampling phase carries 1.4 % of the previous sample into the next,
and 480 ns does not. `sensing_driver_test` waits for a conversion under way
before it clears the FIFO.

### RTL simulation of the wrapper

Until now the wrapper's own RTL (pad configuration, memory sizes, reset) was only
ever simulated as gates. `sim/run_gl_sim.sh` with `RTL=1` runs the same
testbench and frame model on the RTL: the file list synthesis reads
(`sim/genus_flist_to_xrun.py`), the defines synthesis has, the OpenFrame boot
ROM, and models of the pre-hardened memory blocks. A change to the wrapper or
the boot ROM can be tried in a minute, and the gate-level logs can be compared
with RTL logs of the same design.

### What the rebuilds showed

Five place-and-route runs were needed before one ended clean. Each of the first
four found something the flow now handles:

- **Shorts in the memory blocks' edge strips.** A block's LEF obstructs met1 to
  met4 only over its cell rows, which leaves 4 to 18 um free inside every edge
  on every layer. NanoRoute used those strips to reach the pins sideways and as
  a channel for other nets. One run ended with three met1 shorts at a 512 byte
  block's top edge, the next with a met3 short at a 2 kbyte block's bottom
  edge; no repair pass removed them, ripping the nets up whole included.
  `floorplan.tcl` now keeps signals off met1 over the pre-hardened blocks, off
  met3 except in the 4.5 um at the right edge, and off met2 except at the edges
  with met2 pins. (The same file already kept them off met4, and off met3 over
  the 512 byte block, for the same reason.)
- **Setup at zero.** Three builds ended at +18, +3 and -11 ps on the half-cycle
  path into a memory block's address pins (the blocks take the address on the
  falling edge too). `route_setup.tcl` asks for 0.1 ns of setup margin, and
  `route_drc.tcl` now reports the worst setup and hold slack after its repairs
  and optimises once more if either is negative. On the final run that pass was
  needed (-14 ps before it, +13 ps after).
- **An antenna on a clock net.** The clock tree's nets are kept to met2 and
  met3, so NanoRoute cannot move one up a layer, and it does not put diodes on
  clock nets unless told to. One run ended with a single violation, on a clock
  buffer's input. `route_setup.tcl` now allows diodes on clock nets.
- **Two n-well gaps.** The extra optimisation pass made two cells smaller after
  the fillers were in, which left one free site in one row and two in another:
  gaps between n-wells that Innovus' `check_drc` does not look at and
  ChipFoundry's FEOL deck reports (`MR_nwell.SP.1`). `route_drc.tcl` fills the
  gaps again after the pass and writes `reports/filler_06_signoff.rpt`.

### Result

Final layout of 19 Nov (28,470 logic cells, 95 of them antenna diodes):

| Step | Result |
| --- | --- |
| Place and route, 30 ns | setup WNS +0.013 ns, hold WNS +0.034 ns |
| Post-route DRC (Innovus) | the 6 frame-pin markers only |
| Process antennas | no violations |
| Free sites in the rows (`check_filler`) | none |
| Stream-out | PASS, 0 warnings |
| Pegasus LVS | MATCH, 218 cells; port ties PASS (88 groups) |
| RTL, pad-ring design: `hello` and the nine project tests | all pass |
| RTL of the wrapper (`RTL=1`): those ten, `of_mem_test`, `of_boot_test`, and `hello` with `FLASH=boot`, `prog`, `skip`, `badsum` and with `NOHOST=1` | 17 runs, all as expected |
| Gate level, unit delay: the same 17 | all as expected; the host-side logs of every run identical to its RTL run |
| Gate level, SDF, memories as gates, 30 ns | `hello` at slow, typical and fast; `FLASH=boot`, `FLASH=prog`, `of_mem_test`, `sensing_irq_test` and `adc_trigger_test` at slow and fast; `NOHOST=1`, `rtc_time_test` and `clock_ctrl_test` at slow: all pass, no timing violation reported. Logs identical to RTL, but for one line of `sensing_irq_test`: the value of an ADC sample it prints, taken at a different instant (the host link is asynchronous). `of_boot_test` at slow and fast: pass as well, 18 runs in all |
| ChipFoundry FEOL deck | 1 violation: `MR_capm.SP.2` in the ADC macro (known) |
| ChipFoundry's other decks | BEOL 0 violations; off-grid, top cell, cell names, density, pin labels, zero-area, spike: PASS; XOR against the empty frame: 0 differences |
| ChipFoundry's own LVS and OEB, in their container | LVS PASS (77 min), OEB PASS |

"As expected" for `badsum` is the ROM stopping with "flash: BAD SUM" and the
program not running; for `NOHOST=1` it is the processor fetching the program's
first word with the stream port stalled.

## Checks (19 Nov 2026)

### IR drop and power

`signoff/run_ir_drop.sh` runs Innovus' early rail analysis on the routed
database: static drop on vccd1/vssd1, with six ideal sources on the met4 ring
where the frame's connection blocks strap its pins, wire resistance from the
PDK's extraction file (typical only), and a technology-only grid library.

The memory blocks' libraries have no power data, so the tools count the five
blocks as 0.3 mW. Their latch arrays clock an inverter and a clock gate per
byte every cycle. Genus on each block's gate netlist (33.33 MHz, typical, no
wire capacitance) gives 7.4, 3.9 and 2.5 mW for the 512-, 256- and 128-word
blocks: 23.7 mW for the five, against 18.1 mW for all the logic. The chip is
therefore about 41.5 mW at 33.33 MHz (23 mA), not the 14 mW estimated before.

| Case | Power | vccd1 drop | vssd1 rise | Largest wire current against the LEF's DC limit |
| --- | --- | --- | --- | --- |
| build of 16 Nov, libraries as they are | 18.1 mW | 1.85 mV | 1.83 mV | not run |
| build of 16 Nov, with the memories' power | 41.5 mW | 4.39 mV | 4.20 mV | 5.8 % |
| this build, with the memories' power | 41.8 mW | 4.54 mV | 4.35 mV | 5.8 % |
| this build, every current doubled | 83.6 mW | 9.07 mV | 8.70 mV | 11.5 % |

The worst point is the lower instruction-memory block, farthest from the
right-edge feeds. No node is near the 90 mV limit (5 % of 1.8 V). Not covered:
the grids inside the macros, the ADC's analog supply, pads and package, dynamic
drop, RMS and peak current limits. The extraction file ignores temperature:
allow a third more for hot wires.

### The comparator trim's capacitor

The comparator's offset trim is two arrays of `sarcta__C0`, a unit capacitor
made of met2 fingers, 8, 4, 2, 1 and 1 units on the five trim bits. No device
rule recognises it, and its schematic is an ideal 1.25 fF capacitor. LVS treats
it as a black box, which checks the array's wiring. Extraction did the same,
and a black box is netlisted from its schematic: so the extracted macro, like
the schematic, had ideal 1.25 fF units, and the metal of the units themselves
was never extracted.

Extracted from the layout (`analog/cadence/pv/run_pex.sh` with
`--filter-source "C (CP)"` and no black box; see `analog/cadence/pv/README.md`):

| Per array | As netlisted before | From the layout |
| --- | --- | --- |
| unit, plate to plate | 1.25 fF | 1.00 fF |
| bits 4 to 0 | 10 / 5 / 2.5 / 1.25 / 1.25 fF | 8.03 / 4.00 / 2.01 / 1.00 / 1.00 fF |
| common plate to the supplies | 2.3 fF | 3.8 fF |

| Comparator (extracted, Spectre, 27 C, 1.8 V) | Ideal units | Layout units |
| --- | --- | --- |
| one unit of trim, ss / tt / ff | 3.4 / 4.0 / 4.7 mV | 2.4 / 2.8 / 3.4 mV |
| full trim on one side, ss / tt / ff | 43 / 49 / 57 mV | 31 / 36 / 42 mV |
| decision delay at 10 mV, trim 0 / both sides at 31 | 1.95 / 2.53 ns | 1.97 / 2.37 ns |

The ratios are right (8.02 : 3.99 : 2.00 : 1 : 1); the absolute value is 20 %
low, and the trim's step and range are about 28 % smaller than every simulation
so far has shown. Whether that range still covers the comparator's offset is
for the analog team to judge. Two more things the extraction showed: bits 0 and
1 are one unit each, so the 32 codes give 17 levels; and only Quantus' typical
corner exists in the PDK, so there is no process spread on these numbers.

### Mixed-signal runs with the clock registers

The mixed-signal flow (the chip's own `sar_adc` RTL around the `sar_afe` macro
in Spectre) was rerun with the clock-register RTL, at the 30 ns clock the
constraints are for and at the board's 100 ns. The shim that stands in for
`sar_adc` there passes the two divider ports through, and the sample time
stamps match the digital runs at every setting.

Error of the code against an ideal 8-bit conversion of the same input, a 5 kHz
sine, typical corner, ideal input source:

| Clock | `adc_clkdiv` | `adc_samplediv` | Sampling | Schematic macro | Extracted macro | Extracted: gain | Extracted: previous sample carried over |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 30 ns | 4 | 0 | 240 ns | -1..+1 LSB | -2..+2 LSB | +3.1 % | 1.4 % |
| 30 ns | 4 | 8 | 480 ns | 0..+1 | -1..+2 | +2.3 % | 0.3 % |
| 30 ns | 4 | 16 | 960 ns | 0..+1 | -1..+2 | +2.2 % | 0.4 % |
| 30 ns | 8 | 0 | 480 ns | 0..+1 | -1..+2 | +2.6 % | 0.5 % |
| 100 ns | 4 | 0 | 800 ns | 0..+1 | -1..+2 | +2.2 % | 0.1 % |
| 100 ns | 2 | 0 | 400 ns | 0..+1 | -1..+2 | +2.5 % | 0.1 % |
| 100 ns | 1 | 0 | 200 ns | -1..+1 | -3..+2 | +4.0 % | 2.8 % |
| 100 ns | 4 | 40 | 8 us | 0..+1 | -1..+2 | +2.2 % | 0.1 % |
| 100 ns | 4 | 8 | 1.6 us | not run | -1..+2 | +2.2 % | 0.2 % |

The last row is the reset setting on the board. With the comparator's trim
capacitors taken from the layout (see "The comparator trim's capacitor") the
same run gives -1..+2 LSB, +2.4 % and 0.1 %: at trim code 0 the capacitors'
value does not show in the codes.

Carry-over up to about 0.5 % is noise: the schematic macro shows as much.

This explains the defect open since October ("+3 % gain on conversions that
follow each other within 10 us, in the extracted macro only"). It is two things:

- **A constant gain error of about +2.2 %** in the extracted macro. No clock or
  sampling setting removes it, and it is there after a 126 us idle as well. The
  extraction has 0.21 pF of parasitic on each capacitor array's top plate, which
  gives an error of this size.
- **1.4 % of the previous sample carried over** when the sampling phase is
  240 ns, which is too short for the sampling switch. From 400 ns up it is gone.
  The October analysis fitted a gain only, so the carry-over showed up as extra
  gain on back-to-back conversions.

Hence the reset value of `adc_samplediv`: 8, which makes the sampling phase
480 ns at a 30 ns clock and 1.6 us at the board's 100 ns, whatever the firmware
does. `adc_clkdiv` stays 4. At 10 MHz a divider of 1 needs `adc_samplediv` of 3
or more. Not run: process corners other than typical, and a source with real
impedance, which lengthens the sampling time needed.

### Timing at the pins

The constraints give every pin 0.1 ns of input or output delay and two clock
cycles, so the flow's reports only say that no pin is critical.
`signoff/run_io_timing.sh` reads the routed database with propagated clocks and
reports what the layout does at the wrapper's pins, the worse of the slow and
the fast corner, relative to the clock edge at the wrapper's clock pin:

| At the wrapper's pins (final layout) | |
| --- | --- |
| outputs (61 that a flop on the system clock drives) | valid 13.0 ns after the edge at the latest; none changes before 2.3 ns |
| inputs to flops on the system clock, the mode strap aside | setup at most 3.7 ns (GPIO 6); hold at most 3.9 ns |
| the mode strap (GPIO 11) | 12.7 ns of setup: it is combinational to several pads' enables, and static in use |
| debug port, against SWDCK (GPIO 20) | SWDIO valid 7.1 ns after the edge and not before 2.2 ns; SWDIO needs 0.4 ns of setup. The constraints give SWDIO no hold check against SWDCK |
| flash pass-through, pin to pin | 2.2 to 5.5 ns at the slow corner, 0.8 to 1.2 ns at the fast one |

The frame's pads come on top. From the PDK's library for the pad (fast, typical,
slow): the input buffer adds 0.7, 1.3 and 2.2 ns; the output driver in the
strong, fast-slew mode adds 3.3, 5.5 and 8.4 ns into 15 pF. The clock goes
through an input buffer too, so for an input the two largely cancel, and an
output is valid about 24 ns after the clock edge at the package pin in the worst
case (2.2 + 13.0 + 8.4).

What it means:

- Every input the processor reads goes through a two-flop synchroniser or is a
  strap, and the host link and the UARTs are asynchronous to anything outside,
  so the hold figure constrains nothing on the board. A device that wanted to
  share the chip's clock would have to respect it.
- The pass-through is 13 to 16 ns each way with the pads at the slow corner
  (13 for the clock, 15 for the data coming back). With a flash that answers
  within 7 ns, a programming clock of 8 MHz leaves a wide margin; above about
  14 MHz the read data is late at the slow corner.

## RTC through a system reset, the ADC macro's two layout items, final layout (19 Nov 2026)

### The RTC keeps the time through a system reset

The RTC's power-on reset was tied to the system reset, because only `HRESETn`
reached `accelerator_subsystem`: every reset, a debugger's or the program's own
included, put the time back to zero. `PORESETn` now reaches it (one port added
on `nanosoc_region_exp` and on `nanosoc_ss_expansion`, connected to
`SYS_PORESETn` in `nanosoc_system`). The reset pin and power-on assert it;
SYSRESETREQ, the watchdog and lockup do not. The RTC, the divider that makes
its tick and the `rtc_prescale` register are reset by it alone, so the time goes
on counting at the same rate through a system reset. `rtc_warm_reset_test`
loads a time, asks for a system reset, and checks afterwards that the prescale
register kept its value and that the time has gone on from where it was.

### The ADC macro's two layout items

Both were in ChipFoundry's way and both are fixed in the cells' layouts, with
the smallest change that does it (`analog/cadence/pv/README.md` has the
coordinates).

| Item | Was | Is |
| --- | --- | --- |
| `MR_capm.SP.2` in `bootstrap_sw`: ChipFoundry's FEOL deck wants 1.2 um between a MIM capacitor's bottom plate and met3 that does not touch it | the met3 pad of a 3 x 2 via stack 0.75 um from a boost capacitor's plate: 1 violation, a hard precheck failure | the stack is 2 x 2 cuts (+0.6 ohm): 0 violations |
| solid met2 in `carray_8b`: ChipFoundry asks for no solid metal wider than 30 um | the `vssa` shield under the capacitor array: a 76.4 um solid square fits | five more 1.0 um slots in the same polygon: 27.3 um. No other layer of the macro is above 6.9 um |

- Pegasus DRC and LVS of the changed cells and of the macro: as before (no real
  violation; match, with the trim capacitor as a black box and extracted).
- Extraction against the previous one: the same 656 MIM capacitors and 98
  transistors; each top plate 0.6 to 0.7 % less capacitance to everything else,
  the bottom plates of bits 7 to 4 0.4 to 1.0 % less, nothing beyond 1 %. Slots
  3.4 um wide, tried first, put 8.4 fF of each top plate onto the substrate and
  moved the upper bits' bottom plates by up to 2 %; at 1.0 um it is 0.5 fF.
- Mixed-signal run at the reset setting on the board's clock: codes within
  -1..+2 LSB, gain +2.1 %, carry-over 0.1 %, as before the fixes.
- The macro's LEF is unchanged (outline, pins, obstructions), so the fixed
  macro goes into the routed layout at stream-out, with no new place and route.
  Its timing libraries change by 0.2 fF on one pin; timing of the routed layout
  with them is unchanged.

### Antenna repair in the pad-ring flow

`ASIC_ours/Cadence/scripts/route_setup.tcl` has the antenna settings of the
OpenFrame flow. In a full run of the pad-ring flow with them, routing left 86
violations after its layer changes and the diodes removed all of them; the run
ended with no DRC violation and timing met.

### Result

Final layout: the RTC change built with the flow as it now is, which ended clean
on its first run, and the corrected ADC macro.

| Step | Result |
| --- | --- |
| Place and route, 30 ns | setup WNS +0.170 ns, hold WNS +0.049 ns |
| Post-route DRC (Innovus), process antennas, free sites | the 6 frame-pin markers only; none; none |
| Stream-out with the corrected macro | PASS, 0 warnings |
| Pegasus LVS | MATCH, 224 cells; port ties PASS (88 groups) |
| RTL of the wrapper: the tests of 18 Nov, `rtc_warm_reset_test`, and the five flash scenarios | 18 runs, all as expected |
| Gate level, unit delay: the same 18 | all as expected; the host-side logs of every run identical to its RTL run |
| Gate level, SDF, memories as gates, 30 ns | 20 runs, all pass: `hello` at slow, typical and fast; `FLASH=boot`, `FLASH=prog`, `of_mem_test`, `sensing_irq_test`, `adc_trigger_test`, `rtc_warm_reset_test` and `of_boot_test` at slow and fast; `NOHOST=1`, `rtc_time_test` and `clock_ctrl_test` at slow. Logs identical to RTL, but for one line of `sensing_irq_test` (the value of an ADC sample it prints, taken at a different instant). No timing violation reported at slow or typical. Each fast-corner run reports the same 16 setup warnings, all at the first flop of the host link's input synchroniser, where the testbench's asynchronous input changes near the clock edge |
| ChipFoundry's ten decks, run natively | all PASS: FEOL 0 violations (the first build with none), BEOL 0; off-grid, top cell, cell names, density (clear area li1 58.9 %, m1 79.1 %, m2 94.1 %, m3 96.0 %, m4 72.7 %, m5 67.2 %), pin labels, zero-area, spike; XOR against the empty frame: 0 differences |
| `cf precheck` in ChipFoundry's container, every check | **passed**: 12 of 12, their LVS and OEB included (the optional Magic DRC was not run) |

The precheck ran in the local rehearsal project directory. Nothing has been
registered with or sent to ChipFoundry.

## The ADC macro on the team's current cells (20 Nov 2026)

The ADC macro was rebuilt on the two cells the team had redesigned since it was
made: the capacitor array of #135 and the resized sampling switch of the
`bootstrap-sw` branch. `analog/cadence/pv/README.md` has what came from where
and the checks on the macro itself.

- **The array** has no solid met2 plane any more, so the slots cut into that
  plane on 19 Nov are gone with it. The largest solid square of metal in the
  macro is 6.9 um (met3), and 4.8 um on met2.
- **The switch** has a larger enable inverter. ChipFoundry's FEOL deck still
  reported `MR_capm.SP.2` on it, in metal that had not changed, so the via-stack
  change of 19 Nov was made on it again.
- **For the chip nothing moves.** The macro's outline, pins and obstructions
  are the same. In its LEF only the `sample` pin's gate area changes, and in
  its timing libraries that pin's capacitance (57 to 79 fF). So the routed
  layout of 19 Nov is kept, and the new macro goes in at stream-out, as the
  corrected one did then.

### Result

| Step | Result |
| --- | --- |
| Timing of the routed layout with the new macro's libraries | setup WNS +0.170 ns, hold WNS +0.049 ns, as before; no transition or capacitance violation. The slew of `sample` at the macro, slow corner, goes from 0.96 to 1.13 ns (the limit is 1.5 ns) |
| Stream-out with the new macro | PASS, 0 warnings |
| Pegasus LVS | MATCH, 224 cells; port ties PASS (88 groups) |
| SDF written with the new libraries | the gate netlist is the same; 12 of 452,491 SDF lines differ from the file simulated on 19 Nov: the date, and the delays of the `sample` net and its driver |
| Gate level, that SDF, memories as gates: `adc_trigger_test` at slow and fast | pass; logs identical to RTL and to the 19 Nov runs. The fast run has the same 16 setup warnings at the host link's input synchroniser, the slow run none |
| ChipFoundry's ten decks, run natively | all PASS: FEOL 0 violations, BEOL 0; off-grid, top cell, cell names, density (clear area li1 58.9 %, m1 79.1 %, m2 94.3 %, m3 96.0 %, m4 72.7 %, m5 67.2 %), pin labels, zero-area, spike; XOR against the empty frame: 0 differences |
| `cf precheck` in ChipFoundry's container, every check | **passed**: 12 of 12, their LVS and OEB included (the optional Magic DRC was not run) |

The other simulations of 19 Nov were not run again: the RTL, the gate netlist
and every delay outside the `sample` net are the same.

### The ADC with the new cells

The mixed-signal runs of "Mixed-signal runs with the clock registers" again,
on the rebuilt macro (the chip's `sar_adc` RTL around the macro in Spectre, a
5 kHz sine, typical corner, ideal input source):

| Clock | `adc_clkdiv` | `adc_samplediv` | Sampling | Schematic macro | Extracted macro | Extracted: gain | Extracted: previous sample carried over | Extracted, macro of 19 Nov |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 100 ns | 4 | 8 | 1.6 us | 0..+1 LSB | -1..+2 LSB | +1.5 % | 0.3 % | -1..+2 LSB, +2.1 %, 0.1 % |
| 30 ns | 4 | 0 | 240 ns | -1..+1 LSB | -2..+2 LSB | +2.3 % | 1.4 % | -2..+2 LSB, +3.1 %, 1.4 % |
| 30 ns | 4 | 8 | 480 ns | 0..+1 LSB | -1..+1 LSB | +1.4 % | 0.5 % | -1..+2 LSB, +2.3 %, 0.3 % |
| 100 ns | 4 | 0 | 800 ns | 0..+1 LSB | -1..+2 LSB | +1.5 % | 0.2 % | -1..+2 LSB, +2.2 %, 0.1 % |
| 100 ns | 1 | 0 | 200 ns | -1..+1 LSB | -3..+1 LSB | +3.4 % | 2.5 % | -3..+2 LSB, +4.0 %, 2.8 % |

The first row is the reset setting on the board. The 240 ns row is 120
conversions, the others 52. All ten runs end with Spectre reporting no error
and the firmware test passing.

- **At the reset setting the codes are within -1..+2 LSB, as before, and the
  gain error falls from +2.1 to +1.5 %.** The new array's top plates have less
  capacitance to `vss` and `vref` (198 to 139 fF in the extraction), and the
  gain error falls by the same factor. That fits the explanation of 19 Nov; the
  item stays open at +1.5 %.
- **The gain error is 0.6 to 0.9 of a percentage point lower at every
  setting**, for the same reason.
- **The schematic macro gives the same codes as before**, conversion for
  conversion, at the four settings that had a schematic run on 19 Nov. The
  inverter's new sizes change no code.
- **The carry-over at a short sampling phase is not changed by the resized
  switch.** With the extracted macro it is 1.4 % at 240 ns, as before, and
  2.5 % at 200 ns (2.8 %); a difference under about 0.5 % is within the fit's
  scatter. With the schematic macro 200 ns gives 1.4 % before and after. So a
  short sampling phase still carries over part of the previous sample, and the
  reset value of `adc_samplediv` (8, a sampling phase of 480 ns at 30 ns and
  1.6 us on the board) is still what keeps it out.
- **The extracted runs take two to three times as long** as on 19 Nov (41 to
  99 minutes each): the extraction of the new array is larger (18.7k
  resistors, from 10.2k).

## After the merge into main (28 Nov 2026)

Every result above is for the layout built on 19 Nov with the ADC macro of
20 Nov. This work was then rebased onto main, which had taken other work in the
meantime:

| Now on main | In the signed-off layout |
| --- | --- |
| Ten fixes to the sensing peripheral's RTL, a conversion timeout (`status[6]`), byte strobes on the clock registers and `irq_enable` (#145, #146) | no |
| A new power plan for the ADC macro's supplies: 20 um rings for `vdda1`, `vssa1` and the reference, none for `vccd1`, and the macro's `vdd` pin no longer wired (#142) | no |
| A scan-chain script, `Cadence/scripts/dft_setup.tcl`, off by default (`DFT 0`) | no |
| The new capacitor array (#135) | yes, since 20 Nov |

- **Checked on the rebased RTL:** the 16 firmware tests pass in RTL simulation
  (Xcelium), `rtc_warm_reset_test` and `sensing_reset_test` among them. The
  peripheral's block and wrapper benches (`make verify` in
  `agriculture_soc_main`) pass apart from its two open ADC items; its two UVM
  benches were not run.
- **Not run again:** synthesis, place and route, the sign-off, gate-level
  simulation, the mixed-signal runs, ChipFoundry's checks. main's flow does not
  reproduce the layout above: its power plan expects an ADC macro without a
  `vdd` pin.
- **Where the two lines of work met:** `rtc_prescale` keeps its reset by the
  power-on reset alone and takes the byte strobes; `sensing_reset_test` now
  expects it to keep its value through a system reset.
- `rtc_control_2.v` read `pt_setup_done` above its declaration, which Xcelium
  and Genus reject (Verilator and Icarus do not). The declaration moved up in
  #145.

`TODO.md` has the rebuild and what has to be settled before it.

## Known gaps

`TODO.md` beside this file is the list of open items; the ones below are the
background for some of them.

- **No process-antenna check existed** before the rebuild of 16 Nov (see
  "Dev-board pad map and clock registers"); the builds described under "Memories"
  each have a handful of violations.
- **The ADC macro's supply is the frame's `vdda1`**, which the development board
  brings to a header beside its 3.3 V pins. The macro's devices are 1.8 V: wire
  `vdda1` to 1.8 V (see "Pad map").
- **Nothing here has run on hardware.** In particular the flash loader and the
  programming pass-through ("Booting from the board's flash") are verified in
  simulation against a model of the flash written for the purpose
  (`sim/spiflash_model.v`), not against the part on the board.

- **The memories have changed** to DFFRAM (see "Memories"); what follows is why.
  ChipFoundry has told us that they do not waive
  DRC results inside SRAM macros and do not accept OpenRAM macros from their
  December 2026 run on: the relaxed bit-cell rules are allowed only under the core
  area ID layer, and only for pre-approved macros. The routes they give are their
  own SRAM (shipped as a pin-only outline, which passes their deck) or DFFRAM
  (standard cells only). DFFRAM's 8 kbyte block is 1.59 x 1.57 mm, so four do not
  fit this 3.09 mm-wide core; its 4 kbyte block is 1.58 x 0.79 mm (1.25 mm2), 2 kbytes
  0.79 x 0.79 mm, 1 kbyte 0.79 x 0.40 mm. The four OpenRAM macros now take 3.2 mm2
  (1.11 x 0.72 mm each). The test programs fit 4 kbytes when built for size (see
  "Firmware size"), so a 4 kbyte instruction memory and a 1 kbyte data memory in
  DFFRAM would take about half the area the memories take now. The PDK's own
  `sky130_sram_macros` fail the deck in the same rule families as ours.
- **The ADC's control logic is never reset** (see "Gate-level simulation"). This is
  in the RTL, not in this wrapper.
- The SRAM macro in use was generated here with OpenRAM; its own datasheet reports
  2 DRC errors and 1 LVS error and analytical timing, and it is a black box in
  every LVS above.
- At transistor level the ADC macro does not match in this wrapper
  (`run_lvs.sh ... --full sar_afe`): inside the macro nothing ties the substrate to
  its `vss` pin, so with `vss` on `vssa1` its NMOS bodies are on `vssd1` through
  the standard-cell taps. On the chip, where `vss` is the common ground, the same
  comparison matches. Either `vss` goes to `vssd1` here too, or the macro needs
  its own substrate ties.
- Not done: a full `cf precheck` of the
  last stream-out (the one with ChipFoundry's standard-cell version; only its
  `lvs` and `oeb` were rerun). With that cell version the Cadence deck adds two
  library-internal results (`CDR.npc.2`, one more `licon.8a`).
- No metal fill. The Cadence deck's minimum-density rules fail without it;
  ChipFoundry's precheck only checks the maximum.
- The low-power checks still report 96 errors by design: 86 unused analog inout pads
  have no driver, and the 10 frame supplies this design does not use have no
  power/ground function in the UPF. Five of those (the unused grounds) therefore
  carry `USE POWER` on their pins.
- The UPF's `ADC_VREF` supply net is empty in the layout (the reference is net
  `analog_io[15]`), so the UPF and the layout name the reference differently.
- Analog quality is not addressed. The reference reaches the macro on a 2.4 um met2
  strap about 630 um long, on the `analog_io` path, which has a 150 ohm series ESD
  resistor at the pad; `analog_noesd_io` is the direct path. `vinp`/`vinn` are
  ordinary minimum-width routes of 1.1 and 1.4 mm, unshielded (they are two-pin
  nets, pad to macro, with no buffer or diode, as ChipFoundry requires). Only one of
  the frame's four `vdda1` pins and one of its four `vssa1` pins is used.
- ChipFoundry asks for no solid metal wider than 30 um anywhere in the die (their
  article on large metal polygons; above 100 um they call it high risk). No design
  rule checks this. The rings, stripes and straps drawn by this flow are at most
  24 um wide, but the ADC macro's capacitor array (`sar_afe__carray_8b`, two
  instances) has a met2 plate of 156 x 157 um in which a 76 um square of solid metal
  fits. The SRAM macros have not been measured.
- The chip made the ADC reference with `sky130_fd_io__top_gpiovrefv2` and
  `vrefcapv2` pad cells. The frame has no equivalent: the reference has to be
  supplied on the pad or generated in the user area.
- The frame's `vdda1` is run at 1.8 V here, like the chip's VDDA.
- The logic occupies about 1 mm2 in the middle of a 14.5 mm2 core, far from the
  pads; the floorplan has not been tuned for wire length.
