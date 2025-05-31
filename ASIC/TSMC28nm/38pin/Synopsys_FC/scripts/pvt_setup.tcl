remove_modes -all
remove_corners -all
remove_scenarios -all

set TLU_cbest $TLU_dir/cbest.tluplus
set TLU_cbest_T $TLU_dir/cbest_T.tluplus
set TLU_cworst_T $TLU_dir/cworst_T.tluplus
set TLU_cworst $TLU_dir/cworst.tluplus
set TLU_rcbest_T $TLU_dir/rcbest_T.tluplus
set TLU_rcbest $TLU_dir/rcbest.tluplus
set TLU_rcworst_T $TLU_dir/rcworst_T.tluplus
set TLU_rcworst $TLU_dir/rcworst.tluplus
set TLU_typical $TLU_dir/typical.tluplus
set TLU_map $TLU_dir/tluplus.map

read_parasitic_tech -name cbest -tlup $TLU_cbest -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name cbest_T -tlup $TLU_cbest_T -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name cworst_T -tlup $TLU_cworst_T -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name cworst -tlup $TLU_cworst -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcbest_T -tlup $TLU_rcbest_T -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcbest -tlup $TLU_rcbest -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcworst_T -tlup $TLU_rcworst_T -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcworst -tlup $TLU_rcworst -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name typical -tlup $TLU_typical -layermap $TLU_map -sanity_check advanced

set_technology -node 28

## Setup scenarios as below
create_mode hold_mode_ffgnp
create_corner hold_corner_ffgnp
create_scenario -name hold_scenario_ffgnp -mode hold_mode_ffgnp -corner hold_corner_ffgnp
set_scenario_status hold_scenario_ffgnp -none -setup false -hold true -leakage_power true -dynamic_power false -max_transition true -max_capacitance false -min_capacitance true -active true

current_corner hold_corner_ffgnp
read_sdc ../../../constraints_hold_ffg.sdc

create_mode hold_mode_ssgnp
create_corner hold_corner_ssgnp
create_scenario -name hold_scenario_ssgnp -mode hold_mode_ssgnp -corner hold_corner_ssgnp 
set_scenario_status hold_scenario_ssgnp -none -setup false -hold true -leakage_power true -dynamic_power false -max_transition true -max_capacitance false -min_capacitance true -active true

current_corner hold_corner_ssgnp
read_sdc ../../../constraints_hold_ssg.sdc


create_mode setup_mode
create_corner setup_corner
create_scenario -name setup_scenario -mode setup_mode -corner setup_corner
set_scenario_status setup_scenario -none -setup true -hold false -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true

current_corner setup_corner 
read_sdc ../../../constraints_setup.sdc

create_mode em_mode
create_corner em_corner
create_scenario -name em_scenario -mode em_mode -corner em_corner
set_scenario_status em_scenario -none -setup false -hold false -leakage_power false -dynamic_power false -max_transition false -max_capacitance false -min_capacitance false -cell_em false -signal_em true -active true 

current_corner em_corner 
read_sdc ../../../constraints_hold_ffg.sdc

create_mode max_tran_mode
create_corner max_tran_corner
create_scenario -name max_tran_scenario -mode max_tran_mode -corner max_tran_corner
set_scenario_status max_tran_scenario -none -setup false -hold false -leakage_power false -dynamic_power false -max_transition true -max_capacitance false -min_capacitance false -active true 

current_corner max_tran_corner 
read_sdc ../../../constraints_setup.sdc

create_mode typical_mode
create_corner typical_corner
create_scenario -name typical_scenario -mode typical_mode -corner typical_corner
set_scenario_status typical_scenario -none -setup true -hold true -leakage_power true -dynamic_power true -max_transition false -max_capacitance false -min_capacitance false -active true

current_corner typical_corner
read_sdc ../../../constraints_typical.sdc

## hold - FFGNP V=+10% T=-40 and 125, parasitics cworst cbest rcworst rcbest
#         SSSGNP V=-10%, T=-40 and 125, parasitics cworst and rcworst
current_corner hold_corner_ffgnp
set_parasitic_parameters -early_spec cbest -early_temperature 125 -late_spec cworst -late_temperature -40 -library nanosoc_chip_pads.dlib
set_operating_conditions -max_library cln28ht_pmk -max ffg_cbestt_min_0p99v_m40c -min_library cln28ht_pmk -min ffg_cbestt_min_0p99v_125c
set_operating_conditions -max_library cln28ht_hpk -max ffg_cbestt_min_0p99v_m40c -min_library cln28ht_hpk -min ffg_cbestt_min_0p99v_125c
#set_operating_conditions -max_library cln28ht_ret -max ffg_cbestt_min_0p99v_125c -min_library cln28ht_ret -min ffg_cbestt_min_0p99v_125c
set_operating_conditions -max_library sram_16k -max ffg_cbestt_0p99v_0p99v_m40c -min_library sram_16k -min ffg_cbestt_0p99v_0p99v_125c
set_operating_conditions -max_library rom_via -max ffg_cbestt_0p99v_0p99v_m40c -min_library rom_via -min ffg_cbestt_0p99v_0p99v_125c
set_operating_conditions -max_library io_lib -max ffg0p99v1p98vm40c -min_library io_lib -min ffg0p99v1p98v125c
set_operating_conditions -max_library cln28ht -max ffg_cbestt_min_0p99v_m40c -min_library cln28ht -min ffg_cbestt_min_0p99v_125c
set_temperature -40 -min 125 -corners hold_corner_ffgnp
set_voltage 0.99 -min 0.99 -corners hold_corner_ffgnp

set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {VDD}] 0.99
set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {VDDACC}] 0.99
set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {AVDDHV}] 1.98
set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {AVDD}] 0.99
set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners hold_corner_ffgnp -object_list [get_supply_nets {AGND}] 0.0


current_corner hold_corner_ssgnp
set_parasitic_parameters -early_spec cworst -early_temperature 125 -late_spec rcworst -late_temperature -40 -library nanosoc_chip_pads.dlib
set_operating_conditions -max_library cln28ht_pmk -max ssg_cworstt_max_0p81v_m40c -min_library cln28ht_pmk -min ssg_cworstt_max_0p81v_125c
set_operating_conditions -max_library cln28ht_hpk -max ssg_cworstt_max_0p81v_m40c -min_library cln28ht_hpk -min ssg_cworstt_max_0p81v_125c
#set_operating_conditions -max_library cln28ht_ret -max ssg_cworstt_max_0p81v_m40c -min_library cln28ht_ret -min ssg_cworstt_max_0p81v_125c
set_operating_conditions -max_library sram_16k -max ssg_cworstt_0p81v_0p81v_m40c -min_library sram_16k -min ssg_cworstt_0p81v_0p81v_125c
set_operating_conditions -max_library rom_via -max ssg_cworstt_0p81v_0p81v_m40c -min_library rom_via -min ssg_cworstt_0p81v_0p81v_125c
set_operating_conditions -max_library io_lib -max ssg0p81v1p62vm40c -min_library io_lib -min ssg0p81v1p62v125c
set_operating_conditions -max_library cln28ht -max ssg_cworstt_max_0p81v_m40c -min_library cln28ht -min ssg_cworstt_max_0p81v_125c
set_temperature -40 -min 125 -corners hold_corner_ssgnp
set_voltage 0.81 -min 0.81 -corners hold_corner_ssgnp

set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {VDD}] 0.81
set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {VDDACC}] 0.81
set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {AVDDHV}] 1.62
set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {AVDD}] 0.81
set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners hold_corner_ssgnp -object_list [get_supply_nets {AGND}] 0.0


## setup SSGNP V=-10%, T=-40 parasitics cworst_t rcworst_t
#        TT V=-10%, T=85C parasitics cworst_t rcworst_t
#set_parasitic_parameters -early_spec cworst_T -early_temperature -40 -late_spec rcworst_T -late_temperature 25 -library nanosoc_chip_pads.dlib
#set_operating_conditions -max_library cln28ht -max ssg_cworstt_max_0p81v_125c -min_library cln28ht -min tt_ctypical_max_0p90v_25c
#set_temperature -40 -min 25 -corners setup_corner
#set_voltage 0.81 -corners setup_corner
current_corner setup_corner
set_parasitic_parameters -early_spec cworst_T -early_temperature -40 -late_spec rcworst_T -late_temperature -40 -library nanosoc_chip_pads.dlib

set_operating_conditions -library cln28ht_pmk ssg_cworstt_max_0p81v_m40c
set_operating_conditions -library cln28ht_hpk ssg_cworstt_max_0p81v_m40c 
#set_operating_conditions -library cln28ht_ret ssg_cworstt_max_0p81v_m40c 
set_operating_conditions -library sram_16k ssg_cworstt_0p81v_0p81v_m40c 
set_operating_conditions -library rom_via ssg_cworstt_0p81v_0p81v_m40c 
set_operating_conditions -library io_lib ssg0p81v1p62vm40c 
set_operating_conditions -library cln28ht ssg_cworstt_max_0p81v_m40c 
set_temperature -40 -corners setup_corner
set_voltage 0.81 -corners setup_corner

set_voltage -corners setup_corner -object_list [get_supply_nets {VDD}] 0.81
set_voltage -corners setup_corner -object_list [get_supply_nets {VDDACC}] 0.81
set_voltage -corners setup_corner -object_list [get_supply_nets {AVDDHV}] 1.62
set_voltage -corners setup_corner -object_list [get_supply_nets {AVDD}] 0.81
set_voltage -corners setup_corner -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners setup_corner -object_list [get_supply_nets {AGND}] 0.0

## max transition - SSGNP V=-10% T=-40 P=cworst_t rcworst_t
current_corner max_tran_corner 
set_parasitic_parameters -early_spec cworst_T -early_temperature -40 -late_spec rcworst_T -late_temperature -40 -library nanosoc_chip_pads.dlib
set_operating_conditions -library cln28ht_pmk ssg_cworstt_max_0p81v_m40c
set_operating_conditions -library cln28ht_hpk ssg_cworstt_max_0p81v_m40c
#set_operating_conditions -library cln28ht_ret ssg_cworstt_max_0p81v_m40c
set_operating_conditions -library sram_16k ssg_cworstt_0p81v_0p81v_m40c
set_operating_conditions -library rom_via ssg_cworstt_0p81v_0p81v_m40c
set_operating_conditions -library io_lib ssg0p81v1p62vm40c
set_operating_conditions -library cln28ht ssg_cworstt_max_0p81v_m40c
set_temperature -40 -corners max_tran_corner
set_voltage 0.81 -corners max_tran_corner 

set_voltage -corners max_tran_corner -object_list [get_supply_nets {VDD}] 0.81
set_voltage -corners max_tran_corner -object_list [get_supply_nets {VDDACC}] 0.81
set_voltage -corners max_tran_corner -object_list [get_supply_nets {AVDDHV}] 1.62
set_voltage -corners max_tran_corner -object_list [get_supply_nets {AVDD}] 0.81
set_voltage -corners max_tran_corner -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners max_tran_corner -object_list [get_supply_nets {AGND}] 0.0

## typical power - TT V=V T=85C P=ctypical
current_corner typical_corner
set_parasitic_parameters -early_spec typical -early_temperature 85 -late_spec typical -late_temperature 85 -library nanosoc_chip_pads.dlib
set_operating_conditions -library cln28ht_pmk tt_ctypical_max_0p90v_85c
set_operating_conditions -library cln28ht_hpk tt_ctypical_max_0p90v_85c 
#set_operating_conditions -library cln28ht_ret  tt_ctypical_max_0p90v_85c 
set_operating_conditions -library sram_16k  tt_ctypical_0p90v_0p90v_85c 
set_operating_conditions -library rom_via  tt_ctypical_0p90v_0p90v_85c 
set_operating_conditions -library io_lib  tt0p9v1p8v85c 
set_operating_conditions -library cln28ht  tt_ctypical_max_0p90v_85c 
set_temperature 125 -corners typical_corner
set_voltage 0.9 -corners typical_corner 

set_voltage -corners typical_corner -object_list [get_supply_nets {VDD}] 0.9
set_voltage -corners typical_corner -object_list [get_supply_nets {VDDACC}] 0.9
set_voltage -corners typical_corner -object_list [get_supply_nets {AVDDHV}] 1.8
set_voltage -corners typical_corner -object_list [get_supply_nets {AVDD}] 0.9
set_voltage -corners typical_corner -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners typical_corner -object_list [get_supply_nets {AGND}] 0.0

# Max IR drop - FFG V=V T=125 P=cworst

# Signal EM - FFG V=V T=125 P=rcworst_c cworst_T
current_corner em_corner
set_parasitic_parameters -early_spec cworst_T -early_temperature 125 -late_spec rcworst_T -late_temperature 125 -library nanosoc_chip_pads.dlib
set_operating_conditions -library cln28ht_pmk ffg_cbestt_min_0p99v_125c
set_operating_conditions -library cln28ht_hpk ffg_cbestt_min_0p99v_125c 
#set_operating_conditions -library cln28ht_ret  ffg_cbestt_min_0p99v_125c 
set_operating_conditions -library sram_16k  ffg_cbestt_0p99v_0p99v_125c 
set_operating_conditions -library rom_via  ffg_cbestt_0p99v_0p99v_125c 
set_operating_conditions -library io_lib  ffg0p99v1p98v125c 
set_operating_conditions -library cln28ht  ffg_cbestt_min_0p99v_125c 
set_temperature 125 -corners em_corner
set_voltage 0.9 -corners em_corner 

set_voltage -corners em_corner -object_list [get_supply_nets {VDD}] 0.9
set_voltage -corners em_corner -object_list [get_supply_nets {VDDACC}] 0.9
set_voltage -corners em_corner -object_list [get_supply_nets {AVDDHV}] 1.8
set_voltage -corners em_corner -object_list [get_supply_nets {AVDD}] 0.9
set_voltage -corners em_corner -object_list [get_supply_nets {VSS}] 0.0
set_voltage -corners em_corner -object_list [get_supply_nets {AGND}] 0.0

redirect -file ../reports/design_setup.report_scenarios.rpt {report_scenarios} 
redirect -file ../reports/design_setup.report_pvt.rpt {report_pvt} 
redirect -file ../reports/design_setup.report_corners.rpt {report_corners} 

current_corner setup_corner

