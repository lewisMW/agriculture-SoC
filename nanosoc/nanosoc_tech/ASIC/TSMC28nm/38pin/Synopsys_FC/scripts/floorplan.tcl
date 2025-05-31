initialize_floorplan -control_type die -use_site_row -side_length {1111.111111 1666.666666} -core_offset {135}
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

