################################################################################
#
# Created by fc write_floorplan on Fri Apr  4 11:36:26 2025
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
set_attribute -quiet -objects $cellInst -name orientation -value R180
set_attribute -quiet -objects $cellInst -name origin -value { 117.7140 920.2080 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_imem_0/u_imem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 703.0950 472.8000 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_cpu/u_region_dmem_0/u_dmem_0/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 703.0950 323.6640 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_l/u_expram_l/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 703.0950 771.0720 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed

set cellInst [get_cells { \
    u_nanosoc_chip/u_system/u_ss_expansion/u_region_expram_h/u_expram_h/u_sram/genblk1.u_sram \
    }]
set_attribute -quiet -objects $cellInst -name orientation -value R0
set_attribute -quiet -objects $cellInst -name origin -value { 703.0950 621.9360 \
    }
set_attribute -quiet -objects $cellInst -name status -value placed


################################################################################
# User attributes of macros
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

create_io_guide -name _default_io_ring1.left -side left -line { {0.0000 \
    74.4960} 871.2000 } -offset {0.0000 0.0000}
create_io_guide -name _default_io_ring1.bottom -side bottom -line { {945.8880 \
    0.0000} 871.3920 } -offset {0.0000 0.0000}
create_io_guide -name _default_io_ring1.right -side right -line { {1020.3840 \
    945.6960} 871.2000 } -offset {0.0000 0.0000}
create_io_guide -name _default_io_ring1.top -side top -line { {74.4960 \
    1020.1920} 871.3920 } -offset {0.0000 0.0000}

################################################################################
# User attributes of I/O guides
################################################################################


################################################################################
# User attributes of current block
################################################################################

define_user_attribute -classes design -type string LEF58_EDGETYPE
define_user_attribute -classes design -type double ioCellOffsetX
define_user_attribute -classes design -type double ioCellOffsetY

