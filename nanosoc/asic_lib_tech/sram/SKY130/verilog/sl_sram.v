//-----------------------------------------------------------------------------
// SoCLabs ASIC RAM Wrapper 
// - substituted using the same name from the FPGA tech library
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.flynn@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sl_sram #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW = 13
 )
 (
  `ifdef POWER_PINS
  inout  wire          VDD,
  inout  wire          VSS,
  `endif
  // Inputs
  input  wire          CLK,
  input  wire [AW-1:2] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA
  );

wire        CEN = !CS;
wire        GWEN = &(~WREN);

genvar i;
generate
    if(AW==14) begin
        sky130_sram_8kbyte_1rw_32x2048_8 u_sram(
            .clk0(CLK),
            .csb0(CEN),
            .web0(GWEN),
            .wmask0(WREN),
            .addr0(ADDR),
            .din0(WDATA),
            .dout0(RDATA),

            // read port
            .clk1(1'b0),
            .csb1(1'b1),
            .addr1(10'd0),
            .dout1()
        );
    end
endgenerate

endmodule
