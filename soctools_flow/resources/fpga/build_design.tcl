###-----------------------------------------------------------------------------
### Build Design Viviado FPGA Script
### A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
###
### Contributors
###
### David Mapstone (d.a.mapstone@soton.ac.uk)
###
### Copyright  2023, SoC Labs (www.soclabs.org)
###-----------------------------------------------------------------------------
#
# Developed & Tested using vivado_version 2021.1
#

# Get Environmnet Variables from Makefile
set fpga_name $env(FPGA_NAME)
set xilinx_part $env(FPGA_PART)
set project_dir $env(FPGA_PROJECT_DIR)
set import_dir $env(FPGA_TARGET)
set target_tcl_dir $env(FPGA_TARGET_TCL)
set design_name $env(FPGA_DESIGN_NAME)
set wrapper_name $env(FPGA_WRAPPER_NAME)
set pinmap_file $env(FPGA_PINMAP)
set output_dir $env(FPGA_OUTPUT_DIR)
set implementation_dir $env(FPGA_IMP_DIR)

#
# STEP#1: setup design sources and constraints
#
set_part $xilinx_part
set_property TARGET_LANGUAGE Verilog [current_project]
set_property DEFAULT_LIB work [current_project]

set paths [list $implementation_dir]

# Set IP repository paths
set obj [get_filesets sources_1]
if { $obj != {} } {
   set_property "ip_repo_paths" "[file normalize $implementation_dir] " $obj
   # Rebuild user ip_repo's index before adding any source files
   update_ip_catalog -rebuild
}

report_ip_status

# #
# # STEP#2: create Block Diagram and add specific IO wrapper (and import matching pinmap.xdc)
# #
# # using script written out from GUI capture

create_bd_design $design_name

read_verilog $import_dir/$wrapper_name.v
source $target_tcl_dir/$design_name.tcl
create_root_design ""


add_files $pinmap_file

set_property top $wrapper_name [current_fileset]

# #
# # STEP#3: save in Project mode to complete flow
# #
save_project_as $fpga_name $project_dir -exclude_run_results -force

update_compile_order -fileset sources_1

# #
# # STEP#4: synthesize project
# #
set_property part $xilinx_part [get_runs synth_1]
launch_runs synth_1 -jobs 8

wait_on_run synth_1

# #
# # STEP#5: place and route project
# #
set_property part $xilinx_part [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream -jobs 8

wait_on_run impl_1

# #
# # STEP#6: export $design_name.bit and $design_name.hwh files for PYNQ
# #

write_hw_platform -fixed -include_bit -force -file $project_dir/$design_name.xsa

exit 0
