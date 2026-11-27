# -----------------------------------------------------------------------------
# FIFO/Makefile - fifo_apb_adc unit benches (no ARM IP needed).
#   make        fifo_apb_adc_tb       original smoke bench
#   make rand   fifo_apb_adc_rand_tb  reference model + invariants + random
# Explicit file lists; one core / BUILD_ROOT: see ../verif/block_tb.mk.
# -----------------------------------------------------------------------------
include ../verif/block_tb.mk

VERILOG_FILES = ./fifo_apb_adc_tb.v ./fifo_apb_adc.v
RAND_FILES    = ./fifo_apb_adc_rand_tb.v ./fifo_apb_adc.v

.PHONY: all rand clean

all:
	$(call tb_run,fifo,fifo_apb_adc_tb,$(VERILOG_FILES),--trace,)

rand:
	$(call tb_run,fifo_rand,fifo_apb_adc_rand_tb,$(RAND_FILES),--trace,)

clean:
	rm -rf $(OBJ)/obj_fifo* obj_dir build_*.log waveform.vcd
