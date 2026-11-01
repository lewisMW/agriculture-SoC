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

read_db ${block_name}_cts
source $env(SOCLABS_ASIC_FLOW_DIR)/Cadence/procs.tcl

source ../scripts/route_setup.tcl

### Route Design 
route_design -global_detail

report_intermediate_step 04_route $REPORT_DIR

## -- Setup repair BEFORE hold. Without it, hold optimisation is free to load
## -- setup-critical paths with delay buffers unopposed: measured -10.1 -> -52.9 ns
## -- WNS, +21.6k cells and 237k DRCs on the sky130 flow.
opt_design -post_route

# some drc violations esp shorts. auto reroute for a couple of times
# try to get rid of as many as possible
check_drc
delete_routes -regular_wire_with_drc
route_design -global_detail

opt_design -post_route

set_db route_with_eco 1
check_drc
delete_routes -regular_wire_with_drc
route_design -global_detail

opt_design -post_route
# TODO: use the fast timing for hold analysis? should be able to do mmmc
opt_design -post_route -hold

source ../scripts/filler.tcl
# https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_io/docs/user_guide.html
# sky130 IO cells already contain bond pads
# TODO check if this statement is correct?
# source ../scripts/place_bondpads.tcl

report_end_step 05_route_opt $REPORT_DIR

write_db ${block_name}_route

# reporting
report_power -out_file ../outputs/nanosoc_chip_pads_power.rpt -clock_network all -hierarchy all -sort { total }

exit

