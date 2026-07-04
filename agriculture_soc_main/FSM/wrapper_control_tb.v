`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// wrapper_control_tb.v
//
// Unit test for the sampling FSM. Drives adc_valid / fifo_full directly (no ADC
// or FIFO instantiated) and checks the enable->valid handshake, the FIFO-full
// drop path, and that a stale (still-high) adc_valid is ignored until the next
// conversion actually starts. Runs standalone — no ARM IP needed.
// -----------------------------------------------------------------------------
module wrapper_control_tb;

    reg  clk, rstn;
    reg  sample_trig;
    reg  fifo_full;
    reg  adc_valid;
    wire fifo_write_en;
    wire adc_en;
    wire err_fifo_full;

    integer pass_count = 0;
    integer fail_count = 0;

    wrapper_control uut (
        .clk           (clk),
        .rstn          (rstn),
        .sample_trig   (sample_trig),
        .fifo_full     (fifo_full),
        .fifo_write_en (fifo_write_en),
        .adc_en        (adc_en),
        .adc_valid     (adc_valid),
        .err_fifo_full (err_fifo_full)
    );

    always #5 clk = ~clk;

    task check_true;
        input        cond;
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

    // Model the ADC just enough: when the FSM enables it, drop valid for a few
    // cycles (conversion) then raise it. Runs in parallel with the stimulus.
    integer conv;
    initial conv = 0;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, wrapper_control_tb);

        clk = 0; rstn = 0; sample_trig = 0; fifo_full = 0; adc_valid = 0;
        repeat(3) @(posedge clk);
        rstn = 1;
        repeat(2) @(posedge clk);

        // --- Case 1: normal conversion, valid starts low ---
        adc_valid = 0;
        @(posedge clk); sample_trig = 1;
        @(posedge clk); sample_trig = 0;
        // FSM: CHECK -> ENABLE -> WAIT_START(valid low ok) -> WAIT_DONE
        repeat(3) @(posedge clk);
        check_true(adc_en === 1'b1, "C1 adc_en asserted during conversion");
        // conversion completes
        adc_valid = 1;
        // WAIT_DONE -> WRITE on the next edge; fifo_write_en is a 1-cycle pulse
        @(posedge clk);
        check_true(fifo_write_en === 1'b1, "C1 fifo_write_en pulses on completion");
        @(posedge clk);
        check_true(fifo_write_en === 1'b0, "C1 fifo_write_en is a 1-cycle pulse");
        check_true(adc_en === 1'b0, "C1 adc_en deasserted after write");
        adc_valid = 0;

        // --- Case 2: FIFO full at pre-check -> sample dropped ---
        repeat(2) @(posedge clk);
        fifo_full = 1;
        @(posedge clk); sample_trig = 1;
        @(posedge clk); sample_trig = 0;
        repeat(3) @(posedge clk);
        check_true(err_fifo_full === 1'b1, "C2 err_fifo_full set when FIFO full");
        check_true(adc_en === 1'b0, "C2 ADC not enabled when FIFO full");
        fifo_full = 0;

        // --- Case 3: stale adc_valid (=1) must be ignored until conversion starts ---
        adc_valid = 1;                 // pretend previous result still latched
        @(posedge clk); sample_trig = 1;
        @(posedge clk); sample_trig = 0;
        // FSM enables ADC and must sit in WAIT_START until valid FALLS
        repeat(4) @(posedge clk);
        check_true(fifo_write_en === 1'b0, "C3 no premature write while valid stale-high");
        adc_valid = 0;                 // conversion starts (valid falls)
        repeat(2) @(posedge clk);
        adc_valid = 1;                 // conversion done (valid rises)
        @(posedge clk);                // WAIT_DONE -> WRITE
        check_true(fifo_write_en === 1'b1, "C3 write after a real valid edge");
        @(posedge clk);
        adc_valid = 0;

        $display("\n=== FSM: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        #20 $finish;
    end

    initial begin
        #100000;
        $display("WATCHDOG TIMEOUT");
        $finish;
    end

endmodule
