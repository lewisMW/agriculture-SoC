`timescale 1ns/1ps
// =============================================================================
// tb_rtc_control_rand.v
//
// Constrained-random stress test for rtc_control_2.v, complementing the directed
// tb_rtc_control.v (P01-P32). The directed tests exercise the passthrough
// arbitration at a handful of fixed points in the FSM cycle (see P15-P18b);
// this test hammers the RTC with randomly-timed external reads, a randomly
// changing poll period, and randomly-timed disable/enable toggles, all layered
// on top of the free-running autonomous arm/re-arm loop, and checks invariants
// that must hold no matter how the random timing lines up with an arm cycle:
//
//   R1 - PSLVERR is never asserted. A firmware access that collides with an
//        arm cycle must stall, never fault - this is the exact property that
//        motivated the wait-state fix (see HANDOFF.md "RTC hang hardening")
//        and that pslverr_test checks at the firmware level. This checks it
//        directly at the RTL block level, under far more collision pressure
//        (random gaps every 0-31 cycles) than any directed test applies.
//   R2 - every external transfer completes (PREADY asserts) within a bounded
//        number of PCLK cycles - i.e. the stall is never unbounded.
//   R3 - the timestamp read back never goes backwards between two consecutive
//        external reads (no RTCLR write happens in this test, so time must be
//        monotonic even across collisions and poll disable/enable).
//   R4 - autonomous polling keeps making forward progress (rtc_trig fires at
//        least once) despite the read/collision storm.
//   R5 - after each random disable/enable cycle, polling resumes.
//
// Run: `make -C RTC rand`
// =============================================================================

module tb_rtc_control_rand;

// ── Parameters ────────────────────────────────────────────────────────────────
parameter PCLK_PERIOD   = 10;    // 100 MHz
parameter CLK1HZ_PERIOD = 1000;  // 1 kHz sim-accelerated (100x slower than PCLK)

// ── DUT ports ─────────────────────────────────────────────────────────────────
reg         PCLK;
reg         PRESETn;
reg         CLK1HZ;
reg         nPOR;
reg  [31:0] alarm_offset;
reg         poll_enable;

wire [31:0] ctrl_time_value;
wire        ctrl_intr_flag;
wire        rtc_trig;

// Passthrough ports (external master)
reg         PSEL;
reg         PENABLE;
reg         PWRITE;
reg  [11:0] PADDR;
reg  [31:0] PWDATA;
wire [31:0] PRDATA;
wire        PREADY;
wire        PSLVERR;

// ── Test tracking ─────────────────────────────────────────────────────────────
integer pass_count;
integer fail_count;
integer trig_count;

// ── DUT instantiation ─────────────────────────────────────────────────────────
rtc_control_2 #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(12)
) dut (
    .PCLK           (PCLK),
    .PRESETn        (PRESETn),
    .CLK1HZ         (CLK1HZ),
    .nPOR           (nPOR),
    .alarm_offset   (alarm_offset),
    .poll_enable    (poll_enable),
    .ctrl_time_value(ctrl_time_value),
    .ctrl_intr_flag (ctrl_intr_flag),
    .rtc_trig       (rtc_trig),
    .PSEL           (PSEL),
    .PENABLE        (PENABLE),
    .PWRITE         (PWRITE),
    .PADDR          (PADDR),
    .PWDATA         (PWDATA),
    .PRDATA         (PRDATA),
    .PREADY         (PREADY),
    .PSLVERR        (PSLVERR)
);

// ── Clock generation ──────────────────────────────────────────────────────────
initial PCLK   = 0;
always #(PCLK_PERIOD/2)   PCLK   = ~PCLK;

initial CLK1HZ = 0;
always #(CLK1HZ_PERIOD/2) CLK1HZ = ~CLK1HZ;

// ── rtc_trig pulse counter ────────────────────────────────────────────────────
always @(posedge PCLK) begin
    if (!PRESETn)       trig_count <= 0;
    else if (rtc_trig)  trig_count <= trig_count + 1;
end

// ── Check task ────────────────────────────────────────────────────────────────
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

// ── Reset task ────────────────────────────────────────────────────────────────
task do_reset;
    begin
        PRESETn = 1'b0;
        nPOR    = 1'b0;
        repeat(5) @(posedge PCLK);
        nPOR    = 1'b1;
        repeat(2) @(posedge PCLK);
        PRESETn = 1'b1;
        repeat(5) @(posedge PCLK);
    end
endtask

// ── Bounded external APB read — models the AHB->APB bridge, but counts how
// many cycles PREADY was held low so a runaway stall is caught, not just
// silently absorbed by waiting forever. ─────────────────────────────────────
task ext_apb_read_bounded;
    input  [11:0] addr;
    output [31:0] rdata;
    output        slverr;
    output integer stall_cycles;
    begin
        stall_cycles = 0;
        @(posedge PCLK); #1;
        PADDR   = addr;
        PWDATA  = 32'h0;
        PWRITE  = 1'b0;
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        @(posedge PCLK); #1;
        while (!PREADY) begin
            stall_cycles = stall_cycles + 1;
            @(posedge PCLK); #1;
        end
        rdata  = PRDATA;
        slverr = PSLVERR;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    end
endtask

// =============================================================================
// Stimulus
// =============================================================================
reg [31:0] rd_data;
reg        rd_slverr;
reg [31:0] last_time;
integer    trig_before;
integer    max_stall;
integer    stall;
integer    i;
integer    N_ITER;

initial begin
    pass_count   = 0;
    fail_count   = 0;
    max_stall    = 0;
    last_time    = 32'h0;
    PSEL         = 1'b0;
    PENABLE      = 1'b0;
    PWRITE       = 1'b0;
    PADDR        = 12'h0;
    PWDATA       = 32'h0;
    alarm_offset = 32'd2;
    poll_enable  = 1'b1;

    do_reset;

    // Let the RTC finish its first enable/arm cycle before hammering it.
    repeat(200) @(posedge PCLK);

    N_ITER = 150;
    for (i = 0; i < N_ITER; i = i + 1) begin
        case ($random & 2'b11)

            2'd0, 2'd1: begin
                // Randomly-timed external read - may or may not land on top
                // of an autonomous arm cycle.
                repeat($random & 5'h1F) @(posedge PCLK);   // 0-31 cycle random gap
                ext_apb_read_bounded(12'h000, rd_data, rd_slverr, stall);
                check_true(rd_slverr === 1'b0,
                           "R1 PSLVERR never asserted on passthrough read");
                check_true(stall <= 40,
                           "R2 passthrough read completes within a bounded stall");
                if (stall > max_stall) max_stall = stall;
                check_true(rd_data >= last_time,
                           "R3 RTC time monotonic across random reads");
                last_time = rd_data;
            end

            2'd2: begin
                // Randomly change the poll period mid-flight.
                repeat($random & 4'hF) @(posedge PCLK);
                alarm_offset = 32'd1 + ($random & 32'h3);   // 1-4 "seconds"
            end

            2'd3: begin
                // Randomly disable/re-enable autonomous polling.
                repeat($random & 4'hF) @(posedge PCLK);
                poll_enable = 1'b0;
                repeat(5 + ($random & 6'h3F)) @(posedge PCLK);
                trig_before = trig_count;
                poll_enable = 1'b1;
                begin : wait_resume
                    integer t;
                    t = 0;
                    while (trig_count == trig_before && t < 20000) begin
                        @(posedge PCLK);
                        t = t + 1;
                    end
                end
                check_true(trig_count > trig_before,
                           "R5 polling resumes after random disable/enable");
            end

        endcase
    end

    check_true(trig_count > 0,
               "R4 autonomous rtc_trig fired at least once under collision storm");
    $display("Max observed passthrough stall: %0d PCLK cycles", max_stall);

    // =========================================================================
    // Summary
    // =========================================================================
    $display("\n─────────────────────────────────────");
    $display("=== RTC-RAND: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
    $display("─────────────────────────────────────");

    #100;
    $finish;
end

// ── Watchdog ──────────────────────────────────────────────────────────────────
initial begin
    #20_000_000;
    $display("WATCHDOG TIMEOUT - simulation hung");
    $display("\n=== RTC-RAND: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
    $finish;
end

endmodule
