`timescale 1ns/1ps
// =============================================================================
// tb_rtc_closure.sv - rtc_control_2 closure tests RTC-1 .. RTC-12.
//
// Timing unit: a "tick" is one CLK1HZ rising edge. CLK1HZ is generated here
// from PCLK (toggled on the PCLK falling edge, half period c1_half PCLK) so a
// test can move its phase to any PCLK, stop it, or change the ratio.
//
// Guarantee under test (monitor below, active while `gchk` is set): while
// polling is enabled, consecutive rtc_trig pulses are at most
// (armed_offset + 1) ticks plus one arm cycle apart, whatever firmware does to
// the PL031. With `gmin` set, they are also never closer than one tick minus
// an arm cycle (exactly one trigger per period, never two).
//
// Only rtc_control_2 internals are referenced (state, alarm_target,
// armed_offset, wd_ticks, RTCINTR, the PL031-side bus), never the PL031's own,
// so the bench runs unchanged against the real ARM PL031 and the
// stand-in (STUB_RTC=1). Every stand-in result must be re-run with the real
// PL031 before it counts; RTC-10 especially.
//
// Run: make -C RTC clo [STUB_RTC=1]   (bound SVA, --assert)
// Ends with "=== RTC-CLO: N PASSED, M FAILED ===".
// =============================================================================
module tb_rtc_closure;

    localparam int TPCLK = 10;

    localparam logic [4:0]
        S_IDLE = 5'd0, S_ENABLE_SETUP = 5'd1, S_ENABLE_ACCESS = 5'd2, S_READ_SETUP = 5'd3,
        S_READ_ACCESS = 5'd4, S_CALC = 5'd5, S_MATCH_SETUP = 5'd6, S_MATCH_ACCESS = 5'd7,
        S_IMSC_SETUP = 5'd8, S_IMSC_ACCESS = 5'd9, S_WAITING = 5'd10, S_ICR_SETUP = 5'd11,
        S_ICR_ACCESS = 5'd12, S_PULSE_TRIG = 5'd13, S_READ_CAPTURE = 5'd14;

    localparam logic [11:0] A_DR = 12'h000, A_MR = 12'h004, A_LR = 12'h008, A_CR = 12'h00C,
                            A_IMSC = 12'h010, A_RIS = 12'h014, A_MIS = 12'h018, A_ICR = 12'h01C;

    // ------------------------------------------------------------------ DUT
    logic        PCLK = 1'b0, PRESETn = 1'b0, CLK1HZ = 1'b0, nPOR = 1'b0;
    logic [31:0] alarm_offset = 32'd1;
    logic        poll_enable = 1'b1;
    wire  [31:0] ctrl_time_value;
    wire         ctrl_intr_flag, rtc_trig;
    logic        PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
    logic [11:0] PADDR = 12'h0;
    logic [31:0] PWDATA = 32'h0;
    wire  [31:0] PRDATA;
    wire         PREADY, PSLVERR;

    rtc_control_2 #(.DATA_WIDTH(32), .ADDR_WIDTH(12)) dut (
        .PCLK(PCLK), .PRESETn(PRESETn), .CLK1HZ(CLK1HZ), .nPOR(nPOR),
        .alarm_offset(alarm_offset), .poll_enable(poll_enable),
        .ctrl_time_value(ctrl_time_value), .ctrl_intr_flag(ctrl_intr_flag), .rtc_trig(rtc_trig),
        .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE), .PADDR(PADDR), .PWDATA(PWDATA),
        .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR));

    always #(TPCLK / 2) PCLK = ~PCLK;

    // ---------------------------------------------------------- bookkeeping
    int pass_count = 0, fail_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) pass_count++;
        else begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction
    function automatic void note(input string s);
        $display("NOTE [%0t] %s", $time, s);
    endfunction

    // ------------------------------------------------------------- CLK1HZ
    int unsigned c1_half = 50;      // PCLK per half period (period = 2*c1_half)
    int unsigned c1_cnt  = 0;
    bit          c1_run  = 1'b1;
    int unsigned c1_force_rise = 0; // >0: rise exactly this many PCLK from now
    always @(negedge PCLK) begin
        if (c1_force_rise != 0) begin
            c1_force_rise <= c1_force_rise - 1;
            if (c1_force_rise == 1) begin CLK1HZ <= 1'b1; c1_cnt <= 0; end
            else                          CLK1HZ <= 1'b0;
        end else if (c1_run) begin
            if (c1_cnt + 1 >= c1_half) begin CLK1HZ <= ~CLK1HZ; c1_cnt <= 0; end
            else c1_cnt <= c1_cnt + 1;
        end
    end
    function automatic int unsigned period(); return 2 * c1_half; endfunction

    // ------------------------------------------------------------ counters
    longint unsigned cyc = 0;
    always @(posedge PCLK) cyc <= cyc + 1;

    int unsigned trig_count = 0, tick_count = 0;
    always @(posedge PCLK) if (rtc_trig) trig_count <= trig_count + 1;
    always @(posedge CLK1HZ) tick_count <= tick_count + 1;

    // ------------------------------------------- guarantee monitor (RTC-1..)
    // In ticks (always, while gchk): consecutive triggers are at least one
    // tick apart (with gmin: never two per period) and at most
    // armed_offset + 2 ticks apart (armed_offset + 1, plus the tick that can
    // fall inside the arm cycle). In PCLK (only while g_pclk: the CLK1HZ
    // period is regular): at most (armed_offset + 1) periods + 20 PCLK (one
    // arm cycle plus the CLK1HZ synchroniser).
    bit             gchk = 1'b0, gmin = 1'b0, g_pclk = 1'b1, g_quiet = 1'b0;
    longint signed  g_last = -1;              // cycle of the last rtc_trig
    int unsigned    g_last_tick = 0;
    int unsigned    g_arm_off = 1;            // armed_offset of the arm after it
    int unsigned    g_bad_max = 0, g_bad_min = 0, g_gaps = 0;
    longint signed  g_gap_max = 0;
    bit             last_svc_intr = 1'b0;     // service cause of the last sample
    always @(posedge PCLK) begin
        if (dut.state == S_MATCH_SETUP) g_arm_off <= dut.armed_offset;
        if (dut.state == S_ICR_SETUP && dut.fsm_psel == 1'b0) last_svc_intr <= dut.RTCINTR;
        if (!gchk || !PRESETn || !poll_enable) g_last <= -1;
        else if (rtc_trig) begin
            if (g_last >= 0) begin
                // (static always block: declare, then assign - an initialiser
                // here would run only once, at time 0)
                longint signed gap, lim;
                int unsigned   tgap;
                string         tag;
                gap  = longint'(cyc) - g_last;
                lim  = (longint'(g_arm_off) + 1) * period() + 20;
                tgap = tick_count - g_last_tick;
                tag  = g_quiet ? "NOTE" : "FAIL";
                g_gaps++;
                if (gap > g_gap_max) g_gap_max = gap;
                if (tgap > g_arm_off + 2 || (g_pclk && gap > lim)) begin
                    g_bad_max++;
                    $display("%s [%0t] guarantee: rtc_trig gap %0d PCLK / %0d ticks > (armed_offset %0d + 1) ticks + arm cycle",
                             tag, $time, gap, tgap, g_arm_off);
                end
                if (gmin && tgap < 1) begin
                    g_bad_min++;
                    $display("%s [%0t] guarantee: two rtc_trig in one tick (%0d PCLK apart)", tag, $time, gap);
                end
            end
            g_last <= longint'(cyc);
            g_last_tick <= tick_count;
        end
    end
    task automatic g_reset(); g_last = -1; endtask

    // --------------------------------------------- PL031 port monitor (RTC-9)
    // SETUP is always followed by ACCESS with the same address, direction and
    // write data; count external writes landing on the PL031 per address.
    logic        p_sel_q = 0, p_en_q = 0, p_wr_q = 0;
    logic [9:0]  p_addr_q = 0;
    logic [31:0] p_wd_q = 0;
    int unsigned n_port_bad = 0, n_ext_wr_land = 0, n_port_acc = 0;
    always @(posedge PCLK) begin
        if (PRESETn) begin
            if (dut.rtc_penable) begin
                n_port_acc++;
                if (!(p_sel_q && !p_en_q && dut.rtc_psel && p_addr_q == dut.rtc_paddr &&
                      p_wr_q == dut.rtc_pwrite && (!dut.rtc_pwrite || p_wd_q == dut.rtc_pwdata))) begin
                    n_port_bad++;
                    $display("FAIL [%0t] PL031 port: ACCESS not preceded by a matching SETUP", $time);
                end
                if (dut.ext_sel && dut.rtc_pwrite) n_ext_wr_land++;
            end
            if (dut.rtc_psel && !dut.rtc_penable && p_sel_q && !p_en_q) begin
                n_port_bad++;
                $display("FAIL [%0t] PL031 port: SETUP not followed by ACCESS", $time);
            end
        end
        p_sel_q <= dut.rtc_psel; p_en_q <= dut.rtc_penable; p_wr_q <= dut.rtc_pwrite;
        p_addr_q <= dut.rtc_paddr; p_wd_q <= dut.rtc_pwdata;
    end

    int unsigned n_pslverr = 0;
    always @(posedge PCLK) if (PRESETn && PSEL && PENABLE && PREADY && PSLVERR) n_pslverr++;

    // ----------------------------------------------------------- APB master
    // Every bench action happens 1 ns after a PCLK rising edge. A transfer
    // drives SETUP at once, ACCESS on the next edge, and holds ACCESS until
    // PREADY is seen at a rising edge (sampled in the low half before it).
    // Calling apb_xfer again straight away gives a back-to-back transfer.
    bit          apb_abort = 1'b0;
    int unsigned last_stall = 0, max_stall = 0;
    task automatic apb_xfer(input bit wr, input logic [11:0] a, input logic [31:0] d,
                            output logic [31:0] rd);
        int unsigned st = 0;
        rd = 32'h0;
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE = wr; PADDR = a; PWDATA = d;
        @(posedge PCLK); #1;
        if (apb_abort) begin PSEL = 0; PENABLE = 0; PWRITE = 0; return; end
        PENABLE = 1'b1;
        forever begin
            @(negedge PCLK);
            if (apb_abort) break;
            if (PREADY) begin rd = PRDATA; break; end
            st++;
            if (st > 2000) begin check(1'b0, "APB transfer completes (stall > 2000 PCLK)"); break; end
        end
        @(posedge PCLK); #1;
        PSEL = 1'b0; PENABLE = 1'b0; PWRITE = 1'b0;
        last_stall = st;
        if (st > max_stall) max_stall = st;
    endtask
    task automatic apb_rd(input logic [11:0] a, output logic [31:0] rd);
        apb_xfer(1'b0, a, 32'h0, rd);
    endtask
    task automatic apb_wr(input logic [11:0] a, input logic [31:0] d);
        logic [31:0] unused;
        apb_xfer(1'b1, a, d, unused);
    endtask

    // ------------------------------------------------------------- helpers
    task automatic clk(input int n); repeat (n) @(posedge PCLK); #1; endtask

    task automatic wait_state(input logic [4:0] s, input int max_cyc, output bit ok);
        int i = 0;
        ok = 1'b0;
        while (i < max_cyc) begin
            if (dut.state == s) begin ok = 1'b1; return; end
            clk(1); i++;
        end
    endtask

    // wait for the next rtc_trig (observed at posedge+1: the pulse cycle)
    task automatic wait_trig(input int max_cyc, output bit ok, output int took);
        took = 0; ok = 1'b0;
        while (took < max_cyc) begin
            clk(1); took++;
            if (rtc_trig) begin ok = 1'b1; return; end
        end
    endtask

    // FSM parked waiting for the alarm (re-arm finished, bus drained)
    task automatic wait_armed(output bit ok);
        int i = 0;
        ok = 1'b0;
        while (i < 200) begin
            if (dut.state == S_WAITING && !dut.fsm_psel) begin ok = 1'b1; return; end
            clk(1); i++;
        end
    endtask

    task automatic set_offset_and_settle(input logic [31:0] off);
        bit ok; int t;
        longint unsigned lim;
        alarm_offset = off;
        // let the current (already armed) period finish so the new offset is armed
        lim = (longint'(dut.armed_offset) + 3) * period() + 400;
        wait_trig((lim > 64'd100_000_000) ? 100_000_000 : int'(lim), ok, t);
        wait_armed(ok);
        g_reset();
    endtask

    task automatic por_reset();
        apb_abort = 1'b1; PSEL = 0; PENABLE = 0;
        PRESETn = 1'b0; nPOR = 1'b0;
        clk(5); nPOR = 1'b1; clk(2); PRESETn = 1'b1;
        apb_abort = 1'b0;
        clk(5);
    endtask

    // Count rtc_trig pulses over n PCLK.
    task automatic count_trigs(input int n, output int unsigned cnt);
        int unsigned t0 = trig_count;
        clk(n);
        cnt = trig_count - t0;
    endtask

    // -------------------------------------------------------------- RTC-1
    // 50 periods per offset; after each trigger CLK1HZ is re-phased so its
    // next rising edge lands j PCLK later, j sweeping 1..16 - i.e. the tick
    // (2-3 PCLK of synchroniser later) walks across the whole arm window
    // S_READ_SETUP .. S_IMSC_ACCESS of the re-arm that follows the trigger.
    task automatic rtc1();
        int unsigned offs [4] = '{1, 2, 3, 5};
        bit ok; int took;
        $display("--- RTC-1 one trigger per period, CLK1HZ phase swept over the arm window ---");
        foreach (offs[k]) begin
            int unsigned bad0 = g_bad_max + g_bad_min, n0 = trig_count;
            set_offset_and_settle(offs[k]);
            gchk = 1'b1; gmin = 1'b1; g_pclk = 1'b0; g_reset();
            for (int p = 0; p < 50; p++) begin
                wait_trig((offs[k] + 2) * period() + 100, ok, took);
                if (!ok) begin check(1'b0, $sformatf("RTC-1 offset %0d: trigger %0d arrives", offs[k], p)); break; end
                // first falling edge after the trigger drives CLK1HZ low, the
                // rise follows j-1 edges later: synchronised tick at T + j + 1,
                // j = 2..17 covers S_READ_SETUP (T+2) .. S_IMSC_ACCESS (T+11) and beyond
                c1_force_rise = 2 + (p % 16);
            end
            gchk = 1'b0; gmin = 1'b0; g_pclk = 1'b1;
            check(trig_count - n0 >= 50, $sformatf("RTC-1 offset %0d: 50 periods sampled", offs[k]));
            check(g_bad_max + g_bad_min == bad0,
                  $sformatf("RTC-1 offset %0d: every gap within the guarantee, never two per period", offs[k]));
        end
    endtask

    // -------------------------------------------------------------- RTC-2
    task automatic rtc2();
        logic [31:0] now, mr;
        bit ok; int took;
        logic [31:0] targets [3];
        string       nm [3] = '{"past", "now", "far future"};
        $display("--- RTC-2 firmware writes RTCMR while waiting ---");
        set_offset_and_settle(3);
        gchk = 1'b1; gmin = 1'b0;
        for (int i = 0; i < 3; i++) begin
            int unsigned bad0 = g_bad_max;
            wait_armed(ok);
            clk(period() / 2);
            apb_rd(A_DR, now);
            targets[0] = now - 5; targets[1] = now; targets[2] = now + 1000;
            apb_wr(A_MR, targets[i]);
            apb_rd(A_MR, mr);
            check(mr == targets[i], {"RTC-2 RTCMR write (", nm[i], ") reads back"});
            wait_trig((3 + 2) * period() + 100, ok, took);
            check(ok, {"RTC-2 RTCMR ", nm[i], ": next rtc_trig within the guarantee"});
            // re-arm from the current time
            wait_armed(ok);
            apb_rd(A_DR, now);
            check(dut.alarm_target == dut.ctrl_time_value + 32'd3 &&
                  (now == dut.ctrl_time_value || now == dut.ctrl_time_value + 1),
                  $sformatf("RTC-2 RTCMR %s: re-armed from the current time (target %0d, captured %0d, now %0d)",
                            nm[i], dut.alarm_target, dut.ctrl_time_value, now));
            apb_rd(A_MR, mr);
            check(mr == dut.alarm_target, {"RTC-2 RTCMR ", nm[i], ": PL031 match register holds the new target"});
            wait_trig((3 + 2) * period() + 100, ok, took);
            check(ok && g_bad_max == bad0, {"RTC-2 RTCMR ", nm[i], ": sampling continues within the guarantee"});
        end
        gchk = 1'b0;
    endtask

    // -------------------------------------------------------------- RTC-3
    task automatic rtc3();
        bit ok; int took;
        logic [31:0] r;
        int unsigned bad0, wd_before;
        $display("--- RTC-3 RTCIMSC = 0 and RTCICR = 1 before the FSM services ---");
        set_offset_and_settle(2);
        gchk = 1'b1; gmin = 1'b0; bad0 = g_bad_max;
        // (a) mask the interrupt: only the watchdog can service
        for (int i = 0; i < 3; i++) begin
            wait_armed(ok);
            apb_wr(A_IMSC, 32'h0);
            apb_rd(A_IMSC, r);
            check(r[0] == 1'b0, "RTC-3a RTCIMSC reads 0 after firmware masks it");
            wait_trig((2 + 2) * period() + 100, ok, took);
            check(ok && dut.wd_ticks == 3, $sformatf("RTC-3a masked: sampled by the watchdog after offset + 1 ticks (wd_ticks %0d)", dut.wd_ticks));
            wait_armed(ok);
            apb_rd(A_IMSC, r);
            check(r[0] == 1'b1, "RTC-3a the re-arm unmasks RTCIMSC again");
        end
        // (b) firmware clears the match between the PL031 raising it and the
        // FSM servicing it: a back-to-back read stream holds the bus across
        // the match, its last transfer is the RTCICR write.
        // Real PL031 (measured at its ports, 2026-11-16): RTCINTR
        // rises as soon as the count equals the match; an RTCICR written in
        // the first 3 PCLK after that rise does not keep it low, and an
        // RTCICR write only takes effect the cycle AFTER its ACCESS. So when the
        // RTCICR is the last transfer of the burst (i < 3) RTCINTR is still high
        // in the first bus-free cycle and the FSM services the alarm on time
        // (the stand-in used to clear in the ACCESS cycle and lose it). Only
        // firmware that keeps the bus one more transfer after an RTCICR issued
        // more than 3 PCLK after the rise (i >= 3) really steals the interrupt; the
        // watchdog then samples. Either way exactly one sample follows.
        for (int i = 0; i < 6; i++) begin
            int guard = 0;
            bit stolen;
            wait_armed(ok);
            while (!dut.RTCINTR && guard < 4 * period()) begin
                apb_rd(A_DR, r);            // back to back: no idle cycle
                guard++;
            end
            if (i >= 3) begin apb_rd(A_DR, r); apb_rd(A_DR, r); end   // RTCICR more than 3 PCLK after the rise
            apb_wr(A_ICR, 32'h1);           // still back to back
            if (i >= 3) apb_rd(A_DR, r);    // hold the bus while the clear takes effect
            stolen = (dut.RTCINTR == 1'b0);
            check(dut.state == S_WAITING,
                  $sformatf("RTC-3b FSM still waiting after the firmware RTCICR (state %0d)", dut.state));
            if (i >= 3)
                check(stolen, "RTC-3b RTCICR more than 3 PCLK after the rise, bus held one more transfer: interrupt cleared before the FSM services it");
            wait_trig((2 + 2) * period() + 100, ok, took);
            if (stolen)
                check(ok && dut.wd_ticks == 3,
                      $sformatf("RTC-3b stolen interrupt: the watchdog samples after offset + 1 ticks (wd_ticks %0d)", dut.wd_ticks));
            else
                check(ok && took <= 20,
                      $sformatf("RTC-3b RTCICR too early to clear the match: the FSM services it on time (after %0d PCLK)", took));
        end
        check(g_bad_max == bad0, "RTC-3 every gap within the guarantee");
        gchk = 1'b0;
    endtask

    // -------------------------------------------------------------- RTC-4
    task automatic rtc4();
        bit ok; int took;
        logic [31:0] now, r;
        int unsigned bad0;
        logic [31:0] delta [3] = '{32'd1, 32'd100, 32'h8000_0000};
        $display("--- RTC-4 RTCLR backwards / forwards / wrap ---");
        set_offset_and_settle(2);
        gchk = 1'b1; gmin = 1'b0; bad0 = g_bad_max;
        foreach (delta[i]) begin
            logic [31:0] loaded;
            wait_armed(ok);
            apb_rd(A_DR, now);
            loaded = now - delta[i];
            apb_wr(A_LR, loaded);
            wait_trig((2 + 2) * period() + 100, ok, took);
            check(ok, $sformatf("RTC-4 RTCLR back by %0d: next sample within the guarantee", delta[i]));
            wait_armed(ok);
            check(dut.alarm_target == dut.ctrl_time_value + 32'd2 && dut.ctrl_time_value - loaded <= 32'd8,
                  $sformatf("RTC-4 RTCLR back by %0d: re-armed from the loaded time (loaded %h, captured %h)",
                            delta[i], loaded, dut.ctrl_time_value));
        end
        // forward past the armed target
        wait_armed(ok);
        apb_wr(A_LR, dut.alarm_target + 32'd10);
        wait_trig((2 + 2) * period() + 100, ok, took);
        check(ok, "RTC-4 RTCLR forward past the target: next sample within the guarantee (watchdog)");
        // wrap: the counter one below a match at 0xFFFFFFFE, so the next
        // re-arm reads 0xFFFFFFFE (or ...FF) and its target wraps through 0
        wait_armed(ok);
        apb_wr(A_MR, 32'hFFFF_FFFE);
        apb_wr(A_LR, 32'hFFFF_FFFD);
        wait_trig((2 + 2) * period() + 100, ok, took);
        check(ok, "RTC-4 RTCLR 0xFFFFFFFD + RTCMR 0xFFFFFFFE: next sample within the guarantee");
        wait_armed(ok);
        check(dut.alarm_target == dut.ctrl_time_value + 32'd2 && dut.ctrl_time_value >= 32'hFFFF_FFFE &&
              dut.alarm_target <= 32'd1,
              $sformatf("RTC-4 wrap: target = time + 2 modulo 2^32 (time %h, target %h)", dut.ctrl_time_value, dut.alarm_target));
        for (int i = 0; i < 3; i++) begin
            wait_trig((2 + 2) * period() + 100, ok, took);
            check(ok && (i > 0 || last_svc_intr),
                  $sformatf("RTC-4 wrap: sample %0d across the 2^32 wrap%s", i, i == 0 ? " is a real match at the wrapped target" : ""));
        end
        wait_armed(ok);
        apb_rd(A_DR, now);
        check(now < 32'd16, $sformatf("RTC-4 wrap: counter wrapped through 0 (now %0d)", now));
        check(g_bad_max == bad0, "RTC-4 every gap within the guarantee");
        gchk = 1'b0;
    endtask

    // -------------------------------------------------------------- RTC-5
    // Pause for k ticks at: (a) before the match, (b) after the match (alarm
    // pending), (c) right after the watchdog ran out.
    task automatic pause_case(input int where, input int k, input int unsigned off);
        bit ok; int took;
        int unsigned t0, wd0;
        bit pending;
        logic [31:0] target;
        string nm;
        nm = (where == 0) ? "before the match" : (where == 1) ? "after the match" : "after watchdog expiry";
        wait_armed(ok);
        target = dut.alarm_target;
        if (where == 2) apb_wr(A_IMSC, 32'h0);        // no RTCINTR: the watchdog will run out
        if (where == 0) clk(2);
        if (where == 1) begin
            int g = 0;
            // hold the bus so the match cannot be serviced, then pause
            while (!dut.RTCINTR && g < 3 * off * period()) begin logic [31:0] r; apb_rd(A_DR, r); g++; end
        end
        if (where == 2) begin
            int g = 0;
            while (!(dut.wd_ticks > dut.armed_offset) && g < 4 * off * period()) begin
                clk(1); g++;
            end
            // we are in the cycle where wd_expired just became true: pause now,
            // before the next edge services it
        end
        poll_enable = 1'b0;
        t0 = trig_count; wd0 = dut.wd_ticks;
        clk(k * period() + 7);
        check(trig_count == t0, $sformatf("RTC-5 pause %0d ticks %s (offset %0d): no rtc_trig while paused", k, nm, off));
        check(dut.wd_ticks == wd0, $sformatf("RTC-5 pause %0d ticks %s: wd_ticks frozen", k, nm));
        pending = dut.RTCINTR || (dut.wd_ticks > dut.armed_offset);
        if (where >= 1)
            check(pending, $sformatf("RTC-5 pause %s: an alarm is pending at resume", nm));
        poll_enable = 1'b1;
        if (pending) begin
            int unsigned n0 = trig_count;
            wait_trig(12, ok, took);
            check(ok, $sformatf("RTC-5 pause %0d ticks %s: one immediate sample on resume (%0d PCLK)", k, nm, took));
            // exactly one: the next one only after a full re-arm period
            clk(period() / 2);
            check(trig_count == n0 + 1, $sformatf("RTC-5 pause %0d ticks %s: exactly one sample on resume", k, nm));
        end else begin
            logic [31:0] now;
            apb_rd(A_DR, now);
            check(dut.alarm_target == target, $sformatf("RTC-5 pause %0d ticks %s: original target kept", k, nm));
            wait_trig((target - now + 2) * period() + 100, ok, took);
            check(ok, $sformatf("RTC-5 pause %0d ticks %s: the original deadline holds", k, nm));
        end
        if (where == 2) begin wait_armed(ok); end
    endtask

    task automatic rtc5();
        int unsigned off = 3;
        int ks [3];
        $display("--- RTC-5 pause / resume ---");
        set_offset_and_settle(off);
        ks[0] = 1; ks[1] = off; ks[2] = 3 * off;
        for (int w = 0; w < 3; w++)
            foreach (ks[i]) pause_case(w, ks[i], off);
        // pause shorter than the remaining time keeps the deadline: k = 1 at
        // offset 3 right after the arm is the "otherwise" case above.
    endtask

    // -------------------------------------------------------------- RTC-6
    task automatic rtc6();
        logic [4:0] sts [4] = '{S_WAITING, S_ICR_SETUP, S_ICR_ACCESS, S_PULSE_TRIG};
        string      nms [4] = '{"S_WAITING", "S_ICR_SETUP", "S_ICR_ACCESS", "S_PULSE_TRIG"};
        bit ok;
        $display("--- RTC-6 poll_enable dropped during the alarm service ---");
        set_offset_and_settle(1);
        foreach (sts[i]) begin
            int unsigned early, late;
            wait_state(sts[i], 4 * period(), ok);
            if (sts[i] == S_WAITING) begin wait_armed(ok); end
            check(ok, {"RTC-6 reached ", nms[i]});
            poll_enable = 1'b0;
            early = 0; late = 0;
            // rtc_trig as seen in each of the 3 cycles after the disable, then later
            for (int c = 0; c < 3; c++) begin clk(1); if (rtc_trig) early++; end
            for (int c = 0; c < 4 * period(); c++) begin clk(1); if (rtc_trig) late++; end
            note($sformatf("RTC-6 disable in %s: %0d rtc_trig within 3 PCLK, %0d after", nms[i], early, late));
            check(early <= 1, {"RTC-6 disable in ", nms[i], ": at most one rtc_trig within 3 PCLK"});
            check(late == 0,  {"RTC-6 disable in ", nms[i], ": no rtc_trig after that"});
            poll_enable = 1'b1;
            wait_trig(4 * period(), ok, early);
            check(ok, {"RTC-6 disable in ", nms[i], ": sampling resumes on re-enable"});
        end
    endtask

    // -------------------------------------------------------------- RTC-7
    // A new alarm_offset applies from the next arm (before FIX-1 an armed
    // long period was not shortened). For 0xFFFFFFFF -> 3, the only way out is a
    // passthrough RTCMR write close to now.
    // FIX-1 (pending team confirmation): a changed alarm_offset re-arms at
    // once - now + new offset - without producing a sample itself.
    int unsigned n_rearm = 0;            // S_WAITING -> S_READ_SETUP transitions
    logic [4:0]  st_q = 5'd0;
    always @(posedge PCLK) begin
        st_q <= dut.state;
        if (PRESETn && st_q == S_WAITING && dut.state == S_READ_SETUP) n_rearm++;
    end

    // wait until the controller is parked with the current offset armed
    task automatic wait_rearmed(input int max_cyc, output bit ok, output int took);
        took = 0; ok = 1'b0;
        while (took < max_cyc) begin
            if (dut.state == S_WAITING && !dut.fsm_psel && dut.armed_offset == ((alarm_offset == 0) ? 1 : alarm_offset)) begin
                ok = 1'b1; return;
            end
            clk(1); took++;
        end
    endtask

    task automatic offset_change(input logic [31:0] from, input logic [31:0] to);
        bit ok; int took;
        int unsigned eff_to = (to == 0) ? 1 : to;
        int unsigned eff_from = (from == 0) ? 1 : from;
        int unsigned t0, r0;
        set_offset_and_settle(from);
        wait_armed(ok);
        check(dut.armed_offset == eff_from, $sformatf("RTC-7 %0d -> %0d: armed with the old offset", from, to));
        clk(5);
        t0 = trig_count; r0 = n_rearm;
        alarm_offset = to;                        // while waiting
        wait_rearmed(30, ok, took);
        check(ok, $sformatf("RTC-7/FIX-1 %0d -> %0d: re-armed with the new offset within %0d PCLK", from, to, took));
        check(trig_count == t0 && n_rearm == r0 + 1, $sformatf("RTC-7/FIX-1 %0d -> %0d: exactly one re-arm, no sample from it", from, to));
        check(dut.alarm_target - dut.ctrl_time_value == eff_to, $sformatf("RTC-7/FIX-1 %0d -> %0d: target = now + new offset", from, to));
        gchk = 1'b1; gmin = 1'b1; g_reset();
        begin
            int unsigned pt0 = trig_count;
            wait_trig((eff_to + 1) * period() + 40, ok, took);
            check(ok, $sformatf("RTC-7/FIX-1 %0d -> %0d: first sample within new offset + 1 ticks of the write (%0d PCLK)", from, to, took));
        end
        for (int i = 0; i < 3; i++) begin
            wait_trig((eff_to + 2) * period() + 100, ok, took);
            check(ok && took >= (eff_to - 1) * period() && took <= (eff_to + 1) * period() + 20,
                  $sformatf("RTC-7 %0d -> %0d: period %0d is the new offset (%0d PCLK)", from, to, i, took));
        end
        gchk = 1'b0; gmin = 1'b0;
    endtask

    task automatic rtc7();
        bit ok; int took;
        logic [31:0] now;
        $display("--- RTC-7 alarm_offset changed while waiting (FIX-1: re-arms at once) ---");
        offset_change(32'hFFFF_FFFF, 3);
        offset_change(5, 2);
        offset_change(2, 5);
        offset_change(5, 0);
        offset_change(0, 5);
        // the RTCMR workaround (shorten an armed long period) still works
        set_offset_and_settle(32'hFFFF_FFFF);
        wait_armed(ok);
        apb_rd(A_DR, now);
        apb_wr(A_MR, now + 32'd2);
        wait_trig(4 * period() + 100, ok, took);
        check(ok, "RTC-7 RTCMR = RTCDR + 2 through the passthrough still fires an armed long period");
        // offset written mid-arm: the arm in progress used the old one, the
        // re-arm in S_WAITING picks up the new one
        set_offset_and_settle(2);
        wait_state(S_MATCH_SETUP, 4 * period(), ok);
        alarm_offset = 3;
        wait_rearmed(40, ok, took);
        check(ok, "RTC-7/FIX-1 offset written mid-arm (after S_CALC) is armed as soon as the FSM parks");
        // offset written while paused: re-arms while paused
        poll_enable = 1'b0; clk(5); alarm_offset = 1;
        wait_rearmed(40, ok, took);
        check(ok && !poll_enable, "RTC-7/FIX-1 offset written while paused re-arms while paused");
        poll_enable = 1'b1;
        set_offset_and_settle(1);
    endtask

    // FIX-1 cases beyond RTC-7
    task automatic fix1();
        bit ok; int took;
        int unsigned t0, r0, bad;
        logic [31:0] r;
        $display("--- FIX-1 offset change at every PCLK of an arm cycle / alarm service, paused, stalled, rewrites ---");
        // every PCLK from S_ICR_SETUP through the following arm cycle
        bad = 0;
        set_offset_and_settle(2);
        for (int d = 0; d <= 16; d++) begin
            logic [31:0] nv;
            wait_state(S_ICR_SETUP, 4 * period(), ok);
            if (d > 0) clk(d);
            nv = (alarm_offset == 2) ? 3 : 2;
            t0 = trig_count;
            alarm_offset = nv;
            wait_rearmed(40, ok, took);
            if (!ok) bad++;
            if (trig_count - t0 > 1) bad++;            // only the service already running may sample
        end
        check(bad == 0, "FIX-1 offset changed at every PCLK of an alarm service + re-arm: new offset armed, no extra sample");
        // paused, alarm pending: re-arm keeps the interrupt pending; resume gives one sample, then the new period
        set_offset_and_settle(2);
        wait_armed(ok);
        poll_enable = 1'b0;
        begin int g = 0; while (!dut.RTCINTR && g < 6 * period()) begin clk(1); g++; end end
        alarm_offset = 3;
        wait_rearmed(40, ok, took);
        check(ok && dut.RTCINTR, "FIX-1 paused with an alarm pending: re-armed, interrupt still pending");
        t0 = trig_count;
        poll_enable = 1'b1;
        wait_trig(12, ok, took);
        check(ok, "FIX-1 resume with an alarm pending: one immediate sample");
        clk(period() / 2);
        check(trig_count == t0 + 1, "FIX-1 resume: at most one immediate sample");
        wait_rearmed(40, ok, took);
        check(ok && dut.armed_offset == 3, "FIX-1 after the resume sample the new period is armed");
        // paused, no alarm pending
        wait_armed(ok); poll_enable = 1'b0; clk(3);
        alarm_offset = 2;
        wait_rearmed(40, ok, took);
        check(ok && !dut.RTCINTR, "FIX-1 paused without an alarm pending: re-armed with the new offset");
        poll_enable = 1'b1;
        // change during a stalled passthrough: the re-arm waits for the transfer
        set_offset_and_settle(2);
        wait_state(S_ICR_SETUP, 4 * period(), ok);
        fork
            begin apb_rd(A_DR, r); end
            begin clk(4); alarm_offset = 4; end
        join
        wait_rearmed(60, ok, took);
        check(ok && last_stall <= 13, "FIX-1 offset changed during a stalled passthrough: transfer completes, new offset armed");
        // change during a back-to-back burst granted in WAITING: deferred until it ends
        set_offset_and_settle(2);
        wait_armed(ok);
        r0 = n_rearm;
        for (int i = 0; i < 8; i++) begin
            if (i == 2) alarm_offset = 3;
            apb_rd(A_DR, r);
            if (i < 7) check(dut.state == S_WAITING, "FIX-1 re-arm deferred while the passthrough burst holds the bus");
        end
        wait_rearmed(40, ok, took);
        check(ok && n_rearm == r0 + 1, "FIX-1 re-arm runs once the burst ends");
        // the same value rewritten 100 times: no re-arm, period unchanged
        set_offset_and_settle(2);
        wait_armed(ok);
        r0 = n_rearm;
        for (int i = 0; i < 100; i++) begin alarm_offset = 2; clk(3); end
        check(n_rearm == r0, "FIX-1 rewriting the same offset 100 times never re-arms");
        // 50 periods after a change, exactly one sample per period
        alarm_offset = 3;
        wait_rearmed(40, ok, took);
        begin
            int unsigned b0 = g_bad_max + g_bad_min, n0 = trig_count;
            gchk = 1'b1; gmin = 1'b1; g_reset();
            for (int p = 0; p < 50; p++) begin wait_trig(5 * period(), ok, took); if (!ok) break; end
            clk(1);
            gchk = 1'b0; gmin = 1'b0;
            check(trig_count - n0 >= 50 && g_bad_max + g_bad_min == b0, "FIX-1 50 periods after a change: one sample per period, within the guarantee");
        end
        set_offset_and_settle(1);
    endtask

    // -------------------------------------------------------------- RTC-8
    task automatic rtc8();
        bit ok; int took;
        logic [31:0] r, prev_dr;
        int unsigned bad_dr = 0, bad_mr = 0, defer = 0;
        longint unsigned t_idle;
        $display("--- RTC-8 200 back-to-back passthrough reads across a pending alarm ---");
        set_offset_and_settle(1);
        wait_armed(ok);
        prev_dr = 0;
        for (int i = 0; i < 200; i++) begin
            logic [31:0] tgt = dut.alarm_target;
            if (i % 2 == 0) begin
                apb_rd(A_DR, r);
                if (i > 0 && r < prev_dr) bad_dr++;
                prev_dr = r;
            end else begin
                apb_rd(A_MR, r);
                if (r != tgt) bad_mr++;
            end
            if (dut.RTCINTR && dut.state == S_WAITING) defer++;
        end
        t_idle = cyc;                     // first idle cycle starts now
        check(defer > 0, $sformatf("RTC-8 the alarm became due during the stream (%0d transfers deferred it)", defer));
        check(bad_dr == 0, "RTC-8 RTCDR reads never go backwards during the stream");
        check(bad_mr == 0, "RTC-8 RTCMR reads return the armed target on every transfer");
        wait_state(S_ICR_SETUP, 20, ok);
        check(ok && cyc - t_idle <= 6, $sformatf("RTC-8 alarm serviced within 6 PCLK of the first idle cycle (%0d)", cyc - t_idle));
        note("RTC-8 property: while PSEL never drops between transfers the alarm service is deferred without bound; it runs within 6 PCLK of the first idle cycle");
        wait_trig(20, ok, took);
        check(ok, "RTC-8 deferred alarm produces its sample");
    endtask

    // -------------------------------------------------------------- RTC-9
    task automatic rtc9();
        bit ok;
        logic [11:0] regs [8] = '{A_DR, A_MR, A_LR, A_CR, A_IMSC, A_RIS, A_MIS, A_ICR};
        int unsigned bad0 = n_port_bad, stall_max = 0, wr_bad = 0, n = 0;
        logic [31:0] r, last_dr;
        $display("--- RTC-9 passthrough SETUP at every PCLK of the service + re-arm ---");
        set_offset_and_settle(1);
        apb_rd(A_DR, last_dr);
        for (int d = 0; d <= 14; d++)
            foreach (regs[ri])
                for (int wr = 0; wr < 2; wr++) begin
                    logic [31:0] data;
                    int unsigned land0;
                    wait_state(S_ICR_SETUP, 4 * period(), ok);
                    if (!ok) begin check(1'b0, "RTC-9 alarm service reached"); return; end
                    if (d > 0) clk(d);
                    case (regs[ri])
                        A_MR:    data = dut.alarm_target + 32'd1;   // the FSM's own re-arm overwrites it, or the watchdog covers
                        A_LR:    data = last_dr;
                        A_CR:    data = 32'h1;
                        A_IMSC:  data = 32'h1;
                        A_ICR:   data = 32'h0;
                        default: data = 32'h0;
                    endcase
                    land0 = n_ext_wr_land;
                    apb_xfer(wr[0], regs[ri], data, r);
                    n++;
                    if (last_stall > stall_max) stall_max = last_stall;
                    if (wr && n_ext_wr_land - land0 != 1) wr_bad++;
                    if (!wr && regs[ri] == A_DR) last_dr = r;
                end
        check(n_port_bad == bad0, $sformatf("RTC-9 PL031 port: SETUP then ACCESS, same address/direction/data, on all %0d transfers", n));
        check(stall_max <= 13, $sformatf("RTC-9 longest stall %0d PCLK <= 13 (agreed bound)", stall_max));
        check(wr_bad == 0, "RTC-9 every stalled write lands on the PL031 exactly once");
        note($sformatf("RTC-9 longest passthrough stall: %0d PCLK", stall_max));
    endtask

    // -------------------------------------------------------------- RTC-10
    // nPOR low without PRESETn: the counter restarts and sampling resumes.
    task automatic npor_pulse(input string where);
        bit ok; int took;
        logic [31:0] t_a, t_b;
        int unsigned n0;
        nPOR = 1'b0; clk(5);
        apb_rd(A_DR, t_a);                         // firmware access, counter in reset
        check(last_stall <= 13, {"RTC-10 nPOR pulse ", where, ": passthrough completes while the counter is in reset"});
        clk(10); nPOR = 1'b1;
        // nRTCRST is released 2 CLK1HZ edges later
        clk(3 * period());
        apb_rd(A_DR, t_a);
        clk(3 * period());
        apb_rd(A_DR, t_b);
        check(t_b > t_a && t_a < 32'd8,
              $sformatf("RTC-10 nPOR pulse %s: the counter restarts from 0 and runs (%0d -> %0d)", where, t_a, t_b));
        n0 = trig_count;
        wait_trig(6 * period(), ok, took);
        check(ok, {"RTC-10 nPOR pulse ", where, ": autonomous sampling resumes"});
        wait_armed(ok);
        apb_rd(A_DR, t_a);
        check(dut.alarm_target == dut.ctrl_time_value + 32'd2 && dut.ctrl_time_value <= t_a,
              {"RTC-10 nPOR pulse ", where, ": re-armed against the restarted counter"});
        gchk = 1'b1; g_reset();
        for (int i = 0; i < 3; i++) begin
            wait_trig(4 * period() + 100, ok, took);
            check(ok && last_svc_intr, $sformatf("RTC-10 nPOR pulse %s: period %0d sampled by a real PL031 match", where, i));
        end
        gchk = 1'b0;
    endtask


    // RTC-10b: a passthrough whose SETUP/ACCESS straddles the release of the
    // counter reset (nRTCRST rises on the 2nd CLK1HZ edge after nPOR). While
    // nRTCRST is low the FSM parks in S_IDLE and grants the bus; at the release
    // it leaves S_IDLE for an arm cycle. The transfer in flight must still be
    // SETUP-then-ACCESS at the PL031 and complete exactly once. (Bug
    // RTC-RSTREL, found by the WRP-6 soak, seed 5.)
    task automatic rtc10b();
        bit ok;
        logic [31:0] r;
        int unsigned bad0 = n_port_bad, wr0;
        $display("--- RTC-10b passthrough across the nRTCRST release ---");
        for (int d = -6; d <= 6; d++)
            for (int wr = 0; wr < 2; wr++) begin
                wait_armed(ok);
                c1_run = 1'b0; clk(4); CLK1HZ = 1'b0; clk(4);
                nPOR = 1'b0; clk(5); nPOR = 1'b1; clk(5);
                c1_force_rise = 2; clk(30);             // 1st edge: nRTCRST_ff1 <= 1
                CLK1HZ = 1'b0; clk(10);
                // 2nd edge 20 negedges from now releases nRTCRST; SETUP at release + d
                c1_force_rise = 20;
                clk(20 + d);
                wr0 = n_ext_wr_land;
                apb_xfer(wr[0], A_IMSC, 32'h1, r);
                check(last_stall <= 13, $sformatf("RTC-10b %s with SETUP %0d PCLK from the nRTCRST release completes (stall %0d)",
                                                  wr ? "write" : "read", d, last_stall));
                if (wr) check(n_ext_wr_land - wr0 == 1, $sformatf("RTC-10b write at %0d lands exactly once", d));
                c1_run = 1'b1;
                clk(10);
            end
        check(n_port_bad == bad0, "RTC-10b PL031 port SETUP-then-ACCESS on every transfer across the release");
        begin int took; wait_trig(6 * period(), ok, took); end
        check(ok, "RTC-10b sampling resumes");
    endtask

    task automatic rtc10();
        bit ok;
        $display("--- RTC-10 nPOR pulsed without PRESETn ---");
        set_offset_and_settle(2);
        wait_armed(ok); clk(10);
        npor_pulse("while waiting");
        wait_state(S_MATCH_SETUP, 4 * period(), ok);
        npor_pulse("mid-arm");
        rtc10b();
        // full power-on reset (nPOR and PRESETn together) from a running system
        wait_armed(ok);
        por_reset();
        wait_armed(ok);
        check(ok && dut.rtc_enabled, "RTC-10 power-on reset from running: first arm completes");
        begin int took; wait_trig(5 * period(), ok, took); end
        check(ok, "RTC-10 power-on reset from running: sampling resumes");
    endtask

    // -------------------------------------------------------------- RTC-11
    task automatic rtc11();
        bit ok; int took;
        logic [31:0] r;
        int unsigned t0;
        int unsigned halves [5] = '{32, 16, 8, 4, 2};   // period 64, 32, 16, 8, 4 PCLK
        $display("--- RTC-11 CLK1HZ stopped; CLK1HZ at fast ratios ---");
        set_offset_and_settle(1);
        wait_armed(ok);
        c1_run = 1'b0;
        t0 = trig_count;
        for (int i = 0; i < 10; i++) begin apb_rd(A_DR, r); clk(190); end
        check(trig_count == t0, "RTC-11 CLK1HZ stopped 2000 PCLK: no rtc_trig");
        check(dut.state == S_WAITING, "RTC-11 CLK1HZ stopped: FSM parked, not hung");
        apb_wr(A_IMSC, 32'h1);
        check(last_stall <= 13, "RTC-11 CLK1HZ stopped: passthrough still completes");
        c1_run = 1'b1;
        wait_trig(4 * period() + 100, ok, took);
        check(ok, "RTC-11 CLK1HZ restarted: sampling resumes");
        // fast ratios: does RTC-1 (one trigger per period, within the
        // guarantee) still hold? Recorded, not required below PCLK/16.
        foreach (halves[h]) begin
            int unsigned bad0, n0;
            c1_half = halves[h];
            set_offset_and_settle(2);
            bad0 = g_bad_max + g_bad_min; n0 = trig_count;
            g_quiet = (2 * halves[h] < 16);
            gchk = 1'b1; gmin = 1'b1; g_reset();
            for (int p = 0; p < 20; p++) begin
                wait_trig(8 * period() + 200, ok, took);
                if (!ok) break;
            end
            clk(1);                       // trig_count counts the pulse one edge later
            gchk = 1'b0; gmin = 1'b0;
            note($sformatf("RTC-11 CLK1HZ = PCLK/%0d: %0d triggers in 20 periods, %0d guarantee violations",
                           2 * halves[h], trig_count - n0, g_bad_max + g_bad_min - bad0));
            check(trig_count - n0 >= 20, $sformatf("RTC-11 CLK1HZ = PCLK/%0d: sampling never hangs", 2 * halves[h]));
            if (2 * halves[h] >= 16)
                check(g_bad_max + g_bad_min == bad0, $sformatf("RTC-11 CLK1HZ = PCLK/%0d: RTC-1 holds", 2 * halves[h]));
            g_quiet = 1'b0;
        end
        c1_half = 50;
        set_offset_and_settle(1);
    endtask

    // -------------------------------------------------------------- RTC-12
    task automatic warm_reset_in(input logic [4:0] s, input bit stalled, input string nm);
        bit ok; int took;
        logic [31:0] t_bef, t_aft, r;
        int unsigned tk0;
        apb_rd(A_DR, t_bef);
        tk0 = tick_count;
        if (s == S_ENABLE_SETUP || s == S_ENABLE_ACCESS) begin
            // the enable states only run on the first arm after a warm reset
            PRESETn = 1'b0; clk(2); PRESETn = 1'b1;
        end
        if (stalled) begin
            wait_state(S_ICR_SETUP, 4 * period(), ok);
            fork
                begin apb_rd(A_DR, r); end
                begin clk(3); end
            join_any
            ok = ok && PSEL && PENABLE && !PREADY;
        end else begin
            wait_state(s, 4 * period() + 200, ok);
        end
        check(ok, {"RTC-12 precondition: ", nm});
        apb_abort = 1'b1;
        PRESETn = 1'b0;
        #1;
        check(dut.state == S_IDLE && !rtc_trig && dut.alarm_target == 0 && dut.armed_offset == 1 &&
              dut.wd_ticks == 0 && ctrl_time_value == 0 && !dut.fsm_psel && !ctrl_intr_flag,
              {"RTC-12 reset in ", nm, ": registers at reset values"});
        PSEL = 0; PENABLE = 0;
        clk(4);
        wait fork;
        apb_abort = 1'b0;
        PRESETn = 1'b1;
        // a passthrough in the first 3 cycles after the release
        clk(1);
        apb_rd(A_DR, t_aft);
        check(t_aft - t_bef + 32'd1 >= tick_count - tk0 && t_aft - t_bef <= tick_count - tk0 + 1,
              $sformatf("RTC-12 reset in %s: PL031 time preserved (%0d -> %0d over %0d ticks)", nm, t_bef, t_aft, tick_count - tk0));
        wait_armed(ok);
        check(ok && dut.rtc_enabled, {"RTC-12 reset in ", nm, ": first arm completes"});
        wait_trig(5 * period(), ok, took);
        check(ok, {"RTC-12 reset in ", nm, ": sampling resumes"});
    endtask

    task automatic rtc12();
        logic [4:0] sts [15] = '{S_IDLE, S_ENABLE_SETUP, S_ENABLE_ACCESS, S_READ_SETUP, S_READ_ACCESS,
                                 S_READ_CAPTURE, S_CALC, S_MATCH_SETUP, S_MATCH_ACCESS, S_IMSC_SETUP,
                                 S_IMSC_ACCESS, S_WAITING, S_ICR_SETUP, S_ICR_ACCESS, S_PULSE_TRIG};
        int unsigned bad0 = n_port_bad;
        $display("--- RTC-12 PRESETn in every FSM state and during a stalled passthrough ---");
        set_offset_and_settle(1);
        foreach (sts[i]) warm_reset_in(sts[i], 1'b0, $sformatf("state %0d", sts[i]));
        warm_reset_in(S_ICR_SETUP, 1'b1, "a stalled passthrough");
        check(n_port_bad == bad0, "RTC-12 PL031 port protocol-correct across every reset");
    endtask


    // ------------------------------------------- coverage closure (no spec ID)
    // Stimulus for model bins the RTC-n cases do not reach on their own.
    // Arm the given offset with or without a CLK1HZ tick in the arm window
    // (re-phase right after the trigger that starts the arm), then get out
    // of a long armed period with the RTCMR workaround.
    task automatic arm_with(input logic [31:0] off, input bit raced);
        bit ok; int took;
        logic [31:0] now;
        int unsigned eff = (off == 0) ? 1 : off;
        wait_armed(ok);
        if (eff != dut.armed_offset) begin
            // FIX-1: the change re-arms at once; a forced tick 2 negedges out
            // lands in that re-arm's window (S_READ_SETUP .. RTCMR write)
            if (raced) c1_force_rise = 2;
            alarm_offset = off;
        end else begin
            // same offset: arm through an alarm service
            alarm_offset = off;
            wait_trig((eff + 3) * period() + 400, ok, took);
            if (raced) c1_force_rise = 3;
        end
        wait_rearmed(60, ok, took);
        check(ok && dut.armed_offset == eff,
              $sformatf("COV arm with offset %0d (%s)", off, raced ? "tick in the arm window" : "clean"));
        if (off > 8) begin
            apb_rd(A_DR, now);
            apb_wr(A_MR, now + 32'd1);
        end
    endtask

    task automatic cov_extra();
        bit ok; int took;
        logic [31:0] r;
        logic [11:0] far [3] = '{12'h020, 12'h3FC, 12'hFFC};
        $display("--- COV extra stimulus (offset classes x arm-window tick, deferral lengths, ...) ---");
        set_offset_and_settle(2);
        arm_with(0, 1'b1);  arm_with(0, 1'b0);
        arm_with(12, 1'b1); arm_with(12, 1'b0);
        arm_with(20, 1'b0);
        arm_with(5000, 1'b0);
        arm_with(32'hFFFF_FFFF, 1'b1); arm_with(32'hFFFF_FFFF, 1'b0);
        set_offset_and_settle(1);
        // a due alarm held back by a passthrough for 1, 2..8 and 9..64 cycles:
        // pause, let the alarm become pending, then resume while transfers run
        for (int n = 0; n < 3; n++) begin
            int unsigned k = (n == 0) ? 1 : (n == 1) ? 1 : 12;   // number of reads
            wait_armed(ok);
            poll_enable = 1'b0;
            while (!dut.RTCINTR) clk(1);
            clk(3);
            PSEL = 1'b1; PENABLE = 1'b0; PWRITE = 1'b0; PADDR = A_DR;   // SETUP of the first read
            if (n != 0) poll_enable = 1'b1;
            @(posedge PCLK); #1; PENABLE = 1'b1;
            if (n == 0) poll_enable = 1'b1;                             // due only in the ACCESS cycle
            while (!PREADY) begin @(posedge PCLK); #1; end
            @(posedge PCLK); #1; PSEL = 1'b0; PENABLE = 1'b0;
            for (int i = 1; i < k; i++) apb_rd(A_DR, r);
            wait_trig(30, ok, took);
            check(ok, $sformatf("COV deferral case %0d: the held-back alarm is serviced", n));
        end
        // alarm pending while paused for > 5000 PCLK
        wait_armed(ok);
        poll_enable = 1'b0;
        clk(60 * period());
        check(dut.RTCINTR, "COV alarm held pending through a 6000 PCLK pause");
        poll_enable = 1'b1;
        wait_trig(12, ok, took);
        check(ok, "COV the long-pending alarm is serviced on resume");
        // words above RTCICR at the controller port; an all-ones write
        foreach (far[i]) begin
            apb_rd(far[i], r);
            apb_wr(far[i], 32'h0);
            check(PSLVERR == 1'b0 && last_stall <= 13, $sformatf("COV passthrough to byte offset 0x%03h completes", far[i]));
        end
        wait_armed(ok);
        apb_wr(A_IMSC, 32'hFFFF_FFFF);
        apb_rd(A_IMSC, r);
        check(r[0] == 1'b1, "COV RTCIMSC all-ones write keeps the interrupt unmasked");
        wait_trig(4 * period(), ok, took);
        check(ok, "COV sampling continues after the all-ones write");
    endtask

    // ---------------------------------------------------------------- main
    initial begin
        bit ok;
        if ($test$plusargs("vcd")) begin $dumpfile("tb_rtc_closure.vcd"); $dumpvars(0, tb_rtc_closure); end
        clk(2);
        por_reset();
        wait_armed(ok);
        check(ok, "first arm after power-on completes");

        rtc1();
        rtc2();
        rtc3();
        rtc4();
        rtc5();
        rtc6();
        rtc7();
        fix1();
        rtc8();
        rtc9();
        rtc11();
        rtc12();
        cov_extra();
        rtc10();      // last: the stand-in may stop the counter for good

        check(n_pslverr == 0, "PSLVERR never asserted");
        check(n_port_bad == 0, "PL031 port protocol never violated");
        $display("--- guarantee monitor: %0d gaps checked, longest %0d PCLK; longest stall %0d PCLK ---",
                 g_gaps, g_gap_max, max_stall);
        $display("\n=== RTC-CLO: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $finish;
    end

    initial begin
        #400_000_000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== RTC-CLO: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end
endmodule
