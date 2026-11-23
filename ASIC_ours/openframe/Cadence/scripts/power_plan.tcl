### Power plan for nanosoc in the OpenFrame wrapper (experiment).
### vccd1/vssd1 come from the frame through two met3 pins on the right edge and the
### vccd1_connection/vssd1_connection blocks, which join them to the core ring. The
### ring and the stripe grid repeat the template's geometry (openlane config.json:
### 20 um rings 4 um inside the core edge, 6.4 um stripes at a 40 um pitch, met4
### vertical, met5 horizontal). The DFFRAM blocks have their vccd1/vssd1 pins as
### vertical met4 straps across the whole block and nothing on met5: the grid's
### met5 stripes run over them and drop a via on every strap they cross, and the
### grid's own met4 stripes stop at each block. The ADC macro gets a block
### ring; its vdda1/vssa1 come from the frame's pins beside it, its vdd from the
### vccd1 grid, and its reference from the top-edge pad analog_io[15], on that
### port's own net.

### Global connections
connect_global_net vccd -type pg_pin -pin_base_name VPWR -inst_base_name *
connect_global_net vccd -type pg_pin -pin_base_name VPB  -inst_base_name *
connect_global_net vssd -type pg_pin -pin_base_name VGND -inst_base_name *
connect_global_net vssd -type pg_pin -pin_base_name VNB  -inst_base_name *
# the macro, by its full name (-inst_base_name only matches leaf names). vdd, vss and
# vdda repeat what the powered netlist and the UPF already say; vref moves from the
# UPF's ADC_VREF net onto the pad's net, which needs both override options.
connect_global_net vccd -type pg_pin -pin_base_name vdd  -single_inst $sar_afe_name
connect_global_net vssa1 -type pg_pin -pin_base_name vss  -single_inst $sar_afe_name
connect_global_net vdda1 -type pg_pin -pin_base_name vdda -single_inst $sar_afe_name
connect_global_net $vref_net -type pg_pin -pin_base_name vref -single_inst $sar_afe_name -override -netlist_override
foreach {_pin _net} [list vdd vccd1 vss vssa1 vdda vdda1 vref $vref_net] {
    set _is [get_db [get_db $sar_afe_inst .pg_pins -if ".base_name == $_pin"] .net.name]
    if {$_is ne $_net} { error "power_plan.tcl: the ADC macro's $_pin is on '$_is', not on $_net" }
}
if {[get_db [get_db ports $vref_net] .net.name] ne $vref_net} { error "power_plan.tcl: port $vref_net is not on its own net" }
puts "power_plan.tcl: ADC macro supplies: vdd vccd1, vss vssa1, vdda vdda1, vref $vref_net (with its port)"

### Core rings, exactly where the template has them (the connection blocks' vias
### land on the right-hand vertical segments at x 3122.62-3142.62 and 3145.02-3165.02)
foreach {_net _l _r _b _t _w} {
    vccd1 34.02 3132.62 34.80 4730.64 20.0
    vssd1 11.62 3155.02 12.40 4753.04 20.0} {
    set _h [expr {$_w / 2.0}]
    create_shape -net $_net -layer met4 -rect [list [expr {$_l-$_h}] [expr {$_b-$_h}] [expr {$_l+$_h}] [expr {$_t+$_h}]] -shape ring -status fixed
    create_shape -net $_net -layer met4 -rect [list [expr {$_r-$_h}] [expr {$_b-$_h}] [expr {$_r+$_h}] [expr {$_t+$_h}]] -shape ring -status fixed
    create_shape -net $_net -layer met5 -rect [list [expr {$_l-$_h}] [expr {$_b-$_h}] [expr {$_r+$_h}] [expr {$_b+$_h}]] -shape ring -status fixed
    create_shape -net $_net -layer met5 -rect [list [expr {$_l-$_h}] [expr {$_t-$_h}] [expr {$_r+$_h}] [expr {$_t+$_h}]] -shape ring -status fixed
}

### Stripes: the template's grid. met4 is blocked over every macro (the DFFRAM
### blocks' halos; the ADC macro plus its block ring), met5 only over the ADC.
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_ignore_non_default_domains true
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_remove_floating_stripe_over_block true
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer 6
set_db add_stripes_stacked_via_bottom_layer 2
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring  block_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }

lassign [lindex [get_db $sar_afe_inst .bbox] 0] _ax1 _ay1 _ax2 _ay2
set _adc_blockage [list [expr {$_ax1-20}] [expr {$_ay1-20}] [expr {$_ax2+20}] [expr {$_ay2+20}]]
set power_stripes_blockage {}
foreach _m [of_mem_insts] {
    lappend power_stripes_blockage {*}[get_db $_m .place_halo_bbox]
}
lappend power_stripes_blockage $_adc_blockage
puts "power_plan.tcl: met4 stripe blockage: $power_stripes_blockage"
puts "power_plan.tcl: met5 stripe blockage: $_adc_blockage"
set power_stripes_blockage_str [join [list $power_stripes_blockage]]
set power_stripes_blockage_m5_str [join [list [list $_adc_blockage]]]

# DO the ADC first.
### The ADC macro: block ring (innermost first), then its pins to the ring
deselect_obj -all
select_obj [get_db insts $sar_afe_name]
# (net lists as plain strings: these commands do not strip the braces Tcl puts round a
# name with brackets in it)
# TODO the VCCD1 ring can be removed in the future, once the SAR removes the unneeded vdd net.
add_rings -nets "$vref_net vssa1 vdda1" -type block_rings -around selected -layer {top met5 bottom met5 left met4 right met4} -width 20 -spacing 4.8 -offset 2
deselect_obj -all
# TODO I think it's just the -block_pin all taking effect here.ddd
# I want to match the wire width with -block_pin_width_range {min max} --- but it seems like I don't need that anymore!
route_special -connect {block_pin} -inst $sar_afe_name -nets "vssa1 vdda1 $vref_net" -block_pin all -block_pin_target nearest_target -layer_change_range {met1 met5} -crossover_via_layer_range {met1 met5} -target_via_layer_range {met1 met5} -allow_jogging 1 -allow_layer_change 1 

# a block-ring segment of a net: side left/right -> the vertical met4 segment with
# the smallest/largest x; side top -> the horizontal met5 segment with the largest y
proc blockring_seg {net side} {
    set best ""
    foreach w [get_db [get_db nets $net] .special_wires -if {.shape == blockring}] {
        lassign [lindex [get_db $w .rect] 0] x1 y1 x2 y2
        switch $side {
            left  { if {[get_db $w .layer.name] eq "met4" && ($best eq "" || $x1 < [lindex $best 0])} { set best [list $x1 $y1 $x2 $y2] } }
            right { if {[get_db $w .layer.name] eq "met4" && ($best eq "" || $x1 > [lindex $best 0])} { set best [list $x1 $y1 $x2 $y2] } }
            top   { if {[get_db $w .layer.name] eq "met5" && ($best eq "" || $y1 > [lindex $best 1])} { set best [list $x1 $y1 $x2 $y2] } }
        }
    }
    if {$best eq ""} { error "blockring_seg: no $side block-ring segment of $net" }
    return $best
}
set _die_x2 [lindex [lindex [get_db current_design .bbox] 0] 2]
set _die_y2 [lindex [lindex [get_db current_design .bbox] 0] 3]


### The frame's analog pins to the ADC ring. Pin geometry from the template DEF.
# vdda1: right-edge pin, met3, y 3882.03-3905.93. On met3 only across the core ring
# to just inside the core (x 3112.5), then up to met5 and on met5 to the ring's right
# side. A met3 strap all the way would block the rail via stacks (met1-met4) of the
# ~9 rows it lies on and leave their rails floating; met5 at y 3882.03-3898.43 lies
# between the grid's horizontal stripes (vssd1 to 3876.43, vccd1 from 3900.43).

## TODO - we should probably connect the ring to both instances of VDDA/VSSA.

lassign [blockring_seg vdda1 right] _rx1 _ry1 _rx2 _ry2
create_shape -net vdda1 -layer met3 -rect [list 3112.5 3882.03 $_die_x2 3905.93] -shape stripe -status fixed
#create_shape -net vdda1 -layer met5 -rect [list $_rx1 3882.03 3121.5 3898.43] -shape stripe -status fixed
create_shape -net vdda1 -layer met5 -rect [list $_rx1 3882.03 3121.5 3905.93] -shape stripe -status fixed
# (both shapes run horizontally here, which ViaGen only accepts with -orthogonal_only 0)
update_power_vias -add_vias 1 -orthogonal_only 0 -nets vdda1 -area [list [list 3112.5 3882.03 3121.5 3898.43]] -bottom_layer met3 -top_layer met5
if {[llength [get_db [get_db nets vdda1] .special_vias -if {.via_def.name == M3M4*}]] == 0} { error "power_plan.tcl: no met3-met4 via on the vdda1 entry" }
update_power_vias -add_vias 1 -nets vdda1 -area [list [list $_rx1 3882.03 $_rx2 3898.43]] -bottom_layer met4 -top_layer met5
puts "power_plan.tcl: vdda1: met3 from the pin to x 3112.5, met5 to the ring's right side x $_rx1-$_rx2"
# vssa1: top-edge pin, met3, x 2717.71-2741.61, straight down to the ring's top side
lassign [blockring_seg vssa1 top] _rx1 _ry1 _rx2 _ry2
if {$_rx1 > 2731.0 || $_rx2 < 2741.61} { error "power_plan.tcl: the vssa1 pin (x 2717.71-2741.61) is not above the ADC's vssa1 ring (x $_rx1-$_rx2)" }
create_shape -net vssa1 -layer met3 -rect [list 2717.71 $_ry1 2741.61 $_die_y2] -shape stripe -status fixed
update_power_vias -add_vias 1 -nets vssa1 -area [list [list 2717.71 $_ry1 2741.61 $_ry2]] -bottom_layer met3 -top_layer met5
puts "power_plan.tcl: vssa1: met3 from the pin down to the ring's top side y $_ry1-$_ry2"
# The reference (net analog_io[15], see config.tcl): the pad's pin is met2,
# x 2981.80-2982.44, at the top edge, exactly above the macro's right-hand vref pin.
# A 2.4 um met2 strap (the widest that keeps clear of the neighbouring pad-control
# pins) runs from it down to the ring's top side.
lassign [blockring_seg $vref_net top] _rx1 _ry1 _rx2 _ry2
create_shape -net $vref_net -layer met2 -rect [list 2980.92 4705.02 2983.32 $_die_y2] -shape stripe -status fixed
create_shape -net $vref_net -layer met3 -rect [list 2970.92 $_ry1 2993.32 4765.02] -shape stripe -status fixed
update_power_vias -add_vias 1 -orthogonal_only 0 -nets $vref_net -area [list [list 2980.92 4705.02 2983.32 4765.02]] -bottom_layer met2 -top_layer met3

update_power_vias -add_vias 1 -nets $vref_net -area [list [list 2980.92 $_ry1 2983.32 $_ry2]] -bottom_layer met3 -top_layer met5
if {[llength [get_db [get_db nets $vref_net] .special_vias -if {.via_def.name == M2M3*}]] == 0} { error "power_plan.tcl: no met2-met3 via from the reference strap to the ring" }
puts "power_plan.tcl: reference $vref_net: met2 from the pin down to the ring's top side y $_ry1-$_ry2"


# Like the template: first vccd1 stripe centred 58.45 (x) / 63.63 (y), vssd1 9.6 on,
# and every stripe runs from outer ring edge to outer ring edge (x 1.62-3165.02,
# y 2.4-4763.04), not to the die edge. The offsets are from that area's edge to
# the first stripe's near edge.
set _pdn_area {1.62 2.4 3165.02 4763.04}
add_stripes -nets {vccd1 vssd1} -layer met4 -direction vertical   -width 6.4 -spacing 3.2 -set_to_set_distance 40 -start_from left   -start_offset 53.63 -stop_offset 0 -area $_pdn_area -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit 6 -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none -area_blockage $power_stripes_blockage_str
add_stripes -nets {vccd1 vssd1} -layer met5 -direction horizontal -width 6.4 -spacing 3.2 -set_to_set_distance 40 -start_from bottom -start_offset 58.03 -stop_offset 0 -area $_pdn_area -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit 6 -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none -area_blockage $power_stripes_blockage_m5_str

### DFFRAM supplies: a via4 wherever a met5 stripe crosses one of a block's met4
### straps of the same net (add_stripes leaves block pins alone here)
foreach _m [of_mem_insts] {
    update_power_vias -add_vias 1 -nets {vccd1 vssd1} -area [get_db $_m .bbox] -bottom_layer met4 -top_layer met5 \
        -skip_via_on_pin {pad cover standardcell} -skip_via_on_wire_shape {noshape}
}

### vccd1 (the macro's vdd) from the grid: the grid's vccd1 met5 stripes stop at the
### stripe blockage, 20 um from the macro. Those level with the macro are extended
### over the outer rings' met4 sides (vdda1, vssa1: other layer, no via) onto the
### vccd1 ring's left and right sides. No met5 ring segment is in their way there.
lassign [blockring_seg vccd1 left]  _lx1 _ly1 _lx2 _ly2
lassign [blockring_seg vccd1 right] _rx1 _ry1 _rx2 _ry2
set _n 0
foreach _w [get_db [get_db nets vccd1] .special_wires -if {.layer.name == met5 && .shape == stripe}] {
    lassign [lindex [get_db $_w .rect] 0] _wx1 _wy1 _wx2 _wy2
    if {$_wy1 < $_ay1 || $_wy2 > $_ay2} continue
    if {abs($_wx2 - ($_ax1 - 20)) < 1.0} {
        create_shape -net vccd1 -layer met5 -rect [list [expr {$_wx2 - 0.5}] $_wy1 $_lx2 $_wy2] -shape stripe -status fixed; incr _n
    } elseif {abs($_wx1 - ($_ax2 + 20)) < 1.0} {
        create_shape -net vccd1 -layer met5 -rect [list $_rx1 $_wy1 [expr {$_wx1 + 0.5}] $_wy2] -shape stripe -status fixed; incr _n
    }
}
if {$_n < 4} { error "power_plan.tcl: only $_n vccd1 stripes reach the ADC's vccd1 ring" }
update_power_vias -add_vias 1 -nets vccd1 -area [list [list $_lx1 $_ay1 $_lx2 $_ay2] [list $_rx1 $_ay1 $_rx2 $_ay2]] -bottom_layer met4 -top_layer met5
puts "power_plan.tcl: $_n vccd1 met5 stripes extended onto the ADC's vccd1 ring (x $_lx1-$_lx2 and $_rx1-$_rx2)"

### Stripe/ring vias and the standard-cell rails
update_power_vias -add_vias 1 -nets {vccd1 vssd1} -bottom_layer met4 -top_layer met5
### Standard-cell rails: route_special draws the met1 followpins only, and
### update_power_vias then drops the via stacks from the rails to the met4 stripes.
### One route_special call doing both, as the chip-level plan has it, needs well over
### an hour here: the template's 40 um stripe pitch gives ~100k rail/stripe crossings
### (it took 16 min for 26k on the chip). ViaGen does the same in seconds.
route_special -connect {core_pin} -core_pin_target none -nets {vccd1 vssd1} -layer_change_range {met1 met1} -crossover_via_layer_range {met1 met1} -target_via_layer_range {met1 met1} -allow_jogging 0 -allow_layer_change 0
set _rails [llength [get_db [get_db nets {vccd1 vssd1}] .special_wires -if {.shape == followpin}]]
if {$_rails == 0} { error "power_plan.tcl: route_special drew no standard-cell rails" }
update_power_vias -add_vias 1 -nets {vccd1 vssd1} -bottom_layer met1 -top_layer met4
set _v1 [llength [get_db [get_db nets {vccd1 vssd1}] .special_vias -if {.via_def.name == M1M2*}]]
puts "power_plan.tcl: $_rails rail segments, $_v1 rail via stacks to the met4 grid"
if {$_v1 < $_rails} { error "power_plan.tcl: only $_v1 via stacks for $_rails rail segments" }

### Checks, as in the chip-level plan
set _li1 [get_db [get_db nets [list vccd1 vssd1 vdda1 vssa1 $vref_net]] .special_wires -if {.layer.name == li1}]
if {[llength $_li1]} {
  error "power_plan.tcl: [llength $_li1] power wires on li1, e.g. [get_db [lindex $_li1 0] .net.name] [get_db [lindex $_li1 0] .rect]"
}
puts "power_plan.tcl: no power wires on li1"
# every DFFRAM strap must be fed: at least one via4 per strap and net would be
# strap count x stripe count; require a via on each net for each block and report
foreach _m [of_mem_insts] {
    lassign [lindex [get_db $_m .bbox] 0] _x1 _y1 _x2 _y2
    foreach _n {vccd1 vssd1} {
        set _k 0
        foreach _v [get_db [get_db nets $_n] .special_vias] {
            lassign [lindex [get_db $_v .point] 0] _vx _vy
            if {$_vx > $_x1 && $_vx < $_x2 && $_vy > $_y1 && $_vy < $_y2 && [string match M4M5* [get_db $_v .via_def.name]]} { incr _k }
        }
        set _straps [llength [get_db [get_db $_m .base_cell.pg_base_pins -if ".base_name == [expr {$_n eq {vccd1} ? {VPWR} : {VGND}}]"] .physical_pins.layer_shapes.shapes.rect]]
        if {$_k < $_straps} { error "power_plan.tcl: only $_k $_n met4-met5 vias on [get_db $_m .name], which has $_straps straps" }
        puts "power_plan.tcl: DFFRAM [get_db $_m .name]: $_k $_n via4 on $_straps straps"
    }
}

### The supply nets are finished here. Each also has a port (the frame's pin), and
### NanoRoute otherwise "connects" that port with a minimum-width signal wire to the
### nearest rail: 44 um of 0.14 um met1 from the vccd1 and vssd1 pins, across the
### connection block. skip_routing is stored in the database.
foreach _n [concat $power_nets $ground_nets] {
    set_db [get_db nets $_n] .skip_routing true
}
puts "power_plan.tcl: skip_routing on [concat $power_nets $ground_nets]"
