### Connecting Global Nets
# No cell in this design has a pin named VDD or VSS. The sky130 standard cells use
# VPWR/VGND plus VPB/VNB (n-well / p-substrate bias) and the OpenRAM macro uses
# vccd1/vssd1. Connecting by the names VDD/VSS matched nothing and Innovus said so
# (IMPDB-1221, twice). Names below match the gate netlist: .VPWR(VDD) .VPB(VDD)
# .VGND(VSS) .VNB(VSS) .vccd1(VDD) .vssd1(VSS). VDDIO/VSSIO already matched the pads.


# TODO I don't think this is exactly right. Might need to connect to VDDIO/VSSIO???

connect_global_net VDD -type pg_pin -pin_base_name VPWR  -inst_base_name *
connect_global_net VDD -type pg_pin -pin_base_name VPB   -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name VGND  -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name VNB   -inst_base_name *
connect_global_net VDD -type pg_pin -pin_base_name vccd1 -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name vssd1 -inst_base_name *
# These were spelt -overrride, which Innovus 22.1 rejects (IMPTCM-48), stopping the place
# stage here. -netlist_override, not -override: the synthesised netlist ties every pad's
# VSSIO pin to VSS, and -override only replaces earlier connect_global_net rules.
connect_global_net VDDIO -type pg_pin -pin_base_name VDDIO -inst_base_name * -netlist_override
connect_global_net VSSIO -type pg_pin -pin_base_name VSSIO -inst_base_name * -netlist_override
connect_global_net VDDIO -type pg_pin -pin_base_name VDDIO_PAD -inst_base_name * 
connect_global_net VSSIO -type pg_pin -pin_base_name VSSIO_PAD -inst_base_name * 

# SAR ADC analog front end (the sar_afe hard macro; ASIC_ours/macros/sar_afe/README.md).
# vdd (comparator) and vss go to VDD/VSS. vdda (the bootstrapped sampling switches) and
# vref (the CDAC reference, set by the bit-driver inverters) both go to VDDA: vref
# shares the analog supply until the chip has a dedicated, decoupled reference. This
# matches nanosoc_chip_pads.upf. The instance name is the flattened one from synthesis.
set sar_afe_name [get_db [get_db insts -if {.base_cell.name == sar_afe}] .name]
connect_global_net VDD  -type pg_pin -pin_base_name vdd  -inst_base_name $sar_afe_name
connect_global_net VSS  -type pg_pin -pin_base_name vss  -inst_base_name $sar_afe_name
connect_global_net VDDA -type pg_pin -pin_base_name vdda -inst_base_name $sar_afe_name
connect_global_net VDDA -type pg_pin -pin_base_name vref -inst_base_name $sar_afe_name
# The pads' VDDA pins (the VDDA pads' core-side met3 pins and every pad's ring bus) by
# name, as VDDIO/VSSIO above: the synthesised netlist leaves the pads' power pins out
# and the CPF has no connections, so without this VDDA would have no pad pin to route.
connect_global_net VDDA -type pg_pin -pin_base_name VDDA -inst_base_name uPAD_*
# Likewise VCCD, the core supply (nanosoc_chip_pads.upf: the VDD pads' supply pin), which
# was on no net at all, so nothing could join the VDD pads to the VDD core ring.
connect_global_net VDD  -type pg_pin -pin_base_name VCCD -inst_base_name uPAD_*
# The rest of the pad ring's buses on the cells that are not in the netlist (corner pads,
# the VCCHIB/VSWITCH connect slices and the IO fillers, floorplan.tcl), so that they are
# on the same nets as the pads they abut: VCCHIB on VCCD and VSWITCH on VDDIO, as the
# connect slices tie them (and as nanosoc_chip_pads.upf says), on every ring cell; the
# grounds the netlist puts on VSS for the pads.
foreach {_net _pin} {VDDA VDDA  VDD VCCD  VDD VCCHIB  VDDIO VSWITCH} {
    connect_global_net $_net -type pg_pin -pin_base_name $_pin -inst_base_name uPAD_*
    connect_global_net $_net -type pg_pin -pin_base_name $_pin -inst_base_name IOFILL*
}
foreach _cells {uPAD_CORNER_* uPAD_CONN_* uPAD_ADC_* IOFILL*} {
    connect_global_net VSS -type pg_pin -pin_base_name VSSD -inst_base_name $_cells
}
# VSSA, VSSIO_Q and VDDIO_Q on their own nets, as in nanosoc_chip_pads.upf, on every ring
# cell. The synthesised netlist puts the pads' VSSA and VSSIO_Q pins on VSS, while the
# layout keeps those ring buses separate (sign-off LVS); nothing in the core uses them
# (the ADC's vss is on VSS).
foreach {_net _pin} {VSSA VSSA  VSSIO_Q VSSIO_Q  VDDIO_Q VDDIO_Q} {
    foreach _cells {uPAD_* IOFILL*} {
        connect_global_net $_net -type pg_pin -pin_base_name $_pin -inst_base_name $_cells -netlist_override
    }
}

# M1(2), M4(5), M5(6)
# The route_special calls below used to give their layer ranges as { M1(2) M5(6) }. This
# tech has no layer M1 or M5 (they are met1..met5), Innovus treated met5 as out of range
# (IMPSR-486), and the last call's floating-stripe extension bridged the met4 stripes
# across the SRAMs on li1, the one layer their LEF leaves open: VDD-VSS shorts through the
# SRAMs' own li1 (sign-off LVS). The ranges are now { met1 met5 }.

### Top and Bottom Metal Declartions
set_db add_rings_stacked_via_top_layer 6
set_db add_rings_stacked_via_bottom_layer 2

### Adding Rings 
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top 6 bottom 6 left 5 right 5} -width {top 10 bottom 10 left 10 right 10} -spacing {top 5 bottom 5 left 5 right 5} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
# route_special -connect {pad_pin pad_ring} is off (both calls). pad_pin joins nothing:
# route_special takes only CLASS CORE pad ports, and the sky130 pad LEFs have none
# (IMPSR-1256; pad_supply_to_ring below does that job). pad_ring bridged the ring buses
# across the gaps between pads; floorplan.tcl now closes those gaps with IO filler slices,
# and the bridging wires then lay over the fillers' pins of other nets: 787 met4/met5
# shorts in the IO ring (first run with fillers).
#route_special -connect {pad_pin pad_ring} -layer_change_range { met1 met5 } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { met1 met5 } -nets { VDD VSS VDDIO VSSIO } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { met1 met5 }

# TODO I likely need the VDDIO VSSIO rings

### SAR ADC macro: a block ring of VDD, VSS and VDDA around it, as in the macro's
### Innovus check (analog/cadence/pv/macro/innovus_smoke/smoke.tcl). Its supply straps
### are full-height met4 (vss, vdda, vref, vdd from each side edge inwards), so the
### ring's sides are met4 and its top and bottom met5; route_special below drops the
### strap ends onto the top and bottom sides. The ring lies inside the 20 um between
### the macro and the core edge (floorplan.tcl).
deselect_obj -all
select_obj [get_db insts $sar_afe_name]
add_rings -nets {VDD VSS VDDA} -type block_rings -around selected -layer {top met5 bottom met5 left met4 right met4} -width 2 -spacing 2 -offset 2
deselect_obj -all

### Adding Stripes 
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
#set_db add_stripes_stapling_extend_to_minimum_spacing true
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

# The bootrom (u_bootrom_u_sl_rom) used to be in this list too, but it is synthesised to
# standard cells, so there is no such instance: get_cells then raised TCLCMD-917, the
# catch that wrapped this swallowed it, and the stripe blockage below came out empty. The
# met4/met5 stripes then ran straight over the SRAMs, dropping to li1 under their met4
# obstruction (DEF: "NEW li1 1800 + SHAPE STRIPE" across the SRAM at 2307,1160), where
# the SRAMs' own li1 shorted VDD to VSS (sign-off LVS of the first ADC chip run).
set power_stripes_all_macros [ list u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram ]
# The ADC macro too: the met4 stripes go around it. Its met4 is obstructed except at
# its own supply straps, which get their VDD/VSS/VDDA from the block ring above.
lappend power_stripes_all_macros $sar_afe_name

# The stripes' blockage: each macro's place-halo box. No catch: a missing macro, or a
# block in the design that is not in the list, stops the stage here.
set power_stripes_all_macros_bbox {}
foreach macro $power_stripes_all_macros {
  set inst [get_db insts $macro]
  if {[llength $inst] != 1} { error "power_plan.tcl: macro $macro not found" }
  lappend power_stripes_all_macros_bbox {*}[get_db $inst .place_halo_bbox]
}
foreach blk [get_db insts -if {.base_cell.base_class == block}] {
  if {[lsearch -exact $power_stripes_all_macros [get_db $blk .name]] < 0} {
    error "power_plan.tcl: block [get_db $blk .name] is not in power_stripes_all_macros"
  }
}
puts "power_plan.tcl: stripe blockage around [llength $power_stripes_all_macros_bbox] macros: $power_stripes_all_macros_bbox"
set power_stripes_all_macros_bbox_str [join [ list $power_stripes_all_macros_bbox ]]

# M4(5)
add_stripes -nets {VDD VSS} -layer 5 -direction vertical -width 1.8 -spacing 0.8 -set_to_set_distance 100 -extend_to all_domains -start_from left -start_offset 39.5 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none -area_blockage $power_stripes_all_macros_bbox_str
# M5(6)
# Not blocked over the macros (only the met4 stripes are): the SRAMs' LEF obstructs no met5,
# and these stripes are how their supply rings get power, via4 onto the met4 rings where they
# cross (VDD on the outer vccd1 ring, VSS on the inner vssd1 ring). With the macros blocked
# here, vssd1 of all four SRAMs was left unconnected (sign-off LVS), and the stripe ends at the
# halo edges left met5 slivers (CDR.m5.1/m5.2). The ADC's met5 obstruction (its comparator
# clock, y 485.5-491.1) lies between stripe rows.
add_stripes -nets {VDD VSS} -layer 6 -direction horizontal -width 1.8 -spacing 1.6 -set_to_set_distance 100 -extend_to all_domains -start_from left -start_offset 39.5 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none

# get_db [get_cells u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram] .bbox

### SRAM supply rings. Each SRAM's vccd1 (outer) and vssd1 (inner) ring is met3 on two sides
### and met4 on the other two; placed r90/r270 the met4 sides run horizontally, parallel to
### the met5 stripes, so no stripe ever crosses them. add_stripes, update_power_vias and
### route_special block_pin (met4 only) left them without via4, so vssd1 floated (sign-off
### LVS); route_special block_pin with met3 put via3 on the SRAMs' own via3 (CDR.via3.*).
### Instead: a met5 strap right over each met4 ring side, with M4M5_PR vias along it onto
### the ring, run out sideways to the nearest met4 stripe of the same net beyond the macro's
### halo on each side, with a via there. Only met5 and via4: the SRAM GDS has neither.
proc sram_ring_straps {} {
    foreach m [get_db insts -if {.base_cell.name == sky130_sram_*}] {
        lassign [lindex [get_db $m .bbox] 0] llx lly urx ury
        lassign [lindex [get_db $m .place_halo_bbox] 0] hx1 - hx2 -
        lassign [lindex [get_db $m .base_cell.bbox] 0] - - cw ch
        set o [get_db $m .orient]
        foreach {pin net} {vccd1 VDD vssd1 VSS} {
            set pbp [get_db $m .base_cell.pg_base_pins -if ".base_name == $pin"]
            foreach r [get_db [get_db $pbp .physical_pins.layer_shapes -if {.layer.name == met4}] .shapes.rect] {
                lassign $r x1 y1 x2 y2
                switch $o {
                    r90  { lassign [list [expr {$llx+$ch-$y2}] [expr {$lly+$x1}] [expr {$llx+$ch-$y1}] [expr {$lly+$x2}]] ax1 ay1 ax2 ay2 }
                    r270 { lassign [list [expr {$llx+$y1}] [expr {$lly+$cw-$x2}] [expr {$llx+$y2}] [expr {$lly+$cw-$x1}]] ax1 ay1 ax2 ay2 }
                    default { error "sram_ring_straps: [get_db $m .name] is $o; only r90/r270 SRAMs are handled" }
                }
                if {$ax2 - $ax1 < $ay2 - $ay1} { error "sram_ring_straps: $pin met4 side of [get_db $m .name] is not horizontal" }
                # nearest vertical met4 stripe of the net beyond the halo on each side, spanning the side's y
                set left ""; set right ""
                foreach w [get_db [get_db nets $net] .special_wires -if {.layer.name == met4 && .shape == stripe}] {
                    lassign [lindex [get_db $w .rect] 0] wx1 wy1 wx2 wy2
                    if {$wy1 > $ay1 || $wy2 < $ay2} continue
                    if {$wx2 <= $hx1 && ($left eq "" || $wx1 > [lindex $left 0])} { set left [list $wx1 $wx2] }
                    if {$wx1 >= $hx2 && ($right eq "" || $wx1 < [lindex $right 0])} { set right [list $wx1 $wx2] }
                }
                if {$left eq "" || $right eq ""} { error "sram_ring_straps: no $net met4 stripe beside [get_db $m .name] at y $ay1" }
                create_shape -net $net -layer met5 -rect [list [lindex $left 0] $ay1 [lindex $right 1] $ay2] -shape stripe -status fixed
                set yc [expr {($ay1 + $ay2) / 2.0}]
                set n 0
                for {set x [expr {$ax1 + 5.0}]} {$x <= $ax2 - 5.0} {set x [expr {$x + 20.0}]} {
                    create_via -net $net -via_def M4M5_PR -shape stripe -status fixed -location [list $x $yc]; incr n
                }
                foreach s [list $left $right] {
                    create_via -net $net -via_def M4M5_PR -shape stripe -status fixed -location [list [expr {([lindex $s 0] + [lindex $s 1]) / 2.0}] $yc]
                }
                puts "power_plan.tcl: SRAM [get_db $m .name] $pin: met5 strap y $ay1-$ay2 from x [lindex $left 0] to [lindex $right 1], $n via4 on the ring"
            }
        }
    }
}
# (called after the followpin route_special below: there, straps that already existed were
# a "stripe" target for the rows ending at the SRAM halos, which then got M3M4 stacks onto
# the SRAM ring corners, right on the SRAM's own via3)

# connect Macros: off. The met5 stripes it laid over the macros came out as stubs at their
# edges (met5 jogs overlapping by 20 nm: CDR.m5.1/m5.2) and connected no SRAM ring; the
# global met5 stripes above now cross the macros instead.
#select_obj $power_stripes_all_macros
#set_db add_stripes_ignore_block_check false
#set_db add_stripes_break_at none
#set_db add_stripes_route_over_rows_only false
#set_db add_stripes_rows_without_stripes_only false
#set_db add_stripes_extend_to_closest_target {ring stripe}
# M5(6)
# TODO review this
#add_stripes -nets {VDD VSS} -layer 6 -direction horizontal -width 1.6 -spacing 1.6 -set_to_set_distance 15 -over_power_domain 1 -start_from bottom -start_offset 8 -stop_offset 0 -switch_layer_over_obs false -merge_stripes_value 500 -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none


# Add END CAPS
# add_endcaps -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP
# add_endcaps -power_domain PD_ACC -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP

# (second pad_pin/pad_ring call, off for the same reason)
#route_special -connect {pad_pin pad_ring} -layer_change_range { met1 met5 } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { met1 met5 } -nets { VDD VSS VDDIO VSSIO VDDACC } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { met1 met5 }
set_db route_special_via_connect_to_shape { padring stripe }
# VDDIO VSSIO not used inside core so not needed??
### Supply pads to their rings. The route_special -connect pad_pin calls above join no
### pad to anything: route_special only takes pad pins whose LEF ports are CLASS CORE
### (IMPSR-1256, "Number of Pad ports routed: 0"), and the sky130 pad LEFs have none.
### So each supply pad's core-side pins (two ~24 um wide met3 rects on its core edge) are
### drawn in here as met3 wires to the nearest ring wire of the same net, with vias only
### where they meet it. met3 passes under the met4/met5 rings of the other nets.
###   pads   pad instances (a glob), each in the left (r90), bottom (r180), top (r0) or
###          right (r270) row
###   pin    the pad's supply pin;  net  its net;  shape  ring (core ring) or blockring
proc pad_supply_to_ring {pads pin net shape} {
    set wires [get_db [get_db nets $net] .special_wires -if ".shape == $shape"]
    foreach pad [get_db insts $pads] {
        lassign [lindex [get_db $pad .bbox] 0] llx lly urx ury
        lassign [lindex [get_db $pad .base_cell.bbox] 0] - - cw ch
        set orient [get_db $pad .orient]
        set pbp [get_db $pad .base_cell.pg_base_pins -if ".base_name == $pin"]
        foreach ls [get_db $pbp .physical_pins.layer_shapes -if {.layer.name == met3}] {
            foreach r [get_db $ls .shapes.rect] {
                lassign $r x1 y1 x2 y2
                if {$y1 > 0.5} { continue }      ;# core-edge pins only (pad-local y = 0)
                # 2 um in from each side (clear of the pad's met3 obstruction between
                # the pins), and from 1 um inside the pad's core edge outwards
                set a [expr {$x1 + 2.0}]; set b [expr {$x2 - 2.0}]
                switch $orient {
                    r90  { set s [list [expr {$llx + $ch - 1.0}] [expr {$lly + $a}] - [expr {$lly + $b}]]; set dir +x }
                    r270 { set s [list - [expr {$lly + $cw - $b}] [expr {$llx + 1.0}] [expr {$lly + $cw - $a}]]; set dir -x }
                    r180 { set s [list [expr {$llx + $cw - $b}] [expr {$lly + $ch - 1.0}] [expr {$llx + $cw - $a}] -]; set dir +y }
                    r0   { set s [list [expr {$llx + $a}] - [expr {$llx + $b}] [expr {$lly + 1.0}]]; set dir -y }
                    default { error "pad_supply_to_ring: [get_db $pad .name] has orientation $orient" }
                }
                # nearest ring wire of the net that the pin's run would cross
                set best ""; set bestd 1e9
                foreach w $wires {
                    lassign [lindex [get_db $w .rect] 0] wx1 wy1 wx2 wy2
                    switch $dir {
                        +x { if {$wy1 <= [lindex $s 1] && $wy2 >= [lindex $s 3] && $wx1 > [lindex $s 0] && $wx1 - [lindex $s 0] < $bestd} { set best $w; set bestd [expr {$wx1 - [lindex $s 0]}] } }
                        -x { if {$wy1 <= [lindex $s 1] && $wy2 >= [lindex $s 3] && $wx2 < [lindex $s 2] && [lindex $s 2] - $wx2 < $bestd} { set best $w; set bestd [expr {[lindex $s 2] - $wx2}] } }
                        +y { if {$wx1 <= [lindex $s 0] && $wx2 >= [lindex $s 2] && $wy1 > [lindex $s 1] && $wy1 - [lindex $s 1] < $bestd} { set best $w; set bestd [expr {$wy1 - [lindex $s 1]}] } }
                        -y { if {$wx1 <= [lindex $s 0] && $wx2 >= [lindex $s 2] && $wy2 < [lindex $s 3] && [lindex $s 3] - $wy2 < $bestd} { set best $w; set bestd [expr {[lindex $s 3] - $wy2}] } }
                    }
                }
                if {$best eq ""} {
                    puts "**WARN: pad_supply_to_ring: no $shape wire of $net in line with [get_db $pad .name]/$pin"
                    continue
                }
                lassign [lindex [get_db $best .rect] 0] wx1 wy1 wx2 wy2
                switch $dir {
                    +x { lset s 2 $wx2; set v [list $wx1 [lindex $s 1] $wx2 [lindex $s 3]] }
                    -x { lset s 0 $wx1; set v [list $wx1 [lindex $s 1] $wx2 [lindex $s 3]] }
                    +y { lset s 3 $wy2; set v [list [lindex $s 0] $wy1 [lindex $s 2] $wy2] }
                    -y { lset s 1 $wy1; set v [list [lindex $s 0] $wy1 [lindex $s 2] $wy2] }
                }
                create_shape -net $net -layer met3 -rect $s -shape iowire -status fixed
                update_power_vias -add_vias 1 -nets $net -area [list $v] -bottom_layer met3 -top_layer [get_db $best .layer.name]
                puts "pad_supply_to_ring: [get_db $pad .name]/$pin -> $net $shape [get_db $best .layer.name] met3 {$s} vias {$v}"
            }
        }
    }
}
# The ADC's VDDA (vdda and vref) from the VDDA pads beside it to its block ring
# (nanosoc_io_plan.io puts uPAD_VDDA_0 on the left row, uPAD_VDDA_1/2 below the macro).
pad_supply_to_ring uPAD_VDDA_* VDDA VDDA blockring
# The core supply pads to the core rings.
pad_supply_to_ring uPAD_VDD_* VCCD VDD ring
pad_supply_to_ring uPAD_VSS_* VSSD VSS ring

### SAR ADC macro: its supply straps (use_lef: the LEF pins as drawn) onto its block ring.
route_special -connect {block_pin} -inst $sar_afe_name -nets {VDD VSS VDDA} -block_pin use_lef -block_pin_target nearest_target -layer_change_range {met1 met5} -crossover_via_layer_range {met1 met5} -target_via_layer_range {met1 met5} -allow_jogging 1 -allow_layer_change 1

# Followpins only, and their row ends only to rings and stripes (not first_after_row_end):
# rows ending at an SRAM's halo were run onto its vccd1 ring corner with an M3M4 stack,
# on top of the SRAM's own via3 there (CDR.via3.*); the met4 stripes cross every row.
# block_pin also joined the SRAMs' own met3/met4 supply rings with via3
# stacks, on top of their internal via3 (CDR.via3.*), and floating_stripe ran long thin
# met2/met3 VDD/VSS wires through the standard-cell area to reach the stripe ends at the
# macro halos. The SRAMs get their supply from the met5 stripes, the ADC from its own
# route_special above.
route_special -connect {core_pin} -layer_change_range { met1 met5 } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target {ring stripe} -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { PD_TOP } -crossover_via_layer_range { met1 met5 } -nets { VDD VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { met1 met5 }

### The SRAMs' ring straps (sram_ring_straps above), now that the followpins are in.
sram_ring_straps

### No power wire may be on li1: the rails are met1, the macro and pad pins met3/met4, and
### li1 belongs to the cells (an li1 stripe over an SRAM shorted VDD to VSS, see above).
set _li1 [get_db [get_db nets {VDD VSS VDDA}] .special_wires -if {.layer.name == li1}]
if {[llength $_li1]} {
  error "power_plan.tcl: [llength $_li1] power wires on li1, e.g. [get_db [lindex $_li1 0] .net.name] [get_db [lindex $_li1 0] .rect]"
}
puts "power_plan.tcl: no power wires on li1"


### Each SRAM's supply rings must have via4 from the met5 stripes: VDD on vccd1, VSS on vssd1
### (both are met3/met4 rings in the SRAM LEF; with no via on vssd1 its rail floated).
foreach _m [get_db insts -if {.base_cell.name == sky130_sram_*}] {
    lassign [lindex [get_db $_m .bbox] 0] _x1 _y1 _x2 _y2
    foreach _n {VDD VSS} {
        set _k 0
        foreach _v [get_db [get_db nets $_n] .special_vias] {
            lassign [lindex [get_db $_v .point] 0] _vx _vy
            if {$_vx > $_x1 && $_vx < $_x2 && $_vy > $_y1 && $_vy < $_y2 && [string match M4M5* [get_db $_v .via_def.name]]} { incr _k }
        }
        if {$_k == 0} { error "power_plan.tcl: no $_n met4-met5 via on SRAM [get_db $_m .name]" }
        # and no via3 of ours inside it or within 0.5 um of its edge: the SRAM has its own
        # via3 on its ring corners (CDR.via3.* overlap, and via3.2 spacing just outside)
        set _k3 [llength [lmap _v [get_db [get_db nets $_n] .special_vias] {lassign [lindex [get_db $_v .point] 0] _vx _vy; if {$_vx > $_x1-0.5 && $_vx < $_x2+0.5 && $_vy > $_y1-0.5 && $_vy < $_y2+0.5 && [string match M3M4* [get_db $_v .via_def.name]]} {set _v} else {continue}}]]
        if {$_k3 > 0} { error "power_plan.tcl: $_k3 $_n via3 in or within 0.5 um of SRAM [get_db $_m .name]" }
        puts "power_plan.tcl: SRAM [get_db $_m .name]: $_k $_n via4, no via3"
    }
}
