# -----------------------------------------------------------------------------
# verif/cov/Makefile - coverage runs for the sensing peripheral (Verilator 5.052).
#
# Every bench is built twice, in separate directories:
#   functional  --coverage-user  + the covergroup models (+ SVA where listed)
#               -> coverage_<name>.dat, merged into merged.dat
#   code        --coverage-line --coverage-toggle, WITHOUT the covergroup
#               models -> coverage_<name>_code.dat, merged into merged_code.dat
# They are never mixed: --coverage-line in a covergroup build zeroes some bins.
#
#   make <bench>       one functional run   (bench names: see BENCHES below)
#   make code_<bench>  one code-coverage run
#   make free          fifo fsm adc adccal + report             (no ARM IP)
#   make all           every bench + soak + report              (ARM IP or STUB_RTC=1)
#   make code          every code-coverage run + code_holes.py --gate
#   make report        merge coverage_*.dat (+ the two UVM runs if present),
#                      holes.py with waivers.txt: HIT / WAIVED / HOLE
#   make gate          report, non-zero exit on any unwaived hole or viol_ hit
#   make soak SEEDS=n  WRP-6 soak, one coverage file per seed
#   STUB_RTC=1         verif/stubs/pl031_stub.v instead of the ARM PL031
#                      (no ARM IP needed; re-run with the real PL031 for sign-off)
#   BUILD_ROOT=<dir>   build directories on another disk (verilator_1core.mk)
#
# Benches (name = top module + its sources + the coverage models bound in):
#   fifo     FIFO/fifo_apb_adc_rand_tb            fsm      FSM/wrapper_control_seq_tb
#   adc      ADC/tb/sar_adc_tb                    adccal   ADC/tb/sar_adc_cal_tb
#   rtc      RTC/tb_rtc_control_rand              rtcdir   RTC/tb_rtc_control
#   rtcclo   RTC/tb_rtc_closure                   wrapper  Wrapper/adc_apb_wrapper_rand_tb
#   wrapdir  Wrapper/adc_apb_wrapper_rev2_tb      gap      Wrapper/sens_gap_tb
#   clo      Wrapper/sens_closure_tb              soak     Wrapper/sens_soak_tb (per seed)
#   rob      Wrapper/sens_rob_tb (code coverage only: it forces illegal states,
#            which the viol_ state bins of the functional models would flag)
#
# Single-core by design - see ../verilator_1core.mk. Explicit file lists only.
# -----------------------------------------------------------------------------
include ../verilator_1core.mk

ROOT = ../..
OBJ  = $(if $(BUILD_ROOT),$(BUILD_ROOT)/cov,.)

ifeq ($(STUB_RTC),1)
  RTC_FILES = ../stubs/pl031_stub.v
  RTC_INC   = -DPL031_STUB
else
  RTC_FILES = $(shell find $(RTC_IP) -type f -name "*.v" 2>/dev/null)
  RTC_INC   = -I$(RTC_IP)
endif

# The SAR ADC: synthesisable sar_adc + latch + sarlogic, plus the sim-only
# nand2 cell and behavioural sar_afe models.
ADC_FILES  = $(ROOT)/ADC/sar_adc.v $(ROOT)/ADC/sar_comp_latch.v \
             $(ROOT)/../analog/cadence/sar_adc/sarlogic/functional/verilog.v \
             $(ROOT)/ADC/sim/sky130_fd_sc_hd__nand2_1.v $(ROOT)/ADC/sim/sar_afe_model.v
RTC_DUT    = $(ROOT)/RTC/rtc_control_2.v $(RTC_FILES)
SENS_DUT   = $(ROOT)/Wrapper/adc_apb_wrapper_rev2.v \
             $(ROOT)/FSM/wrapper_control_2.v $(ROOT)/FIFO/fifo_apb_adc.v \
             $(ADC_FILES) $(ROOT)/Dummy/dummy_amux.v $(ROOT)/Dummy/dummy_pll.v \
             $(RTC_DUT)
SVA        = ../sensing_assertions.sv

# nanosoc gap-coverage models (nanosoc/system/verif/cov) ride along on the
# wrapper / rtc runs so the block benches measure them too.
NSC_DIR    = $(ROOT)/../nanosoc/system/verif/cov
NSC_WRAP   = $(NSC_DIR)/nsc_sens_apb_cov.sv $(NSC_DIR)/nsc_rtc_boundary_cov.sv $(NSC_DIR)/nsc_bind_sensing.sv
NSC_RTC    = $(NSC_DIR)/nsc_rtc_boundary_cov.sv $(NSC_DIR)/nsc_rtc_bind_only.sv
WRAP_COV   = fifo_cov.sv fsm_cov.sv rtc_cov.sv wrapper_cov.sv sar_cov.sv $(NSC_WRAP)
RTC_COV    = rtc_cov.sv $(NSC_RTC)

DEFS = -DSIMULATION

# ---- bench table: TOP, SRC (bench + DUT), COV (models, functional build only),
# ---- FLG (verilator flags, both builds), FFLG (functional build only), RUN (plusargs)
B_fifo_TOP    = fifo_apb_adc_rand_tb
B_fifo_SRC    = $(ROOT)/FIFO/fifo_apb_adc_rand_tb.v $(ROOT)/FIFO/fifo_apb_adc.v
B_fifo_COV    = fifo_cov.sv $(SVA)
B_fifo_FFLG   = --assert

B_fsm_TOP     = wrapper_control_seq_tb
B_fsm_SRC     = $(ROOT)/FSM/wrapper_control_seq_tb.v $(ROOT)/FSM/wrapper_control_2.v $(ROOT)/Dummy/dummy_adc.v
B_fsm_COV     = fsm_cov.sv $(SVA)
B_fsm_FFLG    = --assert -DSVA_FSM_UNIT

B_adc_TOP     = sar_adc_tb
B_adc_SRC     = $(ROOT)/ADC/tb/sar_adc_tb.v $(ADC_FILES) $(ROOT)/FSM/wrapper_control_2.v
B_adc_COV     = sar_cov.sv fsm_cov.sv $(SVA)
B_adc_FFLG    = --assert

B_adccal_TOP  = sar_adc_cal_tb
B_adccal_SRC  = $(ROOT)/ADC/tb/sar_adc_cal_tb.sv $(ADC_FILES)
B_adccal_COV  = sar_cov.sv $(SVA)
B_adccal_FFLG = --assert

B_rtc_TOP     = tb_rtc_control_rand
B_rtc_SRC     = $(ROOT)/RTC/tb_rtc_control_rand.v $(RTC_DUT)
B_rtc_COV     = $(RTC_COV)
B_rtc_FLG     = $(RTC_INC)

B_rtcdir_TOP  = tb_rtc_control
B_rtcdir_SRC  = $(ROOT)/RTC/tb_rtc_control.v $(RTC_DUT)
B_rtcdir_COV  = $(RTC_COV)
B_rtcdir_FLG  = $(RTC_INC)

B_rtcclo_TOP  = tb_rtc_closure
B_rtcclo_SRC  = $(ROOT)/RTC/tb_rtc_closure.sv $(RTC_DUT)
B_rtcclo_COV  = $(RTC_COV) $(SVA)
B_rtcclo_FLG  = $(RTC_INC)
B_rtcclo_FFLG = --assert

B_wrapper_TOP = adc_apb_wrapper_rand_tb
B_wrapper_SRC = $(ROOT)/Wrapper/adc_apb_wrapper_rand_tb.v $(SENS_DUT)
B_wrapper_COV = $(WRAP_COV) $(SVA)
B_wrapper_FLG = $(RTC_INC)
B_wrapper_FFLG = --assert

B_wrapdir_TOP = adc_apb_wrapper_rev2_tb
B_wrapdir_SRC = $(ROOT)/Wrapper/adc_apb_wrapper_rev2_tb.v $(SENS_DUT)
B_wrapdir_COV = $(WRAP_COV) $(SVA)
B_wrapdir_FLG = $(RTC_INC)
B_wrapdir_FFLG = --assert

B_gap_TOP     = sens_gap_tb
B_gap_SRC     = $(ROOT)/Wrapper/sens_gap_tb.sv $(SENS_DUT)
B_gap_COV     = $(WRAP_COV) $(SVA)
B_gap_FLG     = $(RTC_INC)
B_gap_FFLG    = --assert

B_clo_TOP     = sens_closure_tb
B_clo_SRC     = $(ROOT)/Wrapper/sens_closure_tb.sv $(SENS_DUT)
B_clo_COV     = $(WRAP_COV) $(SVA)
B_clo_FLG     = $(RTC_INC)
B_clo_FFLG    = --assert

B_soak_TOP    = sens_soak_tb
B_soak_SRC    = $(ROOT)/Wrapper/sens_soak_tb.sv $(SENS_DUT)
B_soak_COV    = $(WRAP_COV) $(SVA)
B_soak_FLG    = $(RTC_INC)
B_soak_FFLG   = --assert

B_rob_TOP     = sens_rob_tb
B_rob_SRC     = $(ROOT)/Wrapper/sens_rob_tb.sv $(SENS_DUT)
B_rob_FLG     = $(RTC_INC)

FREE_BENCHES = fifo fsm adc adccal
IP_BENCHES   = rtc rtcdir rtcclo wrapper wrapdir gap clo
BENCHES      = $(FREE_BENCHES) $(IP_BENCHES)
CODE_BENCHES = $(BENCHES) soak rob

# Soak seeds collected for coverage here (the 10-seed pass/fail soak is
# `make -C ../../Wrapper soak`; these runs are the same bench with the models).
SEEDS     ?= 3
SEED_LIST  = $(shell seq 1 $(SEEDS))

.PHONY: $(BENCHES) soak $(addprefix code_,$(CODE_BENCHES)) free all code report gate holes code_report clean
.NOTPARALLEL:

# ---- functional (covergroups + SVA) -----------------------------------------
define func_build
	@echo "===== COVERAGE: $(1) ====="
	@mkdir -p $(OBJ)
	@rm -f coverage_$(1)*.dat
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) --coverage-user $(DEFS) $(B_$(1)_FLG) $(B_$(1)_FFLG) \
	    --Mdir $(OBJ)/obj_$(1) --top $(B_$(1)_TOP) -o V$(1) $(B_$(1)_SRC) $(B_$(1)_COV) > build_$(1).log 2>&1 \
	    || { tail -30 build_$(1).log; false; }
endef

$(BENCHES):
	$(call func_build,$@)
	$(OBJ)/obj_$@/V$@ $(B_$@_RUN) +verilator+coverage+file+coverage_$@.dat > run_$@.log 2>&1; \
	    grep -E "^FAIL|TIMEOUT|%Error|Assertion|=== " run_$@.log | tail -40
	@test -s coverage_$@.dat || { echo "ERROR: $@ wrote no coverage file (did the run abort?)"; tail -5 run_$@.log; false; }

soak:
	$(call func_build,soak)
	@for s in $(SEED_LIST); do \
	    $(OBJ)/obj_soak/Vsoak +seed=$$s +verilator+coverage+file+coverage_soak_$$s.dat > run_soak_$$s.log 2>&1; \
	    grep -E "^FAIL|TIMEOUT|%Error|Assertion|=== " run_soak_$$s.log | tail -20; \
	    test -s coverage_soak_$$s.dat || { echo "ERROR: soak seed $$s wrote no coverage file"; exit 1; }; \
	done

# ---- code coverage (line / branch / toggle; no covergroup models) -----------
$(addprefix code_,$(CODE_BENCHES)): code_%:
	@echo "===== CODE COVERAGE: $* ====="
	@mkdir -p $(OBJ)
	@rm -f coverage_$*_code.dat
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) --coverage-line --coverage-toggle $(DEFS) $(B_$*_FLG) \
	    --Mdir $(OBJ)/obj_$*_code --top $(B_$*_TOP) -o V$*_code $(B_$*_SRC) > build_$*_code.log 2>&1 \
	    || { tail -30 build_$*_code.log; false; }
	$(OBJ)/obj_$*_code/V$*_code $(B_$*_RUN) +verilator+coverage+file+coverage_$*_code.dat > run_$*_code.log 2>&1; \
	    grep -E "TIMEOUT|%Error|=== " run_$*_code.log | tail -5
	@test -s coverage_$*_code.dat || { echo "ERROR: code_$* wrote no coverage file"; tail -5 run_$*_code.log; false; }

# ---- groups (sequential - one core) -----------------------------------------
free:
	$(foreach b,$(FREE_BENCHES),$(MAKE) $(b) &&) true
	$(MAKE) report

all:
	$(foreach b,$(BENCHES),$(MAKE) $(b) &&) true
	$(MAKE) soak
	$(MAKE) report

code:
	$(foreach b,$(CODE_BENCHES),$(MAKE) code_$(b) &&) true
	$(MAKE) code_report

# ---- reports -----------------------------------------------------------------
# The UVM benches write their own coverage.dat; merge them when present.
UVM_DATS = $(wildcard ../uvm/fifo/coverage.dat ../uvm/wrapper/coverage.dat)
FUNC_DATS = $(filter-out %_code.dat,$(wildcard coverage_*.dat))
CODE_DATS = $(wildcard coverage_*_code.dat)

merged.dat: FORCE
	verilator_coverage --write merged.dat $(FUNC_DATS) $(UVM_DATS)

report: merged.dat
	@echo "===== MERGED FUNCTIONAL COVERAGE: $(words $(FUNC_DATS)) block runs + $(words $(UVM_DATS)) UVM runs ====="
	@python3 holes.py merged.dat

gate: merged.dat
	@echo "===== FUNCTIONAL COVERAGE GATE: $(words $(FUNC_DATS)) block runs + $(words $(UVM_DATS)) UVM runs ====="
	@python3 holes.py merged.dat --all --gate

holes: merged.dat
	@python3 holes.py merged.dat --all

code_report:
	verilator_coverage --write merged_code.dat $(CODE_DATS)
	@echo "===== CODE COVERAGE (line + branch per source line, union over instances and runs) ====="
	@rm -rf annotate && verilator_coverage --annotate annotate --annotate-min 1 merged_code.dat > /dev/null
	@echo "Annotated sources: verif/cov/annotate/ (per-instance view; the gate below is the union)"
	@python3 code_holes.py merged_code.dat --gate

FORCE:

clean:
	rm -rf $(OBJ)/obj_* obj_* coverage_*.dat merged.dat merged_code.dat annotate build_*.log run_*.log *.vcd
