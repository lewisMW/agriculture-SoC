
remove_io_guides -all 

create_io_guide -name {main_io.top} -side top -line {{110.000 2639.600} 1950.94} -offset {0.000 0.000} -pad_cells [list  ]
create_io_guide -name {main_io.bottom} -side bottom -line {{2060.940 0.000} 1950.94} -offset {0.000 0.000} -pad_cells [list ]
create_io_guide -name {main_io.left} -side left -line {{0.000 110.000} 2419.6} -offset {0.000 0.000} -pad_cells [list ]
create_io_guide -name {main_io.right} -side right -line {{2170.940 2529.600} 2419.6} -offset {0.000 0.000} -pad_cells [list ]


create_io_corner_cell {main_io.left main_io.top} -reference_cell PCORNER_G
create_io_corner_cell {main_io.bottom main_io.left} -reference_cell PCORNER_G
create_io_corner_cell {main_io.top main_io.right} -reference_cell PCORNER_G
create_io_corner_cell {main_io.right main_io.bottom} -reference_cell PCORNER_G

place_io
