module dummy_adc
#(
parameter DATA_WIDTH = 32,
parameter RAND_SEED = 1
)
(
input wire [DATA_WIDTH-1 : 0] STATUS_REG_ADDR,
output wire [DATA_WIDTH-1 : 0] MEASUREMENT,
input wire [DATA_WIDTH-1 : 0] ADC_TRIGGER,
input wire ANALOG_IN,   // This is an analog wire
input wire clk,
input wire reset
);

reg [DATA_WIDTH-1 : 0] STATUS_REG_ADDR_PREV;
reg [DATA_WIDTH-1 : 0] MEASUREMENT_PREV;
reg [DATA_WIDTH-1 : 0] ADC_TRIGGER_PREV;
reg ANALOG_IN_PREV;

always @(posedge clk or posedge reset) begin
    if (STATUS_REG_ADDR != STATUS_REG_ADDR_PREV) begin
        $display("STATUS_REG_ADDR = %h", STATUS_REG_ADDR);
        STATUS_REG_ADDR_PREV <= STATUS_REG_ADDR;
    end
    if (MEASUREMENT != MEASUREMENT_PREV) begin
        $display("MEASUREMENT = %h", MEASUREMENT);
        MEASUREMENT_PREV <= MEASUREMENT;
    end
    if (ADC_TRIGGER != ADC_TRIGGER_PREV) begin
        $display("ADC_TRIGGER = %h", ADC_TRIGGER);
        ADC_TRIGGER_PREV <= ADC_TRIGGER;
    end
    if (ANALOG_IN != ANALOG_IN_PREV) begin
        $display("ANALOG_IN = %h", ANALOG_IN);
        ANALOG_IN_PREV <= ANALOG_IN;
    end

    MEASUREMENT <= $random; // TODO: set random seed
end

endmodule