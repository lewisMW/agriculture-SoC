set_host_options -max_cores 16 -num_processes 16

source ../scripts/setup.tcl

set standard_cell_gds_file 	$standard_cell_base_path/gds2/sc7mcpp140z_cln28ht_base_svt_c30.gds2
set pmk_gds_file           	$pmk_base_path/gds2/sc7mcpp140z_cln28ht_pmk_svt_c30.gds2
set ret_gds_file           	$ret_base_path/gds2/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35.gds2
set hpc_gds_file           	$hpc_base_path/gds2/sc7mcpp140z_cln28ht_hpk_svt_c30.gds2
set sram_32k_gds_file   	$env(SOCLABS_PROJECT_DIR)/memories/sram_32k/sram_32k.gds2
set sram_16k_gds_file   	$env(SOCLABS_PROJECT_DIR)/memories/sram_32b_16k/sram_32b_16k.gds2
set bootrom_gds_file 		$env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via.gds2
#set Synopsys_PLL_gds_file 	$Synopsys_PLL_dir/gds/5m4x0z/dwc_z19606ts_ns.gds
#set Synopsys_TS_gds_file 	$Synopsys_TS_dir/gdsii/mr74127_v1r1.gds
#set Synopsys_PD_gds_file    	$Synopsys_PD_dir/gds/mr74125_v1r2.gds
#set Synopsys_VM_gds_file    	$Synopsys_VM_dir/gdsii/mr74140_v1r1.gds


write_gds -lib_cell_view frame \
 	-layer_map $cln28ht_tech_path/milkyway/1p8m_5x2z_utalrdl/stream_out_layer_map \
	-allow_design_mismatch -long_names -hierarchy all -units 1000 \
	-merge_files [list $standard_cell_gds_file \
	$pmk_gds_file \
	$ret_gds_file \
	$sram_32k_gds_file \
	$bootrom_gds_file \
  	] $OUT_DIR/nanosoc_chip_pads.gds 
write_verilog -top_module_first -hierarchy all \
	-exclude {corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells pg_netlist spare_cells} $OUT_DIR/nanosoc_chip_pads_gate.v
write_verilog -top_module_first -hierarchy all \
	-exclude {corner_cells filler_cells flip_chip_pad_cells pad_spacer_cells spare_cells} $OUT_DIR/nanosoc_chip_pads_gate_power.v

write_sdf $OUT_DIR/nanosoc_chip_pads_gate.sdf

set_svf $OUT_DIR/impl.svf