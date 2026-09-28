//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  Controller axi stream tx port
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
// Abstract : AXI-Stream TXD (output) port
//-----------------------------------------------------------------------------

module hostio4_controller_axis_txport
 #(
    parameter    WIDTH = 8
  )(
  input  wire             clk,
  input  wire             resetn,
// state machine req/ack handshake
  output wire             tx_req,
  input  wire             tx_ack,
  input  wire [WIDTH-1:0] tx_data,
// AXI-Stream TX port
  input  wire             axis_tx_tready,
  output wire             axis_tx_tvalid,
  output wire [WIDTH-1:0] axis_tx_tdata
  );

reg [WIDTH:0] tx_val_buffer;

// axis TX port interface
// Additional top bit holds TX valid status
always @(posedge clk or negedge resetn)
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
