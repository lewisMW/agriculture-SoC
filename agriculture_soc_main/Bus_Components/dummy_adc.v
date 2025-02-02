module dummy_adc
#(
parameter DATA_WIDTH = 32
)
(
input wire [DATA_WIDTH-1 : 0] STATUS_REG_ADDR,
input wire [DATA_WIDTH-1 : 0] MEASUREMENT,
input wire [DATA_WIDTH-1 : 0] ADC_TRIGGER,
input wire ANALOG_IN   // This is an analog wire
);

always @(STATUS_REG_ADDR) begin
    $display("STATUS_REG_ADDR = %h", STATUS_REG_ADDR);
end

always @(MEASUREMENT) begin
    $display("MEASUREMENT = %h", MEASUREMENT);
end

always @(PLL_CONTROL) begin
    $display("PLL_CONTROL = %h", PLL_CONTROL);
end

always @(ADC_TRIGGER) begin
    $display("ADC_TRIGGER = %h", ADC_TRIGGER);
end

always @(ANALOG_IN) begin
    $display("ANALOG_IN = %h", ANALOG_IN);
end

endmodule