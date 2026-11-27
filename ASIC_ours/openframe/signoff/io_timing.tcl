# =====================================================================
# io_timing.tcl -- what the routed wrapper does at its pins: one timing report
# per pin and kind of path, for io_timing_summary.py to tabulate.
#
#   innovus -stylus -no_gui -batch \
#     -execute "set DB <routed db dir>; set OUT <output dir>" -files io_timing.tcl < /dev/null
#
# The constraints give every pin a nominal 0.1 ns of input or output delay and
# two clock cycles, so the flow's own reports only say that the pins are not
# critical. Here the clocks are propagated and the paths at the pins are written
# out, slow corner for the late side and fast corner for the early side, into
# OUT/paths/paths.txt: clock to output pin, input pin to flop, and pin to pin
# (the flash pass-through).
# =====================================================================
foreach v {DB OUT} { if {![info exists $v]} { puts "IO_TIMING_ERROR: set $v with -execute"; exit 1 } }
file mkdir $OUT/paths
read_db $DB
set_interactive_constraint_modes [get_db constraint_modes .name]
set_propagated_clock [all_clocks]

# slow = the setup view that is not also a hold view; fast = the hold view that is not also a setup view
set sv [get_db [get_db analysis_views -if {.is_setup}] .name]
set hv [get_db [get_db analysis_views -if {.is_hold}] .name]
set slow ""; set fast ""
foreach v $sv { if {[lsearch -exact $hv $v] < 0 && $slow eq ""} { set slow $v } }
foreach v $hv { if {[lsearch -exact $sv $v] < 0 && $fast eq ""} { set fast $v } }
if {$slow eq "" || $fast eq ""} { puts "IO_TIMING_ERROR: no slow or fast view (setup: $sv; hold: $hv)"; exit 1 }
puts "IO_TIMING views: slow=$slow fast=$fast"
# both corners for both checks: a pin's hold requirement, for one, is larger at
# the slow corner (the clock network slows down by more than the input path)
set_analysis_view -setup [list $slow $fast] -hold [list $slow $fast]

# One query for each kind of path, and one line per path found:
#   kind view start end path_delay check_delay capture_latency launch_latency launch_clock capture_clock
# (latencies as the tool has them: network delay plus the clock's source latency,
# which io_timing_summary.py takes off again; it reads it from the sample report
# written for each side).
proc dump {file kind view args} {
    set fh [open $file a]
    set paths [report_timing -collection -view $view {*}$args]
    foreach_in_collection p $paths {
        set lc [get_property $p launching_clock]; set cc [get_property $p capturing_clock]
        set lcn ""; set ccn ""
        if {$lc ne ""} { set lcn [get_object_name $lc] }
        if {$cc ne ""} { set ccn [get_object_name $cc] }
        set chk [get_property $p check_delay]; if {$chk eq ""} { set chk 0 }
        puts $fh [join [list $kind $view [get_property $p launching_point_name] [get_property $p capturing_point_name] \
            [get_property $p path_delay] $chk [get_property $p capturing_clock_latency] \
            [get_property $p launching_clock_latency] $lcn $ccn] " "]
    }
    close $fh
    puts "IO_TIMING $kind $view: [sizeof_collection $paths] paths"
}
file delete -force $OUT/paths/paths.txt
set outs [get_ports {gpio_out[*] gpio_oeb[*]}]
set ins  [get_ports {gpio_in[*]}]
foreach v [list $slow $fast] {
    # every output pin's three latest and three earliest paths (a pin on the
    # pass-through also has a pin-to-pin path, which the summary sets aside)
    dump $OUT/paths/paths.txt out_late  $v -to $outs -late  -max_paths 2000 -nworst 3
    dump $OUT/paths/paths.txt out_early $v -to $outs -early -max_paths 2000 -nworst 3
    # from the input pins: the 40 worst paths to each endpoint (a pin's worst path
    # is rarely its endpoint's worst); the summary keeps the worst per pin. One
    # query per pin would be exact, and takes a hundred times as long.
    dump $OUT/paths/paths.txt in_late   $v -from $ins -late  -max_paths 200000 -nworst 40
    dump $OUT/paths/paths.txt in_early  $v -from $ins -early -max_paths 200000 -nworst 40
    # one full report per clock, for the clocks' source latencies in this view
    report_timing -from [get_clocks clk]    -late -view $v -max_paths 1 > $OUT/paths/sample_clk_$v.txt
    report_timing -from [get_clocks swdclk] -late -view $v -max_paths 1 > $OUT/paths/sample_swdclk_$v.txt
}
puts "IO_TIMING_DONE $OUT"
exit 0
