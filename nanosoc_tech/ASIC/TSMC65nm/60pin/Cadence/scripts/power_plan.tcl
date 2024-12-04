#########################################
# Script : Power Planning 
# Tool : Cadence Innovus 
# Date : May 22, 2023
# Author : Srimanth Tenneti
######################################### 

### Connecting Global Nets
connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name * 
connect_global_net VDDIO -type pg_pin -pin_base_name VDDIO -inst_base_name * 
connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name * 
connect_global_net VSSIO -type pg_pin -pin_base_name VSSIO -inst_base_name * 
connect_global_net VDDACC -type pg_pin -pin_base_name VDD -inst_base_name {} -hinst u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -override
### Top and Bottom Metal Declartions
set_db add_rings_stacked_via_top_layer M8
set_db add_rings_stacked_via_bottom_layer M1 

### Adding Rings 
add_rings -nets {VDD VDDACC VSS} -type core_rings -follow core -layer {top M9 bottom M9 left M8 right M8} -width {top 8 bottom 8 left 8 right 8} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 3 bottom 3 left 3 right 3} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

### Adding Stripes 
set_db add_stripes_ignore_block_check true
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain true
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer AP
set_db add_stripes_stacked_via_bottom_layer M1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring  block_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDD VDDACC VSS} -layer M6 -direction vertical -width 1.8 -spacing 0.8 -set_to_set_distance 60 -extend_to all_domains -start_from left -start_offset 50 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid none

deselect_obj -all

# Connect Accelerator region
select_obj u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator
set_db add_stripes_ignore_block_check true
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target stripe
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain true
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer AP
set_db add_stripes_stacked_via_bottom_layer M4
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring  block_ring }
set_db add_stripes_skip_via_on_pin {  standardcell }
set_db add_stripes_skip_via_on_wire_shape {  noshape   }
add_stripes -nets {VDDACC VSS} -layer M9 -direction horizontal -width 1 -spacing 0.5 -set_to_set_distance 50 -over_power_domain 1 -start_from bottom -start_offset 15 -stop_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid none

deselect_obj -all

# connect Macros
select_obj [ list u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_u_rf_sp_hdf u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_u_rf_sp_hdf u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_u_rf_sp_hdf u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_u_rf_sp_hdf u_nanosoc_chip_u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom]
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target stripe
add_stripes -nets {VDD VSS} -layer M5 -direction horizontal -width 1 -spacing 0.5 -set_to_set_distance 15 -over_power_domain 1 -start_from bottom -start_offset 8 -stop_offset 0 -switch_layer_over_obs false -merge_stripes_value 500 -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid none

deselect_obj -all

# Add END CAPS
add_endcaps -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP
add_endcaps -power_domain ACCEL -start_row_cap ENDCAPTIE2_A12TR -end_row_cap ENDCAPTIE2_A12TR -prefix ENDCAP

