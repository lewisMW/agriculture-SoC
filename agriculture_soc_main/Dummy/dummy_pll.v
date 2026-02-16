module dummy_pll #(
    parameter DATA_WIDTH = 32
)(
    input wire [DATA_WIDTH - 1 : 0] PLL_CONTROL,
    input wire clk,
    input wire reset
);

reg [DATA_WIDTH - 1 : 0] PLL_CONTROL_PREV;

always @(posedge clk or posedge reset) begin
    if (PLL_CONTROL != PLL_CONTROL_PREV) begin
        $display("PLL_CONTROL = %h", PLL_CONTROL);
        PLL_CONTROL_PREV <= PLL_CONTROL;
    end
end

endmodule