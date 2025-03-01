simulation_defs = -DSIMULATION

TB_MODULE = wrapper_control_tb

VERILOG_FILES = $(shell find . -type f -name "*.v")

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs);
	./obj_dir/V$(TB_MODULE);