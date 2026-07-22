`timescale 1ns/1ps
// =============================================================================
// tb_rtc_control.v
//
// Testbench for rtc_control.v
// Tests all 26 properties across 9 areas:
//   P01-P04  Reset behaviour
//   P05-P06  RTC enable (first boot)
//   P07-P08  Timestamp read
//   P09-P10  Alarm calculation
//   P11-P12  Match register + interrupt mask write
//   P13-P14  Waiting behaviour
//   P15-P18  Passthrough
//   P19-P22  Interrupt handling
//   P23-P24  Repeat cycle
//   P25-P26  nRTCRST generation
//   P27      RTC time survives an APB reset
//   P28-P32  poll_enable disable/enable (Task A)
// =============================================================================

// ── FSM state values - must match rtc_control.v ──────────────────────────────
`define S_IDLE          5'd0
`define S_ENABLE_SETUP  5'd1
`define S_ENABLE_ACCESS 5'd2
`define S_READ_SETUP    5'd3
`define S_READ_ACCESS   5'd4
`define S_CALC          5'd5
`define S_MATCH_SETUP   5'd6
`define S_MATCH_ACCESS  5'd7
`define S_IMSC_SETUP    5'd8
`define S_IMSC_ACCESS   5'd9
`define S_WAITING       5'd10
`define S_ICR_SETUP     5'd11
`define S_ICR_ACCESS    5'd12
`define S_PULSE_TRIG    5'd13
`define S_TICK_SETUP    5'd14
`define S_TICK_ACCESS   5'd15
`define S_TICK_CAPTURE  5'd16

module tb_rtc_control;

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

// Passthrough ports
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
integer trig_count;                 // counts rtc_trig pulses (for poll_enable test)
reg [31:0] time_at_alarm_set;

// ── DUT instantiation ─────────────────────────────────────────────────────────
rtc_control #(
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

// ── Hierarchical references into DUT ─────────────────────────────────────────
// Used to inspect internal FSM state and signals without extra ports
`define FSM_STATE    dut.state
`define RTC_ENABLED  dut.rtc_enabled
`define ALARM_TARGET dut.alarm_target
`define NRTCRST      dut.nRTCRST
`define RTC_PSEL     dut.u_rtc.PSEL
`define RTC_PENABLE  dut.u_rtc.PENABLE
`define RTC_PWRITE   dut.u_rtc.PWRITE
`define RTC_PADDR    dut.u_rtc.PADDR
`define RTC_PWDATA   dut.u_rtc.PWDATA
`define RTC_PRDATA   dut.rtc_prdata

// ── Clock generation ──────────────────────────────────────────────────────────
initial PCLK   = 0;
always #(PCLK_PERIOD/2)   PCLK   = ~PCLK;

initial CLK1HZ = 0;
always #(CLK1HZ_PERIOD/2) CLK1HZ = ~CLK1HZ;

// ── Debug monitor ─────────────────────────────────────────────────────────────
always @(posedge PCLK) begin
    if (dut.state != `S_IDLE && dut.state != `S_WAITING)
    $display("[%0t] state=%0d nRTCRST=%b rtc_psel=%b rtc_penable=%b rtc_pwrite=%b rtc_paddr=0x%03X rtc_pwdata=0x%08X rtc_prdata=0x%08X RTCINTR=%b",
             $time,
             dut.state,
             dut.nRTCRST,
             dut.rtc_psel,
             dut.rtc_penable,
             dut.rtc_pwrite,
             dut.rtc_paddr,
             dut.rtc_pwdata,
             dut.rtc_prdata,
             dut.RTCINTR);
end


// ── rtc_trig pulse counter (used by the poll_enable disable/enable test) ─────
always @(posedge PCLK) begin
    if (!PRESETn) trig_count <= 0;
    else if (rtc_trig) trig_count <= trig_count + 1;
end

// ── Check task ────────────────────────────────────────────────────────────────
task check;
    input [31:0]  actual;
    input [31:0]  expected;
    input [511:0] name;
    begin
        if (actual === expected) begin
            $display("PASS [%0t] %s : got 0x%08X", $time, name, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL [%0t] %s : expected 0x%08X got 0x%08X",
                     $time, name, expected, actual);
            fail_count = fail_count + 1;
        end
    end
endtask

// ── Boolean check (for properties without a single expected word) ─────────────
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

// ── APB passthrough tasks (external master) ───────────────────────────────────
// These tasks model the AHB->APB bridge: they hold the ACCESS phase until the
// slave asserts PREADY. rtc_control now inserts wait states (instead of PSLVERR)
// when a passthrough access collides with an autonomous arm cycle, so a bridge
// must wait for PREADY — the old fixed 1-cycle ACCESS would abandon a stalled
// transfer.
task ext_apb_write;
    input [11:0] addr;
    input [31:0] data;
    begin
        @(posedge PCLK); #1;
        PADDR   = addr;
        PWDATA  = data;
        PWRITE  = 1'b1;
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        @(posedge PCLK); #1;
        while (!PREADY) begin @(posedge PCLK); #1; end
        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
    end
endtask

task ext_apb_read;
    input  [11:0] addr;
    output [31:0] rdata;
    output        slverr;
    begin
        @(posedge PCLK); #1;
        PADDR   = addr;
        PWDATA  = 32'h0;
        PWRITE  = 1'b0;
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        @(posedge PCLK); #1;
        while (!PREADY) begin @(posedge PCLK); #1; end
        rdata  = PRDATA;
        slverr = PSLVERR;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
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

// ── Wait for FSM to reach a target state ──────────────────────────────────────
task wait_for_state;
    input [4:0] target;
    input [31:0] timeout_cycles;
    integer i;
    begin
        i = 0;
        while (`FSM_STATE !== target && i < timeout_cycles) begin
            @(posedge PCLK);
            i = i + 1;
        end
        if (i >= timeout_cycles)
            $display("TIMEOUT waiting for state %0d at t=%0t", target, $time);
    end
endtask

// ── Temporary read data and slverr ────────────────────────────────────────────
reg [31:0] rd_data;
reg        rd_slverr;
reg [31:0] captured_time;
reg [31:0] captured_alarm;
integer    trig_saved;
integer    stall_cycles;

// =============================================================================
// Stimulus
// =============================================================================
initial begin
    $dumpfile("tb_rtc_control.vcd");
    $dumpvars(0, tb_rtc_control);

    pass_count = 0;
    fail_count = 0;

    // Autonomous polling enabled by default (matches the reg's reset value)
    poll_enable = 1'b1;

    // Initialise bus to idle
    PSEL      = 0;
    PENABLE   = 0;
    PWRITE    = 0;
    PADDR     = 0;
    PWDATA    = 0;

    // Default alarm offset - 10 CLK1HZ ticks. Big enough to leave a comfortable
    // window in WAITING for the passthrough / read tests before the alarm fires,
    // and still well inside the interrupt-wait timeouts below.
    alarm_offset = 32'd10;

    // =========================================================================
    // AREA 1: Reset behaviour  (P01-P04)
    // =========================================================================
    $display("\n--- Reset behaviour (P01-P04) ---");

    PRESETn = 1'b0;
    nPOR    = 1'b0;
    repeat(5) @(posedge PCLK);

    // P01 - FSM in S_IDLE during reset
    check(`FSM_STATE, `S_IDLE, "P01 FSM in IDLE during reset");

    // P02 - rtc_trig low during reset
    check(rtc_trig, 1'b0, "P02 rtc_trig low during reset");

    // P03 - ctrl_time_value zero during reset
    check(ctrl_time_value, 32'h0, "P03 ctrl_time_value zero during reset");

    // P04 - ctrl_intr_flag zero during reset
    check(ctrl_intr_flag, 1'b0, "P04 ctrl_intr_flag zero during reset");

    // Release resets
    nPOR    = 1'b1;
    PRESETn = 1'b1;
    repeat(2) @(posedge CLK1HZ);
    repeat(3) @(posedge PCLK);
    $display("--- Reset released ---");

    // =========================================================================
    // AREA 2: RTC enable - first boot (P05-P06)
    // =========================================================================
    $display("\n--- RTC enable first boot (P05-P06) ---");

    // P05 - After an APB-only reset (PRESETn pulse, nPOR held high) the RTC
    //   block stays out of reset (nRTCRST tracks nPOR), so the FSM re-arms
    //   immediately: its first action is ENABLE_SETUP on the next cycle, with
    //   no wait for the nRTCRST synchroniser.
    PRESETn = 1'b0;
    repeat(3) @(posedge PCLK);
    PRESETn = 1'b1;
    // nRTCRST stays high (it tracks nPOR), so the FSM re-arms immediately.
    // Catch the transient ENABLE_SETUP rather than assuming a fixed cycle.
    wait_for_state(`S_ENABLE_SETUP, 20);
    check(`FSM_STATE, `S_ENABLE_SETUP, "P05 FSM re-enables (ENABLE_SETUP) after APB reset");

    // =========================================================================
    // AREA 3: Timestamp read (P07-P08)
    // =========================================================================
    $display("\n--- Timestamp read (P07-P08) ---");
    wait_for_state(`S_CALC, 200);
    time_at_alarm_set = ctrl_time_value;
    // Wait for FSM to complete full first cycle and reach WAITING
    wait_for_state(`S_WAITING, 200);

    // P07 - RTC counter is running. The counter starts from 0 at enable, so
    //       rather than expecting a non-zero snapshot we prove it advances:
    //       read RTCDR via passthrough, wait a couple of CLK1HZ ticks, read
    //       again, and confirm it incremented.
    ext_apb_read(12'h000, rd_data, rd_slverr);          // RTCDR now
    captured_time = rd_data;
    repeat(2) @(posedge CLK1HZ);
    repeat(2) @(posedge PCLK);
    ext_apb_read(12'h000, rd_data, rd_slverr);          // RTCDR later
    check_true(rd_data > captured_time,
               "P07 RTCDR advances over time (counter running)");

    // P08 - alarm_target should be ctrl_time_value + alarm_offset
    //       CDC latency means ctrl_time_value = RTC_counter - 1, but
    //       alarm_target = ctrl_time_value + alarm_offset exactly
    captured_alarm = `ALARM_TARGET;
    check(captured_alarm, time_at_alarm_set + alarm_offset,
          "P08 alarm_target = time + offset");

    // =========================================================================
    // AREA 4: Alarm calculation (P09-P10)
    // =========================================================================
    $display("\n--- Alarm calculation (P09-P10) ---");

    // P09 - already confirmed by P08, check with different offset
    //       Trigger a new cycle by waiting for rtc_trig and then
    //       changing alarm_offset before next READ
    // For now verify the stored alarm_target matches arithmetic
    // Accomplishes nothing so removed.
    // check(`ALARM_TARGET, ctrl_time_value + alarm_offset,
    //       "P09 alarm arithmetic correct");

    // P10 - alarm_target must be > ctrl_time_value (always in the future)
    repeat(4) @(posedge PCLK);
    check_true(`ALARM_TARGET > ctrl_time_value,
               "P10 alarm_target is in the future");

    // =========================================================================
    // AREA 5: Match register + IMSC write (P11-P12)
    // =========================================================================
    $display("\n--- Match register and IMSC (P11-P12) ---");

    // FSM should already be in WAITING - the match and IMSC writes happened
    // before we got here. Check via the RTC's own readable registers
    // by doing a passthrough read of RTCMR (word addr 0x001 = byte 0x004)
    // and RTCIMSC (word addr 0x004 = byte 0x010)

    // P11 - RTCMR should equal alarm_target
    $display("Time [%0t]", $time);
    ext_apb_read(12'h004, rd_data, rd_slverr);  // RTCMR byte offset
    $display("Time [%0t] rd_slverr: [%b]",
                 $time, rd_slverr);
    check(rd_data, `ALARM_TARGET, "P11 RTCMR matches alarm_target");

    // P12 - RTCIMSC should be 1 (unmasked)
    ext_apb_read(12'h010, rd_data, rd_slverr);  // RTCIMSC byte offset
    check(rd_data & 32'h1, 32'h1, "P12 RTCIMSC unmasked");

    // =========================================================================
    // AREA 6: Waiting behaviour (P13-P14)
    // =========================================================================
    $display("\n--- Waiting behaviour (P13-P14) ---");

    // P13 - FSM stays in WAITING until RTCINTR fires
    //       Confirm still in WAITING after several PCLK cycles
    check(`FSM_STATE, `S_WAITING, "P13 FSM stays in WAITING");
    repeat(10) @(posedge PCLK);
    check(`FSM_STATE, `S_WAITING, "P13b FSM still in WAITING after 10 cycles");

    // P14 - Wait for the real interrupt to fire. FSM should leave WAITING only
    //       when RTCINTR goes high.
    begin : wait_alarm
        integer timeout;
        timeout = 0;
        while (`FSM_STATE === `S_WAITING && timeout < 5000) begin
            @(posedge PCLK);
            timeout = timeout + 1;
        end
        check_true(`FSM_STATE !== `S_WAITING,
                   "P14 FSM left WAITING when RTCINTR fired");
    end

    // =========================================================================
    // AREA 7: Passthrough (P15-P18)
    // =========================================================================
    // To test passthrough we need FSM back in WAITING.
    // Wait for next cycle to complete setup and reach WAITING again.
    $display("\n--- Passthrough (P15-P18) ---");

    wait_for_state(`S_WAITING, 500);
    repeat(2) @(posedge PCLK);

    // P15 - external APB read of RTCDR during WAITING succeeds (no PSLVERR)
    ext_apb_read(12'h000, rd_data, rd_slverr);  // RTCDR byte offset 0x000
    check(rd_slverr, 1'b0, "P15 no PSLVERR on read during WAITING");
    if (rd_data !== 32'h0)
        $display("PASS [%0t] P15b RTCDR read returned non-zero: 0x%08X",
                 $time, rd_data);
    else
        $display("NOTE [%0t] P15b RTCDR read returned 0 - check RTC running",
                 $time);

    // P16 - external APB write to RTCMR during WAITING succeeds (no PSLVERR)
    // Write a new match value - just testing the transaction completes cleanly
    // Note: this will change the alarm, which is fine for test purposes
    ext_apb_write(12'h004, 32'hFFFFFFFF);  // RTCMR - far future, won't fire
    repeat(2) @(posedge PCLK);
    ext_apb_read(12'h004, rd_data, rd_slverr);
    check(rd_slverr, 1'b0, "P16 no PSLVERR on write during WAITING");
    check(rd_data, 32'hFFFFFFFF, "P16b RTCMR write took effect");

    // P17 - an external access that COLLIDES with an arm cycle is now STALLED
    // (PREADY held low) and then completes WITHOUT PSLVERR. Previously this
    // returned PSLVERR, which the AHB->APB bridge turns into an AHB error and
    // the Cortex-M0 turns into an unrecoverable HardFault (hang). The wait-state
    // removes that hang vector: firmware can read the RTC region at any time.
    // Force FSM out of WAITING by resetting - it re-arms and we catch it busy.
    PRESETn = 1'b0;
    repeat(3) @(posedge PCLK);
    PRESETn = 1'b1;
    // nRTCRST stays high across an APB reset (tracks nPOR), so the FSM re-arms
    // immediately -- catch it in a busy (non-idle/non-waiting) state so the
    // external ACCESS below lands while the FSM owns the bus.
    wait_for_state(`S_ENABLE_ACCESS, 20);
    // Drive a RAW external read (no auto-wait) so we can observe the stall.
    PSEL    = 1'b1;
    PENABLE = 1'b0;
    PWRITE  = 1'b0;
    PADDR   = 12'h000;
    @(posedge PCLK); #1;
    PENABLE = 1'b1;
    @(posedge PCLK); #1;
    check(PREADY,  1'b0, "P17 colliding access stalls (PREADY low), not yet complete");
    check(PSLVERR, 1'b0, "P17b no PSLVERR while stalled (no HardFault path)");
    // Hold ACCESS until the slave completes (models the AHB->APB bridge).
    // Bounded so a (hypothetical) permanent stall fails loudly instead of
    // hanging the sim -- the FSM always parks within ~10 PCLK, so this exits fast.
    stall_cycles = 0;
    while (!PREADY && stall_cycles < 200) begin @(posedge PCLK); #1; stall_cycles = stall_cycles + 1; end
    // NOTE: check/check_true name inputs are [511:0] = 64 chars max — longer
    // literals fail Verilator elaboration ("generates N bits ... doesn't fit").
    check_true(PREADY === 1'b1, "P17c colliding access completes (bounded stall, PREADY high)");
    check(PSLVERR, 1'b0, "P17d colliding access completes WITHOUT PSLVERR");
    rd_data = PRDATA;
    #1;
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    $display("    P17: collision stalled %0d extra cycle(s) then completed, RTCDR=0x%08h",
             stall_cycles, rd_data);

    // P18 - when parked in WAITING the bus is free: a passthrough read completes
    // with no wait state (PREADY high) and no error.
    wait_for_state(`S_WAITING, 500);
    check(PREADY, 1'b1, "P18 PREADY high (no stall) when parked in WAITING");
    ext_apb_read(12'h000, rd_data, rd_slverr);
    check(rd_slverr, 1'b0, "P18b passthrough read succeeds when parked");

    // =========================================================================
    // AREA 8: Interrupt handling (P19-P22)
    // =========================================================================
    $display("\n--- Interrupt handling (P19-P22) ---");

    // Restore real alarm so interrupt fires - write RTCMR via passthrough
    // to alarm_target + small offset from now
    ext_apb_read(12'h000, rd_data, rd_slverr);  // read current time
    ext_apb_write(12'h004, rd_data + 32'd3);    // set alarm 3 ticks ahead
    repeat(2) @(posedge PCLK);

    // Wait for RTCINTR to fire
    begin : wait_intr2
        integer timeout;
        timeout = 0;
        while (ctrl_intr_flag !== 1'b1 && timeout < 5000) begin
            @(posedge PCLK);
            timeout = timeout + 1;
        end

        // P19 - ctrl_intr_flag goes high when RTCINTR fires
        check(ctrl_intr_flag, 1'b1, "P19 ctrl_intr_flag high when RTCINTR fires");
    end

    // P20 - FSM writes RTCICR=1 to clear (check FSM enters the ICR states)
    wait_for_state(`S_ICR_SETUP, 100);
    check(`FSM_STATE, `S_ICR_SETUP, "P20 FSM entered ICR_SETUP to clear interrupt");

    // P21 - rtc_trig pulses for exactly 1 cycle
    // P23 - after PULSE_TRIG the FSM returns to IDLE for a single cycle then
    //       jumps straight to READ_SETUP (rtc_enabled still 1, so ENABLE is
    //       skipped). IDLE lasts only one cycle, so both are checked in-sequence
    //       here rather than by polling for the transient IDLE state.
    wait_for_state(`S_PULSE_TRIG, 20);
    @(posedge PCLK);
    check(rtc_trig, 1'b1, "P21 rtc_trig high in PULSE_TRIG");
    check(`FSM_STATE, `S_IDLE, "P23 returns to IDLE after PULSE_TRIG");
    @(posedge PCLK);
    check(rtc_trig, 1'b0, "P21b rtc_trig low after 1 cycle");
    check(`FSM_STATE, `S_READ_SETUP, "P23b second cycle skips ENABLE, goes to READ");

    // P22 - ctrl_intr_flag goes low after clear
    repeat(3) @(posedge PCLK);
    check(ctrl_intr_flag, 1'b0, "P22 ctrl_intr_flag low after ICR write");

    // =========================================================================
    // AREA 9: Repeat cycle (P24)
    // =========================================================================
    $display("\n--- Repeat cycle (P24) ---");

    // P24 - second alarm is calculated correctly relative to new timestamp
    wait_for_state(`S_WAITING, 200);
    repeat(2) @(posedge PCLK);
    captured_time  = ctrl_time_value;
    captured_alarm = `ALARM_TARGET;
    check(captured_alarm, captured_time + alarm_offset,
          "P24 second alarm arithmetic correct");

    // =========================================================================
    // AREA 9b: RTC time survives an APB reset (P27)
    // =========================================================================
    $display("\n--- Time survives APB reset (P27) ---");

    // Capture the live time (retry if the FSM briefly owns the bus)
    wait_for_state(`S_WAITING, 500);
    begin : rd_before
        integer t; t = 0;
        ext_apb_read(12'h000, rd_data, rd_slverr);         // RTCDR
        while (rd_slverr && t < 100) begin
            ext_apb_read(12'h000, rd_data, rd_slverr); t = t + 1;
        end
        captured_time = rd_data;
    end

    // APB reset ONLY (nPOR stays high) — the counter must keep running.
    PRESETn = 1'b0;
    repeat(3) @(posedge PCLK);
    PRESETn = 1'b1;
    wait_for_state(`S_WAITING, 500);
    begin : rd_after
        integer t; t = 0;
        ext_apb_read(12'h000, rd_data, rd_slverr);
        while (rd_slverr && t < 100) begin
            ext_apb_read(12'h000, rd_data, rd_slverr); t = t + 1;
        end
        captured_alarm = rd_data;   // reuse reg for the "after" value
    end
    $display("    time before=0x%08X after=0x%08X", captured_time, captured_alarm);
    check_true(captured_alarm >= captured_time,
               "P27 RTC time preserved across APB reset (counter not reset)");

    // =========================================================================
    // AREA 10: nRTCRST generation vs nPOR (P25-P26)
    // =========================================================================
    $display("\n--- nRTCRST generation (P25-P26) ---");

    // P25 - nRTCRST low while nPOR low (RTC block reset; independent of PRESETn)
    nPOR = 1'b0;
    repeat(2) @(posedge PCLK);
    check(`NRTCRST, 1'b0, "P25 nRTCRST low while nPOR low");

    // P26 - nRTCRST deasserts exactly 2 CLK1HZ cycles after nPOR releases
    nPOR = 1'b1;
    @(posedge CLK1HZ); #1;
    check(`NRTCRST, 1'b0, "P26a nRTCRST still low after 1 CLK1HZ cycle");
    @(posedge CLK1HZ); #1;
    check(`NRTCRST, 1'b1, "P26b nRTCRST high after 2 CLK1HZ cycles");

    // =========================================================================
    // AREA 11: poll_enable disable/enable (P28-P32)
    //   Task A: firmware must be able to pause autonomous polling without
    //   stopping the RTC counter. Clean-slate reset, arm a short period, prove:
    //     - autonomous rtc_trig fires while enabled
    //     - disable -> no further rtc_trig even though the alarm fires
    //     - the counter keeps advancing while disabled (passthrough still works)
    //     - re-enable -> rtc_trig resumes (pending alarm serviced immediately)
    // =========================================================================
    $display("\n--- poll_enable disable/enable (P28-P32) ---");

    // Clean slate so this area doesn't depend on the nPOR toggling above.
    poll_enable = 1'b1;
    alarm_offset = 32'd3;            // short period for a quick alarm
    do_reset;

    // Let the first autonomous cycle complete: FSM arms, alarm fires, trig pulses.
    begin : wait_first_trig
        integer t; t = 0;
        while (trig_count == 0 && t < 20000) begin @(posedge PCLK); t = t + 1; end
    end
    // P28 - autonomous trigger fires while enabled
    check_true(trig_count >= 1, "P28 autonomous rtc_trig fires while poll_enable=1");

    // Disable polling immediately after a trigger (FSM is re-arming toward the
    // next alarm, well inside the alarm_offset window).
    poll_enable = 1'b0;
    trig_saved  = trig_count;

    // Capture time, then wait longer than alarm_offset so the alarm WOULD fire.
    ext_apb_read(12'h000, rd_data, rd_slverr);
    captured_time = rd_data;
    repeat(6) @(posedge CLK1HZ);    // > alarm_offset (3) CLK1HZ ticks
    repeat(4) @(posedge PCLK);

    // P29 - no new rtc_trig while disabled, even though the alarm fired
    check(trig_count, trig_saved, "P29 no rtc_trig while poll_enable=0");

    // P30 - FSM parked in WAITING while disabled (bus free for passthrough)
    check(`FSM_STATE, `S_WAITING, "P30 FSM parked in WAITING while disabled");

    // P31 - counter still advancing while disabled (passthrough read succeeds)
    ext_apb_read(12'h000, rd_data, rd_slverr);
    check_true(rd_slverr === 1'b0, "P31a passthrough read still granted while disabled");
    check_true(rd_data > captured_time, "P31b RTC counter advances while disabled");

    // Re-enable: the alarm that fired while disabled is pending, so trig should
    // resume promptly.
    poll_enable = 1'b1;
    begin : wait_resume
        integer t; t = 0;
        while (trig_count == trig_saved && t < 20000) begin @(posedge PCLK); t = t + 1; end
    end
    // P32 - rtc_trig resumes after re-enable
    check_true(trig_count > trig_saved, "P32 rtc_trig resumes after poll_enable=1");

    // =========================================================================
    // Summary
    // =========================================================================
    $display("\n─────────────────────────────────────");
    $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
    $display("─────────────────────────────────────");

    #100;
    $finish;
end

// ── Watchdog ──────────────────────────────────────────────────────────────────
initial begin
    #50_000_000;
    $display("WATCHDOG TIMEOUT - simulation hung");
    $finish;
end

endmodule
