//-----------------------------------------------------------------------------
// SLCore M0 Arm Cortex M0 Lint Design Info File
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : HAL Design Info File for Blackboxing Arm IP for Cortex M0
//-----------------------------------------------------------------------------

bb_list
{
    // Exclude Cortex M0 Debug Reset Synchroniser as Arm IP
    designunit = cm0_dbg_reset_sync;
    file = $ARM_CORTEX_M0_DIR/models/cells/cm0_dbg_reset_sync.v;
    
    // Exclude Cortex M0 as Arm IP
    designunit = CORTEXM0;
    file = $ARM_CORTEX_M0_DIR/cortexm0/verilog/CORTEXM0.v;
    
    // Exclude Cortex M0 Debug Access Port as Arm IP
    designunit = CORTEXM0DAP;
    file = $ARM_CORTEX_M0_DIR/cortexm0_dap/verilog/CORTEXM0DAP.v;
    
    // Exclude Cortex M0 Wake on Interrupt Controller as Arm IP
    designunit = cortexm0_wic;
    file = $ARM_CORTEX_M0_DIR/cortexm0_integration/verilog/cortexm0_wic.v;
    
    // Exclude Cortex M0 Reset Send Set as Arm IP
    designunit = cm0_rst_send_set;
    file = $ARM_CORTEX_M0_DIR/models/cells/cm0_rst_send_set.v;
    
    // Exclude Cortex M0 Reset Synchroniser as Arm IP
    designunit = cm0_rst_sync;
    file = $ARM_CORTEX_M0_DIR/models/cells/cm0_rst_sync.v;
    
    // Exclude Cortex M0 PMU as Arm IP
    designunit = cortexm0_pmu;
    file = $ARM_CORTEX_M0_DIR/cortexm0_integration/verilog/cortexm0_pmu.v;

}