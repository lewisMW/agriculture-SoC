set_db add_tieoffs_max_fanout 10
add_tieoffs -lib_cell {TIELO_X1M_A12TR TIEHI_X1M_A12TR} -prefix LTIE -power_domain PD_TOP -exclude_pin ../scripts/tieoff_exclude
add_tieoffs -lib_cell {TIELO_X1M_A12TR TIEHI_X1M_A12TR} -prefix LTIE -power_domain PD_ACC -exclude_pin ../scripts/tieoff_exclude
