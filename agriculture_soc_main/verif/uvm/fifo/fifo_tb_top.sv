// -----------------------------------------------------------------------------
// fifo_tb_top.sv — top module for the FIFO UVM bench.
//   make -C verif/uvm/fifo                 (default test: fifo_full_test)
//   make -C verif/uvm/fifo TEST=fifo_smoke_test SEED=7
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
`include "uvm_macros.svh"

module fifo_tb_top;
    import uvm_pkg::*;
    import fifo_uvm_pkg::*;

    logic clk = 1'b0;
    always #5 clk = ~clk;

    fifo_if #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    fifo_apb_adc #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
        .clk        (clk),
        .rst_n      (vif.rst_n),
        .adc_wr_en  (vif.adc_wr_en),
        .adc_data   (vif.adc_data),
        .fifo_full  (vif.fifo_full),
        .apb_rd_en  (vif.apb_rd_en),
        .apb_rd_data(vif.apb_rd_data),
        .fifo_empty (vif.fifo_empty),
        .fifo_clear (vif.fifo_clear)
    );

    initial begin
        vif.rst_n = 1'b0;
        repeat (3) @(posedge clk);
        @(negedge clk) vif.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if)::set(null, "*", "vif", vif);
        run_test("fifo_full_test");
    end
endmodule
