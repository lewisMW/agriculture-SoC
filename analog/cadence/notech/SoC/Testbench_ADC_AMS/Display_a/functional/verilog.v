//Verilog HDL for "Testench", "Display_a" "functional"



`include "disciplines.vams"

module Display_a(input electrical in, output reg out);

    parameter real vth = 0.9;

    analog begin
        @(cross(V(in) - vth, +1)) out = 1'b1;
        @(cross(V(in) - vth, -1)) out = 1'b0;
    end

endmodule