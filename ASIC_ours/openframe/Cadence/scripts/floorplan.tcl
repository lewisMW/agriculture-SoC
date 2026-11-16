### Floorplan for nanosoc in the ChipFoundry OpenFrame wrapper (experiment).
### The die and the pins are the frame's: openframe_project_wrapper is 3166.63 x
### 4766.63 um, its 887 pins sit on the die edge on met3 where the template DEF
### puts them (../inputs/openframe_pins.def, from chipfoundry/openframe_user_project).
### There is no pad ring here: the GPIO cells live in the frame.

source ../scripts/dont_use.tcl

lassign $OF_DIE  _dx1 _dy1 _dx2 _dy2
lassign $OF_CORE _cx1 _cy1 _cx2 _cy2
# die, IO box (= die, no IO ring), core. -no_snap_to_grid keeps the template's
# row origin (40.02, 40.8): 6710 unithd sites by 1722 rows.
create_floorplan -site unithd -no_snap_to_grid -box_size [list $_dx1 $_dy1 $_dx2 $_dy2  $_dx1 $_dy1 $_dx2 $_dy2  $_cx1 $_cy1 $_cx2 $_cy2]
set core_bbox [get_db current_design .core_bbox]
puts "floorplan.tcl: die [get_db current_design .bbox] core $core_bbox, [llength [get_db rows]] rows"

### The frame's pins. The DEF carries only the PINS section; every pin is on its
### own net (the template binds some to the frame's constants), placed and fixed.
read_def ../inputs/openframe_pins.def
set _unplaced {}
foreach _p [get_db ports] { if {[catch {get_db $_p .place_status} _st] || $_st ne "fixed" && $_st ne "placed"} { lappend _unplaced [get_db $_p .name] } }
puts "floorplan.tcl: [llength [get_db ports]] ports, [llength $_unplaced] not placed/fixed: [lrange $_unplaced 0 9]"
if {[llength $_unplaced]} { error "floorplan.tcl: ports without a placement from the template DEF" }

### Outputs to the frame that are constant. Genus leaves "assign gpio_oeb[1] = 1'b0"
### (P1[1] is always an output), and Innovus puts such a port straight on the ground
### net, where nothing would ever route it. The frame provides a constant per pad
### for this, gpio_loopback_zero/one[i] next to the pad's other pins (CF_gpio_config
### uses them for the static pad configuration), so the port goes on that net.
set _n 0
foreach _p [get_db ports -if {.direction == out}] {
    set _nn [get_db $_p .net.name]
    if {[lsearch -exact $ground_nets $_nn] >= 0} { set _lb gpio_loopback_zero
    } elseif {[lsearch -exact $power_nets $_nn] >= 0} { set _lb gpio_loopback_one
    } else { continue }
    set _pn [get_db $_p .name]
    if {![regexp {^gpio_\w+\[(\d+)\]$} $_pn -> _i]} { error "floorplan.tcl: output port $_pn is tied to $_nn and is not a per-pad gpio_* output" }
    set _lbn [get_db [get_db ports "${_lb}\[$_i\]"] .net]
    if {[llength $_lbn] != 1} { error "floorplan.tcl: no net on ${_lb}\[$_i\] for constant output $_pn" }
    disconnect $_p
    connect $_p -net $_lbn
    puts "floorplan.tcl: constant output $_pn moved from $_nn to [get_db $_p .net.name]"
    incr _n
}
puts "floorplan.tcl: $_n constant outputs moved to the frame's loopback constants"

### The frame's power-connection blocks: physical-only instances at the template's
### positions (def/openframe_project_wrapper.def COMPONENTS). Their GDS joins the
### frame's vccd1/vssd1 pins (met3, right edge) to the core ring that power_plan.tcl
### draws at the template's coordinates.
create_inst -inst vccd1_connection -cell vccd1_connection -location {3122.515 4327.51} -orient r0 -physical -status fixed
create_inst -inst vssd1_connection -cell vssd1_connection -location {3122.515 2088.51} -orient r0 -physical -status fixed

### Memory macros (config.tcl, OF_MEM). All unrotated: the DFFRAM LEFs declare no
### symmetry, so Innovus places them in no other orientation, and their supply
### pins are vertical met4 straps that the grid's horizontal met5 stripes cross and
### feed (power_plan.tcl). Every block has a channel on each side that has pins.
### The ADC front end sits in the top right corner, level with the frame's vdda1
### pin (right edge, y 3894), under its vssa1 pin (top edge, x 2730) and under the
### top-edge pads chosen for its analog signals (gpio 15/16/17 at x 2982/2473/2216).
proc of_mem_insts {} {
    global dffram_macros
    set r {}
    foreach i [get_db insts] { if {[lsearch -exact $dffram_macros [get_db $i .base_cell.name]] >= 0} { lappend r $i } }
    return $r
}
proc of_macro {cell pattern} {
    set m [get_db insts -if ".base_cell.name == $cell && .name == $pattern"]
    if {[llength $m] != 1} { error "floorplan.tcl: expected one $cell matching $pattern, found [llength $m]" }
    return [get_db $m .name]
}
# on the placement grid: site 0.46, row 2.72, from the core origin
proc of_snap {x y} {
    global _cx1 _cy1
    return [list [expr {$_cx1 + round(($x - $_cx1) / 0.46) * 0.46}] [expr {$_cy1 + round(($y - $_cy1) / 2.72) * 2.72}]]
}
proc of_cell_size {cell} {
    lassign [lindex [get_db [get_db base_cells $cell] .bbox] 0] x1 y1 x2 y2
    return [list [expr {$x2 - $x1}] [expr {$y2 - $y1}]]
}
if {$of_mem eq "prebuilt"} {
    # ChipFoundry's pre-hardened blocks: data pins on the right edge, address, clock
    # and control on the bottom edge (the 512 byte block: address and data out on
    # the top edge). Two columns: the instruction memory's two 2 kbyte blocks on
    # the left, the three small ones 400 um to the right of their data pins.
    set col_1 190.0
    set col_2 1789.0
    #                 cell          instance         llx                               lly
    set of_mem_place [list \
        DFFRAM512x32 *imem*ram_lo*   $col_1                            1100.0 \
        DFFRAM512x32 *imem*ram_hi*   $col_1                            2260.0 \
        DFFRAM256x32 *dmem*          $col_2                            1100.0 \
        DFFRAM128x32 *expram_h*      $col_2                            1760.0 \
        DFFRAM128x32 *expram_l*      [expr {$col_2 + 551.115 + 110.0}] 1760.0]
} else {
    # Blocks from the DFFRAM compiler: address, clock and control pins on the right
    # edge, data in on the bottom edge, data out on the top edge. Three rows from
    # the left, with 250 um between rows for the data buses and 300 um to the right
    # of each block for its address pins; the sizes come from the LEFs.
    lassign [of_cell_size RAM1024] _w4 _h4
    lassign [of_cell_size RAM512]  _w2 _h2
    set _x0 190.0
    set _y1 700.0
    set _y2 [expr {$_y1 + $_h4 + 250.0}]
    set _y3 [expr {$_y2 + $_h2 + 250.0}]
    set of_mem_place [list \
        RAM1024 *imem*      $_x0                          $_y1 \
        RAM512  *dmem*      $_x0                          $_y2 \
        RAM512  *expram_l*  [expr {$_x0 + $_w2 + 300.0}]  $_y2 \
        RAM512  *expram_h*  $_x0                          $_y3]
}
set _n_mem [llength [of_mem_insts]]
if {$_n_mem * 4 != [llength $of_mem_place]} { error "floorplan.tcl: [llength $of_mem_place] placement entries for $_n_mem memory macros" }
foreach {cell pat x y} $of_mem_place {
    set n [of_macro $cell $pat]
    set xy [of_snap $x $y]
    place_inst $n $xy r0 -fixed
    lassign [lindex [get_db [get_db insts $n] .bbox] 0] _bx _by _bx2 _by2
    if {abs($_bx - [lindex $xy 0]) > 0.01 || abs($_by - [lindex $xy 1]) > 0.01 || [get_db [get_db insts $n] .place_status] ne "fixed"} {
        error "floorplan.tcl: $n was not placed at $xy (it is at $_bx $_by, [get_db [get_db insts $n] .place_status])"
    }
    if {$_bx < $_cx1 + 100 || $_by < $_cy1 + 100 || $_bx2 > $_cx2 - 100 || $_by2 > $_cy2 - 100} {
        error "floorplan.tcl: $n at $_bx $_by $_bx2 $_by2 is less than 100 um from the core edge"
    }
    create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts $n
    create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer -insts $n
    # Signals stay off met4 over the block. Its LEF leaves met4 free between the
    # supply straps, NanoRoute used that to reach the data pins from above, and one
    # such wire shorted to its neighbour in a way the repair passes could not undo.
    # The pins are met2/met3 on the block's edges and are reached from outside.
    create_route_blockage -layers met4 -rects [get_db [get_db insts $n] .bbox] -except_pg_nets
    # The 512 byte block has 39 met2 pins on its top edge, and its LEF leaves a
    # 12 um strip of met3 free just inside that edge. NanoRoute ran met3 along
    # the strip to reach the pins sideways, and in one build two such wires
    # stayed shorted through every repair pass. Keep signals off met3 over the
    # block, apart from the 4.5 um at the right edge where its met3 pins are:
    # the top pins are then reached from above, on met2.
    if {$cell eq "DFFRAM128x32"} {
        create_route_blockage -layers met3 -rects [list [list $_bx $_by [expr {$_bx2 - 4.5}] $_by2]] -except_pg_nets
    }
    puts "floorplan.tcl: $cell $n at [get_db [get_db insts $n] .bbox]"
}

set sar_afe_inst [get_db insts -if {.base_cell.name == sar_afe}]
if {[llength $sar_afe_inst] != 1} {
    error "floorplan.tcl: expected one sar_afe instance, found [llength $sar_afe_inst]"
}
set sar_afe_name [get_db $sar_afe_inst .name]
# 260 x 429.32 um at (2737.12, 3700): well above the memory blocks; the vdda1 pin (y 3882-3906) is level with the ring's right side, the vssa1
# pin (x 2718-2742) is above the ring's top side, and the analog_io[15] pin
# (x 2982.12) is exactly above the macro's right-hand vref pin (macro x 243-247),
# so the reference comes straight down onto it
set sar_afe_x 2737.12
set sar_afe_y 3700.0
place_inst $sar_afe_name [list $sar_afe_x $sar_afe_y] r0 -fixed
create_place_halo -insts $sar_afe_name -halo_deltas {9.6 9.6 9.6 9.6}
create_route_halo -insts $sar_afe_name -space 4.8 -bottom_layer met1 -top_layer met4
puts "floorplan.tcl: sar_afe $sar_afe_name at [get_db $sar_afe_inst .bbox]"

# the analog nets from the frame's analog_io pads to the macro: never buffered
foreach sar_afe_pin {vinp vinn} {
    set sar_afe_net [get_db [get_db $sar_afe_inst .pins */$sar_afe_pin] .net]
    set_dont_touch $sar_afe_net true
    puts "floorplan.tcl: analog net [get_db $sar_afe_net .name] dont_touch [get_db $sar_afe_net .dont_touch]: [get_db [concat [get_db $sar_afe_net .drivers] [get_db $sar_afe_net .loads]] .name]"
}
