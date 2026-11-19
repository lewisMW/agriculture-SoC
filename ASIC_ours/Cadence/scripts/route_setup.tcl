
### Clock Net Spacing
set_route_attributes -nets clk -preferred_extra_space_tracks 2 

### Multi Cut Via Effort 
set_db route_design_detail_use_multi_cut_via_effort medium

### Timing Driven Route
set_db route_design_with_timing_driven 1 

### SI Driven Route 
set_db route_design_with_si_driven 1 

### Antenna: let NanoRoute repair process antennas, by changing layer and, where
### that is not enough, with a diode, on clock nets too (the clock tree's nets
### are kept to two layers, so they cannot be moved up). Without this the flow
### only reports them (route_drc.tcl, reports/antenna_06_signoff.rpt); the
### OpenFrame flow had 11 violations before it was given the same settings.
set_db route_design_detail_fix_antenna true
set_db route_design_antenna_diode_insertion true
set_db route_design_antenna_cell_name {sky130_fd_sc_hd__diode_2}
set_db route_design_diode_insertion_for_clock_nets true
