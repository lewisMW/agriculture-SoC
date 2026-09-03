# Accelerator domain: the UPF leaves PD_ACC commented out until the ADC is
# integrated, and PD_TOP is -include_scope so it covers the whole design today.
# Restore this as -power_domain PD_ACC when create_power_domain PD_ACC is enabled.
# add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_ACC -check_drc true
add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_TOP -check_drc true

add_filler_gaps 0.8 -effort high





check_filler > check_filler.log
# Accelerator domain: the UPF leaves PD_ACC commented out until the ADC is
# integrated, and PD_TOP is -include_scope so it covers the whole design today.
# Restore this as -power_domain PD_ACC when create_power_domain PD_ACC is enabled.
# add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_ACC -check_drc true
add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_TOP -check_drc true
