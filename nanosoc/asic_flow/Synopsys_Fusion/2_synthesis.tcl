#-----------------------------------------------------------------------------
# ASIC Flow synthesis
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fc_shell -f 2_synthesis.tcl
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

set_qor_strategy -stage synthesis -metric timing -high_effort_timing

set_svf $OUT_DIR/synth.svf

set_stage -step synthesis

redirect -tee -file ../logs/compile1_logic_opto.log {compile_fusion -to logic_opto}
redirect -tee -file $REPORT_DIR/transformed_regs.rep {report_transformed_registers}
redirect -tee -file $REPORT_DIR/ungrouped.rep {report_ungroup}

redirect -tee -file ../logs/compile2_to_initial_opto.log {compile_fusion -from initial_place -to initial_opto}

report_intermediate_step 02a_initial_opto $REPORT_DIR
save_block 

set_stage -step compile_place
redirect -tee -file ../logs/compile3_final_place.log {compile_fusion -from final_place}

add_tie_cells -tie_high_lib_cells [get_lib_cells $tie_hi_cells] -tie_low_lib_cells [get_lib_cells $tie_lo_cells]
report_end_step 02b_compile_fusion $REPORT_DIR

current_scenario typical_scenario
analyze_power_plan -nets [get_nets -design [current_block] $PG_NETS] -analyze_power -voltage $CORE_VOLTAGE


save_block
save_lib ${lib_name}.dlib
save_block -as ${lib_name}.dlib:$block_name/compile.design
exit
