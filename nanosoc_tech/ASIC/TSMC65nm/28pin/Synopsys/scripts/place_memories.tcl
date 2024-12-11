set_macro_relative_location -target_object [get_cell {u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/u_rf_sp_hdf}] -target_orientation R0 -target_corner tr -anchor_corner tr -offset {-0.1 -0.47} -offset_type scalable
set_macro_relative_location -target_object [get_cell {u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf}] -target_orientation R0 -target_corner tr -anchor_corner tr -offset {-0.1 -0.67} -offset_type scalable
set_macro_relative_location -target_object [get_cell {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/u_rf_sp_hdf}] -target_orientation R0 -target_corner tr -anchor_corner tr -offset {-0.1 -0.05} -offset_type scalable
set_macro_relative_location -target_object [get_cell {u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/u_rf_sp_hdf}] -target_orientation R0 -target_corner tr -anchor_corner tr -offset {-0.1 -0.27} -offset_type scalable
set_macro_relative_location -target_object [get_cell {u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom}] -target_orientation R180 -target_corner br -anchor_corner br -offset {-0.15 0.1} -offset_type scalable
create_macro_relative_location_placement

set_attribute -objects [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf] -name physical_status -value fixed
set_attribute -objects [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/u_rf_sp_hdf] -name physical_status -value fixed
set_attribute -objects [get_cells u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/u_rf_sp_hdf] -name physical_status -value fixed
set_attribute -objects [get_cells u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/u_rf_sp_hdf] -name physical_status -value fixed
set_attribute -objects [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom] -name physical_status -value fixed

create_keepout_margin -type hard -outer {5 5 5 5} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf] ref_block];create_keepout_margin -type hard_macro -outer {5 5 5 5} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf] ref_block];create_keepout_margin -type soft -outer {8 8 8 8} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/u_rf_sp_hdf] ref_block];
create_keepout_margin -type hard -outer {5 5 5 5} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom] ref_block];create_keepout_margin -type hard_macro -outer {5 5 5 5} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom] ref_block];create_keepout_margin -type soft -outer {8 8 8 8} [get_attribute [get_cells u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom] ref_block];

