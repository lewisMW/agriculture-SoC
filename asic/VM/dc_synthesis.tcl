set top_module synopsys_VM_sensor_integration

set search_path [list . $search_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_base_svt_c35/r2p0/db /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/dwc_sensors_vm_shrink_tsmc28hpcp_1.00a/synopsys/dwc_sensors_vm_shrink_tsmc28hpcp/1.00a/db]

set target_library "mr74140_wc_vmin_125c.db sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db"
set link_library "mr74140_wc_vmin_125c.db sc12mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db"

analyze -f verilog $env(SOCLABS_SNPS_28NM_IP_DIR)/IP_wrappers/synopsys_VM_sensor_integration.v
analyze -f verilog $env(ARM_IP_LIBRARY_PATH)/latest/Corstone-101/logical/cmsdk_apb4_eg_slave/verilog/cmsdk_apb4_eg_slave_interface.v
elaborate $top_module
current_design $top_module

link

read_sdc ./vm_constraints.sdc 

compile_ultra

write -format verilog -output $env(SOCLABS_SNPS_28NM_IP_DIR)/imp/VM/VM_integration_layer_gates.v
write_sdf -version 2.1 $env(SOCLABS_SNPS_28NM_IP_DIR)/imp/VM/VM_integration_layer_gates.sdf

exit