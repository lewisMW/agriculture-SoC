//-----------------------------------------------------------------------------
// NanoSoC Pin Multiplexing Controller adapted from ARM CMSDK Pin multiplexing control
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Pin multiplexing control for example Cortex-M0/Cortex-M0+
//            microcontroller
//-----------------------------------------------------------------------------
//
module nanosoc_pin_mux (
  //-------------------------------------------
  // I/O ports
  //-------------------------------------------

    // UART
    output wire             uart0_rxd,
    input  wire             uart0_txd,
    input  wire             uart0_txen,
    output wire             uart1_rxd,
    input  wire             uart1_txd,
    input  wire             uart1_txen,
    output wire             uart2_rxd,
    input  wire             uart2_txd,
    input  wire             uart2_txen,

    // Timer
    output wire             timer0_extin,
    output wire             timer1_extin,

`ifdef CORTEX_M0PLUS
`ifdef ARM_CMSDK_INCLUDE_MTB
    // CoreSight MTB M0+
    output wire             TSTART,
    output wire             TSTOP,
`endif
`endif

    // IO Ports
    output wire  [15:0]     p0_in,
    input  wire  [15:0]     p0_out,
    input  wire  [15:0]     p0_outen,
    input  wire  [15:0]     p0_altfunc,

    output wire  [15:0]     p1_in,
    input  wire  [15:0]     p1_out,
    input  wire  [15:0]     p1_outen,
    input  wire  [15:0]     p1_altfunc,

    // // Processor debug interface
    // output wire             i_trst_n,
    // output wire             i_swditms,
    // output wire             i_swclktck,
    // output wire             i_tdi,
    // input  wire             i_tdo,
    // input  wire             i_tdoen_n,
    // input  wire             i_swdo,
    // input  wire             i_swdoen,

    // IO pads
    //inout  wire  [15:0]     P0, // legacy
    //inout  wire  [15:0]     P1, // legacy

    output wire  [15:0]     p1_out_mux,    //alt-function mux
    output wire  [15:0]     p1_out_en_mux  //alt-function mux

    // input  wire             nTRST, // Not needed if serial-wire debug is used
    // input  wire             TDI,   // Not needed if serial-wire debug is used
    // inout  wire             SWDIOTMS,
    // input  wire             SWCLKTCK,
    // output wire             TDO);   // Not needed if serial-wire debug is used
);

  //-------------------------------------------
  // Internal wires
  //-------------------------------------------
  wire      [15:0]     p0_out_mux;
  wire      [15:0]     p0_out_en_mux;
// wire      [15:0]     p1_out_mux;    // promoted to block output
// wire      [15:0]     p1_out_en_mux; // promoted to block output

  //-------------------------------------------
  // Beginning of main code
  //-------------------------------------------
  // inputs
  assign    uart0_rxd    = p1_in[0];
  assign    uart1_rxd    = p1_in[2];
  assign    uart2_rxd    = p1_in[4];
  assign    timer0_extin = p1_in[8];
  assign    timer1_extin = p1_in[9];

  //assign    p0_in        = P0;
  //assign    p1_in        = P1;

  // Output function mux
  assign    p0_out_mux    = p0_out; // No function muxing for Port 0

  assign    p1_out_mux[0] =                               p1_out[0];
  assign    p1_out_mux[1] = (p1_altfunc[1]) ? uart0_txd : p1_out[1];
  assign    p1_out_mux[2] =                               p1_out[2];
  assign    p1_out_mux[3] = (p1_altfunc[3]) ? uart1_txd : p1_out[3];
  assign    p1_out_mux[4] =                               p1_out[4];
  assign    p1_out_mux[5] = (p1_altfunc[5]) ? uart2_txd : p1_out[5];
  assign    p1_out_mux[15:6] = p1_out[15:6];

`ifdef CORTEX_M0PLUS
`ifdef ARM_CMSDK_INCLUDE_MTB
  // MTB control
  // The TSTART/TSTOP synchronising logic is instantiated within the
  // cmsdk_mcu_system module.
  assign    TSTART       = p1_in[7];
  assign    TSTOP        = p1_in[6];
  // This allows TSTART and TSTOP to be controlled from external sources.
`endif
`endif

  // Output enable mux
  assign    p0_out_en_mux   = p0_outen; // No function muxing for Port 0

  assign    p1_out_en_mux[0] =                                p1_outen[0];
  assign    p1_out_en_mux[1] = (p1_altfunc[1]) ? uart0_txen : p1_outen[1];
  assign    p1_out_en_mux[2] =                                p1_outen[2];
  assign    p1_out_en_mux[3] = (p1_altfunc[3]) ? uart1_txen : p1_outen[3];
  assign    p1_out_en_mux[4] =                                p1_outen[4];
  assign    p1_out_en_mux[5] = (p1_altfunc[5]) ? uart2_txen : p1_outen[5];
  assign    p1_out_en_mux[15:6] = p1_outen[15:6];


// port input feedback
  assign    p0_in[ 0] = p0_out_en_mux[ 0] ? p0_out_mux[ 0] : 1'b1;
  assign    p0_in[ 1] = p0_out_en_mux[ 1] ? p0_out_mux[ 1] : 1'b1;
  assign    p0_in[ 2] = p0_out_en_mux[ 2] ? p0_out_mux[ 2] : 1'b1;
  assign    p0_in[ 3] = p0_out_en_mux[ 3] ? p0_out_mux[ 3] : 1'b1;
  assign    p0_in[ 4] = p0_out_en_mux[ 4] ? p0_out_mux[ 4] : 1'b1;
  assign    p0_in[ 5] = p0_out_en_mux[ 5] ? p0_out_mux[ 5] : 1'b1;
  assign    p0_in[ 6] = p0_out_en_mux[ 6] ? p0_out_mux[ 6] : 1'b1;
  assign    p0_in[ 7] = p0_out_en_mux[ 7] ? p0_out_mux[ 7] : 1'b1;
  assign    p0_in[ 8] = p0_out_en_mux[ 8] ? p0_out_mux[ 8] : 1'b1;
  assign    p0_in[ 9] = p0_out_en_mux[ 9] ? p0_out_mux[ 9] : 1'b1;
  assign    p0_in[10] = p0_out_en_mux[10] ? p0_out_mux[10] : 1'b1;
  assign    p0_in[11] = p0_out_en_mux[11] ? p0_out_mux[11] : 1'b1;
  assign    p0_in[12] = p0_out_en_mux[12] ? p0_out_mux[12] : 1'b1;
  assign    p0_in[13] = p0_out_en_mux[13] ? p0_out_mux[13] : 1'b1;
  assign    p0_in[14] = p0_out_en_mux[14] ? p0_out_mux[14] : 1'b1;
  assign    p0_in[15] = p0_out_en_mux[15] ? p0_out_mux[15] : 1'b1;
//
  assign    p1_in[ 0] = p1_out_en_mux[ 0] ? p1_out_mux[ 0] : 1'b1;
  assign    p1_in[ 1] = p1_out_en_mux[ 1] ? p1_out_mux[ 1] : 1'b1;
  assign    p1_in[ 2] = p1_out_en_mux[ 2] ? p1_out_mux[ 2] : 1'b1;
  assign    p1_in[ 3] = p1_out_en_mux[ 3] ? p1_out_mux[ 3] : 1'b1;
  assign    p1_in[ 4] = p1_out_en_mux[ 4] ? p1_out_mux[ 4] : 1'b1;
  assign    p1_in[ 5] = p1_out_en_mux[ 5] ? p1_out_mux[ 5] : 1'b1;
  assign    p1_in[ 6] = p1_out_en_mux[ 6] ? p1_out_mux[ 6] : 1'b1;
  assign    p1_in[ 7] = p1_out_en_mux[ 7] ? p1_out_mux[ 7] : 1'b1;
  assign    p1_in[ 8] = p1_out_en_mux[ 8] ? p1_out_mux[ 8] : 1'b1;
  assign    p1_in[ 9] = p1_out_en_mux[ 9] ? p1_out_mux[ 9] : 1'b1;
  assign    p1_in[10] = p1_out_en_mux[10] ? p1_out_mux[10] : 1'b1;
  assign    p1_in[11] = p1_out_en_mux[11] ? p1_out_mux[11] : 1'b1;
  assign    p1_in[12] = p1_out_en_mux[12] ? p1_out_mux[12] : 1'b1;
  assign    p1_in[13] = p1_out_en_mux[13] ? p1_out_mux[13] : 1'b1;
  assign    p1_in[14] = p1_out_en_mux[14] ? p1_out_mux[14] : 1'b1;
  assign    p1_in[15] = p1_out_en_mux[15] ? p1_out_mux[15] : 1'b1;

  //-------------------------------------------
  // Debug connections
  //-------------------------------------------

  // assign    i_trst_n     = nTRST;
  // assign    i_tdi        = TDI;
  // assign    i_swclktck   = SWCLKTCK;
  // assign    i_swditms    = SWDIOTMS;

  // // Tristate buffers for debug output signals
  // bufif1 (SWDIOTMS, i_swdo, i_swdoen);
  // bufif0 (TDO,      i_tdo,  i_tdoen_n);

  endmodule
