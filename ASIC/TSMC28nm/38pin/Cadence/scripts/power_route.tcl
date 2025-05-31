##################################
# Script : Special Route Script 
# Date : May 24, 2023 
# Description : Power Routing 
# Author : Srimanth Tenneti 
##################################
set_db route_special_via_connect_to_shape { padring stripe }
sroute -connect {blockPin corePin floatingStripe} -layerChangeRange { M1(1) AP(9) } -blockPinTarget nearestTarget -padPinPortConnect {allPort oneGeom} -padPinTarget nearestTarget -corePinTarget firstAfterRowEnd -floatingStripeTarget {blockRing padRing ring stripe ringPin blockPin followpin} -allowJogging 1 -powerDomains { ACCEL } -crossoverViaLayerRange { M1(1) AP(9) } -nets { VDDACC VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { M1(1) AP(9) }
sroute -connect {blockPin corePin floatingStripe} -layerChangeRange { M1(1) AP(9) } -blockPinTarget nearestTarget -padPinPortConnect {allPort oneGeom} -padPinTarget nearestTarget -corePinTarget firstAfterRowEnd -floatingStripeTarget {blockRing padRing ring stripe ringPin blockPin followpin} -allowJogging 1 -powerDomains { TOP } -crossoverViaLayerRange { M1(1) AP(9) } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { M1(1) AP(9) }
#route_special -connect {block_pin core_pin floating_stripe} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target first_after_row_end -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { PD_SYS } -crossover_via_layer_range { M1(1) AP(10) } -nets { VDD_SYS VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { M1(1) AP(10) }
#route_special -connect {block_pin core_pin floating_stripe} -layer_change_range { M1(1) AP(10) } -block_pin_target nearest_target -pad_pin_port_connect {all_port one_geom} -pad_pin_target nearest_target -core_pin_target first_after_row_end -floating_stripe_target {block_ring pad_ring ring stripe ring_pin block_pin followpin} -allow_jogging 1 -power_domains { PD_DBG } -crossover_via_layer_range { M1(1) AP(10) } -nets { VDD_DBG VSS } -allow_layer_change 1 -block_pin use_lef -target_via_layer_range { M1(1) AP(10) }

#route_special  -nets {VDD VSS} -connect core_pin  -block_pin_target nearest_target -core_pin_target first_after_row_end  -allow_jogging 1 -allow_layer_change 1 -layer_change_range { M1(1) M8(8) } -crossover_via_layer_range { M1(1) M8(8) } -target_via_layer_range { M1(1) M8(8) }
