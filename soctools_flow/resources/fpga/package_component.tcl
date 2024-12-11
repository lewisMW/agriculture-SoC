###-----------------------------------------------------------------------------
### Vivado Component Package TCL Script
### A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
###
### Contributors
###
### David Flynn (d.w.flynn@soton.ac.uk)
###
### Copyright � 2022, SoC Labs (www.soclabs.org)
###-----------------------------------------------------------------------------
#
# developed & tested using vivado_version 2021.1
#

#
# STEP#0: setup design sources and constraints
#

set component_lib $env(FPGA_COMPONENT_LIB)

# Read in TCL Filelist
source $env(FPGA_COMPONENT_FILELIST)

# Set Top-level
set_property top $env(FPGA_COMPONENT_TOP) [current_fileset]

#
# STEP#1: run synthesis, report utilization and timing estimates, write checkpoint design
#

update_compile_order -fileset sources_1

ipx::package_project -root_dir $component_lib -vendor $env(FPGA_VENDOR) -library user -taxonomy /UserIP -import_files -set_current false -force -force_update_compile_order

ipx::unload_core  $component_lib/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory  $component_lib  $component_lib/component.xml

update_compile_order -fileset sources_1
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
ipx::merge_project_changes -verbose files [ipx::current_core]

set_property core_revision $env(FPGA_CORE_REV) [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]

ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet -xrt [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project

update_ip_catalog
close_project
