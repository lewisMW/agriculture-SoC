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
set_units -capacitance pF;
set_units -power mW;
set EXTCLK_PERIOD 4166.67;
set SWDCLK_PERIOD [expr 4*$EXTCLK_PERIOD];
set CLK_ERROR 350; #Error calculated from worst case characteristics of CDCM61001 low-jitter oscillator chip at 250MHz
set INTER_CLOCK_UNCERTAINTY 100

### Power constraints
set_max_dynamic_power 20
set_max_leakage_power 0.1

create_clock -name "$EXTCLK" -period "$EXTCLK_PERIOD" -waveform "0 [expr $EXTCLK_PERIOD/2]" [get_ports CLK]
create_clock -name "$SWDCLK" -period "$SWDCLK_PERIOD" -waveform "0 [expr $SWDCLK_PERIOD/2]" [get_ports SWDCK]

set_clock_uncertainty $CLK_ERROR [get_clocks $EXTCLK]
set_clock_uncertainty $CLK_ERROR [get_clocks $SWDCLK]

set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $SWDCLK] -rise_to [get_clocks $EXTCLK]
set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $EXTCLK] -rise_to [get_clocks $SWDCLK]

### Multicycle path through asynchronous clock domains
set_multicycle_path 2 -setup -end -from SWDCK -to CLK
set_multicycle_path 1 -hold -end -from SWDCK -to CLK
set_multicycle_path 2 -setup -end -from CLK -to SWDCK
set_multicycle_path 1 -hold -end -from CLK -to SWDCK

set_false_path -hold -from CLK -to SWDCK

### Multicycle path through pads
set_false_path -through uPAD_SWDIO_IO
set_multicycle_path 2 -through uPAD_SWDIO_IO
#set_false_path -through uPAD_P0_*
#set_false_path -through uPAD_P1_*

set_multicycle_path 2 -from uPAD_SWDIO_IO/I -to uPAD_SWDIO_IO/C 
set_multicycle_path 2 -from uPAD_SWDIO_IO/IE -to uPAD_SWDIO_IO/C 
set_multicycle_path 2 -from uPAD_SWDIO_IO/DS -to uPAD_SWDIO_IO/C
set_multicycle_path 2 -from uPAD_SWDIO_IO/OEN -to uPAD_SWDIO_IO/C 

set_multicycle_path 2 -from uPAD_P0_*/I -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/IE -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/DS -to uPAD_P0_*/C
set_multicycle_path 2 -from uPAD_P0_*/OEN -to uPAD_P0_*/C

set_multicycle_path 2 -from uPAD_P1_*/I -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/IE -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/DS -to uPAD_P1_*/C
set_multicycle_path 2 -from uPAD_P1_*/OEN -to uPAD_P1_*/C

#### DELAY DEFINITION

set_input_delay -clock [get_clocks $EXTCLK] -add_delay 100 [get_ports NRST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 100 [get_ports TEST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 100 [get_ports P0]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 100 [get_ports P1]
set_input_delay -clock [get_clocks $SWDCLK] -add_delay 200 [get_ports SWDIO]

set_max_capacitance 3 [all_outputs]
set_max_fanout 10 [all_inputs]
