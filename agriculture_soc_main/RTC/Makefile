VERILATOR = verilator
# TB_MODULE = arm_rtc_tb
TB_MODULE = tb_rtc_control
TB_FILE   = $(TB_MODULE).v

# ARM_IP_LIBRARY_PATH ?= /mnt/c/Users/b3nsc/SocDesignComp/nanosoc_arm_ip

rtc_ip = $(ARM_IP_LIBRARY_PATH)/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source

VERILOG_FILES = $(shell find . -type f -name "*.v") $(shell find $(rtc_ip) -type f -name "*.v")

simulation_defs = -DSIMULATION
VERILATOR_FLAGS = -Wno-WIDTHEXPAND

.PHONY: all rand clean

all:
	$(VERILATOR) --cc --trace --exe --main $(VERILATOR_FLAGS) --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
	./obj_dir/V$(TB_MODULE)

# Constrained-random collision/liveness stress test (see tb_rtc_control_rand.v).
RAND_MODULE = tb_rtc_control_rand

rand:
	$(VERILATOR) --cc --trace --exe --main $(VERILATOR_FLAGS) --top $(RAND_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
	$(MAKE) -C obj_dir -f V$(RAND_MODULE).mk
	./obj_dir/V$(RAND_MODULE)

clean:
	rm -rf obj_dir waveform.vcd

