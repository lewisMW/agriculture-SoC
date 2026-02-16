//-----------------------------------------------------------------------------
// customised top-level Cortex-M0 'nanosoc' controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
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
// Abstract : Top level for example Cortex-M0/Cortex-M0+ microcontroller
//-----------------------------------------------------------------------------
//

module nanosoc_chip_pads (
`ifdef POWER_PINS
  inout  wire          VDDIO,
  inout  wire          VSSIO,
  inout  wire          VDD,
  inout  wire          VSS,
  inout  wire          VDDACC,
`endif   
  input  wire          SE,
  inout  wire          CLK, // input
  inout  wire          TEST, // output
  inout  wire          NRST,  // active low reset
  inout  wire  [15:0]  P0,
  inout  wire  [15:0]  P1,
  inout  wire          SWDIO,
  inout  wire          SWDCK);


//------------------------------------
// internal wires

localparam GPIO_TIO = 4;

wire        pad_clk_i;
wire        pad_nrst_i;
wire        pad_test_i;
wire        pad_swdclk_i;
wire        pad_swdio_i;
wire        pad_swdio_o;
wire        pad_swdio_e;
wire        pad_swdio_z;
wire [15:0] pad_gpio_port0_i ; 
wire [15:0] pad_gpio_port0_o ;
wire [15:0] pad_gpio_port0_e ;
wire [15:0] pad_gpio_port0_z ;
wire [15:0] pad_gpio_port1_i ;
wire [15:0] pad_gpio_port1_o ;
wire [15:0] pad_gpio_port1_e ;
wire [15:0] pad_gpio_port1_z ;
wire        soc_nreset;
wire        soc_diag_mode;
wire        soc_diag_ctrl;
wire        soc_scan_mode;
wire        soc_scan_enable;
wire [GPIO_TIO-1:0] soc_scan_in; //soc test status outputs
wire [GPIO_TIO-1:0] soc_scan_out; //soc test status outputs
wire        soc_bist_mode;
wire        soc_bist_enable;
wire [GPIO_TIO-1:0] soc_bist_in; //soc test status outputs
wire [GPIO_TIO-1:0] soc_bist_out; //soc test status outputs
wire        soc_alt_mode; // ALT MODE = UART
wire        soc_uart_rxd_i; // UART RXD
wire        soc_uart_txd_o; // UART TXD
wire        soc_swd_mode; // SWD mode
wire        soc_swd_clk_i; // SWDCLK
wire        soc_swd_dio_i; // SWDIO tristate input
wire        soc_swd_dio_o; // SWDIO trstate output
wire        soc_swd_dio_e; // SWDIO tristate output enable
wire        soc_swd_dio_z; // SWDIO tristate output hiz
wire [15:0] soc_gpio_port0_i; // GPIO SOC tristate input
wire [15:0] soc_gpio_port0_o; // GPIO SOC trstate output
wire [15:0] soc_gpio_port0_e; // GPIO SOC tristate output enable
wire [15:0] soc_gpio_port0_z; // GPIO SOC tristate output hiz
wire [15:0] soc_gpio_port1_i; // GPIO SOC tristate input
wire [15:0] soc_gpio_port1_o; // GPIO SOC trstate output
wire [15:0] soc_gpio_port1_e; // GPIO SOC tristate output enable
wire [15:0] soc_gpio_port1_z; // GPIO SOC tristate output hiz

wire pad_se_i;


// connect up high order GPIOs
assign soc_gpio_port0_i[15:GPIO_TIO] = pad_gpio_port0_i[15:GPIO_TIO];
assign pad_gpio_port0_o[15:GPIO_TIO] = soc_gpio_port0_o[15:GPIO_TIO];
assign pad_gpio_port0_e[15:GPIO_TIO] = soc_gpio_port0_e[15:GPIO_TIO];
assign pad_gpio_port0_z[15:GPIO_TIO] = soc_gpio_port0_z[15:GPIO_TIO];
assign soc_gpio_port1_i[15:GPIO_TIO] = pad_gpio_port1_i[15:GPIO_TIO];
assign pad_gpio_port1_o[15:GPIO_TIO] = soc_gpio_port1_o[15:GPIO_TIO];
assign pad_gpio_port1_e[15:GPIO_TIO] = soc_gpio_port1_e[15:GPIO_TIO];
assign pad_gpio_port1_z[15:GPIO_TIO] = soc_gpio_port1_z[15:GPIO_TIO];

wire tiehi = 1'b1;
wire tielo = 1'b0;

nanosoc_chip_cfg #(
    .GPIO_TIO (GPIO_TIO)
  )
  u_nanosoc_chip_cfg
  (
  // Primary Inputs
   .pad_clk_i        (pad_clk_i         )
  ,.pad_nrst_i       (pad_nrst_i        )
  ,.pad_test_i       (pad_test_i        )
  // Alternate/reconfigurable IP and associated bidirectional I/O
  ,.pad_altin_i      (pad_se_i      )  // SWCLK/UARTRXD/SCAN-ENABLE
  ,.pad_altio_i      (pad_swdio_i       )  // SWDIO/UARTTXD tristate input
  ,.pad_altio_o      (pad_swdio_o       )  // SWDIO/UARTTXD trstate output
  ,.pad_altio_e      (pad_swdio_e       )  // SWDIO/UARTTXD tristate output enable
  ,.pad_altio_z      (pad_swdio_z       )  // SWDIO/UARTTXD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-0 (user)
  ,.pad_gpio_port0_i (pad_gpio_port0_i[GPIO_TIO-1:0]) // GPIO PAD tristate input
  ,.pad_gpio_port0_o (pad_gpio_port0_o[GPIO_TIO-1:0]) // GPIO PAD trstate output
  ,.pad_gpio_port0_e (pad_gpio_port0_e[GPIO_TIO-1:0]) // GPIO PAD tristate output enable
  ,.pad_gpio_port0_z (pad_gpio_port0_z[GPIO_TIO-1:0]) // GPIO PAD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-1 (system)
  ,.pad_gpio_port1_i (pad_gpio_port1_i[GPIO_TIO-1:0]) // GPIO PAD tristate input
  ,.pad_gpio_port1_o (pad_gpio_port1_o[GPIO_TIO-1:0]) // GPIO PAD trstate output
  ,.pad_gpio_port1_e (pad_gpio_port1_e[GPIO_TIO-1:0]) // GPIO PAD tristate output enable
  ,.pad_gpio_port1_z (pad_gpio_port1_z[GPIO_TIO-1:0]) // GPIO PAD tristate output hiz
  //SOC
  ,.soc_nreset       (soc_nreset        )
  ,.soc_diag_mode    (soc_diag_mode     )
  ,.soc_diag_ctrl    (soc_diag_ctrl     )
  ,.soc_scan_mode    (soc_scan_mode     )
  ,.soc_scan_enable  (soc_scan_enable   )
  ,.soc_scan_in      (soc_scan_in       ) // soc test scan chain inputs
  ,.soc_scan_out     (soc_scan_out      ) // soc test scan chain outputs
  ,.soc_bist_mode    (soc_bist_mode     )
  ,.soc_bist_enable  (soc_bist_enable   )
  ,.soc_bist_in      (soc_bist_in       ) // soc bist control inputs
  ,.soc_bist_out     (soc_bist_out      ) // soc test status outputs
  ,.soc_alt_mode     (soc_alt_mode      )// ALT MODE = UART
  ,.soc_uart_rxd_i   (soc_uart_rxd_i    ) // UART RXD
  ,.soc_uart_txd_o   (soc_uart_txd_o    ) // UART TXD
  ,.soc_swd_mode     (soc_swd_mode      ) // SWD mode
  ,.soc_swd_clk_i    (soc_swd_clk_i     ) // SWDCLK
  ,.soc_swd_dio_i    (soc_swd_dio_i     ) // SWDIO tristate input
  ,.soc_swd_dio_o    (soc_swd_dio_o     ) // SWDIO trstate output
  ,.soc_swd_dio_e    (soc_swd_dio_e     ) // SWDIO tristate output enable
  ,.soc_swd_dio_z    (soc_swd_dio_z     ) // SWDIO tristate output hiz
  ,.soc_gpio_port0_i (soc_gpio_port0_i[GPIO_TIO-1:0]) // GPIO SOC tristate input
  ,.soc_gpio_port0_o (soc_gpio_port0_o[GPIO_TIO-1:0]) // GPIO SOC trstate output
  ,.soc_gpio_port0_e (soc_gpio_port0_e[GPIO_TIO-1:0]) // GPIO SOC tristate output enable
  ,.soc_gpio_port0_z (soc_gpio_port0_z[GPIO_TIO-1:0]) // GPIO SOC tristate output hiz
  ,.soc_gpio_port1_i (soc_gpio_port1_i[GPIO_TIO-1:0]) // GPIO SOC tristate input
  ,.soc_gpio_port1_o (soc_gpio_port1_o[GPIO_TIO-1:0]) // GPIO SOC trstate output
  ,.soc_gpio_port1_e (soc_gpio_port1_e[GPIO_TIO-1:0]) // GPIO SOC tristate output enable
  ,.soc_gpio_port1_z (soc_gpio_port1_z[GPIO_TIO-1:0]) // GPIO SOC tristate output hiz
);

 // --------------------------------------------------------------------------------
 // Cortex-M0 nanosoc Microcontroller
 // --------------------------------------------------------------------------------

  nanosoc_chip u_nanosoc_chip (
`ifdef POWER_PINS
  .VDD         (VDD),
  .VSS         (VSS),
  .VDDACC      (VDDACC),
`endif
//`ifdef ASIC_TEST_PORTS
  .diag_mode   (soc_diag_mode     ),
  .diag_ctrl   (soc_diag_ctrl     ),
  .scan_mode   (soc_scan_mode     ),
  .scan_enable (soc_scan_enable   ),
  .scan_in     (soc_scan_in       ), // soc test scan chain inputs
  .scan_out    (soc_scan_out      ),       // soc test scan chain outputs
  .bist_mode   (soc_bist_mode     ),
  .bist_enable (soc_bist_enable   ),
  .bist_in     (soc_bist_in       ), // soc bist control inputs
  .bist_out    (soc_bist_out      ),       // soc test status outputs
  .alt_mode    (soc_alt_mode      ),// ALT MODE = UART
  .uart_rxd_i  (soc_uart_rxd_i    ), // UART RXD
  .uart_txd_o  (soc_uart_txd_o    ), // UART TXD
  .swd_mode    (soc_swd_mode      ),    // SWD mode
//`endif
  .clk_i       (pad_clk_i),
  .test_i      (soc_scan_mode), //(test_i),
  .nrst_i      (soc_nreset), //(nrst_i),
  .p0_i        (soc_gpio_port0_i), // level-shifted input from pad
  .p0_o        (soc_gpio_port0_o), // output port drive
  .p0_e        (soc_gpio_port0_e), // active high output drive enable (pad tech dependent)
  .p0_z        (soc_gpio_port0_z), // active low output drive enable (pad tech dependent)
  .p1_i        (soc_gpio_port1_i), // level-shifted input from pad
  .p1_o        (soc_gpio_port1_o), // output port drive
  .p1_e        (soc_gpio_port1_e), // active high output drive enable (pad tech dependent)
  .p1_z        (soc_gpio_port1_z), // active low output drive enable (pad tech dependent)
  .swdio_i     (soc_swd_dio_i),
  .swdio_o     (soc_swd_dio_o),
  .swdio_e     (soc_swd_dio_e),
  .swdio_z     (soc_swd_dio_z),
  .swdclk_i    (pad_swdclk_i)
  );


 // --------------------------------------------------------------------------------
 // IO pad (GLIB Generic Library napping)
 // --------------------------------------------------------------------------------

`ifdef POWER_PINS
// Pad IO power supplies

PAD_VDDIO uPAD_VDDIO_1(
   .PAD(VDDIO)
   );

PAD_VSSIO uPAD_VSSIO_1(
   .PAD(VSSIO)
   );

// Core power supplies

PAD_VDDSOC uPAD_VDD_1(
   .PAD(VDD)
   );

PAD_VSS uPAD_VSS_1(
   .PAD(VSS)
   );

// Accelerator Power supplies
PAD_VDDSOC uPAD_VDDACC_1(
   .PAD(VDDACC)
   );
`endif

// Clock, Reset and Serial Wire Debug ports

PAD_INOUT8MA_NOE uPAD_SE_I (
   .PAD (SE), 
   .O   (tielo),
   .I   (pad_se_i), 
   .NOE (tiehi)
   );

PAD_INOUT8MA_NOE uPAD_CLK_I (
   .PAD (CLK), 
   .O   (tielo),
   .I   (pad_clk_i), 
   .NOE (tiehi)
   );

PAD_INOUT8MA_NOE uPAD_XTAL_I (
   .PAD (TEST), 
   .O   (tielo),
   .I   (pad_test_i), 
   .NOE (tiehi)
   );

PAD_INOUT8MA_NOE uPAD_NRST_I (
   .PAD (NRST), 
   .O   (tielo),
   .I   (pad_nrst_i), 
   .NOE (tiehi)
   );

PAD_INOUT8MA_NOE uPAD_SWDIO_IO (
   .PAD (SWDIO), 
   .O   (pad_swdio_o), 
   .I   (pad_swdio_i),
   .NOE (pad_swdio_z)
   );

PAD_INOUT8MA_NOE uPAD_SWDCK_I (
   .PAD (SWDCK), 
   .O   (tielo), 
   .I   (pad_swdclk_i),
   .NOE (tiehi)
   );

// GPI.I Port 0 x 16

PAD_INOUT8MA_NOE uPAD_P0_00 (
   .PAD (P0[00]), 
   .O   (pad_gpio_port0_o[00]), 
   .I   (pad_gpio_port0_i[00]),
   .NOE (pad_gpio_port0_z[00])
   );

PAD_INOUT8MA_NOE uPAD_P0_01 (
   .PAD (P0[01]), 
   .O   (pad_gpio_port0_o[01]), 
   .I   (pad_gpio_port0_i[01]),
   .NOE (pad_gpio_port0_z[01])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_02 (
   .PAD (P0[02]), 
   .O   (pad_gpio_port0_o[02]), 
   .I   (pad_gpio_port0_i[02]),
   .NOE (pad_gpio_port0_z[02])
   );

PAD_INOUT8MA_NOE uPAD_P0_03 (
   .PAD (P0[03]), 
   .O   (pad_gpio_port0_o[03]), 
   .I   (pad_gpio_port0_i[03]),
   .NOE (pad_gpio_port0_z[03])
   );

PAD_INOUT8MA_NOE uPAD_P0_04 (
   .PAD (P0[04]), 
   .O   (pad_gpio_port0_o[04]), 
   .I   (pad_gpio_port0_i[04]),
   .NOE (pad_gpio_port0_z[04])
   );

PAD_INOUT8MA_NOE uPAD_P0_05 (
   .PAD (P0[05]), 
   .O   (pad_gpio_port0_o[05]), 
   .I   (pad_gpio_port0_i[05]),
   .NOE (pad_gpio_port0_z[05])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_06 (
   .PAD (P0[06]), 
   .O   (pad_gpio_port0_o[06]), 
   .I   (pad_gpio_port0_i[06]),
   .NOE (pad_gpio_port0_z[06])
   );

PAD_INOUT8MA_NOE uPAD_P0_07 (
   .PAD (P0[07]), 
   .O   (pad_gpio_port0_o[07]), 
   .I   (pad_gpio_port0_i[07]),
   .NOE (pad_gpio_port0_z[07])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_08 (
   .PAD (P0[08]), 
   .O   (pad_gpio_port0_o[08]), 
   .I   (pad_gpio_port0_i[08]),
   .NOE (pad_gpio_port0_z[08])
   );

PAD_INOUT8MA_NOE uPAD_P0_09 (
   .PAD (P0[09]), 
   .O   (pad_gpio_port0_o[09]), 
   .I   (pad_gpio_port0_i[09]),
   .NOE (pad_gpio_port0_z[09])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_10 (
   .PAD (P0[10]), 
   .O   (pad_gpio_port0_o[10]), 
   .I   (pad_gpio_port0_i[10]),
   .NOE (pad_gpio_port0_z[10])
   );

PAD_INOUT8MA_NOE uPAD_P0_11 (
   .PAD (P0[11]), 
   .O   (pad_gpio_port0_o[11]), 
   .I   (pad_gpio_port0_i[11]),
   .NOE (pad_gpio_port0_z[11])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_12 (
   .PAD (P0[12]), 
   .O   (pad_gpio_port0_o[12]), 
   .I   (pad_gpio_port0_i[12]),
   .NOE (pad_gpio_port0_z[12])
   );

PAD_INOUT8MA_NOE uPAD_P0_13 (
   .PAD (P0[13]), 
   .O   (pad_gpio_port0_o[13]), 
   .I   (pad_gpio_port0_i[13]),
   .NOE (pad_gpio_port0_z[13])
   );
  
PAD_INOUT8MA_NOE uPAD_P0_14 (
   .PAD (P0[14]), 
   .O   (pad_gpio_port0_o[14]), 
   .I   (pad_gpio_port0_i[14]),
   .NOE (pad_gpio_port0_z[14])
   );

PAD_INOUT8MA_NOE uPAD_P0_15 (
   .PAD (P0[15]), 
   .O   (pad_gpio_port0_o[15]), 
   .I   (pad_gpio_port0_i[15]),
   .NOE (pad_gpio_port0_z[15])
   );
  
// GPI.I Port 1 x 16

PAD_INOUT8MA_NOE uPAD_P1_00 (
   .PAD (P1[00]), 
   .O   (pad_gpio_port1_o[00]), 
   .I   (pad_gpio_port1_i[00]),
   .NOE (pad_gpio_port1_z[00])
   );

PAD_INOUT8MA_NOE uPAD_P1_01 (
   .PAD (P1[01]), 
   .O   (pad_gpio_port1_o[01]), 
   .I   (pad_gpio_port1_i[01]),
   .NOE (pad_gpio_port1_z[01])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_02 (
   .PAD (P1[02]), 
   .O   (pad_gpio_port1_o[02]), 
   .I   (pad_gpio_port1_i[02]),
   .NOE (pad_gpio_port1_z[02])
   );

PAD_INOUT8MA_NOE uPAD_P1_03 (
   .PAD (P1[03]), 
   .O   (pad_gpio_port1_o[03]), 
   .I   (pad_gpio_port1_i[03]),
   .NOE (pad_gpio_port1_z[03])
   );

PAD_INOUT8MA_NOE uPAD_P1_04 (
   .PAD (P1[04]), 
   .O   (pad_gpio_port1_o[04]), 
   .I   (pad_gpio_port1_i[04]),
   .NOE (pad_gpio_port1_z[04])
   );

PAD_INOUT8MA_NOE uPAD_P1_05 (
   .PAD (P1[05]), 
   .O   (pad_gpio_port1_o[05]), 
   .I   (pad_gpio_port1_i[05]),
   .NOE (pad_gpio_port1_z[05])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_06 (
   .PAD (P1[06]), 
   .O   (pad_gpio_port1_o[06]), 
   .I   (pad_gpio_port1_i[06]),
   .NOE (pad_gpio_port1_z[06])
   );

PAD_INOUT8MA_NOE uPAD_P1_07 (
   .PAD (P1[07]), 
   .O   (pad_gpio_port1_o[07]), 
   .I   (pad_gpio_port1_i[07]),
   .NOE (pad_gpio_port1_z[07])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_08 (
   .PAD (P1[08]), 
   .O   (pad_gpio_port1_o[08]), 
   .I   (pad_gpio_port1_i[08]),
   .NOE (pad_gpio_port1_z[08])
   );

PAD_INOUT8MA_NOE uPAD_P1_09 (
   .PAD (P1[09]), 
   .O   (pad_gpio_port1_o[09]), 
   .I   (pad_gpio_port1_i[09]),
   .NOE (pad_gpio_port1_z[09])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_10 (
   .PAD (P1[10]), 
   .O   (pad_gpio_port1_o[10]), 
   .I   (pad_gpio_port1_i[10]),
   .NOE (pad_gpio_port1_z[10])
   );

PAD_INOUT8MA_NOE uPAD_P1_11 (
   .PAD (P1[11]), 
   .O   (pad_gpio_port1_o[11]), 
   .I   (pad_gpio_port1_i[11]),
   .NOE (pad_gpio_port1_z[11])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_12 (
   .PAD (P1[12]), 
   .O   (pad_gpio_port1_o[12]), 
   .I   (pad_gpio_port1_i[12]),
   .NOE (pad_gpio_port1_z[12])
   );

PAD_INOUT8MA_NOE uPAD_P1_13 (
   .PAD (P1[13]), 
   .O   (pad_gpio_port1_o[13]), 
   .I   (pad_gpio_port1_i[13]),
   .NOE (pad_gpio_port1_z[13])
   );
  
PAD_INOUT8MA_NOE uPAD_P1_14 (
   .PAD (P1[14]), 
   .O   (pad_gpio_port1_o[14]), 
   .I   (pad_gpio_port1_i[14]),
   .NOE (pad_gpio_port1_z[14])
   );

PAD_INOUT8MA_NOE uPAD_P1_15 (
   .PAD (P1[15]), 
   .O   (pad_gpio_port1_o[15]), 
   .I   (pad_gpio_port1_i[15]),
   .NOE (pad_gpio_port1_z[15])
   );

endmodule
