#-----------------------------------------------------------------------------
# ASIC Flow design setup
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fc_shell -f 1_design_setup.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

# Import verilog and setup libraries
set_host_options -max_cores 16 -num_processes 16

source ../scripts/config.tcl

#Create the design library 
create_lib ${lib_name}.dlib -technology $tech_file 
foreach lib_path $lib_path_list {
    set_ref_libs -add $lib_path
}

# Report each library cell summary to logs directory
foreach lib $lib_list {
    redirect -tee -file ../logs/lib_${lib}_summary.log {report_lib -cell_summary $lib}
}

# Read in Verilog for nanosoc and nanosoc_chip_pads
redirect -tee -file ../logs/analyze_flist.log {source $file_tcl_list}
redirect -tee -file ../logs/analyze_top_file.log {analyze -format verilog $top_level_verilog}

# Elaborate top level and set top module
redirect -tee -file ../logs/elaborate.log {elaborate $block_name}
redirect -tee -file ../logs/set_top_module.log {set_top_module $block_name}


saif_map -start

# Load floorplan for implementation
source ../scripts/floorplan.tcl
 
# Load setup script
source ../scripts/setup.tcl

# Load power plan for implementation
source ../scripts/power_plan.tcl

save_block 

#set timing_use_enhanced_capacitance_modeling true
#set_app_var compile_clock_gating_through_hierarchy true
#set timing_separate_clock_gating_group TRUE

# Load PVT library setup for implementation libraries
redirect -tee -file ../logs/pvt_setup.log {source ../scripts/pvt_setup.tcl}

# Set lib cell purporses
source ../scripts/lib_cells.tcl

# Load routing rules for particular technology
source ../scripts/routing_rules.tcl 


current_scenario typical_scenario
read_saif -report ../inputs/waves.saif -strip_path nanosoc_tb.u_nanosoc_chip_pads 

redirect -tee -file $REPORT_DIR/initial_power_plan.rep {analyze_power_plan -nets [get_nets -design [current_block] {VDD VDDACC VSS}] -power_budget 10 -voltage 0.9}

redirect -tee -file ../logs/precompile_checks.log {compile_fusion -check_only}

save_block 
save_lib nanosoc_chip_pads.dlib

save_block -as nanosoc_chip_pads.dlib:nanosoc_chip_pads/init.design

exit