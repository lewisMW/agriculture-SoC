`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// rtc_control_2.v
//
// Self-contained RTC controller. Owns the PL031 instance and all reset logic.
//
// Internally generates nRTCRST via a 2-flop sync on CLK1HZ, keyed off nPOR:
//   - asserted asynchronously when nPOR deasserts (power-on / cold reset)
//   - deasserted synchronously to CLK1HZ (2 cycles after nPOR reasserts)
// It is deliberately NOT derived from PRESETn, so the RTC counter keeps time
// across an APB (PRESETn) reset. Only a power-on (nPOR) — or a firmware write
// to RTCLR via passthrough — resets the count. The control FSM below is still
// reset by PRESETn and simply re-arms the alarm against the preserved time.
//
// nPOR must come from outside — it survives APB resets so cannot be
// generated internally.
//
// Scan pins are tied off — not used outside scan insertion flow.
//
// FSM sequence (auto-starts after reset):
//   IDLE -> ENABLE_RTC -> READ_TIME -> CAPTURE -> CALC_ALARM -> SET_MATCH ->
//   ENABLE_INT -> WAITING -> (RTCINTR) -> CLEAR_INT -> PULSE_TRIG -> IDLE
// On repeat cycles ENABLE is skipped (counter already running).
//
// After a power-on reset of the PL031 alone (nPOR without PRESETn) the FSM goes
// from WAITING back to IDLE as soon as the counter reset releases, and the
// next arm runs ENABLE again (see rtc_enabled below).
//
// Passthrough: while parked in WAITING (and IDLE) the FSM leaves the internal
// APB bus alone, so the external master can read/write RTC registers directly
// (e.g. firmware reading the live timestamp). A whole external transfer is
// granted at once, so the RTC always sees a protocol-correct SETUP+ACCESS.
//
// poll_enable (from the wrapper's rtc_ctrl register, reset = 1) gates autonomous
// polling. When it is low the FSM parks in WAITING and does NOT service the
// alarm: it never advances to CLEAR_INT/PULSE_TRIG, so no rtc_trig is emitted
// and wrapper_control_2 is not kicked. The PL031 counter and nRTCRST are left
// untouched, so time keeps running and passthrough reads still work while
// disabled. Re-enable semantics: as soon as poll_enable goes high again the FSM
// resumes from WAITING. If the alarm already fired while disabled (RTCINTR
// pending) it services it immediately — one sample fires on re-enable, then the
// FSM clears the interrupt, re-reads the counter and re-arms from the *current*
// time. If the alarm had not yet fired, it simply keeps waiting for the
// already-armed target. Either way there is no stale-offset stall (the bug that
// motivated this control): pausing/resuming never depends on alarm_offset.
//
// alarm_offset changes (FIX-1, pending team confirmation): a new value is
// armed as soon as the FSM is parked in WAITING with no passthrough granted -
// it re-reads the time and arms now + new offset, without an RTCICR write or
// a sample (alarm service has priority). Before FIX-1 a new offset applied
// only from the next arm, so a long armed period could not be shortened.
// -----------------------------------------------------------------------------

module rtc_control_2 #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
)(
    // ── System ────────────────────────────────────────────────────────────────
    input  wire                  PCLK,
    input  wire                  PRESETn,
    input  wire                  CLK1HZ,

    // ── Power-on reset — must survive APB reset, driven by reset controller ──
    input  wire                  nPOR,

    // ── Control interface from wrapper ────────────────────────────────────────
    input  wire [DATA_WIDTH-1:0] alarm_offset,     // seconds to wait
    input  wire                  poll_enable,       // 1 = autonomous polling on (default)

    // ── Status outputs to wrapper ─────────────────────────────────────────────
    output reg  [DATA_WIDTH-1:0] ctrl_time_value,  // last captured timestamp
    output reg                   ctrl_intr_flag,   // mirrors RTCINTR
    output reg                   rtc_trig,          // 1-cycle pulse on alarm fire

    // Passthrough ports — external master
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [11:0] PADDR,
    input  wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR

);
//random unused wires
wire        SCANOUTPCLK;
wire        SCANOUTCLK1HZ;



// -----------------------------------------------------------------------------
// nRTCRST generation — 2-flop synchroniser on CLK1HZ, keyed off nPOR (NOT
// PRESETn) so the counter survives an APB reset. Assert async with nPOR,
// deassert synchronously to CLK1HZ (2 cycles after nPOR reasserts).
// -----------------------------------------------------------------------------
reg nRTCRST_ff1, nRTCRST_ff2;

always @(posedge CLK1HZ or negedge nPOR) begin
    if (!nPOR) begin
        nRTCRST_ff1 <= 1'b0;
        nRTCRST_ff2 <= 1'b0;
    end else begin
        nRTCRST_ff1 <= 1'b1;
        nRTCRST_ff2 <= nRTCRST_ff1;
    end
end

wire nRTCRST = nRTCRST_ff2;

// nRTCRST seen from the PCLK domain. nRTCRST is a CLK1HZ-domain flop; the FSM
// and the bus arbiter below use this 2-flop-synchronised copy, never nRTCRST
// itself (it used to feed the combinational APB grant directly - an
// asynchronous signal in the PREADY/PSEL path).
reg nrtcrst_s1, nrtcrst_s2;
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) {nrtcrst_s1, nrtcrst_s2} <= 2'b00;
    else          {nrtcrst_s1, nrtcrst_s2} <= {nRTCRST, nrtcrst_s1};
end
wire nrtcrst_pclk = nrtcrst_s2;


// -----------------------------------------------------------------------------
// Passthrough — the external master's APB ports (PSEL/PENABLE/... in the port
// list) are muxed onto the RTC bus while the FSM is parked (see arbitration
// block below), so firmware can read/write RTC registers directly. If
// passthrough is not needed, tie those inputs to 0 at the wrapper.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// RTC APB signals (muxed: FSM or passthrough)
// -----------------------------------------------------------------------------
wire        rtc_psel;
wire        rtc_penable;
wire        rtc_pwrite;
wire  [9:0] rtc_paddr;
wire [31:0] rtc_pwdata;
wire [31:0] rtc_prdata;
wire        RTCINTR;

// Scan — tied off
wire SCANENABLE    = 1'b0;
wire SCANINPCLK    = 1'b0;
wire SCANINCLK1HZ  = 1'b0;

reg        fsm_psel;
reg        fsm_penable;
reg        fsm_pwrite;
reg  [9:0] fsm_paddr;
reg [31:0] fsm_pwdata;


// -----------------------------------------------------------------------------
// PL031 RTC instantiation
// -----------------------------------------------------------------------------
Rtc u_rtc (
    .PCLK          (PCLK),
    .PRESETn       (PRESETn),
    .PSEL          (rtc_psel),
    .PENABLE       (rtc_penable),
    .PWRITE        (rtc_pwrite),
    .PADDR         (rtc_paddr),
    .PWDATA        (rtc_pwdata),
    .CLK1HZ        (CLK1HZ),
    .nRTCRST       (nRTCRST),
    .nPOR          (nPOR),
    .SCANENABLE    (SCANENABLE),
    .SCANINPCLK    (SCANINPCLK),
    .SCANINCLK1HZ  (SCANINCLK1HZ),
    .PRDATA        (rtc_prdata),
    .RTCINTR       (RTCINTR),
    .SCANOUTPCLK   (SCANOUTPCLK),           // not used
    .SCANOUTCLK1HZ (SCANOUTCLK1HZ)            // not used
);

// -----------------------------------------------------------------------------
// PL031 register word addresses  (byte_offset >> 2)
// -----------------------------------------------------------------------------
localparam [9:0]
    RTC_RTCDR   = 10'h000,   // Data register        (read)
    RTC_RTCMR   = 10'h001,   // Match register       (write)
    RTC_RTCCR   = 10'h003,   // Control register     (write, bit0 = enable)
    RTC_RTCIMSC = 10'h004,   // Interrupt mask       (write, bit0 = unmask)
    RTC_RTCICR  = 10'h007;   // Interrupt clear      (write, bit0 = clear)

// -----------------------------------------------------------------------------
// FSM state encoding
// -----------------------------------------------------------------------------
localparam [4:0]
    S_IDLE          = 5'd0,
    S_ENABLE_SETUP  = 5'd1,   // APB SETUP  — write RTCCR=1
    S_ENABLE_ACCESS = 5'd2,   // APB ACCESS — write RTCCR=1
    S_READ_SETUP    = 5'd3,   // APB SETUP  — read  RTCDR
    S_READ_ACCESS   = 5'd4,   // APB ACCESS — read  RTCDR (drive PENABLE)
    S_CALC          = 5'd5,   // 1 cycle:  alarm_target = time + offset
    S_MATCH_SETUP   = 5'd6,   // APB SETUP  — write RTCMR
    S_MATCH_ACCESS  = 5'd7,   // APB ACCESS — write RTCMR
    S_IMSC_SETUP    = 5'd8,   // APB SETUP  — write RTCIMSC=1
    S_IMSC_ACCESS   = 5'd9,   // APB ACCESS — write RTCIMSC=1
    S_WAITING       = 5'd10,  // idle — wait for RTCINTR
    S_ICR_SETUP     = 5'd11,  // APB SETUP  — write RTCICR=1
    S_ICR_ACCESS    = 5'd12,  // APB ACCESS — write RTCICR=1
    S_PULSE_TRIG    = 5'd13,  // pulse rtc_trig for 1 cycle then back to IDLE
    S_READ_CAPTURE  = 5'd14;  // latch RTCDR while the bus is in the ACCESS phase

// -----------------------------------------------------------------------------
// Internal state
// -----------------------------------------------------------------------------
reg [4:0]  state;
reg [31:0] alarm_target;

// rtc_enabled: the FSM's RTCCR = 1 write has reached the PL031 since the last
// power-on reset. The PL031 keeps RTCCR, RTCMR and RTCIMSC on nPOR: a power-on
// reset clears RTCCR.start (the counter stops) and an APB reset (PRESETn) does
// not touch them. So rtc_enabled is reset by nPOR only, never by PRESETn, and
// is set in the cycle the write's ACCESS phase is on the PL031 bus (the FSM's
// bus outputs are registered, so that is the cycle after S_ENABLE_ACCESS). A
// reset that lands before that ACCESS cycle leaves rtc_enabled low and the
// enable is simply written again; rewriting RTCCR = 1 is harmless.
//   - S_IDLE writes RTCCR = 1 whenever rtc_enabled is low.
//   - S_WAITING leaves through S_IDLE to re-enable and re-arm as soon as the
//     counter reset releases, so a power-on reset of the RTC alone (nPOR
//     without PRESETn) restarts the counter at once, not one watchdog period
//     later, and no arm cycle in between can hide the need to re-enable.
// (Bug RTC-NPOR: an nPOR pulse without PRESETn stopped the counter for good.
// Its first fix cleared a PRESETn-reset flag while nRTCRST was low, and FIX-4
// then qualified the enable with a flag that every RTCMR write cleared, so an
// arm cycle between the nPOR pulse and the next S_IDLE - a FIX-1 offset
// re-arm, a watchdog service, or an arm already in flight - lost the enable
// again. Regression RTC-14 in RTC/tb_rtc_closure.sv.)
reg        rtc_enabled;

// FIX-4 (pending team confirmation): clear a stale PL031 interrupt on the first
// arm after a warm reset (RTC-WARMINT, found on the real PL031 2026-11-16). A
// PRESETn-only reset in the few PCLK after an alarm, before the re-arm reached
// the PL031, left the alarm re-raised: RTCMR/RTCIMSC survive (they are on
// nPOR) and the match is still true, so after the reset the PL031 raised the
// interrupt again - a duplicate sample of the same second (regression RTC-13b).
// need_clr is set by PRESETn. The first arm after it always starts in S_IDLE,
// which decides there whether this arm clears (arm_clr): it does when the
// counter is enabled (rtc_enabled), because then an earlier alarm can still be
// matching. The FSM then writes RTCICR = 1 after the RTCMR write (so the old
// match is already replaced) and before RTCIMSC = 1, reusing the S_ICR_*
// states (arm_clr routes that detour to S_IMSC_SETUP, never to S_PULSE_TRIG).
// When rtc_enabled is low the PL031 counter has been stopped since a power-on
// reset - it restarts at 1 against a match of 0, or stays frozen short of any
// match the FSM armed - so nothing can be pending: that arm writes RTCCR = 1
// instead and skips the clear. An arm therefore runs at most one of the two
// extra writes (the enable or the clear), so the passthrough stall bound stays
// 13 PCLK. Under nanosoc nPOR is derived from HRESETn, so every reset is a
// power-on and FIX-4 never adds the clear there.
reg        need_clr;        // warm reset since the last arm from S_IDLE
reg        arm_clr;         // this arm writes RTCICR = 1 (S_ICR_* without a trigger)

// -----------------------------------------------------------------------------
// Missed-alarm watchdog (fixes F8-OFFSET0/1 and RTCLR-FWD)
// -----------------------------------------------------------------------------
// The PL031 raises a match only when its counter *changes to* RTCMR. If the
// armed target is ever at or behind the counter, no match ever comes and the
// FSM would wait in S_WAITING forever — autonomous sampling silently dead:
//   - alarm_offset = 0            -> target == now               (F8-OFFSET0)
//   - offset 1 and a CLK1HZ tick between the RTCDR read and the RTCMR write
//                                 -> target == new now           (F8-OFFSET1)
//   - firmware sets the RTC forward past the target (RTCLR), or writes RTCMR
//     in the past                                                (RTCLR-FWD)
//   - firmware sets the RTC backwards -> target far in the future (long stall)
// Two guards:
//   1. eff_offset clamps alarm_offset 0 to 1.
//   2. While waiting with polling enabled, count CLK1HZ ticks since the arm.
//      If armed_offset + 1 ticks pass with no RTCINTR the match was missed, so
//      service it exactly like an alarm (clear, sample, re-arm from now). The
//      extra tick of margin guarantees a genuine RTCINTR always wins the race.
//      The count freezes while polling is paused, so a pause/resume does not
//      shorten the period.
// Net guarantee: while polling is enabled a sample is taken at most
// armed_offset + 1 seconds after each arm, whatever happens to the RTC.
wire [31:0] eff_offset = (alarm_offset == 32'd0) ? 32'd1 : alarm_offset;
reg  [31:0] armed_offset;   // eff_offset captured at S_CALC
reg  [31:0] wd_ticks;       // CLK1HZ ticks seen in S_WAITING since the arm
wire        wd_expired = (wd_ticks > armed_offset);

// CLK1HZ is asynchronous to PCLK: 2-flop synchroniser + rising-edge detect.
reg  clk1hz_s1, clk1hz_s2, clk1hz_s3;
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) {clk1hz_s1, clk1hz_s2, clk1hz_s3} <= 3'b000;
    else          {clk1hz_s1, clk1hz_s2, clk1hz_s3} <= {CLK1HZ, clk1hz_s1, clk1hz_s2};
end
wire clk1hz_tick = clk1hz_s2 & ~clk1hz_s3;

// -----------------------------------------------------------------------------
// ctrl_intr_flag — registered mirror of RTCINTR for wrapper to read
// -----------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) ctrl_intr_flag <= 1'b0;
    else          ctrl_intr_flag <= RTCINTR;
end



// -----------------------------------------------------------------------------
// APB bus arbitration: external-master passthrough vs FSM (WAIT-STATE, no error)
// -----------------------------------------------------------------------------
// The bus is free for the external master whenever the FSM is parked in IDLE or
// WAITING *and* is not still driving the tail of its own transfer. Because the
// FSM's APB outputs are registered, the ACCESS phase of its last write appears
// on the bus one cycle after the FSM leaves the ACCESS state (i.e. during the
// first WAITING cycle). Gating on !fsm_psel keeps the bus "busy" for that one
// drain cycle so a passthrough can't clobber the FSM's write.
// S_IDLE only counts as free while the counter is still in reset (nRTCRST
// low as seen through nrtcrst_pclk; the FSM then stays in IDLE). Once nRTCRST is high the FSM always leaves
// IDLE on the next cycle and takes the bus for a whole arm cycle, so granting
// there let a passthrough SETUP be split from its ACCESS by ~12 cycles of FSM
// transfers — an APB violation at the PL031 port (bug PL031-APB).
wire bus_free   = (((state == S_IDLE) && !nrtcrst_pclk) || (state == S_WAITING)) && !fsm_psel;

// An external transfer that collides with an arm cycle is STALLED (PREADY held
// low) until the FSM parks — it is never failed with PSLVERR. The FSM is
// deterministic and always returns to WAITING/IDLE within a bounded number of
// cycles (a full re-arm is ~10 PCLK, then it parks and, while a passthrough is
// granted, defers leaving WAITING), so the stall is bounded and the access
// always completes. This removes the PSLVERR -> AHB-error -> Cortex-M0 HardFault
// hang vector: firmware can read/write the RTC region at any time without
// pausing autonomous polling first.
// A transfer whose SETUP has been granted keeps the bus for its ACCESS even if
// bus_free drops in between: that happens when the counter reset releases
// (nrtcrst_pclk rises) right after a SETUP granted in S_IDLE. The FSM only
// drives the bus two cycles after leaving S_IDLE, so the ACCESS never
// collides with it (the ~fsm_psel term keeps that true by construction).
// Before, the grant was lost: the PL031 saw a SETUP with no ACCESS, and ~13
// cycles later an ACCESS with no SETUP (bug RTC-RSTREL, found by the WRP-6
// soak, regression RTC/tb_rtc_closure.sv RTC-10b).
reg  pt_setup_done;   // declared before its first use (see below)
wire grant = PSEL & (bus_free | (pt_setup_done & ~fsm_psel));   // external owns the RTC bus this cycle
wire ext_sel = grant;

// Track whether the RTC has already been shown a SETUP cycle for the current
// external transfer. A colliding access is stalled into its ACCESS phase before
// the bus frees, so on the first granted cycle we force an RTC SETUP (PENABLE
// low) regardless of the external PENABLE, then drive ACCESS the next cycle —
// the RTC always sees a protocol-correct SETUP -> ACCESS.
wire ext_penable = PENABLE & pt_setup_done;         // RTC ACCESS only after SETUP
wire ext_done    = grant & pt_setup_done & PENABLE; // transfer completes this cycle

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)      pt_setup_done <= 1'b0;
    else if (ext_done) pt_setup_done <= 1'b0;   // completed — reset for next transfer
    else if (!PSEL)    pt_setup_done <= 1'b0;   // no transfer in flight
    else if (grant)    pt_setup_done <= 1'b1;   // first granted cycle = SETUP
end

// Never error — colliding accesses are stalled, not failed.
assign PSLVERR = 1'b0;
// Stall (PREADY low) while an external ACCESS is pending but not yet granted a
// clean SETUP+ACCESS on the RTC; complete (PREADY high) on the granted ACCESS.
assign PREADY  = (PSEL & PENABLE) ? ext_done : 1'b1;

// PRDATA — return RTC data during a granted passthrough, 0 otherwise
assign PRDATA  = ext_sel ? rtc_prdata : 32'h0;

// APB to RTC — mux external master vs FSM
assign rtc_psel    = ext_sel ? PSEL         : fsm_psel;
assign rtc_penable = ext_sel ? ext_penable  : fsm_penable;
assign rtc_pwrite  = ext_sel ? PWRITE       : fsm_pwrite;
assign rtc_paddr   = ext_sel ? PADDR[11:2]  : fsm_paddr;
assign rtc_pwdata  = ext_sel ? PWDATA       : fsm_pwdata;




// rtc_enabled (see "Internal state"): reset by nPOR only; set in the cycle the
// FSM's RTCCR = 1 ACCESS is on the PL031 bus.
always @(posedge PCLK or negedge nPOR) begin
    if (!nPOR)
        rtc_enabled <= 1'b0;
    else if (fsm_psel && fsm_penable && fsm_pwrite && (fsm_paddr == RTC_RTCCR))
        rtc_enabled <= 1'b1;
end

// -----------------------------------------------------------------------------
// Main FSM
// -----------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        state           <= S_IDLE;
        rtc_trig        <= 1'b0;
        need_clr        <= 1'b1;
        arm_clr         <= 1'b0;
        alarm_target    <= 32'h0;
        armed_offset    <= 32'd1;
        wd_ticks        <= 32'd0;
        ctrl_time_value <= 32'h0;
        fsm_psel        <= 1'b0;
        fsm_penable     <= 1'b0;
        fsm_pwrite      <= 1'b0;
        fsm_paddr       <= 10'h0;
        fsm_pwdata      <= 32'h0;
    end else begin

        // Default — deassert pulse signals each cycle
        rtc_trig    <= 1'b0;
        fsm_psel    <= 1'b0;
        fsm_penable <= 1'b0;
        fsm_pwrite  <= 1'b0;

        case (state)

            // ── IDLE ──────────────────────────────────────────────────────────
            // Auto-starts after reset. First time: enable counter.
            // Subsequent times: skip straight to reading time.
       
            S_IDLE: begin
                if (nrtcrst_pclk) begin
                    // Enable the counter only if the PL031 has had a power-on
                    // reset since the last enable (rtc_enabled low). After a
                    // warm reset RTCCR.start is still 1: it is on nPOR in the
                    // PL031, this FSM only ever writes 1, and the wrapper
                    // forwards firmware RTCCR writes with start forced to 1
                    // (FIX-3). Skipping the redundant enable keeps the
                    // warm-reset arm, which adds the RTCICR write (FIX-4),
                    // within the 13-PCLK stall bound.
                    arm_clr  <= need_clr && rtc_enabled;
                    need_clr <= 1'b0;
                    if (!rtc_enabled)
                        state <= S_ENABLE_SETUP;
                    else
                        state <= S_READ_SETUP;
                end
            end

            // ── Enable RTC counter — RTCCR = 1 ───────────────────────────────
            S_ENABLE_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b1;
                fsm_paddr   <= RTC_RTCCR;
                fsm_pwdata  <= 32'h1;
                state       <= S_ENABLE_ACCESS;
            end

            S_ENABLE_ACCESS: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b1;
                fsm_pwrite  <= 1'b1;      // must hold write
                fsm_paddr   <= RTC_RTCCR; // must hold address
                fsm_pwdata  <= 32'h1;     // must hold data
                state       <= S_READ_SETUP;   // rtc_enabled sets as this ACCESS reaches the bus
            end

            // ── Read current timestamp — RTCDR ────────────────────────────────
            S_READ_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b0;
                fsm_paddr   <= RTC_RTCDR;
                fsm_pwdata  <= 32'h0;
                state       <= S_READ_ACCESS;
            end

            // Drive the read ACCESS phase (PENABLE high). Registered outputs
            // mean this appears on the RTC bus during S_READ_CAPTURE, which is
            // where rtc_prdata is actually valid to sample.
            S_READ_ACCESS: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b1;
                fsm_paddr   <= RTC_RTCDR;   // hold address through ACCESS
                state       <= S_READ_CAPTURE;
            end

            // Bus is in the read ACCESS phase this cycle — latch the timestamp.
            S_READ_CAPTURE: begin
                ctrl_time_value <= rtc_prdata;
                state           <= S_CALC;
            end

            // ── Calculate alarm target (1 cycle) ──────────────────────────────
            // ctrl_time_value was latched in the previous cycle and is stable.
            S_CALC: begin
                alarm_target <= ctrl_time_value + eff_offset;
                armed_offset <= eff_offset;
                wd_ticks     <= 32'd0;
                state        <= S_MATCH_SETUP;
            end

            // ── Write match register — RTCMR ──────────────────────────────────
            S_MATCH_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b1;
                fsm_paddr   <= RTC_RTCMR;
                fsm_pwdata  <= alarm_target;
                state       <= S_MATCH_ACCESS;
            end

            S_MATCH_ACCESS: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b1;
                fsm_pwrite  <= 1'b1;          // hold write through ACCESS
                fsm_paddr   <= RTC_RTCMR;     // hold address
                fsm_pwdata  <= alarm_target;  // hold data
                if (arm_clr)                  // FIX-4: first arm after a warm reset
                    state <= S_ICR_SETUP;
                else
                    state <= S_IMSC_SETUP;
            end

            // ── Enable interrupt — RTCIMSC = 1 ───────────────────────────────
            S_IMSC_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b1;
                fsm_paddr   <= RTC_RTCIMSC;
                fsm_pwdata  <= 32'h1;
                state       <= S_IMSC_ACCESS;
            end

            S_IMSC_ACCESS: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b1;
                fsm_pwrite  <= 1'b1;          // hold write through ACCESS
                fsm_paddr   <= RTC_RTCIMSC;   // hold address
                fsm_pwdata  <= 32'h1;         // hold data
                state       <= S_WAITING;
            end

            // ── Wait for RTCINTR ──────────────────────────────────────────────
            // FSM parks here with the bus idle so the external master can
            // read/write RTC registers via passthrough. Defer servicing the
            // alarm by a cycle if an external transfer is in progress, so we
            // never tear down a passthrough access half-way.
            S_WAITING: begin
                // Only service the alarm when polling is enabled. When
                // poll_enable is low we park here indefinitely (counter still
                // runs, passthrough still granted); resume the moment it is
                // raised, servicing any alarm that fired while disabled.
                // Watchdog: count ticks only while polling (frozen when
                // paused); saturate so a huge offset never wraps to "expired".
                if (poll_enable && clk1hz_tick && (wd_ticks != 32'hFFFF_FFFF))
                    wd_ticks <= wd_ticks + 32'd1;
                // !PSEL (FIX-1): an access pending in the drain cycle (not yet
                // granted) goes first. Only differs from !ext_sel in that one
                // cycle; it matters because an offset re-arm can now end just
                // as an alarm becomes due, and the access would otherwise wait
                // through the re-arm, the service and another arm (22 PCLK).
                // RTC-NPOR: the PL031 had a power-on reset (counter stopped,
                // RTCMR/RTCIMSC cleared) while this FSM kept running. Once the
                // counter reset has released, go back through S_IDLE, which
                // writes RTCCR = 1 and re-arms from the restarted counter,
                // with no RTCICR write and no sample. This comes before alarm
                // service: a service followed by the enable arm would hold a
                // passthrough for longer than the 13-PCLK bound. The re-arm
                // resets the watchdog, so the next sample is still due within
                // armed_offset + 1 seconds. Also while paused.
                if (!rtc_enabled && nrtcrst_pclk && !PSEL)
                    state <= S_IDLE;
                else if ((RTCINTR || wd_expired) && !PSEL && poll_enable)
                    state <= S_ICR_SETUP;
                // FIX-1 (pending team confirmation): a changed alarm_offset
                // re-arms at once - re-read the time and arm now + new offset.
                // No RTCICR write and no rtc_trig on this path, so the re-arm
                // itself never produces a sample; alarm service (above) has
                // priority and re-arms with the new offset anyway. Also while
                // paused. Change-detect (not a write strobe): rewriting the
                // same value never re-arms, so it cannot starve sampling.
                // !PSEL, not just !ext_sel: an external access stalled through
                // the previous arm cycle is granted first (in the drain cycle
                // it is not yet granted), so it never waits two arm cycles.
                else if ((eff_offset != armed_offset) && !PSEL)
                    state <= S_READ_SETUP;
            end

            // ── Clear interrupt — RTCICR = 1 ─────────────────────────────────
            S_ICR_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b1;
                fsm_paddr   <= RTC_RTCICR;
                fsm_pwdata  <= 32'h1;
                state       <= S_ICR_ACCESS;
            end

            S_ICR_ACCESS: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b1;
                fsm_pwrite  <= 1'b1;          // hold write through ACCESS
                fsm_paddr   <= RTC_RTCICR;    // hold address
                fsm_pwdata  <= 32'h1;         // hold data
                if (arm_clr) begin             // FIX-4: arm-time clear done
                    arm_clr  <= 1'b0;
                    state    <= S_IMSC_SETUP;
                end else
                    state    <= S_PULSE_TRIG;
            end

            // ── Pulse rtc_trig — kicks wrapper_control_2 FSM ────────────────────
            S_PULSE_TRIG: begin
                rtc_trig <= 1'b1;
                state    <= S_IDLE;
            end

            default: state <= S_IDLE;

        endcase

    end
end

endmodule
