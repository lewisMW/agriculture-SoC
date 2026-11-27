`timescale 1ns/1ps
// tb_dffram_gl.v -- one pre-hardened DFFRAM block as its gate netlist (OL-DFFRAM
// hdl/gl), optionally with its own SDF, against a reference array.
//
//   +define+DUTMOD=DFFRAM128x32 +define+AW=7   the block and its address width
//   +define+SDFFILE="\"...sdf\""               annotate the block's delays
//   +define+HALF=15                            half the clock period, ns
//   +define+TIN=3                              inputs change this long after the
//                                              rising edge, as a flop-driven bus does
// Needs preload.vh from dffram_gl_preload.py (name u, path dut) on the include path.
//
// Checks: (1) the backdoor preload (deposit into the latches) reads back through
// the port; (2) random writes (all byte-enable patterns), reads and idle cycles;
// (3) every word again at the end, through the port and through the backdoor.
// A read's data is checked just before the next rising edge; a cycle that writes
// is not checked as a read.
module tb_dffram_gl;
    localparam AW = `AW;
    localparam N  = 1 << AW;
    reg           clk = 1'b0;
    reg           en  = 1'b0;
    reg  [3:0]    we  = 4'b0;
    reg  [AW-1:0] a   = {AW{1'b0}};
    reg  [31:0]   di  = 32'b0;
    wire [31:0]   dout;
    supply1 vp; supply0 vg;

    `DUTMOD dut (.CLK(clk), .EN0(en), .VGND(vg), .VPWR(vp), .A0(a), .Di0(di), .Do0(dout), .WE0(we));

    `include "preload.vh"

`ifdef SDFFILE
    initial $sdf_annotate(`SDFFILE, dut, , "sdf_unit.log", "MAXIMUM");
`endif

    always #(`HALF) clk = ~clk;

    reg [31:0] ref_mem [0:N-1];
    integer    errs = 0, checks = 0, writes = 0, k, seed = 32'h5eed1234;
    reg [31:0] t;

    // Do0 as it stands just before each rising edge
    reg [31:0] dout_s;
    always @(posedge clk) begin #(2 * `HALF - 0.3) dout_s = dout; end

    // what the block took at each rising edge, and the read it then owes: the
    // data of a read taken at one edge is checked just before the next
    reg          p1_v = 1'b0;
    reg [31:0]   p1_d;
    reg [AW-1:0] p1_a;
    always @(posedge clk) begin
        if (p1_v) begin
            checks = checks + 1;
            if (dout_s !== p1_d) begin
                errs = errs + 1;
                if (errs <= 12) $display("FAIL @%0t read word %0d: got %h, expected %h", $time, p1_a, dout_s, p1_d);
            end
        end
        p1_v <= (en === 1'b1) && (we === 4'b0); p1_d <= ref_mem[a]; p1_a <= a;
        if (en === 1'b1 && we !== 4'b0) begin
            writes = writes + 1;
            if (we[0]) ref_mem[a][ 7: 0] = di[ 7: 0];
            if (we[1]) ref_mem[a][15: 8] = di[15: 8];
            if (we[2]) ref_mem[a][23:16] = di[23:16];
            if (we[3]) ref_mem[a][31:24] = di[31:24];
        end
    end

    task cyc(input e, input [3:0] w, input [AW-1:0] ad, input [31:0] d);
        begin @(posedge clk); #(`TIN); en = e; we = w; a = ad; di = d; end
    endtask

    integer r;
    initial begin
        #1;
        for (k = 0; k < N; k = k + 1) begin
            t = (k * 32'h9E3779B1) ^ 32'hA5A5A5A5;
            ref_mem[k] = t;
            of_dep_u(k, t);
        end
        repeat (4) cyc(1'b0, 4'b0, 0, 32'b0);
        // (1) the preload, through the port
        for (k = 0; k < N; k = k + 1) cyc(1'b1, 4'b0, k, 32'hx);
        repeat (3) cyc(1'b0, 4'b0, 0, 32'b0);
        $display("after preload read-back: %0d checks, %0d errors", checks, errs);
        // (2) random traffic
        for (k = 0; k < 6000; k = k + 1) begin
            r = $random(seed);
            case (r[3:0])
                0, 1, 2:          cyc(1'b0, r[7:4], r[8+:AW], $random(seed));           // idle, other inputs moving
                3, 4, 5, 6, 7, 8: cyc(1'b1, (r[7:4] == 4'b0) ? 4'b1111 : r[7:4], r[8+:AW], $random(seed));
                default:          cyc(1'b1, 4'b0, r[8+:AW], $random(seed));
            endcase
        end
        repeat (3) cyc(1'b0, 4'b0, 0, 32'b0);
        $display("after random traffic: %0d writes, %0d checks, %0d errors", writes, checks, errs);
        // (3) every word again
        for (k = 0; k < N; k = k + 1) cyc(1'b1, 4'b0, k, 32'hx);
        repeat (3) cyc(1'b0, 4'b0, 0, 32'b0);
        for (k = 0; k < N; k = k + 1) begin
            of_peek_u(k, t);
            checks = checks + 1;
            if (t !== ref_mem[k]) begin
                errs = errs + 1;
                if (errs <= 12) $display("FAIL backdoor word %0d: latches hold %h, expected %h", k, t, ref_mem[k]);
            end
        end
        $display("%0d writes, %0d checks: %0d PASSED, %0d FAILED", writes, checks, checks - errs, errs);
        $finish;
    end
endmodule
