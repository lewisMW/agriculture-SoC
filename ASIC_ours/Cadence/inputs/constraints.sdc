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
set_units -time ns;

set_units -capacitance pF;
set EXTCLK_PERIOD 30.0;
set SWDCLK_PERIOD [expr 4*$EXTCLK_PERIOD];
set CLK_ERROR 0.001; #50ppm crystal uncertainty
set INTER_CLOCK_UNCERTAINTY 0.01

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

# A: OUT      (soc to external)
# Y: IN       (external to soc)
# IE: INP_DIS (inverted: input enable == !input disable)
# OE: OE_N    (inverted: output enable == !output disable)

# set_multicycle_path 2 -from uPAD_SWDIO_IO/A -to uPAD_SWDIO_IO/Y 
# set_multicycle_path 2 -from uPAD_SWDIO_IO/IE -to uPAD_SWDIO_IO/Y 
# set_multicycle_path 2 -from uPAD_SWDIO_IO/OE -to uPAD_SWDIO_IO/Y 
set_multicycle_path 2 -from uPAD_SWDIO_IO/OUT -to uPAD_SWDIO_IO/IN 
set_multicycle_path 2 -from uPAD_SWDIO_IO/INP_DIS -to uPAD_SWDIO_IO/IN
set_multicycle_path 2 -from uPAD_SWDIO_IO/OE_N -to uPAD_SWDIO_IO/IN

set_multicycle_path 2 -through [get_pins uPAD_P0_*/PAD]
# set_multicycle_path 2 -from uPAD_P0_*/IE -to uPAD_P0_*/Y
# set_multicycle_path 2 -from uPAD_P0_*/OE -to uPAD_P0_*/Y
# set_multicycle_path 2 -from uPAD_P0_*/INP_DIS -to uPAD_P0_*/IN
# set_multicycle_path 2 -from uPAD_P0_*/OE_N -to uPAD_P0_*/IN

set_multicycle_path 2 -through [get_pins uPAD_P1_*/PAD]
# set_multicycle_path 2 -from uPAD_P1_*/IE -to uPAD_P1_*/Y
# set_multicycle_path 2 -from uPAD_P1_*/OE -to uPAD_P1_*/Y
# set_multicycle_path 2 -from uPAD_P1_*/INP_DIS -to uPAD_P1_*/IN
# set_multicycle_path 2 -from uPAD_P1_*/OE_N -to uPAD_P1_*/IN

# for the P0 and P1 GPIO ones, need to ignore the path that goes through externally
# ie from IE -> IN and OE -> IN again.
foreach uPAD_cell [get_db [get_cells -regexp "uPAD_P[01]_.*" -hierarchical] .name] {
    set_multicycle_path 2 -through [get_pins -regexp "${uPAD_cell}/(INP_DIS)|(IN)"]
    set_multicycle_path 2 -through [get_pins -regexp "${uPAD_cell}/(OE_N)|(IN)"]
}

#### DELAY DEFINITION

set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports NRST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports TEST]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports P0]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports P1]
set_input_delay -clock [get_clocks $SWDCLK] -add_delay 0.1 [get_ports SWDIO]

set_max_capacitance 3 [all_outputs]
set_max_fanout 10 [all_inputs]
