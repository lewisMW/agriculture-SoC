// -----------------------------------------------------------------------------
// sensing_tb_top.sv — top module for the sensing-peripheral UVM bench.
//
//   make -C verif/uvm/wrapper                     (needs ARM_IP_LIBRARY_PATH)
//   make -C verif/uvm/wrapper STUB_RTC=1          (no ARM IP: PL031 stand-in)
//   make -C verif/uvm/wrapper TEST=sensing_smoke_test
//
// CLK1HZ is a FAST stand-in (one "second" every CLK1HZ_HALF*2 PCLKs) so RTC
// alarms fire within a short simulation. nPOR is held separately from PRESETn,
// as on silicon, so a warm reset can be exercised without losing RTC time.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
`include "uvm_macros.svh"

module sensing_tb_top;
    import uvm_pkg::*;
    import apb_uvm_pkg::*;
    import sensing_uvm_pkg::*;

    localparam int CLK1HZ_HALF = 32;

    logic PCLK = 1'b0;
    always #5 PCLK = ~PCLK;

    logic CLK1HZ = 1'b0;
    initial forever begin
        repeat (CLK1HZ_HALF) @(posedge PCLK);
        CLK1HZ = ~CLK1HZ;
    end

    logic nPOR;
    apb_if    #(.ADDR_WIDTH(12)) apb (PCLK);
    sample_if                    smp (PCLK);

    adc_apb_wrapper_rev2 dut (
        .PCLK     (PCLK),
        .CLK1HZ   (CLK1HZ),
        .PRESETn  (apb.PRESETn),
        .nPOR     (nPOR),
        .PSEL     (apb.PSEL),
        .PADDR    (apb.PADDR),
        .PENABLE  (apb.PENABLE),
        .PWRITE   (apb.PWRITE),
        .PWDATA   (apb.PWDATA),
        .PRDATA   (apb.PRDATA),
        .PREADY   (apb.PREADY),
        .PSLVERR  (apb.PSLVERR),
        .APBACTIVE(1'b1),
        .PPROT    (3'b000),
        .PSTRB    (4'hF)
    );

    // FIFO-push snoop for the end-to-end scoreboard
    assign smp.rst_n = apb.PRESETn;
    assign smp.push  = dut.fifo_write_en;
    assign smp.data  = dut.adc_sample;
    assign smp.full  = dut.fifo_full;
    assign smp.clear = dut.fifo_clear;

    initial begin
        nPOR        = 1'b0;
        apb.PRESETn = 1'b0;
        repeat (4) @(posedge PCLK);
        nPOR = 1'b1;
        repeat (2) @(posedge PCLK);
        apb.PRESETn = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual apb_if)   ::set(null, "*", "vif",  apb);
        uvm_config_db#(virtual sample_if)::set(null, "*", "svif", smp);
        run_test("sensing_full_test");
    end
endmodule
