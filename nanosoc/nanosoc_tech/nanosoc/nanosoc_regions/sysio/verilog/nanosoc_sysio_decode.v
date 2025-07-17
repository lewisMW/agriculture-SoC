//-----------------------------------------------------------------------------
// NanoSoC AHB decoder for System Peripheral Space adapted from Arm CMSDK AHB decoder
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
//            (C) COPYRIGHT 2013 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-31 11:15:58 +0100 (Tue, 31 Jul 2012) $
//
//      Revision            : $Revision: 217031 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : This module performs the address decode of the HADDR from the
//            CPU and generates the HSELs' for each of the target peripherals.
//            Also performs address decode for MTB
//-----------------------------------------------------------------------------
//
`include "gen_defines.v"

module nanosoc_sysio_decode #(
  parameter SYS_ADDR_W           = 32,
  // APB Subsystem peripheral base address
  parameter BASEADDR_APBSS       = 32'h4000_0000,
  // GPIO0 peripheral base address
  parameter BASEADDR_GPIO0       = 32'h4001_0000,
  // GPIO1 peripheral base address
  parameter BASEADDR_GPIO1       = 32'h4001_1000,
  // Sysctrl base address
  parameter BASEADDR_SYSCTRL     = 32'h4001_f000,
  parameter BASEADDR_ADC         = 32'h4002_0000
)(
    // System Address
    input wire                  hsel,
    input wire [SYS_ADDR_W-1:0] haddr,

    // Peripheral Selection
    output wire                 apbsys_hsel,
    output wire                 gpio0_hsel,
    output wire                 gpio1_hsel,
    output wire                 sysctrl_hsel,
  `ifdef AMS_PERIPHERALS
    output wire                 adcsys_hsel,
  `endif
    // Default slave
    output wire                 defslv_hsel
  );

  // AHB address decode
  // 0x40000000 - 0x4000FFFF : APB subsystem
  // 0x40010000 - 0x40010FFF : AHB peripherals (GPIO0)
  // 0x40011000 - 0x40011FFF : AHB peripherals (GPIO1)
  // 0x4001F000 - 0x4001FFFF : AHB peripherals (SYS control)

  // ----------------------------------------------------------
  // Peripheral Selection decode logic
  // ----------------------------------------------------------

  assign apbsys_hsel  = hsel & (haddr[31:16]==
                        BASEADDR_APBSS[31:16]);   // 0x40000000
  assign gpio0_hsel   = hsel & (haddr[31:12]==
                        BASEADDR_GPIO0[31:12]);   // 0x40010000
  assign gpio1_hsel   = hsel & (haddr[31:12]==
                        BASEADDR_GPIO1[31:12]);   // 0x40011000
  assign sysctrl_hsel = hsel & (haddr[31:12]==
                        BASEADDR_SYSCTRL[31:12]); // 0x4001F000
`ifdef AMS_PERIPHERALS
  assign adcsys_hsel  = hsel & (haddr[31:12]==
                        BASEADDR_ADC[31:12]);     // 0x40020000
`endif
  // ----------------------------------------------------------
  // Default slave decode logic
  // ----------------------------------------------------------
`ifdef AMS_PERIPHERALS
  assign defslv_hsel  = ~(apbsys_hsel |
                          gpio0_hsel   | gpio1_hsel  |
                          sysctrl_hsel | adcsys_hsel
                         );
`else
  assign defslv_hsel  = ~(apbsys_hsel |
                          gpio0_hsel   | gpio1_hsel  |
                          sysctrl_hsel
                         );

`endif

endmodule
