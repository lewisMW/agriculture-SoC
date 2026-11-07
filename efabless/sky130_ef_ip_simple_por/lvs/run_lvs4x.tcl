# Tcl script to run LVS on the simple POR

if {[catch {set PDK_ROOT $::env(PDK_ROOT)}]} {set PDK_ROOT /usr/local/share/pdk}
if {[catch {set PDK $::env(PDK)}]} {set PDK sky130A}

set pdklib ${PDK_ROOT}/${PDK}
set techlibs ${pdklib}/libs.tech
set reflibs ${pdklib}/libs.ref

set setupfile ${techlibs}/netgen/sky130A_setup.tcl
set hvlib ${reflibs}/sky130_fd_sc_hvl/spice/sky130_fd_sc_hvl.spice

set circuit1 [readnet spice ../netlist/layout/sky130_ef_ip__simple_por4x.spice]
set circuit2 [readnet spice $hvlib]

readnet spice ../netlist/schematic/sky130_ef_ip__simple_por4x.spice $circuit2

# debug on

lvs "$circuit1 sky130_ef_ip__simple_por4x" "$circuit2 sky130_ef_ip__simple_por4x" \
        $setupfile sky130_ef_ip__simple_por4x_comp.out
