simulation_defs = -DSIMULATION

TB_MODULE = wrapper_control_tb

# Explicit lists (do NOT glob — the dir now holds two testbenches; globbing
# would pull both in as competing top-levels).
ALL_FILES = ./wrapper_control_tb.v ./wrapper_control.v

all:
	verilator --Wno-fatal --trace --exe --main --top $(TB_MODULE) $(ALL_FILES) --timing $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(TB_MODULE).mk;
	./obj_dir/V$(TB_MODULE);

# Rigorous sequencing/coverage unit test (uses the real dummy_adc handshake)
SEQ_MODULE = wrapper_control_seq_tb
SEQ_FILES  = ./wrapper_control_seq_tb.v ./wrapper_control.v ../Dummy/dummy_adc.v

seq:
	verilator --Wno-fatal --trace --exe --main --top $(SEQ_MODULE) $(SEQ_FILES) --timing $(simulation_defs);
	$(MAKE) -C obj_dir -f V$(SEQ_MODULE).mk;
	./obj_dir/V$(SEQ_MODULE);

clean:
	rm -rf obj_dir waveform.vcd
