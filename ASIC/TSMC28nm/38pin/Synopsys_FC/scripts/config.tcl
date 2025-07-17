## Paths Please Edit for your system
set TSMC_28_base_path           /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28
set tech_file           $TSMC_28_base_path/CMOS/util/PRTF_ICC_28nm_Syn_V19_1a/tsmcn28_9lm5X1Y1Z1UUTRDL.tf
set tphn28hpcpgv18_lib_path     $TSMC_28_base_path/CMOS/HPC+/IO1.8V/iolib/STAGGERED/tphn28hpcpgv18_170d_FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hpcpgv18_170a
set cln28ht_tech_path           /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0
set standard_cell_base_path     /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_base_svt_c30/r0p0
set pmk_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_pmk_svt_c30/r0p0
set ret_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_rklo_lvt_svt_c30_c35/r1p0
set hpc_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_hpk_svt_c30/r0p0
#set Synopsys_PLL_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/PLL/synopsys/dwc_pll3ghz_tsmc28hpcp/1.10a/macro
#set Synopsys_TS_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/1.01b
#set Synopsys_PD_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/dwc_sensors_pd_tsmc28hpcp_1.00a/synopsys/dwc_sensors_pd_tsmc28hpcp/1.00a
#set Synopsys_VM_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/dwc_sensors_vm_shrink_tsmc28hpcp_1.00a/synopsys/dwc_sensors_vm_shrink_tsmc28hpcp/1.00a
set standard_cell_gds_file 	$standard_cell_base_path/gds2/sc7mcpp140z_cln28ht_base_svt_c30.gds2
set pmk_gds_file           	$pmk_base_path/gds2/sc7mcpp140z_cln28ht_pmk_svt_c30.gds2
set ret_gds_file           	$ret_base_path/gds2/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35.gds2
set hpc_gds_file           	$hpc_base_path/gds2/sc7mcpp140z_cln28ht_hpk_svt_c30.gds2

set sram_16k_path               $env(SOCLABS_PROJECT_DIR)/memories/sram_16k
set rom_path                    $env(SOCLABS_PROJECT_DIR)/memories/bootrom
set sram_32k_gds_file   	$env(SOCLABS_PROJECT_DIR)/memories/sram_32k/sram_32k.gds2
set sram_16k_gds_file   	$env(SOCLABS_PROJECT_DIR)/memories/sram_16k/sram_16k.gds2
set bootrom_gds_file 		$env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via.gds2
#set Synopsys_PLL_gds_file 	$Synopsys_PLL_dir/gds/5m4x0z/dwc_z19606ts_ns.gds
#set Synopsys_TS_gds_file 	$Synopsys_TS_dir/gdsii/mr74127_v1r1.gds
#set Synopsys_PD_gds_file    	$Synopsys_PD_dir/gds/mr74125_v1r2.gds
#set Synopsys_VM_gds_file    	$Synopsys_VM_dir/gdsii/mr74140_v1r1.gds

set gds_layer_map $TSMC_28_base_path/CMOS/util/PRTF_ICC_28nm_Syn_V19_1a/PR_tech/Synopsys/GdsOutMap/gdsout_5X1Y1Z1U.map
set gds_merge_file_list [list $standard_cell_gds_file \
	$pmk_gds_file \
	$hpc_gds_file \
	$sram_16k_gds_file \
	$bootrom_gds_file \
]

set REPORT_DIR ../reports
set LOG_DIR ../logs
set OUT_DIR ../outputs

# nanosoc Specifics - don't edit
set file_tcl_list $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl
set file_formality_list $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/formality_flist.tcl
set top_level_verilog $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/nanosoc_chip_pads/tsmc28hpcp/nanosoc_chip_pads_38pin.v

# Variables used in scripts
set lib_name nanosoc_chip_pads
set block_name nanosoc_chip_pads

set lib_path_list [list ../libs/cln28ht/ ../libs/cln28ht_pmk/ ../libs/cln28ht_hpk/  ../libs/sram_16k/  ../libs/rom_via/ ../libs/io_lib/ ../libs/pad_lib/ ]
set lib_list {cln28ht cln28ht_pmk cln28ht_hpk sram_16k rom_via io_lib pad_lib} 

# Libary files for formality
set TSMC_IO_FORMALITY  $tphn28hpcpgv18_lib_path/tphn28hpcpgv18tt0p9v1p8v25c.db
set SRAM_16K_FORMALITY $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_25c.db
set ROM_FORMALITY      $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.db

set STD_CELL_FORMALITY $standard_cell_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_base_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn
set PMK_FORMALITY      $pmk_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_pmk_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn
set HPK_FORMALITY      $hpc_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_hpk_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn


set formality_ref_libs_list [list $TSMC_IO_FORMALITY $SRAM_16K_FORMALITY $ROM_FORMALITY]
set formality_imp_libs_list [list \
    $TSMC_IO_FORMALITY \
    $SRAM_16K_FORMALITY \
    $ROM_FORMALITY \
    $STD_CELL_FORMALITY \
    $PMK_FORMALITY \
    $HPK_FORMALITY \
]
