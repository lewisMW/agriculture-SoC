//-----------------------------------------------------------------------------
// 8-bit extio transfer over 4-bit data plane - initiator
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
// Abstract : Initiator FSM wrapped with synchronizers
//-----------------------------------------------------------------------------


module extio8x4_axis_initiator
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
  input  wire [3:0] iodata4_a,
  output wire [3:0] iodata4_o,
  output wire [3:0] iodata4_e,
  output wire [3:0] iodata4_t,
  output wire       ioreq1_o,
  output wire       ioreq2_o,
  input  wire       ioack_a
  );

wire       ioack_s;
wire [3:0] iodata4_s;

extio8x4_sync u_extio8x4_sync_ioack
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioack_a),
  .sig_s(ioack_s)
  );

extio8x4_sync u_extio8x4_sync_iodata0
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[0]),
  .sig_s(iodata4_s[0])
  );

extio8x4_sync u_extio8x4_sync_iodata1
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[1]),
  .sig_s(iodata4_s[1])
  );

extio8x4_sync u_extio8x4_sync_iodata2
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[2]),
  .sig_s(iodata4_s[2])
  );

extio8x4_sync u_extio8x4_sync_iodata3
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[3]),
  .sig_s(iodata4_s[3])
  );

extio8x4_ifsm u_extio8x4_ifsm
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
  .iodata4_i       ( iodata4_a       ),
  .iodata4_s       ( iodata4_s       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_o        ),
  .ioreq2_o        ( ioreq2_o        ),
  .ioack_s         ( ioack_s         )
  );
           
endmodule

/*
extio8x4_axis_initiator u_extio8x4_axis_initiator
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
  .iodata4_a       ( iodata4_a       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_a        ),
  .ioreq2_o        ( ioreq2_a        ),
  .ioack_a         ( ioack_a         )
  );

*/
