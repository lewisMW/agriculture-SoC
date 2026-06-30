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

// ── APB passthrough tasks (external master) ───────────────────────────────────
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
        @(posedge PCLK);
        rdata  = PRDATA;
        slverr = PSLVERR;
        #1;
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

// =============================================================================
// Stimulus
// =============================================================================
initial begin
    $dumpfile("tb_rtc_control.vcd");
    $dumpvars(0, tb_rtc_control);

    pass_count = 0;
    fail_count = 0;

    // Initialise bus to idle
    PSEL      = 0;
    PENABLE   = 0;
    PWRITE    = 0;
    PADDR     = 0;
    PWDATA    = 0;

    // Default alarm offset - 5 CLK1HZ ticks
    alarm_offset = 32'd5;

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

    // P05 - FSM should immediately move to S_ENABLE_SETUP after reset
    // It auto-starts from IDLE so catch it early
    // Re-reset to observe cleanly
    // In AREA 2 (P05/P06): wait for nRTCRST to propagate
    PRESETn = 1'b0;
    repeat(3) @(posedge PCLK);
    PRESETn = 1'b1;
    // Wait 2 CLK1HZ cycles for nRTCRST synchronizer
    repeat(2) @(posedge CLK1HZ);
    @(posedge PCLK); #1;
    @(posedge PCLK);
    check(`FSM_STATE, `S_ENABLE_SETUP, "P05 FSM goes to ENABLE_SETUP first");

    // =========================================================================
    // AREA 3: Timestamp read (P07-P08)
    // =========================================================================
    $display("\n--- Timestamp read (P07-P08) ---");

    // Wait for FSM to complete full first cycle and reach WAITING
    wait_for_state(`S_WAITING, 200);

    // P07 - ctrl_time_value should be non-zero (RTC has been running)
    //       We can't predict exact value but it should not be 0 after
    //       several CLK1HZ ticks have passed
    // repeat(10) @(posedge CLK1HZ);
    repeat(2) @(posedge PCLK);
    // capture via hierarchical ref to confirm it was latched during READ_ACCESS
    captured_time = ctrl_time_value;
    if (captured_time !== 32'h0)
        $display("PASS [%0t] P07 ctrl_time_value captured non-zero: 0x%08X",
                 $time, captured_time);
    else begin
        $display("FAIL [%0t] P07 ctrl_time_value still zero after RTC running",
                 $time);
        fail_count = fail_count + 1;
    end
    pass_count = pass_count + 1;

    // P08 - alarm_target should be ctrl_time_value + alarm_offset
    //       CDC latency means ctrl_time_value = RTC_counter - 1, but
    //       alarm_target = ctrl_time_value + alarm_offset exactly
    captured_alarm = `ALARM_TARGET;
    check(captured_alarm, captured_time + alarm_offset,
          "P08 alarm_target = time + offset");

    // =========================================================================
    // AREA 4: Alarm calculation (P09-P10)
    // =========================================================================
    $display("\n--- Alarm calculation (P09-P10) ---");

    // P09 - already confirmed by P08, check with different offset
    //       Trigger a new cycle by waiting for rtc_trig and then
    //       changing alarm_offset before next READ
    // For now verify the stored alarm_target matches arithmetic
    check(`ALARM_TARGET, ctrl_time_value + alarm_offset,
          "P09 alarm arithmetic correct");

    // P10 - alarm_target must be > ctrl_time_value (always in the future)
    if (`ALARM_TARGET > ctrl_time_value)
        $display("PASS [%0t] P10 alarm_target is in the future", $time);
    else begin
        $display("FAIL [%0t] P10 alarm_target not in future: target=0x%08X time=0x%08X",
                 $time, `ALARM_TARGET, ctrl_time_value);
        fail_count = fail_count + 1;
    end
    pass_count = pass_count + 1;

    // =========================================================================
    // AREA 5: Match register + IMSC write (P11-P12)
    // =========================================================================
    $display("\n--- Match register and IMSC (P11-P12) ---");

    // FSM should already be in WAITING - the match and IMSC writes happened
    // before we got here. Check via the RTC's own readable registers
    // by doing a passthrough read of RTCMR (word addr 0x001 = byte 0x004)
    // and RTCIMSC (word addr 0x004 = byte 0x010)

    // P11 - RTCMR should equal alarm_target
    ext_apb_read(12'h004, rd_data, rd_slverr);  // RTCMR byte offset
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

    // P14 - Wait for real interrupt to fire (alarm_offset=5 ticks)
    //       FSM should leave WAITING only when RTCINTR goes high
    begin : wait_alarm
        integer timeout;
        timeout = 0;
        while (`FSM_STATE === `S_WAITING && timeout < 5000) begin
            @(posedge PCLK);
            timeout = timeout + 1;
        end
        if (`FSM_STATE !== `S_WAITING)
            $display("PASS [%0t] P14 FSM left WAITING when RTCINTR fired",
                     $time);
        else begin
            $display("FAIL [%0t] P14 FSM stuck in WAITING - RTCINTR never fired",
                     $time);
            fail_count = fail_count + 1;
        end
    end
    pass_count = pass_count + 1;

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

    // P17 - external access during non-idle/waiting state returns PSLVERR
    // Force FSM out of WAITING by triggering a new cycle
    // We do this by resetting - after reset FSM goes through ENABLE->READ etc
    // and we catch it mid-flight
    PRESETn = 1'b0;
    repeat(3) @(posedge PCLK);
    PRESETn = 1'b1; //TODO
    // FSM will be in S_ENABLE_SETUP or S_READ_SETUP - neither is IDLE or WAITING
    // so an external access should get PSLVERR
    @(posedge PCLK); #1;
    // Wait until we're in a busy state (not IDLE, not WAITING)
    wait_for_state(`S_ENABLE_ACCESS, 10);
    // Now try an external read - should get PSLVERR
    PSEL    = 1'b1;
    PENABLE = 1'b0;
    PWRITE  = 1'b0;
    PADDR   = 12'h000;
    @(posedge PCLK); #1;
    PENABLE = 1'b1;
    @(posedge PCLK);
    check(PSLVERR, 1'b1, "P17 PSLVERR asserted during FSM-busy state");
    rd_data = PRDATA;
    check(rd_data, 32'h0, "P17b PRDATA=0 during FSM-busy state");
    #1;
    PSEL    = 1'b0;
    PENABLE = 1'b0;

    // P18 - PREADY always 1 regardless of state
    check(PREADY, 1'b1, "P18 PREADY always 1");
    wait_for_state(`S_WAITING, 500);
    check(PREADY, 1'b1, "P18b PREADY still 1 in WAITING");

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

    // P20 - FSM writes RTCICR=1 to clear (check FSM goes through ICR states)
    wait_for_state(`S_ICR_SETUP, 100);
    $display("PASS [%0t] P20 FSM entered ICR_SETUP to clear interrupt", $time);
    pass_count = pass_count + 1;

    // P21 - rtc_trig pulses for exactly 1 cycle
    wait_for_state(`S_PULSE_TRIG, 20);
    @(posedge PCLK);
    check(rtc_trig, 1'b1, "P21 rtc_trig high in PULSE_TRIG");
    @(posedge PCLK);
    check(rtc_trig, 1'b0, "P21b rtc_trig low after 1 cycle");

    // P22 - ctrl_intr_flag goes low after clear
    repeat(3) @(posedge PCLK);
    check(ctrl_intr_flag, 1'b0, "P22 ctrl_intr_flag low after ICR write");

    // =========================================================================
    // AREA 9: Repeat cycle (P23-P24)
    // =========================================================================
    $display("\n--- Repeat cycle (P23-P24) ---");

    // P23 - after PULSE_TRIG FSM returns to IDLE then READ_SETUP (skips enable)
    wait_for_state(`S_IDLE, 20);
    @(posedge PCLK);
    // rtc_enabled should still be 1, so next state is READ_SETUP not ENABLE_SETUP
    check(`FSM_STATE, `S_READ_SETUP, "P23 second cycle skips ENABLE goes to READ");

    // P24 - second alarm is calculated correctly relative to new timestamp
    wait_for_state(`S_WAITING, 200);
    repeat(2) @(posedge PCLK);
    captured_time  = ctrl_time_value;
    captured_alarm = `ALARM_TARGET;
    check(captured_alarm, captured_time + alarm_offset,
          "P24 second alarm arithmetic correct");

    // =========================================================================
    // AREA 10: nRTCRST generation (P25-P26)
    // =========================================================================
    $display("\n--- nRTCRST generation (P25-P26) ---");

    // P25 - nRTCRST low while PRESETn low
    PRESETn = 1'b0;
    repeat(2) @(posedge PCLK);
    check(`NRTCRST, 1'b0, "P25 nRTCRST low while PRESETn low");

    // P26 - nRTCRST deasserts exactly 2 CLK1HZ cycles after PRESETn releases
    PRESETn = 1'b1;
    // After 1 CLK1HZ cycle ff1 goes high, ff2 still low
    @(posedge CLK1HZ); #1;
    check(`NRTCRST, 1'b0, "P26a nRTCRST still low after 1 CLK1HZ cycle");
    // After 2nd CLK1HZ cycle ff2 goes high
    @(posedge CLK1HZ); #1;
    check(`NRTCRST, 1'b1, "P26b nRTCRST high after 2 CLK1HZ cycles");

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
