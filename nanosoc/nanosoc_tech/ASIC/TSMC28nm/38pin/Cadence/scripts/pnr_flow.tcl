#-----------------------------------------------------------------------------
# NanoSoC Place and route script for Cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: innovus -f pnr_flow.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

set SC_GDS2 $::env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/gds2/sc12_cln65lp_base_rvt.gds2
set SC_HVT_GDS2 $::env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_hvt/r0p0/gds2/sc12_cln65lp_base_hvt.gds2
set PMK_GDS2 $::env(PHYS_IP)/arm/tsmc/cln65lp/sc12_pmk_rvt_hvt/r0p0/gds2/sc12_cln65lp_pmk_rvt_hvt.gds2
set RF_16K_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/rf_16k/rf_16k.gds2
set RF_08K_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/rf_08k/rf_08k.gds2
set ROM_VIA_GDS2 $::env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via.gds2

setMultiCpuUsage -localCpu 8
puts "Starting PnR Flow ..."


### Design Import 
source ../scripts/design_import_noDFT.tcl  

### IO Planning 
source ../scripts/io_plan.tcl

read_power_intent -cpf ../outputs/nanosoc_syn_out.cpf
commit_power_intent
reportPowerDomain
saveDesign nanosoc_chip_pads

update_delay_corner -name default_delay_corner_max -power_domain TOP
update_delay_corner -name default_delay_corner_max -power_domain ACCEL
update_delay_corner -name default_delay_corner_min -power_domain ACCEL
update_delay_corner -name default_delay_corner_min -power_domain TOP
update_delay_corner -name default_delay_corner_ocv -power_domain TOP
update_delay_corner -name default_delay_corner_ocv -power_domain ACCEL
update_delay_corner -name typical_delay_corner -power_domain ACCEL
update_delay_corner -name typical_delay_corner -power_domain TOP

### Memory and accelerator placement
source ../scripts/place_macros.tcl

### Power Plan 
source ../scripts/power_plan.tcl 

### Power Route 
source ../scripts/power_route.tcl 

report_timing -late > ../reports/1pre_place_nanosoc_imp_timing_late.rep
report_timing -early > ../reports/1pre_place_nanosoc_imp_timing_early.rep

uniquify nanosoc_chip_pads -verbose
saveDesign nanosoc_chip_pads
### Placement 
source ../scripts/place.tcl 

report_timing -late > ../reports/2post_place_nanosoc_imp_timing_late.rep
report_timing -early > ../reports/2post_place_nanosoc_imp_timing_early.rep

#reorder_scan 
saveDesign nanosoc_chip_pads

### CTS 
source ../scripts/clock_tree_synthesis.tcl 
#reorder_scan -clock_aware true

report_timing -late > ../reports/3post_clock_nanosoc_imp_timing_late.rep
report_timing -early > ../reports/3post_clock_nanosoc_imp_timing_early.rep

saveDesign nanosoc_chip_pads

### Add fillers
source ../scripts/filler.tcl

### Routing 
source ../scripts/route.tcl 

report_timing -early > ../reports/4post_route_nanosoc_imp_timing_early.rep
report_timing -late > ../reports/4post_route_nanosoc_imp_timing_late.rep

optDesign -postRoute

report_timing -early > ../reports/5post_route_opt_nanosoc_imp_timing_early.rep
report_timing -late > ../reports/5post_route_opt_nanosoc_imp_timing_late.rep

check_antenna
saveDesign nanosoc_chip_pads

delete_routes -net VDDIO
delete_routes -net VSSIO
source place_bondpads.tcl

check_drc -out_file ../reports/nanosoc_imp_drc.rep
check_filler -out_file ../reports/nanosoc_imp_filler.rep
check_connectivity -out_file ../reports/nanosoc_imp_connectivity.rep
check_process_antenna -out_file ../reports/nanosoc_imp_antenna.rep
gui_show 

report_timing -output_format gtd -max_paths 10000 -path_exceptions all -early > timing_full_default_early.mtarpt
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -late > timing_full_default_late.mtarpt
set_analysis_view -setup [list typical_analysis_view] -hold [list typical_analysis_view]
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -early > timing_full_typical_early.mtarpt
report_timing -output_format gtd -max_paths 10000 -path_exceptions all -late > timing_full_typical_late.mtarpt
set_analysis_view -setup [list default_analysis_view_setup typical_analysis_view] -hold [list default_analysis_view_hold typical_analysis_view]

write_stream ../outputs/nanosoc.gds \
    -map_file /home/dwn1c21/SoC-Labs/util/PRTF_EDI_65nm_001_Cad_V24a/PR_tech/Cadence/GdsOutMap/PRTF_EDI_N65_gdsout_6X1Z1U.24a.map \
    -lib_name DesignLib \
    -merge [list ${SC_GDS2} ${RF_16K_GDS2} ${RF_08K_GDS2} ${ROM_VIA_GDS2}]\
    -output_macros -unit 1000 -mode all  

report_area > ../reports/nanosoc_imp_area.rep
report_power > ../reports/nanosoc_imp_power.rep

report_timing -late > ../reports/nanosoc_imp_timing_late.rep
report_timing -early > ../reports/nanosoc_imp_timing_early.rep

set_analysis_view -setup [list typical_analysis_view] -hold [list typical_analysis_view]
report_timing -late > ../reports/nanosoc_imp_timing_typical_late.rep
report_timing -early > ../reports/nanosoc_imp_timing_typical_early.rep

set_analysis_view -setup [list default_analysis_view_setup typical_analysis_view] -hold [list default_analysis_view_hold typical_analysis_view]

write_netlist ../outputs/nanosoc_chip_pads_38pin_pnr.v
write_sdf -min_view default_analysis_view_hold -typical_view typical_analysis_view -max_view default_analysis_view_setup ../outputs/nanosoc_chip_pads_38pin_pnr.sdf

saveDesign nanosoc_chip_pads
