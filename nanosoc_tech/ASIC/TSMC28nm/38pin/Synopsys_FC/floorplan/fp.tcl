################################################################################
#
# Created by fc write_floorplan on Fri Oct 25 13:42:48 2024
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Read DEF
################################################################################

read_def  ${_dirName__0}/floorplan.def

################################################################################
# Macros
################################################################################

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 140.0000 919.4450 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type hard_macro -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_bootrom_0/u_bootrom_cpu_0/u_bootrom/u_sl_rom \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 798.8600 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 971.0400 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 971.0400 563.3200 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 798.8600 563.3200 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type soft -outer { 2.0000 2.0000 2.0000 2.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type hard_macro -outer { 1.0000 1.0000 1.0000 1.0000 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }
create_keepout_margin -type routing_blockage -outer { 2.0000 2.0000 2.0000 \
    2.0000 } -layers { M1 VIA1 M2 VIA2 M3 VIA3 M4 } { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }


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

create_io_guide -name main_io_ring.left -side left -line { {0.0000 110.0000} \
    890.7000 } -offset {0.0000 0.0000} -pad_cells { uPAD_CLK_I uPAD_NRST_I \
    uPAD_P0_00 uPAD_P0_01 uPAD_P0_02 uPAD_P0_03 uPAD_P0_04 uPAD_P0_05 uPAD_P0_06 }
create_io_guide -name main_io_ring.bottom -side bottom -line { {1001.0400 \
    0.0000} 891.0400 } -offset {0.0000 0.0000} -pad_cells { uPAD_P0_07 \
    uPAD_P1_00 uPAD_P1_01 uPAD_P1_02 uPAD_P1_03 uPAD_P1_04 uPAD_P1_05 \
    uPAD_P1_06 uPAD_P1_07 uPAD_SE_I }
create_io_guide -name main_io_ring.right -side right -line { {1111.0400 \
    1000.7000} 890.7000 } -offset {0.0000 0.0000} -pad_cells { uPAD_SWDCK_I \
    uPAD_SWDIO_IO uPAD_TEST_I uPAD_VDDACC_0 uPAD_VDDACC_1 uPAD_VDDACC_2 \
    uPAD_VDDIO_0 uPAD_VDDIO_2 uPAD_VDDIO_3 }
create_io_guide -name main_io_ring.top -side top -line { {110.0000 1110.7000} \
    891.0400 } -offset {0.0000 0.0000} -pad_cells { uPAD_VDD_0 uPAD_VDD_1 \
    uPAD_VDD_2 uPAD_VDD_3 uPAD_VSSIO_0 uPAD_VSSIO_1 uPAD_VSS_0 uPAD_VSS_1 \
    uPAD_VSS_2 uPAD_VSS_3 }

################################################################################
# User attributes of I/O guides
################################################################################


################################################################################
# User attributes of current block
################################################################################


