# System Paths, please edit for your system
set process_node 130

set sky130_open_dir    /opt/pdk/sky130A
set sky130_digital_dir ${sky130_open_dir}/libs.ref/sky130_fd_sc_hd

# contains both the fd_io and ef_io libs
set io_dir      ${sky130_open_dir}/libs.ref/sky130_fd_io 
set sram_dir    /opt/pdk/sram_macros
set sc_dir      ${sky130_digital_dir}

set io_lib_dir ${io_dir}/lib
set sc_lib_dir ${sc_dir}/lib
set level_shifter_dir ${sky130_open_dir}/libs.ref/sky130_fd_sc_hvl/lib
set sram_8k_lib_dir  ${sram_dir}/sky130_sram_8kbyte_1rw_32x2048_8

set lib_search_path_list "$io_lib_dir $sc_lib_dir $level_shifter_dir $sram_8k_lib_dir"

set BASE_LIB sky130_fd_sc_hd__tt_025C_1v80.lib
set LEVEL_SHIFTER_LIB sky130_fd_sc_hvl__tt_025C_3v30_lv1v80.lib
set SRAM_LIB sky130_sram_8kbyte_1rw_32x2048_8_SS_1p8V_25C.lib
# TODO find out about the ESD protection
# hvc:
# lvc:
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
    sky130_ef_io__analog_pad.lib \
    sky130_fd_io__top_xres4v2_ss_ss_100C_1v60_3v00.lib \
]
# sky130_ef_io__analog_pad.lib (above, ../inputs) is the two ADC input pads
# (uPAD_ADC_VINP/VINN): the PDK's sky130_ef_io__analog_stubs.lib cell with the
# voltage_map groups that file lacks, so their ring supply pins exist. It has a single
# corner and no timing arcs.
# sky130_fd_io__top_xres4v2 is the reset pad uPAD_NRST_I. Without its .lib Genus
# black-boxes it (CDFG-428), set_dont_touch on uPAD* then fails (SDC-204) and the
# unresolved-reference guard in 1_synthesis.tcl would stop the stage anyway.

# The ADC's analog front end, a hard macro (ASIC_ours/macros/sar_afe/README.md).
# Genus resolves the sar_afe instance in sar_adc.v from this .lib; sar_afe.v is a
# port list for simulation and LEC only and must never be read into Genus.
set sar_afe_dir [file normalize ../../macros/sar_afe]
lappend lib_search_path_list $sar_afe_dir [file normalize ../inputs]
set SAR_AFE_LIB sar_afe__tt_025C_1v80.lib

set syn_lib_list [list $BASE_LIB $LEVEL_SHIFTER_LIB $SRAM_LIB $SAR_AFE_LIB {*}$IO_PAD_DRIVER]

set block_name nanosoc_chip_pads

set LOG_DIR ../logs
set REPORT_DIR ../reports
set OUT_DIR ../outputs

set hdl_file_list $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
set top_level_hdl ../../nanosoc_chip_pads/nanosoc_chip_pads.v

set constraints_file ../inputs/constraints.sdc

set DFT 0

# VDDA: the analog supply (PD_ANALOG). The sar_afe macro's vdda and vref pins
# are on it, so it has to be a special (power) net from init_design on. VDDIO_Q,
# VSSA and VSSIO_Q are the pad ring's quiet IO and analog ground buses
# (power_plan.tcl puts the IO cells' pins on them, as nanosoc_chip_pads.upf does).
set power_nets {VDD VDDIO VDDA VDDIO_Q}
set ground_nets {VSS VSSIO VSSA VSSIO_Q}


# Set library paths 
# !! EDIT THIS TO YOUR PATHS IN YOUR ENVIRONMENT
# include both the library and tlef for those
set BASE_LEF            [list ${sky130_digital_dir}/techlef/sky130_fd_sc_hd__nom.tlef ${sky130_digital_dir}/lef/sky130_fd_sc_hd.lef]
# for the open source one physical cells (e.g. filler) are included in BASE_LEF
set LEVEL_SHIFTER_LEF   [list ${sky130_open_dir}/libs.ref/sky130_fd_sc_hvl/techlef/sky130_fd_sc_hvl__nom.tlef ${sky130_open_dir}/libs.ref/sky130_fd_sc_hvl/lef/sky130_fd_sc_hvl.lef ]

# ../inputs/sky130_ef_io__analog_pad.lef first: the ADC input pad with its P_CORE pin as
# drawn in the GDS (the PDK LEF's is 3 um wider on each side, and routes landed off the
# metal). Innovus keeps the first definition of a MACRO, so it must precede the PDK LEF.
set IO_PAD_DRIVER_LEF   [list \
  [file normalize ../inputs/sky130_ef_io__analog_pad.lef] \
  ${sky130_open_dir}/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef \
  ${sky130_open_dir}/libs.ref/sky130_fd_io/lef/sky130_ef_io.lef \
]
set SRAM_LEF            ${sram_dir}/sky130_sram_8kbyte_1rw_32x2048_8/sky130_sram_8kbyte_1rw_32x2048_8.lef

#set lef_file_list [list ${TECH_LEF} ${PHYS_CELL_LEF} ${BASE_LEF} ${IO_PAD_DRIVER_LEF} ${SRAM_LEF}]
set lef_file_list [list {*}${BASE_LEF} {*}${LEVEL_SHIFTER_LEF} {*}${IO_PAD_DRIVER_LEF} ${SRAM_LEF}]

# don't use li1 for routing
set bottom_routing_layer 2   ;# met1
# alternatively, use M4 as rounting as well (otherwise congested)
set top_routing_layer    5   ;#met4

# The ADC's analog front-end macro, after the tech LEF (README: "Hooking it into
# ASIC_ours/Cadence"). sar_afe is the bottom-left variant: analog inputs on its
# left edge, digital pins on its right edge.
lappend lef_file_list $sar_afe_dir/sar_afe.lef

