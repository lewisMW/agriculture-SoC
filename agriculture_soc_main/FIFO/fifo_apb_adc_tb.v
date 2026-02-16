`timescale 1ns/1ps

module fifo_apb_adc_tb;

    parameter DATA_WIDTH = 56;
    parameter DEPTH = 16;

    // Signal definitions
    reg clk;
    reg rst_n;
    reg adc_wr_en;
    reg [DATA_WIDTH-1:0] adc_data;
    wire fifo_full;
    reg apb_rd_en;
    wire [DATA_WIDTH-1:0] apb_rd_data;
    wire fifo_empty;
    reg fifo_clear;

    // Instantiate the FIFO
    fifo_apb_adc #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .adc_wr_en(adc_wr_en),
        .adc_data(adc_data),
        .fifo_full(fifo_full),
        .apb_rd_en(apb_rd_en),
        .apb_rd_data(apb_rd_data),
        .fifo_empty(fifo_empty),
        .fifo_clear(fifo_clear)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk; 

    // Waveform dumping
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_apb_adc_tb);
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk        = 0;
        rst_n      = 0;
        adc_wr_en  = 0;
        adc_data   = 0;
        apb_rd_en  = 0;
        fifo_clear = 0;

        // Reset
        #20 rst_n = 1;
        $display("FIFO reset completed");

        // Write data to FIFO
        $display("Start writing to FIFO...");
        repeat (5) begin
            @(posedge clk);
            if (!fifo_full) begin
                adc_wr_en = 1;
                adc_data = {$random, $random[23:0]};
                $display("Data written: %h", adc_data);
            end
        end
        adc_wr_en = 0;

        // Read data from FIFO
        #20;
        $display("Start reading from FIFO...");
        repeat (5) begin
            @(negedge clk);
            if (!fifo_empty) begin
                apb_rd_en = 1;
                $display("Data read: %h", apb_rd_data);
            end
        end
        apb_rd_en = 0;

        // Clear FIFO
        #20;
        $display("Clearing FIFO...");
        fifo_clear = 1;
        #10;
        fifo_clear = 0;
        if (fifo_empty) $display("FIFO cleared successfully!");

        // End simulation
        #50;
        $display("Simulation completed");
        $finish;
    end

endmodule
