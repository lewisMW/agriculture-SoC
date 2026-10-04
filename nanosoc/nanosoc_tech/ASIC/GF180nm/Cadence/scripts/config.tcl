# System Paths, please edit for your system
set gf180mcu_pdk_dir /home/dwn1c21/SoC-Labs/phys_ip/gf180mcuC


set io_lib_dir ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lib
set sc_lib_dir ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_sc_mcu9t5v0/lib
set sram_lib_dir ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_ip_sram/lib

set lib_search_path_list "$io_lib_dir $sc_lib_dir $sram_lib_dir"

set BASE_LIB gf180mcu_fd_sc_mcu9t5v0__ss_125C_3v00.lib
set SRAM_LIB gf180mcu_fd_ip_sram__sram512x8m8wm1__ss_125C_3v00.lib
set IO_PAD_DRIVER gf180mcu_fd_io__ss_125C_2v97.lib

set syn_lib_list [list $BASE_LIB $SRAM_LIB $IO_PAD_DRIVER]

set block_name nanosoc_chip_pads

set LOG_DIR ../logs
set REPORT_DIR ../reports
set OUT_DIR ../outputs

set hdl_file_list $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
set top_level_hdl $::env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/nanosoc_chip_pads/gf180/nanosoc_chip_pads.v

set constraints_file ../inputs/constraints.sdc

set DFT 0

set power_nets {VDD VDDIO}
set ground_nets {VSS VSSIO}


# Set library paths 
# !! EDIT THIS TO YOUR PATHS IN YOUR ENVIRONMENT
set TECH_LEF ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_sc_mcu9t5v0/techlef/gf180mcu_fd_sc_mcu9t5v0__nom.tlef

set BASE_LEF ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_sc_mcu9t5v0/lef/gf180mcu_fd_sc_mcu9t5v0.lef
set IO_PAD_DRIVER_LEF [list \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_ef_io__bi_t.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__asig_5p0.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__bi_24t.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__bi_t.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__brk2.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__brk5.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__cor.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__dvdd.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__dvss.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__fill1.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__fill5.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__fill10.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__fillnc.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__in_c.lef \
    ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_io/lef/gf180mcu_fd_io__in_s.lef ]
set SRAM_LEF ${gf180mcu_pdk_dir}/libs.ref/gf180mcu_fd_ip_sram/lef/gf180mcu_fd_ip_sram__sram512x8m8wm1.lef

set lef_file_list [list ${TECH_LEF} ${BASE_LEF} ${IO_PAD_DRIVER_LEF} ${SRAM_LEF}]


