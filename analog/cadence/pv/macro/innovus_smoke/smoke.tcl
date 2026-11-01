# Innovus smoke test of the ADC macro hand-off views (LEF + lib) with
# sky130_fd_sc_hd: all three placement variants along the bottom of a die,
# as on the chip (Daniel's floorplan has its free space below the SRAMs):
#   u_afe_l  sar_afe    bottom-left,   analog inputs from the left edge
#   u_afe_b  sar_afe_b  bottom-middle, analog inputs from the bottom edge
#   u_afe_r  sar_afe_r  bottom-right,  analog inputs from the right edge
# Power is planned the way ASIC_ours/Cadence/scripts/power_plan.tcl does it
# (met4 stripes kept off the macros, met5 stripes across), plus separate
# analog supplies for the macros: VDDA for the vdda pins (the sampling
# switches), as in the chip's PD_ANALOG domain, and VREF for the vref pins
# (the CDAC reference, decoupled on its own).
#   cd <run dir> && MACRO_OUT=<ASIC_ours/macros/sar_afe> innovus -no_gui -files smoke.tcl
set SC /opt/pdk/sky130A/libs.ref/sky130_fd_sc_hd
set O $::env(MACRO_OUT)
set_multi_cpu_usage -local_cpu 4
set_db init_power_nets {VDD VDDA VREF}
set_db init_ground_nets {VSS}
read_mmmc mmmc.tcl
read_physical -lef [list $SC/techlef/sky130_fd_sc_hd__nom.tlef $SC/lef/sky130_fd_sc_hd.lef \
  $O/sar_afe.lef $O/sar_afe_b.lef $O/sar_afe_r.lef]
read_netlist smoke.v -top afe_smoke3
init_design
connect_global_net VDD  -type pg_pin -pin_base_name VPWR -inst_base_name *
connect_global_net VDD  -type pg_pin -pin_base_name VPB  -inst_base_name *
connect_global_net VSS  -type pg_pin -pin_base_name VGND -inst_base_name *
connect_global_net VSS  -type pg_pin -pin_base_name VNB  -inst_base_name *
connect_global_net VDD  -type pg_pin -pin_base_name vdd  -inst_base_name *
connect_global_net VDDA -type pg_pin -pin_base_name vdda -inst_base_name *
connect_global_net VREF -type pg_pin -pin_base_name vref -inst_base_name *
connect_global_net VSS  -type pg_pin -pin_base_name vss  -inst_base_name *
create_floorplan -site unithd -core_size 1500 800 40 40 40 40
# core spans x 40..1540, y 40..840 (1500 wide since the 20 Oct macro is 260 um
# wide). Macro origins on the met3/met2 track
# pitches (0.68 / 0.46 um multiples from the core origin).
set yL [expr {40 + 0.68 * 30}]
place_inst u_afe_l [list [expr {40 + 0.46 * 44}] $yL] r0 -fixed
place_inst u_afe_b [list [expr {40 + 0.46 * 1300}] $yL] r0 -fixed
place_inst u_afe_r [list [expr {40 + 0.46 * 2550}] $yL] r0 -fixed
foreach i {u_afe_l u_afe_b u_afe_r} { puts "SMOKE $i bbox [get_db [get_db insts $i] .bbox]" }
# IO pins: each macro's vinp/vinn level with its analog pins, on the die edge
# that the macro's analog edge faces; every digital IO on the top edge.
foreach {inst edge} {u_afe_l 0 u_afe_b 3 u_afe_r 2} {
  set v [string index $inst end]
  foreach n {vinp vinn} {
    set r [lindex [get_db [get_db insts $inst] .pins *$n] 0]
    set b [lindex [get_db $r .location] 0]
    puts "SMOKE $inst/$n at $b"
    switch $edge {
      0 { edit_pin -pin ${n}_$v -edge 0 -layer met3 -assign [list 0 [lindex $b 1]] -fixed_pin 1 }
      2 { edit_pin -pin ${n}_$v -edge 2 -layer met3 -assign [list [get_db current_design .bbox.ur.x] [lindex $b 1]] -fixed_pin 1 }
      3 { edit_pin -pin ${n}_$v -edge 3 -layer met3 -assign [list [lindex $b 0] 0] -fixed_pin 1 }
    }
  }
}
edit_pin -pin [get_db [get_db ports -if {.name != vin*}] .name] -edge 1 -layer met2 \
  -spread_type range -start {60 0} -end {1520 0} -fix_overlap 1
foreach i {u_afe_l u_afe_b u_afe_r} {
  create_place_halo -insts $i -halo_deltas {9.6 9.6 9.6 9.6}
  create_route_halo -insts $i -space 4.8 -bottom_layer met1 -top_layer met4
}
# well taps, as the chip flow places them (the standard cells' VNB/VPB)
add_well_taps -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cell_interval 26 -prefix WELLTAP
set_db add_rings_stacked_via_top_layer met5
set_db add_rings_stacked_via_bottom_layer met1
add_rings -nets {VDD VSS VDDA VREF} -type core_rings -follow core -layer {top met5 bottom met5 left met4 right met4} -width 4 -spacing 2 -offset 2
# block rings: met4 on the sides where a macro's met4 supply pins end, met5
# across them. sar_afe/sar_afe_r have full-height met4 straps (ending at the
# top and bottom edges); sar_afe_b, the rotated variant, has full-width met4
# bands ending at its left and right edges, so its ring's layers are swapped.
foreach {i lay} {u_afe_l {top met5 bottom met5 left met4 right met4}
                 u_afe_r {top met5 bottom met5 left met4 right met4}
                 u_afe_b {top met4 bottom met4 left met5 right met5}} {
  deselect_obj -all
  select_obj [get_db insts $i]
  add_rings -nets {VDD VSS VDDA VREF} -type block_rings -around selected -layer $lay -width 2 -spacing 2 -offset 2
}
deselect_obj -all
set_db add_stripes_stacked_via_top_layer met5
set_db add_stripes_stacked_via_bottom_layer met1
set_db add_stripes_skip_via_on_pin {standardcell}
set_db add_stripes_remove_floating_stripe_over_block true
set halos {}
foreach i {u_afe_l u_afe_b u_afe_r} { lappend halos {*}[get_db [get_db insts $i] .place_halo_bbox] }
# met4 vertical stripes kept off the macros (as power_plan.tcl does for its macros)
add_stripes -nets {VDD VSS} -layer met4 -direction vertical -width 1.8 -spacing 0.8 -set_to_set_distance 100 -start_offset 39.5 -area_blockage $halos
# met5 horizontal stripes everywhere: they cross the macros outside their met5 obstruction
add_stripes -nets {VDD VSS VDDA VREF} -layer met5 -direction horizontal -width 1.8 -spacing 1.6 -set_to_set_distance 60 -start_offset 20
route_special -connect {block_pin core_pin} -nets {VDD VSS VDDA VREF} -block_pin_target nearest_target -block_pin use_lef -core_pin_target first_after_row_end -allow_layer_change 1 -allow_jogging 1 -layer_change_range {met1 met5} -crossover_via_layer_range {met1 met5} -target_via_layer_range {met1 met5}
set_db [get_db insts b_*] .dont_touch true
place_design
route_design
check_connectivity -type all -out_file smoke_conn.rpt
puts "SMOKE signal nets: [llength [get_db nets -if {!.is_power && !.is_ground}]]"
foreach n [get_db nets -if {!.is_power && !.is_ground}] { set w 0; foreach s [get_db $n .wires] { set w [expr {$w + [get_db $s .length]}] }; puts "SMOKE net [get_db $n .name] wire_um [format %.1f $w]" }
check_drc -out_file smoke_drc.rpt
foreach n {VDD VSS VDDA VREF} { puts "SMOKE $n special vias: [llength [get_db [get_db nets $n] .special_vias]]" }
write_def smoke.def
puts "SMOKE done"
exit
