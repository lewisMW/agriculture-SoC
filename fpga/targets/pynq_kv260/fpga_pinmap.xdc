##################################################################################
##                                                                              ##
## KRIA KV260 PMOD XDC                                                          ##
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

######################## KV260 camera ########################

# PCAM MIPI ISP
#set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_isp_clk_p}]
#set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_isp_clk_n}]
#set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_isp_data_p[*]}]
#set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_isp_data_n[*]}]

#I2C signals --> I2C switch 0--> ISP AP1302 + Sensor AR1335
#I2C signals --> I2C switch 1--> Sensor AR1335
#I2C signals --> I2C switch 2--> Raspi Camera
#set_property PACKAGE_PIN G11 [get_ports iic_scl_io]
#set_property PACKAGE_PIN F10 [get_ports iic_sda_io]
#set_property IOSTANDARD LVCMOS33 [get_ports iic_*]

# Digilent PCAM 5C MIPI Camera Enable
#set_property PACKAGE_PIN F11      [get_ports "cam_gpio_tri_o[0]"] ;# Bank  45 VCCO - som240_1_b13 - IO_L6N_HDGC_45
#set_property IOSTANDARD LVCMOS33 [get_ports cam_gpio_tri_o[*]]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
