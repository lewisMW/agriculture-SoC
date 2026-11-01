// -----------------------------------------------------------------------------
// nsc_cov_harness_top.sv  —  HARNESS ONLY (Verilator compile/smoke of the
// nanosoc system coverage models on a machine without ARM IP).
//
// Mirrors the parts of nanosoc_tb that matter for coverage, without the
// tristate pads (Verilator rejects nanosoc_tb's mixed pullup/pulldown on P1):
//   - nanosoc_chip instantiated directly (separate _i/_o/_e pin buses)
//   - pin pull-ups emulated: an input pin reads its own output when the chip
//     drives it, else the external driver, else 1 (P1[7] = FT1248MODE, 0 =
//     hostio4/EXTIO mode exactly as nanosoc_tb's pulldown)
//   - hostio4_target + nanosoc_axi_stream_io_8_txd_from_file stream an ADP
//     command file (+define+ADP_FILE="..."; default "adp.cmd") into the debug
//     controller, so the existing ADP command-file tests drive real bus
//     traffic through the SoCLabs RTL even though the CPU is an idle stub.
//   - power-on reset only (NRST released once, as nanosoc_clkreset does). The
//     streamer itself sends "C 201" (ADP GPO bit0 -> DEBUG_RESETREQ), so every
//     run also contains one debugger-requested warm reset.
// This is NOT a test: it adds no stimulus beyond what nanosoc_tb applies,
// except for the runtime options below, which the system tests in
// ../adp_tests use (default = exactly the nanosoc_tb behaviour):
//   +max_cycles=N            end of run (default 400000)
//   +ft1248                  strap P1[7]=1 (FT1248 debug path) and stream the
//                            ADP file through nanosoc_ft1248x1_to_axi_streamio
//                            (the FT1248 device side; nanosoc drives SCLK/SS_N)
//                            instead of hostio4/EXTIO
//   +nrst_at=N +nrst_len=L   pulse the chip NRST pin low at cycle N for L cycles
//   +nrst2_at=N +nrst2_len=L a second pulse
//   The host-side models (streamer, hostio4 target, FT1248 device) keep their
//   own power-on reset, so an NRST pulse resets only the chip, as a reset
//   button on a board would.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
`ifndef ADP_FILE
  `define ADP_FILE "adp.cmd"
`endif
module nsc_cov_harness_top;
    bit FT1248MODE = 1'b0;
    initial FT1248MODE = $test$plusargs("ft1248");

    // ---------------- clock / power-on reset (as nanosoc_clkreset) ----------
    logic clk = 1'b0;
    always #5 clk = ~clk;
    logic [15:0] shifter = 16'h0;
    always @(posedge clk) if (!(&shifter)) shifter <= {shifter[14:0], 1'b1};
    wire host_rstn = shifter[8];             // power-on reset of the host models
    // chip NRST pin: power-on reset plus optional pulses (plusargs)
    int nrst_at = -1, nrst_len = 0, nrst2_at = -1, nrst2_len = 0;
    initial begin
        void'($value$plusargs("nrst_at=%d", nrst_at));
        void'($value$plusargs("nrst_len=%d", nrst_len));
        void'($value$plusargs("nrst2_at=%d", nrst2_at));
        void'($value$plusargs("nrst2_len=%d", nrst2_len));
    end
    logic nrst_pulse_n = 1'b1;
    int unsigned rcyc = 0;
    always @(posedge clk) begin
        rcyc <= rcyc + 1;
        nrst_pulse_n <= !((nrst_at  >= 0 && rcyc >= nrst_at  && rcyc < nrst_at  + nrst_len) ||
                          (nrst2_at >= 0 && rcyc >= nrst2_at && rcyc < nrst2_at + nrst2_len));
    end
    wire nrst = shifter[8] & nrst_pulse_n;

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

    // ---------------- hostio4 target (EXTIO mode) ---------------------------
    wire       rx0_tready, rx0_tvalid; wire [7:0] rx0_tdata;
    wire       rx1_tready, rx1_tvalid; wire [7:0] rx1_tdata;
    wire       tx0_tready, tx0_tvalid; wire [7:0] tx0_tdata;
    wire       tx1_tready, tx1_tvalid; wire [7:0] tx1_tdata;
    wire [3:0] iodata4_i, iodata4_o, iodata4_e, iodata4_t;
    wire       ioack;
    wire       ioreq1 = FT1248MODE ? 1'b0 : (p1_e[0] ? p1_o[0] : 1'b1);
    wire       ioreq2 = FT1248MODE ? 1'b0 : (p1_e[1] ? p1_o[1] : 1'b1);

    wire       ft_miso, ft_miosio_o, ft_miosio_z;   // FT1248 device model pins

    // External drive of each P1 pin by the target (z = not driving).
    logic [15:0] p1_ext_en, p1_ext_val;
    always_comb begin
        p1_ext_en  = 16'h0;
        p1_ext_val = 16'hFFFF;
        p1_ext_en[7]  = 1'b1;  p1_ext_val[7] = FT1248MODE;
        if (FT1248MODE) begin
            p1_ext_en[0] = 1'b1;          p1_ext_val[0] = ft_miso;     // ft_miso_in
            p1_ext_en[2] = !ft_miosio_z;  p1_ext_val[2] = ft_miosio_o; // ft_miosio_io
        end else begin
            p1_ext_en[2] = 1'b1; p1_ext_val[2] = ioack;
            for (int k = 0; k < 4; k++) begin
                p1_ext_en[3+k]  = !iodata4_t[k];
                p1_ext_val[3+k] = iodata4_o[k];
            end
        end
    end
    // Pin resolution: chip drive wins (a contention is visible in the pad
    // coverage model as cp_contention), then external driver, then pull-up.
    for (genvar b = 0; b < 16; b++) begin : g_pins
        assign p1_i[b] = p1_e[b] ? p1_o[b] : (p1_ext_en[b] ? p1_ext_val[b] : 1'b1);
        assign p0_i[b] = p0_e[b] ? p0_o[b] : 1'b1;
    end
    assign iodata4_i = {4{FT1248MODE}} | p1_i[6:3];

    // FT1248 device-side model (used with +ft1248)
    wire       ft_txd_tvalid, ft_rxd_tready;
    wire [7:0] ft_txd_tdata;
    wire       adp_valid, adp_ready, file_ready;
    wire [7:0] adp_data;
    nanosoc_ft1248x1_to_axi_streamio_v1_0 u_ft1248_dev (
        .ft_clk_i(FT1248MODE ? p1_i[1] : 1'b0), .ft_ssn_i(FT1248MODE ? p1_i[3] : 1'b1),
        .ft_miso_o(ft_miso), .ft_miosio_i(p1_i[2]), .ft_miosio_o(ft_miosio_o), .ft_miosio_z(ft_miosio_z),
        .aclk(clk), .aresetn(host_rstn),
        .txd_tvalid_o(ft_txd_tvalid), .txd_tdata8_o(ft_txd_tdata), .txd_tready_i(FT1248MODE ? file_ready : 1'b1),
        .rxd_tready_o(ft_rxd_tready), .rxd_tdata8_i(adp_data), .rxd_tvalid_i(FT1248MODE & adp_valid)
    );

    hostio4_target u_hostio4_target (
        .clk(clk), .resetn(host_rstn), .testmode(1'b0),
        .axis_rx0_tready(rx0_tready), .axis_rx0_tvalid(rx0_tvalid), .axis_rx0_tdata8(rx0_tdata),
        .axis_rx1_tready(rx1_tready), .axis_rx1_tvalid(rx1_tvalid), .axis_rx1_tdata8(rx1_tdata),
        .axis_tx0_tready(tx0_tready), .axis_tx0_tvalid(tx0_tvalid), .axis_tx0_tdata8(tx0_tdata),
        .axis_tx1_tready(tx1_tready), .axis_tx1_tvalid(tx1_tvalid), .axis_tx1_tdata8(tx1_tdata),
        .iodata4_i(iodata4_i), .iodata4_o(iodata4_o), .iodata4_e(iodata4_e), .iodata4_t(iodata4_t),
        .ioreq1_a(ioreq1), .ioreq2_a(ioreq2), .ioack_o(ioack)
    );

    nanosoc_axi_stream_io_8_txd_from_file #(
        .TXDFILENAME(`ADP_FILE), .FAST_LOAD(1)
    ) u_adp_txd (
        .aclk(clk), .aresetn(host_rstn),
        .txd8_ready(adp_ready), .txd8_valid(adp_valid), .txd8_data(adp_data)
    );
    assign adp_ready  = FT1248MODE ? ft_rxd_tready : rx0_tready;
    assign rx0_tvalid = !FT1248MODE & adp_valid;
    assign rx0_tdata  = adp_data;
    assign rx1_tvalid = 1'b0;     // no data-stream input
    assign rx1_tdata  = 8'h00;
    assign tx1_tready = 1'b1;     // sink the data-stream output

    wire test_done;
    nanosoc_axi_stream_io_8_rxd_to_file #(
        .RXDFILENAME("logs/extadp_out.log"), .VERBOSE(0)
    ) u_adp_rxd (
        .aclk(clk), .aresetn(host_rstn), .eof_received(test_done),
        .rxd8_ready(file_ready),
        .rxd8_valid(FT1248MODE ? ft_txd_tvalid : tx0_tvalid),
        .rxd8_data (FT1248MODE ? ft_txd_tdata  : tx0_tdata)
    );
    assign tx0_tready = FT1248MODE ? 1'b1 : file_ready;

    // ---------------- end of run --------------------------------------------
    int unsigned max_cycles = 400000, cyc = 0;
    initial begin
        if ($value$plusargs("max_cycles=%d", max_cycles)) ;
        if (FT1248MODE) $display("[harness] FT1248 debug path (P1[7]=1)");
        if (nrst_at >= 0) $display("[harness] NRST pulse at %0d for %0d cycles", nrst_at, nrst_len);
        if (nrst2_at >= 0) $display("[harness] NRST pulse 2 at %0d for %0d cycles", nrst2_at, nrst2_len);
    end
    always @(posedge clk) begin
        cyc <= cyc + 1;
        if (test_done && !ioreq1 && !ioreq2) begin
            $display("[harness] ADP stream finished (EOF) at cycle %0d", cyc);
            $finish;
        end
        if (cyc >= max_cycles) begin
            $display("[harness] max_cycles=%0d reached", max_cycles);
            $finish;
        end
    end
endmodule
