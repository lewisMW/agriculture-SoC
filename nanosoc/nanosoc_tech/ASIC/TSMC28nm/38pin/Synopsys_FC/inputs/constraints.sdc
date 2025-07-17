#-----------------------------------------------------------------------------
# NanoSoC Constraints for Synthesis 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

#### CLOCK DEFINITION

set EXTCLK "clk";
set SWDCLK "swdclk";
set FCLK "FCLK";
set SYSCLK "sys_clk";
set HCLK "HCLK";
set DCLK "DCLK";
set_units -time ns;

set_units -capacitance pF;
set EXTCLK_PERIOD 4.16667; #240MHz Frequency
set SWDCLK_PERIOD [expr 4*$EXTCLK_PERIOD];
set CLK_ERROR 0.35; #Error calculated from worst case characteristics of CDCM61001 low-jitter oscillator chip at 250MHz
set INTER_CLOCK_UNCERTAINTY 0.1

create_clock -name "$EXTCLK" -period "$EXTCLK_PERIOD" -waveform "0 [expr $EXTCLK_PERIOD/2]" [get_ports CLK]
set_clock_transition [expr $clock_max_transition_factor * $EXTCLK_PERIOD] [get_clocks $EXTCLK]

create_clock -name "$SWDCLK" -period "$SWDCLK_PERIOD" -waveform "0 [expr $SWDCLK_PERIOD/2]" [get_ports SWDCK]
set_clock_transition [expr $clock_max_transition_factor * $SWDCLK_PERIOD] [get_clocks $SWDCLK]

set_clock_uncertainty $CLK_ERROR [get_clocks $EXTCLK]
set_clock_uncertainty $CLK_ERROR [get_clocks $SWDCLK]

set_clock_groups -asynchronous -name EXTERNAL_CLOCKS -allow_paths -group [list $EXTCLK $SWDCLK]

set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $SWDCLK] -rise_to [get_clocks $EXTCLK]
set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $EXTCLK] -rise_to [get_clocks $SWDCLK]

#create_generated_clock -source [get_ports CLK] -name "$SYSCLK"  -multiply_by 1 [get_pins u_nanosoc_chip/u_system/u_ss_cpu/u_cpu_0/u_core_prmu/u_cortexm0_pmu/u_fclk/CLKOUT]
#create_generated_clock -source [get_ports CLK] -name "$HCLK" -multiply_by 1 [get_pins u_nanosoc_chip/u_system/u_ss_cpu/u_cpu_0/u_core_prmu/u_cortexm0_pmu/u_hclk/CLKOUT]
#create_generated_clock -source [get_ports CLK] -name "$DCLK" -multiply_by 1 [get_pins u_nanosoc_chip/u_system/u_ss_cpu/u_cpu_0/u_core_prmu/u_cortexm0_pmu/u_dclk/CLKOUT]


### Multicycle path through asynchronous clock domains
set_multicycle_path 2 -setup -end -from [get_clocks $SWDCLK] -to [get_clocks $EXTCLK]
set_multicycle_path 1 -hold -end -from [get_clocks $SWDCLK] -to [get_clocks $EXTCLK]
set_multicycle_path 2 -setup -end -from [get_clocks $EXTCLK] -to [get_clocks $SWDCLK]
set_multicycle_path 1 -hold -end -from [get_clocks $EXTCLK] -to [get_clocks $SWDCLK]

set_false_path -hold -from [get_clocks $EXTCLK] -to [get_clocks $EXTCLK]

### Multicycle path through pads
set_false_path -through uPAD_SWDIO_IO
set_multicycle_path 2 -through uPAD_SWDIO_IO
#set_false_path -through uPAD_P0_*
#set_false_path -through uPAD_P1_*

set_multicycle_path 2 -from [get_pins uPAD_SWDIO_IO/I]     -to [get_pins uPAD_SWDIO_IO/C] 
set_multicycle_path 2 -from [get_pins uPAD_SWDIO_IO/IE]    -to [get_pins uPAD_SWDIO_IO/C] 
set_multicycle_path 2 -from [get_pins uPAD_SWDIO_IO/DS]    -to [get_pins uPAD_SWDIO_IO/C]
set_multicycle_path 2 -from [get_pins uPAD_SWDIO_IO/OEN]   -to [get_pins uPAD_SWDIO_IO/C] 

set_multicycle_path 2 -from uPAD_P0_*/I -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/IE -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/DS -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/OEN -to uPAD_P0_*/C

set_multicycle_path 2 -from uPAD_P1_*/I -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/IE -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/DS -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/OEN -to uPAD_P1_*/C

#### DELAY DEFINITION

set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports NRST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports TEST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports P0]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports P1]
set_input_delay -clock [get_clocks $SWDCLK] -add_delay 0.1 [get_ports SWDIO]

set_max_transition [expr $max_transition_factor * $EXTCLK_PERIOD] nanosoc_chip_pads

set_max_capacitance 3 [all_outputs]
set_max_fanout 10 [all_inputs]
