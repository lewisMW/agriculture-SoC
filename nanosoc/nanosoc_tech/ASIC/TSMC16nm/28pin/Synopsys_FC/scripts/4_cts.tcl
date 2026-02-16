set_host_options -max_cores 16 -num_processes 16
set REPORT_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports
set LOG_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/logs


synthesize_clock_trees 
check_clock_trees

report_timing

redirect -tee -file $REPORT_DIR/timing_04a_CTS_max.rep {report_timing -delay_type max}
redirect -tee -file $REPORT_DIR/timing_04a_CTS_min.rep {report_timing -delay_type min}

save_lib nanosoc_chip_pads.dlib

clock_opt

report_timing

redirect -tee -file $REPORT_DIR/timing_04b_Clockopt_max.rep {report_timing -delay_type max}
redirect -tee -file $REPORT_DIR/timing_04b_Clockopt_min.rep {report_timing -delay_type min}

save_lib nanosoc_chip_pads.dlib
