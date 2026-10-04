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

module hostio4_target_axis_rxport
 #(
    parameter    WIDTH = 8
  )(
  input  logic             clk,
  input  logic             resetn,
// state machine req/ack handshake
  output logic             rx_req,
  input  logic             rx_ack,
  output logic [WIDTH-1:0] rx_data,
// AXI-Stream rx port
  output logic             axis_rx_tready,
  input  logic             axis_rx_tvalid,
  input  logic [WIDTH-1:0] axis_rx_tdata
  );

logic [WIDTH:0] rx_val_buffer;

// axis rx port interface
// Additional top bit holds rx valid status
always_ff @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx_val_buffer <= {WIDTH{1'b0}};
  else begin
    if (!rx_val_buffer[WIDTH] & axis_rx_tvalid) // load
       rx_val_buffer <= {1'b1,axis_rx_tdata[WIDTH-1:0]};
    else if (rx_val_buffer[WIDTH] & rx_ack) // unload
       rx_val_buffer[WIDTH] <= 1'b0;
    end
end

assign axis_rx_tready = !rx_val_buffer[WIDTH]; // empty
assign rx_data        =  rx_val_buffer[WIDTH-1:0];
assign rx_req         =  rx_val_buffer[WIDTH]; // full

endmodule
