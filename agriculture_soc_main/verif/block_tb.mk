# -----------------------------------------------------------------------------
# block_tb.mk - shared rules for the block-level bench makefiles
# (ADC/, FSM/, FIFO/, RTC/, Wrapper/). Include it as  include ../verif/block_tb.mk
#
# Gives every block makefile:
#   - the single-core / memory-capped Verilator settings (verilator_1core.mk)
#   - STUB_RTC=1   PL031 stand-in instead of the ARM IP (no ARM IP needed; NOT sign-off)
#   - BUILD_ROOT   build directories on another disk (see verilator_1core.mk)
#   - explicit file lists for the sensing DUT (never glob the block directories:
#     they hold legacy revisions and other testbenches)
#   - $(call tb_run,name,top,files,verilator-flags,run-args): build without
#     coverage and run; the bench prints its own
#     "=== NAME: N PASSED, M FAILED ===" line.
# -----------------------------------------------------------------------------
BLOCK_MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(BLOCK_MK_DIR)verilator_1core.mk

AGRI   = $(BLOCK_MK_DIR)..
VERIF  = $(BLOCK_MK_DIR)

# Build-directory root for this makefile: <BUILD_ROOT>/<block dir name>, or "."
OBJ    = $(if $(BUILD_ROOT),$(BUILD_ROOT)/$(notdir $(CURDIR)),.)

ifeq ($(STUB_RTC),1)
  RTC_FILES = $(VERIF)stubs/pl031_stub.v
  RTC_INC   = -DPL031_STUB
else
  # The PL031 kit directory is a flat directory of IP modules with no
  # testbenches, so taking every .v in it is safe (unlike the block dirs).
  RTC_FILES = $(shell find $(RTC_IP) -type f -name "*.v" 2>/dev/null)
  RTC_INC   = -I$(RTC_IP)
endif

# SAR ADC: synthesisable sar_adc + latch + sarlogic, and the simulation-only
# nand2 cell and behavioural sar_afe macro models.
ADC_RTL   = $(AGRI)/ADC/sar_adc.v $(AGRI)/ADC/sar_comp_latch.v \
            $(AGRI)/../analog/cadence/sar_adc/sarlogic/functional/verilog.v
ADC_SIM   = $(AGRI)/ADC/sim/sky130_fd_sc_hd__nand2_1.v $(AGRI)/ADC/sim/sar_afe_model.v
ADC_FILES = $(ADC_RTL) $(ADC_SIM)

# The whole sensing peripheral (adc_apb_wrapper_rev2 and everything under it).
SENS_DUT  = $(AGRI)/Wrapper/adc_apb_wrapper_rev2.v \
            $(AGRI)/FSM/wrapper_control_2.v $(AGRI)/FIFO/fifo_apb_adc.v \
            $(ADC_FILES) $(AGRI)/Dummy/dummy_amux.v $(AGRI)/Dummy/dummy_pll.v \
            $(AGRI)/RTC/rtc_control_2.v $(RTC_FILES)

SVA_FILE  = $(VERIF)sensing_assertions.sv

TB_DEFS   = -DSIMULATION

# $(call tb_run,name,top,files,verilator-flags,run-args)
define tb_run
	@mkdir -p $(OBJ)
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(TB_DEFS) $(4) --Mdir $(OBJ)/obj_$(1) --top $(2) -o V$(1) $(3) \
	    > build_$(1).log 2>&1 || { tail -30 build_$(1).log; false; }
	$(OBJ)/obj_$(1)/V$(1) $(5)
endef

.NOTPARALLEL:

# a literal newline, for $(foreach ...) over $(call tb_run,...)
define newline


endef
