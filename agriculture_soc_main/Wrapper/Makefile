VERILATOR = verilator
TB_MODULE = adc_apb_wrapper_rev1_tb

# ARM PL031 RTC IP (needed by rtc_control). Set ARM_IP_LIBRARY_PATH in your env.
rtc_ip = $(ARM_IP_LIBRARY_PATH)/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source

# Explicit file list — do NOT glob the sibling dirs (they contain rev0, *_old.v
# and other testbenches that would collide with these modules).
VERILOG_FILES = \
    ./adc_apb_wrapper_rev1.v \
    ./adc_apb_wrapper_rev1_tb.v \
    ../FSM/wrapper_control.v \
    ../FIFO/fifo_apb_adc.v \
    ../Dummy/dummy_adc.v \
    ../Dummy/dummy_amux.v \
    ../Dummy/dummy_pll.v \
    ../RTC/rtc_control.v \
    $(shell find $(rtc_ip) -type f -name "*.v")

simulation_defs = -DSIMULATION
VERILATOR_FLAGS = -Wno-fatal

.PHONY: all clean

all:
	$(VERILATOR) --cc --trace --exe --main $(VERILATOR_FLAGS) --top $(TB_MODULE) $(VERILOG_FILES) --timing $(simulation_defs) -I$(rtc_ip)
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
	./obj_dir/V$(TB_MODULE)

clean:
	rm -rf obj_dir waveform.vcd
