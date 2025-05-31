set_db init_lib_search_path "/home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/ $::env(PHYS_IP)/arm/tsmc/cln65lp/sc9_base_rvt/r0p0/lib/ $::env(SOCLABS_PROJECT_DIR)/memories/rf_08k/ $::env(SOCLABS_PROJECT_DIR)/memories/rf_16k/ $::env(SOCLABS_PROJECT_DIR)/memories/bootrom/"
set BASE_LIB sc9_cln65lp_base_rvt_ss_typical_max_1p08v_125c.lib
set RF_16K_LIB rf_16k_ss_1p08v_1p08v_125c.lib
set RF_08K_LIB rf_08k_ss_1p08v_1p08v_125c.lib
set ROM_LIB rom_via_ss_1p08v_1p08v_125c.lib
set IO_PAD_DRIVER tpdn65lpnv2od3bc.lib
create_library_domain domain1
set_db [get_db library_domains domain1] .library "$BASE_LIB $RF_16K_LIB $RF_08K_LIB $ROM_LIB $IO_PAD_DRIVER"

read_power_intent -cpf -module nanosoc_chip_pads ../cpf/nanosoc.cpf

source $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
read_hdl -define POWER_PINS $env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/nanosoc_chip_pads/tsmc65lp/nanosoc_chip_pads_28pin.v
elaborate nanosoc_chip_pads

apply_power_intent
check_library > lib_check.log

check_cpf 

commit_power_intent
check_power_structure -license lpgxl

read_sdc $::env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/constraints.sdc 

#set_db dft_scan_style muxed_scan
#set_db design:nanosoc_chip_pads .dft_min_number_of_scan_chains 1

#read_dft_abstract_model nanosoc_dft_abstract_model
#define_test_signal -name TEST  -active high -function test_mode -index 0 TEST
#define_test_signal -name SWDCK  -active high -function scan_clock -index 0 SWDCK
#define_test_signal -name NRST  -active low -function async_set_reset -index 0 NRST
#define_test_signal -name SWDIO  -active high -function shift_enable -default -index 0 SWDIO
#define_test_signal -name CLK  -active high -function test_clock -index 0 CLK

#define_scan_chain -name chain_ACCEL -sdi DFT_SDI_1 -sdo DFT_SDO_1 -shared_output
#define_scan_chain -name chain_TOP -sdi DFT_SDI_2 -sdo DFT_SDO_2  -shared_output


#check_dft_rules
#fix_dft_violations -test_control TEST -async_reset -add_observe_scan -scan_clock_pin SWDCK


set_db syn_generic_effort high
set_db syn_map_effort high

syn_generic
syn_map

#convert_to_scan

#connect_scan_chains -chains chain_ACCEL -power_domain ACCEL -incremental
#connect_scan_chains -chains chain_TOP -power_domain TOP -incremental

syn_opt

report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_area_28pin.rep
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_timing_28pin.rep
report_gates > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_gates_28pin.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/syn_nanosoc_power_28pin.rep

write_hdl > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_28pin.v
write_hdl -pg > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_28pins.vp

write_sdf -timescale ns > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_28pin.sdf

#report_scan_chains > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_chains.rep
#report_scan_setup > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_setup.rep
#report_scan_registers > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_scan_registers.rep
#write_dft_abstract_model > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_dft_abstract_model

#write_dft_atpg_other_vendor -mentor > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/dft/nanosoc_atpg

#write_scandef > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads.def

