module dummy_adc
#(
parameter DATA_WIDTH = 32
)
(
input wire [DATA_WIDTH-1 : 0] STATUS_REG_ADDR,
input wire [DATA_WIDTH-1 : 0] MEASUREMENT,
input wire [DATA_WIDTH-1 : 0] PLL_CONTROL,
input wire [DATA_WIDTH-1 : 0] AMUX,
input wire [DATA_WIDTH-1 : 0] ADC_TRIGGER
);

endmodule