`timescale 1ns/1ps
// dffram_pg_models.v -- behavioural models of the DFFRAM macros for the
// gate-level simulation, with the supply pins the powered netlist connects.
//
// OL-DFFRAM's own models (hdl/sim) have no VPWR/VGND ports. These behave the
// same, with two differences on purpose: Do0 holds while EN0 is low, as the
// macro's clock-gated output register does (the upstream model returns zero),
// and nothing works unless the supplies are connected, as with the powered
// standard-cell models. RAM is the array the frame model preloads.
module dffram_pg_model #(parameter AW = 9) (
    inout  wire          VPWR,
    inout  wire          VGND,
    input  wire          CLK,
    input  wire [3:0]    WE0,
    input  wire          EN0,
    input  wire [AW-1:0] A0,
    input  wire [31:0]   Di0,
    output wire [31:0]   Do0
);
    reg [31:0] RAM [0:(1<<AW)-1];
    reg [31:0] do_q;
`ifdef OF_RTL_SIM
    wire       powered = 1'b1;      // RTL has no supply pins: the ports are left open
`else
    wire       powered = (VPWR === 1'b1) && (VGND === 1'b0);
`endif
    always @(posedge CLK)
        if (EN0 === 1'b1) begin
            do_q <= RAM[A0];
            if (WE0[0]) RAM[A0][ 7: 0] <= Di0[ 7: 0];
            if (WE0[1]) RAM[A0][15: 8] <= Di0[15: 8];
            if (WE0[2]) RAM[A0][23:16] <= Di0[23:16];
            if (WE0[3]) RAM[A0][31:24] <= Di0[31:24];
        end else if (EN0 !== 1'b0)
            do_q <= 32'bx;
    assign Do0 = powered ? do_q : 32'bx;
endmodule

module DFFRAM512x32 (inout wire VPWR, inout wire VGND, input wire CLK, input wire [3:0] WE0, input wire EN0,
                     input wire [8:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    dffram_pg_model #(.AW(9)) m (.VPWR(VPWR), .VGND(VGND), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule

module DFFRAM256x32 (inout wire VPWR, inout wire VGND, input wire CLK, input wire [3:0] WE0, input wire EN0,
                     input wire [7:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    dffram_pg_model #(.AW(8)) m (.VPWR(VPWR), .VGND(VGND), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule

module DFFRAM128x32 (inout wire VPWR, inout wire VGND, input wire CLK, input wire [3:0] WE0, input wire EN0,
                     input wire [6:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    dffram_pg_model #(.AW(7)) m (.VPWR(VPWR), .VGND(VGND), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule

// -----------------------------------------------------------------------------
// Blocks built with the DFFRAM compiler (RAM512, RAM1024). They differ from the
// pre-hardened ones above in one way that matters: there is an output register
// per 16 words, every one of them clocked each cycle (an unselected block's
// lines are driven low, so its register takes zero), and Do0 is whichever
// register the address pins point at NOW. The model keeps that behaviour, so a
// bridge that moves the address before taking the data reads wrong data here
// as it would on silicon. With USE_POWER_PINS they have VPWR/VGND, as in the
// powered netlist; without it (unit tests) the supplies are tied inside.
// -----------------------------------------------------------------------------
module dffram_compiler_model #(parameter AW = 9) (
    inout  wire          VPWR,
    inout  wire          VGND,
    input  wire          CLK,
    input  wire [3:0]    WE0,
    input  wire          EN0,
    input  wire [AW-1:0] A0,
    input  wire [31:0]   Di0,
    output wire [31:0]   Do0
);
    localparam NB = 1 << (AW - 4);              // 16-word blocks
    reg [31:0] RAM [0:(1<<AW)-1];
    reg [31:0] outreg [0:NB-1];
    wire       powered = (VPWR === 1'b1) && (VGND === 1'b0);
    integer b;
    always @(posedge CLK) begin
        for (b = 0; b < NB; b = b + 1)
            outreg[b] <= (EN0 === 1'b1 && A0[AW-1:4] == b) ? RAM[A0] :
                         (EN0 === 1'b0 || A0[AW-1:4] != b)  ? 32'b0 : 32'bx;
        if (EN0 === 1'b1) begin
            if (WE0[0]) RAM[A0][ 7: 0] <= Di0[ 7: 0];
            if (WE0[1]) RAM[A0][15: 8] <= Di0[15: 8];
            if (WE0[2]) RAM[A0][23:16] <= Di0[23:16];
            if (WE0[3]) RAM[A0][31:24] <= Di0[31:24];
        end
    end
    assign Do0 = powered ? outreg[A0[AW-1:4]] : 32'bx;
endmodule

`ifdef USE_POWER_PINS
module RAM1024 (inout wire VPWR, inout wire VGND, input wire CLK, input wire [3:0] WE0, input wire EN0,
                input wire [9:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    dffram_compiler_model #(.AW(10)) m (.VPWR(VPWR), .VGND(VGND), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule
module RAM512 (inout wire VPWR, inout wire VGND, input wire CLK, input wire [3:0] WE0, input wire EN0,
               input wire [8:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    dffram_compiler_model #(.AW(9)) m (.VPWR(VPWR), .VGND(VGND), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule
`else
module RAM1024 (input wire CLK, input wire [3:0] WE0, input wire EN0,
                input wire [9:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    supply1 vp; supply0 vg;
    dffram_compiler_model #(.AW(10)) m (.VPWR(vp), .VGND(vg), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule
module RAM512 (input wire CLK, input wire [3:0] WE0, input wire EN0,
               input wire [8:0] A0, input wire [31:0] Di0, output wire [31:0] Do0);
    supply1 vp; supply0 vg;
    dffram_compiler_model #(.AW(9)) m (.VPWR(vp), .VGND(vg), .CLK(CLK), .WE0(WE0), .EN0(EN0), .A0(A0), .Di0(Di0), .Do0(Do0));
endmodule
`endif
