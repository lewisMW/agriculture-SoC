proc report_intermediate_step {name REPORT_DIR} {
    report_timing_summary > $REPORT_DIR/timing_summary_${name}.rep
    report_timing -late > $REPORT_DIR/timing_${name}_late.rep
    report_timing -early > $REPORT_DIR/timing_${name}_early.rep
}

proc report_end_step {name REPORT_DIR} {
    report_timing_summary > $REPORT_DIR/timing_summary_${name}.rep
    report_timing -late > $REPORT_DIR/timing_${name}_late.rep
    report_timing -early > $REPORT_DIR/timing_${name}_early.rep
    report_power > $REPORT_DIR/power_${name}.rep
    report_qor -format text -out_file $REPORT_DIR/qor_${name}.rep
}