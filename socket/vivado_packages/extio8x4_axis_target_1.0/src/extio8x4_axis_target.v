//-----------------------------------------------------------------------------
// 8-bit extio transfer over 4-bit data plane - target
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2024, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : target FSM wrapped with synchronizers
//-----------------------------------------------------------------------------


module extio8x4_axis_target
  (
  input  wire       clk,
  input  wire       resetn,
  input  wire       testmode,
// RX 4-channel AXIS interface
  output wire       axis_rx0_tready, 
  input  wire       axis_rx0_tvalid,
  input  wire [7:0] axis_rx0_tdata8,
  output wire       axis_rx1_tready, 
  input  wire       axis_rx1_tvalid,
  input  wire [7:0] axis_rx1_tdata8,
  input  wire       axis_tx0_tready, 
  output wire       axis_tx0_tvalid,
  output wire [7:0] axis_tx0_tdata8,
  input  wire       axis_tx1_tready, 
  output wire       axis_tx1_tvalid,
  output wire [7:0] axis_tx1_tdata8,
// external io interface
  input  wire [3:0] iodata4_i,
  output wire [3:0] iodata4_o,
  output wire [3:0] iodata4_e,
  output wire [3:0] iodata4_t,
  input  wire       ioreq1_a,
  input  wire       ioreq2_a,
  output wire       ioack_o
  );

wire       ioreq1_s;
wire       ioreq2_s;

extio8x4_sync u_extio8x4_sync_ioreq1
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioreq1_a),
  .sig_s(ioreq1_s)
  );

extio8x4_sync u_extio8x4_sync_ioreq2
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioreq2_a),
  .sig_s(ioreq2_s)
  );


extio8x4_tfsm u_extio8x4_tfsm
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

/*
extio8x4_axis_target u_extio8x4_axis_target
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
  .testmode        ( testmode        ),
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
  .ioreq1_a        ( ioreq1_i        ),
  .ioreq2_a        ( ioreq2_i        ),
  .ioack_o         ( ioack_o         )
  );

*/
