open_lib nanosoc_chip_pads.dlib/
open_block nanosoc_chip_pads

set_host_options -max_cores 16 -num_processes 16
source ../scripts/setup.tcl

set_stage -step route
route_auto

report_intermediate_step 04a_route_auto $REPORT_DIR
save_block 

add_via_mapping -from_icc_file $via_map_file


set_stage -step post_route 
route_opt
report_end_step 04b_route_opt $REPORT_DIR

create_stdcell_fillers -lib_cells \
 {FILL128_A7PP140ZTS_C30 \
 FILL32_A7PP140ZTS_C30 \
 FILL16_A7PP140ZTS_C30 \
 FILL4_A7PP140ZTS_C30\
 FILL3_A7PP140ZTS_C30 \
 FILL2_A7PP140ZTS_C30 \
 FILL1_A7PP140ZTS_C30 \
 }

save_block
save_lib nanosoc_chip_pads.dlib

exit