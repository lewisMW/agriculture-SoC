# Decap cells first, then plain fill, as OpenLane does for sky130_fd_sc_hd. The fill_*
# cells hold no diffusion, poly or li1, so with this sparse core the front-end density
# rules failed at sign-off (23 Sep chip, after metal fill: diff.local.low 27.1 % in 30
# windows against 28 %, poly.local.low in 983 windows, li global 31.4 % against 33 %).
# The decaps fill those layers and add decoupling between VDD and VSS. They contain
# transistors, so the LVS netlist must include physical instances
# (write_netlist -include_phys_inst).
# But decaps everywhere overshoot: decap_12 is ~72 % poly, and the all-decap core failed
# CDRW.poly.local.high (<= 38 % per 700 um window) in 1157 windows, up to 64.5 %. So the
# decaps take 40 % of the free space (add_fillers -density) and fill_* the rest: about
# 31 % poly at most per window (cell-area estimate, calibrated to Pegasus on the all-decap
# run), li1 still ~45 % of the die, and decap diffusion spread evenly for the diff fill.
set decap_cells [list sky130_fd_sc_hd__decap_12 sky130_fd_sc_hd__decap_8 sky130_fd_sc_hd__decap_6 sky130_fd_sc_hd__decap_4 sky130_fd_sc_hd__decap_3]
set decap_density 0.40
set filler_cells [list sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1]
add_fillers -base_cells $decap_cells -density $decap_density -prefix DECAP -power_domain PD_TOP -check_drc true

# Accelerator domain: the UPF leaves PD_ACC commented out until the ADC is
# integrated, and PD_TOP is -include_scope so it covers the whole design today.
# Restore this as -power_domain PD_ACC when create_power_domain PD_ACC is enabled.
# add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_ACC -check_drc true
add_fillers -base_cells $filler_cells -prefix FILLER -fill_gap -merge true -power_domain PD_TOP -check_drc true

# add_filler_gaps 0.8 -effort high
# Not after routing: it refine-places cells to close small gaps, and here, after
# route_design, it moved 2,376 routed cells by up to 9.6 um without rerouting them,
# leaving ~19,500 check_drc violations (li1/met1 shorts at the moved pins). The fillers
# above fill every gap down to one site anyway.





check_filler > check_filler.log
# Accelerator domain: the UPF leaves PD_ACC commented out until the ADC is
# integrated, and PD_TOP is -include_scope so it covers the whole design today.
# Restore this as -power_domain PD_ACC when create_power_domain PD_ACC is enabled.
# add_fillers -base_cells [list sky130_fd_sc_hd__fill_1 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_8] -prefix FILLER -fill_gap -merge true -power_domain PD_ACC -check_drc true
add_fillers -base_cells $filler_cells -prefix FILLER -fill_gap -merge true -power_domain PD_TOP -fix_drc
