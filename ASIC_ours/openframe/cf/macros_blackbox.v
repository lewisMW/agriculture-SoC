// Port-only modules for the hard macros (the ADC front end and the DFFRAM
// blocks), compared as black boxes in LVS.
// Verilog and not SPICE so that the bus ranges are explicit: the netlist connects
// buses by concatenation, most significant bit first.
module sar_afe (clk, ctln, ctlp, outn, outp, sample, trima, trimb, vdd, vdda, vinn, vinp, vref, vss);
  input clk;
  input [7:0] ctln;
  input [7:0] ctlp;
  output outn;
  output outp;
  input sample;
  input [4:0] trima;
  input [4:0] trimb;
  inout vdd;
  inout vdda;
  inout vinn;
  inout vinp;
  inout vref;
  inout vss;
endmodule

module DFFRAM512x32 (CLK, WE0, EN0, A0, Di0, Do0, VPWR, VGND);
  input CLK;
  input [3:0] WE0;
  input EN0;
  input [8:0] A0;
  input [31:0] Di0;
  output [31:0] Do0;
  inout VPWR;
  inout VGND;
endmodule

module DFFRAM256x32 (CLK, WE0, EN0, A0, Di0, Do0, VPWR, VGND);
  input CLK;
  input [3:0] WE0;
  input EN0;
  input [7:0] A0;
  input [31:0] Di0;
  output [31:0] Do0;
  inout VPWR;
  inout VGND;
endmodule

module DFFRAM128x32 (CLK, WE0, EN0, A0, Di0, Do0, VPWR, VGND);
  input CLK;
  input [3:0] WE0;
  input EN0;
  input [6:0] A0;
  input [31:0] Di0;
  output [31:0] Do0;
  inout VPWR;
  inout VGND;
endmodule
