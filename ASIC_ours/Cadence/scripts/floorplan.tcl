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
create_floorplan -die_size_by_io_height max -site CoreSite -core_size 3600 5200 50 50 50 50


read_io_file ../scripts/nanosoc_io_plan.io

# these are for the SRAMS. I don't think I need to further touch this
create_relative_floorplan -ref_type core_boundary -orient R0 -horizontal_edge_separate {1  -250  1} -vertical_edge_separate {0  400  0} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram

create_relative_floorplan -ref_type core_boundary -orient R180 -horizontal_edge_separate {1  -250  1} -vertical_edge_separate {2  -400  2} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_relative_floorplan -ref_type object -orient R180 -horizontal_edge_separate {3  -250  1} -vertical_edge_separate {3  0  3} -place u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram -ref u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram

create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_l_u_expram_l_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip_u_system_u_ss_expansion_u_region_expram_h_u_expram_h_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_imem_0_u_imem_0_u_sram_genblk1.u_sram
create_place_halo -halo_deltas {4.8 4.8 2.4 4.8} -insts u_nanosoc_chip_u_system_u_ss_cpu_u_region_dmem_0_u_dmem_0_u_sram_genblk1.u_sram

# TODO add the analog floorplan parts