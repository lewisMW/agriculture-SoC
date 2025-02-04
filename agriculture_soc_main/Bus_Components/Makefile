# VERILATOR = verilator
# TB_MODULE = adc_apb_wrapper_tb

# VERILOG_FILES = \
#     ./adc_apb_wrapper.v \
#     ./dummy_adc.v \
#     ./dummy_amux.v \
#     ../FIFO/fifo_apb_adc.v \
#     ./adc_apb_wrapper_tb.v

# all:
# 	$(VERILATOR) --cc --exe --build -Wall \
#         --trace --timescale 1ns/1ps \
#         $(VERILOG_FILES) \
#         -CFLAGS "-std=c++11" \
#         -o obj_dir/$(TB_MODULE)

# 	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk
# 	./obj_dir/V$(TB_MODULE)

# clean:
# 	rm -rf obj_dir waveform.vcd
# Verilator 仿真配置
VERILATOR = verilator
VFLAGS = --cc --exe --trace --build --timing --main --top-module adc_apb_wrapper_tb

TB_MODULE = adc_apb_wrapper_tb
OBJ_DIR = obj_dir

VERILOG_FILES = \
    ./adc_apb_wrapper.v \
    ../FIFO/fifo_apb_adc.v \
    ./dummy_adc.v \
    ./dummy_amux.v \
    ./adc_apb_wrapper_tb.v

all:
	$(VERILATOR) $(VFLAGS) $(VERILOG_FILES)
	make -C $(OBJ_DIR) -f V$(TB_MODULE).mk
	./$(OBJ_DIR)/V$(TB_MODULE)

clean:
	rm -rf $(OBJ_DIR) *.vcd
