LIB_DIR	:= ./libs
WORK_DIR := ./work
REPORTS_DIR :=  $(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports
LOG_DIR := $(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/logs


gen_fusion_libs:
	@mkdir -p $(LIB_DIR)
	@(cd $(LIB_DIR); \
	lc_shell;)

fusion_design_setup:
	@mkdir -p $(REPORTS_DIR)
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(WORK_DIR)
	@(cd $(WORK_DIR); \
	fc_shell -f ../scripts/1_design_setup.tcl;)
