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
  //----------------------------------
  // package pins
  //----------------------------------
  // corresponds to # of pad cells instantiated, see below
  inout  wire          VCCD_PAD,
  inout  wire          VCCD_PAD1,
  inout  wire          VCCD_PAD2,
  inout  wire          VSSD_PAD,
  inout  wire          VSSD_PAD1,
  inout  wire          VSSD_PAD2,

  inout  wire          VDDIO_PAD,
  inout  wire          VDDIO_PAD1,
  inout  wire          VSSIO_PAD,
  inout  wire          VSSIO_PAD1,
  inout  wire          VDDIO_Q_PAD,
  inout  wire          VDDIO_Q_PAD1,
  inout  wire          VSSIO_Q_PAD,
  inout  wire          VSSIO_Q_PAD1,

  inout  wire          VDDA_PAD,
  inout  wire          VDDA_PAD1,
  inout  wire          VDDA_PAD2,
  inout  wire          VSSA_PAD,
  inout  wire          VSSA_PAD1,
  inout  wire          VSSA_PAD2,

  //----------------------------------
  // power wires
  //----------------------------------
  // main digital supply
  inout  wire          VDD,
  inout  wire          VSS,
  // main io supply
  inout  wire          VDDIO,
  inout  wire          VSSIO,
  // quiet io supply
  inout  wire          VDDIO_Q,
  inout  wire          VSSIO_Q,
  // analog supply
  inout  wire          VDDA,
  inout  wire          VSSA,
  // auxillary supplies
  inout  wire          VSWITCH,
  inout  wire          VCCHIB,

  input  wire          SE,
  input  wire          CLK, // input
  input  wire          TEST, // input
  input  wire          NRST,  // active low reset
  inout  wire  [15:0]  P0,
  inout  wire  [15:0]  P1,
  inout  wire          SWDIO,
  input  wire          SWDCK);

//------------------------------------
// io wires
// POR for the IO ring. This is less than a system reset, but rather
// a reset to setup the IO cells to a correct state.
// TODO wire this up correctly
wire        por_h_io; 

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
 // IOs
 // --------------------------------------------------------------------------------

 // power supplies
 // receive external power from their pads (<net>_PAD)
 // and allows it to be used on power ring.

`define BASE_IO_POWER_PINS \
   .VCCD(VDD), \
   .VSSD(VSS), \
   .VDDA(VDDA), \
   .VSSA(VSSA), \
   .VCCHIB(VCCHIB), \
   .VSWITCH(VSWITCH), 

`define POWER_PINS_VIO_STD \
   .VDDIO(VDDIO), \
   .VSSIO(VSSIO), \
   .VDDIO_Q(VDDIO_Q), \
   .VSSIO_Q(VSSIO_Q), \
   `BASE_IO_POWER_PINS

`define POWER_PINS_VIO_VDDIO_Q \
   .VDDIO(VDDIO_Q), \
   .VSSIO(VSSIO), \
   .VDDIO_Q(VDDIO_Q), \
   .VSSIO_Q(VSSIO_Q), \
   `BASE_IO_POWER_PINS

`define POWER_PINS_VIO_VSSIO_Q \
   .VDDIO(VDDIO), \
   .VSSIO(VSSIO_Q), \
   .VDDIO_Q(VDDIO_Q), \
   .VSSIO_Q(VSSIO_Q), \
   `BASE_IO_POWER_PINS

// Core power supplies
sky130_ef_io__vccd_lvc_clamped_pad uPAD_VDD_0(
   `POWER_PINS_VIO_STD
   .VCCD_PAD(VCCD_PAD)
   );
sky130_ef_io__vccd_lvc_clamped_pad uPAD_VDD_1(
   `POWER_PINS_VIO_STD
   .VCCD_PAD(VCCD_PAD1)
   );
sky130_ef_io__vccd_lvc_clamped_pad uPAD_VDD_2(
   `POWER_PINS_VIO_STD
   .VCCD_PAD(VCCD_PAD2)
   );
sky130_ef_io__vssd_lvc_clamped_pad uPAD_VSS_0(
   `POWER_PINS_VIO_STD
   .VSSD_PAD(VSSD_PAD)
   );
sky130_ef_io__vssd_lvc_clamped_pad uPAD_VSS_1(
   `POWER_PINS_VIO_STD
   .VSSD_PAD(VSSD_PAD1)
   );
sky130_ef_io__vssd_lvc_clamped_pad uPAD_VSS_2(
   `POWER_PINS_VIO_STD
   .VSSD_PAD(VSSD_PAD2)
   );

// Pad IO power supplies
sky130_ef_io__vddio_hvc_clamped_pad uPAD_VDDIO_0(
   `POWER_PINS_VIO_STD
   .VDDIO_PAD(VDDIO_PAD)
   );
sky130_ef_io__vddio_hvc_clamped_pad uPAD_VDDIO_1(
   `POWER_PINS_VIO_STD
   .VDDIO_PAD(VDDIO_PAD1)
   );
sky130_ef_io__vssio_hvc_clamped_pad uPAD_VSSIO_0(
   `POWER_PINS_VIO_STD
   .VSSIO_PAD(VSSIO_PAD)
   );
sky130_ef_io__vssio_hvc_clamped_pad uPAD_VSSIO_1(
   `POWER_PINS_VIO_STD
   .VSSIO_PAD(VSSIO_PAD1)
   );

// Pad IO quiet power supplies
// need to make sure their power pin is connected to <power>_Q
// when specifying power
sky130_ef_io__vddio_hvc_clamped_pad uPAD_VDDIOQ_0(
   `POWER_PINS_VIO_VDDIO_Q
   .VDDIO_PAD(VDDIO_Q_PAD)
   );
sky130_ef_io__vddio_hvc_clamped_pad uPAD_VDDIOQ_1(
   `POWER_PINS_VIO_VDDIO_Q
   .VDDIO_PAD(VDDIO_Q_PAD1)
   );
sky130_ef_io__vssio_hvc_clamped_pad uPAD_VSSIOQ_0(
   `POWER_PINS_VIO_VSSIO_Q
   .VSSIO_PAD(VSSIO_Q_PAD)
   );
sky130_ef_io__vssio_hvc_clamped_pad uPAD_VSSIOQ_1(
   `POWER_PINS_VIO_VSSIO_Q
   .VSSIO_PAD(VSSIO_Q_PAD1)
   );

// Analog power supplies
sky130_ef_io__vdda_hvc_clamped_pad uPAD_VDDA_0(
   `POWER_PINS_VIO_STD
   .VDDA_PAD(VDDA_PAD)
   );
sky130_ef_io__vdda_hvc_clamped_pad uPAD_VDDA_1(
   `POWER_PINS_VIO_STD
   .VDDA_PAD(VDDA_PAD1)
   );
sky130_ef_io__vdda_hvc_clamped_pad uPAD_VDDA_2(
   `POWER_PINS_VIO_STD
   .VDDA_PAD(VDDA_PAD2)
   );
sky130_ef_io__vssa_hvc_clamped_pad uPAD_VSSA_0(
   `POWER_PINS_VIO_STD
   .VSSA_PAD(VSSA_PAD)
   );
sky130_ef_io__vssa_hvc_clamped_pad uPAD_VSSA_1(
   `POWER_PINS_VIO_STD
   .VSSA_PAD(VSSA_PAD1)
   );
sky130_ef_io__vssa_hvc_clamped_pad uPAD_VSSA_2(
   `POWER_PINS_VIO_STD
   .VSSA_PAD(VSSA_PAD2)
   );

// Clock, Reset and Serial Wire Debug ports

sky130_ef_io__gpiov2_pad_wrapped uPAD_SE_I (
    `POWER_PINS_VIO_STD
    .INP_DIS(~tiehi),
    .IN(pad_se_i),
    .OUT(tielo),
    .OE_N(tiehi),
    .PAD(SE)
   );


sky130_ef_io__gpiov2_pad_wrapped uPAD_CLK_I (
    `POWER_PINS_VIO_STD
    .INP_DIS(~tiehi),
    .IN(pad_clk_i),
    .OUT(tielo),
    .OE_N(tiehi),
    .PAD(CLK)
   );

sky130_ef_io__gpiov2_pad_wrapped uPAD_TEST_I (
    `POWER_PINS_VIO_STD
    .INP_DIS(~tiehi),
    .IN(pad_test_i),
    .OUT(tielo),
    .OE_N(tiehi),
    .PAD(TEST)
   );

// connection diagram refer to 
// https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_io/docs/user_guide.html#use-case-for-the-xres-cells
// doc above is confusing. below taken from (slightly modified)
// https://github.com/efabless/caravel/blob/27cbe49c90ba5362ad52c9968dd98e035c30c74f/verilog/rtl/chip_io.v#L308
wire nrst_tie_lo_esd;
wire nrst_weak_pullup;
wire pad_nrst_io; // this is in the VDDIO domain but level shifters should be auto added (hopefully)
sky130_fd_io__top_xres4v2 uPAD_NRST_I (
   `POWER_PINS_VIO_STD
   .PAD(NRST),
   .TIE_WEAK_HI_H(nrst_weak_pullup), // Loop-back connection to pad through pad_a_esd_h
   .TIE_HI_ESD(),
   .TIE_LO_ESD(nrst_tie_lo_esd),
   .PAD_A_ESD_H(nrst_weak_pullup),
   .XRES_H_N(pad_nrst_io), 
   .DISABLE_PULLUP_H(nrst_tie_lo_esd), // 0 = enable pull-up on reset pad
   .EN_VDDIO_SIG_H(nrst_tie_lo_esd),  // No idea.
   .INP_SEL_H(nrst_tie_lo_esd), // 1 = use filt_in_h else filter the pad input
   .FILT_IN_H(nrst_tie_lo_esd), // Alternate input for glitch filter
   .PULLUP_H(nrst_tie_lo_esd), // Pullup connection for alternate filter input
   // it's done like this in caravel but is it actually correct?
   // TODO the skew between enable_h and enable_vddio is not respected?
   // is that a problem?
   .ENABLE_H(por_h_io), // Power-on-reset
   // TODO I don't think this is right.
   // enable_vddio: This qualifier lets the sky130_fd_io__gpio know that VDDIO is either present (1) or absent (0) in VCCHIB domain.
   // but VDDIO is not in the VCCHIB domain???
   .ENABLE_VDDIO(1'b1), // it's done like this in caravel
   .AMUXBUS_A(), .AMUXBUS_B()
);
// as above, pad_nrst_i should be in VDD domain
assign pad_nrst_i = pad_nrst_io;

// scan pins. TODO I might need to set them up differently??
sky130_ef_io__gpiov2_pad_wrapped uPAD_SWDIO_IO (
    `POWER_PINS_VIO_STD
    .INP_DIS(~pad_swdio_z),
    .IN(pad_swdio_i),
    .OUT(pad_swdio_o),
    .OE_N(pad_swdio_z),
    .PAD(SWDIO)
   );

sky130_ef_io__gpiov2_pad_wrapped uPAD_SWDCK_I (
    `POWER_PINS_VIO_STD
    .INP_DIS(~tiehi),
    .IN(pad_swdclk_i),
    .OUT(tielo),
    .OE_N(tiehi),
    .PAD(SWDCK)
   );

// GPI.I Port 0 x 16
`define DIGITAL_IO_PIN(PORT, IDX) \
\
wire gpio_``PORT``_``IDX``_tie_hi_esd; \
wire gpio_``PORT``_``IDX``_tie_lo_esd; \
\
sky130_ef_io__gpiov2_pad_wrapped uPAD_P``PORT``_``IDX ( \
   `POWER_PINS_VIO_STD \
   // functional pins \
   .INP_DIS(~pad_gpio_port``PORT``_z[IDX]), \
   .IN(pad_gpio_port``PORT``_i[IDX]), \
   .IN_H(), // non level shifted input to SOC, don't need \
   .OUT(pad_gpio_port``PORT``_o[IDX]), \
   .OE_N(pad_gpio_port``PORT``_z[IDX]), \
   .PAD(P``PORT[IDX]), \
   .ANALOG_EN(), \
   .ANALOG_SEL(), \
   // other pins \
   .TIE_HI_ESD(gpio_``PORT``_``IDX``_tie_hi_esd), \
   .TIE_LO_ESD(gpio_``PORT``_``IDX``_tie_lo_esd), \
   .ENABLE_INP_H(gpio_``PORT``_``IDX``_tie_hi_esd), // enable cell during reset \
   .DM(3'b110), // strong 1 and 0 \
   // use CMOS input buffer (VDDIO CMOS) \
   .VTRIP_SEL(1'b0), // use CMOS \
   .IB_MODE_SEL(1'b0), // use VDDIO \
   .ANALOG_POL(), \
   // enables, disables for the chip \
   // resets: \
   .ENABLE_H(por_h_io), // for input (vddio domain, just the io cells?) \
   .ENABLE_VDDA_H(por_h_io),// for analog domains \
   // technically resets??? \
   .ENABLE_VSWITCH_H(gpio_``PORT``_``IDX``_tie_hi_esd), // in design VSWITCH is there but connected to VDDIO. TODO check this \
   // TODO like for the reset cell - I have no idea if this is correct. \
   // What does "in VCCHIB domain" mean here? \
   // I think it's saying the signal should be given in VCCHIB (VCCD) domain \
   .ENABLE_VDDIO(por_h_io), // TODO see the reset cell connection, should there be the slew thing? \
   .HLD_H_N(gpio_``PORT``_``IDX``_tie_hi_esd), // hold state control, 1 to use as default \
   .HLD_OVR(1'b0), // actually freeze value, ignored with hld_h_n is 1 \
   .SLOW(1'b0) // default slew rate \
)

`DIGITAL_IO_PIN(0, 00);
`DIGITAL_IO_PIN(0, 01);
`DIGITAL_IO_PIN(0, 02);
`DIGITAL_IO_PIN(0, 03);
`DIGITAL_IO_PIN(0, 04);
`DIGITAL_IO_PIN(0, 05);
`DIGITAL_IO_PIN(0, 06);
`DIGITAL_IO_PIN(0, 07);
`DIGITAL_IO_PIN(0, 08);
`DIGITAL_IO_PIN(0, 09);
`DIGITAL_IO_PIN(0, 10);
`DIGITAL_IO_PIN(0, 11);
`DIGITAL_IO_PIN(0, 12);
`DIGITAL_IO_PIN(0, 13);
`DIGITAL_IO_PIN(0, 14);
`DIGITAL_IO_PIN(0, 15);

`DIGITAL_IO_PIN(1, 00);
`DIGITAL_IO_PIN(1, 01);
`DIGITAL_IO_PIN(1, 02);
`DIGITAL_IO_PIN(1, 03);
`DIGITAL_IO_PIN(1, 04);
`DIGITAL_IO_PIN(1, 05);
`DIGITAL_IO_PIN(1, 06);
`DIGITAL_IO_PIN(1, 07);
`DIGITAL_IO_PIN(1, 08);
`DIGITAL_IO_PIN(1, 09);
`DIGITAL_IO_PIN(1, 10);
`DIGITAL_IO_PIN(1, 11);
`DIGITAL_IO_PIN(1, 12);
`DIGITAL_IO_PIN(1, 13);
`DIGITAL_IO_PIN(1, 14);
`DIGITAL_IO_PIN(1, 15);

endmodule



