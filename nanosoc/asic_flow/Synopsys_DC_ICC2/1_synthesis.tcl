#-----------------------------------------------------------------------------
# ASIC Flow Synthesis
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: dc_shell -f 1_design_setup.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
set_host_options -max_cores 16
source ../scripts/config.tcl

#supress_message = {ELAB-405}
#####
# Set search_path
#
# List locations where your standard cell libraries may be located
#
#####
set search_path [list . $search_path $lib_search_path_list]
######
# Set Target Library
#
# Set a default target library for Design Compiler to target when compiling a design
#
######
set target_library $syn_lib_list

######
# Set Link Library
#
# Set a default link library for Design Compiler to target when compiling a design
#
######
set link_library $syn_lib_list

source $hdl_file_list
analyze -format verilog -lib WORK -define POWER_PINS $top_level_hdl 
elaborate $top_module -lib WORK
current_design $top_module

# Link Design
link

read_sdc ../inputs/constraints.sdc 

load_upf ../inputs/${top_module}.upf

set_voltage -object_list [get_supply_nets VDD*] 1.08
set_voltage -object_list [get_supply_nets VDDIO] 2.97

set_voltage -object_list [get_supply_nets VSS] 0.00

set_operating_conditions -library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c ss_typical_max_1p08v_125c

compile_ultra -gate_clock  

# set_scan_configuration -chain_count 2
# set_dft_signal -view spec -type ScanDataIn -port DFT_SDI_1
# set_dft_signal -view spec -type ScanDataIn -port DFT_SDI_2
# set_dft_signal -view spec -type ScanDataOut -port DFT_SDO_1
# set_dft_signal -view spec -type ScanDataOut -port DFT_SDO_2
# set_dft_signal -view spec -type ScanEnable -port TEST -active_state 1
# set_dft_signal -view existing_dft -type Reset -port NRST -active_state 0
# set_scan_configuration -power_domain_mixing false
# create_test_protocol -infer_clock -infer_asynch 
# dft_drc
# insert_dft
change_names -rules verilog

write -hierarchy -format verilog -output $OUT_DIR/${top_module}.vm
write -hierarchy -format verilog -pg -output $OUT_DIR/${top_module}.vp
save_upf $OUT_DIR/nanosoc_chip_pads_imp.upf

redirect -tee -file ${REPORT_DIR}/${top_module}_area.rep { report_area }
redirect -tee -file ${REPORT_DIR}/${top_module}_reference.rep { report_reference }
redirect -tee -file ${REPORT_DIR}/${top_module}_power.rep { report_power }
redirect -tee -file ${REPORT_DIR}/${top_module}_timing_max.rep \
  { report_timing -delay_type max -path full -max_paths 100 -nets -transition_time -capacitance -significant_digits 3 -nosplit}

redirect -tee -file ${REPORT_DIR}/${top_module}_timing_min.rep \
  { report_timing -delay_type min -path full -max_paths 100 -nets -transition_time -capacitance -significant_digits 3 -nosplit}

write nanosoc_chip_pads

exit