#-----------------------------------------------------------------------------
# sar_adc_top.sdc -- constraints for synthesising sar_adc on its own
# (sar_adc_genus.tcl). The block sees what it sees inside the chip: the chip's
# PCLK on clk, and adc_apb_wrapper_rev2's PCLK flops on its digital ports.
# The ADC's own constraints are sar_adc.sdc, sourced below exactly as the chip
# constraints source it.
#-----------------------------------------------------------------------------
set SAR_ADC_INST    ""
set SAR_ADC_MASTER  clk
set SAR_ADC_SOURCE  clk
set SAR_ADC_PERIOD  30.0        ;# ASIC_ours/Cadence/inputs/constraints.sdc: EXTCLK_PERIOD (33.3 MHz)
set SAR_ADC_CLK_DIV 4

set_units -time ns
set_units -capacitance pF

create_clock -name clk -period $SAR_ADC_PERIOD -waveform [list 0 [expr {$SAR_ADC_PERIOD / 2.0}]] [get_ports clk]
set_clock_uncertainty 0.001 [get_clocks clk]          ;# as the chip SDC (CLK_ERROR)

# en, cal and rstn come from PCLK flops (wrapper_control_2, cal_reg, the reset
# synchroniser); valid and result go to PCLK flops (the valid synchroniser and
# adc_sample). The 2 ns allows for wiring between the blocks.
set_input_delay  -clock clk 2.0 [get_ports {en cal rstn}]
set_output_delay -clock clk 0.0 [get_ports {valid result[*]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__dfrtp_1 -pin Q [get_ports {en cal rstn}]
set_load 0.005 [get_ports {valid result[*]}]

# The same line as in the chip constraints:
source $::env(ACCELERATOR_DIR)/ADC/sar_adc.sdc
