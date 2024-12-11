#-----------------------------------------------------------------------------
# NanoSoC Place and route script for Cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: innovus -stylus -f pnr_flow.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

set SC_GDS2 $::env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/gds2/sc12_cln65lp_base_rvt.gds2
set RF_16K_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/rf_16k/rf_16k.gds2
set RF_08K_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/rf_08k/rf_08k.gds2
set ROM_VIA_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via.gds2

set_multi_cpu_usage -local_cpu 8
puts "Starting PnR Flow ..."


### Design Import 
source design_import.tcl  

### IO Planning 
source io_plan.tcl

commit_power_intent
check_power_domains
### Memory and accelerator placement
source place_macros.tcl

### Power Plan 
source power_plan.tcl 

### Power Route 
source power_route.tcl 

report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/1pre_place_nanosoc_imp_timing_late.rep
report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/1pre_place_nanosoc_imp_timing_early.rep

uniquify nanosoc_chip_pads -verbose
write_db nanosoc_chip_pads
### Placement 
source place.tcl 

report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/2post_place_nanosoc_imp_timing_late.rep
report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/2post_place_nanosoc_imp_timing_early.rep

reorder_scan 
write_db nanosoc_chip_pads

### CTS 
source clock_tree_synthesis.tcl 
reorder_scan -clock_aware true

report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/3post_clock_nanosoc_imp_timing_late.rep
report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/3post_clock_nanosoc_imp_timing_early.rep


write_db nanosoc_chip_pads

### Add fillers
source filler.tcl

### Routing 
source route.tcl 

report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/4post_route_nanosoc_imp_timing_early.rep
report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/4post_route_nanosoc_imp_timing_late.rep

check_antenna
write_db nanosoc_chip_pads

delete_routes -net VDDIO
delete_routes -net VSSIO
source place_bondpads.tcl

check_drc -out_file $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_drc.rep
check_filler -out_file $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_filler.rep
check_connectivity -out_file $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_connectivity.rep
check_process_antenna -out_file $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_antenna.rep
gui_show 

report_timing -output_format gtd -max_paths 10000 -path_exceptions all -early > timing_full_default_early.mtarpt
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -late > timing_full_default_late.mtarpt
set_analysis_view -setup [list typical_analysis_view] -hold [list typical_analysis_view]
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -early > timing_full_typical_early.mtarpt
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -late > timing_full_typical_late.mtarpt
set_analysis_view -setup [list default_analysis_view_setup typical_analysis_view] -hold [list default_analysis_view_hold typical_analysis_view]

write_stream $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/nanosoc.gds \
    -map_file /home/dwn1c21/SoC-Labs/util/PRTF_EDI_65nm_001_Cad_V24a/PR_tech/Cadence/GdsOutMap/PRTF_EDI_N65_gdsout_6X1Z1U.24a.map \
    -lib_name DesignLib \
    -merge [list ${SC_GDS2} ${RF_16K_GDS2} ${RF_08K_GDS2} ${ROM_VIA_GDS2}]\
    -output_macros -unit 1000 -mode all  

report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_area.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_power.rep

report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_timing_late.rep
report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_timing_early.rep

set_analysis_view -setup [list typical_analysis_view] -hold [list typical_analysis_view]
report_timing -late > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_timing_typical_late.rep
report_timing -early > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/nanosoc_imp_timing_typical_early.rep

set_analysis_view -setup [list default_analysis_view_setup typical_analysis_view] -hold [list default_analysis_view_hold typical_analysis_view]

write_netlist $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_PnR/nanosoc_chip_pads_44pin.v
write_sdf -min_view default_analysis_view_hold -typical_view typical_analysis_view -max_view default_analysis_view_setup $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist_PnR/nanosoc_chip_pads_44pin.sdf

write_db nanosoc_chip_pads
