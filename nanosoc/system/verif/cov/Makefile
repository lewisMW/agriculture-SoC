# -----------------------------------------------------------------------------
# nanosoc/system/verif/cov/Makefile — system-level functional coverage.
#
# The coverage models (*.sv here, listed in nanosoc_cov.flist, attached with
# `bind` in nanosoc_cov_bind.sv) observe the nanosoc RTL without modifying it.
#
# 1) Real flow (licensed ARM IP, Xcelium/VCS/Questa): add the flist to the
#    simulator command line, e.g. for the nanosoc makefiles
#        -f $(SOCLABS_PROJECT_DIR)/system/verif/cov/nanosoc_cov.flist
#    and enable covergroup collection (xrun -cov U / vcs -cm ... ). Nothing in
#    the RTL or in nanosoc_tb needs to change. (iverilog — the socsim default —
#    does not support covergroups/bind; use one of the above or Verilator.)
#
# 2) This machine (no ARM IP): Verilator harness with ARM stand-ins
#        make build              compile harness + coverage (single core)
#        make run ADP=<file>     stream an existing ADP command file
#                                (default: system/testcodes/adp_v4_cmd_tests/adp.cmd)
#        make runs               run every ADP command file in ADP_LIST, one by one
#        make adptests [T=name]  self-checking system tests (adp_tests/tests.py)
#        make report / holes     merged summary / every unhit bin
#    REAL_ARM=1 uses $(ARM_IP_LIBRARY_PATH) instead of harness/arm_stubs (and the
#    real PL031 instead of the stub). Coverage hit with the stubs only shows the
#    SoCLabs logic AROUND the ARM IP was exercised — see coverage_plan.md.
#
# Single core, low priority by design (shared machine; see the repo memory note).
# -----------------------------------------------------------------------------
COV_DIR      := $(abspath .)
NANOSOC_DIR  := $(abspath ../../..)
REPO_DIR     := $(abspath $(NANOSOC_DIR)/..)
HARNESS      := $(COV_DIR)/harness
BUILD        := $(COV_DIR)/build
RUNS         := $(COV_DIR)/runs

export SOCLABS_PROJECT_DIR          ?= $(NANOSOC_DIR)
export SOCLABS_NANOSOC_TECH_DIR     ?= $(NANOSOC_DIR)/nanosoc_tech
export SOCLABS_SLCOREM0_TECH_DIR    ?= $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/slcorem0_tech
export SOCLABS_SOCDEBUG_TECH_DIR    ?= $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/socdebug_tech
export SOCLABS_SLDMA230_TECH_DIR    ?= $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/sldma230_tech
export SOCLABS_GENERIC_LIB_TECH_DIR ?= $(NANOSOC_DIR)/generic_lib_tech
export SOCLABS_FPGA_LIB_TECH_DIR    ?= $(NANOSOC_DIR)/fpga_lib_tech
export SOCLABS_ASIC_LIB_TECH_DIR    ?= $(NANOSOC_DIR)/asic_lib_tech
export SOCLABS_PRIMITIVES_TECH_DIR  ?= $(NANOSOC_DIR)/rtl_primitives_tech
export ACCELERATOR_DIR              ?= $(REPO_DIR)/agriculture_soc_main
ifneq ($(REAL_ARM),1)
  export ARM_IP_LIBRARY_PATH := /nonexistent/arm_ip   # force the stand-ins
endif

VERILATOR ?= verilator
JOBS      ?= 1
MEMCAP_KB ?= 4000000
RUN_LIMITED = ulimit -v $(MEMCAP_KB); nice -n 19

ADP      ?= $(NANOSOC_DIR)/system/testcodes/adp_v4_cmd_tests/adp.cmd
# Every upstream nanosoc_tech/testcodes/*/adp.cmd is EMPTY, so with an idle
# CPU stub they all reduce to the streamer's fixed prologue (ESC, "A 20000000",
# "C 201" = debugger reset request). One of them stands for all; the only ADP
# file with real content is adp_v4_cmd_tests.
ADP_LIST ?= $(NANOSOC_DIR)/system/testcodes/adp_v4_cmd_tests/adp.cmd \
            $(SOCLABS_NANOSOC_TECH_DIR)/testcodes/bootloader/adp.cmd
MAX_CYCLES ?= 400000

VL_FLAGS = --binary --timing -j $(JOBS) --output-groups 20 -CFLAGS -O0 \
           -Wno-fatal -Wno-lint -Wno-style -Wno-ASSIGNIN \
           --coverage-user --top-module nsc_cov_harness_top \
           +define+BEHAVIORAL_PADS

.PHONY: build run runs adptests report holes clean

# dut.vc and obj_dir hold absolute paths and a host-linked binary. The checkout
# is shared between the dev container (/workspaces/...) and the WSL box
# (/mnt/c/...), so a build/ made on one is broken on the other. Wipe it when
# the checkout path it was generated for doesn't match this one.
ifneq ($(wildcard $(BUILD)/.root),)
  ifneq ($(shell cat $(BUILD)/.root),$(NANOSOC_DIR))
    $(shell rm -rf $(BUILD))
  endif
else ifneq ($(wildcard $(BUILD)/dut.vc),)
  $(shell rm -rf $(BUILD))
endif

$(BUILD)/dut.vc: $(NANOSOC_DIR)/flist/project/top.flist $(COV_DIR)/nanosoc_cov.flist $(wildcard $(COV_DIR)/*.sv) $(wildcard $(HARNESS)/*/*.v) $(HARNESS)/nsc_cov_harness_top.sv
	@mkdir -p $(BUILD)
	echo $(NANOSOC_DIR) > $(BUILD)/.root
	python3 $(COV_DIR)/flist_resolve.py $(NANOSOC_DIR)/flist/project/top.flist $(BUILD)/raw.vc --missing $(BUILD)/missing.txt
	python3 $(HARNESS)/dedupe_decls.py $(NANOSOC_DIR)/system/src/accelerator_subsystem.v $(BUILD)/accelerator_subsystem.v
	grep -v -e '/verif/tb/verilog/nanosoc_tb.v' -e '/bootrom/verilog/bootrom\.s\?v$$' \
	        -e '/system/src/accelerator_subsystem.v' $(BUILD)/raw.vc > $@
	echo $(BUILD)/accelerator_subsystem.v              >> $@
	echo $(HARNESS)/shims/bootrom_shim.v               >> $@
ifneq ($(REAL_ARM),1)
	echo $(HARNESS)/arm_stubs/arm_ip_stubs.v           >> $@
	echo $(ACCELERATOR_DIR)/verif/stubs/pl031_stub.v   >> $@
endif
	python3 $(COV_DIR)/flist_resolve.py $(COV_DIR)/nanosoc_cov.flist $(BUILD)/cov.vc
	cat $(BUILD)/cov.vc >> $@
	echo $(HARNESS)/nsc_cov_harness_top.sv             >> $@

build: $(BUILD)/dut.vc
	cd $(BUILD) && $(RUN_LIMITED) $(VERILATOR) $(VL_FLAGS) -f dut.vc -o Vnsc > build.log 2>&1 \
	    || { tail -40 $(BUILD)/build.log; false; }
	@grep -c "%Warning" $(BUILD)/build.log | xargs echo "build ok, warnings:"

# One run = one ADP command file. NAME defaults to the testcode directory name.
NAME ?= $(notdir $(patsubst %/,%,$(dir $(ADP))))
run:
	@test -x $(BUILD)/obj_dir/Vnsc || $(MAKE) build
	rm -rf $(RUNS)/$(NAME) && mkdir -p $(RUNS)/$(NAME)/logs
	cp $(ADP) $(RUNS)/$(NAME)/adp.cmd
	cd $(RUNS)/$(NAME) && $(RUN_LIMITED) $(BUILD)/obj_dir/Vnsc +max_cycles=$(MAX_CYCLES) \
	    +verilator+coverage+file+coverage.dat > sim.log 2>&1; tail -3 sim.log
	@cp $(RUNS)/$(NAME)/coverage.dat $(COV_DIR)/coverage_$(NAME).dat

runs:
	@for f in $(ADP_LIST); do $(MAKE) --no-print-directory run ADP=$$f || exit 1; done
	$(MAKE) --no-print-directory report

# Self-checking system tests (ADP debugger as bus master): adp_tests/tests.py.
# Each writes coverage_adp_<name>.dat; T=<name> runs one.
adptests:
	@test -x $(BUILD)/obj_dir/Vnsc || $(MAKE) build
	cd $(COV_DIR)/adp_tests && python3 tests.py $(T)
	$(MAKE) --no-print-directory report

report:
	verilator_coverage --write $(COV_DIR)/merged.dat $(COV_DIR)/coverage_*.dat
	@verilator_coverage --filter-type covergroup --report summary $(COV_DIR)/merged.dat | grep covergroup
	@python3 $(COV_DIR)/holes.py $(COV_DIR)/merged.dat --summary

holes:
	verilator_coverage --write $(COV_DIR)/merged.dat $(COV_DIR)/coverage_*.dat
	@python3 $(COV_DIR)/holes.py $(COV_DIR)/merged.dat --all

clean:
	rm -rf $(BUILD) $(RUNS) $(COV_DIR)/coverage_*.dat $(COV_DIR)/merged.dat
