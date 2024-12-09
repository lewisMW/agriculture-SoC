set sc9mcpp240z_base_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_base_svt_c35/r2p0
set cln28ht_tech_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0

set TLU_dir /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0/synopsys_tluplus/1p8m_5x2z_utalrdl

set TLU_cbest $TLU_dir/cbest.tluplus
set TLU_cworst $TLU_dir/cworst.tluplus
set TLU_rcbest $TLU_dir/rcbest.tluplus
set TLU_rcworst $TLU_dir/rcworst.tluplus
set TLU_map $TLU_dir/tluplus.map

create_lib nanosoc_chip_pads.dlib \
    -technology $cln28ht_tech_path/milkyway/1p8m_5x2z_utalrdl/sc12mcpp140z_tech.tf \
    -ref_libs {./cln28ht/ ./cln28ht_pmk/ ./cln28ht_ret/ ./sram_16k/ ./rom_via/ ./io_lib/ ./pad_lib/}

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl
analyze -format verilog $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/nanosoc_chip_pads/tsmc28hpcp/nanosoc_chip_pads_38pin.v

elaborate nanosoc_chip_pads
set_top_module nanosoc_chip_pads

redirect -tee -file ./lib_cell_summary.log {report_lib -cell_summary cln28ht}
redirect -tee -file ./lib_cell_pmk_summary.log {report_lib -cell_summary cln28ht_pmk}
redirect -tee -file ./lib_cell_ret_summary.log {report_lib -cell_summary cln28ht_ret}

read_parasitic_tech -name cbest   -tlup $TLU_cbest -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name cworst  -tlup $TLU_cworst -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcbest  -tlup $TLU_rcbest -layermap $TLU_map -sanity_check advanced
read_parasitic_tech -name rcworst -tlup $TLU_rcworst -layermap $TLU_map -sanity_check advanced

save_lib nanosoc_chip_pads.dlib
