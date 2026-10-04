`timescale 1ns/1ps
// =============================================================================
// agriculture_soc_checked_tb.v
//
// Self-checking full-SoC integration test. `agriculture_soc_tb.v` (the
// default `make` target) is a pure smoke run: it dumps a waveform and calls
// $finish with no pass/fail verdict at all, even though every layer beneath it
// (FIFO/FSM/RTC block tests, the Wrapper integration + constrained-random
// tests) is self-checking. This closes that gap at the one level none of them
// exercise: the full chip, wired exactly as agriculture_soc.v wires it,
// through the real Cortex-M0 + CMSDK + AHB->APB bridge fabric, not a
// testbench driving the sensing peripheral's APB port directly.
//
// This is intentionally a liveness/integration check, not a re-verification
// of block-level behaviour (that's already covered). Properties:
//
//   S1 - the CPU never asserts LOCKUP (no unrecovered fault dead-loop) once
//        past reset.
//   S2 - the reset-synchroniser chain releases HRESETn after reset.
//   S3 - CLK1HZ actually toggles in the fully-wired chip. This is the exact
//        signal that, when left unconnected under NanoSoC, silently killed
//        the RTC (see HANDOFF.md Task D) - worth a standing regression here
//        so a future top-level rewiring mistake is caught immediately.
//   S4 - PSLVERR out of the sensing peripheral is never asserted (guards the
//        wait-state-not-PSLVERR hang fix at the integration level too).
//   S5 - the full autonomous chain - RTC tick -> alarm -> rtc_trig ->
//        sampling FSM -> ADC -> FIFO write - produces at least one sample
//        (FIFO goes non-empty) end to end, driven by the real nPOR/CLK1HZ
//        wiring in agriculture_soc.v rather than a testbench forcing those
//        ports directly as every lower-level test does.
//
// Run: `make check` (needs ARM_IP_LIBRARY_PATH, same as `make all`/`make lint`)
// =============================================================================

module agriculture_soc_checked_tb;

    localparam T = 20;

    reg        clk;
    reg        reset;
    wire [3:0] LED;

    agriculture_soc DUT (.clk(clk), .reset(reset), .LED(LED));

    always #(T/2) clk = ~clk;

    // ── Test tracking ─────────────────────────────────────────────────────────
    integer pass_count;
    integer fail_count;
    reg     checking_enabled;   // gated on so post-reset transients don't count
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

    // ── Sticky monitors — only count once we're past the initial reset ───────
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

    initial begin
        pass_count = 0;
        fail_count = 0;

        $dumpfile("waveform_checked.vcd");
        $dumpvars();

        clk   = 1'b0;
        reset = 1'b0;
        #(10*T);
        reset = 1'b1;                 // deassert nPOR/resetn for good

        // Let the reset synchroniser (reset_sync_reg) finish before checking.
        repeat(20) @(posedge clk);
        check_true(DUT.hresetn === 1'b1, "S2 HRESETn released after reset deassertion");

        checking_enabled = 1'b1;

        // Run long enough for several CLK1HZ periods and, at the default
        // 5-"second" alarm_offset, several full autonomous poll cycles.
        #(50000*T);

        check_true(!saw_lockup,
                   "S1 CPU never asserts LOCKUP once past reset");
        check_true(!saw_pslverr,
                   "S4 sensing-peripheral PSLVERR never asserted end to end");
        check_true(clk1hz_edges >= 4,
                   "S3 CLK1HZ toggles in the fully-wired chip");
        check_true(saw_fifo_nonempty,
                   "S5 autonomous RTC->FSM->ADC->FIFO chain produces a sample");

        $display("\n─────────────────────────────────────");
        $display("=== SOC-CHECK: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $display("─────────────────────────────────────");

        #100;
        $finish;
    end

    // ── Watchdog ──────────────────────────────────────────────────────────────
    initial begin
        #2_000_000;
        $display("WATCHDOG TIMEOUT - simulation hung");
        $display("\n=== SOC-CHECK: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end

endmodule
