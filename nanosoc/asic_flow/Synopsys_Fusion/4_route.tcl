#-----------------------------------------------------------------------------
# ASIC Flow design setup
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fc_shell -f 4_route.tcl
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

set_stage -step route
redirect -tee -file ../logs/route_auto.log {route_auto}

report_intermediate_step 04a_route_auto $REPORT_DIR
save_block 

source ../scripts/route_opt.tcl

set_stage -step post_route 
redirect -tee -file ../logs/route_opt.log {route_opt}
report_end_step 04b_route_opt $REPORT_DIR

create_stdcell_fillers -lib_cells $fill_cells

save_block
save_lib ${lib_name}.dlib

exit