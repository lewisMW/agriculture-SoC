`timescale 1ns/1ps
module agriculture_soc_tb;

    localparam T = 20;

    reg        clk;
    reg        reset;
    wire [3:0] LED;

    agriculture_soc DUT (.clk(clk), .reset(reset), .LED(LED));

    always #(T/2) clk = ~clk;

    initial
    begin
        $dumpfile("waveform.fst");
        $dumpvars();
        #(10*T);
        clk = 1'b1;
        reset = 1'b0;
        #(5*T);
        reset = 1'b1;
        #(1000*T);
        $finish();
    end

endmodule