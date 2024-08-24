include ../paths.mk

CORE_DIR = $(DESIGNSTART_DIR)/cores/cortexm0_designstart_r2p0/logical/cortexm0_integration/verilog

TB_MODULE = agriculture_soc_tb

ROM_FILE = ../software/hello/hello.hex

VERILOG_FILES = $(shell find . -type f -name "*.v")

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing -I$(CORE_DIR);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	cp $(ROM_FILE) code.hex;
	./obj_dir/V$(TB_MODULE);