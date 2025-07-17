set_host_options -max_cores 8 -num_processes 8

open_lib nanosoc_chip_pads.dlib
open_block nanosoc_chip_pads

initialize_floorplan -control_type die -use_site_row -side_length {1020.384 1020.384} -core_offset 99.984
source ../floorplan/floorplan.tcl

create_io_ring -corner_height 74.496

#source ./io_plan.tcl

read_sdc ../inputs/constraints.sdc

load_upf ../inputs/nanosoc.upf

#source ./power_plan.tcl 
connect_pg_net -create_nets_only
connect_pg_net -automatic

create_pg_ring_pattern ring_pattern -nets {VDD VSS} -horizontal_layer M8 -vertical_layer M9 -horizontal_width {5} -vertical_width {5} -horizontal_spacing {2} -vertical_spacing {2}
set_pg_strategy core_ring -pattern {{name: ring_pattern} {nets: {VDD VSS}} {offset: {3 3}}} -core 
compile_pg -strategies core_ring -ignore_drc

create_pg_mesh_pattern mesh_pattern -layers {{{vertical_layer: M5} {width: 4} {pitch: 30.566} {offset: 21.5}} {{horizontal_layer: M6} {width: 4} {pitch: 30} {offset: 20}}} -via_rule {{intersection : all}}                                                
set_pg_strategy M5M6_mesh -core -pattern {{name: mesh_pattern} {nets: {VDD VSS}}} \
        -extension {{stop : first_target}}
compile_pg -strategies M5M6_mesh -ignore_drc

create_pg_std_cell_conn_pattern std_pattern -layers {M2} -check_std_cell_drc false -mark_as_follow_pin false -rail_width {0.14 0.14}
set_pg_strategy std_cell_strat -pattern {{name: std_pattern} {nets: {VDD VSS}}} -core
compile_pg -strategies std_cell_strat -ignore_drc

place_io 
create_cell {CORNER1 CORNER2 CORNER3 CORNER4} /home/dwn1c21/SoC-Labs/TAPEOUT/nov2025/accelerator-project/nanosoc_tech/ASIC/TSMC16nm/28pin/Synopsys_FC/libs/arm_io_lib:PCORNER_18_18_NT_DR.timing

# source ./init_placement.tcl
source /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0/ndm/9m_2xa1xd3xe2z_utrdl/antenna_rules.tcl
source /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0/ndm/9m_2xa1xd3xe2z_utrdl/icc2_route_options.tcl
source /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0/ndm/9m_2xa1xd3xe2z_utrdl/icc2_rvi_mapping.tcl
source /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0/ndm/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_icc2_route_options.tcl
source /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0/ndm/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_icc2_routing_tracks.tcl

set_voltage -min 0.88 -corners default -object_list [get_supply_nets {VDD}] 0.72
set_voltage -min 0.0 -corners default -object_list [get_supply_nets {VSS}] 0.0

save_block
save_lib nanosoc_chip_pads.dlib
close_lib nanosoc_chip_pads.dlib
