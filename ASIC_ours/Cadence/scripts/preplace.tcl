set_db place_global_cong_effort auto 
set_db place_global_timing_effort high 

### Uniform Cell Distribution and fill gap
# Innovus defaults this to false. Set true it spreads ~21k cells evenly across
# the 10.3 mm2 pad-limited core at 3.3% density: long wires, large clock skew,
# and a hold-buffer explosion. false cuts wirelength ~29% and improves congestion.
set_db place_global_uniform_density false
set_db place_detail_legalization_inst_gap 2

### Placement Mode Config 
set_db place_design_floorplan_mode false 

### Timing Analysis Type 
set_db timing_analysis_type ocv

if {$DFT != 1} {
  #set_db place_global_ignore_scan true
  #set_db place_global_scan_route false
}