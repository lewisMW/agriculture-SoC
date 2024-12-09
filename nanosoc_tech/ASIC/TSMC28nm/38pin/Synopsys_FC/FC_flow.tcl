# Main flow for Synopsys fusion compiler 
set REPORT_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports
set LOG_DIR $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/logs

# Design setup: read libraries and RTL 
redirect -tee -file $LOG_DIR/01_design_setup.log {source ./design_setup.tcl}

# Floorplan setup
redirect -tee -file $LOG_DIR/02_init_floorplan.log {initialize_floorplan -control_type die -use_site_row -side_length {1111.1111111 1111.11111} -core_offset {140}}
redirect -tee -file $LOG_DIR/03_floorplan.log {source ./floorplan/fp.tcl}
place_io
# Read Constraints
redirect -tee -file $LOG_DIR/04_constraints.log {read_sdc ../../constraints.sdc}

# Power Plan
load_upf nanosoc_chip_pads.upf
create_voltage_area -power_domains ACCEL 
create_voltage_area -power_domains PD_DBG
create_voltage_area -power_domains PD_SYS
 
create_voltage_area_shape -voltage_area ACCEL \
				-region {{{140.000 140.000} {370.655 311.165}}} \
				-guard_band {2 2}

create_voltage_area_shape -voltage_area PD_DBG \
				-region {{{703.115 140.000} {971.040 329.520}}} \
				-guard_band {2 2}
create_voltage_area_shape -voltage_area PD_SYS \
				-region {{{234.000 453.940} {548.100 645.665}}} \
				-guard_band {2 2}

create_pg_region {pg_accel} -voltage_area {ACCEL}
create_pg_region {pg_dbg} -voltage_area {PD_DBG}
create_pg_region {pg_sys} -voltage_area {PD_SYS}

redirect -tee -file $LOG_DIR/05_power_plan.log {source ./power_plan.tcl}

# Init coarse placement
redirect -tee -file $LOG_DIR/06_init_placement.log {source ./init_placement.tcl}

# Physical aware synthesis
redirect -tee -file $LOG_DIR/07_compile.log {compile_fusion}
redirect -tee -file $REPORT_DIR/timing_01_compile.rep {report_timing}
save_lib nanosoc_chip_pads.dlib

redirect -tee -file $LOG_DIR/08_clock_tree.log {synthesize_clock_trees -clocks {clk swdclk}}
redirect -tee -file $LOG_DIR/09_clock_opt.log {clock_opt}
redirect -tee -file $REPORT_DIR/timing_02_clock_opt.rep {report_timing}



