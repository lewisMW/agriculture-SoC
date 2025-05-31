LIBS_DIR:=./libs
REPORT_DIR:=./reports
LOG_DIR:=./logs
WORK_DIR:=./work

make_directories:
	mkdir -p $(LIBS_DIR)
	mkdir -p $(REPORT_DIR)
	mkdir -p $(LOG_DIR)
	mkdir -p $(WORK_DIR)

syn_genus:
	cd $(WORK_DIR); genus -f ../scripts/genus.tcl;

syn_genus_nodft:
	cd $(WORK_DIR); genus -f ../scripts/genus_nodft.tcl;

innovus_full:
	cd $(WORK_DIR); innovus -f ../scripts/pnr_flow.tcl;


all: generate_libs syn_genus innovus_full

