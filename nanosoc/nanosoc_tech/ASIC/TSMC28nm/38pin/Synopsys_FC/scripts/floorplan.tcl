set_attribute -objects [get_layers M1] -name routing_direction -value vertical 
set_attribute -objects [get_layers M2] -name routing_direction -value horizontal 
set_attribute -objects [get_layers M3] -name routing_direction -value vertical 
set_attribute -objects [get_layers M4] -name routing_direction -value horizontal 
set_attribute -objects [get_layers M5] -name routing_direction -value vertical 
set_attribute -objects [get_layers M6] -name routing_direction -value horizontal 
set_attribute -objects [get_layers M7] -name routing_direction -value vertical 
set_attribute -objects [get_layers M8] -name routing_direction -value horizontal 
set_attribute -objects [get_layers M9] -name routing_direction -value vertical 
set_attribute -objects [get_layers AP] -name routing_direction -value horizontal 

initialize_floorplan -control_type die -side_length {1111.111111 1666.666666} -core_offset {135} -site_def unit 
# -use_site_row
source ../floorplan/floorplan.tcl

remove_io_guides -all 


create_io_guide -name {main_io.top} -side top -line {{110.000 1666.500} 890.980} -offset {0.000 0.000} -pad_cells [list  \
  uPAD_TEST_I \
  uPAD_SWDCK_I \
  uPAD_VDD_3 \
  uPAD_VSS_3 \
  uPAD_VDDIO_3 \
  uPAD_P1_00 \
  uPAD_P1_01 \
]

create_io_guide -name {main_io.bottom} -side bottom -line {{1000.98 0.000} 890.980 } -offset {0.000 0.000} -pad_cells [list \
  uPAD_P0_02 \
  uPAD_VDDACC_1 \
  uPAD_SE_I \
  uPAD_VDD_1 \
  uPAD_VSS_1 \
  uPAD_P0_01 \
  uPAD_P0_00 \
]

create_io_guide -name {main_io.left} -side left -line {{0.000 110.000} 1446.500} -offset {0.000 0.000} -pad_cells [list \
  uPAD_P0_04 \
  uPAD_P0_05 \
  uPAD_P0_03 \
  uPAD_VDDACC_0 \
  uPAD_VSS_0 \
  uPAD_CLK_I \
  uPAD_VDD_0 \
  uPAD_VDDIO_0 \
  uPAD_SWDIO_IO \
  uPAD_VSSIO_0 \
  uPAD_P0_06 \
  uPAD_P0_07 \
]

create_io_guide -name {main_io.right} -side right -line {{1110.980 1556.500} 1446.500} -offset {0.000 0.000} -pad_cells [list \
  uPAD_P1_04 \
  uPAD_P1_05 \
  uPAD_NRST_I \
  uPAD_VDDIO_2 \
  uPAD_VSS_2 \
  uPAD_VDD_2 \
  uPAD_VDDACC_2 \
  uPAD_P1_02 \
  uPAD_P1_03 \
  uPAD_VSSIO_1 \
  uPAD_P1_06 \
  uPAD_P1_07 \
]

create_io_corner_cell {main_io.left main_io.top} -reference_cell PCORNER_G
create_io_corner_cell {main_io.bottom main_io.left} -reference_cell PCORNER_G
create_io_corner_cell {main_io.top main_io.right} -reference_cell PCORNER_G
create_io_corner_cell {main_io.right main_io.bottom} -reference_cell PCORNER_G

set_signal_io_constraints -io_guide_object {main_io.top} -constraint {{order_only} \
  uPAD_TEST_I \
  uPAD_SWDCK_I \
  uPAD_VDD_3 \
  uPAD_VSS_3 \
  uPAD_VDDIO_3 \
  uPAD_P1_00 \
  uPAD_P1_01 \
}

set_signal_io_constraints -io_guide_object {main_io.bottom} -constraint {{order_only} \
  uPAD_P0_00 \
  uPAD_P0_01 \
  uPAD_VSS_1 \
  uPAD_VDD_1 \
  uPAD_SE_I \
  uPAD_VDDACC_1 \
  uPAD_P0_02 \
}

set_signal_io_constraints -io_guide_object {main_io.left} -constraint {{order_only} \
  uPAD_P0_04 \
  uPAD_P0_05 \
  uPAD_P0_03 \
  uPAD_VDDACC_0 \
  uPAD_VSS_0 \
  uPAD_CLK_I \
  uPAD_VDD_0 \
  uPAD_VDDIO_0 \
  uPAD_SWDIO_IO \
  uPAD_VSSIO_0 \
  uPAD_P0_06 \
  uPAD_P0_07 \
}

set_signal_io_constraints -io_guide_object {main_io.right} -constraint {{order_only} \
  uPAD_P1_04 \
  uPAD_P1_05 \
  uPAD_NRST_I \
  uPAD_VDDIO_2 \
  uPAD_VSS_2 \
  uPAD_VDD_2 \
  uPAD_VDDACC_2 \
  uPAD_P1_02 \
  uPAD_P1_03 \
  uPAD_VSSIO_1 \
  uPAD_P1_06 \
  uPAD_P1_07 \
}

place_io
create_io_filler_cells -io_guides [get_io_guides {main_io.top main_io.right main_io.bottom main_io.left}] -reference_cells [list PFILLER20_G PFILLER10_G PFILLER5_G PFILLER0005_G ] -prefix io_filler


## ------------------------------------------
## Create Bond Pads
## ------------------------------------------

# Bottom
set bottom_pads [list  P0_00 P0_01 VSS_1 VDD_1 SE_I VDDACC_1 P0_02]
foreach pad $bottom_pads {
  create_cell uBONDPAD_${pad} PAD60GU 
  set_attribute -objects uBONDPAD_${pad} -name origin -value [get_attribute -objects uPAD_${pad} -name origin]
  move_objects -delta {0.0 11.66} [get_cell uBONDPAD_${pad}]
}
 
set top_pads [list TEST_I SWDCK_I VDD_3 VSS_3 VDDIO_3 P1_00 P1_01]
foreach pad $top_pads {
  create_cell uBONDPAD_${pad} PAD60GU 
  set_attribute -objects uBONDPAD_${pad} -name orientation -value R180
  set_attribute -objects uBONDPAD_${pad} -name origin -value [get_attribute -objects uPAD_${pad} -name origin]
  move_objects -delta {0.0 -11.66} [get_cell uBONDPAD_${pad}]
}

set left_pads [list P0_04 P0_05 P0_03 VDDACC_0 VSS_0 CLK_I VDD_0 VDDIO_0 SWDIO_IO VSSIO_0 P0_06 P0_07]
foreach pad $left_pads {
  create_cell uBONDPAD_${pad} PAD60GU 
  set_attribute -objects uBONDPAD_${pad} -name orientation -value R270
  set_attribute -objects uBONDPAD_${pad} -name origin -value [get_attribute -objects uPAD_${pad} -name origin]
  move_objects -delta {11.66 0.0} [get_cell uBONDPAD_${pad}]
}

set right_pads [list P1_04 P1_05 NRST_I VDDIO_2 VSS_2 VDD_2 VDDACC_2 P1_02 P1_03 VSSIO_1 P1_06]
foreach pad $right_pads {
  create_cell uBONDPAD_${pad} PAD60GU 
  set_attribute -objects uBONDPAD_${pad} -name orientation -value R90
  set_attribute -objects uBONDPAD_${pad} -name origin -value [get_attribute -objects uPAD_${pad} -name origin]
  move_objects -delta {-11.66 0.0} [get_cell uBONDPAD_${pad}]
}
