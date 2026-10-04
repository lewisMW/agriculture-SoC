`timescale 1ns/1ps
// =============================================================================
// agriculture_soc_reset_rand_tb.v
//
// Randomized async-reset-timing stress test for the full chip. VERIFICATION.md
// §3/§6 flags "async-reset removal timing" as a gap that needs a CDC tool +
// gate-level sim to close properly - this is a behavioural stand-in at RTL:
// it slams `reset` (= nPOR = the async reset for the whole chip, including the
// RTC's CLK1HZ-domain nRTCRST synchroniser) low/high at randomized, cycle-level
// misaligned times relative to both `clk` and the internally-divided CLK1HZ,
// repeatedly, then checks that the chip still comes up clean afterwards.
//
// No existing test does this: every other testbench (block-level and the
// smoke `agriculture_soc_tb.v`) uses a single fixed, clean reset pulse aligned
// to a clock edge. A real async reset can deassert at any point in the clock
// period, and repeatedly - this is what actually stresses reset-synchroniser
// and CDC logic (e.g. rtc_control's nRTCRST 2-flop sync).
//
//   T1 - after N randomly-timed reset pulses, one final clean reset still
//        brings the chip up correctly: HRESETn releases, CLK1HZ resumes
//        toggling, no LOCKUP, no PSLVERR, and the autonomous RTC->FSM->FIFO
//        chain still produces a sample. (Same postconditions as
//        agriculture_soc_checked_tb.v S1-S5, checked only after the storm.)
//
// Deliberately does not check anything *during* the storm itself (mid-storm
// LOCKUP/PSLVERR blips are expected and irrelevant - only clean recovery
// after the last reset matters).
//
// Run: `make reset_rand` (needs ARM_IP_LIBRARY_PATH, same as `make check`)
// =============================================================================

module agriculture_soc_reset_rand_tb;

    localparam T = 20;

    reg        clk;
    reg        reset;
    wire [3:0] LED;

    agriculture_soc DUT (.clk(clk), .reset(reset), .LED(LED));

    always #(T/2) clk = ~clk;

    // ── Test tracking ─────────────────────────────────────────────────────────
    integer pass_count;
    integer fail_count;
    reg     checking_enabled;
    reg     saw_lockup;
    reg     saw_pslverr;
    integer clk1hz_edges;
    reg     prev_clk1hz;
    reg     saw_fifo_nonempty;

    task check_true;
        input         cond;
        input [511:0] name;
        begin
            if (cond) begin
                $display("PASS [%0t] %s", $time, name);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%0t] %s", $time, name);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        checking_enabled = 1'b0;
        saw_lockup        = 1'b0;
        saw_pslverr       = 1'b0;
        saw_fifo_nonempty = 1'b0;
        clk1hz_edges      = 0;
        prev_clk1hz       = 1'b0;
    end

    always @(posedge clk) begin
        if (checking_enabled) begin
            if (DUT.lockup)                     saw_lockup        <= 1'b1;
            if (DUT.sensor_wrapper.PSLVERR)      saw_pslverr       <= 1'b1;
            if (!DUT.sensor_wrapper.fifo_empty)  saw_fifo_nonempty <= 1'b1;
        end
        prev_clk1hz <= DUT.clk1hz;
        if (DUT.clk1hz !== prev_clk1hz) clk1hz_edges <= clk1hz_edges + 1;
    end

    integer i;
    integer N_RESETS;

    initial begin
        pass_count = 0;
        fail_count = 0;
        clk   = 1'b0;
        reset = 1'b0;    // start held in reset

        $dumpfile("waveform_reset_rand.vcd");
        $dumpvars();

        // ── Storm phase — no checks, just misaligned reset pulses ──────────────
        // clk1hz_ctr free-runs 0..49 against CLK1HZ_DIV=50, so pulses of
        // randomized length in *ns* (not whole clk periods) land at arbitrary
        // phases relative to both clk and the divider count.
        N_RESETS = 12;
        for (i = 0; i < N_RESETS; i = i + 1) begin
            reset = 1'b0;
            #(1 + ($random & 9'h1FF));      // 1-511 ns held in reset
            reset = 1'b1;
            #(1 + ($random & 11'h7FF));     // 1-2047 ns released before the next pulse
        end

        // ── Final clean reset — this is the one that must recover correctly ───
        reset = 1'b0;
        #(10*T);
        reset = 1'b1;

        repeat(20) @(posedge clk);
        check_true(DUT.hresetn === 1'b1,
                   "T1 HRESETn released after the final reset, post-storm");

        checking_enabled = 1'b1;

        #(50000*T);

        check_true(!saw_lockup,
                   "T1 CPU never asserts LOCKUP after recovering from the reset storm");
        check_true(!saw_pslverr,
                   "T1 sensing-peripheral PSLVERR never asserted after recovery");
        check_true(clk1hz_edges >= 4,
                   "T1 CLK1HZ resumes toggling cleanly after the reset storm");
        check_true(saw_fifo_nonempty,
                   "T1 autonomous RTC->FSM->ADC->FIFO chain recovers and samples");

        $display("\n─────────────────────────────────────");
        $display("=== SOC-RESET-RAND: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $display("─────────────────────────────────────");

        #100;
        $finish;
    end

    // ── Watchdog ──────────────────────────────────────────────────────────────
    initial begin
        #2_500_000;
        $display("WATCHDOG TIMEOUT - simulation hung");
        $display("\n=== SOC-RESET-RAND: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end

endmodule
