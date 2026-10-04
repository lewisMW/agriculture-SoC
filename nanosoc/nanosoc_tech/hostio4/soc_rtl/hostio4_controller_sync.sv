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

module hostio4_controller_sync #(
    parameter    RESET_VALUE = 1'b0
  )(
  input  logic clk,
  input  logic resetn,
  input  logic testmode,
  input  logic sig_a,
  output logic sig_s
  );

logic [2:1] sig_r;

always_ff @(posedge clk or negedge resetn)
begin
  if (!resetn)
    sig_r <= {2{RESET_VALUE}}; // support active-low/high reset initial values
  else
    sig_r <= {sig_r[1], sig_a}; // shift left
end

assign sig_s = (testmode) ? sig_a : sig_r[2];

endmodule
