# Extra RTL for the OpenFrame wrapper, read before the top level (1_synthesis.tcl)
read_hdl ../../rtl/CF_gpio_config.v
# cells with known DRC problems are not to be used (the libraries are loaded by now)
source ../scripts/dont_use.tcl

# The memories (config.tcl, OF_MEM). Read after the generated file list, so these
# definitions replace the ones it read.
#   prebuilt:    sl_sram with ChipFoundry's DFFRAM blocks, in place of the OpenRAM
#                one (asic_lib_tech/sram/SKY130/verilog/sl_sram.v)
#   compiler_*:  sl_ahb_sram itself, a bridge that holds the address for the
#                DFFRAM compiler's blocks (asic_lib_tech/sram/verilog/sl_ahb_sram.v
#                and the bridge under it are then unused)
if {$of_mem eq "prebuilt"} {
    read_hdl ../../rtl/sl_sram_dffram.v
} else {
    read_hdl ../../rtl/sl_ahb_sram_hold.v
}
# The boot ROM: the OpenFrame one (../../sw/bootrom; run_flow.sh builds it into
# ../outputs/bootrom) in place of the SoC Labs boot loader the file list read.
set _rom [file normalize ../outputs/bootrom/verilog/bootrom.sv]
if {![file exists $_rom]} {
    error "custom_hdl_file_list.tcl: no $_rom (run_flow.sh builds it from ASIC_ours/openframe/sw/bootrom)"
}
read_hdl -sv $_rom
# openframe_project_wrapper.v includes of_mem_config.vh, which config.tcl wrote
set_db init_hdl_search_path [concat [list [file normalize ../outputs]] [get_db init_hdl_search_path]]
