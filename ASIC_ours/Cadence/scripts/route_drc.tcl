#------------------------------------------------------------------------------------
# Post-route DRC check and repair, on the routed and filled design (run_flow.sh stage 5).
#
# 4_pnr_route.tcl repairs DRCs twice, but before its last opt_design passes and the
# fillers, and nothing checked the database that is handed on: the 23 Sep chip went
# to sign-off with ~45 met1/met3 shorts that Pegasus LVS then found as real signal shorts,
# and a tie net lying across a VDD via stack shorted VDD to VSS. This stage runs check_drc
# (regular and special wires) on the final database, rips up and reroutes the nets with
# violations a few times while any remain, and writes ${block_name}_signoff.
#
# It only touches regular (signal) routing: no route_special or add_stripes here, so no
# power via can land on a routed signal after the fact.
#
# run: innovus -stylus -no_gui -files ../scripts/route_drc.tcl   (from this directory)
#------------------------------------------------------------------------------------
source ../scripts/config.tcl

set_multi_cpu_usage -local_cpu 8
read_db ${block_name}_route
source $env(SOCLABS_ASIC_FLOW_DIR)/Cadence/procs.tcl

# check_drc into a report; returns the number of violations in it
proc drc_count {rpt} {
    check_drc -limit 100000 -out_file $rpt
    set fh [open $rpt r]; set txt [read $fh]; close $fh
    return [regexp -all -line {^[A-Za-z][A-Za-z ]*: \( } $txt]
}

set n [drc_count $REPORT_DIR/drc_06_route_in.rpt]
puts "route_drc.tcl: $n DRC violations in ${block_name}_route"

# ECO reroute of the nets with violations, as 4_pnr_route.tcl does, until clean or
# three passes; a pass that removes nothing ends the loop.
set_db route_with_eco true
for {set pass 1} {$n > 0 && $pass <= 3} {incr pass} {
    delete_routes -regular_wire_with_drc
    route_design -global_detail
    set m [drc_count $REPORT_DIR/drc_06_route_pass$pass.rpt]
    puts "route_drc.tcl: pass $pass: $n -> $m DRC violations"
    if {$m >= $n} { set n $m; break }
    set n $m
}

# the final report, and timing after any rerouting
set n [drc_count $REPORT_DIR/drc_06_signoff.rpt]
puts "route_drc.tcl: $n DRC violations in ${block_name}_signoff (reports/drc_06_signoff.rpt)"
check_connectivity -type regular -error 100000 -warning 100000 -out_file $REPORT_DIR/conn_06_signoff_regular.rpt
report_end_step 06_signoff $REPORT_DIR

write_db ${block_name}_signoff

exit
