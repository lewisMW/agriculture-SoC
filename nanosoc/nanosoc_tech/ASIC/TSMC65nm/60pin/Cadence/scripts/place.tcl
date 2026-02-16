############################################ 
# Script : Placement 
# Date : May 24 2024 
# Author : Srimanth Tenneti 
############################################ 

### Congestion and Timing Setting 
set_db design_process_node 65
set_db place_global_cong_effort auto 
set_db place_global_timing_effort high 

### Uniform Cell Distribution 

set_db place_global_uniform_density true

### Placement Mode Config 
set_db place_design_floorplan_mode false 
place_opt_design 

### Delay Calculation 
write_sdf design.sdf -ideal_clock_network 
