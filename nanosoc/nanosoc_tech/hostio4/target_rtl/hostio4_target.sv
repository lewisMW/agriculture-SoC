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

module hostio4_target
  (
  input  logic       clk,
  input  logic       resetn,
  input  logic       testmode,
// RX 4-channel AXIS interface
  output logic       axis_rx0_tready, 
  input  logic       axis_rx0_tvalid,
  input  logic [7:0] axis_rx0_tdata8,
  output logic       axis_rx1_tready, 
  input  logic       axis_rx1_tvalid,
  input  logic [7:0] axis_rx1_tdata8,
  input  logic       axis_tx0_tready, 
  output logic       axis_tx0_tvalid,
  output logic [7:0] axis_tx0_tdata8,
  input  logic       axis_tx1_tready, 
  output logic       axis_tx1_tvalid,
  output logic [7:0] axis_tx1_tdata8,
// external io interface
  input  logic [3:0] iodata4_i,
  output logic [3:0] iodata4_o,
  output logic [3:0] iodata4_e,
  output logic [3:0] iodata4_t,
  input  logic       ioreq1_a,
  input  logic       ioreq2_a,
  output logic       ioack_o
  );

logic       ioreq1_s;
logic       ioreq2_s;

hostio4_target_sync u_hostio4_sync_ioreq1
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioreq1_a),
  .sig_s(ioreq1_s)
  );

hostio4_target_sync u_hostio4_sync_ioreq2
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioreq2_a),
  .sig_s(ioreq2_s)
  );


hostio4_target_fsm u_hostio4_target_fsm
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
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
  .ioreq1_s        ( ioreq1_s        ),
  .ioreq2_s        ( ioreq2_s        ),
  .ioack_o         ( ioack_o         )
  );
           
endmodule
