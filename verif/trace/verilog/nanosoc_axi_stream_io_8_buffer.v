//-----------------------------------------------------------------------------
// customised example Cortex-M0 controller UART with file logging
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : axi_stream 1-stage buffer
//-----------------------------------------------------------------------------


module nanosoc_axi_stream_io_8_buffer
  (
  input  wire  aclk,
  input  wire  aresetn,
  output wire  rxd8_ready,
  input  wire  rxd8_valid,
  input  wire  [7:0] rxd8_data,
  input  wire  txd8_ready,
  output wire  txd8_valid,
  output wire  [7:0] txd8_data
  );

   reg [8:0] datareg;
   
always @(posedge aclk or negedge aresetn)
begin
  if (!aresetn)
    datareg <= 9'b0_00000000;
  else if (!datareg[8] & rxd8_valid)
    datareg <= {1'b1, rxd8_data};
  else if ( datareg[8] & txd8_ready)
    datareg[8] <= 1'b0;
end

assign rxd8_ready = !datareg[8];

assign txd8_valid =  datareg[8];
assign txd8_data  =  datareg[7:0];

endmodule
