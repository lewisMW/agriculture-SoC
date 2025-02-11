module dummy_amux
#(
    parameter AMUX_INPUTS = 4
)
(
    input wire [$clog2(AMUX_INPUTS)-1:0] INPUT_SEL,
    output wire ANALOG_PASSTHROUGH   // This is an analog wire
);
    // TODO: Implement the AMUX logic here  

    always @(INPUT_SEL) begin
        $display("INPUT_SEL = %h", INPUT_SEL);
    end
endmodule

