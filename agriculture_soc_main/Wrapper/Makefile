# -----------------------------------------------------------------------------
# Wrapper/Makefile - sensing peripheral (adc_apb_wrapper_rev2) integration
# benches: RTC controller + sampling FSM + SAR ADC + FIFO behind one APB slave.
#
#   make          adc_apb_wrapper_rev2_tb   directed
#   make rand     adc_apb_wrapper_rand_tb   constrained-random APB traffic
#   make sva      same as rand, with the bound SVA (--assert)
#   make gap      sens_gap_tb               coverage-gap tests T1-T13 (+SVA)
#   make clo      sens_closure_tb           closure tests WRP-1..5, ADC-6,
#                                           RTC-2/3/4/7/10 at wrapper level (+SVA)
#   make soak     sens_soak_tb              WRP-6: SEEDS seeds x >= 2000
#                                           autonomous periods, random APB
#                                           traffic, scoreboard, SVA
#   make params   WRP-7: directed + gap with ADDR_WIDTH=12, DEFAULT_ALARM_OFFSET=1
#   make adcdiv   ADC-6: closure bench at ADC_CLK_DIV = 1, 2, 8
#   make rob      ROB-1: illegal-state recovery (no coverage models bound)
#   make xsafe    ROB-2: directed bench with randomised initial values, 5 seeds
#
#   STUB_RTC=1    PL031 stand-in (no ARM IP; NOT sign-off)
# Explicit file lists - never glob (rev0/rev1 and other benches live here).
# One core / BUILD_ROOT: see ../verif/block_tb.mk.
# -----------------------------------------------------------------------------
include ../verif/block_tb.mk

DIR_FILES  = ./adc_apb_wrapper_rev2_tb.v $(SENS_DUT)
RAND_FILES = ./adc_apb_wrapper_rand_tb.v $(SENS_DUT)
GAP_FILES  = ./sens_gap_tb.sv $(SENS_DUT) $(SVA_FILE)
CLO_FILES  = ./sens_closure_tb.sv $(SENS_DUT) $(SVA_FILE)
SOAK_FILES = ./sens_soak_tb.sv $(SENS_DUT) $(SVA_FILE)
ROB_FILES  = ./sens_rob_tb.sv $(SENS_DUT)

SEEDS     ?= 10
SEED_LIST  = $(shell seq 1 $(SEEDS))
ADC_DIVS  ?= 1 2 8
X_SEEDS   ?= 1 2 3 4 5

.PHONY: all rand sva gap clo soak params adcdiv rob xsafe clean

all:
	$(call tb_run,wrap,adc_apb_wrapper_rev2_tb,$(DIR_FILES),$(RTC_INC) --trace,)

rand:
	$(call tb_run,wrap_rand,adc_apb_wrapper_rand_tb,$(RAND_FILES),$(RTC_INC) --trace,)

sva:
	$(call tb_run,wrap_sva,adc_apb_wrapper_rand_tb,$(RAND_FILES) $(SVA_FILE),$(RTC_INC) --assert,)

gap:
	$(call tb_run,wrap_gap,sens_gap_tb,$(GAP_FILES),$(RTC_INC) --assert,)

clo:
	$(call tb_run,wrap_clo,sens_closure_tb,$(CLO_FILES),$(RTC_INC) --assert,)

# One build, SEEDS runs.
soak:
	@mkdir -p $(OBJ)
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(TB_DEFS) $(RTC_INC) --assert --Mdir $(OBJ)/obj_wrap_soak \
	    --top sens_soak_tb -o Vwrap_soak $(SOAK_FILES) > build_wrap_soak.log 2>&1 \
	    || { tail -30 build_wrap_soak.log; false; }
	@for s in $(SEED_LIST); do $(OBJ)/obj_wrap_soak/Vwrap_soak +seed=$$s || exit 1; done

# WRP-7: the other value of each wrapper parameter (the default builds above
# are ADDR_WIDTH 12 / 16 with DEFAULT_ALARM_OFFSET 5).
params:
	$(call tb_run,wrap_p16,adc_apb_wrapper_rev2_tb,$(DIR_FILES),$(RTC_INC) -GADDR_WIDTH=16 -GDEFAULT_ALARM_OFFSET=1,)
	$(call tb_run,wrap_gap_p12,sens_gap_tb,$(GAP_FILES),$(RTC_INC) --assert -GAW=12 -GDEF_OFF=1,)

# ADC-6: every ADC clock divider.
adcdiv:
	$(foreach d,$(ADC_DIVS),$(call tb_run,wrap_clo_div$(d),sens_closure_tb,$(CLO_FILES),$(RTC_INC) --assert -GADC_CLK_DIV=$(d),+adc_only)$(newline))

rob:
	$(call tb_run,wrap_rob,sens_rob_tb,$(ROB_FILES),$(RTC_INC),)

# ROB-2: no dependence on uninitialised state.
xsafe:
	@mkdir -p $(OBJ)
	$(RUN_LIMITED) $(VERILATOR) $(VL_COMMON) $(TB_DEFS) $(RTC_INC) --x-initial unique --x-assign unique \
	    --Mdir $(OBJ)/obj_wrap_x --top adc_apb_wrapper_rev2_tb -o Vwrap_x $(DIR_FILES) > build_wrap_x.log 2>&1 \
	    || { tail -30 build_wrap_x.log; false; }
	@for s in $(X_SEEDS); do \
	    echo "--- xsafe seed $$s ---"; \
	    $(OBJ)/obj_wrap_x/Vwrap_x +verilator+rand+reset+2 +verilator+seed+$$s | grep -E "FAIL|TIMEOUT|===" \
	        | sed "s/=== WRAPPER:/=== WRAPPER-XSAFE[seed$$s]:/"; \
	done

clean:
	rm -rf $(OBJ)/obj_wrap* obj_dir build_*.log waveform.vcd *.vcd
