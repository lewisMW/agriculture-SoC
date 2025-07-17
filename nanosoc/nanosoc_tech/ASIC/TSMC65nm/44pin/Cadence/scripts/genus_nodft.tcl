#-----------------------------------------------------------------------------
# NanoSoC gate synthesis script for Cadence Genus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: genus -f genus.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu 8
## -- Setup libraries -- ##
set_db init_lib_search_path "/home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/ $::env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/lib/ $::env(SOCLABS_PROJECT_DIR)/memories/rf_16k/ $::env(SOCLABS_PROJECT_DIR)/memories/rf_08k/ $::env(SOCLABS_PROJECT_DIR)/memories/bootrom/"
set BASE_LIB sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.lib
set RF_LIB rf_16k_ss_1p08v_1p08v_125c.lib
set RF_08K rf_08k_ss_1p08v_1p08v_125c.lib
set ROM_LIB rom_via_ss_1p08v_1p08v_125c.lib
set IO_PAD_DRIVER tpdn65lpnv2od3bc.lib
create_library_domain domain1
set_db [get_db library_domains domain1] .library "$BASE_LIB $RF_LIB $RF_08K $ROM_LIB $IO_PAD_DRIVER"
# set_dont_touch SDFF*
check_library > syn_lib_check.log

## -- Load power intent for top and accelerator power domains -- ##
read_power_intent -cpf -module nanosoc_chip_pads ../cpf/nanosoc.cpf

## -- Uncomment if you want to preserve hierarchy -- ##
#set_db auto_ungroup none
 
## -- Read in RTL and elaborate top level
source $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
read_hdl -define POWER_PINS $env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/nanosoc_chip_pads/tsmc65lp/nanosoc_chip_pads_44pin.v
elaborate nanosoc_chip_pads

# Preserve hierarchy for M0.
# set_db hinst:nanosoc_chip_pads/u_nanosoc_chip/u_system/u_ss_cpu/u_cpu_0/u_slcorem0_integration/u_cortexm0 .ungroup_ok false

## -- Apply power intent and check library and CPF -- ##
apply_power_intent
check_cpf -license lpgxl > syn_cpf_check.log
commit_power_intent
check_power_structure -license lpgxl > syn_pow_check.log

## -- Read constraints -- ##
read_sdc $::env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/constraints.sdc 


set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

syn_generic
syn_map

syn_opt

report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_noDFT_nanosoc_area_44pin.rep
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_noDFT_nanosoc_timing_44pin.rep
report_gates > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_noDFT_nanosoc_gates_44pin.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_noDFT_nanosoc_power_44pin.rep

write_hdl > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_noDFT/nanosoc_chip_pads_44pin.v
write_hdl -pg > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_noDFT/nanosoc_chip_pads_44pin.vp

write_sdf -timescale ns > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_noDFT/nanosoc_chip_pads_44pin.sdf

write_do_lec -revised_design $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_noDFT/nanosoc_chip_pads_44pin.v -no_lp -top nanosoc_chip_pads -logfile $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/ > lec.dofile  
