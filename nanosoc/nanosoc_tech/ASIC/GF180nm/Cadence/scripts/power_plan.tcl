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
connect_global_net VDDACC -type pg_pin -pin_base_name VDD -inst_base_name {} -hinst u_nanosoc_chip_u_system/u_ss_expansion_u_region_exp_u_ss_accelerator -override
### Top and Bottom Metal Declartions
set_db add_rings_stacked_via_top_layer M5
set_db add_rings_stacked_via_bottom_layer M1 

### Adding Rings 
add_rings -nets {VDD VDDACC VSS} -type core_rings -follow core -layer {top M9 bottom M9 left M8 right M8} -width {top 3 bottom 3 left 3 right 3} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 2 bottom 2 left 2 right 2} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
route_special -connect {pad_pin pad_ring} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { M1(1) AP(10) } -nets { VDD VSS VDDACC } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { M1(1) AP(10) }
