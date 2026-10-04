add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8 sky130_fd_sc_hs__fill_diode_2 sky130_fd_sc_hs__fill_diode_4 sky130_fd_sc_hs__fill_diode_8] -prefix FILLER -fill_gap -merge true -power_domain ACCEL -check_drc true
add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8 sky130_fd_sc_hs__fill_diode_2 sky130_fd_sc_hs__fill_diode_4 sky130_fd_sc_hs__fill_diode_8] -prefix FILLER -fill_gap -merge true -power_domain TOP -check_drc true

add_filler_gaps 0.8 -effort high





check_filler > check_filler.log
add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8 sky130_fd_sc_hs__fill_diode_2 sky130_fd_sc_hs__fill_diode_4 sky130_fd_sc_hs__fill_diode_8] -prefix FILLER -fill_gap -merge true -power_domain ACCEL -check_drc true
add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8 sky130_fd_sc_hs__fill_diode_2 sky130_fd_sc_hs__fill_diode_4 sky130_fd_sc_hs__fill_diode_8] -prefix FILLER -fill_gap -merge true -power_domain TOP -check_drc true
