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
  parameter AW = 16
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

// fixed pre-compiled 16K instance supported
localparam  TIE_EMA = 3'b010;
localparam  TIE_EMAW = 2'b00;
wire [AW-3:0] ADDR12 = ADDR;
wire [31:0] WDATA32 = WDATA;
wire [31:0] RDATA32;
assign      RDATA = RDATA32;
wire        CEN = !CS;
wire        GWEN = &(~WREN);
wire [31:0] WEN32 = { {8{!WREN[3]}},{8{!WREN[2]}},{8{!WREN[1]}},{8{!WREN[0]}} };
localparam  TIE_RET1N = 1'b1;

generate
  if (AW==14) begin
     sram_16k
      u_sram (
  `ifdef POWER_PINS
      .VDD (VDD),
      .VSS  (VSS),
  `endif
      .Q     (RDATA32),
      .CLK   (CLK),
      .CEN   (CEN),
      .WEN   (WEN32),
      .A     (ADDR12),
      .D     (WDATA32),
      .EMA   (TIE_EMA),
      .EMAW  (TIE_EMAW),
      .GWEN  (GWEN),
      .RET1N (TIE_RET1N)
    );

  end
  else if (AW==15) begin
     sram_32k
      u_sram (
  `ifdef POWER_PINS
      .VDD (VDD),
      .VSS  (VSS),
  `endif
      .Q     (RDATA32),
      .CLK   (CLK),
      .CEN   (CEN),
      .WEN   (WEN32),
      .A     (ADDR12),
      .D     (WDATA32),
      .EMA   (TIE_EMA),
      .EMAW  (TIE_EMAW),
      .GWEN  (GWEN),
      .RET1N (TIE_RET1N)
    );
  end
endgenerate
 

endmodule
