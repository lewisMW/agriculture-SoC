# =====================================================================
# write_sim_netlist.tcl -- netlist and SDF of the routed wrapper for
# gate-level simulation.
#
#   innovus -stylus -no_gui -batch \
#     -execute "set DB <routed db dir>; set OUT <output dir>" \
#     -files write_sim_netlist.tcl < /dev/null
#
# Writes into OUT:
#   <TOP>.sim.v     flat netlist with power pins on every cell and macro, no
#                   fill/tap/decap cells, no module hierarchy (so that no module
#                   name can clash with a testbench model). Power pins on every
#                   cell, because without -include_pg Innovus still writes them
#                   for the cells that came from synthesis and not for the ones
#                   it added itself; simulate with the USE_POWER_PINS models.
#   <TOP>.sim.sdf   delays of the same netlist as min:typ:max triplets = fast
#                   corner : typical : slow corner (for a timing-annotated run)
#   SIM_NETLIST_OK  written last
# =====================================================================
foreach v {DB OUT} { if {![info exists $v]} { puts "SIM_NETLIST_ERROR: set $v with -execute"; exit 1 } }
file mkdir $OUT
read_db $DB
set TOP [get_db current_design .name]
write_netlist $OUT/$TOP.sim.v -flat -include_pg -exclude_leaf_cells
# One triplet per corner: min = the fast corner (the hold view), typ = the typical
# view, max = the slow corner (the setup view). The typical view is the one that
# is active for both setup and hold. A simulator picks one of the three
# ($sdf_annotate's MINIMUM / TYPICAL / MAXIMUM; run_gl_sim.sh's SDF_CORNER).
set setup_views [get_db [get_db analysis_views -if {.is_setup}] .name]
set hold_views  [get_db [get_db analysis_views -if {.is_hold}] .name]
puts "SIM_NETLIST views: setup=$setup_views hold=$hold_views"
set typ {}; set slow {}; set fast {}
foreach v $setup_views { if {[lsearch -exact $hold_views $v] >= 0} { set typ $v } }
foreach v $setup_views { if {$v ne $typ && $slow eq ""} { set slow $v } }
foreach v $hold_views  { if {$v ne $typ && $fast eq ""} { set fast $v } }
if {$slow eq ""} { set slow [lindex $setup_views 0] }
if {$fast eq ""} { set fast [lindex $hold_views 0] }
if {$typ  eq ""} { set typ $slow }
puts "SIM_NETLIST sdf triplets: min=$fast typ=$typ max=$slow"
if {[catch {write_sdf -min_view $fast -typical_view $typ -max_view $slow -recompute_delaycal $OUT/$TOP.sim.sdf} e]} {
    puts "SIM_NETLIST_WARNING: write_sdf failed: $e"
}
set fh [open $OUT/SIM_NETLIST_OK w]; puts $fh "[clock format [clock seconds]] $DB"; close $fh
puts "SIM_NETLIST_DONE $OUT"
exit 0
