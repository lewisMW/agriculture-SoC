`timescale 1ns/1ps
module dummy_adc
#(
    parameter DATA_WIDTH = 32,
    parameter RAND_SEED = 1
)
(
    input  wire [DATA_WIDTH-1:0] STATUS_REG_ADDR,  
    output reg  [DATA_WIDTH-1:0] MEASUREMENT,      
    input  wire [DATA_WIDTH-1:0] ADC_TRIGGER,     
    input  wire                ANALOG_IN,         
    input  wire                clk,               
    input  wire                reset,             
    output reg                 DATA_VALID_OUT     // Data valid pulse 
);

    // Used to detect the rising edge of ADC_TRIGGER
    reg [DATA_WIDTH-1:0] ADC_TRIGGER_PREV;
    reg [DATA_WIDTH-1:0] STATUS_REG_ADDR_PREV;
    reg [DATA_WIDTH-1:0] MEASUREMENT_PREV;
    reg ANALOG_IN_PREV;

    integer seed;
    initial begin
        seed = RAND_SEED;
        ADC_TRIGGER_PREV = 0;
        STATUS_REG_ADDR_PREV = 0;
        MEASUREMENT_PREV = 0;
        ANALOG_IN_PREV = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to initial values
            MEASUREMENT    <= 0;
            DATA_VALID_OUT <= 0;
            ADC_TRIGGER_PREV <= 0;
            STATUS_REG_ADDR_PREV <= 0;
            MEASUREMENT_PREV <= 0;
            ANALOG_IN_PREV <= 0;
        end else begin
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

            // Detect rising edge of ADC_TRIGGER to generate a new measurement
            if (ADC_TRIGGER && !ADC_TRIGGER_PREV) begin
                MEASUREMENT    <= $urandom(); // Generate new data only on a rising edge
                DATA_VALID_OUT <= 1;  // Generate a one-clock-cycle high pulse
                $display("ADC_TRIGGER rising edge detected. New MEASUREMENT = %h", MEASUREMENT);
            end else begin
                DATA_VALID_OUT <= 0; // Keep DATA_VALID_OUT low after one cycle
            end

            // Store the previous ADC_TRIGGER value to detect future edges
            ADC_TRIGGER_PREV <= ADC_TRIGGER;
        end
    end

endmodule
