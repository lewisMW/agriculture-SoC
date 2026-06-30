`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// rtc_control.v
//
// Self-contained RTC controller. Owns the PL031 instance and all reset logic.
//
// Internally generates nRTCRST via 2-flop sync on CLK1HZ per ARM spec:
//   - asserted asynchronously when PRESETn deasserts
//   - deasserted synchronously to CLK1HZ (2 cycles after PRESETn reasserts)
//
// nPOR must come from outside — it survives APB resets so cannot be
// generated internally.
//
// Scan pins are tied off — not used outside scan insertion flow.
//
// FSM sequence (auto-starts after reset):
//   IDLE -> ENABLE_RTC -> READ_TIME -> CALC_ALARM -> SET_MATCH ->
//   ENABLE_INT -> WAITING -> CLEAR_INT -> PULSE_TRIG -> IDLE
//
// Passthrough: while in WAITING the internal APB bus is idle so the
// external master can read RTC registers directly (e.g. firmware reading
// the current timestamp).
// -----------------------------------------------------------------------------

module rtc_control #(
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
// nRTCRST generation — 2-flop synchroniser per ARM PL031 spec s4.11
// Assert asynchronously with PRESETn, deassert synchronously to CLK1HZ
// -----------------------------------------------------------------------------
reg nRTCRST_ff1, nRTCRST_ff2;

always @(posedge CLK1HZ or negedge PRESETn) begin
    if (!PRESETn) begin
        nRTCRST_ff1 <= 1'b0;
        nRTCRST_ff2 <= 1'b0;
    end else begin
        nRTCRST_ff1 <= 1'b1;
        nRTCRST_ff2 <= nRTCRST_ff1;
    end
end

wire nRTCRST = nRTCRST_ff2;

// This detectes 1 CLK HZ edge
reg clk1hz_sync0, clk1hz_sync1, clk1hz_sync2;

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        clk1hz_sync0 <= 1'b0;
        clk1hz_sync1 <= 1'b0;
        clk1hz_sync2 <= 1'b0;
    end else begin
        clk1hz_sync0 <= CLK1HZ;
        clk1hz_sync1 <= clk1hz_sync0;
        clk1hz_sync2 <= clk1hz_sync1;
    end
end

wire clk1hz_rise = clk1hz_sync1 & ~clk1hz_sync2;


// -----------------------------------------------------------------------------
// Passthrough signals — from external master, used during WAITING only
// -----------------------------------------------------------------------------
// These ports exist so firmware can read RTCDR etc while FSM is waiting.
// Wire them in at the top level by connecting PSEL/PENABLE etc from the
// wrapper into rtc_control. For now declared as inputs below the RTC ports.
// If passthrough is not needed, tie them to 0.

// Declared as localparams here — replace with ports if passthrough needed
// For now the FSM owns the bus exclusively and passthrough is left as a
// future wiring task at wrapper level.

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
    S_READ_ACCESS   = 5'd4,   // APB ACCESS — read  RTCDR, latch value
    S_CALC          = 5'd5,   // 1 cycle:  alarm_target = time + offset
    S_MATCH_SETUP   = 5'd6,   // APB SETUP  — write RTCMR
    S_MATCH_ACCESS  = 5'd7,   // APB ACCESS — write RTCMR
    S_IMSC_SETUP    = 5'd8,   // APB SETUP  — write RTCIMSC=1
    S_IMSC_ACCESS   = 5'd9,   // APB ACCESS — write RTCIMSC=1
    S_WAITING       = 5'd10,  // idle — wait for RTCINTR
    S_ICR_SETUP     = 5'd11,  // APB SETUP  — write RTCICR=1
    S_ICR_ACCESS    = 5'd12,  // APB ACCESS — write RTCICR=1
    S_PULSE_TRIG    = 5'd13,  // pulse rtc_trig for 1 cycle then back to IDLE
    S_TICK_SETUP    = 5'd14,   // APB SETUP  — periodic read RTCDR while waiting
    S_TICK_ACCESS   = 5'd15,   // APB ACCESS — periodic read RTCDR, latch value
    S_TICK_CAPTURE  = 5'd16;

// -----------------------------------------------------------------------------
// Internal state
// -----------------------------------------------------------------------------
reg [4:0]  state;
reg [31:0] alarm_target;
reg        rtc_enabled;     // set after first RTCCR write, never cleared

// -----------------------------------------------------------------------------
// ctrl_intr_flag — registered mirror of RTCINTR for wrapper to read
// -----------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) ctrl_intr_flag <= 1'b0;
    else          ctrl_intr_flag <= RTCINTR;
end



// APB Bus passthrough
// External access attempted
wire ext_access = PSEL & PENABLE;

// Bus is free when FSM is idle or waiting
wire bus_free = (state == S_IDLE) || (state == S_WAITING);

// Passthrough only when bus is free
wire passthrough = ext_access & bus_free;

// Error when external master tries during FSM activity
assign PSLVERR = ext_access & ~bus_free;
assign PREADY  = 1'b1;   // always complete immediately, never stall

// PRDATA — return RTC data on passthrough, 0 otherwise
assign PRDATA  = passthrough ? rtc_prdata : 32'h0;

// APB to RTC — mux FSM vs passthrough
assign rtc_psel    = passthrough ? PSEL    : fsm_psel;
assign rtc_penable = passthrough ? PENABLE : fsm_penable;
assign rtc_pwrite  = passthrough ? PWRITE  : fsm_pwrite;
assign rtc_paddr   = passthrough ? PADDR[11:2] : fsm_paddr;
assign rtc_pwdata  = passthrough ? PWDATA  : fsm_pwdata;




// -----------------------------------------------------------------------------
// Main FSM
// -----------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        state           <= S_IDLE;
        rtc_trig        <= 1'b0;
        rtc_enabled     <= 1'b0;
        alarm_target    <= 32'h0;
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
                if (nRTCRST) begin
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
                rtc_enabled <= 1'b1;
                state       <= S_READ_SETUP;
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

            S_READ_ACCESS: begin
                fsm_psel        <= 1'b1;
                fsm_penable     <= 1'b1;
                ctrl_time_value <= rtc_prdata;   // latch timestamp
                state           <= S_CALC;
            end

            // ── Calculate alarm target (1 cycle) ──────────────────────────────
            // ctrl_time_value is now stable from previous cycle
            S_CALC: begin
                alarm_target <= ctrl_time_value + alarm_offset;
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
                state       <= S_IMSC_SETUP;
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
                state       <= S_WAITING;
            end

            // ── Wait for RTCINTR ──────────────────────────────────────────────
            // FSM holds bus idle here. Passthrough can be added by muxing
            // external PSEL/PENABLE into rtc_psel/rtc_penable at this state.
            // S_WAITING: begin
            //     fsm_pwrite <= 1'b0;
            //     if (RTCINTR && !passthrough)
            //         state <= S_ICR_SETUP;

            // end
            // Now once every 1hz cycle we go and do a passthrough.
            S_WAITING: begin
                fsm_pwrite <= 1'b0;
                if (RTCINTR && !passthrough)
                    state <= S_ICR_SETUP;
                else if (clk1hz_rise && !ext_access)
                    state <= S_TICK_SETUP;
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
                state       <= S_PULSE_TRIG;
            end

            // ── Pulse rtc_trig — kicks wrapper_control FSM ────────────────────
            S_PULSE_TRIG: begin
                rtc_trig <= 1'b1;
                state    <= S_IDLE;
            end
            S_TICK_SETUP: begin
                fsm_psel    <= 1'b1;
                fsm_penable <= 1'b0;
                fsm_pwrite  <= 1'b0;
                fsm_paddr   <= RTC_RTCDR;
                fsm_pwdata  <= 32'h0;
                state       <= S_TICK_ACCESS;
            end

            S_TICK_ACCESS: begin
                fsm_psel        <= 1'b1;
                fsm_penable     <= 1'b1;
                // ctrl_time_value <= rtc_prdata;   // refresh latched timestamp
                state           <= S_TICK_CAPTURE;
            end

            S_TICK_CAPTURE: begin
                fsm_psel        <= 1'b1;        // keep bus held steady while sampling
                fsm_penable     <= 1'b1;
                ctrl_time_value <= rtc_prdata;  // now valid
                state           <= S_WAITING;
            end

            default: state <= S_IDLE;

        endcase
    end
end

endmodule