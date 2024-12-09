## Paths Please Edit for your system
set cln28ht_tech_path           /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0
set standard_cell_base_path     /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_base_svt_c35/r2p0
set pmk_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_pmk_svt_c35/r1p0
set ret_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_rklo_lvt_svt_c30_c35/r1p0

# Technology files
set cln28ht_tech_file                       $cln28ht_tech_path/milkyway/1p8m_5x2z_utalrdl/sc12mcpp140z_tech.tf
set cln28ht_lef_file                        $cln28ht_tech_path/lef/1p8m_5x2z_utalrdl/sc12mcpp140z_tech.lef

# Standard Cell libraries
set standard_cell_lef_file                  $standard_cell_base_path/lef/sc12mcpp140z_cln28ht_base_svt_c35.lef
set standard_cell_gds_file                  $standard_cell_base_path/gds2/sc12mcpp140z_cln28ht_base_svt_c35.gds2
set standard_cell_db_file_ss_0p81v_125C     $standard_cell_base_path/db/sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db
set standard_cell_db_file_tt_0p90v_25C      $standard_cell_base_path/db/sc12mcpp140z_cln28ht_base_svt_c35_tt_ctypical_max_0p90v_25c.db
set standard_cell_db_file_ff_0p99v_m40C     $standard_cell_base_path/db/sc12mcpp140z_cln28ht_base_svt_c35_ffg_cbestt_min_0p99v_m40c.db
set standard_cell_antenna_file              $standard_cell_base_path/milkyway/1p8m_5x2z_utalrdl/sc12mcpp140z_cln28ht_base_svt_c35_antenna.clf

# Power Management Kit 
set pmk_lef_file                            $pmk_base_path/lef/sc12mcpp140z_cln28ht_pmk_svt_c35.lef
set pmk_gds_file                            $pmk_base_path/gds2/sc12mcpp140z_cln28ht_pmk_svt_c35.gds2
set pmk_db_file_ss_0p81v_125C               $pmk_base_path/db/sc12mcpp140z_cln28ht_pmk_svt_c35_ssg_cworstt_max_0p81v_125c.db
set pmk_db_file_tt_0p90v_25C                $pmk_base_path/db/sc12mcpp140z_cln28ht_pmk_svt_c35_tt_ctypical_max_0p90v_25c.db
set pmk_db_file_ff_0p99v_m40C               $pmk_base_path/db/sc12mcpp140z_cln28ht_pmk_svt_c35_ffg_cbestt_min_0p99v_m40c.db
set pmk_antenna_file                        $pmk_base_path/milkyway/1p8m_5x2z_utalrdl/sc12mcpp140z_cln28ht_pmk_svt_c35_antenna.clf

# Retention Kit
set ret_lef_file                            $ret_base_path/lef/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35.lef
set ret_gds_file                            $ret_base_path/gds2/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35.gds2
set ret_db_file_ss_0p81v_125C               $ret_base_path/db/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35_ssg_cworstt_max_0p81v_125c.db
set ret_db_file_tt_0p90v_25C                $ret_base_path/db/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35_tt_ctypical_max_0p90v_25c.db
set ret_db_file_ff_0p99v_m40C               $ret_base_path/db/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35_ffg_cbestt_min_0p99v_m40c.db
set ret_antenna_file                        $ret_base_path/milkyway/1p8m_5x2z_utalrdl/sc12mcpp140z_cln28ht_rklo_lvt_svt_c30_c35_antenna.clf


# IO Paths
set TSMC_28NM_PDK_PATH          /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28
set tphn28hpcpgv18_lef_file     $TSMC_28NM_PDK_PATH/CMOS/HPC+/IO1.8V/iolib/TSMCHOME/digital/Back_End/lef/tphn28hpcpgv18_110a/mt_2/6lm/lef/tphn28hpcpgv18_6lm.lef
set tphn28hpcpgv18_lib_path     $TSMC_28NM_PDK_PATH/CMOS/HPC+/IO1.8V/iolib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hpcpgv18_170a
set IO_TT_0p9v_1p8v_25c_db      $tphn28hpcpgv18_lib_path/tphn28hpcpgv18tt0p9v1p8v25c.db
set IO_FF_0p99v_1p98v_m40c_db   $tphn28hpcpgv18_lib_path/tphn28hpcpgv18ffg0p99v1p98vm40c.db
set IO_SS_0p81v_1p62v_125c_db   $tphn28hpcpgv18_lib_path/tphn28hpcpgv18ssg0p81v1p62v125c.db

set pad_lef_file /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/iolib/TSMCHOME/digital/Back_End/lef/tpbn28v_160a/cup/8m/8M_5X2Z/lef/tpbn28v_8lm.lef

# SRAM files (using Arm compiler)
set sram_16k_path                       $env(SOCLABS_PROJECT_DIR)/memories/sram_16k
set sram_16k_lef_file                   $sram_16k_path/sram_16k.lef
set sram_16k_gds_file                   $sram_16k_path/sram_16k.gds2
set sram_16k_lib_file_ss_0p81v_125c     $sram_16k_path/sram_16k_ssg_cworstt_0p81v_0p81v_125c.lib
set sram_16k_lib_file_tt_0p90v_25c      $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_85c.lib
set sram_16k_lib_file_ff_0p99v_m40c     $sram_16k_path/sram_16k_ffg_cbestt_0p99v_0p99v_m40c.lib
set sram_16k_db_file_ss_0p81v_125c      $sram_16k_path/sram_16k_ssg_cworstt_0p81v_0p81v_125c.db
set sram_16k_db_file_tt_0p90v_25c       $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_85c.db
set sram_16k_db_file_ff_0p99v_m40c      $sram_16k_path/sram_16k_ffg_cbestt_0p99v_0p99v_m40c.db

# ROM Files (using arm Compiler)
set rom_path                        $env(SOCLABS_PROJECT_DIR)/memories/bootrom
set rom_via_lef_file                $rom_path/rom_via.lef       
set rom_via_gds_file                $rom_path/rom_via.gds2
set rom_via_lib_file_ss_0p81v_125c  $rom_path/rom_via_ssg_cworstt_0p81v_0p81v_125c.lib
set rom_via_lib_file_tt_0p90v_25c   $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.lib
set rom_via_lib_file_ff_0p99v_m40c  $rom_path/rom_via_ffg_cbestt_0p99v_0p99v_m40c.lib
set rom_via_db_file_ss_0p81v_125c   $rom_path/rom_via_ssg_cworstt_0p81v_0p81v_125c.db
set rom_via_db_file_tt_0p90v_25c    $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.db
set rom_via_db_file_ff_0p99v_m40c   $rom_path/rom_via_ffg_cbestt_0p99v_0p99v_m40c.db

# Create standard cell fusion library
create_fusion_lib -dbs [list $standard_cell_db_file_ss_0p81v_125C $standard_cell_db_file_tt_0p90v_25C $standard_cell_db_file_ff_0p99v_m40C]  -lefs [list $cln28ht_lef_file $standard_cell_lef_file] -technology $cln28ht_tech_file cln28ht
save_fusion_lib cln28ht
close_fusion_lib cln28ht

# Create Power Management Kit fusion library
create_fusion_lib -dbs [list $pmk_db_file_ss_0p81v_125C $pmk_db_file_tt_0p90v_25C $pmk_db_file_ff_0p99v_m40C] -lefs [list $cln28ht_lef_file $pmk_lef_file] -technology $cln28ht_tech_file cln28ht_pmk
save_fusion_lib cln28ht_pmk
close_fusion_lib cln28ht_pmk

# Create Retention fusion library
create_fusion_lib -dbs [list $ret_db_file_ss_0p81v_125C $ret_db_file_tt_0p90v_25C $ret_db_file_ff_0p99v_m40C] -lefs [list $cln28ht_lef_file $ret_lef_file] -technology $cln28ht_tech_file cln28ht_ret
save_fusion_lib cln28ht_ret
close_fusion_lib cln28ht_ret

# 16K SRAM
read_lib $sram_16k_lib_file_ss_0p81v_125c 
write_lib -output $sram_16k_db_file_ss_0p81v_125c -format db SRAM_16K_ssg_cworstt_0p81v_0p81v_125c
close_lib -all

read_lib $sram_16k_lib_file_tt_0p90v_25c 
write_lib -output $sram_16k_db_file_tt_0p90v_25c -format db SRAM_16K_tt_ctypical_0p90v_0p90v_85c
close_lib -all

read_lib $sram_16k_lib_file_ff_0p99v_m40c 
write_lib -output $sram_16k_db_file_ff_0p99v_m40c -format db SRAM_16K_ffg_cbestt_0p99v_0p99v_m40c
close_lib -all

create_fusion_lib -dbs [list $sram_16k_db_file_ss_0p81v_125c $sram_16k_db_file_tt_0p90v_25c $sram_16k_db_file_ff_0p99v_m40c] -lefs $sram_16k_lef_file -technology $cln28ht_tech_file sram_16k
save_fusion_lib sram_16k
close_fusion_lib sram_16k

# Boot ROM
read_lib $rom_via_lib_file_ss_0p81v_125c 
write_lib -output $rom_via_db_file_ss_0p81v_125c -format db rom_via_ssg_cworstt_0p81v_0p81v_125c
close_lib -all

read_lib $rom_via_lib_file_tt_0p90v_25c 
write_lib -output $rom_via_db_file_tt_0p90v_25c -format db rom_via_tt_ctypical_0p90v_0p90v_25c
close_lib -all

read_lib $rom_via_lib_file_ff_0p99v_m40c 
write_lib -output $rom_via_db_file_ff_0p99v_m40c -format db rom_via_ffg_cbestt_0p99v_0p99v_m40c
close_lib -all

create_fusion_lib -dbs [list $rom_via_db_file_ss_0p81v_125c $rom_via_db_file_tt_0p90v_25c $rom_via_db_file_ff_0p99v_m40c] -lefs $rom_via_lef_file -technology $cln28ht_tech_file rom_via
save_fusion_lib rom_via
close_fusion_lib rom_via

# IO Lib
create_fusion_lib -dbs [list $IO_SS_0p81v_1p62v_125c_db $IO_TT_0p9v_1p8v_25c_db $IO_FF_0p99v_1p98v_m40c_db] -lefs $tphn28hpcpgv18_lef_file -technology $cln28ht_tech_file io_lib
save_fusion_lib io_lib
close_fusion_lib io_lib

# Pad Lib
create_fusion_lib -lefs $pad_lef_file -technology $cln28ht_tech_file pad_lib
save_fusion_lib pad_lib
close_fusion_lib pad_lib
exit