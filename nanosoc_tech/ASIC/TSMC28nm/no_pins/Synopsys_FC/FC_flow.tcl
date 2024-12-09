# Main flow for Synopsys fusion compiler 
set REPORT_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports
set LOG_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/logs

# Design setup: read libraries and RTL 
redirect -tee -file $LOG_DIR/01_design_setup.log {source ./design_setup.tcl}

# Floorplan setup
redirect -tee -file $LOG_DIR/02_init_floorplan.log {initialize_floorplan -control_type die -use_site_row -side_length {1111.1111111 1111.11111} -core_offset {140}}
redirect -tee -file $LOG_DIR/03_floorplan.log {source ./floorplan/fp.tcl}

# Read Constraints
redirect -tee -file $LOG_DIR/04_constraints.log {read_sdc ../../constraints.sdc}

# Power Plan
redirect -tee -file $LOG_DIR/05_power_plan.log {source ./power_plan.tcl}

# Init coarse placement
redirect -tee -file $LOG_DIR/06_init_placement.log {source ./init_placement.tcl}

# Physical aware synthesis
redirect -tee -file $LOG_DIR/07_compile.log {compile_fusion}
save_lib nanosoc_chip_pads.dlib
redirect -tee -file $REPORT_DIR/timing_01_compile.rep {report_timing}
