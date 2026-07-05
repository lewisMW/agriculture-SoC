`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// wrapper_control_seq_tb.v
//
// Rigorous sequencing/coverage unit test for the sampling FSM. Complements
// wrapper_control_tb.v (which hand-drives adc_valid to test the handshake and
// the stale-valid case) by wiring the FSM to the REAL dummy_adc so the
// enable->valid protocol is exercised end-to-end, and by checking the
// higher-level sequencing properties from VERIFICATION.md:
//   - one sample per trigger (write pulse count == successful triggers)
//   - back-to-back triggers each produce a sample
//   - a trigger asserted mid-conversion is ignored (no extra sample)
//   - FIFO-full drop sets err_fifo_full and produces NO write; the flag then
//     self-clears on the next successful cycle
//   - every FSM state is reached (functional coverage)
//   - constrained-random trigger/fifo_full stream vs. a reference count
//
// Standalone (uses dummy_adc, no ARM IP).  Run: make -C FSM seq
// -----------------------------------------------------------------------------
module wrapper_control_seq_tb;

    // FSM state encodings (mirror wrapper_control.v)
    localparam [2:0] S_IDLE=3'd0, S_CHECK_FIFO=3'd1, S_ENABLE=3'd2,
                     S_WAIT_START=3'd3, S_WAIT_DONE=3'd4, S_WRITE=3'd5, S_ERR_FULL=3'd6;

    reg  clk, rstn;
    reg  sample_trig;
    reg  fifo_full;
    wire fifo_write_en;
    wire adc_en;
    wire err_fifo_full;
    wire adc_valid;

    integer pass_count = 0;
    integer fail_count = 0;

    wrapper_control uut (
        .clk(clk), .rstn(rstn),
        .sample_trig(sample_trig),
        .fifo_full(fifo_full),
        .fifo_write_en(fifo_write_en),
        .adc_en(adc_en),
        .adc_valid(adc_valid),
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
            if (fifo_write_en && fifo_full)
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

    integer i;
    integer exp_writes;
    integer before;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, wrapper_control_seq_tb);

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
        before = wr_count;
        pulse_trig;
        // wait until the ADC is mid-conversion, then fire a spurious trigger
        wait (uut.state == S_WAIT_DONE);
        sample_trig = 1'b1; @(posedge clk); #1; sample_trig = 1'b0;
        repeat (2) @(posedge clk);
        i = 0;
        while (uut.state !== S_IDLE && i < 50) begin @(posedge clk); i = i + 1; end
        check_true(wr_count == before + 1, "C3 mid-conversion trigger ignored (only one write)");

        // C4: FIFO full at pre-check -> drop, err set, NO write
        before = wr_count;
        fifo_full = 1'b1;
        pulse_trig;
        repeat (4) @(posedge clk);
        check_true(err_fifo_full === 1'b1, "C4 err_fifo_full set on full drop");
        check_true(wr_count == before, "C4 no write when FIFO full");
        check_true(adc_en === 1'b0, "C4 ADC not enabled on full drop");

        // C4b: err_fifo_full self-clears on the next successful cycle
        fifo_full = 1'b0;
        run_episode(50);
        check_true(err_fifo_full === 1'b0, "C4b err_fifo_full clears on next good cycle");
        check_true(wr_count == before + 1, "C4b write resumes after full clears");

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
