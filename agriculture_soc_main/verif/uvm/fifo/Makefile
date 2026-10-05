# -----------------------------------------------------------------------------
# verif/uvm/fifo/Makefile — UVM bench for fifo_apb_adc (no ARM IP needed).
#
#   make                       build + run fifo_full_test (with coverage)
#   make TEST=fifo_smoke_test  pick a test
#   make SEED=1234             different random seed (no rebuild needed)
#   make run                   re-run the existing binary (no rebuild)
#   make report                coverage summary + holes for the last run
#
# The first build compiles the whole UVM library and is slow on one core
# (see ../../verilator_1core.mk); later builds reuse ccache.
# -----------------------------------------------------------------------------
include ../../verilator_1core.mk

ROOT   = ../../..
TOP    = fifo_tb_top
TEST  ?= fifo_full_test
SEED  ?= 1
VERB  ?= UVM_LOW

FILES = $(VL_UVM) \
        fifo_if.sv fifo_uvm_pkg.sv fifo_tb_top.sv \
        $(ROOT)/FIFO/fifo_apb_adc.v \
        ../../cov/fifo_cov.sv

.PHONY: all build run report clean

all: build run report

build:
	@echo "===== BUILD $(TOP) (single core; first UVM build is slow) ====="
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(VL_COV_UVM) --top $(TOP) -o V$(TOP) \
	    $(FILES) > build.log 2>&1 || { grep -E "^%Error" build.log | head -30; tail -5 build.log; false; }
	@grep -c "^%Warning" build.log | xargs echo "warnings (see build.log):"

run:
	./obj_dir/V$(TOP) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) +verilator+seed+$(SEED) \
	    +verilator+coverage+file+coverage.dat | tee run.log

report:
	@python3 ../../cov/holes.py coverage.dat

clean:
	rm -rf obj_dir build.log run.log coverage.dat
