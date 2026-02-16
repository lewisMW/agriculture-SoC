#-----------------------------------------------------------------------------
# NanoSoC Synopsys synthesis tcl file to be run with dc_shell
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

set rtlPath $env(SOCLABS_PROJECT_DIR)
set report_path $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/
set top_module nanosoc_chip_pads
set io_path /home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a
#supress_message = {ELAB-405}
#####
# Set search_path
#
# List locations where your standard cell libraries may be located
#
#####
set search_path [list . $search_path $env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/sdb/ $env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/db/ $env(SOCLABS_PROJECT_DIR)/memories/rf $env(SOCLABS_PROJECT_DIR)/memories/bootrom $io_path]
set search_path [concat $rtlPath $search_path]
######
# Set Target Library
#
# Set a default target library for Design Compiler to target when compiling a design
#
######
set target_library "sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.db rf_sp_hdf_ss_1p08v_1p08v_125c.db rom_via_ss_1p08v_1p08v_125c.db tpdn65lpnv2od3wc.db"

######
# Set Link Library
#
# Set a default link library for Design Compiler to target when compiling a design
#
######
set link_library "sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.db rf_sp_hdf_ss_1p08v_1p08v_125c.db rom_via_ss_1p08v_1p08v_125c.db tpdn65lpnv2od3wc.db"

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl
elaborate $top_module -lib WORK
current_design $top_module

# Link Design
link

read_sdc ../../constraints.sdc 

load_upf ../nanosoc_chip_pads.upf

set_voltage -object_list {VDD VDDACC VDD_VSS.power VDDACC_VSS.power TOP.primary.power ACCEL.primary.power} 1.08
set_voltage -object_list {VSS VDD_VSS.ground VDDACC_VSS.ground TOP.primary.ground ACCEL.primary.ground} 0.00

set_operating_conditions -library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c ss_typical_max_1p08v_125c

set_app_var compile_delete_unloaded_sequential_cells false
compile_ultra -gate_clock -scan 

set_scan_configuration -chain_count 2
set_dft_signal -view spec -type ScanDataIn -port DFT_SDI_1
set_dft_signal -view spec -type ScanDataIn -port DFT_SDI_2
set_dft_signal -view spec -type ScanDataOut -port DFT_SDO_1
set_dft_signal -view spec -type ScanDataOut -port DFT_SDO_2
set_dft_signal -view spec -type ScanEnable -port TEST -active_state 1
set_dft_signal -view existing_dft -type Reset -port NRST -active_state 0
set_scan_configuration -power_domain_mixing false
create_test_protocol -infer_clock -infer_asynch 
dft_drc
insert_dft

write -hierarchy -format verilog -output $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads.vm
write -hierarchy -format verilog -pg -output $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads.vp
write_scan_def -output $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads.def
write_test_protocol -output $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads_scan.stil 

redirect [format "%s%s%s" $report_path $top_module _area.rep] { report_area }
redirect -append [format "%s%s%s" $report_path $top_module _area.rep] { report_reference }
redirect [format "%s%s%s" $report_path $top_module _power.rep] { report_power }
redirect [format "%s%s%s" $report_path $top_module _scan_path.rep] { report_scan_path }
redirect [format "%s%s%s" $report_path $top_module _timing.rep] \
  { report_timing -path full -max_paths 100 -nets -transition_time -capacitance -significant_digits 3 -nosplit}

