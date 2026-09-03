# System Paths, please edit for your system
set process_node 130

set sky130_open_dir    /opt/pdk/sky130A
set sky130_digital_dir ${sky130_open_dir}/libs.ref/sky130_fd_sc_hd

set io_dir      ${sky130_open_dir}/libs.ref/sky130_fd_io
set sram_dir    /opt/pdk/sram_macros
set sc_dir      ${sky130_digital_dir}

set io_lib_dir ${io_dir}/lib
set sc_lib_dir ${sc_dir}/lib
set sram_8k_lib_dir  ${sram_dir}/sky130_sram_8kbyte_1rw_32x2048_8

set lib_search_path_list "$io_lib_dir $sc_lib_dir $sram_8k_lib_dir"

set BASE_LIB sky130_fd_sc_hd__ss_100C_1v60.lib
set SRAM_LIB sky130_sram_8kbyte_1rw_32x2048_8_SS_1p8V_25C.lib
set IO_PAD_DRIVER [list \
    sky130_ef_io__gpiov2_pad_wrapped_ss_ss_100C_1v60_3v00.lib \
    sky130_ef_io__vccd_lvc_clamped3_pad_ss_100C_1v60_3v00_3v00.lib \
    sky130_ef_io__vccd_lvc_clamped_pad_ss_100C_1v60_3v00_3v00.lib \
    sky130_ef_io__vdda_hvc_clamped_pad_ss_100C_1v60_3v00_3v00.lib \
    sky130_ef_io__vddio_hvc_clamped_pad_ss_100C_1v60_3v00_3v00.lib \
    sky130_ef_io__vssa_hvc_clamped_pad_ss_100C_1v60_3v00_3v00.lib \
    sky130_ef_io__vssd_lvc_clamped3_pad_ss_100C_1v60_3v00.lib \
    sky130_ef_io__vssd_lvc_clamped_pad_ss_100C_1v60_3v00.lib \
    sky130_ef_io__vssio_hvc_clamped_pad_ss_100C_1v60_3v00_3v00.lib \
]
# TODO: the analog block libs

set syn_lib_list [list $BASE_LIB $SRAM_LIB {*}$IO_PAD_DRIVER]

set block_name nanosoc_chip_pads

set LOG_DIR ../logs
set REPORT_DIR ../reports
set OUT_DIR ../outputs

set hdl_file_list $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
# TODO we might need to slightly modify this
set top_level_hdl ../../nanosoc_chip_pads/nanosoc_chip_pads.v

set constraints_file ../inputs/constraints.sdc

set DFT 0

set power_nets {VDD VDDIO}
set ground_nets {VSS VSSIO}


# Set library paths 
# !! EDIT THIS TO YOUR PATHS IN YOUR ENVIRONMENT
# NOTE!! I had to uncomment out the li1 layer for this version.
# set TECH_LEF            ${sky130_cadence_dir}/sky130_scl_9T_0.1.2/sky130_scl_9T_tech/lef/sky130_scl_9T.tlef

# set BASE_LEF            ${sky130_cadence_dir}/sky130_scl_9T_0.1.2/sky130_scl_9T/lef/sky130_scl_9T.lef
# set PHYS_CELL_LEF       ${sky130_cadence_dir}/sky130_scl_9T_0.1.2/sky130_scl_9T_tech/lef/sky130_scl_9T_phyCells.lef
set TECH_LEF            ${sky130_digital_dir}/techlef/sky130_fd_sc_hd__nom.tlef
set BASE_LEF            ${sky130_digital_dir}/lef/sky130_fd_sc_hd.lef
# for the open source one physical cells (e.g. filler) are included in BASE_LEF

set IO_PAD_DRIVER_LEF   ${sky130_open_dir}/libs.ref/sky130_fd_io/lef/sky130_ef_io.lef
set SRAM_LEF            ${sram_dir}/sky130_sram_8kbyte_1rw_32x2048_8/sky130_sram_8kbyte_1rw_32x2048_8.lef

#set lef_file_list [list ${TECH_LEF} ${PHYS_CELL_LEF} ${BASE_LEF} ${IO_PAD_DRIVER_LEF} ${SRAM_LEF}]
set lef_file_list [list ${TECH_LEF} ${BASE_LEF} ${IO_PAD_DRIVER_LEF} ${SRAM_LEF}]

# TODO: the analog blocks lefs

