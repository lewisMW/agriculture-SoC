#------------------------------------------------------------------------------------
# Cadence Innovus: Floorplan
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# Copyright (c) 2026, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------
### Power intent: the domains' supply nets. Genus writes the CPF from the 1801 UPF with
### the power domains only, no supply nets (outputs/<block>_gate1.cpf), so Innovus has no
### primary power or ground net for PD_TOP, and add_tieoffs (postplace.tcl) and
### add_fillers (filler.tcl) stop with IMPSP-5110: every run so far had no tie cells and
### no fillers. 2_pnr_setup.tcl has read and committed that CPF; here the same file, with
### the nets and each domain's primary supplies from nanosoc_chip_pads.upf
### (set_domain_supply_net) added, is read and committed again, before the floorplan.
set _fh [open $OUT_DIR/${block_name}_gate1.cpf r]; set _cpf [read $_fh]; close $_fh
set _nets "create_power_nets -nets VDD -voltage 1.8
create_power_nets -nets VDDA -voltage 1.8
create_power_nets -nets VDDIO -voltage 3.3
create_power_nets -nets VDDIO_Q -voltage 3.3
create_ground_nets -nets VSS
create_ground_nets -nets VSSA
create_ground_nets -nets VSSIO
create_ground_nets -nets VSSIO_Q
"
set _doms "update_power_domain -name PD_TOP -primary_power_net VDD -primary_ground_net VSS
update_power_domain -name PD_IO -primary_power_net VDDIO -primary_ground_net VSSIO
update_power_domain -name PD_ANALOG -primary_power_net VDDA -primary_ground_net VSSA
end_design"
if {![regsub {(set_design [^\n]*\n)} $_cpf "\\1$_nets" _cpf] || ![regsub {end_design} $_cpf $_doms _cpf]} {
    error "floorplan.tcl: unexpected CPF from Genus: $OUT_DIR/${block_name}_gate1.cpf"
}
set _fh [open $OUT_DIR/${block_name}_gate1_supplies.cpf w]; puts -nonewline $_fh $_cpf; close $_fh
read_power_intent -cpf $OUT_DIR/${block_name}_gate1_supplies.cpf
commit_power_intent
puts "floorplan.tcl: PD_TOP supplies [get_db power_domain:PD_TOP .primary_power_net.name]/[get_db power_domain:PD_TOP .primary_ground_net.name]"

# TODO this needs to be (2.920um w x 3.520um h) (right now too large, max 15mm^2)
#create_floorplan -die_size_by_io_height max -site CoreSite -core_size 2920 3520 50 50 50 50
#create_floorplan -die_size_by_io_height max -site unithd -core_size 2920 3520 50 50 50 50
# That command gave a 2920.08 x 3520.02 core at (261.105, 260.945) and, after
# read_io_file, a 3442.29 x 4041.91 die. The same core with the die rounded to whole um
# (3442 x 4042): the pad ring's filler slices come in whole um (nanosoc_io_plan.io), so
# each row between the corner pads must be a whole number of um long. The IO box is
# 197.965 um in from the die, the height of the IO cells (read_io_file moves the die to
# that distance from the IO box: with 210.965 it shrank the die by 13 um a side).
# -no_snap_to_grid keeps the boxes exactly as given; the core box is the one Innovus
# snapped to the rows and tracks itself.
create_floorplan -site unithd -no_snap_to_grid -box_size {0 0 3442 4042  197.965 197.965 3244.035 3844.035  261.105 260.945 3181.185 3780.965}


read_io_file ../scripts/nanosoc_io_plan.io

# these are for the SRAMS. I don't think I need to further touch this
create_relative_floorplan -ref_type core_boundary -orient R90 -horizontal_edge_separate {1  -150  1} -vertical_edge_separate {0  150  0} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -orient R90 -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram

create_relative_floorplan -ref_type core_boundary -orient R270 -horizontal_edge_separate {1  -150  1} -vertical_edge_separate {2  -150  2} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -orient R270 -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram

create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram

create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram

snap_floorplan -all

### Close the pad ring. Between the pads there was nothing, so every ring bus that exists
### only by abutment (VDDA, VSSA, VSWITCH, VCCHIB, VDDIO_Q, the enables, AMUXBUS_A/B) was
### broken from pad to pad: the analog pads got no VDDA from the VDDA pads, and no gpiov2
### pad had VCCHIB or VSWITCH. sky130_ef_io__com_bus_slice_* carry all the buses; the IO
### plan spaces the pads by whole um, so the 20/10/5/1 um slices fill every gap exactly.
### After snap_floorplan, and fixed: the slices' LEF has no SYMMETRY, so snap_floorplan
### -all turned the placed left/right ones back to R0 (only the checks before it passed).
### One side at a time, in the orientation of that side's pads: the PDK LEF gives the slices
### no SYMMETRY, and add_io_fillers left all of them unrotated (N) on every side, so on the
### bottom, left and right rows their bus bands met the pads' buses at the wrong heights
### and shorted VDD to VSS, VDDA, VDDIO and VSSIO (sign-off LVS of the first filled ring).
foreach {_side _orient} {top r0 bottom r180 left r90 right r270} {
    add_io_fillers -cells {sky130_ef_io__com_bus_slice_20um sky130_ef_io__com_bus_slice_10um sky130_ef_io__com_bus_slice_5um sky130_ef_io__com_bus_slice_1um} -prefix IOFILL -side $_side -filler_orient $_orient
}
set_db [get_db insts IOFILL*] .place_status fixed
# Check: along each side, the IO cells (corners, pads, connect slices, fillers) abut from
# corner to corner, with no gap or overlap left.
set _die [lindex [get_db current_design .bbox] 0]
foreach {_side _axis _edge} {left 1 llx  right 1 urx  bottom 0 lly  top 0 ury} {
    set _segs {}
    foreach _i [get_db insts -if {.base_cell.name == sky130_ef_io__* || .base_cell.name == sky130_fd_io__*}] {
        lassign [lindex [get_db $_i .bbox] 0] _x1 _y1 _x2 _y2
        switch $_edge {
            llx { set _on [expr {abs($_x1 - [lindex $_die 0]) < 0.001}] }
            urx { set _on [expr {abs($_x2 - [lindex $_die 2]) < 0.001}] }
            lly { set _on [expr {abs($_y1 - [lindex $_die 1]) < 0.001}] }
            ury { set _on [expr {abs($_y2 - [lindex $_die 3]) < 0.001}] }
        }
        if {$_on} { lappend _segs [expr {$_axis ? [list $_y1 $_y2] : [list $_x1 $_x2]}] }
    }
    set _segs [lsort -real -index 0 $_segs]
    set _gaps {}
    for {set _k 1} {$_k < [llength $_segs]} {incr _k} {
        set _g [expr {[lindex $_segs $_k 0] - [lindex $_segs [expr {$_k - 1}] 1]}]
        if {abs($_g) > 0.001} { lappend _gaps [format %.3f@%.3f $_g [lindex $_segs $_k 0]] }
    }
    puts "floorplan.tcl: die [get_db current_design .bbox], IO ring $_side: [llength $_segs] cells, [lindex $_segs 0 0]..[lindex $_segs end 1], gaps/overlaps: [expr {[llength $_gaps] ? $_gaps : {none}}]"
}
puts "floorplan.tcl: [llength [get_db insts IOFILL*]] IO filler slices, [llength [get_db insts uPAD_CONN_*]] VCCHIB/VSWITCH connect slices"
set _o {}; foreach _i [get_db insts IOFILL*] { lappend _o [get_db $_i .orient] }
puts "floorplan.tcl: IO filler orientations: [lmap _k [lsort -unique $_o] {list $_k [llength [lsearch -all $_o $_k]]}]"


### SAR ADC analog front end: the sar_afe hard macro (ASIC_ours/macros/sar_afe/README.md,
### "Placing it on the chip"). The SRAMs fill the core's upper corners; the macro goes
### at the bottom-left, in R0, so its analog inputs (vinp/vinn, met3, left edge) face the
### left pad row, where uPAD_ADC_VINP/VINN sit level with them (nanosoc_io_plan.io), and
### its digital pins (met3, right edge) face the core, where the SAR logic goes.
### The origin is the README's: 44 sites (0.46 um) right of and 30 x 0.68 um above the
### core origin, on the placement grid, 20 um inside the core edges, which leaves room
### for the macro's block ring (power_plan.tcl) outside its halo. It is placed after
### snap_floorplan so nothing moves it. Synthesis flattens the hierarchy above it, so
### the instance is found by its cell rather than by name. With this floorplan it sits
### at (281.345, 281.345); vinn/vinp are at y 488.86/503.16, which the IO plan uses.
set sar_afe_inst [get_db insts -if {.base_cell.name == sar_afe}]
if {[llength $sar_afe_inst] != 1} {
    error "floorplan.tcl: expected one sar_afe instance, found [llength $sar_afe_inst]"
}
set sar_afe_name [get_db $sar_afe_inst .name]
set sar_afe_core [get_db current_design .core_bbox]
set sar_afe_x [expr {[lindex $sar_afe_core 0 0] + 0.46 * 44}]
set sar_afe_y [expr {[lindex $sar_afe_core 0 1] + 0.68 * 30}]
place_inst $sar_afe_name [list $sar_afe_x $sar_afe_y] r0 -fixed
# Same place halo as the SRAMs. The route halo keeps signal routing 4.8 um off the
# macro on met1-met4 (it is obstructed li1-met4 except at its pins); met5 is free over
# most of it, for the power stripes.
create_place_halo -insts $sar_afe_name -halo_deltas {9.6 9.6 9.6 9.6}
create_route_halo -insts $sar_afe_name -space 4.8 -bottom_layer met1 -top_layer met4
puts "floorplan.tcl: sar_afe $sar_afe_name at [get_db $sar_afe_inst .bbox]"

### The analog pads' P_CORE must be the GDS-true one from ../inputs/sky130_ef_io__analog_pad.lef
### (x 27.72-46.72), not the PDK LEF's 25 um rectangle (config.tcl).
foreach _r [get_db [get_db pins uPAD_ADC_VINP/P_CORE] .base_pin.physical_pins.layer_shapes.shapes.rect] {
    if {abs([lindex $_r 0] - 27.72) > 0.001 || abs([lindex $_r 2] - 46.72) > 0.001} {
        error "floorplan.tcl: sky130_ef_io__analog_pad P_CORE is $_r, not the 27.72-46.72 override"
    }
    puts "floorplan.tcl: analog pad P_CORE $_r (LEF override)"
}

### The ADC's analog inputs run from each analog pad's P_CORE straight to the macro's
### vinp/vinn: no buffer, resizing or other cell may go on them, in optimisation or CTS.
foreach sar_afe_pin {vinp vinn} {
    set sar_afe_net [get_db [get_db $sar_afe_inst .pins */$sar_afe_pin] .net]
    set_dont_touch $sar_afe_net true
    puts "floorplan.tcl: analog net [get_db $sar_afe_net .name] dont_touch [get_db $sar_afe_net .dont_touch]: [get_db [concat [get_db $sar_afe_net .drivers] [get_db $sar_afe_net .loads]] .name]"
}
