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
  $sdf_annotate ( "../../../imp/ASIC/nanosoc/netlist/nanosoc_chip_pads_gate.sdf"
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
  .P0         (P0[7:0]),
  .P1         (P1[7:0]),
  .SWDIO      (SWDIOTMS),
  .SWDCK      (SWCLKTCK)
  );
`endif
//-----------------------------------------------------------------------------
// Abstract : Simple clock and power on reset generator
//-----------------------------------------------------------------------------

  reg osc_q;
  reg [15:0] shifter;
  
  initial
    begin
      osc_q     <= 1'b1;
      shifter   <= 16'h0000;
      #(3 * CLOCK_PHASE) osc_q <= 1'b0;
    end

  always @(osc_q)
   #CLOCK_PHASE
       osc_q <= !osc_q;

  assign CLK = osc_q;

  always @(posedge osc_q or negedge TEST_NPOR)
    if (!TEST_NPOR)
      shifter <= 16'h0000;
    else if (! (&shifter)) begin // until full...
      shifter   <= {shifter[14:0], 1'b1}; // shift left, fill with 1's
    end
  assign NRST_early =  shifter[ 7];
  assign NRST       =  shifter[ 8];
  assign NRST_late  =  shifter[ 9] ;
  assign NRST_ext   =  shifter[15];

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
