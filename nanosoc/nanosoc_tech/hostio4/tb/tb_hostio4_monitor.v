//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  SoC Target
//
// A joint work commissioned on behalf of SoC Labs,
// under Arm Academic Access license.
//
// Contributors
//
// Design: David Flynn (dwflynn@soton.ac.uk)
//
// Packaging: Microsoft CoPilot AI agent support
//
// Copyright (c) 2024-6, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module tb_hostio4_monitor #(
    parameter    VERBOSE = 0
  )(
// external io interface
  input  logic [3:0] iodata4,
  input  logic       ioreq1,
  input  logic       ioreq2,
  input  logic       ioack
  );


wire  status_phase;

assign status_phase = !ioreq1 & !ioreq2 & !ioack;

// built from asynchronous handshake edges, reset when IOREQ1 is inactive
// use IOACK edges to sample signals from controller/SOC
// and IOREQ2 edges to sample signals from taret/HOST
//              ________________________
// ioreq1  ____|                        |___
//                   ____      ____
// ioreq2  _________|    |____|    |________
//                ____      ____      ____
// ioack  _______|    |____|    |____|    |__
//                   _________   
// cphase1 _________|         |______________
//                        _________ 
// cphase2 ______________|         |_________
//                     __________________
// txcmd  ____________|                  |___
//                          _____________
// txdat  _________________| 7:4:7:0      |_________
//                     _____________
// rxcmd  ____________|            |_________
//                            _____________
// rxdat  ___________________| 7:4:7:0      |_________

reg cphase1;
always @(posedge ioreq2 or negedge ioreq1)
  if (!ioreq1)
    cphase1 <= 1'b0;
  else
    cphase1 <= !cphase1;

reg cphase2;
always @(negedge ioreq2 or negedge ioreq1)
  if (!ioreq1)
    cphase2 <= 1'b0;
  else
    cphase2 <= !cphase2;

reg cphase3;
always @(posedge ioreq2 or negedge ioreq1)
  if (!ioreq1)
    cphase3 <= 1'b0;
  else
    cphase3 <= cphase2;

wire cmd_sample  =  cphase1 & !cphase2;

reg cmd_tx;
always @(negedge ioack or negedge ioreq1)
  if (!ioreq1)
    cmd_tx <= 1'b0;
  else if (cmd_sample & !iodata4[0]) // 0 for TX command
    cmd_tx <= 1'b1;

reg cmd_rx;
always @(negedge ioack or negedge ioreq1)
  if (!ioreq1)
    cmd_rx <= 1'b0;
  else if (cmd_sample &  iodata4[0]) // 0 for RX command
    cmd_rx <= 1'b1;

reg [4:0] cmd4;
always @(negedge ioack)
  if (cmd_sample) // 0 for TX command
    cmd4 <= iodata4[3:0];

wire txdh_sample =  cphase1 &  cphase2 & cmd_tx;
wire txdl_sample = !cphase1 &  cphase2 & cmd_tx;

reg [8:0] txdata;
always @(posedge ioack or negedge ioreq1)
  if (!ioreq1)
    txdata[8:4] <= 5'b00000;
  else if (txdh_sample) 
    txdata[8:4] <= {1'b1,iodata4[3:0]};

always @(negedge ioack or negedge ioreq1)
  if (!ioreq1)
    txdata[3:0] <= 4'b000;
  else if (txdl_sample) 
    txdata[3:0] <= iodata4[3:0];

reg tphase1;
always @(posedge ioack or negedge ioreq1)
  if (!ioreq1)
    tphase1 <= 1'b0;
  else if (cmd_rx)
    tphase1 <= !tphase1;

reg tphase2;
always @(negedge ioack or negedge ioreq1)
  if (!ioreq1)
    tphase2 <= 1'b0;
  else
    tphase2 <= tphase1;

wire rxdh_sample =  tphase1 & !tphase2 & cmd_rx;
wire rxdl_sample =  tphase1 &  tphase2 & cmd_rx;

reg [8:0] rxdata;
always @(posedge ioreq2 or negedge ioreq1)
  if (!ioreq1)
    rxdata[8:4] <= 5'b00000;
  else if (rxdh_sample) 
    rxdata[8:4] <= {1'b1,iodata4[3:0]};

always @(negedge ioreq2 or negedge ioreq1)
  if (!ioreq1)
    rxdata[3:0] <= 4'b0000;
  else if (rxdl_sample) 
    rxdata[3:0] <= iodata4[3:0];

wire eop = cphase3 & !cphase2 & ioack & (VERBOSE != 0);

always @(posedge eop)
  if (txdata[8]) begin
    if (cmd4[1])
      $display("   * hostio4: DatOut C2H <0x%02x> (cmd [%04b])", txdata[7:0], cmd4);
    else
      $display("   * hostio4: DatIn  H2C <0x%02x> (cmd [%04b])", txdata[7:0], cmd4);
  end else begin
    if (cmd4[1])
      $display("   * hostio4: StdOut C2H <0x%02x> (cmd [%04b])", rxdata[7:0], cmd4);
    else
      $display("   * hostio4: StdIn  H2C <0x%02x> (cmd [%04b])", rxdata[7:0], cmd4);
  end
             
endmodule
