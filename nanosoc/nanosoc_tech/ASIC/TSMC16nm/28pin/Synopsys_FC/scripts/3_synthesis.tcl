set_host_options -max_cores 16 -num_processes 16
set REPORT_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports
set LOG_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/logs

current_corner default
set_parasitic_parameters -early_spec rcbest -early_temperature -40 -late_spec rcworst -late_temperature 125 -library nanosoc_chip_pads.dlib
set_operating_conditions -max_library cln16fcll -max ffgnp_cbestccbestt_min_0p88v_m40c -min_library cln16fcll -min ssgnp_cworstccworstt_max_0p72v_125c
set_process_number -early 1 -late 1 -corners default
set_temperature -min -40 -corners default 125
set_voltage 0.72 -min 0.88 -corners default


# Compile fusion takes about 6.5 hrs to run
compile_fusion 
save_lib nanosoc_chip_pads.dlib

redirect -tee -file $REPORT_DIR/timing_03a_compile_fusion_max.rep {report_timing -delay_type max}
redirect -tee -file $REPORT_DIR/timing_03a_compile_fusion_min.rep {report_timing -delay_type min}

place_opt 

redirect -tee -file $REPORT_DIR/timing_03b_place_opt_max.rep {report_timing -delay_type max}
redirect -tee -file $REPORT_DIR/timing_03b_place_opt_min.rep {report_timing -delay_type min}


save_lib nanosoc_chip_pads.dlib
