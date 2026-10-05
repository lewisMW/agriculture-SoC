# -----------------------------------------------------------------------------
# verilator_1core.mk — shared Verilator settings for the coverage / UVM targets.
#
# EVERYTHING here is deliberately single-core and low-priority: a parallel UVM
# build (-j 0) once exhausted the RAM of the WSL dev machine and crashed it.
#   - -j 1                 one verilate thread, one C++ compile job
#   - --output-groups N    with -j 1 Verilator otherwise concatenates ALL the
#                          generated C++ into ONE translation unit (~300 MB for
#                          UVM -> one 3.5 GB+ g++ process). Too many groups is
#                          also bad: ~2000 tiny compiles each re-parse a big
#                          header (~2.5 h). ~20 groups is the sweet spot.
#   - -CFLAGS -O0          testbenches don't need optimised C++; -O0 compiles
#                          several times faster and uses far less memory
#   - nice -n 19           the build never starves the desktop
#   - ulimit -v            hard memory cap per build (KB); raise if a big UVM
#                          build is killed with "virtual memory exhausted"
# Override on the command line if you are on a bigger machine, e.g.
#   make JOBS=4 MEMCAP_KB=8000000
# -----------------------------------------------------------------------------
VERILATOR  ?= verilator
JOBS       ?= 1
MEMCAP_KB  ?= 3000000
UVM_HOME   ?= /opt/uvm

export MAKEFLAGS := -j$(JOBS)

# Prefix for every heavy command
RUN_LIMITED = ulimit -v $(MEMCAP_KB); nice -n 19

OUTPUT_GROUPS ?= 20

VL_COMMON = --binary --timing -j $(JOBS) --output-groups $(OUTPUT_GROUPS) -CFLAGS -O0 \
            -Wno-fatal -Wno-lint -Wno-style

# Functional coverage: covergroups are only written to coverage.dat when the
# model is built with coverage enabled (--coverage-user = covergroups + SVA cover).
#
# Code coverage (line / fsm) is OPT-IN with CODE_COV=1 and should be a SEPARATE
# run: in Verilator 5.052, adding --coverage-line to a covergroup build made
# some bins silently read 0 (rtc_cov cp_arm: 29 hits without it, 0 with it).
# Never trust covergroup numbers from a --coverage-line build.
ifeq ($(CODE_COV),1)
  VL_COV   = --coverage-line --coverage-fsm
else
  VL_COV   = --coverage-user
endif

# UVM benches: covergroups only (line coverage would also instrument the whole
# UVM library).
VL_COV_UVM = --coverage-user

VL_UVM     = +define+UVM_NO_DPI +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv

# ARM PL031 location (same path the RTC / Wrapper block makefiles use)
RTC_IP     = $(ARM_IP_LIBRARY_PATH)/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source
