# Place and route setup script for Cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: innovus -stylus -f 2_pnr_setup.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
source ../scripts/config.tcl

set_multi_cpu_usage -local_cpu 8
puts "Starting CTS Flow ..."

read_db $block_name
source $env(SOCLABS_ASIC_FLOW_DIR)/Cadence/procs.tcl

source ../scripts/route_setup.tcl

### Route Design 
route_design -global_detail

report_intermediate_step 04_route $REPORT_DIR

## -- Setup repair BEFORE hold. Without it, hold optimisation is free to load
## -- setup-critical paths with delay buffers unopposed: measured -10.1 -> -52.9 ns
## -- WNS, +21.6k cells and 237k DRCs on the sky130 flow.
opt_design -post_route
report_intermediate_step 04b_route_setupopt $REPORT_DIR

opt_design -post_route -hold

report_end_step 05_route_opt $REPORT_DIR

write_db $block_name

source ../scripts/filler.tcl
## -- Not every technology ships a place_bondpads.tcl (sky130 does not).
if {[file exists ../scripts/place_bondpads.tcl]} {
    source ../scripts/place_bondpads.tcl
} else {
    puts "NOTE: no ../scripts/place_bondpads.tcl for this technology - skipping."
}


exit

