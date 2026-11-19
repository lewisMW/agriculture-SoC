# -----------------------------------------------------------------------------
# RTC/Makefile - rtc_control_2 block benches.
#   make        tb_rtc_control       directed (P01-P32)
#   make rand   tb_rtc_control_rand  constrained-random collision / liveness
#   make clo    tb_rtc_closure       closure tests RTC-1..RTC-12 (+ FIX-1) with
#                                    the bound SVA (--assert)
#   STUB_RTC=1  PL031 stand-in (no ARM IP; NOT sign-off) - otherwise the real
#               PL031 from ARM_IP_LIBRARY_PATH
# Explicit file lists: this directory also holds rtc_control.v, *_old.v and
# older testbenches, which must not be compiled in.
# One core / BUILD_ROOT: see ../verif/block_tb.mk.
# -----------------------------------------------------------------------------
include ../verif/block_tb.mk

RTC_DUT   = ./rtc_control_2.v $(RTC_FILES)
DIR_FILES = ./tb_rtc_control.v $(RTC_DUT)
RND_FILES = ./tb_rtc_control_rand.v $(RTC_DUT)
CLO_FILES = ./tb_rtc_closure.sv $(RTC_DUT) $(SVA_FILE)

RTC_FLAGS = $(RTC_INC) -Wno-WIDTHEXPAND

.PHONY: all rand clo clean

all:
	$(call tb_run,rtc,tb_rtc_control,$(DIR_FILES),$(RTC_FLAGS) --trace,)

rand:
	$(call tb_run,rtc_rand,tb_rtc_control_rand,$(RND_FILES),$(RTC_FLAGS) --trace,)

clo:
	$(call tb_run,rtc_clo,tb_rtc_closure,$(CLO_FILES),$(RTC_FLAGS) --assert,)

clean:
	rm -rf $(OBJ)/obj_rtc* obj_dir build_*.log waveform.vcd
