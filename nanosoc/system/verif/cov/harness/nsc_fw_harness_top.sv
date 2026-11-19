// -----------------------------------------------------------------------------
// nsc_fw_harness_top.sv  —  firmware-run harness for chip-level coverage
// (SYS-4). Separate from nsc_cov_harness_top
// on purpose: the ADP test flow (make build / run / adptests) is untouched.
//
//   make build_fw REAL_ARM=1          compile (box: real Cortex-M0 + CMSDK)
//   make fw FW=<testcode> REAL_ARM=1  run one firmware image
//
// What it does, mirroring nanosoc_tb:
//   - nanosoc_chip with the same pin resolution as nsc_cov_harness_top (pin
//     pull-ups emulated, P1[7] = 0 so the debug path is EXTIO and idle)
//   - the CPU runs image.hex from the run directory: the nanosoc_ss_cpu IMEM
//     model preloads "image.hex" (IMEM_MEM_FPGA_IMG), as socsim copies it
//   - UART2 (P1[5]) captured to logs/uart2.log by nanosoc_uart_capture, with
//     the baud recovery copied from nanosoc_tb.v (BAUDPROGDIV16 = 389)
//   - the run ends when the firmware sends the end byte (0x04,
//     UartEndSimulation: SIMULATIONEND) or at +max_cycles (default 40 M)
// With the ARM stand-ins (no REAL_ARM) the CPU is idle: it compiles and runs,
// prints nothing on UART2 and stops at +max_cycles - only a REAL_ARM=1 run is real.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module nsc_fw_harness_top;
    // ---------------- clock / power-on reset (as nanosoc_clkreset) ----------
    logic clk = 1'b0;
    always #5 clk = ~clk;
    logic [15:0] shifter = 16'h0;
    always @(posedge clk) if (!(&shifter)) shifter <= {shifter[14:0], 1'b1};
    wire nrst = shifter[8];

    // ---------------- chip --------------------------------------------------
    wire [15:0] p0_i, p0_o, p0_e, p0_z, p1_i, p1_o, p1_e, p1_z;
    wire        swdio_o, swdio_e, swdio_z, uart_txd_o;
    wire [3:0]  scan_out, bist_out;

    nanosoc_chip u_nanosoc_chip (
        .diag_mode(1'b0), .diag_ctrl(1'b0), .scan_mode(1'b0), .scan_enable(1'b0),
        .scan_in(4'h0), .scan_out(scan_out), .bist_mode(1'b0), .bist_enable(1'b0),
        .bist_in(4'h0), .bist_out(bist_out), .alt_mode(1'b0), .uart_rxd_i(1'b1),
        .uart_txd_o(uart_txd_o), .swd_mode(1'b0),
        .clk_i(clk), .test_i(1'b0), .nrst_i(nrst),
        .p0_i(p0_i), .p0_o(p0_o), .p0_e(p0_e), .p0_z(p0_z),
        .p1_i(p1_i), .p1_o(p1_o), .p1_e(p1_e), .p1_z(p1_z),
        .swdio_i(1'b1), .swdio_o(swdio_o), .swdio_e(swdio_e), .swdio_z(swdio_z),
        .swdclk_i(1'b0)
    );

    // Pins: chip drive wins, else pull-up. P1[7] = 0 (EXTIO debug mode, idle:
    // ioreq lines pulled high, no host attached); P1[2] (ioack) held 0.
    for (genvar b = 0; b < 16; b++) begin : g_pins
        assign p0_i[b] = p0_e[b] ? p0_o[b] : 1'b1;
        if (b == 7 || b == 2) begin : g_strap
            assign p1_i[b] = p1_e[b] ? p1_o[b] : 1'b0;
        end else begin : g_pull
            assign p1_i[b] = p1_e[b] ? p1_o[b] : 1'b1;
        end
    end

    // ---------------- UART2 capture (copied from nanosoc_tb.v) --------------
    logic [8:0] bauddiv;
    wire        baudclken = (bauddiv == 9'b0);
    always @(negedge nrst or posedge clk)
        if (!nrst) bauddiv <= 9'd0;
        else       bauddiv <= baudclken ? (9'd389 - 9'd1) : (bauddiv - 9'd1);
    wire  baudx16_clk = bauddiv[8];
    wire  UARTXD = p1_i[5];
    logic UARTXD_del;
    always @(negedge nrst or posedge baudx16_clk)
        if (!nrst) UARTXD_del <= 1'b0; else UARTXD_del <= UARTXD;
    wire  UARTXD_edge = UARTXD_del ^ UARTXD;
    logic [3:0] pllq;
    always @(negedge nrst or posedge baudx16_clk)
        if (!nrst)            pllq <= 4'b0000;
        else if (UARTXD_edge) pllq <= 4'b0110;
        else                  pllq <= pllq - 4'd1;
    wire uart_clk = pllq[3];

    wire uart_end;
    nanosoc_uart_capture #(.LOGFILENAME("logs/uart2.log")) u_uart2_capture (
        .RESETn(nrst), .CLK(uart_clk), .RXD(UARTXD),
        .DEBUG_TESTER_ENABLE(), .SIMULATIONEND(uart_end), .AUXCTRL()
    );

    // ---------------- end of run --------------------------------------------
    int unsigned max_cycles = 40_000_000, cyc = 0;
    initial begin
        if ($value$plusargs("max_cycles=%d", max_cycles)) ;
        $display("[fw-harness] running image.hex, max_cycles=%0d", max_cycles);
    end
    always @(posedge clk) begin
        cyc <= cyc + 1;
        if (uart_end) begin
            $display("[fw-harness] firmware ended the simulation (UART2 0x04) at cycle %0d", cyc);
            $finish;
        end
        if (cyc >= max_cycles) begin
            $display("[fw-harness] max_cycles=%0d reached", max_cycles);
            $finish;
        end
    end
endmodule
