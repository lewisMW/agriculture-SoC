# Import verilog and setup libraries
set_host_options -max_cores 16 -num_processes 16

source ../scripts/setup.tcl

# Set paths !!! Please edit for your system !!!
set cln28ht_tech_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0

#Create the design library 
create_lib nanosoc_chip_pads.dlib \
    -technology $cln28ht_tech_path/milkyway/1p8m_5x2z_utalrdl/sc7mcpp140z_tech.tf \
    -ref_libs {../libs/cln28ht/ ../libs/cln28ht_pmk/ ../libs/cln28ht_hpk  ../libs/sram_16k/  ../libs/rom_via/ ../libs/io_lib/ ../libs/pad_lib/}

# Removed ../libs/cln28ht_ret/ from lib for now

set lib_list {cln28ht cln28ht_pmk cln28ht_hpk sram_16k rom_via io_lib pad_lib} 
# removed cln28ht_ret from lib


redirect -tee -file ../logs/analyze_flist.log {source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl}
redirect -tee -file ../logs/analyze_top_file.log {analyze -format verilog $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/nanosoc_chip_pads/tsmc28hpcp/nanosoc_chip_pads_38pin.v}

redirect -tee -file ../logs/elaborate.log {elaborate nanosoc_chip_pads}
redirect -tee -file ../logs/set_top_module.log {set_top_module nanosoc_chip_pads}

redirect -tee -file ../logs/lib_cell_summary.log {report_lib -cell_summary cln28ht}
redirect -tee -file ../logs/lib_cell_pmk_summary.log {report_lib -cell_summary cln28ht_pmk}
#redirect -tee -file ../logs/lib_cell_ret_summary.log {report_lib -cell_summary cln28ht_ret}
redirect -tee -file ../logs/lib_cell_hpk_summary.log {report_lib -cell_summary cln28ht_hpk}
redirect -tee -file ../logs/lib_cell_io_lib_summary.log {report_lib -cell_summary io_lib}
redirect -tee -file ../logs/lib_cell_pad_lib_summary.log {report_lib -cell_summary pad_lib}
redirect -tee -file ../logs/lib_cell_sram_16k_summary.log {report_lib -cell_summary sram_16k}
redirect -tee -file ../logs/lib_cell_rom_via_summary.log {report_lib -cell_summary rom_via}

saif_map -start

source ../scripts/floorplan.tcl
 

source ../scripts/power_plan.tcl

save_block 

source ../scripts/routing_rules.tcl 

#set timing_use_enhanced_capacitance_modeling true
#set_app_var compile_clock_gating_through_hierarchy true
#set timing_separate_clock_gating_group TRUE


source ../scripts/pvt_setup.tcl

create_routing_rule {NDR1} -default_reference_rule  -multiplier_width 2 -multiplier_spacing 2
set_clock_routing_rules -rules NDR1 -clocks {clk swdclk} -min_routing_layer M2 -max_routing_layer M5



set_lib_cell_purpose -include none  {*X0*}
set_lib_cell_purpose -include none {*BUF*X0*}
set_lib_cell_purpose -include none {INV*X0*}
set_lib_cell_purpose -include none {*DLY*}
set_lib_cell_purpose -include none  {*FRICG*}
set_lib_cell_purpose -include none  {SDFF*H*}
set_lib_cell_purpose -include none  {SDFFX*}
set_lib_cell_purpose -include none  {HEAD*}
set_lib_cell_purpose -include none  {FOOT*}


set_lib_cell_purpose -exclude hold {**}
set_lib_cell_purpose -include hold {*DLY*}

#set_lib_cell_purpose -include hold {*BUF*X0* INV*X0*}
set_lib_cell_purpose -include cts  {*FRICG*}


set_message_info -id ATTR-11 -limit  5
get_lib_cells cln28ht/* -filter "valid_purposes(block) =~ *hold*"

current_scenario typical_scenario
read_saif ./waves.saif
redirect -tee -file $REPORT_DIR/initial_power_plan.rep {analyze_power_plan -nets [get_nets -design [current_block] {VDD VDDACC VSS}] -power_budget 10 -voltage 0.9}



redirect -tee -file ../logs/precompile_checks.log {compile_fusion -check_only}

save_block 
save_lib nanosoc_chip_pads.dlib

save_block -as nanosoc_chip_pads.dlib:nanosoc_chip_pads/init.design

exit