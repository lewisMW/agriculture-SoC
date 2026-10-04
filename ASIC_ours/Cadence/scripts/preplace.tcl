set_db place_global_cong_effort auto 
set_db place_global_timing_effort high 

### Uniform Cell Distribution and fill gap
set_db place_global_uniform_density true
set_db place_detail_legalization_inst_gap 2

### Placement Mode Config 
set_db place_design_floorplan_mode false 

### Timing Analysis Type 
set_db timing_analysis_type ocv

if {$DFT != 1} {
  #set_db place_global_ignore_scan true
  #set_db place_global_scan_route false
}