// -----------------------------------------------------------------------------
// rtc_cov.sv
//
// Functional-coverage model for rtc_control_2 (autonomous PL031 controller +
// firmware passthrough arbiter). Bound into every rtc_control_2 instance.
// NEEDS ARM IP to compile (rtc_control_2 instantiates the PL031 `Rtc`).
//
//   cp_state       : every FSM state visited
//   cp_arm         : first arm (IDLE->ENABLE) vs re-arm (IDLE->READ, counter
//                    already running), alarm serviced (WAITING->ICR), trigger
//                    pulse returning to IDLE
//   cp_offset      : alarm_offset values at the CALC step, incl. the 0 and
//                    wrap-around (0xFFFF_FFFF) edge cases
//   cp_pt_reg      : firmware passthrough access to each PL031 register,
//   cp_pt_dir        read and write  (x_pt_reg_dir crosses them)
//   cp_stall_state : FSM state when a passthrough access was STALLED (PREADY
//                    low) — HANDOFF decision #2: collisions wait, never error
//   cp_stall_len   : how many wait states a stalled access saw
//   cp_poll        : poll_enable paused / resumed; alarm fired while paused;
//                    resumed with an alarm already pending (service-on-resume)
//   cp_defer       : alarm pending while a passthrough owned the bus (FSM
//                    deferred servicing by a cycle)
//   cg_reset       : warm reset (PRESETn low, nPOR high — RTC counter must
//                    survive) vs power-on reset (nPOR low)
// -----------------------------------------------------------------------------
module rtc_cov (
    input logic        PCLK,
    input logic        PRESETn,
    input logic        nPOR,
    input logic [4:0]  state,
    input logic [31:0] alarm_offset,
    input logic        poll_enable,
    input logic        RTCINTR,
    input logic        rtc_trig,
    // external (firmware) passthrough side
    input logic        PSEL,
    input logic        PENABLE,
    input logic        PWRITE,
    input logic [11:0] PADDR,
    input logic        PREADY,
    input logic        PSLVERR,
    input logic        ext_sel
);
    localparam logic [4:0]
        S_IDLE          = 5'd0,
        S_ENABLE_SETUP  = 5'd1,
        S_ENABLE_ACCESS = 5'd2,
        S_READ_SETUP    = 5'd3,
        S_READ_ACCESS   = 5'd4,
        S_CALC          = 5'd5,
        S_MATCH_SETUP   = 5'd6,
        S_MATCH_ACCESS  = 5'd7,
        S_IMSC_SETUP    = 5'd8,
        S_IMSC_ACCESS   = 5'd9,
        S_WAITING       = 5'd10,
        S_ICR_SETUP     = 5'd11,
        S_ICR_ACCESS    = 5'd12,
        S_PULSE_TRIG    = 5'd13,
        S_READ_CAPTURE  = 5'd14;

    // ── Derived signals ──────────────────────────────────────────────────────
    wire pt_access   = PSEL && PENABLE;           // external ACCESS phase
    wire pt_stalled  = pt_access && !PREADY;      // wait state inserted
    wire pt_complete = pt_access &&  PREADY;      // transfer completes

    // Length of the current stall, sampled when the access completes.
    int unsigned stall_cnt;
    int unsigned stall_len;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)        stall_cnt <= 0;
        else if (pt_stalled) stall_cnt <= stall_cnt + 1;
        else if (pt_complete) stall_cnt <= 0;
    end

    // {previous, current} state history for transition bins (Verilator 5.052
    // transition bins only accept literal numbers, not named constants).
    logic [4:0] st_q;
    logic       hist_valid;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin st_q <= S_IDLE; hist_valid <= 1'b0; end
        else          begin st_q <= state;  hist_valid <= 1'b1; end
    end

    covergroup cg_rtc;
        option.per_instance = 1;

        cp_state : coverpoint state {
            bins idle          = {S_IDLE};
            bins enable_setup  = {S_ENABLE_SETUP};
            bins enable_access = {S_ENABLE_ACCESS};
            bins read_setup    = {S_READ_SETUP};
            bins read_access   = {S_READ_ACCESS};
            bins read_capture  = {S_READ_CAPTURE};
            bins calc          = {S_CALC};
            bins match_setup   = {S_MATCH_SETUP};
            bins match_access  = {S_MATCH_ACCESS};
            bins imsc_setup    = {S_IMSC_SETUP};
            bins imsc_access   = {S_IMSC_ACCESS};
            bins waiting       = {S_WAITING};
            bins icr_setup     = {S_ICR_SETUP};
            bins icr_access    = {S_ICR_ACCESS};
            bins pulse_trig    = {S_PULSE_TRIG};
        }

        cp_arm : coverpoint {st_q, state} iff (hist_valid) {
            bins first_arm     = {{S_IDLE,       S_ENABLE_SETUP}};
            bins re_arm        = {{S_IDLE,       S_READ_SETUP}};
            bins alarm_service = {{S_WAITING,    S_ICR_SETUP}};
            bins trig_to_idle  = {{S_PULSE_TRIG, S_IDLE}};
        }

        cp_offset : coverpoint alarm_offset iff (state == S_CALC) {
            bins zero  = {0};
            bins one   = {1};
            bins short = {[2:10]};
            bins mid   = {[11:3600]};
            bins long  = {[3601:32'hFFFF_FFFE]};
            bins wrap  = {32'hFFFF_FFFF};
        }

        cp_pt_reg : coverpoint PADDR[4:2] iff (pt_complete) {
            bins rtcdr   = {3'd0};
            bins rtcmr   = {3'd1};
            bins rtclr   = {3'd2};
            bins rtccr   = {3'd3};
            bins rtcimsc = {3'd4};
            bins rtcris  = {3'd5};
            bins rtcmis  = {3'd6};
            bins rtcicr  = {3'd7};
        }
        cp_pt_dir : coverpoint PWRITE iff (pt_complete) {
            bins read  = {1'b0};
            bins write = {1'b1};
        }
        x_pt_reg_dir : cross cp_pt_reg, cp_pt_dir;

        cp_stall_state : coverpoint state iff (pt_stalled) {
            bins during_enable = {S_ENABLE_SETUP, S_ENABLE_ACCESS};
            bins during_read   = {S_READ_SETUP, S_READ_ACCESS, S_READ_CAPTURE};
            bins during_calc   = {S_CALC};
            bins during_match  = {S_MATCH_SETUP, S_MATCH_ACCESS};
            bins during_imsc   = {S_IMSC_SETUP, S_IMSC_ACCESS};
            bins during_drain  = {S_WAITING};        // FSM's last write draining
            bins during_clear  = {S_ICR_SETUP, S_ICR_ACCESS, S_PULSE_TRIG};
        }

        cp_stall_len : coverpoint stall_len iff (pt_complete) {
            bins none   = {0};
            bins one    = {1};
            bins few    = {[2:5]};
            bins many   = {[6:15]};
            bins excess = {[16:$]};   // > a full re-arm: worth a look if hit
        }

        // Must NEVER be hit (HANDOFF decision #2). Counted, not illegal, so a
        // violation still leaves a coverage.dat to inspect.
        cp_pslverr : coverpoint PSLVERR iff (pt_complete) {
            bins error_seen = {1'b1};
        }

        cp_poll : coverpoint poll_enable {
            bins pause  = (1'b1 => 1'b0);
            bins resume = (1'b0 => 1'b1);
        }
        cp_alarm_while_paused : coverpoint (RTCINTR && !poll_enable && state == S_WAITING) {
            bins seen = {1'b1};
        }
        cp_resume_pending : coverpoint (poll_enable && RTCINTR && state == S_WAITING) {
            bins service_pending = (1'b0 => 1'b1);
        }

        cp_defer : coverpoint (state == S_WAITING && RTCINTR && ext_sel) {
            bins deferred = {1'b1};
        }

        cp_trig : coverpoint rtc_trig {
            bins pulse = {1'b1};
        }
    endgroup

    // Reset coverage is sampled regardless of PRESETn (that is the point).
    covergroup cg_reset;
        option.per_instance = 1;
        cp_reset : coverpoint {nPOR, PRESETn} {
            bins power_on = {2'b00, 2'b01};
            bins warm     = {2'b10};
            bins running  = {2'b11};
        }
        cp_reset_edge : coverpoint {nPOR, PRESETn} {
            bins warm_reset_entry = (2'b11 => 2'b10);
            bins warm_reset_exit  = (2'b10 => 2'b11);
            bins por_entry        = (2'b11 => 2'b00);
        }
    endgroup

    cg_rtc   cg   = new;
    cg_reset cg_r = new;

    always @(posedge PCLK) begin
        stall_len = stall_cnt;
        cg_r.sample();
        if (PRESETn) cg.sample();
    end

endmodule

bind rtc_control_2 rtc_cov u_rtc_cov (
    .PCLK        (PCLK),
    .PRESETn     (PRESETn),
    .nPOR        (nPOR),
    .state       (state),
    .alarm_offset(alarm_offset),
    .poll_enable (poll_enable),
    .RTCINTR     (RTCINTR),
    .rtc_trig    (rtc_trig),
    .PSEL        (PSEL),
    .PENABLE     (PENABLE),
    .PWRITE      (PWRITE),
    .PADDR       (PADDR),
    .PREADY      (PREADY),
    .PSLVERR     (PSLVERR),
    .ext_sel     (ext_sel)
);
