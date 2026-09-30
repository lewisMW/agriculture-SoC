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

module hostio4_target_axis_txport
 #(
    parameter    WIDTH = 8
  )(
  input  logic             clk,
  input  logic             resetn,
// state machine req/ack handshake
  output logic             tx_req,
  input  logic             tx_ack,
  input  logic [WIDTH-1:0] tx_data,
// AXI-Stream TX port
  input  logic             axis_tx_tready,
  output logic             axis_tx_tvalid,
  output logic [WIDTH-1:0] axis_tx_tdata
  );

logic [WIDTH:0] tx_val_buffer;

// axis TX port interface
// Additional top bit holds TX valid status
always_ff @(posedge clk or negedge resetn)
begin
  if (!resetn)
    tx_val_buffer <= {WIDTH{1'b0}};
  else begin
    if (!tx_val_buffer[WIDTH] & tx_ack) // load
       tx_val_buffer <= {1'b1,tx_data[WIDTH-1:0]};
    else if (tx_val_buffer[WIDTH] & axis_tx_tready) // unload
       tx_val_buffer[WIDTH] <= 1'b0;
    end
end

assign axis_tx_tvalid           =  tx_val_buffer[WIDTH]; //full
assign axis_tx_tdata[WIDTH-1:0] =  tx_val_buffer[WIDTH-1:0];
assign tx_req                   = !tx_val_buffer[WIDTH]; //empty

endmodule
