LIBS_DIR:=./libs
REPORT_DIR:=./reports
LOG_DIR:=./logs
WORK_DIR:=./work
OUT_DIR:=./outputs

make_directories:
	mkdir -p $(LIBS_DIR)
	mkdir -p $(REPORT_DIR)
	mkdir -p $(LOG_DIR)
	mkdir -p $(WORK_DIR)
	mkdir -p $(OUT_DIR)

generate_libs: make_directories
	cd $(LIBS_DIR); lc_shell; -f ../scripts/synopsys_lib_conversion.tcl;

synthesis:  
	cd $(WORK_DIR); dc_shell

fusion_init_design:
	cd $(WORK_DIR); fc_shell -f ../scripts/1_design_setup.tcl;

fusion_synthesis:
	cd $(WORK_DIR); fc_shell -f ../scripts/2_synthesis.tcl;

fusion_clock_opt:
	cd $(WORK_DIR); fc_shell -f ../scripts/3_clock.tcl 

fusion_route:
	cd $(WORK_DIR); fc_shell;

fusion_full_flow: fusion_init_design fusion_synthesis fusion_clock_opt fusion_route

all: generate_libs fusion_full_flow

