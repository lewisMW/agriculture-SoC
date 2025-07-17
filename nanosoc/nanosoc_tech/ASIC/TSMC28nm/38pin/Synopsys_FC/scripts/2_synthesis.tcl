open_lib nanosoc_chip_pads.dlib/
open_block nanosoc_chip_pads

set_host_options -max_cores 16 -num_processes 16
source ../scripts/setup.tcl

set_qor_strategy -stage synthesis -metric timing -high_effort_timing
#set_app_options -list {compile.flow.hold_area_budgeting {enhanced}}
#set_app_options -list {compile.flow.enable_multibit {true}}
#set_app_options -list {compile.flow.high_effort_timing {1}}
#set_app_options -list {compile.initial_place.buffering_aware_placement_effort {high}}
#set_app_options -list {compile.flow.high_effort_area {false}}
#set_app_options -list {compile.final_place.effort {high}}
#set_app_options -list {compile.early_place.effort {high}}
#set_app_options -name compile.congestion.placer_enhanced_router -value true
#
#
#
#set_app_options -name compile.initial_drc.global_route_based -value true
#set_app_options -name compile.final_place.placement_congestion_effort -value ultra
#set_app_options -name compile.initial_opto.placement_congestion_effort -value high
#set_app_options -name compile.flow.high_effort_timing  -value 1
#set_app_options -name compile.het.dtdp_congestion -value true
#
#set_app_options -name place.coarse.cong_restruct -value on 
#set_app_options -name place.coarse.cong_restruct_effort -value high 
#set_app_options -name place.coarse.cong_restruct_iterations -value 2 
#
#set_app_options -name place.coarse.max_density -value 0.5
#set_app_options -name place.coarse.congestion_driven_max_util -value 0.8
#set_app_options -name place.coarse.advanced_node_congestion_driven_max_util -value true 
#set_app_options -name place.coarse.congestion_expansion_direction -value both
#
#set_app_options -name place.coarse.increased_cell_expansion -value true


#DFT Setup
#set_scan_configuration -chain_count 4 -power_domain_mixing false -exclude_elements u_nanosoc_chip_cfg/*
#
#set_dft_signal -type TestMode -port TEST -active_state 1
#set_dft_signal -type ScanClock -port CLK
#set_dft_signal -type Reset -port NRST -active_state 0
#set_dft_signal -type ScanEnable -port SE -active_state 1 -hookup_pin {u_nanosoc_chip_cfg/soc_scan_enable}
#set_dft_signal -type ScanDataIn -port {P0[0]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_in[0]}
#set_dft_signal -type ScanDataIn -port {P0[1]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_in[1]}
#set_dft_signal -type ScanDataIn -port {P0[2]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_in[2]}
#set_dft_signal -type ScanDataIn -port {P0[3]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_in[3]}
#set_dft_signal -type ScanDataOut -port {P1[0]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_out[0]}
#set_dft_signal -type ScanDataOut -port {P1[1]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_out[1]}
#set_dft_signal -type ScanDataOut -port {P1[2]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_out[2]}
#set_dft_signal -type ScanDataOut -port {P1[3]} -hookup_pin {u_nanosoc_chip_cfg/soc_scan_out[3]}

# Compile fusion takes about 6.5 hrs to run
set_stage -step synthesis

compile_fusion -to logic_opto

#create_test_protocol
#dft_drc -test_mode all_dft
#run_test_point_analysis
#preview_dft
#insert_dft

compile_fusion -from initial_place -to initial_opto

report_intermediate_step 02a_initial_opto $REPORT_DIR
save_block 

set_stage -step compile_place
compile_fusion -from final_place

add_tie_cells -tie_high_lib_cells [get_lib_cells {cln28ht/TIEHI_X1M_A7PP140ZTS_C30}] -tie_low_lib_cells [get_lib_cells {cln28ht/TIELO_X1M_A7PP140ZTS_C30}]


report_end_step 02b_compile_fusion $REPORT_DIR

current_scenario typical_scenario
analyze_power_plan -nets [get_nets -design [current_block] {VDDACC VDD VSS}] -analyze_power -voltage 0.9

# Write netlist

save_block
save_lib nanosoc_chip_pads.dlib
save_block -as nanosoc_chip_pads.dlib:nanosoc_chip_pads/compile.design
exit
