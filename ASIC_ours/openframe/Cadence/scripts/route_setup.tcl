source ../scripts/dont_use.tcl

### Hold margin. Hold was optimised to exactly zero, and the routing that follows
### the last optimisation pass moved the worst path a few ps either way: four runs
### ended at -7, -5, -3 and +4 ps. 50 ps of target slack keeps the result positive.
set_db opt_hold_target_slack 0.05

### check_drc: the frame's pins reach 2 um beyond the die edge by design (template
### DEF), which check_drc reports as ~880 "Out Of Die" shorts
set_db check_drc_disable_rules out_of_die

### Clock Net Spacing: the system clock's root net (the frame's gpio_in[38] here)
set _clk_root [get_db [get_db ports {gpio_in[38]}] .net.name]
set_route_attributes -nets $_clk_root -preferred_extra_space_tracks 2

### Multi Cut Via Effort 
set_db route_design_detail_use_multi_cut_via_effort medium

### Timing Driven Route
set_db route_design_with_timing_driven 1 

### SI Driven Route 
set_db route_design_with_si_driven 1 

### Antenna: let NanoRoute add a diode where changing layers is not enough. A
### build without this had 11 process-antenna violations (check_process_antenna),
### seven of them on the wrapper's own input pins: a long met2 run from the pin to
### the first gate, with nothing but that gate on it inside the wrapper.
set_db route_design_detail_fix_antenna true
set_db route_design_antenna_diode_insertion true
set_db route_design_antenna_cell_name {sky130_fd_sc_hd__diode_2}
