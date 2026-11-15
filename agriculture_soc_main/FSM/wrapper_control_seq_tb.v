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
//
// Standalone (uses dummy_adc, no ARM IP).  Run: make -C FSM seq
// -----------------------------------------------------------------------------
module wrapper_control_seq_tb;

    // FSM state encodings (mirror wrapper_control_2.v)
    localparam [2:0] S_IDLE=3'd0, S_CHECK_FIFO=3'd1, S_ENABLE=3'd2,
                     S_WAIT_START=3'd3, S_WAIT_DONE=3'd4, S_WRITE=3'd5, S_ERR_FULL=3'd6;

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

    wrapper_control_2 uut (
        .clk(clk), .rstn(rstn),
        .sample_trig(sample_trig),
        .fifo_full(fifo_full),
        .fifo_write_en(fifo_write_en),
        .adc_en(adc_en),
        .adc_valid(adc_valid_fsm),
        .err_fifo_full(err_fifo_full)
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
    reg [6:0] state_seen = 7'b0;
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

        // ── FSM-3: adc_valid stuck (no conversion timeout - documented, O-2) ─
        begin : fsm3
            integer w0, k, n_hi;
            integer holds [0:2];
            holds[0] = 1; holds[1] = 10; holds[2] = 500;
            for (k = 0; k < 3; k = k + 1) begin
                @(posedge clk); #1;
                wait_idle(100);
                // let the ADC finish the back-to-back conversion it starts after
                // every sample (adc_en is still high at its done step), so valid
                // is high from a finished conversion, as a real ADC leaves it
                v_force = 1'b0;
                repeat (40) @(posedge clk); #1;
                w0 = wr_count;
                v_force = 1'b1; v_val = 1'b1;              // valid still high from the last conversion
                pulse_trig;
                wait_state(S_WAIT_START, 10);
                repeat (holds[k]) begin
                    @(posedge clk); #1;
                end
                check_true(uut.state === S_WAIT_START && adc_en === 1'b1 && wr_count == w0,
                           "FSM-3 valid held high: FSM waits in S_WAIT_START, adc_en high, no write");
                v_val = 1'b0;                              // conversion starts
                @(posedge clk); #1;
                check_true(uut.state === S_WAIT_DONE, "FSM-3 valid fell: S_WAIT_DONE");
                if (k == 2) begin
                    repeat (500) @(posedge clk); #1;
                    check_true(uut.state === S_WAIT_DONE && adc_en === 1'b1 && wr_count == w0,
                               "FSM-3 valid held low 500 cycles: FSM waits in S_WAIT_DONE, no write");
                end
                v_val = 1'b1;                              // the real rise
                @(posedge clk); #1;
                check_true(uut.state === S_WRITE && fifo_write_en === 1'b1, "FSM-3 write only on the real rise");
                @(posedge clk); #1;
                check_true(wr_count == w0 + 1, "FSM-3 exactly one write");
            end
            v_force = 1'b0;
            $display("NOTE FSM-3 property: wrapper_control_2 has no conversion timeout; a dead ADC parks it in S_WAIT_START/S_WAIT_DONE (status[3:2] = 1) until reset (see FIX-2)");
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
