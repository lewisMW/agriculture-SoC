module dummy_amux
#(
    parameter AMUX_INPUTS = 4
)
(
    input wire [$clog2(AMUX_INPUTS)-1:0] INPUT_SEL,
    output wire ANALOG_PASSTHROUGH,   // This is an analog wire
    input wire clk
);

    reg [$clog2(AMUX_INPUTS)-1:0] INPUT_SEL_PREV;

    // TODO: Implement the AMUX logic here  

    always @(posedge clk) begin
        if (INPUT_SEL != INPUT_SEL_PREV) begin
            $display("INPUT_SEL = %h", INPUT_SEL);
            INPUT_SEL_PREV <= INPUT_SEL;
        end
    end
    
endmodule