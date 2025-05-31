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

# Paths to librarys 
# Edit this
set TSMC_28NM_PDK_PATH          /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28
set standard_cell_base_path     /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_base_svt_c35/r2p0

set IO_PAD_DRIVER_DIR $TSMC_28NM_PDK_PATH/CMOS/HPC+/IO1.8V/iolib/STAGGERED/tphn28hpcpgv18_170d_FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hpcpgv18_170a
set BASE_LIB_DIR        $standard_cell_base_path/lib

# Don't touch these
set SRAM_16K_DIR $::env(SOCLABS_PROJECT_DIR)/memories/sram_16k/
set ROM_DIR $::env(SOCLABS_PROJECT_DIR)/memories/bootrom/


set_db init_lib_search_path "$IO_PAD_DRIVER_DIR $BASE_LIB_DIR $SRAM_16K_DIR $ROM_DIR"
set BASE_LIB sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.lib

set SRAM_LIB        sram_16k_ssg_cworstt_0p81v_0p81v_125c.lib
set ROM_LIB         rom_via_ssg_cworstt_0p81v_0p81v_125c.lib
set IO_PAD_DRIVER   tphn28hpcpgv18ssg0p81v1p62v125c.lib
create_library_domain domain1
set_db [get_db library_domains domain1] .library "$BASE_LIB  $SRAM_LIB  $ROM_LIB $IO_PAD_DRIVER"
# set_dont_touch SDFF*
check_library > syn_lib_check.log

## -- Load power intent for top and accelerator power domains -- ##
read_power_intent -cpf -version 1.1 -module nanosoc_chip_pads ../inputs/nanosoc.cpf

## -- Uncomment if you want to preserve hierarchy -- ##
#set_db auto_ungroup none
 
## -- Read in RTL and elaborate top level
source $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
read_hdl -define POWER_PINS $env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/nanosoc_chip_pads/tsmc28hpcp/nanosoc_chip_pads_38pin.v
elaborate nanosoc_chip_pads

# Preserve hierarchy for M0.
# set_db hinst:nanosoc_chip_pads/u_nanosoc_chip/u_system/u_ss_cpu/u_cpu_0/u_slcorem0_integration/u_cortexm0 .ungroup_ok false

## -- Apply power intent and check library and CPF -- ##
apply_power_intent
#check_cpf -license lpgxl -detail > syn_cpf_check.log
commit_power_intent
check_power_structure -license lpgxl > syn_pow_check.log

## -- Read constraints -- ##
read_sdc $::env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/TSMC28nm/constraints.sdc 


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

report_area > ../reports/syn_nanosoc_area_38pin.rep
report_timing > ../reports/syn_nanosoc_timing_38pin.rep
report_gates > ../reports/syn_nanosoc_gates_38pin.rep
report_power > ../reports/syn_nanosoc_power_38pin.rep

write_hdl > ../outputs/nanosoc_chip_pads_38pin.v
write_hdl -pg > ../outputs/nanosoc_chip_pads_38pin.vp

write_sdf -timescale ns > ../outputs/nanosoc_chip_pads_38pin.sdf

write_do_lec -revised_design ../outputs/nanosoc_chip_pads_38pin.v -no_lp -top nanosoc_chip_pads -logfile ../outputs/ > lec.dofile  

write_power_intent -cpf -design nanosoc_chip_pads -base_name ../cpf/nanosoc_syn_out


report_scan_chains > ../outputs/nanosoc_scan_chains_38pin.rep
report_scan_setup > ../outputs/nanosoc_scan_setup_38pin.rep
report_scan_registers > ../outputs/nanosoc_scan_registers_38pin.rep
write_dft_abstract_model > ../outputs/nanosoc_dft_abstract_model_38pin
write_dft_atpg_other_vendor -mentor > ../outputs/nanosoc_atpg_38pin

write_scandef > ../outputs/nanosoc_chip_pads_38pin.def

