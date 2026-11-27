# =====================================================================
# ir_drop.tcl -- static IR drop on the core supply (vccd1/vssd1) of the routed
# OpenFrame wrapper, with Innovus' early rail analysis.
#
#   innovus -stylus -no_gui -batch \
#     -execute "set DB <routed db dir>; set OUT <output dir>" \
#     -files ir_drop.tcl < /dev/null
#   (../../signoff/run_ir_drop.sh does this and prints the summary)
#
# What it does
#   1. power: report_power in one analysis view with a default activity, which
#      also writes the current each instance draws from each supply net;
#   2. power-grid library: a technology-only one (wire and via resistances from
#      the extraction technology file; every cell is a current tap at its LEF
#      supply pins, no cell has an internal grid);
#   3. voltage sources: where the frame feeds the core ring. The frame's
#      vccd1_connection and vssd1_connection blocks (LEF obstructions in this
#      database, metal only in their GDS) strap each of the wrapper's three
#      vccd1 pins and three vssd1 pins to the right-hand side of that net's
#      ring, so one ideal source goes on the ring level with each pin;
#   4. the rail analysis, and a summary: IR_DROP_SUMMARY lines in the log and
#      in <OUT>/ir_drop_summary.txt.
#
# Optional variables, set in -execute like DB and OUT
#   QRC          extraction technology file
#                (default $SKY130/quantus/extraction/typical/qrcTechFile)
#   VIEW         analysis view for the power numbers (default: the view that is
#                active for both setup and hold, which is the typical one)
#   ACTIVITY     toggles per clock cycle of inputs and flip-flop outputs (0.2)
#   SCALE        factor on every current (1.0); 2 is a simple pessimistic case
#   MACRO_POWER  {cell mW cell mW ...}: power for each instance of a macro. The
#                memory blocks' libraries carry no power data, so without this
#                they draw only what their output nets cost
#   TEMP         temperature for the wire resistances, in C (25)
#   PWR GND VDD  the supply pair and its voltage (vccd1 vssd1 1.8)
#   LIMIT_MV     drop that counts as a violation, per net, in mV (5 % of VDD)
#   EM_TOP       elements per net and layer inspected in step 5 (1000)
#   CPUS         threads (8)
#
#   5. currents: the extraction file has no electromigration rules, so the
#      largest wire and via currents are set against the technology LEF's DC
#      limits (DCCURRENTDENSITY AVERAGE) here; see the comment at that step.
#
# Not covered: the grids inside the macros (the memory blocks' own rails and
# straps, the ADC macro), the ADC's analog supply, the frame's pads, bond wires
# and package, dynamic (switching) drop, RMS and peak current limits, signal
# wires. The extraction file is a typical one and TEMP does not change its
# resistances; allow about a third more drop for hot wires.
# =====================================================================
foreach v {DB OUT} { if {![info exists $v]} { puts "IR_DROP_ERROR: set $v with -execute"; exit 1 } }
if {![info exists QRC]} {
    if {![info exists ::env(SKY130)]} { puts "IR_DROP_ERROR: set QRC (or the SKY130 environment variable) to find the extraction technology file"; exit 1 }
    set QRC [file join $::env(SKY130) quantus extraction typical qrcTechFile]
}
if {![file exists $QRC]} { puts "IR_DROP_ERROR: no extraction technology file $QRC"; exit 1 }
foreach {v d} {ACTIVITY 0.2 SCALE 1.0 MACRO_POWER {} TEMP 25 PWR vccd1 GND vssd1 VDD 1.8 CPUS 8} { if {![info exists $v]} { set $v $d } }
if {![info exists LIMIT_MV]} { set LIMIT_MV [expr {50.0 * $VDD}] }
file mkdir $OUT
set OUT [file normalize $OUT]

read_db $DB
set TOP [get_db current_design .name]
set_multi_cpu_usage -local_cpu $CPUS

if {![info exists VIEW]} {
    set VIEW ""
    set _hold [get_db [get_db analysis_views -if {.is_hold}] .name]
    foreach _v [get_db [get_db analysis_views -if {.is_setup}] .name] { if {[lsearch -exact $_hold $_v] >= 0} { set VIEW $_v; break } }
    if {$VIEW eq ""} { set VIEW [lindex [get_db [get_db analysis_views -if {.is_setup}] .name] 0] }
}
puts "IR_DROP: design $TOP, view $VIEW, activity $ACTIVITY, scale $SCALE, wires at $TEMP C, $PWR/$GND at $VDD V"

# ---- 1. power, and the static current of every instance ----------------------
set_db power_method static
set_db power_write_static_currents true
set_db power_write_db true
set_db power_output_dir $OUT/power
set_default_switching_activity -input_activity $ACTIVITY -sequential_activity $ACTIVITY
set _macro_mw 0.0
foreach {_cell _mw} $MACRO_POWER {
    set _insts [get_db insts -if ".base_cell.name == $_cell"]
    if {[llength $_insts] == 0} { puts "IR_DROP_ERROR: MACRO_POWER names $_cell, which has no instance"; exit 1 }
    foreach _i $_insts {
        set_power $_mw -insts [get_db $_i .name]
        set _macro_mw [expr {$_macro_mw + $_mw}]
        puts "IR_DROP: $_mw mW given to [get_db $_i .name] ($_cell)"
    }
}
report_power -view $VIEW -out_file $OUT/power.rpt
set _cur {}
foreach _n [list $PWR $GND] {
    if {![file exists $OUT/static_$_n.ptiavg]} { puts "IR_DROP_ERROR: report_power wrote no current file for $_n"; exit 1 }
    lappend _cur $OUT/static_$_n.ptiavg
}

# ---- 2. technology-only power-grid library -----------------------------------
# extraction-file layer <- LEF layer. The local interconnect (li1, with mcon) is
# a poly-type layer in the extraction file and carries no supply wiring above
# the cells, so it is left out.
set _fh [open $OUT/lef_qrc.map w]
foreach {_k _q _l} {metal metal1 met1  metal metal2 met2  metal metal3 met3  metal metal4 met4  metal metal5 met5
                    via via1 via  via via2 via2  via via3 via3  via via4 via4} { puts $_fh "$_k $_q lefdef $_l" }
close $_fh
set_pg_library_mode -cell_type techonly -extraction_tech_file $QRC -lef_layer_map $OUT/lef_qrc.map \
    -power_pins [list VPWR $VDD VPB $VDD] -ground_pins {VGND VNB} -default_area_capacitance 0.01 -temperature $TEMP
write_pg_library -out_dir $OUT/pgv
if {![file exists $OUT/pgv/techonly.cl]} { puts "IR_DROP_ERROR: no power-grid library (see $OUT/pgv/*.log)"; exit 1 }

# ---- 3. voltage sources -------------------------------------------------------
# one per supply pin of the wrapper, on the vertical ring segment of the same net
# nearest to it, level with the pin
proc ir_sources {net file} {
    set port [get_db ports $net]
    if {$port eq ""} { error "no port $net" }
    set rings {}
    foreach w [get_db [get_db nets $net] .special_wires -if {.shape == ring}] {
        lassign [lindex [get_db $w .rect] 0] x1 y1 x2 y2
        if {($y2 - $y1) > ($x2 - $x1)} { lappend rings [list [get_db $w .layer.name] $x1 $y1 $x2 $y2] }
    }
    if {[llength $rings] == 0} { error "net $net has no vertical ring segment" }
    set fh [open $file w]; set n 0; set out {}
    foreach r [get_db $port .physical_pins.layer_shapes.shapes.rect] {
        lassign $r px1 py1 px2 py2
        set pxc [expr {($px1 + $px2) / 2.0}]; set pyc [expr {($py1 + $py2) / 2.0}]
        set best ""; set bd 1e30
        foreach g $rings {
            lassign $g lay x1 y1 x2 y2
            if {$pyc < $y1 || $pyc > $y2} continue
            set d [expr {abs(($x1 + $x2) / 2.0 - $pxc)}]
            if {$d < $bd} { set bd $d; set best $g }
        }
        if {$best eq ""} { error "no ring segment of $net beside its pin at y $pyc" }
        lassign $best lay x1 y1 x2 y2
        incr n
        puts $fh [format "%s_%d %.3f %.3f %s" $net $n [expr {($x1 + $x2) / 2.0}] $pyc $lay]
        lappend out [format "(%.2f, %.2f) %s" [expr {($x1 + $x2) / 2.0}] $pyc $lay]
    }
    close $fh
    if {$n == 0} { error "port $net has no pin shape" }
    return $out
}
foreach _n [list $PWR $GND] { puts "IR_DROP: sources on $_n: [join [ir_sources $_n $OUT/$_n.pp] {, }]" }

# ---- 4. rail analysis ---------------------------------------------------------
set _lim [expr {$LIMIT_MV / 1000.0}]
set_rail_analysis_config -method era_static -accuracy xd -analysis_view $VIEW \
    -power_grid_libraries [list $OUT/pgv/techonly.cl] -temperature $TEMP -report_voltage_drop true
set_pg_nets -net $PWR -voltage $VDD -threshold [expr {$VDD - $_lim}]
set_pg_nets -net $GND -voltage 0.0  -threshold $_lim
set_rail_analysis_domain -domain_name core -power_nets $PWR -ground_nets $GND
set_power_pads -net $PWR -format xy -file $OUT/$PWR.pp
set_power_pads -net $GND -format xy -file $OUT/$GND.pp
set_power_data -format current -scale $SCALE $_cur
report_rail -type domain -output_dir $OUT/rail core

# ---- summary ------------------------------------------------------------------
# the newest state directory, its instance-voltage file (name, supply-to-ground
# loss, drop on the power net, bounce on the ground net, cell) and per-net reports
set _state ""; set _t 0
foreach _d [glob -nocomplain -type d $OUT/rail/core_*] { if {[file mtime $_d] >= $_t} { set _t [file mtime $_d]; set _state $_d } }
if {$_state eq "" || ![file exists $_state/Reports/${PWR}_${GND}.avg.iv]} { puts "IR_DROP_ERROR: the rail analysis left no result under $OUT/rail"; exit 1 }
set _w(pwr) {-1 ""}; set _w(gnd) {-1 ""}; set _w(sum) {-1 ""}; set _nc 0; set _ni 0
set _fh [open $_state/Reports/${PWR}_${GND}.avg.iv r]
while {[gets $_fh _l] >= 0} {
    if {[string index $_l 0] ne "-"} continue
    lassign $_l _dash _name _sum _p _g _cell
    incr _ni
    if {$_sum eq "NA" || $_p eq "NA" || $_g eq "NA"} { incr _nc; continue }
    if {$_p   > [lindex $_w(pwr) 0]} { set _w(pwr) [list $_p $_name $_cell] }
    if {$_g   > [lindex $_w(gnd) 0]} { set _w(gnd) [list $_g $_name $_cell] }
    if {$_sum > [lindex $_w(sum) 0]} { set _w(sum) [list $_sum $_name $_cell] }
}
close $_fh
proc ir_where {name} {
    set i [get_db insts $name]
    if {$i eq ""} { return "(not found)" }
    lassign [lindex [get_db $i .bbox] 0] x1 y1 x2 y2
    return [format "at (%.1f, %.1f)" [expr {($x1 + $x2) / 2.0}] [expr {($y1 + $y2) / 2.0}]]
}
proc ir_grep {file pat} {
    set r ""
    if {![file exists $file]} { return $r }
    set fh [open $file r]
    while {[gets $fh l] >= 0} { if {[regexp -- $pat $l]} { set r [string trim $l]; break } }
    close $fh
    return $r
}
set _sum {}
lappend _sum "database        $DB"
lappend _sum "view, activity  $VIEW, $ACTIVITY per cycle; currents x $SCALE; wires at $TEMP C; state $_state"
lappend _sum "power (x 1)     [ir_grep $OUT/power.rpt {^Total Power:}] mW, of which $_macro_mw mW set by hand on macros"
foreach _n [list $PWR $GND] {
    lappend _sum "$_n           [ir_grep $_state/Reports/$_n/$_n.main.rpt {^Total Static Current Loaded}]"
    lappend _sum "$_n           source current [ir_grep $_state/Reports/$_n/$_n.main.rpt {Maximum Vsrc Current}]"
    lappend _sum "$_n           [ir_grep $_state/Reports/$_n/$_n.main.rpt {^Number of Violations}] (limit $LIMIT_MV mV)"
}
lappend _sum [format "worst %s drop    %.3f mV at instance %s (%s) %s" $PWR [expr {1000.0 * [lindex $_w(pwr) 0]}] [lindex $_w(pwr) 1] [lindex $_w(pwr) 2] [ir_where [lindex $_w(pwr) 1]]]
lappend _sum [format "worst %s bounce  %.3f mV at instance %s (%s) %s" $GND [expr {1000.0 * [lindex $_w(gnd) 0]}] [lindex $_w(gnd) 1] [lindex $_w(gnd) 2] [ir_where [lindex $_w(gnd) 1]]]
lappend _sum [format "worst supply loss    %.3f mV (drop plus bounce at one instance): %s (%s) %s" [expr {1000.0 * [lindex $_w(sum) 0]}] [lindex $_w(sum) 1] [lindex $_w(sum) 2] [ir_where [lindex $_w(sum) 1]]]
lappend _sum "instances       $_ni reported, $_nc not connected to the analysed nets (see $_state/Reports/$PWR/$PWR.pg_integrity.rpt)"

# ---- 5. currents against the technology LEF's limits -------------------------
# The extraction file has no electromigration rules, so the tool reports no
# current-density ratio. The LEF has a DC limit per layer (DCCURRENTDENSITY
# AVERAGE: mA per um of width for a metal, mA per cut for a via). For each net
# and layer, the EM_TOP largest element currents are set against it: a wire
# element with the width of the supply wire it lies in, a via element with the
# number of cuts of the via at that point. Any element below those is bounded
# by the smallest current inspected in the narrowest supply wire of the layer
# (or in a single cut); "<=" marks a figure that is this bound.
if {![info exists EM_TOP]} { set EM_TOP 1000 }
set _limit [dict create]
foreach _f [get_db init_lef_files] {
    if {![file exists $_f]} continue
    set _fh [open $_f r]; set _lay ""
    while {[gets $_fh _l] >= 0} {
        if {[regexp {^\s*LAYER\s+(\S+)} $_l -> _x]} { set _lay $_x }
        if {$_lay ne "" && [regexp {DCCURRENTDENSITY\s+AVERAGE\s+([0-9.]+)} $_l -> _x]} { dict set _limit $_lay $_x }
    }
    close $_fh
}
set _em {}; set _em_viol 0; set _em_worst {-1 ""}
if {[dict size $_limit] == 0} {
    lappend _em "currents        not compared: the LEF files state no DCCURRENTDENSITY limit"
} elseif {[catch {
    file mkdir $OUT/em
    read_power_rail_results -rail_directory $_state
    foreach _n [list $PWR $GND] {
        # this net's supply wires by layer, and the cuts of its vias by cut layer and point
        array unset _wires; array unset _wmin
        foreach _sw [get_db [get_db nets $_n] .special_wires] {
            set _lay [get_db $_sw .layer.name]
            lassign [lindex [get_db $_sw .rect] 0] x1 y1 x2 y2
            set _wd [expr {min($x2 - $x1, $y2 - $y1)}]
            lappend _wires($_lay) [list $x1 $y1 $x2 $y2 $_wd]
            if {![info exists _wmin($_lay)] || $_wd < $_wmin($_lay)} { set _wmin($_lay) $_wd }
        }
        set _vias [get_db [get_db nets $_n] .special_vias]
        set _cuts [dict create]; array unset _vd
        foreach _p [get_db $_vias .point] _d [get_db $_vias .via_def] {
            if {![info exists _vd($_d)]} { set _vd($_d) [list [get_db $_d .cut_layer.name] [expr {[get_db $_d .cut_rows] * [get_db $_d .cut_columns]}]] }
            lassign $_vd($_d) _cl _nc
            set _k [format "%s %.2f %.2f" $_cl [lindex $_p 0] [lindex $_p 1]]
            if {![dict exists $_cuts $_k] || [dict get $_cuts $_k] > $_nc} { dict set _cuts $_k $_nc }
        }
        foreach _lobj [get_db layers -if {.type == routing || .type == cut}] {
            set _lay [get_db $_lobj .name]
            if {![dict exists $_limit $_lay]} continue
            set _iscut [expr {[get_db $_lobj .type] eq "cut"}]
            if {!$_iscut && ![info exists _wires($_lay)]} continue
            set _rpt $OUT/em/rc.$_n.$_lay.rpt
            file delete $_rpt
            if {[catch {report_power_rail_results -plot rc -nets $_n -layers $_lay -limit $EM_TOP -file_name $_rpt}] || ![file exists $_rpt]} continue
            set _lim [dict get $_limit $_lay]
            set _rows 0; set _last 0.0; set _best -1.0; set _bestd ""; set _imax 0.0; set _guess 0
            set _fh [open $_rpt r]
            while {[gets $_fh _l] >= 0} {
                # an element row: current, layer, x1 y1 x2 y2, net, id (the histogram below the rows also starts with numbers)
                if {[llength $_l] != 8} continue
                lassign $_l _i _ql x1 y1 x2 y2
                set _ok 1
                foreach _x [list $_i $x1 $y1 $x2 $y2] { if {![string is double -strict $_x]} { set _ok 0 } }
                if {!$_ok} continue
                set _ma [expr {abs($_i) * 1000.0}]
                incr _rows; set _last $_ma
                if {$_ma > $_imax} { set _imax $_ma }
                if {$_iscut} {
                    set _k [format "%s %.2f %.2f" $_lay $x1 $y1]
                    if {[dict exists $_cuts $_k]} { set _nc [dict get $_cuts $_k] } else { set _nc 1; incr _guess }
                    set _r [expr {$_ma / $_nc / $_lim}]
                    set _d [format "%.4f mA in %d cut(s) at (%.2f, %.2f)" $_ma $_nc $x1 $y1]
                } else {
                    set _mx [expr {($x1 + $x2) / 2.0}]; set _my [expr {($y1 + $y2) / 2.0}]; set _wd ""
                    foreach _wr $_wires($_lay) {
                        lassign $_wr a1 b1 a2 b2 _ww
                        if {$_mx >= $a1 - 0.01 && $_mx <= $a2 + 0.01 && $_my >= $b1 - 0.01 && $_my <= $b2 + 0.01 && ($_wd eq "" || $_ww < $_wd)} { set _wd $_ww }
                    }
                    if {$_wd eq ""} { set _wd $_wmin($_lay); incr _guess }
                    set _r [expr {$_ma / $_wd / $_lim}]
                    set _d [format "%.4f mA in a %.2f um wire at (%.2f, %.2f)" $_ma $_wd $_mx $_my]
                }
                if {$_r > $_best} { set _best $_r; set _bestd $_d }
            }
            close $_fh
            if {$_rows == 0} continue
            set _mark ""
            if {$_rows >= $EM_TOP} {
                set _b [expr {$_last / ($_iscut ? 1.0 : $_wmin($_lay)) / $_lim}]
                if {$_b > $_best} { set _best $_b; set _mark "<= "; set _bestd [format "bound: every element below the %d inspected carries under %.4f mA" $_rows $_last] }
            }
            if {$_best >= 1.0} { incr _em_viol }
            if {$_best > [lindex $_em_worst 0]} { set _em_worst [list $_best "$_n $_lay"] }
            lappend _em [format "current %-6s %-5s largest %.4f mA; worst %s%.2f %% of the limit (%s %s): %s%s" $_n $_lay $_imax $_mark [expr {100.0 * $_best}] $_lim \
                [expr {$_iscut ? "mA/cut" : "mA/um"}] $_bestd [expr {$_guess ? " ($_guess element(s) matched to no wire or via: narrowest wire or one cut assumed)" : ""}]]
        }
    }
} _e]} {
    lappend _em "currents        comparison failed: $_e"
    set _em_viol -1
}
foreach _l $_em { lappend _sum $_l }
if {$_em_viol >= 0 && [lindex $_em_worst 0] >= 0} {
    lappend _sum [format "Current Limit Violations: %d (worst %.2f %% of the LEF's DC limit, on %s; currents x %s)" $_em_viol [expr {100.0 * [lindex $_em_worst 0]}] [lindex $_em_worst 1] $SCALE]
}
set _fh [open $OUT/ir_drop_summary.txt w]
foreach _l $_sum { puts "IR_DROP_SUMMARY: $_l"; puts $_fh $_l }
close $_fh
puts "IR_DROP_DONE $OUT"
exit 0
