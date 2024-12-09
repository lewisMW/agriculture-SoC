# Technology files
set cln28ht_tech_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0
set cln28ht_tech_file   $cln28ht_tech_path/milkyway/1p8m_5x2z_utalrdl/sc9mcpp140z_tech.tf
set cln28ht_lef_file    $cln28ht_tech_path/lef/1p8m_5x2z_utalrdl/sc9mcpp140z_tech.lef

# Standard Cell libraries
set sc9mcpp140z_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc9mcpp140z_base_svt_c35/r0p0
set sc9mcpp140z_lef_file                $sc9mcpp140z_base_path/lef/sc9mcpp140z_cln28ht_base_svt_c35.lef
set sc9mcpp140z_gds_file                $sc9mcpp140z_base_path/gds2/sc9mcpp140z_cln28ht_base_svt_c35.gds2
set sc9mcpp140z_db_file_ss_0p81v_125C   $sc9mcpp140z_base_path/db/sc9mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db
set sc9mcpp140z_db_file_tt_0p90v_25C    $sc9mcpp140z_base_path/db/sc9mcpp140z_cln28ht_base_svt_c35_tt_ctypical_max_0p90v_25c.db
set sc9mcpp140z_db_file_ff_0p99v_m40C   $sc9mcpp140z_base_path/db/sc9mcpp140z_cln28ht_base_svt_c35_ffg_cbestt_min_0p99v_m40c.db
set sc9mcpp140z_antenna_file            $sc9mcpp140z_base_path/milkyway/1p8m_5x2z_utalrdl/sc9mcpp140z_cln28ht_base_svt_c35_antenna.clf

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
create_fusion_lib -dbs [list $sc9mcpp140z_db_file_ss_0p81v_125C $sc9mcpp140z_db_file_tt_0p90v_25C $sc9mcpp140z_db_file_ff_0p99v_m40C]  -lefs [list $cln28ht_lef_file $sc9mcpp140z_lef_file] -technology $cln28ht_tech_file cln28ht
save_fusion_lib cln28ht

close_fusion_lib cln28ht

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


exit