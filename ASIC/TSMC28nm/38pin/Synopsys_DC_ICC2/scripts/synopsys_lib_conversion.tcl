# SRAM files (using Arm compiler)
set sram_16k_path                       $env(SOCLABS_PROJECT_DIR)/memories/sram_16k
set sram_16k_lib_file_ss_0p81v_125c     $sram_16k_path/sram_16k_ssg_cworstt_0p81v_0p81v_125c.lib
set sram_16k_lib_file_tt_0p90v_25c      $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_25c.lib
set sram_16k_lib_file_ff_0p99v_m40c     $sram_16k_path/sram_16k_ffg_cbestt_0p99v_0p99v_m40c.lib
set sram_16k_db_file_ss_0p81v_125c      $sram_16k_path/sram_16k_ssg_cworstt_0p81v_0p81v_125c.db
set sram_16k_db_file_tt_0p90v_25c       $sram_16k_path/sram_16k_tt_ctypical_0p90v_0p90v_25c.db
set sram_16k_db_file_ff_0p99v_m40c      $sram_16k_path/sram_16k_ffg_cbestt_0p99v_0p99v_m40c.db

# ROM Files (using arm Compiler)
set rom_path                        $env(SOCLABS_PROJECT_DIR)/memories/bootrom
set rom_via_lib_file_ss_0p81v_125c  $rom_path/rom_via_ssg_cworstt_0p81v_0p81v_125c.lib
set rom_via_lib_file_tt_0p90v_25c   $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.lib
set rom_via_lib_file_ff_0p99v_m40c  $rom_path/rom_via_ffg_cbestt_0p99v_0p99v_m40c.lib
set rom_via_db_file_ss_0p81v_125c   $rom_path/rom_via_ssg_cworstt_0p81v_0p81v_125c.db
set rom_via_db_file_tt_0p90v_25c    $rom_path/rom_via_tt_ctypical_0p90v_0p90v_25c.db
set rom_via_db_file_ff_0p99v_m40c   $rom_path/rom_via_ffg_cbestt_0p99v_0p99v_m40c.db

# 16K SRAM
read_lib $sram_16k_lib_file_ss_0p81v_125c
write_lib -output ./sram_16k_db_file_ss_0p81v_125c.db -format db SRAM_16K_ssg_cworstt_0p81v_0p81v_125c
close_lib -all

read_lib $sram_16k_lib_file_tt_0p90v_25c 
write_lib -output $sram_16k_db_file_tt_0p90v_25c -format db SRAM_16K_tt_ctypical_0p90v_0p90v_25c
close_lib -all

read_lib $sram_16k_lib_file_ff_0p99v_m40c 
write_lib -output $sram_16k_db_file_ff_0p99v_m40c -format db SRAM_16K_ffg_cbestt_0p99v_0p99v_m40c
close_lib -all

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

exit