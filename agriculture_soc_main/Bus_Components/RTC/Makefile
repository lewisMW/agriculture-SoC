VERILATOR = verilator
TB_MODULE = rtc_control_tb

rtc_ip = /mnt/d/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source


VERILOG_FILES = $(shell find . -type f -name "*.v") $(shell find $(rtc_ip) -type f -name "*.v")

simulation_defs = -DSIMULATION

all:
	$(VERILATOR) --cc --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
	./obj_dir/V$(TB_MODULE)

clean:
	rm -rf obj_dir waveform.vcd

