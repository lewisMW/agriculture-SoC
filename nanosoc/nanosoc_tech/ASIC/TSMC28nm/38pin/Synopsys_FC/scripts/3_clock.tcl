open_lib nanosoc_chip_pads.dlib/
open_block nanosoc_chip_pads

set_host_options -max_cores 16 -num_processes 16
source ../scripts/setup.tcl

# Clock opt cts
set_stage -step cts

clock_opt -from build_clock -to build_clock
report_intermediate_step 03a_CTS_build $REPORT_DIR
save_block

clock_opt -from route_clock -to route_clock
report_intermediate_step 03b_CTS_route $REPORT_DIR
save_block

set_app_options -name time.aocvm_enable_analysis -value true ;
set_stage -step post_cts_opto
clock_opt -from final_opto -to final_opto
report_end_step 03c_CTS_final $REPORT_DIR

current_scenario typical_scenario
analyze_power_plan -nets [get_nets -design [current_block] {VDD VDDACC VSS}] -analyze_power -voltage 0.9

save_block
save_lib nanosoc_chip_pads.dlib

save_block -as nanosoc_chip_pads.dlib:nanosoc_chip_pads/cts.design

exit