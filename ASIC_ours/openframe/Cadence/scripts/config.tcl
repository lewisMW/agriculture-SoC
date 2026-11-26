# Configuration for nanosoc in the ChipFoundry OpenFrame wrapper (experiment).
# Derived from ../../../Cadence/scripts/config.tcl without the sky130 pad ring:
# the padframe belongs to the frame, the user area is 3166.63 x 4766.63 um.
set process_node 130

set sky130_open_dir    /opt/pdk/sky130A
set sky130_digital_dir ${sky130_open_dir}/libs.ref/sky130_fd_sc_hd
set sc_dir             ${sky130_digital_dir}

set sc_lib_dir      ${sc_dir}/lib
set lib_search_path_list "$sc_lib_dir"

set BASE_LIB sky130_fd_sc_hd__tt_025C_1v80.lib

# Memories: DFFRAM blocks (standard cells only; OpenRAM macros are not accepted for
# fabrication). OF_MEM (environment) picks the set; it has to be the same for
# synthesis and every place-and-route stage.
#   prebuilt        ChipFoundry's pre-hardened OL-DFFRAM blocks (../../fetch_dffram.sh
#                   puts them in ../../ip/OL-DFFRAM; DFFRAM_ROOT overrides):
#                   4 kbyte + 1 kbyte + 512 byte + 512 byte = 6 kbyte. Default.
#   compiler_latch  blocks built here with the DFFRAM compiler, latch storage
#   compiler_dff    the same with flip-flop storage
#                   (../../ip/DFFRAM_latch, ../../ip/DFFRAM_dff: the compiler's
#                   products directory; DFFRAM_COMPILER_ROOT overrides):
#                   4 + 2 + 2 + 2 kbyte = 10 kbyte, behind the holding bridge
#                   ../../rtl/sl_ahb_sram_hold.v.
# of_mem_aw is the address width in bytes of imem, dmem, expram_l, expram_h; it is
# written to ../outputs/of_mem_config.vh for openframe_project_wrapper.v.
set of_mem prebuilt
if {[info exists ::env(OF_MEM)]} { set of_mem $::env(OF_MEM) }
switch -- $of_mem {
    prebuilt {
        set dffram_dir [file normalize ../../ip/OL-DFFRAM]
        if {[info exists ::env(DFFRAM_ROOT)]} { set dffram_dir $::env(DFFRAM_ROOT) }
        set dffram_macros {DFFRAM512x32 DFFRAM256x32 DFFRAM128x32}
        set of_mem_aw {12 10 9 9}
        set _probe $dffram_dir/layout/lef/DFFRAM512x32.lef
    }
    compiler_latch - compiler_dff {
        set dffram_dir [file normalize ../../ip/DFFRAM_[string range $of_mem 9 end]]
        if {[info exists ::env(DFFRAM_COMPILER_ROOT)]} { set dffram_dir $::env(DFFRAM_COMPILER_ROOT) }
        set dffram_macros {RAM1024 RAM512}
        set of_mem_aw {12 11 11 11}
        set _probe $dffram_dir/RAM512/lef/RAM512.lef
    }
    default { error "config.tcl: OF_MEM is '$of_mem'; use prebuilt, compiler_latch or compiler_dff" }
}
if {![file exists $_probe]} {
    error "config.tcl: no DFFRAM macros for OF_MEM=$of_mem in $dffram_dir (see ASIC_ours/openframe/README.md, \"Memories\")"
}
# LEF, GDS and one timing library per macro and corner (slow, typical, fast).
# Of the pre-hardened blocks only the 512-word one has libraries named by corner;
# the two smaller ones come from an older run and are called Slowest/Typical/
# Fastest (all three state 1.60 V, 100 C, and their clock-to-output delays hardly
# differ: their hold numbers are not to be relied on).
proc dffram_lef {macro} {
    global dffram_dir of_mem
    if {$of_mem eq "prebuilt"} { return $dffram_dir/layout/lef/$macro.lef }
    return $dffram_dir/$macro/lef/$macro.lef
}
proc dffram_gds {macro} {
    global dffram_dir of_mem
    if {$of_mem eq "prebuilt"} { return $dffram_dir/layout/gds/$macro.gds }
    return $dffram_dir/$macro/gds/$macro.gds
}
proc dffram_lib {macro corner} {
    global dffram_dir of_mem
    set d [dict get {slow max_ss_100C_1v60 typical nom_tt_025C_1v80 fast min_ff_n40C_1v95} $corner]
    if {$of_mem ne "prebuilt"} { return $dffram_dir/$macro/lib/$d/${macro}__$d.lib }
    if {$macro eq "DFFRAM512x32"} { return $dffram_dir/timing/lib/$d/${macro}__$d.lib }
    lassign [dict get {slow {max Slowest} typical {nom Typical} fast {min Fastest}} $corner] d n
    return $dffram_dir/timing/lib/$d/$macro.$n.lib
}
set DFFRAM_LIBS {}; set DFFRAM_LIBS_SLOW {}; set DFFRAM_LIBS_FAST {}
foreach _m $dffram_macros {
    lappend DFFRAM_LIBS      [dffram_lib $_m typical]
    lappend DFFRAM_LIBS_SLOW [dffram_lib $_m slow]
    lappend DFFRAM_LIBS_FAST [dffram_lib $_m fast]
}
# the region sizes for the RTL (written only when they change)
set _vh "// written by config.tcl for OF_MEM=$of_mem: address width in bytes of each memory region\n"
foreach _n {OF_IMEM_AW OF_DMEM_AW OF_EXPRAM_L_AW OF_EXPRAM_H_AW} _v $of_mem_aw { append _vh "`define $_n $_v\n" }
file mkdir ../outputs
set _old ""
if {[file exists ../outputs/of_mem_config.vh]} { set _f [open ../outputs/of_mem_config.vh r]; set _old [read $_f]; close $_f }
if {$_old ne $_vh} { set _f [open ../outputs/of_mem_config.vh w]; puts -nonewline $_f $_vh; close $_f }

set sar_afe_dir [file normalize ../../../macros/sar_afe]
lappend lib_search_path_list $sar_afe_dir [file normalize ../inputs]
set SAR_AFE_LIB sar_afe__tt_025C_1v80.lib

set syn_lib_list [list $BASE_LIB {*}$DFFRAM_LIBS $SAR_AFE_LIB]

set block_name openframe_project_wrapper
set LOG_DIR ../logs
set REPORT_DIR ../reports
set OUT_DIR ../outputs

set hdl_file_list $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
set custom_hdl_file_list ../inputs/custom_hdl_file_list.tcl
set top_level_hdl ../../rtl/openframe_project_wrapper.v
set constraints_file ../inputs/constraints.sdc
set DFT 1

# the frame's supplies as named in the wrapper template. The ADC reference comes in
# on pad 15: that port's own net, analog_io[15], is made a power net here and the
# macro's vref pin is put on it in power_plan.tcl (the UPF's ADC_VREF net stays
# empty in the layout; a port cannot be moved onto another supply net in a way that
# survives write_db/read_db, but a power pin can be moved onto the port's net).
set vref_net    {analog_io[15]}
set power_nets  [list vccd1 vdda1 ADC_VREF $vref_net]
set ground_nets {vssd1 vssa1}

set BASE_LEF      [list ${sky130_digital_dir}/techlef/sky130_fd_sc_hd__nom.tlef ${sky130_digital_dir}/lef/sky130_fd_sc_hd.lef]
set DFFRAM_LEF {}
foreach _m $dffram_macros { lappend DFFRAM_LEF [dffram_lef $_m] }
# the frame's two power-connection blocks (met3 obstructions in LEF; their GDS
# joins the frame's vccd1/vssd1 pins to the core ring at fixed positions)
set OPENFRAME_LEF [list [file normalize ../inputs/vccd1_connection.lef] [file normalize ../inputs/vssd1_connection.lef]]
set lef_file_list [list {*}${BASE_LEF} {*}${DFFRAM_LEF} {*}${OPENFRAME_LEF} $sar_afe_dir/sar_afe.lef]

set bottom_routing_layer 2   ;# met1
set top_routing_layer    5   ;# met4; met5 is for the power grid only

# OpenFrame wrapper geometry, from chipfoundry/openframe_user_project
# def/openframe_project_wrapper.def and openlane/openframe_project_wrapper/config.json
set OF_DIE  {0 0 3166.63 4766.63}
set OF_CORE {40.02 40.8 3126.62 4724.64}   ;# the template's rows: 6710 unithd sites x 1722 rows

# the frame's 86 unused analog inout pads are undriven by design; let the
# low-power rule check report that without stopping synthesis (1_synthesis.tcl)
set lp_check_nonfatal 1
