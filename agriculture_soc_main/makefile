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
# The SAR ADC: sar_adc + latch + sarlogic (synthesisable), and the simulation-
# only models of its nand2 cells and of the sar_afe analog macro.
ADC_FILES = \
    ./ADC/sar_adc.v \
    ./ADC/sar_comp_latch.v \
    ../analog/cadence/sar_adc/sarlogic/functional/verilog.v
ADC_SIM_FILES = \
    ./ADC/sim/sky130_fd_sc_hd__nand2_1.v \
    ./ADC/sim/sar_afe_model.v

DESIGN_FILES = \
    ./agriculture_soc.v \
    ./agriculture_soc_tb.v \
    ./AHB/AHBDCD.v \
    ./AHB/AHBMUX.v \
    ./FIFO/fifo_apb_adc.v \
    ./FSM/wrapper_control_2.v \
    $(ADC_FILES) \
    $(ADC_SIM_FILES) \
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
# Full-SoC self-checking tests. `all` above (agriculture_soc_tb) is a pure
# smoke run with no pass/fail verdict — these two exercise the same fully-wired
# chip (real Cortex-M0 + CMSDK + AHB->APB bridge, not a directly-poked APB
# port) and actually check it:
#   make check       — liveness/integration checks (no LOCKUP, no PSLVERR,
#                       CLK1HZ alive, autonomous RTC->FSM->FIFO chain samples).
#   make reset_rand  — same postconditions, but only after a storm of
#                       randomly-timed async reset pulses (see
#                       agriculture_soc_reset_rand_tb.v).
# Both reuse code.hex exactly like `all` (see ROM_FILE fallback below).
# -----------------------------------------------------------------------------
CHECK_MODULE      = agriculture_soc_checked_tb
RESET_RAND_MODULE = agriculture_soc_reset_rand_tb

CHECK_DESIGN_FILES = $(filter-out ./agriculture_soc_tb.v,$(DESIGN_FILES)) ./agriculture_soc_checked_tb.v
CHECK_VERILOG_FILES = \
    $(CHECK_DESIGN_FILES) \
    $(shell find $(rtc_ip) -type f -name "*.v") \
    $(CM0_FILES) \
    $(CMSDK_FILES)

RESET_RAND_DESIGN_FILES = $(filter-out ./agriculture_soc_tb.v,$(DESIGN_FILES)) ./agriculture_soc_reset_rand_tb.v
RESET_RAND_VERILOG_FILES = \
    $(RESET_RAND_DESIGN_FILES) \
    $(shell find $(rtc_ip) -type f -name "*.v") \
    $(CM0_FILES) \
    $(CMSDK_FILES)

.PHONY: check reset_rand

check:
	verilator --Wno-fatal --trace --exe --main --top $(CHECK_MODULE) $(CHECK_VERILOG_FILES) --timing +libext+.v+.vlib $(ARM_INCDIRS) $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(CHECK_MODULE).mk;
	@if [ -f "$(ROM_FILE)" ]; then \
	    cp "$(ROM_FILE)" code.hex; echo "Loaded $(ROM_FILE) -> code.hex"; \
	elif [ -f code.hex ]; then \
	    echo "NOTE: $(ROM_FILE) not found (firmware not built) — running existing code.hex"; \
	else \
	    echo "ERROR: no $(ROM_FILE) and no existing code.hex to run"; exit 1; \
	fi
	./obj_dir/V$(CHECK_MODULE);

reset_rand:
	verilator --Wno-fatal --trace --exe --main --top $(RESET_RAND_MODULE) $(RESET_RAND_VERILOG_FILES) --timing +libext+.v+.vlib $(ARM_INCDIRS) $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(RESET_RAND_MODULE).mk;
	@if [ -f "$(ROM_FILE)" ]; then \
	    cp "$(ROM_FILE)" code.hex; echo "Loaded $(ROM_FILE) -> code.hex"; \
	elif [ -f code.hex ]; then \
	    echo "NOTE: $(ROM_FILE) not found (firmware not built) — running existing code.hex"; \
	else \
	    echo "ERROR: no $(ROM_FILE) and no existing code.hex to run"; exit 1; \
	fi
	./obj_dir/V$(RESET_RAND_MODULE);

# -----------------------------------------------------------------------------
# Unit-test regression and sign-off. One step table, in verif/signoff.py:
#
#   make verify        every bench (RTC/Wrapper need the PL031 or STUB_RTC=1;
#                      the full-SoC check/reset_rand need the Cortex-M0 kit and
#                      are SKIPPED without it)
#   make verify-free   only the benches that need no ARM IP
#   make signoff       verify + functional coverage gate + code coverage gate;
#                      writes verif/cov/SIGNOFF_REPORT.txt and
#                      verif/cov/OPEN_BUGS_REPORT.md
#   make signoff ONLY=gap,clo   a subset of steps (python3 verif/signoff.py --list)
#
#   STUB_RTC=1       PL031 stand-in (no ARM IP needed; verdict is marked STUB, not sign-off)
#   BUILD_ROOT=dir   build dirs + step logs on a local disk
#   OPEN_BUGS_OK=1   exit 0 when the only failures are [SUSPECTED RTL BUG <ID>]
#                    checks with <ID> in verif/cov/open_bugs.txt. They are still
#                    counted, still printed, and named in the verdict.
# A bench that does not print its "=== NAME: N PASSED, M FAILED ===" line
# (build failure, SVA abort, missing file) fails the run.
# -----------------------------------------------------------------------------
SIGNOFF = python3 verif/signoff.py $(if $(ONLY),--only $(ONLY))

.PHONY: verify verify-free signoff

verify:
	$(SIGNOFF) --benches

verify-free:
	$(SIGNOFF) --free

signoff:
	$(SIGNOFF)

# -----------------------------------------------------------------------------
# Lint (sign-off gate 2). Two scopes:
#   make lint-free  # peripheral RTL that needs no ARM IP (fast, vendor-noise-free)
#   make lint       # full sensing DUT incl. rtc_control + PL031 (needs ARM IP)
# Note: expect a few benign WIDTH/UNUSED to fix; the dummy analog stubs
# warn — waive or exclude those.
# -----------------------------------------------------------------------------
LINT_FREE_FILES = \
    ./FIFO/fifo_apb_adc.v \
    ./FSM/wrapper_control_2.v \
    $(ADC_FILES) \
    $(ADC_SIM_FILES) \
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

# -----------------------------------------------------------------------------
# Functional coverage (Verilator 5.052+ covergroups) and UVM benches.
# Everything below is single-core / nice'd / memory-capped (verif/verilator_1core.mk).
# Verilator 5.052 limitations and run notes are in the comments of each file under verif/.
#
#   make cov-free     FIFO + FSM coverage, merged report         (no ARM IP)
#   make cov          FIFO + FSM + RTC + Wrapper coverage         (ARM IP)
#   make uvm-fifo     FIFO UVM bench                              (no ARM IP)
#   make uvm-sensing  full peripheral UVM bench over APB          (ARM IP)
#   make uvm-sensing STUB_RTC=1   same, PL031 stand-in            (no ARM IP, smoke only)
# -----------------------------------------------------------------------------
.PHONY: cov-free cov uvm-fifo uvm-sensing

cov-free:
	$(MAKE) -C verif/cov free

cov:
	$(MAKE) -C verif/cov all

uvm-fifo:
	$(MAKE) -C verif/uvm/fifo

uvm-sensing:
	$(MAKE) -C verif/uvm/wrapper
