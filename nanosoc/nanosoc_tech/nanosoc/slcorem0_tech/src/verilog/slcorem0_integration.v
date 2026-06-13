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
    parameter WPT      =  2)      // Number of DWT comparators
                                  //   0 = none
                                  //   1 = one
                                  //   2 = two
    // ----------------------------------------------------------------------

    (// CLOCK AND RESETS
     input  wire        FCLK,
     input  wire        SCLK,
     input  wire        HCLK,
     input  wire        DCLK,
     input  wire        DBGRESETn,
     input  wire        HRESETn,

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

     // DEBUG SLAVE PORT (directly exposed for DAP connection)
     input  wire [31:0] SLVADDR,
     input  wire [31:0] SLVWDATA,
     input  wire [ 1:0] SLVTRANS,
     input  wire        SLVWRITE,
     input  wire [ 1:0] SLVSIZE,
     output wire [31:0] SLVRDATA,
     output wire        SLVREADY,
     output wire        SLVRESP,

     // DEBUG
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
     input  wire [19:0] ECOREVNUM,

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
     input  wire        CDBGPWRUPACK,

     // SCAN IO
     input  wire        SE
     );

   // ------------------------------------------------------------
   // Generate signal that can be used to gate system clock
   // ------------------------------------------------------------

   // HCLK to core (and system) may be gated if the core is
   // sleeping, and there is no chance of a debug transaction

   wire        gate_hclk = ( (SLEEPING | ~SLEEPHOLDACKn) &
                             ~CDBGPWRUPACK );

   // ------------------------------------------------------------
   // Connect wake-up interrupt controller to Cortex-M0 NVIC
   // ------------------------------------------------------------

   // the WIC module makes no distinction between NMI, RXEV or
   // regular interrupts, so simply assign NMI, RXEV and the
   // configured number of IRQ signals consistently to the least
   // significant bits of input and output ports

   wire        wic_ds_req_n;            // WIC  -> NVIC mode request
   wire        wic_ds_ack_n;            // NVIC -> WIC mode acknowledge
   wire        wic_load;                // NVIC -> WIC load
   wire [31:0] wic_mask_isr;            // NVIC -> WIC IRQs mask
   wire        wic_mask_nmi;            // NVIC -> WIC NMI mask
   wire        wic_mask_rxev;           // NVIC -> WIC RXEV mask
   wire        wic_clear;               // NVIC -> WIC clear

   wire [33:0] wic_pend;                // interrupt pend lines
   wire [33:0] wic_sense;               // WIC sensitivity output

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
          .SLVRDATA                       (SLVRDATA[31:0]),
          .SLVREADY                       (SLVREADY),
          .SLVRESP                        (SLVRESP),
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
          .SLVADDR                        (SLVADDR[31:0]),
          .SLVSIZE                        (SLVSIZE[1:0]),
          .SLVTRANS                       (SLVTRANS[1:0]),
          .SLVWDATA                       (SLVWDATA[31:0]),
          .SLVWRITE                       (SLVWRITE),
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

   assign      WICSENSE      = wic_sense[33:0];


endmodule // CORTEXM0INTEGRATION

// ---------------------------------------------------------------
// EOF
// ---------------------------------------------------------------
