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
;   1. Put the OA libraries on disk. The cells live on THREE diverged branches
;      (merge base 966efc6). PIN THE COMMITS - branch tips move, and the
;      generated netlists change with them. These are the commits that produced
;      the committed AMS/spice/sky130_cells.scs:
;
;         54e94e6  analog-sky130-dev : cap_array_8b, cdac_8b, inverter, opamp_np_ab
;         0d8dd22  bootstrap-sw      : bootstrap_switch_lib/{bootstrap_sw, inv_lvt}
;         5845df0  Erick_branch      : Comparator, Trim (+ Comparator_tb_AMS)
;
;      for c in 54e94e6 0d8dd22 5845df0; do
;        d=/tmp/$c; rm -rf $d; mkdir -p $d
;        git archive $c analog | tar -x -C $d
;      done
;
;   2. Erick's Comparator binds its two Trim instances to a library named "SoC"
;      (Trim actually lives in sky130_analog_lib). Cadence REFUSES two library
;      names pointing at one directory, so SoC needs its own directory:
;
;         L=/tmp/5845df0/analog/cadence/sky130/SoC/sky130_analog_lib
;         rm -rf /tmp/soclib && mkdir -p /tmp/soclib
;         cp -r $L/data.dm $L/.oalib /tmp/soclib/ && ln -s $L/Trim /tmp/soclib/Trim
;
;   3. Create a cds.lib next to where you run virtuoso. Comment character is
;      '#', NOT '//' - a '//' comment silently breaks the following DEFINE:
;         INCLUDE $SKY130/cds.lib
;         DEFINE sky130_analog_lib     /tmp/5845df0/analog/cadence/sky130/SoC/sky130_analog_lib
;         DEFINE SoC                   /tmp/soclib
;         DEFINE bootstrap_switch_lib  /tmp/0d8dd22/analog/cadence/sky130/SoC/sky130_analog_lib/bootstrap_switch_lib
;      (cap_array_8b/cdac_8b/inverter exist on 54e94e6; point sky130_analog_lib
;       there instead when netlisting those, or merge the trees first.)
;
;   4. virtuoso -nograph < netlist_sky130.il
;
;   5. Netlists appear at ~/simulation/<cell>/spectre/schematic/netlist/netlist
;
; All of step 1-3 disappears once the three branches are merged into ONE flat
; sky130_analog_lib - see AMS/INTEGRATION.md.
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
