######################################
# Script : Place and Route Flow 
# Date : 25th May 2023 
# Author : Srimanth Tenneti 
# Description : Innovus PnR Flow 
###################################### 

puts "Starting PnR Flow ..."


### Design Import 
source design_import.tcl  

### IO Planning 
source io_plan.tcl

### Memory and accelerator placement
source place_macros.tcl
commit_power_intent
check_power_domains

### Power Plan 
source power_plan.tcl 

### Power Route 
source power_route.tcl 

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/1pre_place_nanosoc_imp_timing.rep

### Placement 
source place.tcl 

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/2post_place_nanosoc_imp_timing.rep


uniquify nanosoc_chip_pads -verbose
### CTS 
source clock_tree_synthesis.tcl 

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/3post_clock_nanosoc_imp_timing.rep

### Add filler cells
eval_legacy { addFiller -cell FILL128_A12TR WELLANTENNATIEPW2_A12TR FILLTIE8_A12TR FILLTIE64_A12TR FILLTIE4_A12TR FILLTIE32_A12TR FILLTIE2_A12TR FILLTIE16_A12TR FILLTIE128_A12TR FILLCAPTIE8_A12TR -prefix FILLER -powerDomain ACCEL -doDRC }
eval_legacy { addFiller -cell WELLANTENNATIEPW2_A12TR FILLTIE8_A12TR FILLTIE64_A12TR FILLTIE4_A12TR FILLTIE32_A12TR FILLTIE2_A12TR FILLTIE16_A12TR FILLTIE128_A12TR FILLCAPTIE8_A12TR -prefix FILLER -powerDomain TOP -doDRC }


### Routing 
source route.tcl 

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/4post_route_nanosoc_imp_timing.rep

check_antenna

### Fill metal
set_metal_fill -layer M1 -opc_active_spacing 0.090 -border_spacing -0.001
set_metal_fill -layer M2 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M3 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M4 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M5 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M6 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M7 -opc_active_spacing 0.100 -border_spacing -0.001
set_metal_fill -layer M8 -opc_active_spacing 0.400 -border_spacing -0.001
set_metal_fill -layer M9 -opc_active_spacing 0.400 -border_spacing -0.001
set_metal_fill -layer AP -opc_active_spacing 2.000 -border_spacing -0.001
add_metal_fill -layers { M1 M2 M3 M4 M5 M6 M7 M8 M9 AP } -nets { VSSIO VSS VDDACC VDDIO VDD }


report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_timing.rep
report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_area.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_power.rep

gui_show 




