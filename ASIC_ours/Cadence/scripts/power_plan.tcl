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
connect_global_net VDDIO -type pg_pin -pin_base_name VDDIO -inst_base_name * -overrride
connect_global_net VSSIO -type pg_pin -pin_base_name VSSIO -inst_base_name * -overrride
connect_global_net VDDIO -type pg_pin -pin_base_name VDDIO_PAD -inst_base_name * 
connect_global_net VSSIO -type pg_pin -pin_base_name VSSIO_PAD -inst_base_name * 

# M1(2), M4(5), M5(6)

### Top and Bottom Metal Declartions
set_db add_rings_stacked_via_top_layer 6
set_db add_rings_stacked_via_bottom_layer 2

### Adding Rings 
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top 6 bottom 6 left 5 right 5} -width {top 10 bottom 10 left 10 right 10} -spacing {top 5 bottom 5 left 5 right 5} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
route_special -connect {pad_pin pad_ring} -layer_change_range { M1(2) M5(6) } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { M1(2) M5(6) } -nets { VDD VSS VDDIO VSSIO } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { M1(2) M5(6) }

# TODO I likely need the VDDIO VSSIO rings

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

set power_stripes_all_macros [ list u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram u_nanosoc_chip_u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom ]

# if block doesn't exist silently ignore
catch {
  #set power_stripes_all_macros_bbox [concat {*}[lmap macro $power_stripes_all_macros {get_db [get_cells $macro] .bbox} ]]
  set power_stripes_all_macros_bbox [concat {*}[lmap macro $power_stripes_all_macros {get_db [get_cells $macro] .place_halo_bbox} ]]
}
set power_stripes_all_macros_bbox_str [join [ list $power_stripes_all_macros_bbox ]]

# M4(5)
add_stripes -nets {VDD VSS} -layer 5 -direction vertical -width 1.8 -spacing 0.8 -set_to_set_distance 100 -extend_to all_domains -start_from left -start_offset 39.5 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none -area_blockage $power_stripes_all_macros_bbox_str
# M5(6)
# TODO somehow, these stripes are going through the macros, which is not needed/wanted
add_stripes -nets {VDD VSS} -layer 6 -direction horizontal -width 1.8 -spacing 1.6 -set_to_set_distance 100 -extend_to all_domains -start_from left -start_offset 39.5 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none -area_blockage $power_stripes_all_macros_bbox_str

# get_db [get_cells u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram] .bbox

# connect Macros
select_obj $power_stripes_all_macros
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target {ring stripe}
# M5(6)
# TODO review this
add_stripes -nets {VDD VSS} -layer 6 -direction horizontal -width 1.6 -spacing 1.6 -set_to_set_distance 15 -over_power_domain 1 -start_from bottom -start_offset 8 -stop_offset 0 -switch_layer_over_obs false -merge_stripes_value 500 -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit 2 -block_ring_top_layer_limit 6 -block_ring_bottom_layer_limit 2 -use_wire_group 0 -snap_wire_center_to_grid none


# Add END CAPS
# add_endcaps -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP
# add_endcaps -power_domain PD_ACC -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP

route_special -connect {pad_pin pad_ring} -layer_change_range { M1(2) M5(6) } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { M1(2) M5(6) } -nets { VDD VSS VDDIO VSSIO VDDACC } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { M1(2) M5(6) }
set_db route_special_via_connect_to_shape { padring stripe }
# VDDIO VSSIO not used inside core so not needed??
route_special -connect {block_pin core_pin floating_stripe} -layer_change_range { M1(2) M5(6) } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target first_after_row_end -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { PD_TOP } -crossover_via_layer_range { M1(2) M5(6) } -nets { VDD VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { M1(2) M5(6) }

