

# Power Plan
load_upf ../scripts/nanosoc_chip_pads.upf


#----------------------------------------------------
# 	Create voltage areas and power regions 
#----------------------------------------------------
create_voltage_area -power_domains ACCEL 
# create_voltage_area -power_domains PD_DBG
# create_voltage_area -power_domains PD_SYS
 
create_voltage_area_shape -voltage_area ACCEL \
				-region {{{135.000 135.000} {975.98 1120}}} \
				-guard_band {2 2}

#create_voltage_area_shape -voltage_area PD_DBG \
#				-region {{{140.000 673.000} {464.150 970.400}}} \
#				-guard_band {2 2}
#create_voltage_area_shape -voltage_area PD_SYS \
#				-region {{{594.440 523.900} {1012.365 970.400}}} \
#				-guard_band {2 2}

create_pg_region {pg_accel} -voltage_area {ACCEL}
# create_pg_region {pg_dbg} -voltage_area {PD_DBG}
# create_pg_region {pg_sys} -voltage_area {PD_SYS}
commit_upf

connect_pg_net -create_nets_only
connect_pg_net -automatic
connect_pg_net -net {VDDACC} [get_pins -design [current_block] -quiet -physical_context {uPAD_VDDACC_*/VDD}]
connect_pg_net -net {VDDACC} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_expansion/u_region_exp/u_ss_accelerator/*/VDD}]
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom/VDD}]
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram/VDD}]
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram/VDD}]
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram/VDD}]
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram/VDD}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom/VSSE}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram/VSS}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram/VSS}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram/VSS}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram/VSS}]

connect_pg_net -net {VDDIO} [get_pins -design [current_block] -quiet -physical_context {uPAD_VDDIO_*/VDDPST}]
connect_pg_net -net {VSSIO} [get_pins -design [current_block] -quiet -physical_context {uPAD_VSSIO_*/VSSPST}]

#----------------------------------------------------
# 	Create Power supply Ring
#----------------------------------------------------
create_pg_ring_pattern ring_pattern -horizontal_layer AP -horizontal_width {5} -horizontal_spacing {2}\
                                    -vertical_layer M9 -vertical_width {4} -vertical_spacing {2} -nets {VDDACC VDD VSS}

set_pg_strategy core_ring -pattern {{name: ring_pattern} {nets: {VDD VSS VDDACC}} {offset: {3 3}}} -core 
compile_pg -strategies core_ring

#----------------------------------------------------
# 	I/O to rings connections
#----------------------------------------------------
set_app_options -name plan.pgroute.hmpin_connection_target_layers -value M9
create_pg_macro_conn_pattern io_to_ring_h -pin_conn_type scattered_pin -nets {VDDACC VDD VSS} \
 	-layers {M2 M2} -width {1.41 1.41} -pin_layers {M2} \
	-via_rule {{intersection : all} {via_master : NIL}}
set_pg_strategy h_io_to_ring -macros {uPAD_VDD_0 uPAD_VDD_2 uPAD_VSS_0 uPAD_VSS_2 uPAD_VDDACC_0 uPAD_VDDACC_2} \
 	-pattern {{name: io_to_ring_h} {nets: {VDD VDDACC VSS}}} -extension {{{stop : first_target}}{{stop : pad_ring}}}
set_pg_strategy_via_rule rule1 -via_rule { \
   {{{strategies: h_io_to_ring}{layers: M2}} {{existing: ring}{layers: M9}} \
    {via_master: default}} {{intersection: undefined} {via_master: NIL}}}
compile_pg -strategies h_io_to_ring -via_rule rule1

set_app_options -name plan.pgroute.hmpin_connection_target_layers -value AP
create_pg_macro_conn_pattern io_to_ring_v -pin_conn_type scattered_pin -nets {VDDACC VDD VSS} \
 	-layers {M2 M2} -width {1.41 1.41} -pin_layers {M2} \
	-via_rule {{intersection : all} {via_master : NIL}}
set_pg_strategy v_io_to_ring -macros {uPAD_VDD_1 uPAD_VDD_3 uPAD_VSS_1 uPAD_VSS_3 uPAD_VDDACC_1} \
 	-pattern {{name: io_to_ring_v} {nets: {VDD VDDACC VSS}}} -extension {{{stop : first_target}}{{stop : pad_ring}}}
set_pg_strategy_via_rule rule2 -via_rule { \
   {{{strategies: v_io_to_ring}{layers: M2}} {{existing: ring}{layers: AP}} \
    {via_master: default}} {{intersection: undefined} {via_master: NIL}}}
compile_pg -strategies v_io_to_ring -via_rule rule2


#----------------------------------------------------
# 	Top Layer M(TOP) & M(TOP-1) mesh
#----------------------------------------------------
create_pg_mesh_pattern mesh_pattern -layers {{{vertical_layer: M9} {width: 4} {pitch: 60} {offset: 20}} \
                                                {{horizontal_layer: AP} {width: 4} {pitch: 60} {offset: 20}}}
set_pg_strategy M9AP_mesh -pattern {{name: mesh_pattern} {nets: {VDD VDDACC VSS}}} -core -extension {{{stop : first_target}}}
compile_pg -strategies M9AP_mesh


#----------------------------------------------------
# 	Power supply to Macros
#----------------------------------------------------
create_pg_mesh_pattern macro_straps -layers {{{vertical_layer : M5} {width : 0.21} {spacing : minimum} {offset : 5} {pitch : 10} {trim : true}}}
set_pg_strategy macro_mesh -macros {u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram} -pattern {{name: macro_straps} {nets: {VDD VSS}}} -extension {{{stop : first_target}}}
# set_pg_strategy macro_mesh -polygon {{135.000 1341.965} {975.980 1531.500}} -pattern {{name: macro_straps} {nets: {VDD VSS}}} -extension {{{stop : first_target}}}
compile_pg -strategies macro_mesh

#----------------------------------------------------
# Std Cell rails
#----------------------------------------------------
create_pg_std_cell_conn_pattern std_pattern -layers {M2} -check_std_cell_drc false -mark_as_follow_pin false -rail_width {0.13 0.13}
#set_pg_strategy std_cell_dbg -voltage_areas PD_DBG -pattern {{name : std_pattern}{nets : {VDD_DBG VSS}}} 
#set_pg_strategy std_cell_sys -voltage_areas PD_SYS -pattern {{name : std_pattern}{nets : {VDD_SYS VSS}}} 

set_pg_strategy std_cell_accel -voltage_areas ACCEL -pattern {{name : std_pattern}{nets : {VDDACC VSS}}} -extension {{{stop : outermost_ring}}}
set_pg_strategy std_cell_strat -voltage_areas DEFAULT_VA -pattern {{name: std_pattern} {nets: {VDD VSS}}} -extension {{{stop : outermost_ring}}}

compile_pg -strategies std_cell_strat

compile_pg -strategies std_cell_accel
#compile_pg -strategies std_cell_dbg
#compile_pg -strategies std_cell_sys




#----------------------------------------------------
#	Physical cells (endcaps and taps)
#----------------------------------------------------

# Create endcap cells
create_boundary_cells -left_boundary_cell [get_lib_cells {cln28ht/ENDCAPTIE3_A7PP140ZTS_C30}] -right_boundary_cell [get_lib_cells {cln28ht/ENDCAPTIE3_A7PP140ZTS_C30}]

# Create taps
create_tap_cells -distance 132.0000 -lib_cell [get_lib_cells {cln28ht/FILLTIE5_A7PP140ZTS_C30}] -voltage_area DEFAULT_VA -offset 33.0000 -pattern stagger
create_tap_cells -distance 132.0000 -lib_cell [get_lib_cells {cln28ht/FILLTIE5_A7PP140ZTS_C30}] -voltage_area ACCEL -offset 33.0000 -pattern stagger

read_virtual_pad_file ../scripts/virtual_pads

