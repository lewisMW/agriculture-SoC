proc report_intermediate_step {name REPORT_DIR} {
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}_interclock.rep {report_global_timing -delay_type min -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}.rep {report_global_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}_interclock.rep {report_global_timing -delay_type max -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}.rep {report_global_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_max.rep {report_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_min.rep {report_timing -delay_type min}
}

proc report_end_step {name REPORT_DIR} {
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}_interclock.rep {report_global_timing -delay_type min -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}.rep {report_global_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}_interclock.rep {report_global_timing -delay_type max -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}.rep {report_global_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_max.rep {report_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_min.rep {report_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/area_${name}.rep {report_area}
    redirect -tee -file $REPORT_DIR/qor_${name}.rep {report_qor}

    current_scenario typical_scenario
    redirect -tee -file $REPORT_DIR/power_${name}_hierarchy.rep {report_power -scenarios typical_scenario -hierarchy}
    redirect -tee -file $REPORT_DIR/power_${name}.rep {report_power -scenarios typical_scenario}

}