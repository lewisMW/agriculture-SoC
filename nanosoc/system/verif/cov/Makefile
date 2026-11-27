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
#    SoCLabs logic AROUND the ARM IP was exercised.
#
# Single core, low priority by design (shared machine).
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
# may be shared between two hosts that mount it at different paths
# (e.g. a container and a WSL host), so a build/ made on one is broken on the other. Wipe it when
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

# -----------------------------------------------------------------------------
# Firmware runs for chip-level coverage (SYS-4/SYS-5). A separate top
# (harness/nsc_fw_harness_top.sv) and build directory (build_fw/): the ADP
# targets above are unchanged.
#   make build_fw [REAL_ARM=1]      compile the firmware harness
#   make fw FW=<testcode>           run system/testcodes/<FW>/<FW>.hex (or the
#                                   upstream nanosoc_tech/testcodes one) as
#                                   image.hex; UART2 -> runs/fw_<FW>/logs/uart2.log;
#                                   coverage_fw_<FW>.dat; "=== FW-<FW>: ... ==="
#   make fws                        every image in FW_LIST, then report
# Build the .hex first with the testcode makefile (a toolchain without newlib
# cannot build it). Without REAL_ARM=1 the CPU is an idle stand-in: the run reaches
# FW_MAX_CYCLES with an empty uart2.log and reports FAILED - needs REAL_ARM=1.
# -----------------------------------------------------------------------------
BUILD_FW      := $(COV_DIR)/build_fw
FW_MAX_CYCLES ?= 40000000
UP_TESTCODES   = $(SOCLABS_NANOSOC_TECH_DIR)/testcodes
UART_CAPTURE   = $(SOCLABS_NANOSOC_TECH_DIR)/verif/trace/verilog/nanosoc_uart_capture.v
FW_LIST ?= adc_trigger_test fifo_drain_test sensing_driver_test rtc_time_test \
           adc_autonomous_test pslverr_test fault_recovery_test \
           sensing_regmap_test sensing_rtc_regs_test sensing_stress_test \
           sensing_sleep_poll_test sensing_reset_test sensing_cal_test \
           interrupt_demo sleep_demo watchdog_demo self_reset_demo default_slaves_tests \
           apb_mux_tests memory_tests romtable_tests uart_tests timer_tests dualtimer_demo gpio_tests

.PHONY: build_fw fw fws

build_fw: $(BUILD)/dut.vc
	@mkdir -p $(BUILD_FW)
	grep -v 'nsc_cov_harness_top.sv' $(BUILD)/dut.vc > $(BUILD_FW)/dut.vc
	grep -q 'nanosoc_uart_capture.v' $(BUILD_FW)/dut.vc || echo $(UART_CAPTURE) >> $(BUILD_FW)/dut.vc
	echo $(HARNESS)/nsc_fw_harness_top.sv >> $(BUILD_FW)/dut.vc
	cd $(BUILD_FW) && $(RUN_LIMITED) $(VERILATOR) $(subst nsc_cov_harness_top,nsc_fw_harness_top,$(VL_FLAGS)) \
	    -f dut.vc -o Vnsc_fw > build.log 2>&1 || { tail -40 $(BUILD_FW)/build.log; false; }
	@grep -c "%Warning" $(BUILD_FW)/build.log | xargs echo "build_fw ok, warnings:"

fw:
	@test -n "$(FW)" || { echo "usage: make fw FW=<testcode>"; false; }
	@test -x $(BUILD_FW)/obj_dir/Vnsc_fw || $(MAKE) build_fw
	@hex=$(NANOSOC_DIR)/system/testcodes/$(FW)/$(FW).hex; test -f $$hex || hex=$(UP_TESTCODES)/$(FW)/$(FW).hex; \
	 test -f $$hex || { echo "no $(FW).hex found (build the testcode first)"; false; }; \
	 rm -rf $(RUNS)/fw_$(FW) && mkdir -p $(RUNS)/fw_$(FW)/logs && cp $$hex $(RUNS)/fw_$(FW)/image.hex
	-cd $(RUNS)/fw_$(FW) && $(RUN_LIMITED) $(BUILD_FW)/obj_dir/Vnsc_fw +max_cycles=$(FW_MAX_CYCLES) \
	    +verilator+coverage+file+coverage.dat > sim.log 2>&1; tail -2 $(RUNS)/fw_$(FW)/sim.log
	@if [ -f $(RUNS)/fw_$(FW)/coverage.dat ]; then cp $(RUNS)/fw_$(FW)/coverage.dat $(COV_DIR)/coverage_fw_$(FW).dat; fi
	@u=$(RUNS)/fw_$(FW)/logs/uart2.log; p=0; f=1; \
	 if [ -f $$u ] && grep -q 'FAIL' $$u; then :; \
	 elif [ -f $$u ] && grep -qE 'TEST PASSED|Test Passed!|: PASS' $$u; then p=1; f=0; \
	 else echo "no pass line in $$u (idle CPU stand-in, hang, or max_cycles)"; fi; \
	 echo "=== FW-$(FW): $$p PASSED, $$f FAILED ==="

fws:
	@for t in $(FW_LIST); do $(MAKE) --no-print-directory fw FW=$$t; done
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
