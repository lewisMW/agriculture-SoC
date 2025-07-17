
set top_module snps_PLL_integration_layer

set search_path [list . $search_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_base_svt_c35/r2p0/db /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/PLL/synopsys/dwc_pll3ghz_tsmc28hpcp/1.10a/macro/timing/lib]

set target_library "dwc_z19606ts_ns_ssg0p81v125c_rcworst.db sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db"
set link_library "dwc_z19606ts_ns_ssg0p81v125c_rcworst.db sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db"

analyze -f verilog $env(ARM_IP_LIBRARY_PATH)/latest/Corstone-101/logical/cmsdk_apb4_eg_slave/verilog/cmsdk_apb4_eg_slave_interface.v
analyze -f verilog $env(SOCLABS_SNPS_28NM_IP_DIR)/IP_wrappers/PLL_integration_layer.v
elaborate $top_module
current_design $top_module

link

read_sdc ./pll_constraints.sdc

compile_ultra

write -format verilog -output $env(SOCLABS_SNPS_28NM_IP_DIR)/imp/PLL/PLL_integration_layer_gates.v
write_sdf -version 2.1 $env(SOCLABS_SNPS_28NM_IP_DIR)/imp/PLL/PLL_integration_layer_gates.sdf

exit
