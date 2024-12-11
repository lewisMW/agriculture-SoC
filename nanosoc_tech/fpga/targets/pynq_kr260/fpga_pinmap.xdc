##################################################################################
##                                                                              ##
## KR260 IO subset      XDC                                                     ##
##                                                                              ##
##################################################################################

######################## PMOD 1 Upper ########################
set_property PACKAGE_PIN H12 [get_ports {PMOD0_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_0}]
set_property PULLDOWN true [get_ports {PMOD0_0}];

set_property PACKAGE_PIN E10 [get_ports {PMOD0_1}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_1}]
set_property PULLDOWN true [get_ports {PMOD0_1}];

set_property PACKAGE_PIN D10 [get_ports {PMOD0_2}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_2}]
set_property PULLUP true [get_ports {PMOD0_2}];

set_property PACKAGE_PIN C11 [get_ports {PMOD0_3}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_3}]
set_property PULLUP true [get_ports {PMOD0_3}];

######################## PMOD 1 Lower ########################
set_property PACKAGE_PIN B10 [get_ports {PMOD0_4}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_4}]
set_property PULLUP true [get_ports {PMOD0_4}];

set_property PACKAGE_PIN E12 [get_ports {PMOD0_5}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_5}]
set_property PULLUP true [get_ports {PMOD0_5}];

set_property PACKAGE_PIN D11 [get_ports {PMOD0_6}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_6}]
set_property PULLUP true [get_ports {PMOD0_6}];

set_property PACKAGE_PIN B11 [get_ports {PMOD0_7}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_7}]
set_property PULLUP true [get_ports {PMOD0_7}];

## ######################## PMOD 2 Upper ########################
## set_property PACKAGE_PIN J11 [get_ports {PMOD1_0}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_0}]

## set_property PACKAGE_PIN J10 [get_ports {PMOD1_1}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_1}]

## set_property PACKAGE_PIN K13 [get_ports {PMOD1_2}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_2}]

## set_property PACKAGE_PIN K12 [get_ports {PMOD1_3}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_3}]

## ######################## PMOD 2 Lower ########################
## set_property PACKAGE_PIN H11 [get_ports {PMOD1_4}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_4}]

## set_property PACKAGE_PIN G10 [get_ports {PMOD1_5}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_5}]

## set_property PACKAGE_PIN F12 [get_ports {PMOD1_6}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_6}]

## set_property PACKAGE_PIN F11 [get_ports {PMOD1_7}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_7}]

## ######################## PMOD 3 Upper ########################
## set_property PACKAGE_PIN AE12 [get_ports {PMOD2_0}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_0}]

## set_property PACKAGE_PIN AF12 [get_ports {PMOD2_1}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_1}]

## set_property PACKAGE_PIN AG10 [get_ports {PMOD2_2}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_2}]

## set_property PACKAGE_PIN AH10 [get_ports {PMOD2_3}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_3}]

## ######################## PMOD 3 Lower ########################
## set_property PACKAGE_PIN AF11 [get_ports {PMOD2_4}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_4}]

## set_property PACKAGE_PIN AG11 [get_ports {PMOD2_5}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_5}]

## set_property PACKAGE_PIN AH12 [get_ports {PMOD2_6}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_6}]

## set_property PACKAGE_PIN AH11 [get_ports {PMOD2_7}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD2_7}]

## ######################## PMOD 4 Upper ########################
## set_property PACKAGE_PIN AC12 [get_ports {PMOD3_0}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_0}]

## set_property PACKAGE_PIN AD12 [get_ports {PMOD3_1}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_1}]

## set_property PACKAGE_PIN AE10 [get_ports {PMOD3_2}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_2}]

## set_property PACKAGE_PIN AF10 [get_ports {PMOD3_3}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_3}]

## ######################## PMOD 4 Lower ########################
## set_property PACKAGE_PIN AD11 [get_ports {PMOD3_4}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_4}]

## set_property PACKAGE_PIN AD10 [get_ports {PMOD3_5}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_5}]

## set_property PACKAGE_PIN AA11 [get_ports {PMOD3_6}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_6}]

## set_property PACKAGE_PIN AA10 [get_ports {PMOD3_7}]
## set_property IOSTANDARD LVCMOS33 [get_ports {PMOD3_7}]

  ######################## PMOD generic ########################
  set_property SLEW SLOW [get_ports PMOD*];
  set_property DRIVE 4 [get_ports PMOD*];

## ######################## Raspberry Pi GPIO Header ########################
## ### AXI GPIO ### 
## set_property PACKAGE_PIN AD15 [get_ports {rpi_gpio[0]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[0]}]

## set_property PACKAGE_PIN AD14 [get_ports {rpi_gpio[1]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[1]}]

## set_property PACKAGE_PIN AE15 [get_ports {rpi_gpio[2]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[2]}]

## set_property PACKAGE_PIN AE14 [get_ports {rpi_gpio[3]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[3]}]

## set_property PACKAGE_PIN AG14 [get_ports {rpi_gpio[4]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[4]}]

## set_property PACKAGE_PIN AH14 [get_ports {rpi_gpio[5]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[5]}]

## set_property PACKAGE_PIN AG13 [get_ports {rpi_gpio[6]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[6]}]

## set_property PACKAGE_PIN AH13 [get_ports {rpi_gpio[7]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[7]}]

## set_property PACKAGE_PIN AC14 [get_ports {rpi_gpio[8]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[8]}]

## set_property PACKAGE_PIN AC13 [get_ports {rpi_gpio[9]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[9]}]

## set_property PACKAGE_PIN AE13 [get_ports {rpi_gpio[10]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[10]}]

## set_property PACKAGE_PIN AF13 [get_ports {rpi_gpio[11]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[11]}]

## set_property PACKAGE_PIN AA13 [get_ports {rpi_gpio[12]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[12]}]

## set_property PACKAGE_PIN AB13 [get_ports {rpi_gpio[13]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[13]}]

## set_property PACKAGE_PIN W14 [get_ports {rpi_gpio[14]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[14]}]

## set_property PACKAGE_PIN W13 [get_ports {rpi_gpio[15]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[15]}]

## set_property PACKAGE_PIN AB15 [get_ports {rpi_gpio[16]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[16]}]

## set_property PACKAGE_PIN AB14 [get_ports {rpi_gpio[17]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[17]}]

## set_property PACKAGE_PIN Y14 [get_ports {rpi_gpio[18]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[18]}]

## set_property PACKAGE_PIN Y13 [get_ports {rpi_gpio[19]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[19]}]

## set_property PACKAGE_PIN W12 [get_ports {rpi_gpio[20]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[20]}]

## set_property PACKAGE_PIN W11 [get_ports {rpi_gpio[21]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[21]}]

## set_property PACKAGE_PIN Y12 [get_ports {rpi_gpio[22]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[22]}]

## set_property PACKAGE_PIN AA12 [get_ports {rpi_gpio[23]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[23]}]

## set_property PACKAGE_PIN Y9 [get_ports {rpi_gpio[24]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[24]}]

## set_property PACKAGE_PIN AA8 [get_ports {rpi_gpio[25]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[25]}]

## set_property PACKAGE_PIN AB10 [get_ports {rpi_gpio[26]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[26]}]

## set_property PACKAGE_PIN AB9 [get_ports {rpi_gpio[27]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio[27]}]

## ### Special Functions ###
## #set_property PACKAGE_PIN AD15 [get_ports {rpi_gpio0_id_sd}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio0_id_sd}]

## #set_property PACKAGE_PIN AD14 [get_ports {rpi_gpio1_id_sc}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio1_id_sc}]

## #set_property PACKAGE_PIN AE15 [get_ports {rpi_gpio2_sda}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio2_sda}]

## #set_property PACKAGE_PIN AE14 [get_ports {rpi_gpio3_scl}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio3_scl}]

## #set_property PACKAGE_PIN AG14 [get_ports {rpi_gpio4_gpclk0}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio4_gpclk0}]

## #set_property PACKAGE_PIN AH14 [get_ports {rpi_gpio5}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio5}]

## #set_property PACKAGE_PIN AG13 [get_ports {rpi_gpio6}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio6}]

## #set_property PACKAGE_PIN AH13 [get_ports {rpi_gpio7_ce1}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio7_ce1}]

## #set_property PACKAGE_PIN AC14 [get_ports {rpi_gpio8_ce0}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio8_ce0}]

## #set_property PACKAGE_PIN AC13 [get_ports {rpi_gpio9_miso}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio9_miso}]

## #set_property PACKAGE_PIN AE13 [get_ports {rpi_gpio10_mosi}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio10_mosi}]

## #set_property PACKAGE_PIN AF13 [get_ports {rpi_gpio11_sclk}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio11_sclk}]

## #set_property PACKAGE_PIN AA13 [get_ports {rpi_gpio12_pwm0}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio12_pwm0}]

## #set_property PACKAGE_PIN AB13 [get_ports {rpi_gpio13_pwm1}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio13_pwm1}]

## #set_property PACKAGE_PIN W14 [get_ports {rpi_gpio14_txd}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio14_txd}]

## #set_property PACKAGE_PIN W13 [get_ports {rpi_gpio15_rxd}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio15_rxd}]

## #set_property PACKAGE_PIN AB15 [get_ports {rpi_gpio16}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio16}]

## #set_property PACKAGE_PIN AB14 [get_ports {rpi_gpio17}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio17}]

## #set_property PACKAGE_PIN Y14 [get_ports {rpi_gpio18_pcm_clk}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio18_pcm_clk}]

## #set_property PACKAGE_PIN Y13 [get_ports {rpi_gpio19_pcm_fs}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio19_pcm_fs}]

## #set_property PACKAGE_PIN W12 [get_ports {rpi_gpio20_pcm_din}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio20_pcm_din}]

## #set_property PACKAGE_PIN W11 [get_ports {rpi_gpio21_pcm_dout}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio21_pcm_dout}]

## #set_property PACKAGE_PIN Y12 [get_ports {rpi_gpio22}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio22}]

## #set_property PACKAGE_PIN AA12 [get_ports {rpi_gpio23}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio23}]

## #set_property PACKAGE_PIN Y9 [get_ports {rpi_gpio24}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio24}]

## #set_property PACKAGE_PIN AA8 [get_ports {rpi_gpio25}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio25}]

## #set_property PACKAGE_PIN AB10 [get_ports {rpi_gpio26}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio26}]

## #set_property PACKAGE_PIN AB9 [get_ports {rpi_gpio27}]
## #set_property IOSTANDARD LVCMOS33 [get_ports {rpi_gpio27}]

## ######################## PMOD generic ########################
## set_property SLEW SLOW [get_ports rpi_*];
## set_property DRIVE 4 [get_ports rpi_*];
