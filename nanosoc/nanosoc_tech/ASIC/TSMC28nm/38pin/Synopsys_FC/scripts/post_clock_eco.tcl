connect_pg_net -net POC [get_pins io_filler_*/POC]
connect_pg_net -net POC [get_pins uPAD*/POC]

connect_pg_net -net VDD [get_pins io_filler_*/VDD]
connect_pg_net -net VDD [get_pins uPAD*/VDD]

connect_pg_net -net VDDIO [get_pins io_filler_*/VDDPST]
connect_pg_net -net VDDIO [get_pins uPAD*/VDDPST]

connect_pg_net -net VSSIO [get_pins io_filler_*/VSSPST]
connect_pg_net -net VSSIO [get_pins uPAD*/VSSPST]

connect_pg_net -net VSS [get_pins io_filler_*/VSS]
connect_pg_net -net VSS [get_pins uPAD*/VSS]


connect_pg_net -net {VDDACC} [get_pins -design [current_block] -quiet -physical_context {uPAD_VDDACC_*/AVDD}]

connect_pg_net -net POC     [get_pins __added_corner_cell_*/POC]
connect_pg_net -net VDD     [get_pins __added_corner_cell_*/VDD]
connect_pg_net -net VDDIO   [get_pins __added_corner_cell_*/VDDPST]
connect_pg_net -net VSSIO   [get_pins __added_corner_cell_*/VSSPST]
connect_pg_net -net VSS     [get_pins __added_corner_cell_*/VSS]
