//-----------------------------------------------------------------------------
// NanoSoC clock and power on generator adapted from Arm CMSDK Simple clock and power on reset generator
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
// Abstract : Simple clock and power on reset generator
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module nanosoc_clkreset(
  output wire CLK,
  output wire NRST,
  output wire NRST_early,
  output wire NRST_late,
  output wire NRST_ext
  );

  reg clock_q;

  reg [15:0] shifter;
  
  initial
    begin
      clock_q   <= 1'b0;
      shifter   <= 16'h0000;
      #40 clock_q <= 1'b1;
    end

  always @(clock_q)
 //     #25 clock_q <= ~clock_q; // 50ns period 20MHz - 9600 baud 
      #5 clock_q <= !clock_q;  // 10ns period, 100MHz - 48000 baud

  assign CLK = clock_q;

  always @(posedge clock_q)
    if (! (&shifter)) // until full...
      shifter   <= {shifter[14:0], 1'b1}; // shift left, fill with 1's

  assign NRST_early =  shifter[ 7];
  assign NRST       =  shifter[ 8];
  assign NRST_late  =  shifter[9] ;
  assign NRST_ext   =  shifter[15];

endmodule



