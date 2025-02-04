module fifo_apb_adc #(
    parameter DATA_WIDTH = 56,
    parameter DEPTH = 16
)(
    input wire clk,                     // Clock
    input wire rst_n,                   // Reset (active low)

    // ADC Write Interface
    input wire adc_wr_en,
    input wire [DATA_WIDTH-1:0] adc_data,
    output wire fifo_full,

    // APB Read Interface
    input wire apb_rd_en,
    output wire [DATA_WIDTH-1:0] apb_rd_data,
    output wire fifo_empty,
    input wire fifo_clear
);

    // FIFO Storage
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

    // Read/Write Pointers
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH):0] count;

    // Write Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            wr_ptr <= 0;
        end else if (adc_wr_en && !fifo_full) begin
            fifo_mem[wr_ptr] <= adc_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            rd_ptr <= 0;
        end else if (apb_rd_en && !fifo_empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Counter Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            count <= 0;
        end else begin
            case ({adc_wr_en, apb_rd_en})
                2'b10: count <= count + 1;  // Write
                2'b01: count <= count - 1;  // Read
                default: count <= count;
            endcase
        end
    end

    // Status Signals
    assign fifo_full  = (count == DEPTH);
    assign fifo_empty = (count == 0);
    assign apb_rd_data = fifo_mem[rd_ptr];

endmodule
