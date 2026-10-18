`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// sar_comp_latch.v
//
// Active-low (NAND) SR latch between the sar_afe comparator and sarlogic.
//
// The comparator resets BOTH outputs HIGH while its clk is low. On the rising
// edge exactly one output falls: outn when the vinp side wins (the bit is 1),
// outp when the vinn side wins (the bit is 0). The latch holds that decision
// through the next reset, so sarlogic samples a stable comp on the following
// rising edge of its clock:
//
//     q  = NAND(outn, qn)      outn falls -> q = 1
//     qn = NAND(outp, q)       outp falls -> q = 0     both high -> hold
//
// q has the polarity of the behavioural sr_latch's q (s = outp, r = outn), but
// the behavioural latch gives x on {1,1}; this one holds.
//
// Built from two sky130_fd_sc_hd__nand2_1 cells so that the netlist is exactly
// this structure. sar_adc.sdc sets dont_touch on them and breaks the loop with
// set_disable_timing (u_nand_qn B->Y, so both decision paths to q stay timed).
// Instance names u_nand_q / u_nand_qn are referenced by that SDC.
//
// Simulation needs a model of the cell: ADC/sim/sky130_fd_sc_hd__nand2_1.v
// (sim-only), or the PDK's functional Verilog.
// -----------------------------------------------------------------------------
module sar_comp_latch (
`ifdef USE_POWER_PINS
    inout  wire vdd,
    inout  wire vss,
`endif
    input  wire outp,   // comparator outputs, both high in reset
    input  wire outn,
    output wire q,      // comp: 1 when outn fell (vinp > vinn)
    output wire qn
);

    sky130_fd_sc_hd__nand2_1 u_nand_q (
`ifdef USE_POWER_PINS
        .VPWR (vdd),
        .VGND (vss),
        .VPB  (vdd),
        .VNB  (vss),
`endif
        .A    (outn),
        .B    (qn),
        .Y    (q)
    );

    sky130_fd_sc_hd__nand2_1 u_nand_qn (
`ifdef USE_POWER_PINS
        .VPWR (vdd),
        .VGND (vss),
        .VPB  (vdd),
        .VNB  (vss),
`endif
        .A    (outp),
        .B    (q),
        .Y    (qn)
    );

endmodule
