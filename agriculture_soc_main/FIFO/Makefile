# VERILATOR = verilator
# TOP_MODULE = fifo_apb_adc_tb

# all: sim

# sim:
# 	verilator --cc --exe --trace --timing sim_main.cpp fifo_apb_adc_tb.v fifo_apb_adc.v --build

# 	make -C obj_dir -f V$(TOP_MODULE).mk
# 	./obj_dir/V$(TOP_MODULE)

# clean:
# 	rm -rf obj_dir waveform.vcd
VERILATOR = verilator
TB_MODULE = fifo_apb_adc_tb

VERILOG_FILES = \
    ./fifo_apb_adc_tb.v \
    ./fifo_apb_adc.v

all:
	$(VERILATOR) --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing;
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	./obj_dir/V$(TB_MODULE);

clean:
	rm -rf obj_dir waveform.vcd
