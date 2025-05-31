############################################ 
# Script : Placement 
# Date : 26th April 2025 
# Authors : Srimanth Tenneti 
#           Daniel Newbrook
############################################ 

### Congestion and Timing Setting 
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
addTieHiLo -cell {TIELO_X1M_A12PP140ZTS_C35 TIEHI_X1M_A12PP140ZTS_C35} -prefix LTIE -powerDomain TOP -excludePin ../scripts/tieoff_exclude
addTieHiLo -cell {TIELO_X1M_A12PP140ZTS_C35 TIEHI_X1M_A12PP140ZTS_C35} -prefix LTIE -powerDomain ACCEL -excludePin ../scripts/tieoff_exclude
