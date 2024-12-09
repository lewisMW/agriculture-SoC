set_parasitic_parameters -early_spec cbest -early_temperature -40 -late_spec cworst -late_temperature 125 -library nanosoc_chip_pads.dlib
set_operating_conditions -max_library cln28ht -max ssg_cworstt_max_0p81v_125c -min_library cln28ht -min ffg_cbestt_min_0p99v_m40c
set_temperature -40 -min 125 -corners default
set_voltage 0.81 -min 0.99 -corners default


set_voltage -min 0.99 -corners default -object_list [get_supply_nets {VDD}] 0.81
set_voltage -min 0.99 -corners default -object_list [get_supply_nets {VDD_SYS}] 0.81
set_voltage -min 0.99 -corners default -object_list [get_supply_nets {VDD_DBG}] 0.81
set_voltage -min 0.99 -corners default -object_list [get_supply_nets {VDDACC}] 0.81
set_voltage -min 0.0 -corners default -object_list [get_supply_nets {VSS}] 0.0
redirect -tee -file ./precompile_checks.log {compile_fusion -check_only}

explore_logic_hierarchy -create_module_boundary -nested -cell [get_cells -design [current_block] {u_nanosoc_chip u_nanosoc_chip_cfg}]
explore_logic_hierarchy -place -rectangular
save_lib nanosoc_chip_pads.dlib
