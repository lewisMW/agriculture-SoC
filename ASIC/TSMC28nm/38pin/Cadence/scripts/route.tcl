
### Clock Net Spacing
#set_route_attributes -nets clk -preferred_extra_space_tracks 2 

### Multi Cut Via Effort 
set_db route_design_detail_use_multi_cut_via_effort medium

### Timing Driven Route
set_db route_design_with_timing_driven 1 

### SI Driven Route 
set_db route_design_with_si_driven 1 

### Route Design 
routeDesign -globalDetail

