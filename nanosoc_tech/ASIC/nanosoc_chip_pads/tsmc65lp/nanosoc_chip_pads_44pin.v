//-----------------------------------------------------------------------------
// Top-Level Pad implementation for TSMC65nm
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
// Abstract : Top level for example Cortex-M0/Cortex-M0+ microcontroller
//-----------------------------------------------------------------------------
//
`include "gen_defines.v"

module nanosoc_chip_pads (
  inout  wire          VDDIO,
  inout  wire          VSSIO,
  inout  wire          VDD,
  inout  wire          VSS,
  inout  wire          VDDACC,

  input  wire          SE,
  input  wire          CLK, // input
  input  wire          TEST, // input
  input  wire          NRST,  // active low reset
  inout  wire  [7:0]  P0,
  inout  wire  [7:0]  P1,
  inout  wire          SWDIO,
  input  wire          SWDCK);


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
wire        soc_uart_txd_o = 1'b1; // UART TXD
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

  nanosoc_chip u_nanosoc_chip (
`ifdef POWER_PINS
  .VDD        (VDD),
  .VSS        (VSS),
  .VDDACC     (VDDACC),
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
  .clk_i(pad_clk_i),
  .test_i(soc_scan_mode),
  .nrst_i(soc_nreset),
  .p0_i(soc_gpio_port0_i), // level-shifted input from pad
  .p0_o(soc_gpio_port0_o), // output port drive
  .p0_e(soc_gpio_port0_e), // active high output drive enable (pad tech dependent)
  .p0_z(soc_gpio_port0_z), // active low output drive enable (pad tech dependent)
  .p1_i(soc_gpio_port1_i), // level-shifted input from pad
  .p1_o(soc_gpio_port1_o), // output port drive
  .p1_e(soc_gpio_port1_e), // active high output drive enable (pad tech dependent)
  .p1_z(soc_gpio_port1_z), // active low output drive enable (pad tech dependent)
  .swdio_i(soc_swd_dio_i),
  .swdio_o(soc_swd_dio_o),
  .swdio_e(soc_swd_dio_e),
  .swdio_z(soc_swd_dio_z),
  .swdclk_i(pad_swdclk_i)
  );


 // --------------------------------------------------------------------------------
 // IO pad (TSMC 65nm specific Library napping)
 // --------------------------------------------------------------------------------

// Pad IO power supplies

PVDD2CDG uPAD_VDDIO_0(
   .VDDPST(VDDIO)
   );
//PVDD2CDG uPAD_VDDIO_1(
//   .VDDPST(VDDIO)
//   );
PVDD2CDG uPAD_VDDIO_2(
   .VDDPST(VDDIO)
   );
PVDD2POC uPAD_VDDIO_3(
   .VDDPST(VDDIO)
   );

PVSS2CDG uPAD_VSSIO_0(
   .VSSPST(VSSIO)
   );
PVSS2CDG uPAD_VSSIO_1(
   .VSSPST(VSSIO)
   );

// Core power supplies

PVDD1CDG uPAD_VDD_0(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_1(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_2(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_3(
   .VDD(VDD)
   );

PVSS1CDG uPAD_VSS_0(
   .VSS(VSS)
   );
PVSS1CDG uPAD_VSS_1(
   .VSS(VSS)
   );
PVSS1CDG uPAD_VSS_2(
   .VSS(VSS)
   );
PVSS1CDG uPAD_VSS_3(
   .VSS(VSS)
   );
// Accelerator Power supplies
PVDD1CDG uPAD_VDDACC_0(
   .VDD(VDDACC)
   );
PVDD1CDG uPAD_VDDACC_1(
   .VDD(VDDACC)
   );
PVDD1CDG uPAD_VDDACC_2(
   .VDD(VDDACC)
   );

// Clock, Reset and Serial Wire Debug ports

PRDW0408SCDG uPAD_SE_I (
    .IE(tiehi),
    .C(pad_se_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(SE)
   );


PRDW0408SCDG uPAD_CLK_I (
    .IE(tiehi),
    .C(pad_clk_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(CLK)
   );

PRDW0408SCDG uPAD_TEST_I (
    .IE(tiehi),
    .C(pad_test_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(TEST)
   );

PRDW0408SCDG uPAD_NRST_I (
    .IE(tiehi),
    .C(pad_nrst_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(NRST)
   );

PRDW0408SCDG uPAD_SWDIO_IO (
    .IE(pad_swdio_z),
    .C(pad_swdio_i),
    .PE(tielo),
    .DS(tielo),
    .I(pad_swdio_o),
    .OEN(pad_swdio_z),
    .PAD(SWDIO)
   );

PRDW0408SCDG uPAD_SWDCK_I (
    .IE(tiehi),
    .C(pad_swdclk_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(SWDCK)
   );

// GPI.I Port 0 x 16

PRDW0408SCDG uPAD_P0_00 (
    .IE(pad_gpio_port0_z[00]),
    .C(pad_gpio_port0_i[00]),
    .PE(pad_gpio_port0_z[00]&pad_gpio_port0_o[00]),
    .DS(tielo),
    .I(pad_gpio_port0_o[00]),
    .OEN(pad_gpio_port0_z[00]),
    .PAD(P0[00])
   );

PRDW0408SCDG uPAD_P0_01 (
    .IE(pad_gpio_port0_z[01]),
    .C(pad_gpio_port0_i[01]),
    .PE(pad_gpio_port0_z[01]&pad_gpio_port0_o[01]),
    .DS(tielo),
    .I(pad_gpio_port0_o[01]),
    .OEN(pad_gpio_port0_z[01]),
    .PAD(P0[01])
   );
  
PRDW0408SCDG uPAD_P0_02 (
    .IE(pad_gpio_port0_z[02]),
    .C(pad_gpio_port0_i[02]),
    .PE(pad_gpio_port0_z[02]&pad_gpio_port0_o[02]),
    .DS(tielo),
    .I(pad_gpio_port0_o[02]),
    .OEN(pad_gpio_port0_z[02]),
    .PAD(P0[02])
   );

PRDW0408SCDG uPAD_P0_03 (
    .IE(pad_gpio_port0_z[03]),
    .C(pad_gpio_port0_i[03]),
    .PE(pad_gpio_port0_z[03]&pad_gpio_port0_o[03]),
    .DS(tielo),
    .I(pad_gpio_port0_o[03]),
    .OEN(pad_gpio_port0_z[03]),
    .PAD(P0[03])
   );

PRDW0408SCDG uPAD_P0_04 (
    .IE(pad_gpio_port0_z[04]),
    .C(pad_gpio_port0_i[04]),
    .PE(pad_gpio_port0_z[04]&pad_gpio_port0_o[04]),
    .DS(tielo),
    .I(pad_gpio_port0_o[04]),
    .OEN(pad_gpio_port0_z[04]),
    .PAD(P0[04])
   );

PRDW0408SCDG uPAD_P0_05 (
    .IE(pad_gpio_port0_z[05]),
    .C(pad_gpio_port0_i[05]),
    .PE(pad_gpio_port0_z[05]&pad_gpio_port0_o[05]),
    .DS(tielo),
    .I(pad_gpio_port0_o[05]),
    .OEN(pad_gpio_port0_z[05]),
    .PAD(P0[05])
   );
  
PRDW0408SCDG uPAD_P0_06 (
    .IE(pad_gpio_port0_z[06]),
    .C(pad_gpio_port0_i[06]),
    .PE(pad_gpio_port0_z[06]&pad_gpio_port0_o[06]),
    .DS(tielo),
    .I(pad_gpio_port0_o[06]),
    .OEN(pad_gpio_port0_z[06]),
    .PAD(P0[06])
   );

PRDW0408SCDG uPAD_P0_07 (
    .IE(pad_gpio_port0_z[07]),
    .C(pad_gpio_port0_i[07]),
    .PE(pad_gpio_port0_z[07]&pad_gpio_port0_o[07]),
    .DS(tielo),
    .I(pad_gpio_port0_o[07]),
    .OEN(pad_gpio_port0_z[07]),
    .PAD(P0[07])
   );
// GPI.I Port 1 x 16

PRDW0408SCDG uPAD_P1_00 (
    .IE(pad_gpio_port1_z[00]),
    .C(pad_gpio_port1_i[00]),
    .PE(pad_gpio_port1_z[00]&pad_gpio_port1_o[00]),
    .DS(tielo),
    .I(pad_gpio_port1_o[00]),
    .OEN(pad_gpio_port1_z[00]),
    .PAD(P1[00])
   );

PRDW0408SCDG uPAD_P1_01 (
    .IE(pad_gpio_port1_z[01]),
    .C(pad_gpio_port1_i[01]),
    .PE(pad_gpio_port1_z[01]&pad_gpio_port1_o[01]),
    .DS(tielo),
    .I(pad_gpio_port1_o[01]),
    .OEN(pad_gpio_port1_z[01]),
    .PAD(P1[01])
   );
  
PRDW0408SCDG uPAD_P1_02 (
    .IE(pad_gpio_port1_z[02]),
    .C(pad_gpio_port1_i[02]),
    .PE(pad_gpio_port1_z[02]&pad_gpio_port1_o[02]),
    .DS(tielo),
    .I(pad_gpio_port1_o[02]),
    .OEN(pad_gpio_port1_z[02]),
    .PAD(P1[02])
   );

PRDW0408SCDG uPAD_P1_03 (
    .IE(pad_gpio_port1_z[03]),
    .C(pad_gpio_port1_i[03]),
    .PE(pad_gpio_port1_z[03]&pad_gpio_port1_o[03]),
    .DS(tielo),
    .I(pad_gpio_port1_o[03]),
    .OEN(pad_gpio_port1_z[03]),
    .PAD(P1[03])
   );

PRDW0408SCDG uPAD_P1_04 (
    .IE(pad_gpio_port1_z[04]),
    .C(pad_gpio_port1_i[04]),
    .PE(pad_gpio_port1_z[04]&pad_gpio_port1_o[04]),
    .DS(tielo),
    .I(pad_gpio_port1_o[04]),
    .OEN(pad_gpio_port1_z[04]),
    .PAD(P1[04])
   );

PRDW0408SCDG uPAD_P1_05 (
    .IE(pad_gpio_port1_z[05]),
    .C(pad_gpio_port1_i[05]),
    .PE(pad_gpio_port1_z[05]&pad_gpio_port1_o[05]),
    .DS(tielo),
    .I(pad_gpio_port1_o[05]),
    .OEN(pad_gpio_port1_z[05]),
    .PAD(P1[05])
   );
  
PRDW0408SCDG uPAD_P1_06 (
    .IE(pad_gpio_port1_z[06]),
    .C(pad_gpio_port1_i[06]),
    .PE(pad_gpio_port1_z[06]&pad_gpio_port1_o[06]),
    .DS(tielo),
    .I(pad_gpio_port1_o[06]),
    .OEN(pad_gpio_port1_z[06]),
    .PAD(P1[06])
   );

PRDW0408SCDG uPAD_P1_07 (
    .IE(pad_gpio_port1_z[07]),
    .C(pad_gpio_port1_i[07]),
    .PE(pad_gpio_port1_z[07]&pad_gpio_port1_o[07]),
    .DS(tielo),
    .I(pad_gpio_port1_o[07]),
    .OEN(pad_gpio_port1_z[07]),
    .PAD(P1[07])
   );


assign pad_gpio_port0_i[8] = pad_gpio_port0_o[8] & pad_gpio_port0_e[8];
assign pad_gpio_port0_i[9] = pad_gpio_port0_o[9] & pad_gpio_port0_e[9];
assign pad_gpio_port0_i[10] = pad_gpio_port0_o[10] & pad_gpio_port0_e[10];
assign pad_gpio_port0_i[11] = pad_gpio_port0_o[11] & pad_gpio_port0_e[11];
assign pad_gpio_port0_i[12] = pad_gpio_port0_o[12] & pad_gpio_port0_e[12];
assign pad_gpio_port0_i[13] = pad_gpio_port0_o[13] & pad_gpio_port0_e[13];
assign pad_gpio_port0_i[14] = pad_gpio_port0_o[14] & pad_gpio_port0_e[14];
assign pad_gpio_port0_i[15] = pad_gpio_port0_o[15] & pad_gpio_port0_e[15];

assign pad_gpio_port1_i[8] = pad_gpio_port1_o[8] & pad_gpio_port1_e[8];
assign pad_gpio_port1_i[9] = pad_gpio_port1_o[9] & pad_gpio_port1_e[9];
assign pad_gpio_port1_i[10] = pad_gpio_port1_o[10] & pad_gpio_port1_e[10];
assign pad_gpio_port1_i[11] = pad_gpio_port1_o[11] & pad_gpio_port1_e[11];
assign pad_gpio_port1_i[12] = pad_gpio_port1_o[12] & pad_gpio_port1_e[12];
assign pad_gpio_port1_i[13] = pad_gpio_port1_o[13] & pad_gpio_port1_e[13];
assign pad_gpio_port1_i[14] = pad_gpio_port1_o[14] & pad_gpio_port1_e[14];
assign pad_gpio_port1_i[15] = pad_gpio_port1_o[15] & pad_gpio_port1_e[15];

endmodule



