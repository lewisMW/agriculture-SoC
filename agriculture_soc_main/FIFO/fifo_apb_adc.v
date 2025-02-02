// // module fifo_apb_adc #(
// //     parameter DATA_WIDTH = 56,  // FIFO data width (14-bit ADC + 34-bit Timestamp + 8-bit Sensor ID)
// //     parameter DEPTH = 120       // FIFO depth (stores 24 hours of data, 5 samples per hour)
// // )(
// //     input  wire                 clk,        // Clock signal (might shared between ADC and APB)
// //     input  wire                 rst_n,      // reset

// //     // ADC Write Interface
// //     input  wire                 adc_wr_en,  // ADC write enable signal
// //     input  wire [DATA_WIDTH-1:0] adc_data,   // ADC sampled data (including metadata)
// //     output wire                 fifo_full,  // FIFO full signal, informs ADC to stop writing

// //     // APB Read Interface
// //     input  wire                 apb_rd_en,  // APB read enable signal
// //     output wire [DATA_WIDTH-1:0] apb_rd_data,// APB read data output
// //     output wire                 fifo_empty, // FIFO empty signal, prevents APB from reading empty FIFO
// //     input  wire                 fifo_clear  // APB clear signal, resets the FIFO
// // );

// //     // Internal FIFO memory storage
// //     reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

// //     // Read/Write Pointers
// //     reg [$clog2(DEPTH)-1:0] wr_ptr;  // Write pointer
// //     reg [$clog2(DEPTH)-1:0] rd_ptr;  // Read pointer
// //     reg [($clog2(DEPTH)):0] count;   // Counter to track FIFO occupancy

// //     // FIFO Write Logic (ADC → FIFO)
// //     always @(posedge clk or negedge rst_n) begin
// //         if (!rst_n || fifo_clear) begin
// //             wr_ptr <= 0;
// //         end else if (adc_wr_en && !fifo_full) begin
// //             fifo_mem[wr_ptr] <= adc_data;
// //             wr_ptr <= wr_ptr + 1;
// //         end
// //     end

// //     // FIFO Read Logic (FIFO → APB)
// //     always @(posedge clk or negedge rst_n) begin
// //         if (!rst_n || fifo_clear) begin
// //             rd_ptr <= 0;
// //         end else if (apb_rd_en && !fifo_empty) begin
// //             rd_ptr <= rd_ptr + 1;
// //         end
// //     end

// //     // FIFO Counter Logic
// //     always @(posedge clk or negedge rst_n) begin
// //         if (!rst_n || fifo_clear) begin
// //             count <= 0;
// //         end else begin
// //             case ({adc_wr_en, apb_rd_en})
// //                 2'b10: count <= count + 1; // Write operation (ADC → FIFO)
// //                 2'b01: count <= count - 1; // Read operation (FIFO → APB)
// //                 default: count <= count;   // No operation
// //             endcase
// //         end
// //     end

// //     // FIFO Status Flags
// //     assign fifo_full  = (count == DEPTH);
// //     assign fifo_empty = (count == 0);
// //     assign apb_rd_data = fifo_mem[rd_ptr];

// // endmodule
// module fifo_apb_adc #(
//     parameter DATA_WIDTH = 56,
//     parameter DEPTH = 120
// )(
//     input  wire                 clk,
//     input  wire                 rst_n,

//     // ADC Write Interface
//     input  wire                 adc_wr_en,
//     input  wire [DATA_WIDTH-1:0] adc_data,
//     output wire                 fifo_full,

//     // APB Read Interface
//     input  wire                 apb_rd_en,
//     output wire [DATA_WIDTH-1:0] apb_rd_data,
//     output wire                 fifo_empty,
//     input  wire                 fifo_clear
// );

//     // Internal FIFO memory storage
//     reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

//     // Read/Write Pointers
//     reg [$clog2(DEPTH)-1:0] wr_ptr;
//     reg [$clog2(DEPTH)-1:0] rd_ptr;
//     reg [($clog2(DEPTH)):0] count;

//     // FIFO Write Logic
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             wr_ptr <= 0;
//         end else if (adc_wr_en && !fifo_full) begin
//             fifo_mem[wr_ptr] <= adc_data;
//             wr_ptr <= wr_ptr + 1;
//         end
//     end

//     // FIFO Read Logic
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             rd_ptr <= 0;
//         end else if (apb_rd_en && !fifo_empty) begin
//             rd_ptr <= rd_ptr + 1;
//         end
//     end

//     // FIFO Counter Logic
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             count <= 0;
//         end else begin
//             case ({adc_wr_en, apb_rd_en})
//                 2'b10: count <= count + 1;
//                 2'b01: count <= count - 1;
//                 default: count <= count;
//             endcase
//         end
//     end

//     // FIFO Status Flags
//     assign fifo_full  = (count == DEPTH);
//     assign fifo_empty = (count == 0);
//     assign apb_rd_data = fifo_mem[rd_ptr];

// endmodule
// module fifo_apb_adc #(
//     parameter DATA_WIDTH = 56,
//     parameter DEPTH = 16
// )(
//     input wire clk,                     // ✅ 作为输入
//     input wire rst_n,                   // ✅ 作为输入
//     input wire adc_wr_en,
//     input wire [DATA_WIDTH-1:0] adc_data,
//     output wire fifo_full,
//     input wire apb_rd_en,
//     output wire [DATA_WIDTH-1:0] apb_rd_data,
//     output wire fifo_empty,
//     input wire fifo_clear
// );


//     /* verilator public */
//     reg clk;
//     reg rst_n;
//     reg adc_wr_en;
//     reg [DATA_WIDTH-1:0] adc_data;
//     reg apb_rd_en;
//     reg fifo_clear;

//     /* verilator public */
//     wire fifo_full;
//     wire [DATA_WIDTH-1:0] apb_rd_data;
//     wire fifo_empty;

//     // 内部 FIFO 存储
//     reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

//     // 读写指针
//     reg [$clog2(DEPTH)-1:0] wr_ptr;
//     reg [$clog2(DEPTH)-1:0] rd_ptr;
//     reg [$clog2(DEPTH):0] count;

//     // 写入逻辑
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             wr_ptr <= 0;
//         end else if (adc_wr_en && !fifo_full) begin
//             fifo_mem[wr_ptr] <= adc_data;
//             wr_ptr <= wr_ptr + 1;
//         end
//     end

//     // 读取逻辑
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             rd_ptr <= 0;
//         end else if (apb_rd_en && !fifo_empty) begin
//             rd_ptr <= rd_ptr + 1;
//         end
//     end

//     // 计数器逻辑
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n || fifo_clear) begin
//             count <= 0;
//         end else begin
//             case ({adc_wr_en, apb_rd_en})
//                 2'b10: count <= count + 1;
//                 2'b01: count <= count - 1;
//                 default: count <= count;
//             endcase
//         end
//     end

//     // 状态标志
//     assign fifo_full  = (count == DEPTH);
//     assign fifo_empty = (count == 0);
//     assign apb_rd_data = fifo_mem[rd_ptr];

// endmodule


module fifo_apb_adc #(
    parameter DATA_WIDTH = 56,
    parameter DEPTH = 16
)(
    input wire clk,                     // 时钟
    input wire rst_n,                   // 复位

    // ADC 写入接口
    input wire adc_wr_en,
    input wire [DATA_WIDTH-1:0] adc_data,
    output wire fifo_full,

    // APB 读取接口
    input wire apb_rd_en,
    output wire [DATA_WIDTH-1:0] apb_rd_data,
    output wire fifo_empty,
    input wire fifo_clear
);

    // FIFO 存储
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

    // 读写指针
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH):0] count;

    // 写入逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            wr_ptr <= 0;
        end else if (adc_wr_en && !fifo_full) begin
            fifo_mem[wr_ptr] <= adc_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // 读取逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            rd_ptr <= 0;
        end else if (apb_rd_en && !fifo_empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    // 计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fifo_clear) begin
            count <= 0;
        end else begin
            case ({adc_wr_en, apb_rd_en})
                2'b10: count <= count + 1;  // 写入
                2'b01: count <= count - 1;  // 读取
                default: count <= count;
            endcase
        end
    end

    // 状态信号
    assign fifo_full  = (count == DEPTH);
    assign fifo_empty = (count == 0);
    assign apb_rd_data = fifo_mem[rd_ptr];

endmodule