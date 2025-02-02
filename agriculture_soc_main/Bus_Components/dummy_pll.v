module dummy_pll #(
    parameter DATA_WIDTH = 32
)(
    input wire [DATA_WIDTH - 1 : 0] PLL_CONTROL
);

always @(PLL_CONTROL) begin
    $display("PLL_CONTROL = %h", PLL_CONTROL);
end

endmodule