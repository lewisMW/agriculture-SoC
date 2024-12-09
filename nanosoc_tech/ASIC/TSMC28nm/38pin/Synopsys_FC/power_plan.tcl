connect_pg_net -create_nets_only
connect_pg_net -automatic

create_pg_ring_pattern ring_pattern -horizontal_layer M7 -horizontal_width {5} -horizontal_spacing {2}\
                                    -vertical_layer M8 -vertical_width {5} -vertical_spacing {2}
set_pg_strategy core_ring -pattern {{name: ring_pattern} {nets: {VDD VDDACC VSS}} {offset: {3 3}}} -core 
compile_pg -strategies core_ring


create_pg_mesh_pattern mesh_pattern -layers {{{vertical_layer: M8} {width: 1} {pitch: 30} {offset: 20}} \
                                                {{horizontal_layer: M5} {width: 1} {pitch: 30} {offset: 20}}}
set_pg_strategy M5M8_mesh -pattern {{name: mesh_pattern} {nets: {VDD VDDACC VSS}}} -core
compile_pg -strategies M5M8_mesh


create_pg_std_cell_conn_pattern std_pattern -layers {M1} -check_std_cell_drc false -mark_as_follow_pin false -rail_width {0.13 0.13}
set_pg_strategy std_cell_accel -voltage_areas ACCEL -pattern {{name : std_pattern}{nets : {VDDACC VSS}}}
set_pg_strategy std_cell_dbg -voltage_areas PD_DBG -pattern {{name : std_pattern}{nets : {VDD_DBG VSS}}}
set_pg_strategy std_cell_sys -voltage_areas PD_SYS -pattern {{name : std_pattern}{nets : {VDD_SYS VSS}}}

set_pg_strategy std_cell_strat -voltage_areas DEFAULT_VA -pattern {{name: std_pattern} {nets: {VDD VSS}}}

compile_pg -strategies std_cell_accel
compile_pg -strategies std_cell_dbg
compile_pg -strategies std_cell_sys


compile_pg -strategies std_cell_strat
