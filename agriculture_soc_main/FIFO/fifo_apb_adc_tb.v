// `timescale 1ns/1ps

// module fifo_apb_adc_tb(
//     input wire clk,       // 让 Verilator 识别 clk
//     input wire rst_n,     // 让 Verilator 识别 rst_n
//     output reg adc_wr_en,
//     output reg [55:0] adc_data,
//     input  wire fifo_full,
//     output reg apb_rd_en,
//     input  wire [55:0] apb_rd_data,
//     input  wire fifo_empty,
//     output reg fifo_clear
// );

//     // Instantiate FIFO module
//     fifo_apb_adc #(
//         .DATA_WIDTH(56),
//         .DEPTH(120)
//     ) dut (
//         .clk(clk),
//         .rst_n(rst_n),
//         .adc_wr_en(adc_wr_en),
//         .adc_data(adc_data),
//         .fifo_full(fifo_full),
//         .apb_rd_en(apb_rd_en),
//         .apb_rd_data(apb_rd_data),
//         .fifo_empty(fifo_empty),
//         .fifo_clear(fifo_clear)
//     );

// endmodule


//     // Clock Generation
//     always #5 clk = ~clk; // 10ns clock cycle

//     // Test Sequence
//     initial begin
//         // Initialize signals
//         clk        = 0;
//         rst_n      = 0;
//         adc_wr_en  = 0;
//         adc_data   = 0;
//         apb_rd_en  = 0;
//         fifo_clear = 0;

//         // Reset the FIFO
//         #20 rst_n = 1;
//         $display("FIFO Reset Done.");

//         // Write data into FIFO
//         $display("Starting FIFO Write...");
//         repeat (5) begin
//             @(posedge clk);
//             if (!fifo_full) begin
//                 adc_wr_en = 1;
//                 adc_data = {$random, $random[23:0]}; // Ensure 56-bit random value
//                 $display("Writing ADC Data: %h", adc_data);
//             end
//         end
//         adc_wr_en = 0;

//         // Read data from FIFO
//         #20;
//         $display("Starting FIFO Read...");
//         repeat (5) begin
//             @(posedge clk);
//             if (!fifo_empty) begin
//                 apb_rd_en = 1;
//                 $display("Reading FIFO Data: %h", apb_rd_data);
//             end
//         end
//         apb_rd_en = 0;

//         // Test FIFO Full
//         #20;
//         $display("Testing FIFO Full Condition...");
//         repeat (DEPTH) begin
//             @(posedge clk);
//             if (!fifo_full) begin
//                 adc_wr_en = 1;
//                 adc_data = {$random, $random[23:0]};
//             end
//         end
//         adc_wr_en = 0;
//         #10;
//         if (fifo_full) $display("FIFO is Full as expected.");

//         // Test FIFO Clear
//         #20;
//         $display("Clearing FIFO...");
//         fifo_clear = 1;
//         #10;
//         fifo_clear = 0;
//         if (fifo_empty) $display("FIFO Successfully Cleared.");

//         // End Simulation
//         #50;
//         $display("Simulation Complete.");
//         $finish;
//     end

// endmodule
// module fifo_apb_adc_tb;

//     // Parameters
//     parameter DATA_WIDTH = 56;
//     parameter DEPTH = 120;

//     // Signals
//     reg clk;
//     reg rst_n;
    
//     // ADC Interface
//     reg                  adc_wr_en;
//     reg [DATA_WIDTH-1:0] adc_data;
//     wire                 fifo_full;

//     // APB Interface
//     reg                  apb_rd_en;
//     wire [DATA_WIDTH-1:0] apb_rd_data;
//     wire                 fifo_empty;
//     reg                  fifo_clear;

//     // **添加 Verilator public 以暴露信号**
//     /* verilator public_module */
//     /* verilator public_flat_rw */

//     // Instantiate FIFO module
//     fifo_apb_adc #(
//         .DATA_WIDTH(DATA_WIDTH),
//         .DEPTH(DEPTH)
//     ) dut (
//         .clk(clk),
//         .rst_n(rst_n),
//         .adc_wr_en(adc_wr_en),
//         .adc_data(adc_data),
//         .fifo_full(fifo_full),
//         .apb_rd_en(apb_rd_en),
//         .apb_rd_data(apb_rd_data),
//         .fifo_empty(fifo_empty),
//         .fifo_clear(fifo_clear)
//     );

//     // Clock Generation
//     always #5 clk = ~clk; // 10ns clock cycle

//     // Test Sequence
//     initial begin
//         // Initialize signals
//         clk        = 0;
//         rst_n      = 0;
//         adc_wr_en  = 0;
//         adc_data   = 0;
//         apb_rd_en  = 0;
//         fifo_clear = 0;

//         // Reset the FIFO
//         #20 rst_n = 1;
//         $display("FIFO Reset Done.");
//     end

// endmodule

`timescale 1ns/1ps

module fifo_apb_adc_tb;

    parameter DATA_WIDTH = 56;
    parameter DEPTH = 16;

    // 信号定义
    reg clk;
    reg rst_n;
    reg adc_wr_en;
    reg [DATA_WIDTH-1:0] adc_data;
    wire fifo_full;
    reg apb_rd_en;
    wire [DATA_WIDTH-1:0] apb_rd_data;
    wire fifo_empty;
    reg fifo_clear;

    // 例化 FIFO
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

    // **时钟生成**
    always #5 clk = ~clk; // 10ns 时钟周期

    // **波形记录**
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_apb_adc_tb);
    end

    // **测试流程**
    initial begin
        clk = 0;
        rst_n = 0;
        adc_wr_en = 0;
        adc_data = 0;
        apb_rd_en = 0;
        fifo_clear = 0;

        // **复位**
        #20 rst_n = 1;
        $display("FIFO 复位完成");

        // **写入数据**
        $display("开始写入 FIFO...");
        repeat (5) begin
            @(posedge clk);
            if (!fifo_full) begin
                adc_wr_en = 1;
                adc_data = {$random, $random[23:0]};
                $display("写入数据: %h", adc_data);
            end
        end
        adc_wr_en = 0;

        // **读取数据**
        #20;
        $display("开始读取 FIFO...");
        repeat (5) begin
            @(negedge clk);
            if (!fifo_empty) begin
                apb_rd_en = 1;
                $display("read_data: %h", apb_rd_data);
            end
        end
        apb_rd_en = 0;

        // **清空 FIFO**
        #20;
        $display("清空 FIFO...");
        fifo_clear = 1;
        #10;
        fifo_clear = 0;
        if (fifo_empty) $display("FIFO 清空成功！");

        // **结束仿真**
        #50;
        $display("仿真结束");
        $finish;
    end

endmodule
