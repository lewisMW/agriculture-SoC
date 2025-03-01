`define IDLE 5'd0   //waiting for trigger
`define PRE_CHECK_FIFO 5'd1
`define ENABLE_ADC 5'd2
`define ADC_WARMUP 5'd3
`define MEASUREMENT_START 5'd4
`define POST_CHECK_FIFO 5'd5
`define SIGNAL_FIFO_FULL 5'd6
`define ERR_FIFO_PRE_CHECK_FAIL 5'd7

module wrapper_control(
    input  wire clk,
    input  wire rst,

    input wire rtc_trig,

    input wire fifo_full,
    output reg fifo_write_en,

    output reg adc_enable,
    input wire adc_ready,
    output reg adc_start,
    input wire adc_done,

    output reg apb_fifo_ready
);

reg [4:0] current_state, next_state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= `IDLE;

        adc_enable     <= 1'b0;
        adc_start      <= 1'b0;
        fifo_write_en  <= 1'b0;
        apb_fifo_ready <= 1'b0;
    end else begin
        current_state <= next_state;

        case (current_state)
            `IDLE: begin
                adc_enable     <= 1'b0;
                adc_start      <= 1'b0;
                fifo_write_en  <= 1'b0;
                apb_fifo_ready <= 1'b0;

                if (rtc_trig)
                    next_state <= `PRE_CHECK_FIFO;
            end

            `PRE_CHECK_FIFO: begin
                if (!fifo_full)
                    next_state <= `ENABLE_ADC;
                else
                    next_state <= `ERR_FIFO_PRE_CHECK_FAIL;
            end

            `ENABLE_ADC: begin
                adc_enable <= 1;

                next_state <= `ADC_WARMUP;
            end

            `ADC_WARMUP: begin
                if (adc_ready)
                    next_state <= `MEASUREMENT_START;
            end

            `MEASUREMENT_START: begin
                adc_start <= 1;
                fifo_write_en <= 1;

                if (adc_done)
                    next_state <= `POST_CHECK_FIFO;
            end

            `POST_CHECK_FIFO: begin 
                if (fifo_full)
                    next_state <= `SIGNAL_FIFO_FULL;
                else
                    next_state <= `IDLE;
            end

            `SIGNAL_FIFO_FULL: begin
                apb_fifo_ready <= 1;

                next_state <= `IDLE;
            end

            `ERR_FIFO_PRE_CHECK_FAIL: begin
                // TODO: Error handling
                apb_fifo_ready <= 1;
                
                next_state <= `IDLE;
            end

            default: begin
                next_state <= `IDLE;
            end
        endcase
    end
end

endmodule