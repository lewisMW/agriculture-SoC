; netlist_sky130.il - regenerate AMS/spice/sky130_cells.scs from OpenAccess.
;
; Produces proper SPECTRE netlists from the sky130 schematics. This is what
; makes the device-level swaps trustworthy: the LVS CDLs that Pegasus writes
; (analog/cadence/pegasus_runs/**/*.cdl) name devices by their SCHEMATIC
; cellview (e.g. `cap_mim_m3__base`), which does not exist in the Cadence
; sky130 port and therefore cannot be simulated. Netlisting through OA binds
; devices via the PDK's simulation views instead (-> `cap_mim_m3_1`).
;
; USAGE (headless - no GUI needed, but a Virtuoso licence is required):
;
;   1. Put the OA libraries on disk. The cells currently live on two DIFFERENT
;      branches, which have diverged (merge base 966efc6):
;         analog-sky130-dev : cap_array_8b, cdac_8b, inverter, opamp_np_ab
;         bootstrap-sw      : bootstrap_switch_lib/{bootstrap_sw, inv_lvt}
;      e.g.  git archive origin/analog-sky130-dev analog | tar -x -C /tmp/asd
;            git archive origin/bootstrap-sw      analog | tar -x -C /tmp/bsw
;
;   2. Create a cds.lib next to where you run virtuoso:
;         INCLUDE $SKY130/cds.lib
;         DEFINE sky130_analog_lib     /tmp/asd/analog/cadence/sky130/SoC/sky130_analog_lib
;         DEFINE bootstrap_switch_lib  /tmp/bsw/analog/cadence/sky130/SoC/sky130_analog_lib/bootstrap_switch_lib
;
;   3. virtuoso -nograph < netlist_sky130.il
;
;   4. Netlists appear at ~/simulation/<cell>/spectre/schematic/netlist/netlist
;
; ASSEMBLING sky130_cells.scs from the output:
;   - cap_array_8b and inverter: take the `subckt ... ends` blocks out of the
;     CDAC_8B netlist, not their own. Netlisting a cell directly emits its
;     contents at top level with NO subckt wrapper; netlisting a PARENT emits
;     the children properly wrapped.
;   - bootstrap_sw: it is the top cell here, so wrap its body by hand in
;     `subckt bootstrap_sw en in out vdd vss ... ends` (see sky130_cells.scs).
;   - add `parameters cu=1f` to cap_array_8b AFTER the full port list - the
;     behavioural view is instantiated as `cap_array_8b #(.cu(cu))`, and views
;     must match on parameters as well as ports.
;   - the result is SPECTRE syntax, so include it under `simulator lang=spectre`
;     (the model .include lines stay under `simulator lang=spice`).
;
; SKILL gotcha: do not use `t` as a loop variable - it is protected (true).

procedure(doNL(lib cell)
  let((p)
    printf("--- netlisting %s/%s ---\n" lib cell)
    simulator('spectre)
    design(lib cell "schematic")
    p = createNetlist(?recreateAll t ?display nil)
    printf("NETLIST_PATH %s %s %L\n" lib cell p)
  )
)

doNL("sky130_analog_lib" "cdac_8b")            ; -> wrapped cap_array_8b + inverter
doNL("sky130_analog_lib" "cap_array_8b")       ; unwrapped, for cross-checking
doNL("bootstrap_switch_lib" "bootstrap_sw")    ; needs a hand-written wrapper

printf("DONE_NL\n")
exit
