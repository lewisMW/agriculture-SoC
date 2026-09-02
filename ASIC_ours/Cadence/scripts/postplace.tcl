set_db add_tieoffs_max_fanout 10
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