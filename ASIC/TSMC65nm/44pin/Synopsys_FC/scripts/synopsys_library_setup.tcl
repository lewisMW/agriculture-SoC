## Paths Please Edit for your system
set cln65lp_tech_path           /home/dwn1c21/SoC-Labs/phys_ip/TSMC/65/CMOS/LP/stclib/12-track/tcbn65lpbwp12t-set/tcbn65lpbwp12t_200b_FE/TSMCHOME/digital/Back_End
set standard_cell_base_path     /research/AAA/phys_ip_library/arm/tsmc/cln65lp/sc12_base_rvt/r0p0
set io_base_path                /home/dwn1c21/SoC-Labs/phys_ip/TSMC/65/CMOS/LP/IO2.5V/iolib/linear/tpdn65lpnv2od3_200a_FE/TSMCHOME/digital
set pmk_base_path               /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/sc9mcpp96c_pmk_svt_c24/r2p0
set ret_base_path               /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/sc9mcpp96c_rklo_lvt_svt_c20_c24/r1p0

# Technology files
set cln65lp_tech_file       $cln65lp_tech_path/milkyway/tcbn65lpbwp12t_200a/techfiles/tsmcn65_9lmT2.tf
set cln65lp_lef_file        $cln65lp_tech_path/lef/tcbn65lpbwp12t_140b/lef/tcbn65lpbwp12t_9lmT2.lef

# Standard Cell libraries
set standard_cell_lef_file                  $standard_cell_base_path/lef/sc12_cln65lp_base_rvt.lef
set standard_cell_gds_file                  $standard_cell_base_path/gds2/sc12_cln65lp_base_rvt.gds2
set standard_cell_db_file_ss_0p72v_125C     $standard_cell_base_path/db/sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.db
set standard_cell_db_file_tt_0p80v_25C      $standard_cell_base_path/db/sc12_cln65lp_base_rvt_tt_typical_max_1p20v_25c.db
set standard_cell_db_file_ff_0p88v_m40C     $standard_cell_base_path/db/sc12_cln65lp_base_rvt_ff_typical_min_1p32v_m40c.db
set standard_cell_antenna_file              $standard_cell_base_path/milkyway/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_cln16fcll001_base_svt_c24_antenna.clf

# Arm IO Library
set io_lef_file                         $io_base_path/Back_End/lef/tpdn65lpnv2od3_140b/mt_2/9lm/lef/tpdn65lpnv2od3_9lm.lef
set io_gds_file                         $io_base_path/gds2/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_9m_2xa1xd3xe2z_fc.gds2
set io_db_file_ss_0p72v_125C            $io_base_path/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3wc.db
set io_db_file_tt_0p80v_25C             $io_base_path/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3tc.db
set io_db_file_ff_0p88v_m40C            $io_base_path/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3bc.db
set io_antenna_file                     $io_base_path/milkyway/9m_2xa1xd3xe2z_fc/io_gppr_cln16fcll001_t18_mv08_fs18_rvt_dr_antenna.clf

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
create_fusion_lib -dbs [list $standard_cell_db_file_ss_0p72v_125C $standard_cell_db_file_tt_0p80v_25C $standard_cell_db_file_ff_0p88v_m40C]  -lefs [list $cln65lp_lef_file $standard_cell_lef_file] -technology $cln65lp_tech_file cln65lp
save_fusion_lib cln65lp
close_fusion_lib cln65lp

# Create Arm IO Library 
create_fusion_lib -dbs [list $io_db_file_ss_0p72v_125C $io_db_file_tt_0p80v_25C $io_db_file_ff_0p88v_m40C]  -lefs $io_lef_file -technology $cln65lp_tech_file io_lib

save_fusion_lib io_lib
close_fusion_lib io_lib


exit