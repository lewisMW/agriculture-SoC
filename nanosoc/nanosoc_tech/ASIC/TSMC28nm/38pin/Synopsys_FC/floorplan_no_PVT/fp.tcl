################################################################################
#
# Created by fc write_floorplan on Mon Jun 16 16:08:36 2025
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
set_attribute -quiet -objects $cellInst -name origin -value { 161.5650 \
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
# Bundles
################################################################################

set _bundles [get_bundles * -quiet]
if [sizeof_collection $_bundles] {
remove_bundles $_bundles
}


################################################################################
# User attributes of bundles
################################################################################


################################################################################
# Routing corridors
################################################################################

remove_routing_corridors -all


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
# User attributes of current block
################################################################################


