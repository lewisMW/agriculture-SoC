//Verilog HDL for "Testench", "Display" "functional"




`include "disciplines.vams"

module Disp(input electrical in, output reg out);

    parameter real vth = 0.9;

    analog begin
        @(cross(V(in) - vth, +1)) out = 1'b1;
        @(cross(V(in) - vth, -1)) out = 1'b0;
    end

endmodule