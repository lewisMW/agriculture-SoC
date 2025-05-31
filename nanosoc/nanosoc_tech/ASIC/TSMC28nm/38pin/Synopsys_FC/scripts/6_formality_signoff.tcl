
set TSMC_28NM_PDK_PATH          /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28
set tphn28hpcpgv18_lib_path     $TSMC_28NM_PDK_PATH/CMOS/HPC+/IO1.8V/iolib/STAGGERED/tphn28hpcpgv18_170d_FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hpcpgv18_170a
set standard_cell_base_path     /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_base_svt_c30/r0p0
set pmk_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_pmk_svt_c30/r0p0
set ret_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_rklo_lvt_svt_c30_c35/r1p0
set hpc_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_hpk_svt_c30/r0p0

set sram_16k_path               $env(SOCLABS_PROJECT_DIR)/memories/sram_16k
set rom_path                    $env(SOCLABS_PROJECT_DIR)/memories/bootrom

set IO_TT_0p90v_1p80v_25c_db    $tphn28hpcpgv18_lib_path/tphn28hpcpgv18tt0p9v1p8v25c.db
set db_sram_16k_tt_ctypical_0p90v_25c   $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_25c.db
set db_rom_tt_ctypical_0p90v_25c   $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.db

set db_base_svt_c35_tt_ctypical_max_0p90v_25c   $standard_cell_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_base_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn
set db_pmk_svt_c35_tt_ctypical_max_0p90v_25c    $pmk_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_pmk_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn
set db_hpk_c35_tt_ctypical_max_0p90v_25c    $hpc_base_path/db-ccs-tn/sc7mcpp140z_cln28ht_hpk_svt_c30_tt_ctypical_max_0p90v_25c.db_ccs_tn


set_mismatch_message_filter -warn FMR_ELAB-147
set_mismatch_message_filter -warn FMR_ELAB-058
set_svf ./default-20250528_srv03335_3030032.svf

set hdlin_allow_partial_pg_netlist true

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/formality_flist.tcl
read_verilog -define POWER_PINS -r $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/nanosoc_chip_pads/tsmc28hpcp/nanosoc_chip_pads_38pin.v

read_db -r $IO_TT_0p90v_1p80v_25c_db
read_db -r $db_sram_16k_tt_ctypical_0p90v_25c
read_db -r $db_rom_tt_ctypical_0p90v_25c 

set_top nanosoc_chip_pads

read_db -i $IO_TT_0p90v_1p80v_25c_db
read_db -i $db_sram_16k_tt_ctypical_0p90v_25c
read_db -i $db_rom_tt_ctypical_0p90v_25c 
read_db -i $db_base_svt_c35_tt_ctypical_max_0p90v_25c
read_db -i $db_pmk_svt_c35_tt_ctypical_max_0p90v_25c
read_db -i $db_hpk_c35_tt_ctypical_max_0p90v_25c
read_verilog -i ../outputs/nanosoc_chip_pads_gate.v

set_top nanosoc_chip_pads

match
verify

analyze_points -failing

save_session nanosoc_chip_pads_formal_equivalence