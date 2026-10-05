# -----------------------------------------------------------------------------
# verif/uvm/wrapper/Makefile — UVM bench for the whole sensing peripheral
# (adc_apb_wrapper_rev2: RTC controller + FSM + ADC + FIFO) over APB.
#
#   make                          build + run sensing_full_test (ARM IP needed)
#   make STUB_RTC=1               use the PL031 stand-in (no ARM IP; smoke only)
#   make TEST=sensing_smoke_test  pick a test
#   make SEED=1234                different random seed
#   make run / make report        re-run / coverage holes
#
# Sign-off results MUST come from a run against the real PL031:
#   export ARM_IP_LIBRARY_PATH=/path/to/nanosoc_arm_ip  &&  make
# -----------------------------------------------------------------------------
include ../../verilator_1core.mk

ROOT   = ../../..
TOP    = sensing_tb_top
TEST  ?= sensing_full_test
SEED  ?= 1
VERB  ?= UVM_LOW

ifeq ($(STUB_RTC),1)
  RTC_FILES = ../../stubs/pl031_stub.v
  RTC_INC   =
else
  ifeq ($(wildcard $(RTC_IP)),)
    $(error ARM PL031 not found at '$(RTC_IP)'. Set ARM_IP_LIBRARY_PATH, or use STUB_RTC=1 for a no-ARM smoke run)
  endif
  RTC_FILES = $(shell find $(RTC_IP) -type f -name "*.v")
  RTC_INC   = -I$(RTC_IP)
endif

FILES = $(VL_UVM) \
        ../apb/apb_if.sv sample_if.sv ../apb/apb_uvm_pkg.sv sensing_uvm_pkg.sv sensing_tb_top.sv \
        $(ROOT)/Wrapper/adc_apb_wrapper_rev2.v \
        $(ROOT)/FSM/wrapper_control_2.v \
        $(ROOT)/FIFO/fifo_apb_adc.v \
        $(ROOT)/Dummy/dummy_adc.v $(ROOT)/Dummy/dummy_amux.v $(ROOT)/Dummy/dummy_pll.v \
        $(ROOT)/RTC/rtc_control_2.v $(RTC_FILES) \
        ../../cov/fifo_cov.sv ../../cov/fsm_cov.sv ../../cov/rtc_cov.sv ../../cov/wrapper_cov.sv

.PHONY: all build run report clean

all: build run report

build:
	@echo "===== BUILD $(TOP) (single core; first UVM build is slow) ====="
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(VL_COV_UVM) -DSIMULATION $(RTC_INC) --top $(TOP) -o V$(TOP) \
	    $(FILES) > build.log 2>&1 || { grep -E "^%Error" build.log | head -30; tail -5 build.log; false; }
	@grep -c "^%Warning" build.log | xargs echo "warnings (see build.log):"

run:
	./obj_dir/V$(TOP) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) +verilator+seed+$(SEED) \
	    +verilator+coverage+file+coverage.dat | tee run.log

report:
	@python3 ../../cov/holes.py coverage.dat

clean:
	rm -rf obj_dir build.log run.log coverage.dat
