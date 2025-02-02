include ../paths.mk

CORE_DIR = $(DESIGNSTART_DIR)/cores/cortexm0_designstart_r2p0/logical/cortexm0_integration/verilog

cmsdk_ahb_to_sram = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_to_sram/verilog
cmsdk_ahb_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_gpio/verilog
cmsdk_ahb_apb = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_to_apb/verilog
cmsdk_iop_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_iop_gpio/verilog
cmsdk_fpga_sram = $(DESIGNSTART_DIR)/logical/cmsdk_fpga_sram/verilog
fpga_options_defs = $(DESIGNSTART_DIR)/RevC/SMM_M0DS/fpga_top/verilog

simulation_defs = -DSIMULATION

TB_MODULE = agriculture_soc_tb

# ROM_FILE = ../software/hello/write_test.hex
ROM_FILE = ../software/hello/adc_trigger_test.hex

VERILOG_FILES = $(shell find . -type f -name "*.v")

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing -I$(CORE_DIR) -I$(cmsdk_ahb_to_sram) -I$(cmsdk_ahb_gpio) -I$(cmsdk_iop_gpio) -I$(cmsdk_ahb_apb) -I$(cmsdk_fpga_sram) -I$(fpga_options_defs) $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	cp $(ROM_FILE) code.hex;
	./obj_dir/V$(TB_MODULE);