## Paths Please Edit for your system
set cln16fcll_tech_path         /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0
set standard_cell_base_path     /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/sc9mcpp96c_base_svt_c24/r2p0
set arm_io_base_path            /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/io_gppr_t18_mv08_fs18_rvt_dr/r1p3
set pmk_base_path               /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/sc9mcpp96c_pmk_svt_c24/r2p0
set ret_base_path               /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/sc9mcpp96c_rklo_lvt_svt_c20_c24/r1p0

# Technology files
set cln16fcll_tech_file                       $cln16fcll_tech_path/ndm/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_tech.tf
set cln16fcll_lef_file                        $cln16fcll_tech_path/lef/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_tech.lef

# Standard Cell libraries
set standard_cell_lef_file                  $standard_cell_base_path/lef/sc9mcpp96c_cln16fcll001_base_svt_c24.lef
set standard_cell_gds_file                  $standard_cell_base_path/gds2/sc9mcpp96c_cln16fcll001_base_svt_c24.gds2
set standard_cell_db_file_ss_0p72v_125C     $standard_cell_base_path/db/sc9mcpp96c_cln16fcll001_base_svt_c24_ssgnp_cworstccworstt_max_0p72v_125c.db
set standard_cell_db_file_tt_0p80v_25C      $standard_cell_base_path/db/sc9mcpp96c_cln16fcll001_base_svt_c24_tt_typical_max_0p80v_25c.db
set standard_cell_db_file_ff_0p88v_m40C     $standard_cell_base_path/db/sc9mcpp96c_cln16fcll001_base_svt_c24_ffgnp_cbestccbestt_min_0p88v_m40c.db
set standard_cell_antenna_file              $standard_cell_base_path/milkyway/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_cln16fcll001_base_svt_c24_antenna.clf

# Arm IO Library
set arm_io_lef_file                         $arm_io_base_path/lef/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_9m_2xa1xd3xe2z_fc.lef
set arm_io_gds_file                         $arm_io_base_path/gds2/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_9m_2xa1xd3xe2z_fc.gds2
set arm_io_db_file_ss_0p72v_125C            $arm_io_base_path/db/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_ssgnp_cworstccworstt_0p72v_1p62v_125c.db
set arm_io_db_file_tt_0p80v_25C             $arm_io_base_path/db/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_tt_typical_0p80v_1p80v_25c.db
set arm_io_db_file_ff_0p88v_m40C            $arm_io_base_path/db/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_ffgnp_cbestccbestt_0p88v_1p98v_m40c.db
set arm_io_antenna_file                     $arm_io_base_path/milkyway/9m_2xa1xd3xe2z_fc/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_antenna.clf

# 32K SRAM PATHS
set SRAM_32K_PATH            $env(SOCLABS_PROJECT_DIR)/memories/sram_32k
set SRAM_32K_lef_file        $SRAM_32K_PATH/sram_32k.lef
set SRAM_32K_gds_file        $SRAM_32K_PATH/sram_32k.gds2
set SRAM_32K_lib_file_ss     $SRAM_32K_PATH/sram_32k_ssgnp_0p72v_0p72v_125c.lib
set SRAM_32K_lib_file_tt     $SRAM_32K_PATH/sram_32k_tt_0p80v_0p80v_25c.lib
set SRAM_32K_lib_file_ff     $SRAM_32K_PATH/sram_32k_ffgnp_0p88v_0p88v_m40c.lib
set SRAM_32K_db_file_ss      $SRAM_32K_PATH/sram_32k_ssgnp_0p72v_0p72v_125c.db
set SRAM_32K_db_file_tt      $SRAM_32K_PATH/sram_32k_tt_0p80v_0p80v_25c.db
set SRAM_32K_db_file_ff      $SRAM_32K_PATH/sram_32k_ffgnp_0p88v_0p88v_m40c.db

# ROM PATHS
set ROM_VIA_PATH            $env(SOCLABS_PROJECT_DIR)/memories/bootrom
set ROM_VIA_lef_file        $ROM_VIA_PATH/rom_via.lef
set ROM_VIA_gds_file        $ROM_VIA_PATH/rom_via.gds2
set ROM_VIA_lib_file_ss     $ROM_VIA_PATH/rom_via_ssgnp_0p72v_0p72v_125c.lib
set ROM_VIA_lib_file_tt     $ROM_VIA_PATH/rom_via_tt_0p80v_0p80v_25c.lib
set ROM_VIA_lib_file_ff     $ROM_VIA_PATH/rom_via_ffgnp_0p88v_0p88v_m40c.lib
set ROM_VIA_db_file_ss      $ROM_VIA_PATH/rom_via_ssgnp_0p72v_0p72v_125c.db
set ROM_VIA_db_file_tt      $ROM_VIA_PATH/rom_via_tt_0p80v_0p80v_25c.db
set ROM_VIA_db_file_ff      $ROM_VIA_PATH/rom_via_ffgnp_0p88v_0p88v_m40c.db

# 32K SRAMs
read_lib $SRAM_32K_lib_file_ss
write_lib -output $SRAM_32K_db_file_ss -format db sram_32k_ssgnp_0p72v_0p72v_125c
close_lib -all

read_lib $SRAM_32K_lib_file_tt 
write_lib -output $SRAM_32K_db_file_tt -format db sram_32k_tt_0p80v_0p80v_25c
close_lib -all

read_lib $SRAM_32K_lib_file_ff 
write_lib -output $SRAM_32K_db_file_ff -format db sram_32k_ffgnp_0p88v_0p88v_m40c
close_lib -all

create_fusion_lib -dbs [list $SRAM_32K_db_file_ss $SRAM_32K_db_file_tt $SRAM_32K_db_file_ff] -lefs $SRAM_32K_lef_file -technology $cln16fcll_tech_file SRAM_32K
save_fusion_lib SRAM_32K
close_fusion_lib SRAM_32K

# ROM VIA 
read_lib $ROM_VIA_lib_file_ss
write_lib -output $ROM_VIA_db_file_ss -format db rom_via_ssgnp_0p72v_0p72v_125c
close_lib -all

read_lib $ROM_VIA_lib_file_tt 
write_lib -output $ROM_VIA_db_file_tt -format db rom_via_tt_0p80v_0p80v_25c
close_lib -all

read_lib $ROM_VIA_lib_file_ff 
write_lib -output $ROM_VIA_db_file_ff -format db rom_via_ffgnp_0p88v_0p88v_m40c
close_lib -all

create_fusion_lib -dbs [list $ROM_VIA_db_file_ss $ROM_VIA_db_file_tt $ROM_VIA_db_file_ff] -lefs $ROM_VIA_lef_file -technology $cln16fcll_tech_file ROM_VIA
save_fusion_lib ROM_VIA
close_fusion_lib ROM_VIA



# Create standard cell fusion library
create_fusion_lib -dbs [list $standard_cell_db_file_ss_0p72v_125C $standard_cell_db_file_tt_0p80v_25C $standard_cell_db_file_ff_0p88v_m40C]  -lefs [list $cln16fcll_lef_file $standard_cell_lef_file] -technology $cln16fcll_tech_file cln16fcll
save_fusion_lib cln16fcll
close_fusion_lib cln16fcll

# Create Arm IO Library 
create_fusion_lib -dbs [list $arm_io_db_file_ss_0p72v_125C $arm_io_db_file_tt_0p80v_25C $arm_io_db_file_ff_0p88v_m40C]  -lefs [list $cln16fcll_lef_file $arm_io_lef_file] -technology $cln16fcll_tech_file arm_io_lib
save_fusion_lib arm_io_lib
close_fusion_lib arm_io_lib

exit