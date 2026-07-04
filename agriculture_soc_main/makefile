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
# testbenches (wrapper_control_tb, tb_rtc_control, fifo_apb_adc_tb, arm_rtc_tb,
# adc_apb_wrapper_rev1_tb) and legacy revisions (adc_apb_wrapper_rev0,
# rtc_control_old, rtc_control_tb_*) that collide / add extra top-levels.
DESIGN_FILES = \
    ./agriculture_soc.v \
    ./agriculture_soc_tb.v \
    ./AHB/AHBDCD.v \
    ./AHB/AHBMUX.v \
    ./FIFO/fifo_apb_adc.v \
    ./FSM/wrapper_control.v \
    ./Dummy/dummy_adc.v \
    ./Dummy/dummy_amux.v \
    ./Dummy/dummy_pll.v \
    ./RTC/rtc_control.v \
    ./Wrapper/adc_apb_wrapper_rev1.v

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
