simulation_defs = -DSIMULATION

TB_MODULE = rtc_control_tb

VERILOG_FILES = $(shell find . -type f -name "*.v")

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	./obj_dir/V$(TB_MODULE);