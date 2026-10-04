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

opt_design -post_route -hold

report_end_step 05_route_opt $REPORT_DIR

write_db $block_name

source ../scripts/filler.tcl
source ../scripts/place_bondpads.tcl


exit

