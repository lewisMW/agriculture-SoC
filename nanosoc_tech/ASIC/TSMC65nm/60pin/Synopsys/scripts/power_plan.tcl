connect_pg_net -automatic

# Create Outer core ring
create_pg_ring_pattern ring_pattern -horizontal_layer M9 -horizontal_width {5} -horizontal_spacing {2} -vertical_layer M8 -vertical_width {5} -vertical_spacing {2}
set_pg_strategy core_ring -pattern {{name:ring_pattern} {nets: {VDD VDDIO VDDACC VSS}}{offset: {3 3}}} -core

# Create vertical straps in Nanosoc region
create_pg_mesh_pattern strap_pattern -layers {{{vertical_layer: M6} {width: 1} {pitch: 50} {spacing: interleaving} {trim: false}}}
set_pg_strategy M6_straps -voltage_areas VA_TOP -pattern {{name: strap_pattern}{nets: VDD VSS}} -extension {{{stop : outermost_ring}}} -blockage {{{pg_regions : {pg_ACCEL}}}} 

# Create std cell rails in Nanosoc Region
create_pg_std_cell_conn_pattern rail_pattern -layers M5 
set_pg_strategy M5_rails -voltage_areas VA_TOP -pattern {{name: rail_pattern}{nets: VDD VSS}} -extension {{{stop : outermost_ring}}} -blockage {{{pg_regions : {pg_ACCEL}}}} 

# Create rails for macros
create_pg_macro_conn_pattern sram_pg_mesh -pin_conn_type long_pin -nets {VDD VSS} -direction horizontal -layers M5 -width 0.64 -spacing interleaving -pitch 3 -pin_layers {M4} -via_rule {{intersection : all}}
set_pg_strategy sram_pg_mesh -macros {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/u_rf_sp_hdf u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom  \
u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/u_rf_sp_hdf  \
u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/u_rf_sp_hdf} -pattern {{name : sram_pg_mesh}{nets : {VDD VSS}}}


# Create ring for Accelerator Region
# create_pg_ring_pattern acc_ring_pattern -horizontal_layer M9 -horizontal_width {3} -horizontal_spacing {1} -vertical_layer M8 -vertical_width {3} -vertical_spacing {1}
# set_pg_strategy acc_ring -voltage_areas VA_ACCEL -pattern {{name:acc_ring_pattern} {nets: {VDDACC VSS}}}

# Create std cell rails in Accelerator region
create_pg_std_cell_conn_pattern acc_rail_pattern -layers M5
set_pg_strategy acc_rails -voltage_areas VA_ACCEL -pattern {{name:acc_rail_pattern}{nets:{VDDACC VSS}}} -extension {{{stop: first_target}}}

# Create straps for Accelerator region
create_pg_mesh_pattern acc_strap_pattern -layers {{vertical_layer : M8} {width : 1} {spacing : interleaving} {pitch : 50} {trim : false}}
set_pg_strategy M8_straps_acc -voltage_areas VA_ACCEL -pattern {{name: acc_strap_pattern}{nets: VDDACC VSS}} -extension {{{stop : outermost_ring}}}

create_pg_mesh_pattern acc_mesh_pattern -layers {{horizontal_layer : M9} {width : 1} {spacing : interleaving} {pitch : 50} {trim : false}}
set_pg_strategy M9_mesh_acc -voltage_areas VA_ACCEL -pattern {{name: acc_mesh_pattern}{nets: VDDACC VSS}} -extension {{{stop : outermost_ring}}}

# Compile all power strategies
compile_pg -strategies {core_ring M6_straps M5_rails acc_rails M8_straps_acc M9_mesh_acc sram_pg_mesh}