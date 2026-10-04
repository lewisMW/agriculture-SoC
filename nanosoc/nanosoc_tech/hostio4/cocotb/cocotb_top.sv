//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  SoC Testbench
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

`timescale 1ns/1ps

module cocotb_top;
  logic clk;
  logic resetn;
  logic testmode;

  logic        C_axis_rx0_tvalid; logic [7:0] C_axis_rx0_tdata8; logic C_axis_rx0_tready;
  logic        C_axis_rx1_tvalid; logic [7:0] C_axis_rx1_tdata8; logic C_axis_rx1_tready;
  logic        C_axis_tx0_tvalid; logic [7:0] C_axis_tx0_tdata8; logic C_axis_tx0_tready;
  logic        C_axis_tx1_tvalid; logic [7:0] C_axis_tx1_tdata8; logic C_axis_tx1_tready;

  logic        T_axis_rx0_tvalid; logic [7:0] T_axis_rx0_tdata8; logic T_axis_rx0_tready;
  logic        T_axis_rx1_tvalid; logic [7:0] T_axis_rx1_tdata8; logic T_axis_rx1_tready;
  logic        T_axis_tx0_tvalid; logic [7:0] T_axis_tx0_tdata8; logic T_axis_tx0_tready;
  logic        T_axis_tx1_tvalid; logic [7:0] T_axis_tx1_tdata8; logic T_axis_tx1_tready;

  tri  [3:0] iodata4;
  tri        ioreq1;
  tri        ioreq2;

  wire [3:0] C_iodata4_i, C_iodata4_o, C_iodata4_e, C_iodata4_t;
  logic      C_ioreq_t, C_ioreq_e, C_ioreq1_o, C_ioreq2_o;

  wire [3:0] C2_iodata4_i, C2_iodata4_o, C2_iodata4_e, C2_iodata4_t;
  logic      C2_ioreq_t, C2_ioreq_e, C2_ioreq1_o, C2_ioreq2_o;

  wire [3:0] T_iodata4_i, T_iodata4_o, T_iodata4_e, T_iodata4_t;
  wire       ioack;

  wire       C2_ioack;
  pullup(C2_ioack);

  assign testmode = 1'b0;
  initial begin clk = 1'b0; forever #5 clk = ~clk; end
  initial begin resetn = 1'b0; #100 resetn = 1'b1; end

  initial begin
    C_axis_tx0_tready = 1'b1; C_axis_tx1_tready = 1'b1;
    T_axis_tx0_tready = 1'b1; T_axis_tx1_tready = 1'b1;
  end

  hostio4_controller u_hostio4_controller (
    .clk(clk), .resetn(resetn), .testmode(testmode),
    .axis_rx0_tready(C_axis_rx0_tready), .axis_rx0_tvalid(C_axis_rx0_tvalid), .axis_rx0_tdata8(C_axis_rx0_tdata8),
    .axis_rx1_tready(C_axis_rx1_tready), .axis_rx1_tvalid(C_axis_rx1_tvalid), .axis_rx1_tdata8(C_axis_rx1_tdata8),
    .axis_tx0_tready(C_axis_tx0_tready), .axis_tx0_tvalid(C_axis_tx0_tvalid), .axis_tx0_tdata8(C_axis_tx0_tdata8),
    .axis_tx1_tready(C_axis_tx1_tready), .axis_tx1_tvalid(C_axis_tx1_tvalid), .axis_tx1_tdata8(C_axis_tx1_tdata8),
    .iodata4_a(C_iodata4_i), .iodata4_o(C_iodata4_o), .iodata4_e(C_iodata4_e), .iodata4_t(C_iodata4_t),
    .ioreq1_o(C_ioreq1_o), .ioreq2_o(C_ioreq2_o), .ioreq_e(C_ioreq_e), .ioreq_t(C_ioreq_t),
    .ioack_a(ioack)
  );

  hostio4_controller u_hostio4_controller2 (
    .clk(clk), .resetn(resetn), .testmode(testmode),
    .axis_rx0_tready(), .axis_rx0_tvalid(1'b0), .axis_rx0_tdata8(8'h00),
    .axis_rx1_tready(), .axis_rx1_tvalid(1'b0), .axis_rx1_tdata8(8'h00),
    .axis_tx0_tready(1'b1), .axis_tx0_tvalid(), .axis_tx0_tdata8(),
    .axis_tx1_tready(1'b1), .axis_tx1_tvalid(), .axis_tx1_tdata8(),
    .iodata4_a(C2_iodata4_i), .iodata4_o(C2_iodata4_o), .iodata4_e(C2_iodata4_e), .iodata4_t(C2_iodata4_t),
    .ioreq1_o(C2_ioreq1_o), .ioreq2_o(C2_ioreq2_o), .ioreq_e(C2_ioreq_e), .ioreq_t(C2_ioreq_t),
    .ioack_a(C2_ioack)
  );

  hostio4_target u_hostio4_target (
    .clk(!clk), .resetn(resetn), .testmode(testmode),
    .axis_rx0_tready(T_axis_rx0_tready), .axis_rx0_tvalid(T_axis_rx0_tvalid), .axis_rx0_tdata8(T_axis_rx0_tdata8),
    .axis_rx1_tready(T_axis_rx1_tready), .axis_rx1_tvalid(T_axis_rx1_tvalid), .axis_rx1_tdata8(T_axis_rx1_tdata8),
    .axis_tx0_tready(T_axis_tx0_tready), .axis_tx0_tvalid(T_axis_tx0_tvalid), .axis_tx0_tdata8(T_axis_tx0_tdata8),
    .axis_tx1_tready(T_axis_tx1_tready), .axis_tx1_tvalid(T_axis_tx1_tvalid), .axis_tx1_tdata8(T_axis_tx1_tdata8),
    .iodata4_i(T_iodata4_i), .iodata4_o(T_iodata4_o), .iodata4_e(T_iodata4_e), .iodata4_t(T_iodata4_t),
    .ioreq1_a(ioreq1), .ioreq2_a(ioreq2), .ioack_o(ioack)
  );

  genvar i;
  generate
    for (i=0;i<4;i=i+1) begin : g_bus
      bufif0 #1 (iodata4[i], C_iodata4_o[i],  C_iodata4_t[i]);
      bufif0 #1 (iodata4[i], C2_iodata4_o[i], C2_iodata4_t[i]);
      bufif0 #1 (iodata4[i], T_iodata4_o[i],  T_iodata4_t[i]);
    end
  endgenerate
  assign C_iodata4_i  = iodata4;
  assign C2_iodata4_i = iodata4;
  assign T_iodata4_i  = iodata4;

  bufif0 #1 (ioreq1, C_ioreq1_o,  C_ioreq_t);
  bufif0 #1 (ioreq2, C_ioreq2_o,  C_ioreq_t);
  bufif0 #1 (ioreq1, C2_ioreq1_o, C2_ioreq_t);
  bufif0 #1 (ioreq2, C2_ioreq2_o, C2_ioreq_t);

  // Biasing
//  pulldown(iodata4[0]); pulldown(iodata4[1]); pulldown(iodata4[2]); pulldown(iodata4[3]);
  pulldown(ioreq1); pulldown(ioreq2);

  // Assertion: iodata4 must never be X/Z when ioreq1 low, once reset is released
  integer _post_reset_cycles;
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      _post_reset_cycles <= 0;
    end else if (!ioreq1) begin
      if (_post_reset_cycles < 8) _post_reset_cycles <= _post_reset_cycles + 1;
      if (_post_reset_cycles >= 2) begin
        assert(!$isunknown(iodata4))
          else $fatal(1, "iodata4 became X/Z (value=%b), ioreq1=%b", iodata4, ioreq1);
      end
    end
  end

  tb_hostio4_monitor #(
    .VERBOSE(0)
  ) u_tb_hostio4_monitor (
  .iodata4 ( iodata4 ),
  .ioreq1  ( ioreq1  ),
  .ioreq2  ( ioreq2  ),
  .ioack   ( ioack   )
  );


//always@(posedge clk)
//  $display(ioreq1, ioreq2, ioack, ":", iodata4[3], iodata4[2], iodata4[1], iodata4[0]);

//always@(posedge clk)
//  if (C_axis_rx0_tvalid & C_axis_rx0_tready &  resetn)
//    $display($time," C_axis_rx0:%02h", C_axis_rx0_tdata8);

//always@(posedge clk)
//  if (T_axis_tx0_tvalid & T_axis_tx0_tready & resetn)
//    $display($time,"T_axis_tx0:%02h",T_axis_tx0_tdata8);


endmodule
