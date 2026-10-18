`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// sky130_fd_sc_hd__nand2_1.v -- SIMULATION ONLY. Never list it in a synthesis
// filelist: synthesis and the physical flow take the cell from the
// sky130_fd_sc_hd .lib/.lef.
//
// Stand-in for the PDK cell used by sar_comp_latch, so RTL simulations
// (plain and AMS) need no PDK checkout. Same ports, and the same 4-state
// function and zero delay as the PDK's functional model
// (libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v: nand + buf).
// Do not compile it together with that PDK file (duplicate module).
// -----------------------------------------------------------------------------
module sky130_fd_sc_hd__nand2_1 (
`ifdef USE_POWER_PINS
    input  VPWR,
    input  VGND,
    input  VPB,
    input  VNB,
`endif
    output Y,
    input  A,
    input  B
);
    nand (Y, A, B);
endmodule
