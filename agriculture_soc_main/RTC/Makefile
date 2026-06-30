# VERILATOR = verilator
# TB_MODULE = rtc_control_tb

# rtc_ip = /mnt/d/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source


# VERILOG_FILES = $(shell find . -type f -name "*.v") $(shell find $(rtc_ip) -type f -name "*.v")

# simulation_defs = -DSIMULATION

# all:
# 	$(VERILATOR) --cc --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
# 	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
# 	./obj_dir/V$(TB_MODULE)

# clean:
# 	rm -rf obj_dir waveform.vcd

# VERILATOR = verilator
# TB_MODULE = arm_rtc_tb.v

# rtc_ip = /mnt/c/Users/b3nsc/SocDesignComp/nanosoc_arm_ip/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source


# VERILOG_FILES = $(shell find . -type f -name "*.v") $(shell find $(rtc_ip) -type f -name "*.v")

# simulation_defs = -DSIMULATION

# all:
# 	$(VERILATOR) --cc --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
# 	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
# 	./obj_dir/V$(TB_MODULE)

# cleancd ,
# 	rm -rf obj_dir waveform.vcd
VERILATOR = verilator
# TB_MODULE = arm_rtc_tb
TB_MODULE = tb_rtc_control
TB_FILE   = $(TB_MODULE).v
rtc_ip = /mnt/c/Users/b3nsc/SocDesignComp/nanosoc_arm_ip/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source
VERILOG_FILES = $(shell find . -type f -name "*.v") $(shell find $(rtc_ip) -type f -name "*.v")
simulation_defs = -DSIMULATION
VERILATOR_FLAGS = -Wno-WIDTHEXPAND

all:
	$(VERILATOR) --cc --trace --exe --main $(VERILATOR_FLAGS) --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
	./obj_dir/V$(TB_MODULE)

clean:
	rm -rf obj_dir waveform.vcd


