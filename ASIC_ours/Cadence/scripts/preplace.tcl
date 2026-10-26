### Well taps. sky130_fd_sc_hd cells carry no n-well or substrate taps of their own,
### and this flow never placed any: Pegasus on the 23 Sep chip found no tap cell at all,
### nwell.4/nwell.ntap failing in every standard-cell row (~720k flat violations), and
### nothing guarding against latch-up. One sky130_fd_sc_hd__tapvpwrvgnd_1 at most every
### 14 um along each row (centre to centre), as OpenLane does for this library. They go
### in before placement (add_well_taps keeps them out of the macro halos) and are fixed.
add_well_taps -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cell_interval 14 -prefix WELLTAP
# their VPWR/VGND, as for every other standard cell (power_plan.tcl)
connect_global_net VDD -type pg_pin -pin_base_name VPWR -inst_base_name WELLTAP*
connect_global_net VSS -type pg_pin -pin_base_name VGND -inst_base_name WELLTAP*
puts "preplace.tcl: [llength [get_db insts -if {.base_cell.name == sky130_fd_sc_hd__tapvpwrvgnd_1}]] well taps"

set_db place_global_cong_effort high 
set_db place_global_timing_effort high 

### Uniform Cell Distribution and fill gap
# Innovus defaults this to false. Set true it spreads ~21k cells evenly across
# the 10.3 mm2 pad-limited core at 3.3% density: long wires, large clock skew,
# and a hold-buffer explosion. false cuts wirelength ~29% and improves congestion.
set_db place_global_uniform_density false
#set_db place_detail_legalization_inst_gap 2

### Placement Mode Config 
set_db place_design_floorplan_mode false 

### Timing Analysis Type 
set_db timing_analysis_type ocv

if {$DFT != 1} {
  #set_db place_global_ignore_scan true
}