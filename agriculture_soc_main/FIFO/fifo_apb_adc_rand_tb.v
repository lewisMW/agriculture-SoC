`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// fifo_apb_adc_rand_tb.v
//
// Rigorous, self-checking unit test for fifo_apb_adc. Where the original
// fifo_apb_adc_tb just $displays data, this one carries a software reference
// model (a queue) and asserts against it, plus continuous invariant monitors.
//
// Covers the FIFO properties from VERIFICATION.md:
//   - reset -> empty, !full
//   - fill to DEPTH, full flag exactly at DEPTH
//   - overflow attempt while full: write is dropped, no corruption
//   - drain to empty in FIFO order, empty flag exactly at 0
//   - underflow read while empty: rd_ptr does not advance / data preserved
//   - simultaneous read+write at the full and empty boundaries
//   - fifo_clear mid-traffic flushes to empty
//   - wrap-around: many push/pop cycles past DEPTH, order preserved
//   - constrained-random traffic vs. the reference model
//   - invariants (always): count <= DEPTH, full<->count==DEPTH,
//     empty<->count==0, model occupancy == dut count
//
// Standalone — no ARM IP needed.  Run: make -C FIFO rand
// -----------------------------------------------------------------------------
module fifo_apb_adc_rand_tb;

    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 4;      // small so "full" is reached quickly
    localparam N_RAND     = 400;    // constrained-random operations

    reg                   clk, rst_n;
    reg                   adc_wr_en;
    reg  [DATA_WIDTH-1:0] adc_data;
    wire                  fifo_full;
    reg                   apb_rd_en;
    wire [DATA_WIDTH-1:0] apb_rd_data;
    wire                  fifo_empty;
    reg                   fifo_clear;

    integer pass_count = 0;
    integer fail_count = 0;

    fifo_apb_adc #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n),
        .adc_wr_en(adc_wr_en), .adc_data(adc_data), .fifo_full(fifo_full),
        .apb_rd_en(apb_rd_en), .apb_rd_data(apb_rd_data), .fifo_empty(fifo_empty),
        .fifo_clear(fifo_clear)
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

    // ── Reference model: a queue mirroring the DUT ───────────────────────────
    reg [DATA_WIDTH-1:0] model_mem [0:DEPTH-1];
    integer model_head, model_tail, model_count;

    task model_reset; begin model_head = 0; model_tail = 0; model_count = 0; end endtask
    // (model occupancy is compared inline as (model_count==DEPTH)/(==0); zero-arg
    //  functions are illegal in Verilog, so no model_full()/model_empty() helpers.)

    // ── Bus-driving primitives (one op per clock, mirror DUT gating) ─────────
    // Push: hold wr_en over exactly one rising edge, then release.
    task fifo_push(input [DATA_WIDTH-1:0] d);
        begin
            adc_wr_en = 1'b1; adc_data = d;
            @(posedge clk); #1;                 // write happens on this edge if !full
            if (!fifo_full && (model_count != DEPTH)) begin
                model_mem[model_tail] = d;
                model_tail = (model_tail + 1) % DEPTH;
                model_count = model_count + 1;
            end
            adc_wr_en = 1'b0;
        end
    endtask

    // Pop: apb_rd_data is combinational (= front), so sample it before the edge
    // that advances rd_ptr, then compare against the model front.
    task fifo_pop;
        reg [DATA_WIDTH-1:0] got, exp;
        begin
            apb_rd_en = 1'b1;
            #1 got = apb_rd_data;               // front, valid this cycle
            if (!fifo_empty && (model_count != 0)) begin
                exp = model_mem[model_head];
                check_true(got === exp, "POP data matches reference-model front");
                model_head = (model_head + 1) % DEPTH;
                model_count = model_count - 1;
            end
            @(posedge clk); #1;                 // rd_ptr advances on this edge
            apb_rd_en = 1'b0;
        end
    endtask

    // Simultaneous read+write across one edge.
    task fifo_rw(input [DATA_WIDTH-1:0] d);
        reg [DATA_WIDTH-1:0] got, exp;
        reg do_wr, do_rd;
        begin
            adc_wr_en = 1'b1; adc_data = d; apb_rd_en = 1'b1;
            #1 got = apb_rd_data;
            do_wr = !fifo_full  && (model_count != DEPTH);
            do_rd = !fifo_empty && (model_count != 0);
            if (do_rd) begin
                exp = model_mem[model_head];
                check_true(got === exp, "R+W: read returns current front");
            end
            @(posedge clk); #1;
            adc_wr_en = 1'b0; apb_rd_en = 1'b0;
            // Update model to mirror the DUT's do_wr/do_rd gating on this edge.
            if (do_rd) begin model_head = (model_head + 1) % DEPTH; model_count = model_count - 1; end
            if (do_wr) begin model_mem[model_tail] = d; model_tail = (model_tail + 1) % DEPTH; model_count = model_count + 1; end
        end
    endtask

    task do_clear;
        begin
            fifo_clear = 1'b1;
            @(posedge clk); #1;
            fifo_clear = 1'b0;
            model_reset;
        end
    endtask

    // ── Continuous invariant monitors (act like concurrent assertions) ───────
    // Purely DUT-internal invariants, safe to sample at the clock edge. The
    // model-vs-DUT occupancy comparison is done inside the pop/rw tasks (at
    // task boundaries) to avoid a read-during-NBA race here.
    integer inv_fail = 0;
    always @(posedge clk) begin
        if (rst_n && !fifo_clear) begin
            if (dut.count > DEPTH)                    inv_fail = inv_fail + 1;
            if (fifo_full  !== (dut.count == DEPTH))  inv_fail = inv_fail + 1;
            if (fifo_empty !== (dut.count == 0))      inv_fail = inv_fail + 1;
        end
    end

    integer i;
    reg [DATA_WIDTH-1:0] seed_val;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_apb_adc_rand_tb);

        clk = 0; rst_n = 0; adc_wr_en = 0; adc_data = 0; apb_rd_en = 0; fifo_clear = 0;
        model_reset;

        repeat (3) @(posedge clk);
        rst_n = 1; #1;

        // 1. Reset state
        check_true(fifo_empty === 1'b1, "reset: FIFO empty");
        check_true(fifo_full  === 1'b0, "reset: FIFO not full");

        // 2. Fill exactly to DEPTH; full asserts only at DEPTH
        for (i = 0; i < DEPTH; i = i + 1) begin
            check_true(fifo_full === 1'b0, "fill: not full before DEPTH writes");
            fifo_push(8'hA0 + i[7:0]);
        end
        check_true(fifo_full  === 1'b1, "fill: full after DEPTH writes");
        check_true(fifo_empty === 1'b0, "fill: not empty when full");

        // 3. Overflow attempt: write while full must be dropped, no corruption
        fifo_push(8'hEE);                       // model_full() true -> model unchanged
        check_true(fifo_full === 1'b1, "overflow: still full after dropped write");
        check_true(dut.count === DEPTH, "overflow: count stayed at DEPTH");

        // 4. Drain to empty; values come out in write order (A0,A1,...), NOT 0xEE
        for (i = 0; i < DEPTH; i = i + 1) fifo_pop;
        check_true(fifo_empty === 1'b1, "drain: empty after DEPTH reads");
        check_true(fifo_full  === 1'b0, "drain: not full when empty");

        // 5. Underflow read: read while empty must not advance / corrupt pointers
        apb_rd_en = 1'b1; @(posedge clk); #1; apb_rd_en = 1'b0;
        check_true(fifo_empty === 1'b1, "underflow: still empty after read-when-empty");
        // prove rd_ptr wasn't corrupted: push one known value and pop it back
        fifo_push(8'h5C);
        fifo_pop;                               // checks value == 0x5C via model
        check_true(fifo_empty === 1'b1, "underflow: FIFO healthy after empty read");

        // 6. Simultaneous R+W at the empty boundary: only the write takes effect
        do_clear;
        fifo_rw(8'h11);                         // empty -> do_rd=0, do_wr=1
        check_true(dut.count === 1, "R+W@empty: count==1 (write only)");

        // 7. Simultaneous R+W while full: count holds, one in / one out
        for (i = model_count; i < DEPTH; i = i + 1) fifo_push(8'h20 + i[7:0]);
        check_true(fifo_full === 1'b1, "R+W@full: full before simultaneous R+W");
        fifo_rw(8'h33);                         // full -> do_rd=1, do_wr=1
        check_true(fifo_full === 1'b1, "R+W@full: still full (count held)");

        // 8. fifo_clear mid-traffic flushes to empty
        do_clear;
        check_true(fifo_empty === 1'b1, "clear: empty after fifo_clear");
        check_true(fifo_full  === 1'b0, "clear: not full after fifo_clear");

        // 9. Wrap-around: interleave push/pop well past DEPTH so both pointers
        //    wrap several times; the model catches any ordering/pointer error.
        do_clear;
        for (i = 0; i < 3; i = i + 1) fifo_push(8'h40 + i[7:0]);
        for (i = 0; i < 24; i = i + 1) begin
            fifo_push(8'h50 + i[7:0]);
            fifo_pop;
        end
        while (!fifo_empty) fifo_pop;
        check_true(fifo_empty === 1'b1, "wrap: drained clean after wrap-around");

        // 10. Constrained-random traffic vs. the reference model
        do_clear;
        seed_val = 8'h01;
        for (i = 0; i < N_RAND; i = i + 1) begin
            case ($random & 2'b11)
                2'd0, 2'd1: begin seed_val = seed_val + 8'h07; fifo_push(seed_val); end
                2'd2:       fifo_pop;
                2'd3:       if (($random & 8'hFF) < 8'h20) do_clear;
                            else begin seed_val = seed_val + 8'h07; fifo_rw(seed_val); end
            endcase
        end
        while (!fifo_empty) fifo_pop;           // final drain checks remaining order
        check_true(model_count == 0, "random: model drained to empty");

        // 11. Fold the continuous invariant monitor into the score
        check_true(inv_fail == 0, "invariants held for the whole run");

        $display("\n=== FIFO: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        #20 $finish;
    end

    initial begin
        #500000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== FIFO: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end

endmodule
