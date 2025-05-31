//-----------------------------------------------------------------------------
// SoCLabs ASIC ROM Wrapper 
// - substituded using the same name from the FPGA tech library
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module bootrom #(
    parameter AW_ADDR_W = 8
)(
    `ifdef POWER_PINS
    inout VDD,
    inout VSS,
    `endif
    input  wire CLK,
    input  wire EN,
    input  wire [7:0] W_ADDR,
    output reg [31:0] RDATA 
);

    rom_via 
        u_sl_rom(
        `ifdef POWER_PINS
        .VDD(VDD),
        .VSSE(VSS),
        `endif
        .Q(RDATA),
        .CLK(CLK),
        .CEN(!EN),
        .A(W_ADDR),
        .EMA(3'b010),
        .TEN(1'b1),
        .BEN(1'b1),
        .TCEN(1'b0),
        .TA(8'b0),
        .TQ(32'b0),
        .PGEN(1'b0),
        .KEN(1'b1)
    );

endmodule
