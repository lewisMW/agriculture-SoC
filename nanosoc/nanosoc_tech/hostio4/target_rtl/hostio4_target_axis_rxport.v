//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  Target axi-stream rx-port
//
// A joint work commissioned on behalf of SoC Labs,
// under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2024-6, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Abstract : AXI-Stream RXD (input) port
//-----------------------------------------------------------------------------

module hostio4_target_axis_rxport
 #(
    parameter    WIDTH = 8
  )(
  input  wire             clk,
  input  wire             resetn,
// state machine req/ack handshake
  output wire             rx_req,
  input  wire             rx_ack,
  output wire [WIDTH-1:0] rx_data,
// AXI-Stream rx port
  output wire             axis_rx_tready,
  input  wire             axis_rx_tvalid,
  input  wire [WIDTH-1:0] axis_rx_tdata
  );

reg [WIDTH:0] rx_val_buffer;

// axis rx port interface
// Additional top bit holds rx valid status
always @(posedge clk or negedge resetn)
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
