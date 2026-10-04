#-----------------------------------------------------------------------------
# ASIC Flow CTS + clock opt
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fc_shell -f 3_clock.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

source ../scripts/config.tcl

open_lib ${lib_name}.dlib/
open_block $block_name

set_host_options -max_cores 16 -num_processes 16
source ../scripts/setup.tcl
source $env(SOCLABS_ASIC_FLOW_DIR)/Synopsys_Fusion/procs.tcl

# Clock opt cts
set_stage -step cts

redirect -tee -file ../logs/clock_opt_build_clock.log {clock_opt -from build_clock -to build_clock}
report_intermediate_step 03a_CTS_build $REPORT_DIR
save_block

redirect -tee -file ../logs/clock_opt_route_clock.log {clock_opt -from route_clock -to route_clock}
report_intermediate_step 03b_CTS_route $REPORT_DIR
save_block

set_app_options -name time.aocvm_enable_analysis -value true ;
set_stage -step post_cts_opto
redirect -tee -file ../logs/clock_opt_final_optp.log {clock_opt -from final_opto -to final_opto}
report_end_step 03c_CTS_final $REPORT_DIR

redirect -tee -file $LOG_DIR/no_hold_cells.log  {sizeof_collection [get_cells -physical_context *_h_inst*]}

source ../scripts/post_clock_eco.tcl

current_scenario typical_scenario
analyze_power_plan -nets [get_nets -design [current_block] {VDD VDDACC VSS}] -analyze_power -voltage 0.9

change_names -rules verilog -hierarchy

write_verilog -top_module_first -hierarchy all \
	-exclude {leaf_module_declarations empty_modules corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells pg_netlist spare_cells supply_statements} $OUT_DIR/${block_name}_gate.v
write_verilog -top_module_first -hierarchy all \
	-exclude {leaf_module_declarations empty_modules corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells spare_cells supply_statements} $OUT_DIR/${block_name}_gate_power.v

write_sdf -corner typical_corner $OUT_DIR/${block_name}_gate_typical.sdf
write_sdf -corner setup_corner $OUT_DIR/${block_name}_gate_setup.sdf
write_sdf -corner hold_corner_ffgnp $OUT_DIR/${block_name}_gate_hold.sdf

set_svf -off
	
save_block
save_lib ${lib_name}.dlib
save_block -as ${lib_name}.dlib:$block_name/cts.design

exit