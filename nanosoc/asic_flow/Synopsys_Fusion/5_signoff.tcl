#-----------------------------------------------------------------------------
# ASIC Flow signoff and export
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fc_shell -f 5_signoff.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

source ../scripts/config.tcl

open_lib ${lib_name}.dlib/
open_block $block_name

set_host_options -max_cores 16 -num_processes 16

source ../scripts/setup.tcl
source $env(SOCLABS_ASIC_FLOW_DIR)/Synopsys_Fusion/procs.tcl

signoff_fix_drc -max_number_repair_loop 10


write_gds -lib_cell_view frame \
 	-layer_map $gds_layer_map \
	-allow_design_mismatch -long_names -hierarchy all -units 1000 \
	-merge_files $gds_merge_file_list \
  	$OUT_DIR/${block_name}.gds 

write_verilog -top_module_first -hierarchy all \
	-exclude {leaf_module_declarations empty_modules corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells pg_netlist spare_cells} $OUT_DIR/${block_name}_gate.v
write_verilog -top_module_first -hierarchy all \
	-exclude {leaf_module_declarations empty_modules corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells spare_cells} $OUT_DIR/${block_name}_gate_power.v

write_sdf $OUT_DIR/${block_name}_gate.sdf

set_svf $OUT_DIR/impl.svf

exit