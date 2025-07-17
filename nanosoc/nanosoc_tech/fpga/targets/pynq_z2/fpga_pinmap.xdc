##################################################################################
##                                                                              ##
## PZ2 PMODA XDC                                                                ##
##                                                                              ##
##################################################################################


set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_0]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_1]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_2]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_3]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_4]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_5]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_6]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD0_7]

set_property PACKAGE_PIN Y18 [get_ports PMOD0_0]
set_property PACKAGE_PIN Y19 [get_ports PMOD0_1]
set_property PACKAGE_PIN Y16 [get_ports PMOD0_2]
set_property PACKAGE_PIN Y17 [get_ports PMOD0_3]
set_property PACKAGE_PIN U18 [get_ports PMOD0_4]
set_property PACKAGE_PIN U19 [get_ports PMOD0_5]
set_property PACKAGE_PIN W18 [get_ports PMOD0_6]
set_property PACKAGE_PIN W19 [get_ports PMOD0_7]

set_property PULLDOWN true [get_ports PMOD0_0]
set_property PULLDOWN true [get_ports PMOD0_1]
set_property PULLUP true [get_ports PMOD0_2]
set_property PULLUP true [get_ports PMOD0_3]
set_property PULLUP true [get_ports PMOD0_4]
set_property PULLUP true [get_ports PMOD0_5]
set_property PULLUP true [get_ports PMOD0_6]
set_property PULLUP true [get_ports PMOD0_7]

##set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PMOD0_7_IBUF]
