//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  SoC Controller
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

module hostio4_controller
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
  input  logic [3:0] iodata4_a,
  output logic [3:0] iodata4_o,
  output logic [3:0] iodata4_e,
  output logic [3:0] iodata4_t,
  output logic       ioreq1_o,
  output logic       ioreq2_o,
  output logic       ioreq_e,
  output logic       ioreq_t,
  input  logic       ioack_a
  );

logic       ioack_s;
logic [3:0] iodata4_s;

hostio4_controller_sync  # (
  .RESET_VALUE(1'b1)
  )
 u_hostio4_controller_sync_ioack
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(ioack_a),
  .sig_s(ioack_s)
  );

// async status on iodata4 is active-hi so reset synchronizers to avoid spurious requests

hostio4_controller_sync  # (
  .RESET_VALUE(1'b0)
  )
  u_hostio4_controller_sync_iodata0 (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[0]),
  .sig_s(iodata4_s[0])
  );

hostio4_controller_sync  # (
  .RESET_VALUE(1'b0)
  ) u_hostio4_controller_sync_iodata1 (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[1]),
  .sig_s(iodata4_s[1])
  );

hostio4_controller_sync  # (
  .RESET_VALUE(1'b0)
  ) u_hostio4_controller_sync_iodata2 (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[2]),
  .sig_s(iodata4_s[2])
  );

hostio4_controller_sync   # (
  .RESET_VALUE(1'b0)
  ) u_hostio4_controller_sync_iodata3 (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(iodata4_a[3]),
  .sig_s(iodata4_s[3])
  );

logic ioclken;
`ifdef IOCLKDIV
hostio4_controller_sync u_hostio4_ioclken_div2
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(!ioclken),
  .sig_s(ioclken)
  );
`else
  assign ioclken = 1'b1;
`endif

hostio4_controller_fsm u_hostio4_controller_fsm
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
  .ioclken         ( ioclken         ),
  .iodata4_i       ( iodata4_a       ),
  .iodata4_s       ( iodata4_s       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_o        ),
  .ioreq2_o        ( ioreq2_o        ),
  .ioreq_e         ( ioreq_e         ),
  .ioreq_t         ( ioreq_t         ),
  .ioack_s         ( ioack_s         )
  );
           
endmodule
