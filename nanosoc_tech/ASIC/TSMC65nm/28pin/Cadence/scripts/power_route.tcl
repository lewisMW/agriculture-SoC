##################################
# Script : Special Route Script 
# Date : May 24, 2023 
# Description : Power Routing 
# Author : Srimanth Tenneti 
##################################
route_special -connect {pad_pin pad_ring} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port all_geom} -pad_pin_target nearest_target -allow_jogging 1 -crossover_via_layer_range { M1(1) AP(10) } -nets { VDD VSS VDDACC } -allow_layer_change 1 -pad_pin_width 6 -target_via_layer_range { M1(1) AP(10) }

route_special -connect {block_pin core_pin floating_stripe} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target first_after_row_end -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { ACCEL } -crossover_via_layer_range { M1(1) AP(10) } -nets { VDDACC VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { M1(1) AP(10) }
route_special -connect {block_pin core_pin floating_stripe} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target first_after_row_end -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { TOP } -crossover_via_layer_range { M1(1) AP(10) } -nets { VDD VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { M1(1) AP(10) }

#route_special  -nets {VDD VSS} -connect core_pin  -block_pin_target nearest_target -core_pin_target first_after_row_end  -allow_jogging 1 -allow_layer_change 1 -layer_change_range { M1(1) M8(8) } -crossover_via_layer_range { M1(1) M8(8) } -target_via_layer_range { M1(1) M8(8) }
