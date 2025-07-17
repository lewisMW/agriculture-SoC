//-----------------------------------------------------------------------------
// NanoSoC Testbench adpated from example Cortex-M0 controller testbench
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
// Abstract : Testbench for the Cortex-M0 example system
//-----------------------------------------------------------------------------
//
`timescale 1ns/1ps
`include "gen_defines.v"

module nanosoc_tb;

  wire        CLK;   // crystal pin 1
  wire        TEST;  // 0 for system usaged
  wire        NRST;    // active low reset
  wire        NRST_early;  // active low reset
  wire        NRST_late;   // active low reset
  wire        NRST_ext;    // active low reset

  wire [15:0] P0;      // Port 0
  wire [15:0] P1;      // Port 1

  wire        VDDIO;
  wire        VSSIO;
  wire        VDD;
  wire        VSS;
  wire        VDDACC;
  
  //Debug tester signals
  wire        nTRST;
  wire        TDI;
  wire        SWDIOTMS;
  wire        SWCLKTCK;
  wire        TDO;

  wire        PCLK;          // Clock for UART capture device
  wire [5:0]  debug_command; // used to drive debug tester
  wire        debug_running; // indicate debug test is running
  wire        debug_err;     // indicate debug test has error

  wire        debug_test_en1; // UART2 output trace (CMSDK)
  wire        debug_test_en2; // FT1248 output trace (nanosoc V1)
  wire        debug_test_en3; // EXTIO output trace (nanosoc V2)
  wire        debug_test_en; // To enable the debug tester connection to MCU GPIO P0
                             // This signal is controlled by software,
                             // Use "UartPutc((char) 0x1B)" to send ESCAPE code to start
                             // the command, use "UartPutc((char) 0x11)" to send debug test
                             // enable command, use "UartPutc((char) 0x12)" to send debug test
                             // disable command. Refer to tb_uart_capture.v file for detail
  assign debug_test_en = debug_test_en1 | debug_test_en2 | debug_test_en3; // UART2, FT1248 or EXTIO

  //-----------------------------------------
  // System options

`define MEM_INIT 1;
localparam BE=0;
`define ARM_CMSDK_INCLUDE_DEBUG_TESTER 1

`ifdef ADP_FILE
  localparam ADP_FILENAME=`ADP_FILE;
`else
  localparam ADP_FILENAME="adp.cmd";
`endif

localparam DATA_IN_FILENAME="data_in.csv";
localparam DATA_OUT_FILENAME="logs/data_out.csv";

/*
SROM_Ax32
  #(.ADDRWIDTH (8),
    .filename ("bootrom/hex/bootloader.hex"),
    .romgen (1)
   )
   u_BOOTROM (
    .CLK(CLK),
    .ADDR(8'h0),
    .SEL(1'b0),
    .RDATA( )
  );
*/

`ifdef SDF_SIM
initial
  $sdf_annotate ( "../../../src/rtl/nanosoc_chip_pads_44pin.sdf"
                 , u_nanosoc_chip_pads
                 ,
                 , "sdf_annotate.log"
                 , "MAXIMUM"
                 );
`endif // SDF_SIM

`ifdef VCD_SIM
initial begin
  $dumpfile("waves.vcd");
  $dumpvars(6,u_nanosoc_chip_pads);
  end
`endif // VCD_SIM

 // --------------------------------------------------------------------------------
 // Cortex-M0/Cortex-M0+ Microcontroller
 // --------------------------------------------------------------------------------

`ifdef SDF_SIM
  nanosoc_chip_pads
   u_nanosoc_chip_pads (
`ifdef POWER_PINS
  .VDDIO      (VDDIO),
  .VSSIO      (VSSIO),
  .VDD        (VDD),
  .VSS        (VSS),
  .VDDACC     (VDDACC),
`endif
  .SE         (1'b0),
  .CLK        (CLK),  // input
  .TEST       (TEST),  // input
  .NRST       (NRST),   // active low reset
  .P0         (P0[7:0]),
  .P1         (P1[7:0]),
  .SWDIO      (SWDIOTMS),
  .SWDCK      (SWCLKTCK)
  );
`else
  nanosoc_chip_pads
   u_nanosoc_chip_pads (
`ifdef POWER_PINS
  .VDDIO      (VDDIO),
  .VSSIO      (VSSIO),
  .VDD        (VDD),
  .VSS        (VSS),
  .VDDACC     (VDDACC),
`endif
  .SE         (1'b0),
  .CLK        (CLK),  // input
  .TEST       (TEST),  // input
  .NRST       (NRST),   // active low reset
  .P0         (P0[15:0]),
  .P1         (P1[15:0]),
  .SWDIO      (SWDIOTMS),
  .SWDCK      (SWCLKTCK)
  );
`endif
 // --------------------------------------------------------------------------------
 // Source for clock and reset
 // --------------------------------------------------------------------------------
 `ifndef COCOTB_SIM
  nanosoc_clkreset u_nanosoc_clkreset(
  .CLK       (CLK),
  .NRST      (NRST),
  .NRST_early(NRST_early),
  .NRST_late (NRST_late),
  .NRST_ext  (NRST_ext )
  );
  `endif

  assign TEST = 1'b0;
  
  // Pullup to suppress X-inputs
  pullup(P0[ 0]);
  pullup(P0[ 1]);
  pullup(P0[ 2]);
  pullup(P0[ 3]);
  pullup(P0[ 4]);
  pullup(P0[ 5]);
  pullup(P0[ 6]);
  pullup(P0[ 7]);
  pullup(P0[ 8]);
  pullup(P0[ 9]);
  pullup(P0[10]);
  pullup(P0[11]);
  pullup(P0[12]);
  pullup(P0[13]);
  pullup(P0[14]);
  pullup(P0[15]);

  pullup(P1[ 0]);
  pullup(P1[ 1]);
  pullup(P1[ 2]);
  pullup(P1[ 3]);
  pullup(P1[ 4]);
  pullup(P1[ 5]);
  pullup(P1[ 6]);
//  pullup(P1[ 7]); // FT1248 mode
  pulldown(P1[ 7]); // EXTIO mode
  pullup(P1[ 8]);
  pullup(P1[ 9]);
  pullup(P1[10]);
  pullup(P1[11]);
  pullup(P1[12]);
  pullup(P1[13]);
  pullup(P1[14]);
  pullup(P1[15]);

`ifdef FAST_SIM
  parameter FAST_LOAD = 1;
`else
  parameter FAST_LOAD = 0;
`endif

 // --------------------------------------------------------------------------------
 // EXTIO8x4 stream interface - enabled when P1[7] is low
 //   default in previous testbenches was pullup (for FT1248, UART2)
 //
 //          v1 mapping was:    v2 config
 //   P1[0] - ft_miso_in        ioreq1
 //   P1[1] - ft_clk_out        ioreq2
 //   P1[2] - ft_miosio_io      ioack
 //   P1[3] - ft_ssn_out        iodata[0]
 //   P1[4] - uart2_rxd         iodata[1]
 //   P1[5] - uart2_txd         iodata[2]
 //   P1[6] - reserved (1)      iodata[3]
 //   P1[7] - reserved (1)      zero
 // --------------------------------------------------------------------------------

// 4-channel AXIS interface - Subordinate side
  wire       axis_rx0_tready; 
  wire       axis_rx0_tvalid;
  wire [7:0] axis_rx0_tdata8;
  wire       axis_rx1_tready; 
  wire       axis_rx1_tvalid;
  wire [7:0] axis_rx1_tdata8;
  wire       axis_tx0_tready; 
  wire       axis_tx0_tvalid;
  wire [7:0] axis_tx0_tdata8;
  wire       axis_tx1_tready; 
  wire       axis_tx1_tvalid;
  wire [7:0] axis_tx1_tdata8;
// external io interface
  tri  [3:0] iodata4;
  wire [3:0] iodata4_i;
  wire [3:0] iodata4_o;
  wire [3:0] iodata4_e;
  wire [3:0] iodata4_t;
  wire       ioreq1;
  wire       ioreq2;
  wire       ioack;

wire test_done;

wire FT1248MODE = P1[7];
wire end_sim = test_done & !FT1248MODE & !ioreq1 & !ioreq2 & !ioack;
  always @(posedge PCLK)
    if (end_sim) begin
      $stop;
    end

extio8x4_axis_target u_extio8x4_axis_target
  (
  .clk             ( CLK             ),
  .resetn          ( NRST            ),
  .testmode        ( TEST            ),
// RX 4-channel AXIS interface
  .axis_rx0_tready ( axis_rx0_tready ),
  .axis_rx0_tvalid ( axis_rx0_tvalid ),
  .axis_rx0_tdata8 ( axis_rx0_tdata8 ),
  .axis_rx1_tready ( axis_rx1_tready ),
  .axis_rx1_tvalid ( axis_rx1_tvalid ),
  .axis_rx1_tdata8 ( axis_rx1_tdata8 ),
  .axis_tx0_tready ( axis_tx0_tready ),
  .axis_tx0_tvalid ( axis_tx0_tvalid ),
  .axis_tx0_tdata8 ( axis_tx0_tdata8 ),
  .axis_tx1_tready ( axis_tx1_tready ),
  .axis_tx1_tvalid ( axis_tx1_tvalid ),
  .axis_tx1_tdata8 ( axis_tx1_tdata8 ),
// external io interface
  .iodata4_i       ( iodata4_i       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_a        ( ioreq1          ),
  .ioreq2_a        ( ioreq2          ),
  .ioack_o         ( ioack           )
  );

// tristate buffer emulation
   assign ioreq1    = FT1248MODE ? 1'b0 : P1[0];
   assign ioreq2    = FT1248MODE ? 1'b0 : P1[1];
   bufif0 #1 (P1[2], ioack,        FT1248MODE);
   bufif0 #1 (P1[3], iodata4_o[0], (iodata4_t[0] | FT1248MODE));
   bufif0 #1 (P1[4], iodata4_o[1], (iodata4_t[1] | FT1248MODE));
   bufif0 #1 (P1[5], iodata4_o[2], (iodata4_t[2] | FT1248MODE));
   bufif0 #1 (P1[6], iodata4_o[3], (iodata4_t[3] | FT1248MODE));
   assign iodata4_i = {4{FT1248MODE}} | P1[6:3];

`ifndef COCOTB_SIM

  nanosoc_axi_stream_io_8_txd_from_file #(
    .TXDFILENAME(ADP_FILENAME),
//    .CODEFILENAME("null.hex"),
    .FAST_LOAD(FAST_LOAD)
  ) u_nanosoc_axi_stream_io_adp_txd_from_file (
    .aclk       (CLK),
    .aresetn    (NRST),
    .txd8_ready (axis_rx0_tready),
    .txd8_valid (axis_rx0_tvalid),
    .txd8_data  (axis_rx0_tdata8)
  );

`ifndef COCOTB_SIM
  nanosoc_axi_stream_io_8_rxd_to_file#(
    .RXDFILENAME("logs/extadp_in.log")
  ) u_nanosoc_axi_stream_io_8_adprxd_to_file (
    .aclk         (CLK),
    .aresetn      (NRST),
    .eof_received ( ),
    .rxd8_ready   ( ), //axis_rx0_tready),
    .rxd8_valid   (axis_rx0_tvalid & axis_rx0_tready),
    .rxd8_data    (axis_rx0_tdata8)
  );
`endif

  nanosoc_axi_stream_io_8_rxd_to_file#(
    .RXDFILENAME("logs/extadp_out.log"),
    .VERBOSE(0)
  ) u_nanosoc_axi_stream_io_stream_adp_rxd_to_file (
    .aclk         (CLK),
    .aresetn      (NRST),
    .eof_received (test_done),
    .rxd8_ready   (axis_tx0_tready),
    .rxd8_valid   (axis_tx0_tvalid),
    .rxd8_data    (axis_tx0_tdata8)
  );

  soclabs_axis8_capture  #(.LOGFILENAME("logs/extio_adp_out.log"))
    u_soclabs_axis8_capture1(
    .RESETn               (NRST),
    .CLK                  (CLK),
    .RXD8_READY   (    ),
    .RXD8_VALID   (axis_tx0_tvalid & axis_tx0_tready),
    .RXD8_DATA    (axis_tx0_tdata8),
    .DEBUG_TESTER_ENABLE  (debug_test_en3),
    .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
    .AUXCTRL              ()
  );

  nanosoc_axi_stream_io_8_txd_from_datafile #(
    .TXDFILENAME(DATA_IN_FILENAME)
  ) u_nanosoc_axi_stream_io_8_txd_from_datafile (
    .aclk       (CLK),
    .aresetn    (NRST),
    .txd8_ready (axis_rx1_tready),
    .txd8_valid (axis_rx1_tvalid),
    .txd8_data  (axis_rx1_tdata8)
  );



  nanosoc_axi_stream_io_8_rxd_to_file#(
    .RXDFILENAME(DATA_OUT_FILENAME)
  ) u_nanosoc_axi_stream_io_extdata_8_rxd_to_file (
    .aclk         (CLK),
    .aresetn      (NRST),
    .eof_received ( ),
    .rxd8_ready   (axis_tx1_tready),
    .rxd8_valid   (axis_tx1_tvalid),
    .rxd8_data    (axis_tx1_tdata8)
  );

`endif

 // --------------------------------------------------------------------------------
 // UART output capture
 // --------------------------------------------------------------------------------
`ifdef ARM_CMSDK_SLOWSPEED_PCLK
  // If PCLK is running at slower speed, the UART output will also be slower
  assign PCLK = u_cmsdk_mcu.u_cmsdk_mcu.PCLK;
`else
  assign PCLK = CLK;
`endif

 // --------------------------------------------------------------------------------
 // external UART phase lock to (known) baud rate

// seem unable to use the following (due to generate instance naming?)
//  wire baudx16_clk = u_cmsdk_mcu.u_cmsdk_mcu.u_cmsdk_mcu_system.u_apb_subsystem.u_apb_uart_2.BAUDTICK;

// 240000000/6250 = 38400 baud
// 6250/16 = 390.625
`define BAUDPROGDIV16 389

 reg [8:0] bauddiv;
 wire    baudclken = (bauddiv == 9'b0);

  always @(negedge NRST or posedge PCLK)
    if (!NRST)
      bauddiv <=0;
    else
      bauddiv <= (baudclken) ? (`BAUDPROGDIV16-1) : (bauddiv -1) ;   // count down of BAUDPROG

  wire baudx16_clk = bauddiv[8]; //prefer:// !baudclken;

///  wire UARTXD =  P1[5];
  wire UARTXD =  P1[5] | FT1248MODE; // high if in EXTIO mode
  reg  UARTXD_del;
  always @(negedge NRST or posedge baudx16_clk)
    if (!NRST)
      UARTXD_del <= 1'b0;
    else
      UARTXD_del <= UARTXD; // delay one BAUD_TICK-time

  wire UARTXD_edge = UARTXD_del ^ UARTXD; // edge detect

  reg [3:0] pllq;
  always @(negedge NRST or posedge baudx16_clk)
    if (!NRST)
      pllq[3:0] <= 4'b0000; // phase lock ready for Q[3] to go high
    else
      if (UARTXD_edge)
        pllq[3:0] <= 4'b0110; // sync to mid bit-time
      else
        pllq[3:0] <= pllq[3:0] - 1; // count down divide-by-16

  wire baud_clk = pllq[3];

reg baud_clk_del;
  always @(negedge NRST or posedge PCLK)
    if (!NRST)
      baud_clk_del <= 1'b1;
    else
      baud_clk_del <= baud_clk;

 // --------------------------------------------------------------------------------
 // set FASTMODE true if UART simulation mode is programmed
  wire FASTMODE = 1'b0;
  wire uart_clk = (FASTMODE) ? PCLK : baud_clk; //(baud_clk & !baud_clk_del);

`ifndef COCOTB_SIM
  nanosoc_uart_capture  #(.LOGFILENAME("logs/uart2.log"))
    u_nanosoc_uart_capture(
    .RESETn               (NRST),
    .CLK                  (uart_clk), //PCLK),
    .RXD                  (UARTXD), // UART 2 use for StdOut
    .DEBUG_TESTER_ENABLE  (debug_test_en1),
    .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
    .AUXCTRL              ()
  );
`endif

 // --------------------------------------------------------------------------------
 // FTDI IO capture
 // --------------------------------------------------------------------------------

  // UART connection
///  assign P1[4] = P1[5]; // loopback UART2

  bufif1 #1 (P1[4], P1[5], FT1248MODE);

///  wire ft_clk_out = P1[1];
///  wire ft_miso_in;
///  assign P1[0] = ft_miso_in;
///  wire ft_ssn_out = P1[3];

  wire ft_clk_out;
  wire ft_miso_in;
  wire ft_ssn_out;

  assign ft_clk_out = (FT1248MODE) ?  P1[1] : 1'b0;
  bufif1 #1 (P1[0], ft_miso_in, FT1248MODE);
  assign ft_ssn_out = (FT1248MODE) ?  P1[3] : 1'b1;

  wire ft_miosio_o;
  wire ft_miosio_z;
  wire ft_miosio_i;
///  assign ft_miosio_i  = P1[2]; // & ft_miosio_z;
///  assign P1[2] = (ft_miosio_z) ? 1'bz : ft_miosio_o;
  assign ft_miosio_i = (FT1248MODE) ? P1[2] : 1'b0; // & ft_miosio_z;
  bufif1 #1 (P1[2], ft_miosio_o, (FT1248MODE & !ft_miosio_z));


  //
  // AXI stream io testing
  //

  wire txd8_tready;
  wire txd8_tvalid;
  wire [7:0] txd8_tdata ;

  wire rxd8_tready;
  wire rxd8_tvalid;
  wire [7:0] rxd8_tdata ;

`ifndef COCOTB_SIM
  nanosoc_axi_stream_io_8_txd_from_file #(
    .TXDFILENAME(ADP_FILENAME),
//    .CODEFILENAME("null.hex"),
    .FAST_LOAD(FAST_LOAD)
  ) u_nanosoc_axi_stream_io_8_txd_from_file (
    .aclk       (CLK),
    .aresetn    (NRST),
    .txd8_ready (txd8_tready),
    .txd8_valid (txd8_tvalid),
    .txd8_data  (txd8_tdata)
  );
`endif

  nanosoc_ft1248x1_to_axi_streamio_v1_0 u_nanosoc_ft1248x1_to_axi_streamio_v1_0
  (
  .ft_clk_i     (ft_clk_out),
  .ft_ssn_i     (ft_ssn_out),
  .ft_miso_o    (ft_miso_in),
  .ft_miosio_i  (ft_miosio_i),
  .ft_miosio_o  (ft_miosio_o),
  .ft_miosio_z  (ft_miosio_z),
  .aclk         (CLK),
  .aresetn      (NRST),
  .rxd_tready_o (txd8_tready),
  .rxd_tvalid_i (txd8_tvalid),
  .rxd_tdata8_i (txd8_tdata),
  .txd_tready_i (rxd8_tready),
  .txd_tvalid_o (rxd8_tvalid),
  .txd_tdata8_o (rxd8_tdata)
  );

`ifndef COCOTB_SIM
  nanosoc_axi_stream_io_8_rxd_to_file#(
    .RXDFILENAME("logs/ft1248_out.log")
  ) u_nanosoc_axi_stream_io_8_rxd_to_file (
    .aclk         (CLK),
    .aresetn      (NRST),
    .eof_received ( ),
    .rxd8_ready   (rxd8_tready),
    .rxd8_valid   (rxd8_tvalid),
    .rxd8_data    (rxd8_tdata)
  );
`endif

nanosoc_track_tb_iostream
  u_nanosoc_track_tb_iostream
  (
  .aclk         (CLK),
  .aresetn      (NRST),
  .rxd8_ready   (rxd8_tready),
  .rxd8_valid   (rxd8_tvalid),
  .rxd8_data    (rxd8_tdata),
  .DEBUG_TESTER_ENABLE  (debug_test_en2),
  .AUXCTRL      ( ),
  .SIMULATIONEND( )
  );

wire ft_clk2uart;
wire ft_rxd2uart;
wire ft_txd2uart;

nanosoc_ft1248x1_track
  u_nanosoc_ft1248x1_track
  (
  .ft_clk_i     (ft_clk_out),
  .ft_ssn_i     (ft_ssn_out),
  .ft_miso_i    (ft_miso_in),
  .ft_miosio_i  (ft_miosio_i),
  .aclk         (CLK),
  .aresetn      (NRST),
  .FTDI_CLK2UART_o      (ft_clk2uart),  // Clock (baud rate)
  .FTDI_OP2UART_o       (ft_rxd2uart),  // Received data to UART capture
  .FTDI_IP2UART_o       (ft_txd2uart)   // Transmitted data to UART capture
  );

`ifndef COCOTB_SIM
  nanosoc_uart_capture  #(.LOGFILENAME("logs/ft1248_op.log"))
    u_nanosoc_uart_capture1(
    .RESETn               (NRST),
    .CLK                  (ft_clk2uart),
    .RXD                  (ft_rxd2uart),
    .DEBUG_TESTER_ENABLE  ( ), //debug_test_en2), //driven by u_nanosoc_track_tb_iostream
    .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
    .AUXCTRL              ()
  );
`endif

`ifndef COCOTB_SIM
// nanosoc_uart_capture  #(.LOGFILENAME("logs/ft1248_ip.log"))
//   u_nanosoc_uart_capture2(
//   .RESETn               (NRST),
//   .CLK                  (ft_clk2uart),
//   .RXD                  (ft_txd2uart),
//   .DEBUG_TESTER_ENABLE  ( ),
//   .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
//   .AUXCTRL              ()
// );
`endif

 // --------------------------------------------------------------------------------
 // Tracking CPU with Tarmac trace support
 // --------------------------------------------------------------------------------


`ifdef CORTEX_M0
`ifdef USE_TARMAC

`define ARM_CM0IK_PATH u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_cpu.u_cpu_0.u_slcorem0_integration.u_cortexm0

  CORTEXM0
     #(.ACG(1), .AHBSLV(0), .BE(0), .BKPT(4),
       .DBG(1), .NUMIRQ(32), .RAR(1), .SMUL(0),
       .SYST(1), .WIC(1), .WICLINES(34), .WPT(2))
       u_cortexm0_track
         (
          // Outputs
          .HADDR                          ( ),
          .HBURST                         ( ),
          .HMASTLOCK                      ( ),
          .HPROT                          ( ),
          .HSIZE                          ( ),
          .HTRANS                         ( ),
          .HWDATA                         ( ),
          .HWRITE                         ( ),
          .HMASTER                        ( ),
          .SLVRDATA                       ( ),
          .SLVREADY                       ( ),
          .SLVRESP                        ( ),
          .DBGRESTARTED                   ( ),
          .HALTED                         ( ),
          .TXEV                           ( ),
          .LOCKUP                         ( ),
          .SYSRESETREQ                    ( ),
          .CODENSEQ                       ( ),
          .CODEHINTDE                     ( ),
          .SPECHTRANS                     ( ),
          .SLEEPING                       ( ),
          .SLEEPDEEP                      ( ),
          .SLEEPHOLDACKn                  ( ),
          .WICDSACKn                      ( ),
          .WICMASKISR                     ( ),
          .WICMASKNMI                     ( ),
          .WICMASKRXEV                    ( ),
          .WICLOAD                        ( ),
          .WICCLEAR                       ( ),
          // Inputs
          .SCLK                           (`ARM_CM0IK_PATH.SCLK),
          .HCLK                           (`ARM_CM0IK_PATH.HCLK),
          .DCLK                           (`ARM_CM0IK_PATH.DCLK),
          .DBGRESETn                      (`ARM_CM0IK_PATH.DBGRESETn),
          .HRESETn                        (`ARM_CM0IK_PATH.HRESETn),
          .HRDATA                         (`ARM_CM0IK_PATH.HRDATA[31:0]),
          .HREADY                         (`ARM_CM0IK_PATH.HREADY),
          .HRESP                          (`ARM_CM0IK_PATH.HRESP),
          .SLVADDR                        (`ARM_CM0IK_PATH.SLVADDR[31:0]),
          .SLVSIZE                        (`ARM_CM0IK_PATH.SLVSIZE[1:0]),
          .SLVTRANS                       (`ARM_CM0IK_PATH.SLVTRANS[1:0]),
          .SLVWDATA                       (`ARM_CM0IK_PATH.SLVWDATA[31:0]),
          .SLVWRITE                       (`ARM_CM0IK_PATH.SLVWRITE),
          .DBGRESTART                     (`ARM_CM0IK_PATH.DBGRESTART),
          .EDBGRQ                         (`ARM_CM0IK_PATH.EDBGRQ),
          .NMI                            (`ARM_CM0IK_PATH.NMI),
          .IRQ                            (`ARM_CM0IK_PATH.IRQ[31:0]),
          .RXEV                           (`ARM_CM0IK_PATH.RXEV),
          .STCALIB                        (`ARM_CM0IK_PATH.STCALIB[25:0]),
          .STCLKEN                        (`ARM_CM0IK_PATH.STCLKEN),
          .IRQLATENCY                     (`ARM_CM0IK_PATH.IRQLATENCY[7:0]),
          .ECOREVNUM                      (`ARM_CM0IK_PATH.ECOREVNUM[19:0]),
          .SLEEPHOLDREQn                  (`ARM_CM0IK_PATH.SLEEPHOLDREQn),
          .WICDSREQn                      (`ARM_CM0IK_PATH.WICDSREQn),
          .SE                             (`ARM_CM0IK_PATH.SE));

`define ARM_CM0IK_TRACK u_cortexm0_track
  cm0_tarmac #(.LOGFILENAME("logs/tarmac0.log"))
    u_tarmac_track
      (.enable_i      (1'b1),

       .hclk_i        (`ARM_CM0IK_TRACK.HCLK),
       .hready_i      (`ARM_CM0IK_TRACK.HREADY),
       .haddr_i       (`ARM_CM0IK_TRACK.HADDR[31:0]),
       .hprot_i       (`ARM_CM0IK_TRACK.HPROT[3:0]),
       .hsize_i       (`ARM_CM0IK_TRACK.HSIZE[2:0]),
       .hwrite_i      (`ARM_CM0IK_TRACK.HWRITE),
       .htrans_i      (`ARM_CM0IK_TRACK.HTRANS[1:0]),
       .hresetn_i     (`ARM_CM0IK_TRACK.HRESETn),
       .hresp_i       (`ARM_CM0IK_TRACK.HRESP),
       .hrdata_i      (`ARM_CM0IK_TRACK.HRDATA[31:0]),
       .hwdata_i      (`ARM_CM0IK_TRACK.HWDATA[31:0]),
       .lockup_i      (`ARM_CM0IK_TRACK.LOCKUP),
       .halted_i      (`ARM_CM0IK_TRACK.HALTED),
       .codehintde_i  (`ARM_CM0IK_TRACK.CODEHINTDE[2:0]),
       .codenseq_i    (`ARM_CM0IK_TRACK.CODENSEQ),

       .hdf_req_i     (`ARM_CM0IK_TRACK.u_top.u_sys.ctl_hdf_request),
       .int_taken_i   (`ARM_CM0IK_TRACK.u_top.u_sys.dec_int_taken_o),
       .int_return_i  (`ARM_CM0IK_TRACK.u_top.u_sys.dec_int_return_o),
       .int_pend_i    (`ARM_CM0IK_TRACK.u_top.u_sys.nvm_int_pend),
       .pend_num_i    (`ARM_CM0IK_TRACK.u_top.u_sys.nvm_int_pend_num[5:0]),
       .ipsr_i        (`ARM_CM0IK_TRACK.u_top.u_sys.psr_ipsr[5:0]),

       .ex_last_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.ctl_ex_last),
       .iaex_en_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.ctl_iaex_en),
       .reg_waddr_i   (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.ctl_wr_addr[3:0]),
       .reg_write_i   (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.ctl_wr_en),
       .xpsr_en_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.ctl_xpsr_en),
       .fe_addr_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.pfu_fe_addr[30:0]),
       .int_delay_i   (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.pfu_int_delay),
       .special_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.pfu_op_special),
       .opcode_i      (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.pfu_opcode[15:0]),
       .reg_wdata_i   (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.psr_gpr_wdata[31:0]),

       .atomic_i      (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_ctl.atomic),
       .atomic_nxt_i  (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_ctl.atomic_nxt),
       .dabort_i      (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_ctl.data_abort),
       .ex_last_nxt_i (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_ctl.ex_last_nxt),
       .int_preempt_i (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_ctl.int_preempt),

       .psp_sel_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_gpr.psp_sel),
       .xpsr_i        (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_gpr.xpsr[31:0]),

       .iaex_i        (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_pfu.iaex[30:0]),
       .iaex_nxt_i    (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_pfu.iaex_nxt[30:0]),
       .opcode_nxt_i  (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_pfu.ibuf_de_nxt[15:0]),
       .delay_count_i (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_pfu.ibuf_lo[13:6]),
       .tbit_en_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_pfu.tbit_en),

       .cflag_en_i    (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_psr.cflag_ena),
       .ipsr_en_i     (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_psr.ipsr_ena),
       .nzflag_en_i   (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_psr.nzflag_ena),
       .vflag_en_i    (`ARM_CM0IK_TRACK.u_top.u_sys.u_core.u_psr.vflag_ena)
  );

`endif // USE_TARMAC
`endif // CORTEX_M0

 // --------------------------------------------------------------------------------
 // Tracking DMA logging support
 // - Track inputs to on-chip PL230 DMAC and replicate state and outputs in testbench
 // - log the RTL Inuts/outputs/internal-state of this traccking DMAC
 // --------------------------------------------------------------------------------
`ifdef DMAC_0_PL230
`define DMAC_PATH u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_dma.u_dmac_0.u_pl230_udma

  pl230_udma u_track_pl230_udma (
  // Clock and Reset
    .hclk          (`DMAC_PATH.hclk),
    .hresetn       (`DMAC_PATH.hresetn),
  // DMA Control
    .dma_req       (`DMAC_PATH.dma_req),
    .dma_sreq      (`DMAC_PATH.dma_sreq),
    .dma_waitonreq (`DMAC_PATH.dma_waitonreq),
    .dma_stall     (`DMAC_PATH.dma_stall),
    .dma_active    ( ),
    .dma_done      ( ),
    .dma_err       ( ),
  // AHB-Lite Master Interface
    .hready        (`DMAC_PATH.hready),
    .hresp         (`DMAC_PATH.hresp),
    .hrdata        (`DMAC_PATH.hrdata),
    .htrans        ( ),
    .hwrite        ( ),
    .haddr         ( ),
    .hsize         ( ),
    .hburst        ( ),
    .hmastlock     ( ),
    .hprot         ( ),
    .hwdata        ( ),
  // APB Slave Interface
    .pclken        (`DMAC_PATH.pclken),
    .psel          (`DMAC_PATH.psel),
    .pen           (`DMAC_PATH.pen),
    .pwrite        (`DMAC_PATH.pwrite),
    .paddr         (`DMAC_PATH.paddr),
    .pwdata        (`DMAC_PATH.pwdata),
    .prdata        ( )
  );

`define DMAC_TRACK_PATH u_track_pl230_udma

`ifndef COCOTB_SIM
  nanosoc_dma_log_to_file #(.FILENAME("logs/dma230.log"),.NUM_CHNLS(4),.NUM_CHNL_BITS(2),.TIMESTAMP(1))
    u_nanosoc_dma_log_to_file (
    .hclk          (`DMAC_TRACK_PATH.hclk),
    .hresetn       (`DMAC_TRACK_PATH.hresetn),
  // AHB-Lite Master Interface
    .hready        (`DMAC_TRACK_PATH.hready),
    .hresp         (`DMAC_TRACK_PATH.hresp),
    .hrdata        (`DMAC_TRACK_PATH.hrdata),
    .htrans        (`DMAC_TRACK_PATH.htrans),
    .hwrite        (`DMAC_TRACK_PATH.hwrite),
    .haddr         (`DMAC_TRACK_PATH.haddr),
    .hsize         (`DMAC_TRACK_PATH.hsize),
    .hburst        (`DMAC_TRACK_PATH.hburst),
    .hprot         (`DMAC_TRACK_PATH.hprot),
    .hwdata        (`DMAC_TRACK_PATH.hwdata),
   // APB control interface
    .pclken        (`DMAC_TRACK_PATH.pclken),
    .psel          (`DMAC_TRACK_PATH.psel),
    .pen           (`DMAC_TRACK_PATH.pen),
    .pwrite        (`DMAC_TRACK_PATH.pwrite),
    .paddr         (`DMAC_TRACK_PATH.paddr),
    .pwdata        (`DMAC_TRACK_PATH.pwdata),
    .prdata        (`DMAC_TRACK_PATH.prdata),
  // DMA Control
    .dma_req       (`DMAC_TRACK_PATH.dma_req),
    .dma_active    (`DMAC_TRACK_PATH.dma_active),
    .dma_done      (`DMAC_TRACK_PATH.dma_done),
   // DMA state from tracking RTL model
    .dma_chnl      (`DMAC_TRACK_PATH.u_pl230_ahb_ctrl.current_chnl),
    .dma_ctrl_state(`DMAC_TRACK_PATH.u_pl230_ahb_ctrl.ctrl_state)
  );
  `endif
`endif

 // --------------------------------------------------------------------------------
 // Tracking Accelerator logging support
 // --------------------------------------------------------------------------------

 `define ACC_PATH u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_exp

`ifndef COCOTB_SIM
  nanosoc_accelerator_ss_logger #(
    .FILENAME("logs/acc_exp.log"),
    .TIMESTAMP(1)
  ) u_accelerator_ss_logger (
     .HCLK            (`ACC_PATH.HCLK          ),
     .HRESETn         (`ACC_PATH.HRESETn       ),
     .HSEL_i          (`ACC_PATH.HSEL          ),
     .HADDR_i         (`ACC_PATH.HADDR         ),
     .HTRANS_i        (`ACC_PATH.HTRANS        ),
     .HWRITE_i        (`ACC_PATH.HWRITE        ),
     .HSIZE_i         (`ACC_PATH.HSIZE         ),
     .HPROT_i         (`ACC_PATH.HPROT         ),
     .HWDATA_i        (`ACC_PATH.HWDATA        ),
     .HREADY_i        (`ACC_PATH.HREADY        ),
     .HRDATA_o        (`ACC_PATH.HRDATA        ),
     .HREADYOUT_o     (`ACC_PATH.HREADYOUT     ),
     .HRESP_o         (`ACC_PATH.HRESP         ),
     .exp_drq_ip_o    (`ACC_PATH.EXP_DRQ[0]    ),
     .exp_dlast_ip_i  (`ACC_PATH.EXP_DLAST[0]  ),
     .exp_drq_op_o    (`ACC_PATH.EXP_DRQ[1]    ),
     .exp_dlast_op_i  (`ACC_PATH.EXP_DLAST[1]  ),
     .exp_irq_o       (`ACC_PATH.EXP_IRQ       )
   );
`endif

 // --------------------------------------------------------------------------------
 // Debug tester connection -
 // --------------------------------------------------------------------------------
  `ifdef ARM_CMSDK_INCLUDE_DEBUG_TESTER

  // Add pullups and pulldowns on Debug Interface

   pullup   (nTRST);
   pullup   (TDI);
   pullup   (TDO);
   pullup   (SWDIOTMS);
   pulldown (SWCLKTCK);


   //connect to P0 for debug command and status pin
   //add pulldown to debug command and debug status signals
   // to give default value 0;
   pulldown(debug_command[5]);
   pulldown(debug_command[4]);
   pulldown(debug_command[3]);
   pulldown(debug_command[2]);
   pulldown(debug_command[1]);
   pulldown(debug_command[0]);

   pulldown(debug_running);
   pulldown(debug_err);

   //Tristate logic for GPIO connection
   bufif1 (P0[7], debug_running, debug_test_en);
   bufif1 (P0[6], debug_err, debug_test_en);
   bufif1 (debug_command[5], P0[5], debug_test_en);
   bufif1 (debug_command[4], P0[4], debug_test_en);
   bufif1 (debug_command[3], P0[3], debug_test_en);
   bufif1 (debug_command[2], P0[2], debug_test_en);
   bufif1 (debug_command[1], P0[1], debug_test_en);
   bufif1 (debug_command[0], P0[0], debug_test_en);

  cmsdk_debug_tester #(.ROM_MEMFILE((BE==1) ? "debugtester_be.hex" : "debugtester_le.hex"))
  u_cmsdk_debug_tester
  (
   // Clock and Reset
   .CLK                                 (CLK),
   .PORESETn                            (NRST_ext),

   // Command Interface
   .DBGCMD                              (debug_command[5:0]),
   .DBGRUNNING                          (debug_running),
   .DBGERROR                            (debug_err),

   // Trace Interface
   .TRACECLK                            (1'b0),
   .TRACEDATA                           (4'h0),
   .SWV                                 (1'b0),

   // Debug Interface
   .TDO                                 (TDO),
   .nTRST                               (nTRST),
   .SWCLKTCK                            (SWCLKTCK),
   .TDI                                 (TDI),
   .SWDIOTMS                            (SWDIOTMS)
   );
  `endif

 // --------------------------------------------------------------------------------
 // Misc
 // --------------------------------------------------------------------------------

  // Format for time reporting
  initial    $timeformat(-9, 0, " ns", 0);

  // Preload EXP rams
  // Icarus Verilog Fix: hierarchical assignment not supported for localparams.
  localparam aw_expram_l = 14; //u_nanosoc_chip_pads.u_nanosoc_chip.u_system.EXPRAM_L_RAM_ADDR_W;
  localparam aw_expram_h = 14; //u_nanosoc_chip_pads.u_nanosoc_chip.u_system.EXPRAM_H_RAM_ADDR_W;

  localparam awt_expram_l = ((1<<(aw_expram_l-2))-1);
  localparam awt_expram_h = ((1<<(aw_expram_h-2))-1);

  reg [7:0] fileimage_l [((1<<aw_expram_l)-1):0];
  reg [7:0] fileimage_h [((1<<aw_expram_h)-1):0];
  integer i,j;

  initial begin
    $readmemh("expram_l.hex", fileimage_l); 
    for (i=0;i<awt_expram_l;i=i+1) begin 
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_l.u_expram_l.u_sram.BRAM0[i] = fileimage_l[ 4*i];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_l.u_expram_l.u_sram.BRAM1[i] = fileimage_l[(4*i)+1];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_l.u_expram_l.u_sram.BRAM2[i] = fileimage_l[(4*i)+2];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_l.u_expram_l.u_sram.BRAM3[i] = fileimage_l[(4*i)+3];
    end
    $readmemh("expram_h.hex", fileimage_h); 
    for (i=0;i<awt_expram_h;i=i+1) begin 
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_h.u_expram_h.u_sram.BRAM0[i] = fileimage_h[ 4*i];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_h.u_expram_h.u_sram.BRAM1[i] = fileimage_h[(4*i)+1];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_h.u_expram_h.u_sram.BRAM2[i] = fileimage_h[(4*i)+2];
      u_nanosoc_chip_pads.u_nanosoc_chip.u_system.u_ss_expansion.u_region_expram_h.u_expram_h.u_sram.BRAM3[i] = fileimage_h[(4*i)+3];
    end
  end

  // Configuration checks
  initial begin
`ifdef CORTEX_M0DESIGNSTART
`ifdef CORTEX_M0
     $display("ERROR (nanosoc_tb.v) in CPU preprocessing directive : Both CORTEX_M0DESIGNSTART and CORTEX_M0 are set. Please use only one.");
     $stop;
`endif
`endif
`ifdef CORTEX_M0DESIGNSTART
`ifdef CORTEX_M0PLUS
     $display("ERROR (nanosoc_tb.v) in CPU preprocessing directive : Both CORTEX_M0DESIGNSTART and CORTEX_M0PLUS are set. Please use only one.");
     $stop;
`endif
`endif
`ifdef CORTEX_M0
`ifdef CORTEX_M0PLUS
     $display("ERROR (nanosoc_tb.v) in CPU preprocessing directive : Both CORTEX_M0 and CORTEX_M0PLUS are set. Please use only one.");
     $stop;
`endif
`endif
`ifdef CORTEX_M0DESIGNSTART
`ifdef CORTEX_M0
`ifdef CORTEX_M0PLUS
     $display("ERROR (nanosoc_tb.v) in CPU preprocessing directive : All of CORTEX_M0DESIGNSTART, CORTEX_M0 and CORTEX_M0PLUS are set. Please use only one.");
     $stop;
`endif
`endif
`endif
`ifdef CORTEX_M0
`else
`ifdef CORTEX_M0PLUS
`else
`ifdef CORTEX_M0DESIGNSTART
`else
     $display("ERROR (nanosoc_tb.v) in CPU preprocessing directive : None of CORTEX_M0DESIGNSTART, CORTEX_M0 and CORTEX_M0PLUS are set. Please select one.");
     $stop;
`endif
`endif
`endif

  end
endmodule
