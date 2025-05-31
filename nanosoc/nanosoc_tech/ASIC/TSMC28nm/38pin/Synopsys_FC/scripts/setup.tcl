## Paths Please Edit for your system
set cln28ht_tech_path           /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0
set standard_cell_base_path     /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_base_svt_c30/r0p0
set pmk_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_pmk_svt_c30/r0p0
set ret_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc12mcpp140z_rklo_lvt_svt_c30_c35/r1p0
set hpc_base_path               /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc7mcpp140z_hpk_svt_c30/r0p0
#set Synopsys_PLL_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/PLL/synopsys/dwc_pll3ghz_tsmc28hpcp/1.10a/macro
#set Synopsys_TS_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/1.01b
#set Synopsys_PD_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/dwc_sensors_pd_tsmc28hpcp_1.00a/synopsys/dwc_sensors_pd_tsmc28hpcp/1.00a
#set Synopsys_VM_dir /home/dwn1c21/SoC-Labs/Synopsys_ip/IP/Southampton_28hpcp_pd_vm_ts_vmps_pvtc/dwc_sensors_vm_shrink_tsmc28hpcp_1.00a/synopsys/dwc_sensors_vm_shrink_tsmc28hpcp/1.00a

set TLU_dir /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0/synopsys_tluplus/1p8m_5x2z_utalrdl



set REPORT_DIR ../reports
set LOG_DIR ../logs
set OUT_DIR ../outputs


proc report_intermediate_step {name REPORT_DIR} {
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}_interclock.rep {report_global_timing -delay_type min -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}.rep {report_global_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}_interclock.rep {report_global_timing -delay_type max -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}.rep {report_global_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_max.rep {report_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_min.rep {report_timing -delay_type min}
}

proc report_end_step {name REPORT_DIR} {
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}_interclock.rep {report_global_timing -delay_type min -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_min_${name}.rep {report_global_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}_interclock.rep {report_global_timing -delay_type max -include inter_clock}
    redirect -tee -file $REPORT_DIR/timing_global_max_${name}.rep {report_global_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_max.rep {report_timing -delay_type max}
    redirect -tee -file $REPORT_DIR/timing_${name}_min.rep {report_timing -delay_type min}
    redirect -tee -file $REPORT_DIR/area_${name}.rep {report_area}
    redirect -tee -file $REPORT_DIR/qor_${name}.rep {report_qor}

    current_scenario typical_scenario
    redirect -tee -file $REPORT_DIR/power_${name}_hierarchy.rep {report_power -scenarios typical_scenario -hierarchy}
    redirect -tee -file $REPORT_DIR/power_${name}.rep {report_power -scenarios typical_scenario}

}