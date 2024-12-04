#------------------------------------------------------------------------------------
# Cadence Innovus: Place  macros
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# Copyright (c) 2023, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------

# relative floorplan
delete_relative_floorplan -all
create_relative_floorplan -ref_type core_boundary -horizontal_edge_separate {1  -4.8  1} -vertical_edge_separate {2  0  2} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_rf_sp_hdf
create_relative_floorplan -ref_type object -horizontal_edge_separate {3  -18.0  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_rf_sp_hdf -ref u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_rf_sp_hdf
create_relative_floorplan -ref_type core_boundary -horizontal_edge_separate {1  -4.8  1} -vertical_edge_separate {1  0  1} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_rf_sp_hdf 
create_relative_floorplan -ref_type object -orient R0 -horizontal_edge_separate {3  -14.4  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_rf_sp_hdf -ref u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_rf_sp_hdf
create_relative_floorplan -ref_type core_boundary -orient R180 -horizontal_edge_separate {3  200  3} -vertical_edge_separate {2  0  2} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom

move_obj u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -point {500 500}
update_floorplan_obj -obj u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -rects {600 135.0 865 265.0}
add_fences -hinst u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator  -min_gap 5
create_partition -hinst u_nanosoc_chip_u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -core_spacing 2.0 2.0 2.0 2.0 -rail_width 0.0 -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 -reserved_layer { 1 2 3 4 5 6 7 8 9 10} -pin_layer_top { 2 4 6 8 10} -pin_layer_left { 3 5 7 9} -pin_layer_bottom { 2 4 6 8 10} -pin_layer_right { 3 5 7 9} -place_halo 2 2 2 2 -route_halo 2.0 -route_halo_top_layer 5 -route_halo_bottom_layer 1

create_place_halo -halo_deltas {2 2 0 2} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {2 2 0 2} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {0 2 2 2} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {0 2 2 2} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {2 2 0 2} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom
