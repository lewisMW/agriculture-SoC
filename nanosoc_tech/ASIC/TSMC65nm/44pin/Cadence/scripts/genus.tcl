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


set_db dft_scan_style muxed_scan
set_db design:nanosoc_chip_pads .dft_min_number_of_scan_chains 4
set_db hinst:nanosoc_chip_pads/u_nanosoc_chip_cfg .dft_dont_scan true
define_test_signal -name TEST  -active high -shared_input -hookup_pin u_nanosoc_chip/test_i -function test_mode -index 0 TEST
define_test_signal -name CLK  -active high -hookup_pin u_nanosoc_chip/clk_i -function test_clock -index 0 CLK
define_test_signal -name NRST  -active low -hookup_pin u_nanosoc_chip/nrst_i -function async_set_reset -index 0 NRST
define_test_signal -name SE  -active high -shared_input -hookup_pin u_nanosoc_chip_cfg/soc_scan_enable  -function shift_enable -default -index 0 SE
define_scan_chain -name chain_ACCEL -sdi P0[0] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[0] -sdo P1[0] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[0] -shared_output -shared_input
define_scan_chain -name chain_TOP_1 -sdi P0[1] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[1] -sdo P1[1] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[1] -shared_output -shared_input
define_scan_chain -name chain_TOP_2 -sdi P0[2] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[2] -sdo P1[2] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[2] -shared_output -shared_input
define_scan_chain -name chain_TOP_3 -sdi P0[3] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[3] -sdo P1[3] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[3] -shared_output -shared_input

fix_pad_cfg -mode input -test_control TEST P0[0]
fix_pad_cfg -mode input -test_control TEST P0[1]
fix_pad_cfg -mode input -test_control TEST P0[2]
fix_pad_cfg -mode input -test_control TEST P0[3]

fix_pad_cfg -mode output -test_control TEST P1[0]
fix_pad_cfg -mode output -test_control TEST P1[1]
fix_pad_cfg -mode output -test_control TEST P1[2]
fix_pad_cfg -mode output -test_control TEST P1[3]

check_dft_rules
fix_dft_violations -test_control TEST -async_reset -add_observe_scan -scan_clock_pin CLK
fix_dft_violations -test_control TEST -async_set

set_db syn_generic_effort high
set_db syn_map_effort high

syn_generic
syn_map

convert_to_scan
connect_scan_chains

syn_opt

report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_area_44pin.rep
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_timing_44pin.rep
report_gates > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_gates_44pin.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_power_44pin.rep

write_hdl > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_44pin.v
write_hdl -pg > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_44pin.vp

write_sdf -timescale ns > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_44pin.sdf

write_do_lec -revised_design $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_44pin.v -no_lp -top nanosoc_chip_pads -logfile $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/ > lec.dofile  

report_scan_chains > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_chains_44pin.rep
report_scan_setup > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_setup_44pin.rep
report_scan_registers > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_registers_44pin.rep
write_dft_abstract_model > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_dft_abstract_model_44pin
write_dft_atpg_other_vendor -mentor > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_atpg_44pin
write_scandef > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_44pin.def

