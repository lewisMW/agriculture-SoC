//-----------------------------------------------------------------------------
// SoCLabs SLCore-M0 Reset Control - Cortex-M0 Reset Control
// - Added additional reset synchroniser to allow for synchronisation of both 
//   Core and System versions of HRESETn (system works when CPU is powered down)
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2009-03-21 16:43:18 +0000 (Sat, 21 Mar 2009) $
//
//      Revision            : $Revision: 104871 $
//
//      Release Information : Cortex-M0-AT510-r0p0-00rel0
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// CORTEX-M0 EXAMPLE RESET CONTROLLER
// This module is designed as an example reset controller for the Cortex-M0 
// // processor It takes a global reset that can be asynchronously asserted 
// and generates from it synchronously asserted and deasserted resets based 
// on synchronous reset requests
// This module is intended to interface to the example PMU provided (cortexm0_pmu.v)
// You can modify this module to suit your requirements
//-----------------------------------------------------------------------------

module slcorem0_rstctrl
  (/*AUTOARG*/
  // Outputs
  SYS_PORESETn, SYS_HRESETn, CORE_HRESETn, CORE_DBGRESETn, SYS_HRESETREQ, 
  // Inputs
  SYS_GLOBALRESETn, SYS_FCLK, CORE_HCLK, CORE_DCLK, SYS_HCLK, SYS_SYSRESETREQ, 
  CORE_PMUHRESETREQ, CORE_PMUDBGRESETREQ, SYS_RSTBYPASS, SYS_SE
  );

  input  SYS_GLOBALRESETn;   // Global asynchronous reset
  input  SYS_FCLK;           // System Free running clock
  input  SYS_HCLK;           // AHB clock (connect to HCLK of non-cortex m0 devices)
  input  CORE_HCLK;          // AHB clock (connect to HCLK of CORTEXM0INTEGRATION)
  input  CORE_DCLK;          // Debug clock (connect to DCLK of CORTEXM0INTEGRATION)
  input  SYS_SYSRESETREQ;    // Synchronous (to HCLK) request for HRESETn from system
  input  CORE_PMUHRESETREQ;  // Synchronous (to CORE_HCLK) request for HRESETn from PMU
  input  CORE_PMUDBGRESETREQ; // Synchronous (to CORE_DCLK) request for DBGRESETn from PMU
  input  SYS_RSTBYPASS;      // Reset synchroniser bypass (for DFT)
  input  SYS_SE;             // Scan Enable (for DFT)

  output SYS_HRESETREQ;      // Synchronous (to FCLK) indication of HRESET request
  output SYS_PORESETn;       // Connect to PORESETn of CORTEXM0INTEGRATION
  output SYS_HRESETn;        // Connect to HRESETn of AHB System
  output CORE_HRESETn;       // Connect to HRESETn of CORTEXM0INTEGRATION
  output CORE_DBGRESETn;     // Connect to DBGRESETn of CORTEXM0INTEGRATION

  // Sample synchronous requests to assert HRESETn
  // Sources:
  // 1 - System (SYSRESETREQ)
  // 2 - PMU    (PMUHRESETREQ)
  wire   h_reset_req_in = SYS_SYSRESETREQ | CORE_PMUHRESETREQ;
  
  cm0_rst_send_set u_hreset_req
    (.RSTn      (SYS_PORESETn),
     .CLK       (SYS_FCLK),
     .RSTREQIN  (h_reset_req_in),
     .RSTREQOUT (SYS_HRESETREQ)
     );

  // Sample synchronous requests to assert DBGRESETn
  wire   dbg_reset_req_sync;
  
  cm0_rst_send_set u_dbgreset_req
    (.RSTn      (SYS_PORESETn),
     .CLK       (SYS_FCLK),
     .RSTREQIN  (CORE_PMUDBGRESETREQ),
     .RSTREQOUT (dbg_reset_req_sync)
     );
  
  // --------------------
  // Reset synchronisers
  // --------------------
  
  cm0_rst_sync u_sys_poresetn_sync
    (.RSTINn    (SYS_GLOBALRESETn),
     .RSTREQ    (1'b0),
     .CLK       (SYS_FCLK),
     .SE        (SYS_SE),
     .RSTBYPASS (SYS_RSTBYPASS),
     .RSTOUTn   (SYS_PORESETn)
     );

  cm0_rst_sync u_sys_hresetn_sync
    (.RSTINn    (SYS_GLOBALRESETn),
     .RSTREQ    (SYS_HRESETREQ),
     .CLK       (SYS_HCLK),
     .SE        (SYS_SE),
     .RSTBYPASS (SYS_RSTBYPASS),
     .RSTOUTn   (SYS_HRESETn)
     );
    
  cm0_rst_sync u_core_hresetn_sync
    (.RSTINn    (SYS_GLOBALRESETn),
     .RSTREQ    (SYS_HRESETREQ),
     .CLK       (CORE_HCLK),
     .SE        (SYS_SE),
     .RSTBYPASS (SYS_RSTBYPASS),
     .RSTOUTn   (CORE_HRESETn)
     );

  cm0_rst_sync u_core_dbgresetn_sync
    (.RSTINn    (SYS_GLOBALRESETn),
     .RSTREQ    (dbg_reset_req_sync),
     .CLK       (CORE_DCLK),
     .SE        (SYS_SE),
     .RSTBYPASS (SYS_RSTBYPASS),
     .RSTOUTn   (CORE_DBGRESETn)
     );
  
endmodule // cortexm0_rst_ctl



