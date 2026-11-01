# -----------------------------------------------------------------------------
# verif/cov/Makefile — functional-coverage runs (Verilator 5.052+ covergroups).
#
# Each target re-runs an EXISTING self-checking testbench with the matching
# coverage model(s) bound into the DUT, writes coverage_<name>.dat, and prints
# a per-target report. The testbenches themselves are not modified.
#
#   make fifo        FIFO/fifo_apb_adc_rand_tb      + fifo_cov            (no ARM IP)
#   make fsm         FSM/wrapper_control_seq_tb     + fsm_cov             (no ARM IP)
#   make free        fifo + fsm, merged report                            (no ARM IP)
#   make rtc         RTC/tb_rtc_control_rand        + rtc_cov             (ARM IP)
#   make wrapper     Wrapper/adc_apb_wrapper_rand_tb + all four models    (ARM IP)
#   make gap         Wrapper/sens_gap_tb (coverage-gap tests) + all models + SVA (ARM IP)
#   make rtcdir      RTC/tb_rtc_control (directed)  + rtc_cov             (ARM IP)
#   make wrapdir     Wrapper/adc_apb_wrapper_rev2_tb (directed) + models  (ARM IP)
#   make all         everything, merged report                            (ARM IP)
#   make report      merge every coverage_*.dat present -> summary + annotate/
#   make holes       list every covergroup bin that was never hit
#   CODE_COV=1       line + FSM code coverage instead of covergroups (separate
#                    run - see ../verilator_1core.mk for why they are not mixed)
#   STUB_RTC=1       use verif/stubs/pl031_stub.v instead of the ARM PL031
#                    (compile/smoke only - NOT sign-off)
#
# Single-core by design - see ../verilator_1core.mk.
# -----------------------------------------------------------------------------
include ../verilator_1core.mk

ROOT = ../..

ifeq ($(STUB_RTC),1)
  RTC_FILES = ../stubs/pl031_stub.v
  RTC_INC   = -DPL031_STUB
else
  RTC_FILES = $(shell find $(RTC_IP) -type f -name "*.v" 2>/dev/null)
  RTC_INC   = -I$(RTC_IP)
endif

FIFO_FILES = $(ROOT)/FIFO/fifo_apb_adc_rand_tb.v $(ROOT)/FIFO/fifo_apb_adc.v fifo_cov.sv
FSM_FILES  = $(ROOT)/FSM/wrapper_control_seq_tb.v $(ROOT)/FSM/wrapper_control_2.v \
             $(ROOT)/Dummy/dummy_adc.v fsm_cov.sv
RTC_TB_FILES = $(ROOT)/RTC/tb_rtc_control_rand.v $(ROOT)/RTC/rtc_control_2.v \
             $(RTC_FILES) rtc_cov.sv
# The SAR ADC (wrapper_rev2 instantiates sar_adc since the SKY130 AMS merge):
# synthesisable sar_adc + latch + sarlogic, plus the sim-only nand2 cell and
# behavioural sar_afe models. Same set as Wrapper/Makefile's ADC_FILES.
ADC_FILES  = $(ROOT)/ADC/sar_adc.v $(ROOT)/ADC/sar_comp_latch.v \
             $(ROOT)/../analog/cadence/sar_adc/sarlogic/functional/verilog.v \
             $(ROOT)/ADC/sim/sky130_fd_sc_hd__nand2_1.v $(ROOT)/ADC/sim/sar_afe_model.v
SENS_DUT   = $(ROOT)/Wrapper/adc_apb_wrapper_rev2.v \
             $(ROOT)/FSM/wrapper_control_2.v $(ROOT)/FIFO/fifo_apb_adc.v \
             $(ADC_FILES) $(ROOT)/Dummy/dummy_amux.v $(ROOT)/Dummy/dummy_pll.v \
             $(ROOT)/RTC/rtc_control_2.v $(RTC_FILES)
ALL_COV    = fifo_cov.sv fsm_cov.sv rtc_cov.sv wrapper_cov.sv
# Gap-closing bench (coverage_plan.md): self-checking, SVA bound (--assert).
GAP_FILES  = $(ROOT)/Wrapper/sens_gap_tb.sv $(SENS_DUT) $(ALL_COV) ../sensing_assertions.sv
# Directed benches, so their coverage counts too.
RTCDIR_FILES  = $(ROOT)/RTC/tb_rtc_control.v $(ROOT)/RTC/rtc_control_2.v $(RTC_FILES) rtc_cov.sv
WRAPDIR_FILES = $(ROOT)/Wrapper/adc_apb_wrapper_rev2_tb.v $(SENS_DUT) $(ALL_COV)
WRAP_FILES = $(ROOT)/Wrapper/adc_apb_wrapper_rand_tb.v $(ROOT)/Wrapper/adc_apb_wrapper_rev2.v \
             $(ROOT)/FSM/wrapper_control_2.v $(ROOT)/FIFO/fifo_apb_adc.v \
             $(ADC_FILES) $(ROOT)/Dummy/dummy_amux.v $(ROOT)/Dummy/dummy_pll.v \
             $(ROOT)/RTC/rtc_control_2.v $(RTC_FILES) \
             fifo_cov.sv fsm_cov.sv rtc_cov.sv wrapper_cov.sv

# nanosoc gap-coverage models (nanosoc/system/verif/cov, bound with
# nsc_bind_sensing.sv) ride along on the wrapper/rtc runs so the existing
# benches measure them too. NSC_COV=0 to leave them out.
NSC_COV ?= 1
NSC_DIR  = $(ROOT)/../nanosoc/system/verif/cov
ifeq ($(NSC_COV),1)
  NSC_WRAP_FILES = $(NSC_DIR)/nsc_sens_apb_cov.sv $(NSC_DIR)/nsc_rtc_boundary_cov.sv \
                   $(NSC_DIR)/nsc_bind_sensing.sv
  NSC_RTC_FILES  = $(NSC_DIR)/nsc_rtc_boundary_cov.sv $(NSC_DIR)/nsc_rtc_bind_only.sv
endif
WRAP_FILES += $(NSC_WRAP_FILES)
RTC_TB_FILES += $(NSC_RTC_FILES)
GAP_FILES += $(NSC_WRAP_FILES)
RTCDIR_FILES += $(NSC_RTC_FILES)
WRAPDIR_FILES += $(NSC_WRAP_FILES)

DEFS = -DSIMULATION

# Code-coverage runs get their own .dat/obj names so they never overwrite the
# functional-coverage results; `make report` merges both kinds.
ifeq ($(CODE_COV),1)
  SFX = _code
endif

# $(call cov_run,name,top,files,extra-flags)
define cov_run
	@echo "===== COVERAGE: $(1)$(SFX) ====="
	rm -rf obj_$(1)$(SFX) coverage_$(1)$(SFX).dat
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(VL_COV) $(DEFS) $(4) \
	    --Mdir obj_$(1)$(SFX) --top $(2) -o V$(1) $(3) > build_$(1)$(SFX).log 2>&1 \
	    || { tail -30 build_$(1)$(SFX).log; false; }
	./obj_$(1)$(SFX)/V$(1) +verilator+coverage+file+coverage_$(1)$(SFX).dat | tee run_$(1)$(SFX).log
	@verilator_coverage --report summary coverage_$(1)$(SFX).dat | grep -E "covergroup|line|fsm"
endef

.PHONY: fifo fsm rtc wrapper gap rtcdir wrapdir free all report holes clean

fifo:
	$(call cov_run,fifo,fifo_apb_adc_rand_tb,$(FIFO_FILES),)

fsm:
	$(call cov_run,fsm,wrapper_control_seq_tb,$(FSM_FILES),)

rtc:
	$(call cov_run,rtc,tb_rtc_control_rand,$(RTC_TB_FILES),$(RTC_INC))

wrapper:
	$(call cov_run,wrapper,adc_apb_wrapper_rand_tb,$(WRAP_FILES),$(RTC_INC))

gap:
	$(call cov_run,gap,sens_gap_tb,$(GAP_FILES),$(RTC_INC) --assert)

rtcdir:
	$(call cov_run,rtcdir,tb_rtc_control,$(RTCDIR_FILES),$(RTC_INC))

wrapdir:
	$(call cov_run,wrapdir,adc_apb_wrapper_rev2_tb,$(WRAPDIR_FILES),$(RTC_INC))

# Run sequentially (never in parallel - one core).
free:
	$(MAKE) fifo
	$(MAKE) fsm
	$(MAKE) report

all:
	$(MAKE) fifo
	$(MAKE) fsm
	$(MAKE) rtc
	$(MAKE) wrapper
	$(MAKE) gap
	$(MAKE) rtcdir
	$(MAKE) wrapdir
	$(MAKE) report

report:
	verilator_coverage --write merged.dat coverage_*.dat
	@echo "===== MERGED FUNCTIONAL COVERAGE (covergroups) ====="
	verilator_coverage --filter-type covergroup --report summary merged.dat | grep covergroup
	@python3 holes.py merged.dat
	@echo "===== CODE COVERAGE (line / fsm) ====="
	verilator_coverage --report summary merged.dat
	rm -rf annotate && verilator_coverage --annotate annotate --annotate-min 1 merged.dat
	@echo "Annotated sources: verif/cov/annotate/  (uncovered lines marked %000000)"

# Every covergroup bin with a zero count = a coverage hole to target next.
holes:
	@verilator_coverage --write merged.dat coverage_*.dat
	@python3 holes.py merged.dat

clean:
	rm -rf obj_* coverage_*.dat merged.dat annotate build_*.log run_*.log *.vcd
