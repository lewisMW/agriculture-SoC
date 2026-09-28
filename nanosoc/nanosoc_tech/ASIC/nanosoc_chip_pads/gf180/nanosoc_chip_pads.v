//-----------------------------------------------------------------------------
// Top-Level Pad implementation for GF180
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright � 2021-5, SoC Labs (www.soclabs.org)
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

gf180mcu_fd_io__dvdd uPAD_VDDIO_0(
   );
gf180mcu_fd_io__dvdd uPAD_VDDIO_2(
   );
gf180mcu_fd_io__dvdd uPAD_VDDIO_3(
   );

gf180mcu_fd_io__dvss uPAD_VSSIO_0(
   );
gf180mcu_fd_io__dvss uPAD_VSSIO_1(
   );

// Core power supplies

gf180mcu_fd_io__dvdd uPAD_VDD_0(
   );
gf180mcu_fd_io__dvdd uPAD_VDD_1(
   );
gf180mcu_fd_io__dvdd uPAD_VDD_2(
   );
gf180mcu_fd_io__dvdd uPAD_VDD_3(
   );

gf180mcu_fd_io__dvss uPAD_VSS_0(
   );
gf180mcu_fd_io__dvss uPAD_VSS_1(
   );
gf180mcu_fd_io__dvss uPAD_VSS_2(
   );
gf180mcu_fd_io__dvss uPAD_VSS_3(
   );
// Accelerator Power supplies
// Not sure yet in GF180 how to supply seperate domains
gf180mcu_fd_io__asig_5p0 uPAD_VDDACC_0(
);

gf180mcu_fd_io__asig_5p0 uPAD_VDDACC_1(
);

gf180mcu_fd_io__asig_5p0 uPAD_VDDACC_2(
);

// Clock, Reset and Serial Wire Debug ports

gf180mcu_fd_io__in_s uPAD_SE_I (
    .PD(tiehi),
    .PU(tielo),
    .PAD(SE),
    .Y(pad_se_i)
   );


gf180mcu_fd_io__in_c uPAD_CLK_I (
   .PU(tielo),
   .PD(tielo),
   .Y(pad_clk_i),
   .PAD(CLK)
   );

gf180mcu_fd_io__in_s uPAD_TEST_I (
    .PU(tielo),
    .PD(tiehi),
    .Y(pad_test_i),
    .PAD(TEST)
   );

gf180mcu_fd_io__in_s uPAD_NRST_I (
    .PU(tiehi),
    .PD(tielo),
    .Y(pad_nrst_i),
    .PAD(NRST)
   );

gf180mcu_fd_io__bi_t uPAD_SWDIO_IO (
   .CS(tiehi),
   .SL(tielo),
   .IE(pad_swdio_z),
   .OE(pad_swdio_e),
   .PU(tielo),
   .PD(tielo),
   .A(pad_swdio_o),
   .PDRV0(tiehi),
   .PDRV1(tiehi),
   .PAD(SWDIO),
   .Y(pad_swdio_i)
   );

gf180mcu_fd_io__in_c uPAD_SWDCK_I (
   .PU(tielo),
   .PD(tielo),
   .Y(pad_swdclk_i),
   .PAD(SWDCK)
   );

// GPI.I Port 0 x 16

gf180mcu_fd_io__bi_t  uPAD_P0_00 (
   .IE(pad_gpio_port0_z[00]),
   .Y(pad_gpio_port0_i[00]),
   .PD(pad_gpio_port0_z[00]&pad_gpio_port0_o[00]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[00]),
   .OE(pad_gpio_port0_e[00]),
   .PAD(P0[00])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_01 (
   .IE(pad_gpio_port0_z[01]),
   .Y(pad_gpio_port0_i[01]),
   .PD(pad_gpio_port0_z[01]&pad_gpio_port0_o[01]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[01]),
   .OE(pad_gpio_port0_e[01]),
   .PAD(P0[01])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_02 (
   .IE(pad_gpio_port0_z[02]),
   .Y(pad_gpio_port0_i[02]),
   .PD(pad_gpio_port0_z[02]&pad_gpio_port0_o[02]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[02]),
   .OE(pad_gpio_port0_e[02]),
   .PAD(P0[02])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_03 (
   .IE(pad_gpio_port0_z[03]),
   .Y(pad_gpio_port0_i[03]),
   .PD(pad_gpio_port0_z[03]&pad_gpio_port0_o[03]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[03]),
   .OE(pad_gpio_port0_e[03]),
   .PAD(P0[03])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_04 (
   .IE(pad_gpio_port0_z[04]),
   .Y(pad_gpio_port0_i[04]),
   .PD(pad_gpio_port0_z[04]&pad_gpio_port0_o[04]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[04]),
   .OE(pad_gpio_port0_e[04]),
   .PAD(P0[04])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_05 (
   .IE(pad_gpio_port0_z[05]),
   .Y(pad_gpio_port0_i[05]),
   .PD(pad_gpio_port0_z[05]&pad_gpio_port0_o[05]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[05]),
   .OE(pad_gpio_port0_e[05]),
   .PAD(P0[05])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_06 (
   .IE(pad_gpio_port0_z[06]),
   .Y(pad_gpio_port0_i[06]),
   .PD(pad_gpio_port0_z[06]&pad_gpio_port0_o[06]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[06]),
   .OE(pad_gpio_port0_e[06]),
   .PAD(P0[06])
   );

gf180mcu_fd_io__bi_t  uPAD_P0_07 (
   .IE(pad_gpio_port0_z[07]),
   .Y(pad_gpio_port0_i[07]),
   .PD(pad_gpio_port0_z[07]&pad_gpio_port0_o[07]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port0_o[07]),
   .OE(pad_gpio_port0_e[07]),
   .PAD(P0[07])
   );

// GPI.I Port 1 x 16

gf180mcu_fd_io__bi_t  uPAD_P1_00 (
   .IE(pad_gpio_port1_z[00]),
   .Y(pad_gpio_port1_i[00]),
   .PD(pad_gpio_port1_z[00]&pad_gpio_port1_o[00]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[00]),
   .OE(pad_gpio_port1_e[00]),
   .PAD(P1[00])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_01 (
   .IE(pad_gpio_port1_z[01]),
   .Y(pad_gpio_port1_i[01]),
   .PD(pad_gpio_port1_z[01]&pad_gpio_port1_o[01]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[01]),
   .OE(pad_gpio_port1_e[01]),
   .PAD(P1[01])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_02 (
   .IE(pad_gpio_port1_z[02]),
   .Y(pad_gpio_port1_i[02]),
   .PD(pad_gpio_port1_z[02]&pad_gpio_port1_o[02]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[02]),
   .OE(pad_gpio_port1_e[02]),
   .PAD(P1[02])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_03 (
   .IE(pad_gpio_port1_z[03]),
   .Y(pad_gpio_port1_i[03]),
   .PD(pad_gpio_port1_z[03]&pad_gpio_port1_o[03]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[03]),
   .OE(pad_gpio_port1_e[03]),
   .PAD(P1[03])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_04 (
   .IE(pad_gpio_port1_z[04]),
   .Y(pad_gpio_port1_i[04]),
   .PD(pad_gpio_port1_z[04]&pad_gpio_port1_o[04]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[04]),
   .OE(pad_gpio_port1_e[04]),
   .PAD(P1[04])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_05 (
   .IE(pad_gpio_port1_z[05]),
   .Y(pad_gpio_port1_i[05]),
   .PD(pad_gpio_port1_z[05]&pad_gpio_port1_o[05]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[05]),
   .OE(pad_gpio_port1_e[05]),
   .PAD(P1[05])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_06 (
   .IE(pad_gpio_port1_z[06]),
   .Y(pad_gpio_port1_i[06]),
   .PD(pad_gpio_port1_z[06]&pad_gpio_port1_o[06]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[06]),
   .OE(pad_gpio_port1_e[06]),
   .PAD(P1[06])
   );

gf180mcu_fd_io__bi_t  uPAD_P1_07 (
   .IE(pad_gpio_port1_z[07]),
   .Y(pad_gpio_port1_i[07]),
   .PD(pad_gpio_port1_z[07]&pad_gpio_port1_o[07]),
   .PU(tielo),
   .PDRV0(tielo),
   .PDRV1(tielo),
   .CS(tiehi),
   .SL(tielo),
   .A(pad_gpio_port1_o[07]),
   .OE(pad_gpio_port1_e[07]),
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



