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
puts "Starting PnR Flow ..."

### Settting PG Nets 
set_db init_power_nets $power_nets 
set_db init_ground_nets $ground_nets

### Processing MMMC 
read_mmmc ../scripts/${block_name}.mmmc 

### Reading LEFs 
read_physical -lef $lef_file_list

### Reading Netlist 
read_netlist $OUT_DIR/${block_name}_gate_power.v

### Read DEF scan chain
if {$DFT == 1} {
    read_def $OUT_DIR/$block_name.def
}

### Initializing the Design 
init_design

read_power_intent -cpf $OUT_DIR/${block_name}_gate1.cpf

commit_power_intent

set_db design_process_node $process_node

source ../scripts/floorplan.tcl
source ../scripts/power_plan.tcl

source $env(SOCLABS_ASIC_FLOW_DIR)/Cadence/procs.tcl

### Placement
report_intermediate_step 00_pre_place $REPORT_DIR

source ../scripts/preplace.tcl

place_design

if {$DFT == 1} {
    reorder_scan
}

report_end_step 01_place $REPORT_DIR

source ../scripts/postplace.tcl

write_db $block_name

exit


