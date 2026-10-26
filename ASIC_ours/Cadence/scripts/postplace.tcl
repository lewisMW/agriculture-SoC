set_db add_tieoffs_max_fanout 10
# Keep each tie cell by its loads. Without a limit one conb_1 drove pad control pins
# 1.3 mm away (23 Sep chip), and that long tie net crossed a VDD via stack: a VDD-VSS
# short through the conb_1 in sign-off LVS, and ~17 of its check_drc violations. 100 um
# still reaches the pads' control pins, 60-80 um outside the core rows.
set_db add_tieoffs_max_distance 100
# contains both HI and LO
# NOTE!! I had to remove the quotation marks of the cell sky130_fd_sc_hd__conb_1 in the .lib file, for cadence to be happy
# --- BEFORE ---
# direction : "output",
# function : "1",
# --- AFTER  ---
# direction : output,
# function : 1,
# TODO tieoff_exclude not exactly working yet
set_db add_tieoffs_cells sky130_fd_sc_hd__conb_1
#add_tieoffs -lib_cell sky130_fd_sc_hd__conb_1 -prefix LTIE -matching_power_domains true -exclude_pin ../scripts/tieoff_exclude
add_tieoffs -lib_cell sky130_fd_sc_hd__conb_1 -prefix LTIE -matching_power_domains true
#add_tieoffs -lib_cell sky130_fd_sc_hd__conb_1 -prefix LTIE -power_domain PD_ACC -exclude_pin ../scripts/tieoff_exclude
#add_tieoffs -prefix LTIE -power_domain PD_TOP
check_tieoffs