`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_rtc_boundary_cov.sv — coverage AT THE PL031 (`Rtc`) BOUNDARY ONLY.
//
// Bound into rtc_control_2 (see nsc_bind_sensing.sv). Observes only the ports
// of the u_rtc instance and the controller around it — never the inside of the
// PL031 — so the same model works with the real ARM RTL and with
// agriculture_soc_main/verif/stubs/pl031_stub.v.
//
// !!! Anything hit with the stub only shows the surrounding logic was exercised.
// !!! Every bin here needs a re-run with the real PL031.
//
//   cg_rtc_bus   APB accesses at the Rtc port: word (DR..ICR + out-of-range)
//                x direction x source (autonomous FSM vs firmware passthrough);
//                passthrough stall length; PSLVERR never (viol)
//   cg_rtc_irq   RTCINTR rise/fall, high while polling paused, rise during a
//                passthrough, high-time, rise without an armed match (viol)
//   cg_rtc_clk   CLK1HZ ticks seen; tick inside the RDATA-read -> RTCMR-write
//                window (the alarm_offset=1 race, F8) x offset class; offset 0
//                armed (dead alarm, F8)
//   cg_rtc_rst   nRTCRST release; accesses while nRTCRST is low; PRESETn reset
//                with nRTCRST high (counter must survive) vs both
// -----------------------------------------------------------------------------
module nsc_rtc_boundary_cov (
    input logic        PCLK,
    input logic        PRESETn,
    input logic        nPOR,
    input logic        CLK1HZ,
    input logic        nRTCRST,
    // Rtc instance port
    input logic        rtc_psel,
    input logic        rtc_penable,
    input logic        rtc_pwrite,
    input logic [9:0]  rtc_paddr,
    input logic [31:0] rtc_pwdata,
    input logic        RTCINTR,
    // controller context
    input logic        ext_sel,          // passthrough owns the Rtc bus
    input logic [4:0]  state,
    input logic [31:0] alarm_offset,
    input logic        poll_enable,
    // external passthrough port (firmware side)
    input logic        PSEL,
    input logic        PENABLE,
    input logic        PREADY,
    input logic        PSLVERR
);
    localparam logic [4:0] S_IDLE = 5'd0, S_READ_SETUP = 5'd3, S_READ_CAPTURE = 5'd14,
                           S_CALC = 5'd5, S_MATCH_SETUP = 5'd6, S_MATCH_ACCESS = 5'd7,
                           S_WAITING = 5'd10;

    wire rtc_access = rtc_psel && rtc_penable;    // PL031 has no PREADY: 1-cycle ACCESS

    // ---------------- CLK1HZ edge in PCLK domain (observer only) -----------
    logic [2:0] c1_sync;
    always @(posedge PCLK) c1_sync <= {c1_sync[1:0], CLK1HZ};
    wire tick = c1_sync[1] && !c1_sync[2];
    int unsigned ticks;
    always @(posedge PCLK or negedge nPOR)
        if (!nPOR) ticks <= 0; else if (tick && ticks < 1000) ticks <= ticks + 1;

    // arm window: from the RTCDR read set-up to the RTCMR write access
    logic in_arm_window, tick_in_window;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin in_arm_window <= 1'b0; tick_in_window <= 1'b0; end
        else begin
            if (state == S_READ_SETUP) begin in_arm_window <= 1'b1; tick_in_window <= 1'b0; end
            else if (state == S_WAITING) in_arm_window <= 1'b0;
            if (in_arm_window && tick) tick_in_window <= 1'b1;
        end
    end
    wire match_written = rtc_access && rtc_pwrite && (rtc_paddr == 10'h001) && !ext_sel;

    // ---------------- passthrough stall length ------------------------------
    int unsigned stall_len;
    logic        stalled_q;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin stall_len <= 0; stalled_q <= 1'b0; end
        else begin
            stalled_q <= PSEL && PENABLE && !PREADY;
            if (PSEL && PENABLE && !PREADY) stall_len <= stall_len + 1;
            else if (PSEL && PENABLE && PREADY) stall_len <= 0;
        end
    end
    wire stall_done = PSEL && PENABLE && PREADY && stalled_q;

    // ---------------- RTCINTR -----------------------------------------------
    // What made this RTCINTR rise possible, since the previous rise: 0 none,
    // 1 FSM RTCMR write, 2 firmware RTCMR/RTCLR write, 3 an RTCIMSC write
    // unmasking a raw interrupt that was already pending. Consumed by the rise.
    // (2026-11-15: an RTCICR write no longer clears it. Clearing the interrupt
    // does not clear RTCMR, so the armed match still fires later; the WRP-6
    // soak hit viol_unarmed on exactly that legal sequence.)
    logic intr_q;  int unsigned intr_high;  logic [1:0] armed;
    wire  intr_rise = RTCINTR && !intr_q;
    wire fw_arm  = rtc_access && rtc_pwrite && ext_sel &&
                   (rtc_paddr == 10'h001 || rtc_paddr == 10'h002);
    wire imsc_wr = rtc_access && rtc_pwrite && (rtc_paddr == 10'h004) && rtc_pwdata[0];
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin intr_q <= 1'b0; intr_high <= 0; armed <= 2'd0; end
        else begin
            intr_q <= RTCINTR;
            intr_high <= RTCINTR ? intr_high + 1 : 0;
            if (match_written)              armed <= 2'd1;
            else if (fw_arm)                armed <= 2'd2;
            else if (imsc_wr && armed == 0) armed <= 2'd3;
            else if (intr_rise)             armed <= 2'd0;
        end
    end
    wire intr_fall = !RTCINTR && intr_q;

    // passthrough-port protocol of whoever drives it (see nsc_sens_apb_cov, F20)
    logic pacc_q, pdone_q;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin pacc_q <= 1'b0; pdone_q <= 1'b0; end
        else begin pacc_q <= PSEL && PENABLE && !PREADY; pdone_q <= PSEL && PENABLE && PREADY; end
    end
    wire p_abandoned  = pacc_q  && !(PSEL && PENABLE);
    wire p_held_after = pdone_q &&  (PSEL && PENABLE);

    covergroup cg_rtc_bus;
        option.per_instance = 1;
        cp_word : coverpoint rtc_paddr iff (rtc_access) {
            bins rtcdr = {10'h000}; bins rtcmr = {10'h001}; bins rtclr = {10'h002};
            bins rtccr = {10'h003}; bins rtcimsc = {10'h004}; bins rtcris = {10'h005};
            bins rtcmis = {10'h006}; bins rtcicr = {10'h007};
            bins beyond_icr = {[10'h008:10'h3FF]};   // unreachable via wrapper decode
        }
        cp_dir : coverpoint rtc_pwrite iff (rtc_access) { bins read = {0}; bins write = {1}; }
        cp_src : coverpoint ext_sel iff (rtc_access) { bins fsm = {0}; bins firmware = {1}; }
        // {source, direction, word}: only the combinations that can legally
        // occur are goals (binsof() cannot be relied
        // on in Verilator 5.052). rtc_control_2 itself only reads RTCDR and
        // writes RTCCR / RTCMR / RTCIMSC / RTCICR (RTC_RTC* localparams, states
        // S_ENABLE_*, S_READ_*, S_MATCH_*, S_IMSC_*, S_ICR_*): any other
        // FSM-sourced access is a viol_ bin. Value = {ext_sel, pwrite, word[9:0]}.
        x_word_dir_src : coverpoint {ext_sel, rtc_pwrite, rtc_paddr} iff (rtc_access) {
            bins fw_rd_rtcdr   = {12'h800}; bins fw_rd_rtcmr   = {12'h801};
            bins fw_rd_rtclr   = {12'h802}; bins fw_rd_rtccr   = {12'h803};
            bins fw_rd_rtcimsc = {12'h804}; bins fw_rd_rtcris  = {12'h805};
            bins fw_rd_rtcmis  = {12'h806}; bins fw_rd_rtcicr  = {12'h807};
            bins fw_wr_rtcdr   = {12'hC00}; bins fw_wr_rtcmr   = {12'hC01};
            bins fw_wr_rtclr   = {12'hC02}; bins fw_wr_rtccr   = {12'hC03};
            bins fw_wr_rtcimsc = {12'hC04}; bins fw_wr_rtcris  = {12'hC05};
            bins fw_wr_rtcmis  = {12'hC06}; bins fw_wr_rtcicr  = {12'hC07};
            // words above RTCICR: reachable at the rtc_control_2 port (RTC block
            // bench) only - the wrapper's rtc_region forwards words 0-7.
            bins fw_rd_beyond_icr = {[12'h808:12'hBFF]};
            bins fw_wr_beyond_icr = {[12'hC08:12'hFFF]};
            bins fsm_rd_rtcdr   = {12'h000};
            bins fsm_wr_rtcmr   = {12'h401};
            bins fsm_wr_rtccr   = {12'h403};
            bins fsm_wr_rtcimsc = {12'h404};
            bins fsm_wr_rtcicr  = {12'h407};
            bins viol_fsm_read_not_rtcdr = {[12'h001:12'h3FF]};
            bins viol_fsm_write_other    = {12'h400, 12'h402, 12'h405, 12'h406, [12'h408:12'h7FF]};
        }
        cp_wdata_class : coverpoint rtc_pwdata iff (rtc_access && rtc_pwrite && ext_sel) {
            bins zero = {32'h0}; bins one = {32'h1}; bins all_ones = {32'hFFFF_FFFF};
            bins other = default;
        }
        cp_stall_len : coverpoint stall_len iff (stall_done) {
            // Worst case since the PL031-APB fix (no grant in S_IDLE once the
            // counter is out of reset): an access whose SETUP coincides with
            // S_ICR_SETUP waits through ICR_ACCESS, PULSE_TRIG, IDLE, the 8
            // arm states, the drain cycle and its own forced SETUP = 13 PCLK.
            bins one = {1}; bins two_to_4 = {[2:4]}; bins five_to_13 = {[5:13]};
            bins viol_long = {[14:$]};             // > service + full re-arm: impossible
        }
        cp_pslverr : coverpoint PSLVERR iff (PSEL && PENABLE && PREADY) {
            bins okay = {1'b0}; bins viol_pslverr = {1'b1};
        }
        cp_pt_protocol : coverpoint {p_abandoned, p_held_after} {
            bins legal = {2'b00};
            bins viol_access_abandoned_while_stalled = {2'b10, 2'b11};
            bins viol_access_held_after_completion   = {2'b01};
        }
    endgroup

    covergroup cg_rtc_irq;
        option.per_instance = 1;
        cp_edge : coverpoint {intr_rise, intr_fall} {
            bins rise = {2'b10}; bins fall = {2'b01};
        }
        cp_rise_ctx : coverpoint {poll_enable, ext_sel} iff (intr_rise) {
            bins polling          = {2'b10};
            bins paused           = {2'b00, 2'b01};
            bins during_passthru  = {2'b11};
        }
        cp_rise_source : coverpoint armed iff (intr_rise) {
            bins fsm_alarm      = {2'd1};
            bins firmware_match = {2'd2};  // firmware wrote RTCMR/RTCLR via passthrough
            bins unmask         = {2'd3};  // RTCIMSC write with the raw interrupt already set
            bins viol_unarmed   = {2'd0};  // interrupt with no RTCMR/RTCLR/RTCIMSC write since the previous one
        }
        cp_high_time : coverpoint intr_high iff (intr_fall || (RTCINTR && intr_high == 5000)) {
            bins short_lt8   = {[1:7]};
            bins mid_8_4999  = {[8:4999]};
            bins held_5000   = {[5000:$]};         // e.g. paused with alarm pending
        }
    endgroup

    covergroup cg_rtc_clk;
        option.per_instance = 1;
        cp_ticks : coverpoint ticks {
            bins none = {0}; bins first = {1}; bins few = {[2:9]}; bins many = {[10:$]};
        }
        cp_offset_at_arm : coverpoint alarm_offset iff (match_written) {
            bins zero_dead = {0};                  // F8: target == now -> never fires
            bins one_racy  = {1};                  // F8: racy if a tick lands in window
            bins two_to_9  = {[2:9]};
            bins ten_plus  = {[10:32'hFFFF_FFFE]};
            bins wrap      = {32'hFFFF_FFFF};
        }
        cp_tick_in_window : coverpoint tick_in_window iff (match_written) {
            bins clean = {1'b0};
            bins tick_raced = {1'b1};
        }
        x_offset_tick : cross cp_offset_at_arm, cp_tick_in_window;
        cp_tick_vs_access : coverpoint {tick, rtc_access, ext_sel} {
            bins tick_with_fw_access  = {3'b111};
            bins tick_with_fsm_access = {3'b110};
        }
    endgroup

    covergroup cg_rtc_rst;
        option.per_instance = 1;
        cp_nrtcrst_release : coverpoint nRTCRST { bins released = {1'b1}; bins held = {1'b0}; }
        cp_access_in_rtc_reset : coverpoint ext_sel iff (rtc_access && !nRTCRST) {
            bins firmware_access_counter_in_reset = {1'b1};
        }
        cp_presetn_kind : coverpoint {PRESETn, nRTCRST} {
            bins apb_reset_rtc_alive = {2'b01};    // decision #3: time survives
            bins both_reset          = {2'b00};
            bins rtc_reset_only      = {2'b10};    // nPOR without PRESETn
        }
    endgroup

    cg_rtc_bus cg_bus = new;
    cg_rtc_irq cg_irq = new;
    cg_rtc_clk cg_clk = new;
    cg_rtc_rst cg_rst = new;
    always @(posedge PCLK) begin
        cg_rst.sample();
        if (PRESETn) begin cg_bus.sample(); cg_irq.sample(); cg_clk.sample(); end
    end
endmodule
