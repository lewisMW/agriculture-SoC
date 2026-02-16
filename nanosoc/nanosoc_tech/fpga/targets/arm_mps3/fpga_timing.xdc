##################################################################################
##                                                                              ##
## Arm MPS3 Rev-C timing XDC                                                    ##
##                                                                              ##
##################################################################################

create_clock -period 100.000 -name CS_TCK -waveform {0.000 50.000} [get_ports CS_TCK]
create_clock -period 20.000 -name {OSCCLK[1]} -waveform {0.000 10.000} [get_ports {OSCCLK[1]}]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -min -add_delay 11.000 [get_ports {UART_RX_F[*]}]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -max -add_delay 15.000 [get_ports {UART_RX_F[*]}]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -min -add_delay 11.000 [get_ports CB_nRST]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -max -add_delay 15.000 [get_ports CB_nRST]
set_input_delay -clock [get_clocks CS_TCK] -min -add_delay 5.000 [get_ports CS_TMS]
set_input_delay -clock [get_clocks CS_TCK] -max -add_delay 9.000 [get_ports CS_TMS]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -min -add_delay 11.000 [get_ports CS_nSRST]
set_input_delay -clock [get_clocks {OSCCLK[1]}] -max -add_delay 15.000 [get_ports CS_nSRST]
set_output_delay -clock [get_clocks {OSCCLK[1]}] -min -add_delay -5.000 [get_ports {SH0_IO[*]}]
set_output_delay -clock [get_clocks {OSCCLK[1]}] -max -add_delay 15.000 [get_ports {SH0_IO[*]}]
set_output_delay -clock [get_clocks {OSCCLK[1]}] -min -add_delay 0.000 [get_ports {UART_TX_F[*]}]
set_output_delay -clock [get_clocks {OSCCLK[1]}] -max -add_delay 6.000 [get_ports {UART_TX_F[*]}]
set_output_delay -clock [get_clocks CS_TCK] -min -add_delay -1.000 [get_ports CS_TMS]
set_output_delay -clock [get_clocks CS_TCK] -max -add_delay 5.000 [get_ports CS_TMS]
