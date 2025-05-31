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

module extio8x4_sync #(
    parameter    RESET_VALUE = 1'b0
  )(
  input  wire clk,
  input  wire resetn,
  input  wire testmode,
  input  wire sig_a,
  output wire sig_s
  );

reg [2:1] sig_r;

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    sig_r <= {2{RESET_VALUE}}; // support active-low/high reset initial values
  else
    sig_r <= {sig_r[1], sig_a}; // shift left
end

assign sig_s = (testmode) ? sig_a : sig_r[2];

endmodule

/*
extio8x4_sync, u_extio8x4_sync_1
  (
  .clk(clk),
  .resetn(resetn),
  .testmode(testmode),
  .sig_a(sig_i),
  .sig_s(sig_s)
  );

*/
