############################################ 
# Script : Placement 
# Date : May 24 2024 
# Author : Srimanth Tenneti 
############################################ 

### Congestion and Timing Setting 
set_db design_process_node 65
set_db place_global_cong_effort auto 
set_db place_global_timing_effort high 

### Uniform Cell Distribution and fill gap
set_db place_global_uniform_density true
set_db place_detail_legalization_inst_gap 2

### Placement Mode Config 
set_db place_design_floorplan_mode false 
place_design

### Delay Calculation 
write_sdf design.sdf -ideal_clock_network 
set_db add_tieoffs_max_fanout 10
add_tieoffs -lib_cell {TIELO_X1M_A12TR TIEHI_X1M_A12TR} -prefix LTIE -power_domain TOP -exclude_pin tieoff_exclude
add_tieoffs -lib_cell {TIELO_X1M_A12TR TIEHI_X1M_A12TR} -prefix LTIE -power_domain ACCEL -exclude_pin tieoff_exclude
