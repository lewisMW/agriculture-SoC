################################################################################
#
# Created by fc write_floorplan on Wed Nov  5 12:35:44 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Pins
################################################################################

set __pins [get_terminals -quiet]
if {[sizeof_collection $__pins] > 0} {
set __termShapes [get_shapes -of_objects [get_terminals * -quiet] -quiet]
if {[sizeof_collection $__termShapes] > 0} {
remove_shapes $__termShapes -force
}
set __termVias [get_vias -of_objects [get_terminals * -quiet] -quiet]
if {[sizeof_collection $__termVias] > 0} {
remove_vias $__termVias -force
}
set __termShapePatterns [get_shape_patterns -of_objects [get_terminals * -quiet] -quiet]
if {[sizeof_collection $__termShapePatterns] > 0} {
remove_shape_patterns $__termShapePatterns
}
}

################################################################################
# Read DEF
################################################################################

remove_routing_rules -all
read_def  ${_dirName__0}/floorplan.def

################################################################################
# Macros
################################################################################

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 448.0900 \
    1531.5000 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 522.8000 \
    1187.1050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 522.8000 \
    1359.2850 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 786.4450 \
    1359.3200 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 786.4450 \
    1187.1400 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_ts0.u_snps_PVT_ts0/u_synopsys_ts \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 135.0000 \
    1331.5000 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_ts0.u_snps_PVT_ts0/u_synopsys_ts \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_ts0.u_snps_PVT_ts0/u_synopsys_ts \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_ts0.u_snps_PVT_ts0/u_synopsys_ts \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_ts0.u_snps_PVT_ts0/u_synopsys_ts \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_pd0.u_snps_PVT_pd0/u_synopsys_pd \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 151.4300 \
    1231.6250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_pd0.u_snps_PVT_pd0/u_synopsys_pd \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_pd0.u_snps_PVT_pd0/u_synopsys_pd \
    }
create_keepout_margin -type hard_macro -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_pd0.u_snps_PVT_pd0/u_synopsys_pd \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { NW VTL_N CO M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_systemctrl/u_region_sysio/u_nanosoc_sysio_snps_pvt_ss/gen_snps_PVT_pd0.u_snps_PVT_pd0/u_synopsys_pd \
    }

set cellInst [get_cells { uBONDPAD_P0_00 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 887.1100 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_01 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 773.2350 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSS_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 659.3650 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDD_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 545.4900 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_SE_I }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 431.6200 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDACC_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 317.7450 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_02 }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 203.8750 11.6600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_TEST_I }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 223.8750 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_SWDCK_I }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 337.7450 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDD_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 451.6200 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSS_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 565.4900 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDIO_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 679.3650 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_00 }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 793.2350 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_01 }]
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 907.1100 \
    1654.8400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_04 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 222.8100 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_05 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 335.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_03 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 448.4250 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDACC_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 561.2300 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSS_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 674.0400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_CLK_I }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 786.8450 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDD_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 899.6550 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDIO_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 1012.4600 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_SWDIO_IO }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 1125.2700 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSSIO_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 1238.0750 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_06 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 1350.8850 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P0_07 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 11.6600 1463.6900 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_04 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    1443.6900 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_05 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    1330.8850 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_NRST_I }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    1218.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDIO_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    1105.2700 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSS_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    992.4600 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDD_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    879.6550 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VDDACC_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    766.8450 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_02 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    654.0400 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_03 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    541.2300 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_VSSIO_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    428.4250 }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { uBONDPAD_P1_06 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3200 \
    315.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed


################################################################################
# User attributes of macros
################################################################################


################################################################################
# Bounds and user attributes of bound shapes
################################################################################

remove_bounds -all


################################################################################
# User attributes of bounds
################################################################################


################################################################################
# Blockages
################################################################################

remove_routing_blockages -all -force

remove_placement_blockages -all -force

remove_pin_blockages -all

remove_shaping_blockages -all

################################################################################
# User attributes of blockages
################################################################################

################################################################################
# Module Boundaries
################################################################################

set hbCells [get_cells -quiet -filter hierarchy_type==boundary -hierarchical]
if [sizeof_collection $hbCells] {
   set_cell_hierarchy_type -type normal $hbCells
}


################################################################################
# I/O guides
################################################################################

remove_io_guides -all

create_io_guide -name main_io.top -side top -line { {110.0000 1666.5000} \
    890.9800 } -offset {0.0000 0.0000} -pad_cells { uPAD_TEST_I uPAD_SWDCK_I \
    uPAD_VDD_3 uPAD_VSS_3 uPAD_VDDIO_3 uPAD_P1_00 uPAD_P1_01 }
create_io_guide -name main_io.bottom -side bottom -line { {1000.9800 0.0000} \
    890.9800 } -offset {0.0000 0.0000} -pad_cells { uPAD_P0_02 uPAD_VDDACC_1 \
    uPAD_SE_I uPAD_VDD_1 uPAD_VSS_1 uPAD_P0_01 uPAD_P0_00 }
create_io_guide -name main_io.left -side left -line { {0.0000 110.0000} \
    1446.5000 } -offset {0.0000 0.0000} -pad_cells { uPAD_P0_04 uPAD_P0_05 \
    uPAD_P0_03 uPAD_VDDACC_0 uPAD_VSS_0 uPAD_CLK_I uPAD_VDD_0 uPAD_VDDIO_0 \
    uPAD_SWDIO_IO uPAD_VSSIO_0 uPAD_P0_06 uPAD_P0_07 }
create_io_guide -name main_io.right -side right -line { {1110.9800 1556.5000} \
    1446.5000 } -offset {0.0000 0.0000} -pad_cells { uPAD_P1_04 uPAD_P1_05 \
    uPAD_NRST_I uPAD_VDDIO_2 uPAD_VSS_2 uPAD_VDD_2 uPAD_VDDACC_2 uPAD_P1_02 \
    uPAD_P1_03 uPAD_VSSIO_1 uPAD_P1_06 uPAD_P1_07 }

################################################################################
# User attributes of I/O guides
################################################################################


################################################################################
# Routing directions
################################################################################

set_attribute -objects [get_layers M1] -name routing_direction -value vertical
set_attribute -objects [get_layers M2] -name routing_direction -value horizontal
set_attribute -objects [get_layers M3] -name routing_direction -value vertical
set_attribute -objects [get_layers M4] -name routing_direction -value horizontal
set_attribute -objects [get_layers M5] -name routing_direction -value vertical
set_attribute -objects [get_layers M6] -name routing_direction -value horizontal
set_attribute -objects [get_layers M7] -name routing_direction -value vertical
set_attribute -objects [get_layers M8] -name routing_direction -value horizontal
set_attribute -objects [get_layers M9] -name routing_direction -value vertical
set_attribute -objects [get_layers AP] -name routing_direction -value horizontal

################################################################################
# Terminals/shapes/vias of ports with user attributes
################################################################################

################################################################################
# User attributes of ports
################################################################################


################################################################################
# User attributes of current block
################################################################################


