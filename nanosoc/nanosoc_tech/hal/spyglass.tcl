set_app_var enable_lint true

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl

elaborate nanosoc_chip_pads

check_lint

report_violations -app {lint} -file report_hdl.txt -verbose