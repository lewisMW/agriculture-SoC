#------------------------------------------------------------------------------------
# Cadence Innovus: Floorplan
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# Copyright (c) 2025, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------

create_floorplan -core_margins_by die -flip s -site sc12_cln65lp -die_size 1000.0 1500.0 140.0 140.0 140.0 140.0

delete_io_fillers -cell PCORNER
delete_io_fillers -cell PFILLER20
delete_io_fillers -cell PFILLER10
delete_io_fillers -cell PFILLER5
delete_io_fillers -cell PFILLER1
delete_io_fillers -cell PFILLER05
delete_io_fillers -cell PFILLER0005


read_io_file ../scripts/nanosoc_io_plan.io

add_io_fillers -cells PCORNER -prefix CORNER -side n -from 880 -to 1000
add_io_fillers -cells PCORNER -prefix CORNER -side e -from 0 -to 120
add_io_fillers -cells PCORNER -prefix CORNER -side s -from 0 -to 120
add_io_fillers -cells PCORNER -prefix CORNER -side w -from 1380 -to 1500

add_io_fillers -cells PFILLER20 -prefix FILLER -side n
add_io_fillers -cells PFILLER20 -prefix FILLER -side e
add_io_fillers -cells PFILLER20 -prefix FILLER -side s 
add_io_fillers -cells PFILLER20 -prefix FILLER -side w 

add_io_fillers -cells PFILLER10 -prefix FILLER -side n
add_io_fillers -cells PFILLER10 -prefix FILLER -side e
add_io_fillers -cells PFILLER10 -prefix FILLER -side s 
add_io_fillers -cells PFILLER10 -prefix FILLER -side w 

add_io_fillers -cells PFILLER5 -prefix FILLER -side n
add_io_fillers -cells PFILLER5 -prefix FILLER -side e
add_io_fillers -cells PFILLER5 -prefix FILLER -side s 
add_io_fillers -cells PFILLER5 -prefix FILLER -side w 

add_io_fillers -cells PFILLER1 -prefix FILLER -side n
add_io_fillers -cells PFILLER1 -prefix FILLER -side e
add_io_fillers -cells PFILLER1 -prefix FILLER -side s 
add_io_fillers -cells PFILLER1 -prefix FILLER -side w 

add_io_fillers -cells PFILLER05 -prefix FILLER -side n
add_io_fillers -cells PFILLER05 -prefix FILLER -side e
add_io_fillers -cells PFILLER05 -prefix FILLER -side s 
add_io_fillers -cells PFILLER05 -prefix FILLER -side w 

add_io_fillers -cells PFILLER0005 -prefix FILLER -side n
add_io_fillers -cells PFILLER0005 -prefix FILLER -side e
add_io_fillers -cells PFILLER0005 -prefix FILLER -side s 
add_io_fillers -cells PFILLER0005 -prefix FILLER -side w 

# relative floorplan
gui_set_draw_view fplan
delete_relative_floorplan -all
delete_place_halo -all_macros

create_relative_floorplan -ref_type core_boundary -orient R0 -horizontal_edge_separate {1  -4.8  1} -vertical_edge_separate {0  2.4  0} -place u_nanosoc_chip/u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom
create_relative_floorplan -ref_type core_boundary -horizontal_edge_separate {1  0  1} -vertical_edge_separate {2  0 2} -place u_nanosoc_chip/u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_rf_sp_hdf
create_relative_floorplan -ref_type object -horizontal_edge_separate {3  -12  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip/u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_rf_sp_hdf -ref u_nanosoc_chip/u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_rf_sp_hdf

create_relative_floorplan -ref_type core_boundary -orient R180 -horizontal_edge_separate {3  0  3} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip/u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_rf_sp_hdf 
create_relative_floorplan -ref_type object -orient R180 -horizontal_edge_separate {1  12  3} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip/u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_rf_sp_hdf -ref u_nanosoc_chip/u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_rf_sp_hdf 

create_relative_floorplan -ref_type core_boundary -horizontal_edge_separate {3  0  3} -vertical_edge_separate {0  0  0} -place u_nanosoc_chip/u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -ref nanosoc_chip_pads -no_record

update_floorplan_obj -obj u_nanosoc_chip/u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -rects {140.0 140.0 512.40 704.0}
add_fences -hinst u_nanosoc_chip/u_system_u_ss_expansion_u_region_exp_u_ss_accelerator  -min_gap 2.4
create_partition -hinst u_nanosoc_chip/u_system_u_ss_expansion_u_region_exp_u_ss_accelerator -core_spacing 2.0 2.0 2.0 2.0 -rail_width 0.0 -min_pitch_left 0 -min_pitch_right 0 -min_pitch_top 2 -min_pitch_bottom 0 -reserved_layer { 1 2 3 4 5 6 7 8 9 10} -pin_layer_top { 2 4 6 8 10} -pin_layer_left { 3 5 7 9} -pin_layer_bottom { 2 4 6 8 10} -pin_layer_right { 3 5 7 9} -place_halo 2 0 0 0 -route_halo 0.0 -route_halo_top_layer 5 -route_halo_bottom_layer 1

create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip/u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip/u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip/u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip/u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_rf_sp_hdf
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip/u_system_u_ss_cpu_u_region_bootrom_0_u_bootrom_cpu_0_u_bootrom_u_sl_rom

add_fences -hinst u_nanosoc_chip/u_system_u_ss_expansion_u_region_exp_u_ss_accelerator  -min_gap 2.4
