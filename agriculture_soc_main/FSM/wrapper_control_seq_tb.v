`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// wrapper_control_seq_tb.v
//
// Rigorous sequencing/coverage unit test for the sampling FSM. Complements
// wrapper_control_2_tb.v (which hand-drives adc_valid to test the handshake and
// the stale-valid case) by wiring the FSM to the REAL dummy_adc so the
// enable->valid protocol is exercised end-to-end, and by checking the
// higher-level sequencing properties:
//   - one sample per trigger (write pulse count == successful triggers)
//   - back-to-back triggers each produce a sample
//   - a trigger asserted mid-conversion is ignored (no extra sample)
//   - FIFO-full drop sets err_fifo_full and produces NO write; the flag then
//     self-clears on the next successful cycle
//   - every FSM state is reached (functional coverage)
//   - constrained-random trigger/fifo_full stream vs. a reference count
//   - FSM-1..4: a one-cycle trigger in
//     every busy state, a held (level) trigger, adc_valid stuck high / low
//     (no conversion timeout before FIX-2), and fifo_full rising
//     after the pre-check (unit-only case; built with -DSVA_FSM_UNIT)
//   - FSM-5: after a timeout of a slow ADC that is still converting, the next
//     trigger stores a fresh sample, never the old conversion's result
//
// Standalone (uses dummy_adc, no ARM IP).  Run: make -C FSM seq
// -----------------------------------------------------------------------------
module wrapper_control_seq_tb;

    // FSM state encodings (mirror wrapper_control_2.v)
    localparam [2:0] S_IDLE=3'd0, S_CHECK_FIFO=3'd1, S_ENABLE=3'd2,
                     S_WAIT_START=3'd3, S_WAIT_DONE=3'd4, S_WRITE=3'd5, S_ERR_FULL=3'd6,
                     S_ERR_TIMEOUT=3'd7;

    reg  clk, rstn;
    reg  sample_trig;
    reg  fifo_full;
    wire fifo_write_en;
    wire adc_en;
    wire err_fifo_full;
    wire adc_valid;          // from dummy_adc
    reg  v_force = 1'b0;     // FSM-3: drive the FSM's adc_valid by hand
    reg  v_val   = 1'b0;
    wire adc_valid_fsm = v_force ? v_val : adc_valid;
    reg  inv_off = 1'b0;     // FSM-4: the write-while-full invariant is not a unit property

    integer pass_count = 0;
    integer fail_count = 0;

    localparam integer TMO = 60;            // CONV_TIMEOUT for this unit bench
    wire err_adc_timeout;
    wrapper_control_2 #(.CONV_TIMEOUT(TMO)) uut (
        .clk(clk), .rstn(rstn),
        .sample_trig(sample_trig),
        .fifo_full(fifo_full),
        .fifo_write_en(fifo_write_en),
        .adc_en(adc_en),
        .adc_valid(adc_valid_fsm),
        .err_fifo_full(err_fifo_full),
        .err_adc_timeout(err_adc_timeout)
    );

    // Real behavioural ADC: exercises the enable->valid handshake for real.
    dummy_adc #(.RESULT_WIDTH(8), .CONV_CYCLES(6), .RAND_SEED(8'h3C)) u_adc (
        .clk(clk), .rstn(rstn), .en(adc_en), .cal(1'b0), .ANALOG_IN(1'b0),
        .valid(adc_valid), .result()
    );

    always #5 clk = ~clk;

    task check_true;
        input         cond;
        input [511:0] name;
        begin
            if (cond) begin $display("PASS [%0t] %s", $time, name); pass_count = pass_count + 1; end
            else      begin $display("FAIL [%0t] %s", $time, name); fail_count = fail_count + 1; end
        end
    endtask

    // ── Monitors: count write pulses and record every state visited ──────────
    integer wr_count = 0;
    reg [7:0] state_seen = 8'b0;
    always @(posedge clk) begin
        if (rstn) begin
            if (fifo_write_en) wr_count = wr_count + 1;
            state_seen[uut.state] = 1'b1;
            // Safety invariant: never write while the FIFO is full.
            if (fifo_write_en && fifo_full && !inv_off)
                check_true(1'b0, "INVARIANT VIOLATED: write while FIFO full");
        end
    end

    // ── Helpers ──────────────────────────────────────────────────────────────
    task pulse_trig;
        begin sample_trig = 1'b1; @(posedge clk); #1; sample_trig = 1'b0; end
    endtask

    // Run one trigger episode to completion (back to IDLE). Returns via wr_count.
    task run_episode(input integer tmo);
        integer k;
        begin
            pulse_trig;
            repeat (2) @(posedge clk);              // guarantee we've left IDLE
            k = 0;
            while (uut.state !== S_IDLE && k < tmo) begin @(posedge clk); k = k + 1; end
            if (k >= tmo) check_true(1'b0, "episode did not return to IDLE (timeout)");
        end
    endtask


    // ── FSM-1..4 helpers ─────────────────────────────────────────────────────
    task wait_state(input [2:0] st, input integer tmo);
        integer k;
        begin
            k = 0;
            while (uut.state !== st && k < tmo) begin @(posedge clk); #1; k = k + 1; end
            if (k >= tmo) begin $display("  (waiting for state %0d, FSM in %0d)", st, uut.state); check_true(1'b0, "wait_state timeout"); end
        end
    endtask
    task wait_idle(input integer tmo);
        integer k;
        begin
            k = 0;
            while (uut.state !== S_IDLE && k < tmo) begin @(posedge clk); #1; k = k + 1; end
            if (k >= tmo) check_true(1'b0, "FSM returns to IDLE (timeout)");
        end
    endtask

    // FSM-1: one-cycle trigger while the FSM is in state `st`
    task fsm1_case(input [2:0] st, input full);
        integer w0;
        reg [8*14-1:0] nm;
        begin
            @(posedge clk); #1;                  // align: run_episode returns on the edge itself
            wait_idle(100);
            w0 = wr_count;
            fifo_full = full;
            pulse_trig;
            wait_state(st, 100);
            sample_trig = 1'b1; @(posedge clk); #1; sample_trig = 1'b0;   // the extra trigger
            wait_idle(100);
            repeat (3) @(posedge clk); #1;
            check_true(uut.state === S_IDLE, "FSM-1 extra trigger in a busy state: FSM back in IDLE, no second episode");
            if (wr_count != w0 + (full ? 0 : 1)) $display("  (state %0d: %0d writes)", st, wr_count - w0);
            check_true(wr_count == w0 + (full ? 0 : 1), "FSM-1 extra trigger in a busy state produces no write");
            fifo_full = 1'b0;
            w0 = wr_count;
            run_episode(60);
            check_true(wr_count == w0 + 1, "FSM-1 the next trigger after it works");
        end
    endtask

    integer i;
    integer exp_writes;
    integer wr_before;

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("waveform.vcd");
            $dumpvars(0, wrapper_control_seq_tb);
        end

        clk = 0; rstn = 0; sample_trig = 0; fifo_full = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (2) @(posedge clk);

        // Reset behaviour
        check_true(uut.state === S_IDLE, "reset: FSM in IDLE");
        check_true(err_fifo_full === 1'b0, "reset: err_fifo_full clear");
        check_true(wr_count == 0, "reset: no writes yet");

        // C1: one trigger -> exactly one sample
        run_episode(50);
        check_true(wr_count == 1, "C1 single trigger produces one write");

        // C2: back-to-back triggers -> two more samples
        run_episode(50);
        run_episode(50);
        check_true(wr_count == 3, "C2 back-to-back triggers each produce a write");

        // C3: a trigger asserted mid-conversion must be ignored (no extra write)
        wr_before = wr_count;
        pulse_trig;
        // wait until the ADC is mid-conversion, then fire a spurious trigger
        wait (uut.state == S_WAIT_DONE);
        sample_trig = 1'b1; @(posedge clk); #1; sample_trig = 1'b0;
        repeat (2) @(posedge clk);
        i = 0;
        while (uut.state !== S_IDLE && i < 50) begin @(posedge clk); i = i + 1; end
        check_true(wr_count == wr_before + 1, "C3 mid-conversion trigger ignored (only one write)");

        // C4: FIFO full at pre-check -> drop, err set, NO write
        wr_before = wr_count;
        fifo_full = 1'b1;
        pulse_trig;
        repeat (4) @(posedge clk);
        check_true(err_fifo_full === 1'b1, "C4 err_fifo_full set on full drop");
        check_true(wr_count == wr_before, "C4 no write when FIFO full");
        check_true(adc_en === 1'b0, "C4 ADC not enabled on full drop");

        // C4b: err_fifo_full self-clears on the next successful cycle
        fifo_full = 1'b0;
        run_episode(50);
        check_true(err_fifo_full === 1'b0, "C4b err_fifo_full clears on next good cycle");
        check_true(wr_count == wr_before + 1, "C4b write resumes after full clears");

        // C5: constrained-random stream. Hold fifo_full stable across each
        //     episode; expected writes += 1 only when not full at the pre-check.
        exp_writes = wr_count;
        for (i = 0; i < 60; i = i + 1) begin
            fifo_full = ($random & 8'hFF) < 8'h40;   // full ~25% of the time
            if (!fifo_full) exp_writes = exp_writes + 1;
            run_episode(60);
        end
        check_true(wr_count == exp_writes, "C5 random: write count matches reference model");
        fifo_full = 1'b0;


        // ── FSM-1: one-cycle trigger in every busy state ─────────────────────
        fsm1_case(S_CHECK_FIFO, 1'b0);
        fsm1_case(S_ENABLE,     1'b0);
        fsm1_case(S_WAIT_START, 1'b0);
        fsm1_case(S_WAIT_DONE,  1'b0);
        fsm1_case(S_WRITE,      1'b0);
        fsm1_case(S_ERR_FULL,   1'b1);

        // ── FSM-2: level trigger; trigger on the cycle the FSM re-enters IDLE ─
        begin : fsm2
            integer w0, passes, k;
            reg     in_idle_q;
            @(posedge clk); #1;
            wait_idle(100);
            w0 = wr_count; passes = 0; in_idle_q = 1'b1;
            sample_trig = 1'b1;
            for (k = 0; k < 120; k = k + 1) begin
                @(posedge clk); #1;
                if (uut.state == S_CHECK_FIFO) passes = passes + 1;
            end
            sample_trig = 1'b0;
            wait_idle(100);
            $display("  FSM-2 held trigger: %0d passes, %0d writes", passes, wr_count - w0);
            check_true(passes >= 4 && wr_count - w0 == passes,
                       "FSM-2 held trigger: back-to-back samples, exactly one per pass through IDLE");
            // a one-cycle trigger in the very cycle the FSM is back in IDLE
            w0 = wr_count;
            pulse_trig;
            wait_state(S_WRITE, 100);
            @(posedge clk); #1;                           // now in IDLE
            check_true(uut.state === S_IDLE, "FSM-2 FSM re-entered IDLE");
            pulse_trig;                                   // accepted at once
            wait_state(S_CHECK_FIFO, 3);
            wait_idle(100);
            check_true(wr_count == w0 + 2, "FSM-2 trigger on the re-entry cycle starts the next sample");
        end

        // ── FSM-3 / FIX-2: conversion timeout (CONV_TIMEOUT = TMO here) ──────
        begin : fsm3
            integer w0, k, waitc;
            // (a) valid stuck high (never starts), (b) stuck low (never finishes)
            for (k = 0; k < 2; k = k + 1) begin
                @(posedge clk); #1;
                wait_idle(100);
                v_force = 1'b0; repeat (40) @(posedge clk); #1;
                w0 = wr_count;
                v_force = 1'b1; v_val = 1'b1;
                pulse_trig;
                wait_state(S_WAIT_START, 10);
                if (k == 1) begin v_val = 1'b0; end         // starts, never finishes
                waitc = 0;
                while (uut.state == S_WAIT_START || uut.state == S_WAIT_DONE) begin @(posedge clk); #1; waitc = waitc + 1; end
                check_true(uut.state === S_ERR_TIMEOUT && waitc == TMO,
                           k == 0 ? "FSM-3/FIX-2 valid stuck high: S_ERR_TIMEOUT after exactly CONV_TIMEOUT cycles"
                                  : "FSM-3/FIX-2 valid stuck low: S_ERR_TIMEOUT after exactly CONV_TIMEOUT cycles");
                check_true(adc_en === 1'b0 && fifo_write_en === 1'b0, "FSM-3/FIX-2 S_ERR_TIMEOUT: adc_en low, no write");
                sample_trig = 1'b1; @(posedge clk); #1; sample_trig = 1'b0;   // trigger during S_ERR_TIMEOUT
                check_true(uut.state === S_IDLE && err_adc_timeout === 1'b1, "FSM-3/FIX-2 back to IDLE after one cycle, flag set");
                repeat (5) @(posedge clk); #1;
                check_true(uut.state === S_IDLE && wr_count == w0, "FSM-3/FIX-2 trigger during S_ERR_TIMEOUT ignored, no write");
            end
            // (c) a conversion finishing on the last allowed cycle is accepted
            w0 = wr_count;
            v_val = 1'b1;
            pulse_trig;
            wait_state(S_WAIT_START, 10);
            v_val = 1'b0;                                  // starts at once (cycle 1)
            repeat (TMO - 2) @(posedge clk); #1;           // TMO-1 cycles waited so far
            v_val = 1'b1;                                  // done on the last allowed cycle
            @(posedge clk); #1;
            check_true(uut.state === S_WRITE, "FSM-3/FIX-2 conversion completing on the last allowed cycle is accepted");
            @(posedge clk); #1;
            check_true(wr_count == w0 + 1 && err_adc_timeout === 1'b0, "FSM-3/FIX-2 the written sample clears the timeout flag");
            // (d) the flag stays set until a sample is written, then clears
            v_force = 1'b0;
            run_episode(200);
            check_true(err_adc_timeout === 1'b0, "FSM-3/FIX-2 flag stays clear after a good conversion");
            // (e) a conversion that only STARTS on the last allowed cycle times
            //     out: the budget covers start and completion together
            @(posedge clk); #1;
            wait_idle(100);
            v_force = 1'b1; v_val = 1'b1;                  // last conversion done, valid high
            w0 = wr_count;
            pulse_trig;
            wait_state(S_WAIT_START, 10);                  // waiting cycle 1
            repeat (TMO - 1) @(posedge clk); #1;           // waiting cycle TMO (the last)
            v_val = 1'b0;                                  // the start shows only now
            @(posedge clk); #1;
            check_true(uut.state === S_ERR_TIMEOUT && wr_count == w0,
                       "FSM-3 start on the last allowed cycle times out");
            v_force = 1'b0;
            $display("NOTE FSM-3/FIX-2: a dead ADC now times out after CONV_TIMEOUT cycles (status[6] in the wrapper) instead of parking the FSM");
        end

        // ── FSM-5: no stale sample after a timeout (FSM-STALE + FIX-2) ───────
        // A slow but alive ADC times out while still converting (valid low).
        // The next trigger must wait for that conversion to finish and its
        // own conversion to start, and store a fresh sample. Before the fix
        // adc_quiet stayed set through S_ERR_TIMEOUT, so the next trigger took
        // the still-low valid as its own start and stored the old conversion.
        begin : fsm5
            integer w0, k;
            reg seen_done_early;
            @(posedge clk); #1;
            wait_idle(100);
            v_force = 1'b1; v_val = 1'b0;
            repeat (2) @(posedge clk); #1;
            v_val = 1'b1; repeat (2) @(posedge clk); #1;   // a conversion completes: ADC quiet
            v_val = 1'b0;                                  // valid low from here
            check_true(uut.adc_quiet === 1'b1, "FSM-5 precondition: ADC quiet");
            w0 = wr_count;
            pulse_trig;
            wait_state(S_WAIT_DONE, 10);                   // conversion started (valid low)
            wait_state(S_ERR_TIMEOUT, TMO + 5);            // slow: still converting at the timeout
            @(posedge clk); #1;
            check_true(uut.state === S_IDLE && err_adc_timeout === 1'b1 && uut.adc_quiet === 1'b0,
                       "FSM-5 timeout mid-conversion: IDLE, flag set, adc_quiet low");
            // next trigger while the slow conversion is still running
            pulse_trig;
            seen_done_early = 1'b0;
            for (k = 0; k < 8; k = k + 1) begin
                @(posedge clk); #1;
                if (uut.state == S_WAIT_DONE) seen_done_early = 1'b1;
            end
            check_true(!seen_done_early && uut.state === S_WAIT_START,
                       "FSM-5 old conversion's low valid not taken as start");
            v_val = 1'b1; repeat (3) @(posedge clk); #1;   // the old conversion finishes
            check_true(uut.state === S_WAIT_START && wr_count == w0,
                       "FSM-5 old conversion's completion not stored");
            v_val = 1'b0; repeat (2) @(posedge clk); #1;   // this trigger's conversion starts
            check_true(uut.state === S_WAIT_DONE, "FSM-5 this trigger's own start is seen");
            v_val = 1'b1;
            wait_idle(20);
            check_true(wr_count == w0 + 1 && err_adc_timeout === 1'b0,
                       "FSM-5 one fresh sample written, flag cleared");
            v_force = 1'b0;
            // a genuinely dead ADC after a timeout: every later trigger times
            // out again (no hang, no write)
            v_force = 1'b1; v_val = 1'b0;
            w0 = wr_count;
            for (k = 0; k < 3; k = k + 1) begin
                @(posedge clk); #1;
                wait_idle(2 * TMO);
                pulse_trig;
                wait_state(S_ERR_TIMEOUT, TMO + 10);
            end
            wait_idle(10);
            check_true(wr_count == w0 && err_adc_timeout === 1'b1,
                       "FSM-5 dead ADC: repeated triggers time out, no write");
            v_val = 1'b1; repeat (3) @(posedge clk); #1;   // the ADC recovers
            v_force = 1'b0;
            run_episode(4 * TMO);
            check_true(wr_count == w0 + 1 && err_adc_timeout === 1'b0,
                       "FSM-5 recovered ADC: next trigger writes, flag cleared");
        end

        // ── FSM-4: fifo_full rising after the pre-check (unit-only case) ─────
        begin : fsm4
            integer w0;
            @(posedge clk); #1;
            wait_idle(100);
            w0 = wr_count;
            inv_off = 1'b1;
            pulse_trig;
            wait_state(S_ENABLE, 10);
            fifo_full = 1'b1;                              // after S_CHECK_FIFO passed
            wait_idle(100);
            check_true(wr_count == w0 + 1, "FSM-4 fifo_full after the pre-check: the FSM still writes (the FIFO drops the push)");
            $display("NOTE FSM-4 property: the FSM checks fifo_full only in S_CHECK_FIFO; a_no_write_when_full is a property of the integrated design (only the FSM pushes), checked by the wrapper benches, not by this unit case");
            fifo_full = 1'b0;
            inv_off = 1'b0;
        end

        // C6: functional coverage — every state must have been reached
        check_true(state_seen[S_IDLE],       "COV S_IDLE reached");
        check_true(state_seen[S_CHECK_FIFO], "COV S_CHECK_FIFO reached");
        check_true(state_seen[S_ENABLE],     "COV S_ENABLE reached");
        check_true(state_seen[S_WAIT_START], "COV S_WAIT_START reached");
        check_true(state_seen[S_WAIT_DONE],  "COV S_WAIT_DONE reached");
        check_true(state_seen[S_WRITE],      "COV S_WRITE reached");
        check_true(state_seen[S_ERR_FULL],   "COV S_ERR_FULL reached");
        check_true(state_seen[S_ERR_TIMEOUT],"COV S_ERR_TIMEOUT reached (FIX-2)");

        $display("\n=== FSM-SEQ: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        #20 $finish;
    end

    initial begin
        #2000000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== FSM-SEQ: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end

endmodule
