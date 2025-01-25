// // #include "Vfifo_apb_adc_tb.h"  // 确保匹配 Verilator 生成的类
// // #include "verilated.h"
// // #include "verilated_vcd_c.h"
// // #include <iostream>

// // int main(int argc, char **argv) {
// //     Verilated::commandArgs(argc, argv);
// //     Vfifo_apb_adc_tb *dut = new Vfifo_apb_adc_tb;  // 确保与 Verilog 顶层模块匹配

// //     // 启用波形转储
// //     Verilated::traceEverOn(true);
// //     VerilatedVcdC *trace = new VerilatedVcdC;
// //     dut->trace(trace, 99);
// //     trace->open("wave.vcd");

// //     // 初始化时钟和复位
// //     dut->clk = 0;
// //     dut->rst_n = 0;
// //     dut->adc_wr_en = 0;
// //     dut->adc_data = 0;
// //     dut->apb_rd_en = 0;
// //     dut->fifo_clear = 0;

// //     // 生成时钟信号
// //     for (int i = 0; i < 10; i++) {
// //         dut->clk = !dut->clk;
// //         dut->eval();
// //     }
// //     dut->rst_n = 1;

// //     // 写入 FIFO
// //     for (int i = 0; i < 5; i++) {
// //         dut->adc_wr_en = 1;
// //         dut->adc_data = 0xAABBCCDD0011 + i;
// //         for (int j = 0; j < 2; j++) {
// //             dut->clk = !dut->clk;
// //             dut->eval();
// //             trace->dump(i * 10 + j);
// //         }
// //     }
// //     dut->adc_wr_en = 0;

// //     // 读取 FIFO
// //     for (int i = 0; i < 5; i++) {
// //         dut->apb_rd_en = 1;
// //         for (int j = 0; j < 2; j++) {
// //             dut->clk = !dut->clk;
// //             dut->eval();
// //             trace->dump(i * 10 + j);
// //         }
// //         std::cout << "Read Data: " << std::hex << dut->apb_rd_data << std::endl;
// //     }
// //     dut->apb_rd_en = 0;

// //     trace->close();
// //     delete dut;
// //     return 0;
// // }
// #include "Vfifo_apb_adc_tb.h"
// #include "verilated.h"
// #include "verilated_vcd_c.h"
// #include <iostream>

// int main(int argc, char **argv) {
//     Verilated::commandArgs(argc, argv);
//     Vfifo_apb_adc_tb *dut = new Vfifo_apb_adc_tb;
    
//     // 启用波形
//     Verilated::traceEverOn(true);
//     VerilatedVcdC *trace = new VerilatedVcdC;
//     dut->trace(trace, 99);
//     trace->open("wave.vcd");

//     // 初始化
//     bool clk = 0;
//     dut->rst_n = 0;
//     dut->adc_wr_en = 0;
//     dut->adc_data = 0;
//     dut->apb_rd_en = 0;
//     dut->fifo_clear = 0;

//     // 复位周期
//     for (int i = 0; i < 5; i++) {
//         clk = !clk;
//         dut->eval();
//         trace->dump(i * 10);
//     }
//     dut->rst_n = 1; // 释放复位

//     // 写入 FIFO
//     for (int i = 0; i < 5; i++) {
//         clk = !clk;
//         dut->adc_wr_en = 1;
//         dut->adc_data = (0xAABBCCDD0011 + i);
//         dut->eval();
//         trace->dump(i * 10);
//     }
//     dut->adc_wr_en = 0;

//     // 读取 FIFO
//     for (int i = 0; i < 5; i++) {
//         clk = !clk;
//         dut->apb_rd_en = 1;
//         dut->eval();
//         std::cout << "Read Data: " << std::hex << dut->apb_rd_data << std::endl;
//         trace->dump(i * 10);
//     }
//     dut->apb_rd_en = 0;

//     // 结束
//     trace->close();
//     delete dut;
//     return 0;
// }
#include "Vfifo_apb_adc_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vfifo_apb_adc_tb *dut = new Vfifo_apb_adc_tb;
    
    // 启用波形
    Verilated::traceEverOn(true);
    VerilatedVcdC *trace = new VerilatedVcdC;
    dut->trace(trace, 99);
    trace->open("wave.vcd");

    // 初始化
    bool clk = 0;
    dut->rst_n = 0;
    dut->eval();
    
    for (int i = 0; i < 10; i++) {
        clk = !clk;
        dut->eval();
        trace->dump(i * 10);
    }

    dut->rst_n = 1;

    // 写入 FIFO
    for (int i = 0; i < 5; i++) {
        clk = !clk;
        dut->adc_wr_en = 1;
        dut->adc_data = (0xAABBCCDD0011 + i);
        dut->eval();
        trace->dump(i * 10);
    }
    dut->adc_wr_en = 0;

    // 结束
    trace->close();
    delete dut;
    return 0;
}
