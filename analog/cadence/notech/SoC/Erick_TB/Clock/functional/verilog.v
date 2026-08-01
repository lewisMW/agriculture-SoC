//Verilog HDL for "Testench", "Clock" "functional"

`timescale 1ns / 1ps

module Clock (clk);
    parameter cycle = 1000000;	// clock period (ns)
    output clk;
    reg clk;

    initial clk = 0;

    always #(cycle/2) clk = ~clk;
endmodule

