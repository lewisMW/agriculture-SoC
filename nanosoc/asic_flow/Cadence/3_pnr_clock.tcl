#-----------------------------------------------------------------------------
# Place and route setup script for Cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: innovus -stylus -f 2_pnr_setup.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
source ../scripts/config.tcl

set_multi_cpu_usage -local_cpu 8
puts "Starting CTS Flow ..."

read_db $block_name
source $env(SOCLABS_ASIC_FLOW_DIR)/Cadence/procs.tcl

source ../scripts/cts_setup.tcl

### Clock Tree Sepc 
create_clock_tree_spec -out_file design_clk.spec 

### Creating a Clock Tree 
ccopt_design 

report_intermediate_step 02_cts $REPORT_DIR

### Optimizing the design 
opt_design -post_cts 
opt_design -post_cts -hold 

if {$DFT == 1} {
    reorder_scan -clock_aware true
}

report_end_step 03_cts_opt $REPORT_DIR

write_db $block_name

exit

