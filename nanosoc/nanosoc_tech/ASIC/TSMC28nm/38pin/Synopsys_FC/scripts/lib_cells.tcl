set_lib_cell_purpose -include none  {*X0*}
set_lib_cell_purpose -include none {*BUF*X0*}
set_lib_cell_purpose -include none {INV*X0*}
set_lib_cell_purpose -include none {*DLY*}
set_lib_cell_purpose -include none  {*FRICG*}
set_lib_cell_purpose -include none  {SDFF*H*}
set_lib_cell_purpose -include none  {SDFFX*}
set_lib_cell_purpose -include none  {HEAD*}
set_lib_cell_purpose -include none  {FOOT*}


set_lib_cell_purpose -exclude hold {**}
set_lib_cell_purpose -include hold {*DLY*}

#set_lib_cell_purpose -include hold {*BUF*X0* INV*X0*}
set_lib_cell_purpose -include cts  {*FRICG*}


set_message_info -id ATTR-11 -limit  5
get_lib_cells cln28ht/* -filter "valid_purposes(block) =~ *hold*"

