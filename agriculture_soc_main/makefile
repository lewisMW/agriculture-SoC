# include ../paths.mk

# CORE_DIR = $(DESIGNSTART_DIR)/cores/cortexm0_designstart_r2p0/logical/cortexm0_integration/verilog

# cmsdk_ahb_to_sram = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_to_sram/verilog
# cmsdk_ahb_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_gpio/verilog
# cmsdk_iop_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_iop_gpio/verilog
# cmsdk_fpga_sram = $(DESIGNSTART_DIR)/logical/cmsdk_fpga_sram/verilog
# fpga_options_defs = $(DESIGNSTART_DIR)/RevC/SMM_M0DS/fpga_top/verilog

# simulation_defs = -DSIMULATION

# TB_MODULE = agriculture_soc_tb

# ROM_FILE = ../software/hello/hello.hex

# VERILOG_FILES = $(shell find . -type f -name "*.v")

# all:
# 	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing -I$(CORE_DIR) -I$(cmsdk_ahb_to_sram) -I$(cmsdk_ahb_gpio) -I$(cmsdk_iop_gpio) -I$(cmsdk_fpga_sram) -I$(fpga_options_defs) $(simulation_defs);
# 	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
# 	cp $(ROM_FILE) code.hex;
# 	./obj_dir/V$(TB_MODULE);

include ../paths.mk

$(info DESIGNSTART_DIR = $(DESIGNSTART_DIR))

CORE_DIR = $(DESIGNSTART_DIR)/cores/cortexm0_designstart_r2p0/logical/cortexm0_integration/verilog
cmsdk_ahb_to_sram = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_to_sram/verilog
cmsdk_ahb_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_ahb_gpio/verilog
cmsdk_iop_gpio = $(DESIGNSTART_DIR)/logical/cmsdk_iop_gpio/verilog
cmsdk_fpga_sram = $(DESIGNSTART_DIR)/logical/cmsdk_fpga_sram/verilog
fpga_options_defs = $(DESIGNSTART_DIR)/RevC/SMM_M0DS/fpga_top/verilog


TB_MODULE = agriculture_soc_tb
ROM_FILE = ../software/hello/hello.hex

VERILOG_FILES = \
    $(CORE_DIR)/CORTEXM0INTEGRATION.v \
    $(cmsdk_ahb_to_sram)/cmsdk_ahb_to_sram.v \
    $(cmsdk_ahb_gpio)/cmsdk_ahb_gpio.v \
    $(cmsdk_iop_gpio)/cmsdk_iop_gpio.v \
    $(cmsdk_fpga_sram)/cmsdk_fpga_sram.v \
    ./agriculture_soc_tb.v \
    ./agriculture_soc.v \
    ./Bus_Components/AHBMUX.v \
    ./Bus_Components/adc_apb_wrapper.v \
    ./Bus_Components/AHBDCD.v \
    ./GPIO_Interface/AHBGPIO.v \
    ./FIFO/AHB_SoC_Interface.v \
    ./FIFO/Master_Interface_DDS.v \
    ./FIFO/Circular_FIFO.v \
    ./RAM_Interface/AHB2SRAM.v

$(info CORE_DIR = $(CORE_DIR))
$(info VERILOG_FILES = $(VERILOG_FILES))

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing \
        -I$(CORE_DIR) -I$(cmsdk_ahb_to_sram) -I$(cmsdk_ahb_gpio) -I$(cmsdk_iop_gpio) -I$(cmsdk_fpga_sram) -I$(fpga_options_defs) \
        $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	cp $(ROM_FILE) code.hex;
	./obj_dir/V$(TB_MODULE);