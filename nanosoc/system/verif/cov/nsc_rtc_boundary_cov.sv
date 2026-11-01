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
// !!! Every bin here is "needs re-run with real RTL" in coverage_plan.md.
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
    // What last made a match possible: 0 none, 1 FSM RTCMR write, 2 firmware
    // RTCMR/RTCLR write. Cleared by any RTCICR write.
    logic intr_q;  int unsigned intr_high;  logic [1:0] armed;
    wire fw_arm  = rtc_access && rtc_pwrite && ext_sel &&
                   (rtc_paddr == 10'h001 || rtc_paddr == 10'h002);
    wire icr_wr  = rtc_access && rtc_pwrite && (rtc_paddr == 10'h007);
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin intr_q <= 1'b0; intr_high <= 0; armed <= 2'd0; end
        else begin
            intr_q <= RTCINTR;
            intr_high <= RTCINTR ? intr_high + 1 : 0;
            if (match_written)  armed <= 2'd1;
            else if (fw_arm)    armed <= 2'd2;
            else if (icr_wr)    armed <= 2'd0;
        end
    end
    wire intr_rise = RTCINTR && !intr_q;
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
        x_word_dir_src : cross cp_word, cp_dir, cp_src {
            // rtc_control_2 itself only ever reads RTCDR and writes RTCCR,
            // RTCMR, RTCIMSC, RTCICR. Every other FSM-sourced combination is
            // structurally impossible, so it is excluded rather than left as a
            // permanent hole. (Firmware-sourced bins all stay.)
            ignore_bins fsm_rd_not_dr = binsof(cp_src.fsm) && binsof(cp_dir.read) &&
                binsof(cp_word) intersect {[10'h001:10'h3FF]};
            ignore_bins fsm_wr_dr     = binsof(cp_src.fsm) && binsof(cp_dir.write) && binsof(cp_word.rtcdr);
            ignore_bins fsm_wr_lr     = binsof(cp_src.fsm) && binsof(cp_dir.write) && binsof(cp_word.rtclr);
            ignore_bins fsm_wr_ris    = binsof(cp_src.fsm) && binsof(cp_dir.write) && binsof(cp_word.rtcris);
            ignore_bins fsm_wr_mis    = binsof(cp_src.fsm) && binsof(cp_dir.write) && binsof(cp_word.rtcmis);
            ignore_bins fsm_wr_beyond = binsof(cp_src.fsm) && binsof(cp_dir.write) && binsof(cp_word.beyond_icr);
        }
        cp_wdata_class : coverpoint rtc_pwdata iff (rtc_access && rtc_pwrite && ext_sel) {
            bins zero = {32'h0}; bins one = {32'h1}; bins all_ones = {32'hFFFF_FFFF};
            bins other = default;
        }
        cp_stall_len : coverpoint stall_len iff (stall_done) {
            bins one = {1}; bins two_to_4 = {[2:4]}; bins five_to_12 = {[5:12]};
            bins viol_long = {[13:$]};             // > a full arm cycle: should be impossible
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
            bins viol_unarmed   = {2'd0};  // interrupt with no match/load since last clear
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
