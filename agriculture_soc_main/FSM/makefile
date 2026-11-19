# -----------------------------------------------------------------------------
# FSM/makefile - wrapper_control_2 (sampling FSM) unit benches (no ARM IP).
#   make        wrapper_control_2_tb    hand-driven adc_valid handshake
#   make seq    wrapper_control_seq_tb  sequencing / coverage / random, FSM-1..4
# Explicit lists (do NOT glob - the dir holds several testbenches and the
# superseded wrapper_control.v). One core / BUILD_ROOT: ../verif/block_tb.mk.
# -----------------------------------------------------------------------------
include ../verif/block_tb.mk

ALL_FILES = ./wrapper_control_2_tb.v ./wrapper_control_2.v
SEQ_FILES = ./wrapper_control_seq_tb.v ./wrapper_control_2.v ../Dummy/dummy_adc.v

.PHONY: all seq clean

all:
	$(call tb_run,fsm,wrapper_control_2_tb,$(ALL_FILES),--trace,)

seq:
	$(call tb_run,fsm_seq,wrapper_control_seq_tb,$(SEQ_FILES) $(SVA_FILE),--trace --assert -DSVA_FSM_UNIT,)

clean:
	rm -rf $(OBJ)/obj_fsm* obj_dir build_*.log waveform.vcd
