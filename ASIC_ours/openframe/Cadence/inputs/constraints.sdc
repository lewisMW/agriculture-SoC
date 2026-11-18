# Timing constraints for nanosoc in the OpenFrame wrapper. Same clocks and
# clock-domain exceptions as ../../../Cadence/inputs/constraints.sdc, with the
# pad-cell paths replaced by the wrapper's gpio_in/gpio_out ports.
set EXTCLK "clk";
set SWDCLK "swdclk";
set_units -time ns;
set_units -capacitance pF;
set EXTCLK_PERIOD 30.0;
# OF_CLK_PERIOD (environment, ns) overrides the period for a trial run; it has to be
# set for synthesis and for every place-and-route stage alike.
if {[info exists ::env(OF_CLK_PERIOD)]} { set EXTCLK_PERIOD $::env(OF_CLK_PERIOD) }
set SWDCLK_PERIOD [expr 4*$EXTCLK_PERIOD];
set CLK_ERROR 0.001; #50ppm crystal uncertainty
set INTER_CLOCK_UNCERTAINTY 0.01

# gpio 38 is CLK, gpio 20 is SWDCK (see ../../rtl/openframe_project_wrapper.v)
set CLK_PORT   [get_ports {gpio_in[38]}]
set SWDCK_PORT [get_ports {gpio_in[20]}]
create_clock -name "$EXTCLK" -period "$EXTCLK_PERIOD" -waveform "0 [expr $EXTCLK_PERIOD/2]" $CLK_PORT
create_clock -name "$SWDCLK" -period "$SWDCLK_PERIOD" -waveform "0 [expr $SWDCLK_PERIOD/2]" $SWDCK_PORT
set_clock_uncertainty $CLK_ERROR [get_clocks $EXTCLK]
set_clock_uncertainty $CLK_ERROR [get_clocks $SWDCLK]
set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $SWDCLK] -rise_to [get_clocks $EXTCLK]
set_clock_uncertainty -setup $INTER_CLOCK_UNCERTAINTY -rise_from [get_clocks $EXTCLK] -rise_to [get_clocks $SWDCLK]

# the ADC's generated clocks; its master clock is defined on the frame's gpio_in[38]
# here, not on a chip pin called CLK
set SAR_ADC_SOURCE {gpio_in[38]}
source $::env(ACCELERATOR_DIR)/ADC/sar_adc.sdc

# The RTC's tick. clk1hz_reg in nanosoc/system/src/accelerator_subsystem.v toggles
# every rtc_prescale system clocks (a register of the sensing peripheral) and
# clocks the RTC's counter and its reset synchroniser. Without a clock defined on
# it those flops are not timed at all and get no clock tree: a routed build had a
# removal violation of 0.1 ns on the counter's reset that only the gate-level
# simulation showed. The constraint is for the fastest setting, a toggle every
# cycle. The RTC meets the bus side through its own synchronisers, so the two
# clocks are declared asynchronous.
set CLK1HZ_DIV 1       ;# system clocks per half period, at the fastest rtc_prescale
set clk1hz_c [get_cells -quiet -hierarchical *clk1hz_reg_reg]
if {[sizeof_collection $clk1hz_c] != 1} {
    error "constraints.sdc: expected one clk1hz_reg_reg flop, found [sizeof_collection $clk1hz_c]"
}
set clk1hz_q [get_pins -quiet [get_object_name $clk1hz_c]/Q]
if {[sizeof_collection $clk1hz_q] == 0} {
    set clk1hz_q [get_pins -quiet [get_object_name $clk1hz_c]/q]    ;# Genus, before mapping
}
if {[sizeof_collection $clk1hz_q] != 1} {
    error "constraints.sdc: no Q pin on [get_object_name $clk1hz_c]"
}
create_generated_clock -name clk1hz -source $CLK_PORT -divide_by [expr {2 * $CLK1HZ_DIV}] $clk1hz_q
set_clock_groups -asynchronous -name clk1hz_async -group [get_clocks clk1hz] \
    -group [get_clocks [list $EXTCLK sar_clk sar_clkc]]

# SWD <-> system clock crossings are multicycle, as in the chip-level constraints
set_multicycle_path 2 -setup -end -from [get_clocks $SWDCLK] -to [get_clocks $EXTCLK]
set_multicycle_path 1 -hold  -end -from [get_clocks $SWDCLK] -to [get_clocks $EXTCLK]
set_multicycle_path 2 -setup -end -from [get_clocks $EXTCLK] -to [get_clocks $SWDCLK]
set_multicycle_path 1 -hold  -end -from [get_clocks $EXTCLK] -to [get_clocks $SWDCLK]
set_false_path -hold -from [get_clocks $EXTCLK] -to [get_clocks $SWDCLK]

# the GPIO ports: the pad is outside the wrapper now, so the port is the boundary
set_multicycle_path 2 -setup -through [get_ports {gpio_in[*]}]
set_multicycle_path 1 -hold  -through [get_ports {gpio_in[*]}]
set_multicycle_path 2 -setup -through [get_ports {gpio_out[*] gpio_oeb[*]}]
set_multicycle_path 1 -hold  -through [get_ports {gpio_out[*] gpio_oeb[*]}]

# reset from the frame; static pad configuration from the frame's constants
# (nrst = resetb_l AND porb_l, the reset pad and the frame's power-on reset)
set_false_path -setup -from [get_ports {resetb_l porb_l}]
# and its removal check: both are asynchronous to clk and go to the reset
# synchroniser (nanosoc_chip_cfg sync_nrst_sr), so a hold-side check against clk at
# the port means nothing. The chip-level constraints do not need this line only
# because the reset pad's delay happens to cover the 0.36 ns removal time.
set_false_path -hold -from [get_ports {resetb_l porb_l}]
set_ideal_network [get_ports {resetb_l porb_l}]
set_false_path -from [get_ports {gpio_loopback_one[*] gpio_loopback_zero[*]}]

# Flash programming (openframe_project_wrapper.v). The strap FLASH_PROG, GPIO 14,
# is static: it holds the chip in reset and switches four pads to the
# pass-through. The pass-through itself is combinational, pad to pad (the
# FTDI's CSB, SCK and SDI to the flash, the flash's IO1 back): 15 ns each way
# leaves an SPI clock of several MHz, the pads' own delays included.
set_false_path -from [get_ports {gpio_in[14]}]
set_max_delay 15 -from [get_ports {gpio_in[2] gpio_in[3] gpio_in[4] gpio_in[42]}] \
                 -to   [get_ports {gpio_out[1] gpio_out[39] gpio_out[40] gpio_out[41]}]
set_false_path -setup -through [get_nets soc_scan_mode]

set_input_delay  -clock [get_clocks $EXTCLK] -add_delay 0.1 [remove_from_collection [remove_from_collection [get_ports {gpio_in[*]}] $CLK_PORT] $SWDCK_PORT]
set_input_delay  -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports {resetb_l porb_l}]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.1 [get_ports {gpio_out[*] gpio_oeb[*]}]
set_max_capacitance 3 [all_outputs]
set_max_fanout 10 [all_inputs]
