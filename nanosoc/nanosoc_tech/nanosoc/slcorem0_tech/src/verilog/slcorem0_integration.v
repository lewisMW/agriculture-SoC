//-----------------------------------------------------------------------------
// SLCore Core Integration
// - Modified Version of CORTEXM0INTEGRATION
// - Exposes ROM Table Wire
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2009 ARM Limited.
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

module slcorem0_integration
  #(
    // ----------------------------------------------------------------------
    // CORTEX-M0 INTEGRATION PER-INSTANCE PARAMETERIZATION:
    // ----------------------------------------------------------------------
    parameter ACG      =  1,      // Architectural clock gating:
                                  //   0 = absent
                                  //   1 = present
    // ----------------------------------------------------------------------
    parameter BE       =  0,      // Data transfer endianess:
                                  //   0 = little-endian
                                  //   1 = byte-invariant big-endian
    // ----------------------------------------------------------------------
    parameter BKPT     =  4,      // Number of breakpoint comparators:
                                  //   0 = none
                                  //   1 = one
                                  //   2 = two
                                  //   3 = three
                                  //   4 = four
    // ----------------------------------------------------------------------
    parameter DBG      =  1,      // Debug configuration:
                                  //   0 = no debug support
                                  //   1 = implement debug support
    // ----------------------------------------------------------------------
    parameter JTAGnSW  = 0,       // Debug port interface
                                  //   0 = SerialWire interface
                                  //   1 = JTAG interface
    // ----------------------------------------------------------------------
    parameter NUMIRQ   = 32,      // Functional IRQ lines:
                                  //   0 = none
                                  //   1 = IRQ[0]
                                  //   2 = IRQ[1:0]
                                  //   . . ...
                                  //  32 = IRQ[31:0]
    // ----------------------------------------------------------------------
    parameter RAR      =  0,      // Reset-all-register option
                                  //   0 = standard, architectural reset
                                  //   1 = extended, all register reset
    // ----------------------------------------------------------------------
    parameter SMUL     =  0,      // Multiplier configuration:
                                  //   0 = MULS is single cycle (fast)
                                  //   1 = MULS takes 32-cycles (small)
    // ----------------------------------------------------------------------
    parameter SYST     =  1,      // SysTick option:
                                  //   0 = SysTick not present
                                  //   1 = SysTick present
    // ----------------------------------------------------------------------
    parameter WIC      =  1,      // Wake-up interrupt controller support:
                                  //   0 = no support
                                  //   1 = WIC deep-sleep supported
    // ----------------------------------------------------------------------
    parameter WICLINES = 34,      // Supported WIC lines:
                                  //   2 = NMI and RXEV
                                  //   3 = NMI, RXEV and IRQ[0]
                                  //   4 = NMI, RXEV and IRQ[1:0]
                                  //   . . ...
                                  //  34 = NMI, RXEV and IRQ[31:0]
    // ----------------------------------------------------------------------
    parameter WPT      =  2,      // Number of DWT comparators
                                  //   0 = none
                                  //   1 = one
                                  //   2 = two
    // ----------------------------------------------------------------------
    parameter [31:0] ROMTABLE_BASE = 32'hE00FF000) // ROM Table Base Address
                                // - Defaultly points to Core ROMTABLE
    // ----------------------------------------------------------------------

    (// CLOCK AND RESETS
     input  wire        FCLK,
     input  wire        SCLK,
     input  wire        HCLK,
     input  wire        DCLK,
     input  wire        PORESETn,
     input  wire        DBGRESETn,
     input  wire        HRESETn,
     input  wire        SWCLKTCK,
     input  wire        nTRST,

     // AHB-LITE MASTER PORT
     output wire [31:0] HADDR,
     output wire [ 2:0] HBURST,
     output wire        HMASTLOCK,
     output wire [ 3:0] HPROT,
     output wire [ 2:0] HSIZE,
     output wire [ 1:0] HTRANS,
     output wire [31:0] HWDATA,
     output wire        HWRITE,
     input  wire [31:0] HRDATA,
     input  wire        HREADY,
     input  wire        HRESP,
     output wire        HMASTER,

     // CODE SEQUENTIALITY AND SPECULATION
     output wire        CODENSEQ,
     output wire [ 2:0] CODEHINTDE,
     output wire        SPECHTRANS,

     // DEBUG
     input  wire        SWDITMS,
     input  wire        TDI,
     output wire        SWDO,
     output wire        SWDOEN,
     output wire        TDO,
     output wire        nTDOEN,
     input  wire        DBGRESTART,
     output wire        DBGRESTARTED,
     input  wire        EDBGRQ,
     output wire        HALTED,

     // MISC
     input  wire        NMI,
     input  wire [31:0] IRQ,
     output wire        TXEV,
     input  wire        RXEV,
     output wire        LOCKUP,
     output wire        SYSRESETREQ,
     input  wire [25:0] STCALIB,
     input  wire        STCLKEN,
     input  wire [ 7:0] IRQLATENCY,
     input  wire [27:0] ECOREVNUM,    // [27:20] to DAP, [19:0] to core

     // POWER MANAGEMENT
     output wire        GATEHCLK,
     output wire        SLEEPING,
     output wire        SLEEPDEEP,
     output wire        WAKEUP,
     output wire [33:0] WICSENSE,
     input  wire        SLEEPHOLDREQn,
     output wire        SLEEPHOLDACKn,
     input  wire        WICENREQ,
     output wire        WICENACK,
     output wire        CDBGPWRUPREQ,
     input  wire        CDBGPWRUPACK,

     // SCAN IO
     input  wire        SE,
     input  wire        RSTBYPASS
     );
   // ------------------------------------------------------------
   // ROM Table Value Calculation
   // ------------------------------------------------------------
   wire    [31:0] ROMTABLE_VAL;
   assign         ROMTABLE_VAL = {ROMTABLE_BASE[31:2],2'd3};
   // ------------------------------------------------------------
   // Configurability
   // ------------------------------------------------------------

   wire        cfg_dbg = DBG != 0;  // Reduce DBG param to a wire

   // ------------------------------------------------------------
   // Define sub-module interconnect wires
   // ------------------------------------------------------------

   wire        dp_reset_n;          // DAP DP reset (synchronised)
  
   wire [31:0] slv_rdata;           // Core -> DAP read data
   wire        slv_ready;           // Core -> DAP bus ready
   wire        slv_resp;            // Core -> DAP error response

   wire        wic_clear;           // NVIC -> WIC clear
   wire        wic_ds_req_n;        // WIC  -> NVIC mode request
   wire        wic_ds_ack_n;        // NVIC -> WIC mode acknowledge
   wire        wic_load;            // NVIC -> WIC load
   wire [31:0] wic_mask_isr;        // NVIC -> WIC IRQs mask
   wire        wic_mask_nmi;        // NVIC -> WIC NMI mask
   wire        wic_mask_rxev;       // NVIC -> WIC RXEV mask

   wire [33:0] wic_pend;            // interrupt pend lines

   wire [33:0] wic_sense;           // WIC sensitivity output

   wire [31:0] slv_addr_dap;        // DAP -> Core address
   wire [31:0] slv_wdata_dap;       // DAP -> Core write data
   wire [ 1:0] slv_trans_dap;       // DAP -> Core transaction
   wire        slv_write_dap;       // DAP -> Core write
   wire [ 1:0] slv_size_dap;        // DAP -> Core size

   wire        sw_do;               // DAP serial-wire output
   wire        sw_do_en;            // DAP serial-wire out enable
   wire        t_do;                // DAP TDO
   wire        t_do_en_n;           // DAP TDO enable
   wire        cdbg_pwrup_req;      // DAP powerup request

   // ------------------------------------------------------------
   // Tie off key debug signals if no debug is implemented
   // ------------------------------------------------------------

   // this logic is present to allow synthesis to strip out the
   // debug-access-port if no debug is required; implementors
   // may choose simply not to instantiate the DAP sub-module

   wire [31:0] slv_addr       = cfg_dbg ? slv_addr_dap  : {32{1'b0}};
   wire [31:0] slv_wdata      = cfg_dbg ? slv_wdata_dap : {32{1'b0}};
   wire [ 1:0] slv_trans      = cfg_dbg ? slv_trans_dap : {2{1'b0}};
   wire        slv_write      = cfg_dbg ? slv_write_dap : 1'b0;
   wire [ 1:0] slv_size       = cfg_dbg ? slv_size_dap  : {2{1'b0}};
   wire        device_en      = cfg_dbg ? 1'b1          : 1'b0;

   wire        sw_di_t_ms     = cfg_dbg ? SWDITMS       : 1'b1;
   wire        t_di           = cfg_dbg ? TDI           : 1'b0;
   wire        cdbg_pwrup_ack = cfg_dbg ? CDBGPWRUPACK  : 1'b0;
   wire [31:0] slv_rdata_dap  = cfg_dbg ? slv_rdata     : {32{1'b0}};
   wire        slv_ready_dap  = cfg_dbg ? slv_ready     : 1'b0;
   wire        slv_resp_dap   = cfg_dbg ? slv_resp      : 1'b0;

   // ------------------------------------------------------------
   // Reset synchronizer for dp_reset
   // ------------------------------------------------------------

   cm0_dbg_reset_sync #(.PRESENT(DBG))
     u_dpreset_sync
       (
        .RSTIN     (PORESETn),
        .CLK       (SWCLKTCK),
        .SE        (SE),
        .RSTBYPASS (RSTBYPASS),
        .RSTOUT    (dp_reset_n));

   // ------------------------------------------------------------
   // Generate signal that can be used to gate system clock
   // ------------------------------------------------------------

   // HCLK to core (and system) may be gated if the core is
   // sleeping, and there is no chance of a debug transaction

   wire        gate_hclk = ( (SLEEPING | ~SLEEPHOLDACKn) &
                             ~cdbg_pwrup_ack );

   // ------------------------------------------------------------
   // Connect wake-up interrupt controller to Cortex-M0 NVIC
   // ------------------------------------------------------------

   // the WIC module makes no distinction between NMI, RXEV or
   // regular interrupts, so simply assign NMI, RXEV and the
   // configured number of IRQ signals consistently to the least
   // significant bits of input and output ports

   wire [33:0] wic_mask = { wic_mask_isr[31:0],
                            wic_mask_nmi,
                            wic_mask_rxev };

   wire [33:0] wic_int  = { IRQ[31:0],
                            NMI,
                            RXEV };

   wire [31:0] irq_pend  = IRQ  | wic_pend[33:2];
   wire        nmi_pend  = NMI  | wic_pend[1];
   wire        rxev_pend = RXEV | wic_pend[0];

   // ------------------------------------------------------------

   // ------------------------------------------------------------
   // Cortex-M0 processor instantiation
   // ------------------------------------------------------------

   CORTEXM0
     #(.ACG(ACG), .AHBSLV(0), .BE(BE), .BKPT(BKPT),
       .DBG(DBG), .NUMIRQ(NUMIRQ), .RAR(RAR), .SMUL(SMUL),
       .SYST(SYST), .WIC(WIC), .WICLINES(WICLINES), .WPT(WPT))
       u_cortexm0
         (
          // Outputs
          .HADDR                          (HADDR[31:0]),
          .HBURST                         (HBURST[2:0]),
          .HMASTLOCK                      (HMASTLOCK),
          .HPROT                          (HPROT[3:0]),
          .HSIZE                          (HSIZE[2:0]),
          .HTRANS                         (HTRANS[1:0]),
          .HWDATA                         (HWDATA[31:0]),
          .HWRITE                         (HWRITE),
          .HMASTER                        (HMASTER),
          .SLVRDATA                       (slv_rdata[31:0]),
          .SLVREADY                       (slv_ready),
          .SLVRESP                        (slv_resp),
          .DBGRESTARTED                   (DBGRESTARTED),
          .HALTED                         (HALTED),
          .TXEV                           (TXEV),
          .LOCKUP                         (LOCKUP),
          .SYSRESETREQ                    (SYSRESETREQ),
          .CODENSEQ                       (CODENSEQ),
          .CODEHINTDE                     (CODEHINTDE[2:0]),
          .SPECHTRANS                     (SPECHTRANS),
          .SLEEPING                       (SLEEPING),
          .SLEEPDEEP                      (SLEEPDEEP),
          .SLEEPHOLDACKn                  (SLEEPHOLDACKn),
          .WICDSACKn                      (wic_ds_ack_n),
          .WICMASKISR                     (wic_mask_isr[31:0]),
          .WICMASKNMI                     (wic_mask_nmi),
          .WICMASKRXEV                    (wic_mask_rxev),
          .WICLOAD                        (wic_load),
          .WICCLEAR                       (wic_clear),
          // Inputs
          .SCLK                           (SCLK),
          .HCLK                           (HCLK),
          .DCLK                           (DCLK),
          .DBGRESETn                      (DBGRESETn),
          .HRESETn                        (HRESETn),
          .HRDATA                         (HRDATA[31:0]),
          .HREADY                         (HREADY),
          .HRESP                          (HRESP),
          .SLVADDR                        (slv_addr[31:0]),
          .SLVSIZE                        (slv_size[1:0]),
          .SLVTRANS                       (slv_trans[1:0]),
          .SLVWDATA                       (slv_wdata[31:0]),
          .SLVWRITE                       (slv_write),
          .DBGRESTART                     (DBGRESTART),
          .EDBGRQ                         (EDBGRQ),
          .NMI                            (nmi_pend),
          .IRQ                            (irq_pend[31:0]),
          .RXEV                           (rxev_pend),
          .STCALIB                        (STCALIB[25:0]),
          .STCLKEN                        (STCLKEN),
          .IRQLATENCY                     (IRQLATENCY[7:0]),
          .ECOREVNUM                      (ECOREVNUM[19:0]),
          .SLEEPHOLDREQn                  (SLEEPHOLDREQn),
          .WICDSREQn                      (wic_ds_req_n),
          .SE                             (SE));

   // ------------------------------------------------------------
   // Cortex-M0 debug-access-port instantiation
   // ------------------------------------------------------------

   CORTEXM0DAP
     #(.JTAGnSW(JTAGnSW),
       .DBG(DBG),
       .RAR(RAR))
       u_dap
         (// Outputs
          .SWDO                           (sw_do),
          .SWDOEN                         (sw_do_en),
          .TDO                            (t_do),
          .nTDOEN                         (t_do_en_n),
          .CDBGPWRUPREQ                   (cdbg_pwrup_req),
          .SLVADDR                        (slv_addr_dap[31:0]),
          .SLVWDATA                       (slv_wdata_dap[31:0]),
          .SLVTRANS                       (slv_trans_dap[1:0]),
          .SLVWRITE                       (slv_write_dap),
          .SLVSIZE                        (slv_size_dap[1:0]),
          // Inputs
          .SWCLKTCK                       (SWCLKTCK),
          .nTRST                          (nTRST),
          .DPRESETn                       (dp_reset_n),
          .APRESETn                       (DBGRESETn),
          .SWDITMS                        (sw_di_t_ms),
          .TDI                            (t_di),
          .CDBGPWRUPACK                   (cdbg_pwrup_ack),
          .DEVICEEN                       (device_en),
          .DCLK                           (DCLK),
          .SLVRDATA                       (slv_rdata_dap[31:0]),
          .SLVREADY                       (slv_ready_dap),
          .SLVRESP                        (slv_resp_dap),
          .BASEADDR                       (ROMTABLE_VAL),
          .ECOREVNUM                      (ECOREVNUM[27:20]),
          .SE                             (SE)
          );

   // ------------------------------------------------------------
   // Cortex-M0 wake-up interrupt controller instantiation
   // ------------------------------------------------------------

   cortexm0_wic
     #(.WIC(WIC), .WICLINES(WICLINES))
       u_wic
         (// Outputs
          .WAKEUP                         (WAKEUP),
          .WICSENSE                       (wic_sense[33:0]),
          .WICPEND                        (wic_pend[33:0]),
          .WICDSREQn                      (wic_ds_req_n),
          .WICENACK                       (WICENACK),
          // Inputs
          .FCLK                           (FCLK),
          .nRESET                         (HRESETn),
          .WICLOAD                        (wic_load),
          .WICCLEAR                       (wic_clear),
          .WICINT                         (wic_int[33:0]),
          .WICMASK                        (wic_mask[33:0]),
          .WICENREQ                       (WICENREQ),
          .WICDSACKn                      (wic_ds_ack_n));

   // ------------------------------------------------------------
   // Assign outputs
   // ------------------------------------------------------------

   assign      GATEHCLK      = gate_hclk;

   assign      SWDO          = cfg_dbg ? sw_do          : 1'b0;
   assign      SWDOEN        = cfg_dbg ? sw_do_en       : 1'b0;
   assign      TDO           = t_do;
   assign      nTDOEN        = cfg_dbg ? t_do_en_n      : 1'b1;
   assign      CDBGPWRUPREQ  = cfg_dbg ? cdbg_pwrup_req : 1'b0;

   assign      WICSENSE      = wic_sense[33:0];


endmodule // CORTEXM0INTEGRATION

// ---------------------------------------------------------------
// EOF
// ---------------------------------------------------------------
