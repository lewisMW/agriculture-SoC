################################################################################
#
# Created by fc write_floorplan on Thu Sep 12 11:29:50 2024
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
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 235.0500 944.1350 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 454.5000 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 626.6800 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 971.0400 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 798.8600 781.1650 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed


################################################################################
# User attributes of macros
################################################################################


################################################################################
# I/O guides
################################################################################

remove_io_guides -all


################################################################################
# User attributes of I/O guides
################################################################################


################################################################################
# User attributes of current block
################################################################################


