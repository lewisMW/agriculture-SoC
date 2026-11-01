#------------------------------------------------------------------------------------
# Cadence Innovus: Floorplan
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# Copyright (c) 2026, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------
# TODO this needs to be (2.920um w x 3.520um h) (right now too large, max 15mm^2)
#create_floorplan -die_size_by_io_height max -site CoreSite -core_size 2920 3520 50 50 50 50
create_floorplan -die_size_by_io_height max -site unithd -core_size 2920 3520 50 50 50 50


read_io_file ../scripts/nanosoc_io_plan.io

# these are for the SRAMS. I don't think I need to further touch this
create_relative_floorplan -ref_type core_boundary -orient R90 -horizontal_edge_separate {1  -150  1} -vertical_edge_separate {0  150  0} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -orient R90 -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram

create_relative_floorplan -ref_type core_boundary -orient R270 -horizontal_edge_separate {1  -150  1} -vertical_edge_separate {2  -150  2} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -orient R270 -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram

create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {9.6 9.6 9.6 9.6} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram

create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_route_halo -bottom_layer $bottom_routing_layer -space 4.8 -top_layer $top_routing_layer  -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram

snap_floorplan -all