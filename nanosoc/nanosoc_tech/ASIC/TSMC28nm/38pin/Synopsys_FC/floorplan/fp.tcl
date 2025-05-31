################################################################################
#
# Created by fc write_floorplan on Fri May 23 13:50:47 2025
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
set_attribute -quiet -objects $cellInst -name origin -value { 230.0500 \
    1504.9350 }
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
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 631.6200 \
    1341.9650 }
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
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 459.4400 \
    1341.9650 }
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
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 803.8000 \
    1341.9650 }
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
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 975.9800 \
    1341.9650 }
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
# Route guides and their user attributes
################################################################################

remove_routing_guides -all



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
# User attributes of current block
################################################################################


