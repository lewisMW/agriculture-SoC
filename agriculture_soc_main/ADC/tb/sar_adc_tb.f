// sar_adc_tb: sources, relative to the repo root (run from there).
// Synthesisable sar_adc
agriculture_soc_main/ADC/sar_adc.v
agriculture_soc_main/ADC/sar_comp_latch.v
analog/cadence/sar_adc/sarlogic/functional/verilog.v
// Simulation-only models: the nand2 cell and the sar_afe macro
agriculture_soc_main/ADC/sim/sky130_fd_sc_hd__nand2_1.v
agriculture_soc_main/ADC/sim/sar_afe_model.v
// The wrapper's sampling FSM, and the testbench
agriculture_soc_main/FSM/wrapper_control_2.v
agriculture_soc_main/ADC/tb/sar_adc_tb.v
