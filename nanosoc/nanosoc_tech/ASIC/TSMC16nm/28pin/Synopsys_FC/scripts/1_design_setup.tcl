# Import verilog and setup libraries

set_host_options -max_cores 8 -num_processes 8

# Set paths !!! Please edit for your system !!!
set cln16fcll_tech_path /research/AAA/phys_ip_library/arm/tsmc/cln16fcll001/arm_tech/r3p0

set cln16fcll_tech_file $cln16fcll_tech_path/ndm/9m_2xa1xd3xe2z_utrdl/sc9mcpp96c_tech.tf
set TLU_dir             $cln16fcll_tech_path/synopsys_tluplus/9m_2xa1xd3xe2z_utrdl

set TLU_cbest $TLU_dir/cbest.tluplus
set TLU_cworst $TLU_dir/cworst.tluplus
set TLU_rcbest $TLU_dir/rcbest.tluplus
set TLU_rcworst $TLU_dir/rcworst.tluplus
set TLU_map $TLU_dir/tluplus.map

#Create the design library 
create_lib nanosoc_chip_pads.dlib \
    -technology $cln16fcll_tech_file \
    -ref_libs {../libs/cln16fcll ../libs/arm_io_lib ../libs/SRAM_32K ../libs/ROM_VIA}


# Read in the verilog for
source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl
analyze -format verilog $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/nanosoc_chip_pads/tsmc16fcll/nanosoc_chip_pads_28pin.v

elaborate nanosoc_chip_pads
set_top_module nanosoc_chip_pads

read_parasitic_tech -name cbest   -tlup $TLU_cbest -layermap $TLU_map 
read_parasitic_tech -name cworst  -tlup $TLU_cworst -layermap $TLU_map 
read_parasitic_tech -name rcbest  -tlup $TLU_rcbest -layermap $TLU_map 
read_parasitic_tech -name rcworst -tlup $TLU_rcworst -layermap $TLU_map 

save_lib nanosoc_chip_pads.dlib
