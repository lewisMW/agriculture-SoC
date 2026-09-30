module fifo_apb_adc #(
    parameter DATA_WIDTH = 64,
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
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (fifo_clear) begin
            wr_ptr <= 0;
        end else if (adc_wr_en && !fifo_full) begin
            fifo_mem[wr_ptr] <= adc_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
        end else if (fifo_clear) begin
            rd_ptr <= 0;
        end else if (apb_rd_en && !fifo_empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    // A write/read only actually happens when there is room / data. Mirror the
    // gating used by the pointer logic so count can never over/underflow (the
    // previous version incremented count on a write even when full).
    wire do_wr = adc_wr_en & ~fifo_full;
    wire do_rd = apb_rd_en & ~fifo_empty;

    // Counter Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear)
            count <= 0;
        else if (do_wr & ~do_rd)
            count <= count + 1'b1;
        else if (~do_wr & do_rd)
            count <= count - 1'b1;
    end

    // Status Signals
    assign fifo_full  = (count == DEPTH);
    assign fifo_empty = (count == 0);
    assign apb_rd_data = fifo_mem[rd_ptr];

endmodule
