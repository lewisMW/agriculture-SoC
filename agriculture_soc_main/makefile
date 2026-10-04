# Full standalone SoC simulation.
#
# All ARM IP is sourced from ARM_IP_LIBRARY_PATH (the nanosoc_arm_ip kit) — the
# Cortex-M0 core, the CMSDK peripherals (Corstone-101/BP210) and the PL031 RTC
# all live under it. ARM_IP_LIBRARY_PATH must be set in your env (same var the
# RTC/Wrapper block sims already use). The old DESIGNSTART_DIR flow is no longer
# used here: that kit was incomplete/mislocated and this AT510-BU-50000 kit is
# the full (non-obfuscated) RTL.

ARM_IP  = $(ARM_IP_LIBRARY_PATH)
CM0_LOG = $(ARM_IP)/Cortex-M0/AT510-BU-50000-r0p0-03rel2/logical
CS_LOG  = $(ARM_IP)/Corstone-101/BP210-r1p1-00rel0/BP210-BU-00000-r1p1-00rel0/logical
rtc_ip  = $(ARM_IP)/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source

# Cortex-M0: core + DAP + integration + cell/wrapper models. Recurse the module
# dirs; drop *_defs.v (those are `include-only, not standalone modules).
CM0_FILES = $(shell find \
    $(CM0_LOG)/cortexm0 \
    $(CM0_LOG)/cortexm0_dap \
    $(CM0_LOG)/cortexm0_integration \
    $(CM0_LOG)/models \
    -name '*.v' ! -name '*_defs.v' 2>/dev/null)

# CMSDK peripherals instantiated by agriculture_soc.v (from Corstone-101/BP210)
# plus their sub-modules and the memory/clock-gate models. Dependency set taken
# from nanosoc's corstone101_ip.flist: cmsdk_ahb_gpio pulls in cmsdk_ahb_to_iop
# (same dir) and cmsdk_iop_gpio (separate dir); the peripherals use
# cmsdk_clock_gate (models/clkgate); the boot image loads via cmsdk_fpga_rom
# (models/memories).
CMSDK_FILES = $(shell find \
    $(CS_LOG)/cmsdk_ahb_to_sram \
    $(CS_LOG)/cmsdk_ahb_gpio \
    $(CS_LOG)/cmsdk_iop_gpio \
    $(CS_LOG)/cmsdk_ahb_to_apb \
    $(CS_LOG)/models/memories \
    $(CS_LOG)/models/clkgate \
    -name '*.v' ! -name '*_defs.v' 2>/dev/null)

# `include search dirs: every dir that holds ARM source (defs files sit next to
# their modules), plus the PL031 rtl_source and the ualdis disassembler. The
# ualdis/verilog files are `include-only (pulled in by cm0_tarmac.v for sim
# tracing) — added as an incdir, NOT compiled as sources.
ARM_INCDIRS = $(addprefix +incdir+,$(sort $(dir $(CM0_FILES) $(CMSDK_FILES)))) \
              +incdir+$(CM0_LOG)/ualdis/verilog \
              +incdir+$(rtc_ip)

simulation_defs = -DSIMULATION

TB_MODULE = agriculture_soc_tb

# ROM_FILE = ../software/hello/read_entire_fifo.hex
# ROM_FILE = ../software/hello/adc_trigger_test.hex
ROM_FILE = ../software/hello/write_test.hex

# Design files only — do NOT glob the tree. The sub-dirs contain per-block
# testbenches (wrapper_control_2_tb, tb_rtc_control, fifo_apb_adc_tb, arm_rtc_tb,
# adc_apb_wrapper_rev2_tb) and legacy revisions (adc_apb_wrapper_rev0,
# rtc_control, rtc_control_tb_*) that collide / add extra top-levels.
DESIGN_FILES = \
    ./agriculture_soc.v \
    ./agriculture_soc_tb.v \
    ./AHB/AHBDCD.v \
    ./AHB/AHBMUX.v \
    ./FIFO/fifo_apb_adc.v \
    ./FSM/wrapper_control_2.v \
    ./Dummy/dummy_adc.v \
    ./Dummy/dummy_amux.v \
    ./Dummy/dummy_pll.v \
    ./RTC/rtc_control_2.v \
    ./Wrapper/adc_apb_wrapper_rev2.v

VERILOG_FILES = \
    $(DESIGN_FILES) \
    $(shell find $(rtc_ip) -type f -name "*.v") \
    $(CM0_FILES) \
    $(CMSDK_FILES)

.PHONY: all clean

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(VERILOG_FILES) --timing +libext+.v+.vlib $(ARM_INCDIRS) $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	@if [ -f "$(ROM_FILE)" ]; then \
	    cp "$(ROM_FILE)" code.hex; echo "Loaded $(ROM_FILE) -> code.hex"; \
	elif [ -f code.hex ]; then \
	    echo "NOTE: $(ROM_FILE) not found (firmware not built) — running existing code.hex"; \
	else \
	    echo "ERROR: no $(ROM_FILE) and no existing code.hex to run"; exit 1; \
	fi
	./obj_dir/V$(TB_MODULE);

clean:
	rm -rf obj_dir code.hex *.vcd

# -----------------------------------------------------------------------------
# Unit-test regression. Runs every self-checking block testbench and aggregates
# the per-block "=== NAME: N PASSED, M FAILED ===" summary lines.
#
#   make verify        # full suite (RTC + Wrapper need ARM_IP_LIBRARY_PATH set)
#   make verify-free   # only the blocks that need no ARM IP (FIFO + FSM)
#
# Each block builds in its own dir/obj_dir, so there are no cross-block
# collisions. Failures in one block do not stop the others (leading '-').
# -----------------------------------------------------------------------------
VERIF_LOG = verif_run.log

.PHONY: verify verify-free _verify_summary

verify: _run_free _run_ip _verify_summary

verify-free: _run_free _verify_summary

_run_free:
	@rm -f $(VERIF_LOG)
	@echo "===== UNIT TEST REGRESSION ====="
	-@$(MAKE) --no-print-directory -C FIFO rand 2>&1 | tee -a $(VERIF_LOG)
	-@$(MAKE) --no-print-directory -C FSM  all  2>&1 | tee -a $(VERIF_LOG)
	-@$(MAKE) --no-print-directory -C FSM  seq  2>&1 | tee -a $(VERIF_LOG)

_run_ip:
	-@$(MAKE) --no-print-directory -C RTC     all  2>&1 | tee -a $(VERIF_LOG)
	-@$(MAKE) --no-print-directory -C Wrapper all  2>&1 | tee -a $(VERIF_LOG)
	-@$(MAKE) --no-print-directory -C Wrapper rand 2>&1 | tee -a $(VERIF_LOG)

_verify_summary:
	@echo ""
	@echo "===== REGRESSION SUMMARY ====="
	@grep -E "===.*PASSED,.*FAILED.*===" $(VERIF_LOG) || echo "(no summary lines — did a build fail? RTC/Wrapper need ARM_IP_LIBRARY_PATH)"
	@echo "=============================="
	@if grep -qE "[1-9][0-9]* FAILED" $(VERIF_LOG); then \
	    echo "RESULT: FAILURES PRESENT"; false; \
	 else \
	    echo "RESULT: ALL REPORTED SUITES PASS"; \
	 fi

# -----------------------------------------------------------------------------
# Lint (sign-off gate 2). Two scopes:
#   make lint-free  # peripheral RTL that needs no ARM IP (fast, vendor-noise-free)
#   make lint       # full sensing DUT incl. rtc_control + PL031 (needs ARM IP)
# HANDOFF note: expect a few benign WIDTH/UNUSED to fix; the dummy analog stubs
# warn — waive or exclude those.
# -----------------------------------------------------------------------------
LINT_FREE_FILES = \
    ./FIFO/fifo_apb_adc.v \
    ./FSM/wrapper_control_2.v \
    ./Dummy/dummy_adc.v \
    ./Dummy/dummy_amux.v \
    ./Dummy/dummy_pll.v

LINT_DUT_FILES = \
    ./Wrapper/adc_apb_wrapper_rev2.v \
    ./RTC/rtc_control_2.v \
    $(LINT_FREE_FILES) \
    $(shell find $(rtc_ip) -type f -name "*.v")

.PHONY: lint lint-free

lint-free:
	verilator --lint-only -Wall $(LINT_FREE_FILES)

lint:
	verilator --lint-only -Wall --top-module adc_apb_wrapper_rev2 $(LINT_DUT_FILES) $(ARM_INCDIRS)
