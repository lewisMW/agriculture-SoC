# -----------------------------------------------------------------------------
# ADC/Makefile - SAR ADC digital unit benches (no ARM IP needed).
#
#   make            sar_adc_tb       DC / ramp / sine / FSM handshake / one cal
#   make cal        sar_adc_cal_tb   ADC-1..ADC-4 (codes, calibration vs offset,
#                                    cal/en changes mid-conversion, reset in
#                                    every state) at the default CLK_DIV = 4
#   make div        sar_adc_cal_tb rebuilt at CLK_DIV = 1, 2, 8 (ADC-5)
#
# Explicit file list (same set as tb/sar_adc_tb.f); never glob.
# One core, BUILD_ROOT: see ../verif/block_tb.mk.
# -----------------------------------------------------------------------------
include ../verif/block_tb.mk

TB_FILES  = $(ADC_FILES) ../FSM/wrapper_control_2.v ./tb/sar_adc_tb.v
CAL_FILES = $(ADC_FILES) ./tb/sar_adc_cal_tb.sv

DIVS ?= 1 2 8

.PHONY: all cal div clean

all:
	$(call tb_run,sar_adc_tb,sar_adc_tb,$(TB_FILES),,)

cal:
	$(call tb_run,sar_adc_cal,sar_adc_cal_tb,$(CAL_FILES),,)

# ADC-5: one build per divider; each prints its own summary line.
div:
	$(foreach d,$(DIVS),$(call tb_run,sar_adc_cal_div$(d),sar_adc_cal_tb,$(CAL_FILES),-GCLK_DIV=$(d),)$(newline))

clean:
	rm -rf $(OBJ)/obj_sar_adc* obj_dir build*.log *.vcd
