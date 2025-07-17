//-----------------------------------------------------------------------------
// SLCore-M0 SysTick controller adapted from Arm CMSDK Simple control for SysTick signals for Cortex-M processor
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
// Abstract : Simple control for SysTick signals for Cortex-M processor
//-----------------------------------------------------------------------------

module slcorem0_stclkctrl #(
  // Ratio between FCLK and SysTck reference clock
  parameter DIV_RATIO = 18'd01000,

  // Divide by half for each phase
  parameter DIVIDER_RELOAD = (DIV_RATIO>>1)-1
  )(
    input  wire        FCLK,      // Free running clock
    input  wire        SYSRESETn, // System reset
    output wire        STCLKEN,   // SysTick clock
    output wire [25:0] STCALIB    // SysTick calibration
  );

  reg     [17:0] reg_clk_divider;
  reg            reg_stclken;

  assign STCALIB[25] = 1'b0; // NoRef - reference clock provided
  assign STCALIB[24] = 1'b1; // Skew - reference info not available
  assign STCALIB[23:0] = {24{1'b0}}; // 10 ms value  set to 0, indicate this value is not used

  // Divider
  wire [17:0] reg_clk_div_min1 = reg_clk_divider - 18'd1;
  always @(posedge FCLK or negedge SYSRESETn)
  begin
  if (~SYSRESETn)
    reg_clk_divider <= {18{1'b0}};
  else
    begin
    if (|reg_clk_divider)
      reg_clk_divider <= reg_clk_div_min1[17:0];
    else
      reg_clk_divider <= DIVIDER_RELOAD[17:0];
    end
  end

  // Toggle register
  always @(posedge FCLK or negedge SYSRESETn)
  begin
  if (~SYSRESETn)
    reg_stclken <= 1'b0;
  else
    begin
    if (reg_clk_divider==18'h00000)
      reg_stclken <= ~reg_stclken;
    end
  end

  // Connect to top level
  assign STCLKEN = reg_stclken;

endmodule

