`timescale 1ns/1ps
// =============================================================================
// sens_closure_tb.sv - sensing-peripheral closure tests at wrapper level
// (WRP-1..WRP-5, ADC-6, and the
// wrapper-level view of RTC-2/3/4/7/10).
//
// Drives adc_apb_wrapper_rev2 exactly as nanosoc does (16-bit PADDR, PSTRB,
// PPROT) with a protocol-correct APB master (holds ACCESS until PREADY is seen
// at a rising edge). CLK1HZ is generated here (period TICK PCLK) and can be
// stopped. Internal signals are used only to time stimulus and in the
// scoreboards; register behaviour is checked on the bus.
//
// Scoreboards (always on):
//   - ADC: every rising edge of the SAR ADC's raw `valid` queues that
//     conversion's `result`; every FIFO push must equal the oldest queued
//     result of a conversion the FSM started (ADC-6). Raw valid rises must
//     equal synchronised rises (the 3-flop synchroniser never misses a
//     2*ADC_CLK_DIV-PCLK pulse).
//   - FIFO: a model queue of pushes / pops / clears; every MEASUREMENT_LO pop
//     read on the bus must equal the model's front.
//   - Triggers: a trigger (rtc_trig | manual_trig) seen while the FSM is in
//     IDLE is accepted; every accepted trigger gives exactly one push or one
//     drop (FIFO full).
//
// +adc_only  run only ADC-6 (the `make adcdiv` builds at ADC_CLK_DIV 1, 2, 8)
// Ends with "=== SENS-CLO: ... ===" ("=== SENS-CLO[divN]: ... ===" with +adc_only).
// =============================================================================
module sens_closure_tb #(
    parameter int AW          = 16,
    parameter int ADC_CLK_DIV = 4
);
    localparam logic [15:0]
        A_STATUS = 16'h004, A_MEAS_HI = 16'h008, A_MEAS_LO = 16'h00C,
        A_PLL    = 16'h100, A_AMUX    = 16'h104, A_TRIG    = 16'h108, A_CAL = 16'h10C,
        A_RTCDR  = 16'h200, A_RTCMR   = 16'h204, A_RTCLR   = 16'h208, A_RTCCR = 16'h20C,
        A_RTCIMSC= 16'h210, A_RTCRIS  = 16'h214, A_RTCMIS  = 16'h218, A_RTCICR = 16'h21C,
        A_FCLR   = 16'h220, A_ALARM   = 16'h224, A_RTCCTRL = 16'h228;
    localparam logic [2:0] F_IDLE = 3'd0, F_CHECK = 3'd1, F_ENABLE = 3'd2, F_WSTART = 3'd3,
                           F_WDONE = 3'd4, F_WRITE = 3'd5, F_ERR = 3'd6;
    localparam logic [4:0] R_WAITING = 5'd10, R_ICR_SETUP = 5'd11;

    // ------------------------------------------------------------------ DUT
    logic          PCLK = 1'b0, CLK1HZ = 1'b0, PRESETn = 1'b0, nPOR = 1'b0;
    logic          PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
    logic [AW-1:0] PADDR = '0;
    logic [31:0]   PWDATA = '0;
    logic [3:0]    PSTRB = 4'h0;
    wire  [31:0]   PRDATA;
    wire           PREADY, PSLVERR;

    adc_apb_wrapper_rev2 #(.ADDR_WIDTH(AW), .DEFAULT_ALARM_OFFSET(32'd5), .ADC_CLK_DIV(ADC_CLK_DIV)) uut (
        .PCLK(PCLK), .CLK1HZ(CLK1HZ), .PRESETn(PRESETn), .nPOR(nPOR),
        .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .APBACTIVE(1'b1), .PPROT(3'b001), .PSTRB(PSTRB),
        .ADC_VINP(1'b0), .ADC_VINN(1'b0));

    always #5 PCLK = ~PCLK;

    // CLK1HZ from PCLK falling edges; period 2*c1_half PCLK
    int unsigned c1_half = 200;
    int unsigned c1_cnt  = 0;
    bit          c1_run  = 1'b1;
    always @(negedge PCLK) if (c1_run) begin
        if (c1_cnt + 1 >= c1_half) begin CLK1HZ <= ~CLK1HZ; c1_cnt <= 0; end
        else c1_cnt <= c1_cnt + 1;
    end
    function automatic int unsigned tick(); return 2 * c1_half; endfunction

    // ------------------------------------------------------------ checking
    int pass_count = 0, fail_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) pass_count++;
        else begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction

    // ----------------------------------------------------------- APB master
    // Called at posedge+1; SETUP now, ACCESS next cycle, ACCESS held until
    // PREADY is sampled at a rising edge (sampled in the low half before it).
    logic [31:0] rdat;
    int unsigned last_stall = 0, max_stall = 0, n_pslverr = 0;
    task automatic xfer(input bit wr, input logic [AW-1:0] a, input logic [31:0] d, input logic [3:0] strb);
        int unsigned st = 0;
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE = wr; PADDR = a; PWDATA = wr ? d : 32'h0; PSTRB = wr ? strb : 4'h0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        forever begin
            @(negedge PCLK);
            if (PREADY) begin rdat = PRDATA; if (PSLVERR) n_pslverr++; break; end
            st++;
            if (st > 500) begin check(1'b0, "APB transfer completes"); break; end
        end
        @(posedge PCLK); #1;
        PSEL = 1'b0; PENABLE = 1'b0; PWRITE = 1'b0; PSTRB = 4'h0;
        last_stall = st; if (st > max_stall) max_stall = st;
    endtask
    task automatic wr(input logic [AW-1:0] a, input logic [31:0] d); xfer(1'b1, a, d, 4'hF); endtask
    task automatic wrs(input logic [AW-1:0] a, input logic [31:0] d, input logic [3:0] s); xfer(1'b1, a, d, s); endtask
    task automatic rd(input logic [AW-1:0] a, output logic [31:0] d); xfer(1'b0, a, 32'h0, 4'h0); d = rdat; endtask

    // ------------------------------------------------------------- helpers
    task automatic cyc(input int n); repeat (n) @(posedge PCLK); #1; endtask
    task automatic wait_fsm(input logic [2:0] s, input int tmo, output bit ok);
        int i = 0; ok = 1'b0;
        while (i < tmo) begin if (uut.u_ctrl.state == s) begin ok = 1'b1; return; end cyc(1); i++; end
    endtask
    task automatic wait_fsm_idle();
        int i = 0;
        while (i < 5000 && !(uut.u_ctrl.state == F_IDLE && !uut.sample_trig)) begin cyc(1); i++; end
        cyc(2);
    endtask
    task automatic wait_rtc_parked();
        int i = 0;
        while (i < 5000 && !(uut.u_rtc.state == R_WAITING && !uut.u_rtc.fsm_psel)) begin cyc(1); i++; end
    endtask
    // Pausing: an RTC trigger already in its service can still fire up to 3
    // PCLK later (RTC-6 property), so wait that out before returning.
    task automatic set_poll(input bit en); wr(A_RTCCTRL, {31'h0, en}); if (!en) cyc(5); endtask

    // ------------------------------------------------------- scoreboards
    // ADC: results of conversions, in the ADC's own domain
    logic [7:0] adc_q[$];
    int unsigned n_raw_rise = 0, n_sync_rise = 0, n_adc_bad = 0, n_conv_start = 0;
    always @(posedge uut.adc_raw_valid) if (PRESETn) begin
        #0.1;
        adc_q.push_back(uut.adc_result);
        n_raw_rise++;
    end
    // FIFO model, triggers
    logic [7:0] fq[$];
    int unsigned n_push = 0, n_pop = 0, n_drop = 0, n_acc = 0, n_ign = 0, n_clear = 0;
    int unsigned n_rtc_trig = 0, n_man_trig = 0, n_rd_wr_same = 0, sb_err = 0;
    int unsigned rw_same_occ [17];
    logic adc_en_q = 1'b0;
    always @(posedge PCLK) begin
        if (!PRESETn) begin
            fq.delete(); adc_q.delete(); adc_en_q <= 1'b0;
        end else begin
            adc_en_q <= uut.adc_en;
            if (uut.adc_valid_rise) n_sync_rise++;
            if (uut.rtc_trig) n_rtc_trig++;
            if (uut.manual_trig) n_man_trig++;
            if (uut.sample_trig) begin
                if (uut.u_ctrl.state == F_IDLE) n_acc++; else n_ign++;
            end
            if (uut.u_ctrl.state == F_ERR) n_drop++;
            if (uut.fifo_write_en) begin
                // ADC-6: the push is the result of the conversion just finished
                if (adc_q.size() == 0) begin n_adc_bad++; $display("FAIL [%0t] ADC-6 push with no finished conversion", $time); end
                else begin
                    logic [7:0] e;
                    // the push is the newest finished conversion (an unrequested
                    // back-to-back one may have finished before it)
                    e = adc_q[$];
                    adc_q.delete();
                    if (uut.adc_sample !== e) begin
                        n_adc_bad++;
                        $display("FAIL [%0t] ADC-6 push 0x%02h != that conversion's result 0x%02h", $time, uut.adc_sample, e);
                    end
                end
            end
            if (uut.fifo_rd_en && uut.fifo_write_en) begin
                n_rd_wr_same++;
                rw_same_occ[uut.u_fifo.count]++;
            end
            if (uut.fifo_clear) begin
                fq.delete(); n_clear++;
            end else begin
                if (uut.fifo_rd_en && !uut.fifo_empty) begin
                    if (fq.size() == 0) sb_err++; else void'(fq.pop_front());
                    n_pop++;
                end
                if (uut.fifo_write_en && !uut.fifo_full) begin fq.push_back(uut.adc_sample); n_push++; end
            end
        end
    end
    // stale conversions (en dropped before valid, or an ADC result nobody
    // consumed) must not pile up: drop queued results older than the latest
    // conversion start
    always @(posedge PCLK) if (PRESETn && uut.adc_en && !adc_en_q) begin
        n_conv_start++;
        adc_q.delete();
    end


    // ------------------------------------------ conversion-age scoreboard
    // Each SAR conversion: when it started (sarlogic entered sSample) and
    // whether it was a calibration. A pushed sample must come from a
    // conversion that started at or after the trigger the FSM accepted, with
    // the ADC_CAL setting in force at that trigger.
    localparam logic [2:0] SAR_SAMPLE = 3'd2, SAR_DONE = 3'd4;
    realtime conv_start_t = 0, done_start_t = 0, last_start_t = 0, t_acc = 0;
    bit      conv_cal = 0, done_cal = 0, last_cal = 0, acc_cal = 0;
    logic [2:0] sar_st_q = 3'd0;
    int unsigned n_stale = 0, n_calmis = 0, n_age_checked = 0;
    always @(posedge PCLK) begin
        sar_st_q <= uut.u_adc.u_logic.state;
        if (uut.u_adc.u_logic.state == SAR_SAMPLE && sar_st_q != SAR_SAMPLE) begin
            conv_start_t = $realtime; conv_cal = uut.u_adc.u_logic.calibrate;
        end
        if (uut.u_adc.u_logic.state == SAR_DONE && sar_st_q != SAR_DONE) begin
            done_start_t = conv_start_t; done_cal = conv_cal;
        end
        if (PRESETn && uut.sample_trig && uut.u_ctrl.state == F_IDLE) begin
            t_acc = $realtime; acc_cal = uut.cal_reg;
        end
        if (PRESETn && uut.fifo_write_en) begin
            n_age_checked++;
            if (last_start_t < t_acc) begin
                n_stale++;
                if (n_stale <= 5)
                    $display("FAIL [%0t] stale sample: conversion started at %0t, before the accepted trigger at %0t", $time, last_start_t, t_acc);
            end
            if (last_cal != acc_cal) begin
                n_calmis++;
                if (n_calmis <= 5)
                    $display("FAIL [%0t] sample conversion cal=%b but ADC_CAL was %b at the trigger", $time, last_cal, acc_cal);
            end
        end
    end
    always @(posedge uut.adc_raw_valid) begin last_start_t = done_start_t; last_cal = done_cal; end

    // Pop through the bus and compare with the model's front
    int unsigned n_pop_bad = 0;
    // The expected value is the model's front in the ACCESS cycle itself: a
    // previous pop's fifo_rd_en (registered) lands in this read's SETUP cycle.
    task automatic pop(output logic [7:0] v, output bit was_empty);
        logic [7:0] exp_v;
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE = 1'b0; PADDR = A_MEAS_LO; PSTRB = 4'h0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        @(negedge PCLK);                          // MEASUREMENT_LO never stalls
        was_empty = (fq.size() == 0);
        exp_v = was_empty ? 8'h00 : fq[0];
        v = PRDATA[7:0];
        if (!PREADY || PRDATA !== {24'h0, exp_v}) begin
            n_pop_bad++;
            $display("FAIL [%0t] pop read 0x%08h (PREADY %b), model front 0x%02h", $time, PRDATA, PREADY, exp_v);
        end
        @(posedge PCLK); #1;
        PSEL = 1'b0; PENABLE = 1'b0;
    endtask
    task automatic drain(output int unsigned n);
        logic [7:0] v; bit e;
        n = 0;
        cyc(1);
        while (fq.size() > 0 && n < 40) begin pop(v, e); n++; cyc(1); end
        cyc(2);
    endtask

    // One manual sample, waited for
    task automatic manual_sample();
        wr(A_TRIG, 32'h1);
        cyc(2);
        wait_fsm_idle();
    endtask

    // ---------------------------------------------------------------- WRP-1
    task automatic wrp1();
        logic [31:0] s;
        bit ok;
        int unsigned resv_bad = 0, n0;
        $display("--- WRP-1 status observation ---");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1); cyc(2);
        // during a conversion
        wr(A_TRIG, 32'h1);
        wait_fsm(F_WDONE, 100, ok);
        rd(A_STATUS, s);
        check(ok && s[3:2] == 2'b01, $sformatf("WRP-1 STATUS[3:2] reads 1 during a conversion (0x%08h)", s));
        if (s[31:6] != 0) resv_bad++;
        wait_fsm_idle();
        rd(A_STATUS, s);
        check(s[3:2] == 2'b00 && s[1:0] == 2'b01, $sformatf("WRP-1 STATUS[3:2] reads 0 after it, FIFO partial (0x%08h)", s));
        if (s[31:6] != 0) resv_bad++;
        // fill, drop, then the next good sample clears [4]
        while (fq.size() < 16) manual_sample();
        rd(A_STATUS, s);
        check(s[1:0] == 2'b10 && s[4] == 1'b0, "WRP-1 FIFO full, no drop yet");
        n0 = n_drop;
        manual_sample();
        rd(A_STATUS, s);
        check(n_drop == n0 + 1 && s[4] == 1'b1, $sformatf("WRP-1 STATUS[4] sets on the drop (0x%08h)", s));
        rd(A_STATUS, s);
        check(s[4] == 1'b1, "WRP-1 STATUS[4] stays set while no sample is accepted");
        begin logic [7:0] v; bit e; pop(v, e); end
        manual_sample();
        rd(A_STATUS, s);
        check(s[4] == 1'b0, $sformatf("WRP-1 STATUS[4] clears on the next accepted sample (0x%08h)", s));
        if (s[31:6] != 0) resv_bad++;
        wr(A_FCLR, 32'h1); cyc(2);
        // alarm pending while paused: [5]
        wait_rtc_parked();
        begin int g = 0; while (!uut.u_rtc.RTCINTR && g < 20 * tick()) begin cyc(1); g++; end end
        cyc(3);
        rd(A_STATUS, s);
        check(uut.u_rtc.RTCINTR && s[5] == 1'b1, $sformatf("WRP-1 STATUS[5] reads 1 while an alarm is pending, polling paused (0x%08h)", s));
        if (s[31:6] != 0) resv_bad++;
        set_poll(1'b1);
        cyc(20);
        rd(A_STATUS, s);
        check(s[5] == 1'b0, $sformatf("WRP-1 STATUS[5] reads 0 once the alarm is serviced (0x%08h)", s));
        check(resv_bad == 0, "WRP-1 STATUS[31:6] always 0");
        wait_fsm_idle();
    endtask

    // ---------------------------------------------------------------- WRP-2
    // A second trigger at every PCLK offset of the first one's conversion,
    // both orders (manual during RTC, RTC during manual).
    task automatic wrp2();
        bit ok;
        int unsigned span, a0, p0, d0, i0, bad = 0, ign0;
        $display("--- WRP-2 RTC and manual triggers overlapping ---");
        wr(A_ALARM, 32'd1);
        set_poll(1'b1);
        wr(A_FCLR, 32'h1);
        // conversion span in PCLK, measured on one manual sample
        wait_fsm_idle();
        begin int t = 0; wr(A_TRIG, 32'h1); while (uut.u_ctrl.state != F_WRITE && t < 2000) begin cyc(1); t++; end span = t + 4; end
        wait_fsm_idle();
        ign0 = n_ign;
        // (a) manual trigger d PCLK after an RTC trigger
        for (int d = 0; d <= span; d++) begin
            int g = 0;
            while (!uut.rtc_trig && g < 4 * tick()) begin cyc(1); g++; end
            a0 = n_acc; p0 = n_push; d0 = n_drop;
            cyc(d);
            wr(A_TRIG, 32'h1);
            cyc(2); wait_fsm_idle();
            if (n_push + n_drop - p0 - d0 != n_acc - a0 || n_acc - a0 < 1) bad++;
            if (fq.size() > 8) begin wr(A_FCLR, 32'h1); cyc(2); end
        end
        check(bad == 0, $sformatf("WRP-2a manual trigger at every offset of an RTC conversion: one sample per accepted trigger (%0d offsets)", span + 1));
        // (b) RTC trigger d PCLK into a manual conversion: hold the alarm
        // pending with polling paused, start the manual conversion, resume.
        bad = 0;
        for (int d = 0; d <= span; d++) begin
            int g = 0;
            set_poll(1'b0);
            wait_fsm_idle();
            while (!uut.u_rtc.RTCINTR && g < 4 * tick()) begin cyc(1); g++; end
            a0 = n_acc; p0 = n_push; d0 = n_drop; i0 = n_rtc_trig;
            wr(A_TRIG, 32'h1);
            if (d > 2) cyc(d - 2);
            set_poll(1'b1);                       // RTC trigger ~4 PCLK later
            cyc(8); wait_fsm_idle();
            if (n_rtc_trig != i0 + 1 || n_push + n_drop - p0 - d0 != n_acc - a0 || n_acc - a0 < 1) bad++;
            if (fq.size() > 8) begin wr(A_FCLR, 32'h1); cyc(2); end
        end
        check(bad == 0, $sformatf("WRP-2b RTC trigger at every offset of a manual conversion: one sample per accepted trigger (%0d offsets)", span + 1));
        check(n_ign > ign0, $sformatf("WRP-2 property recorded: a trigger landing while busy is discarded (%0d discarded)", n_ign - ign0));
        $display("NOTE WRP-2 property: a trigger (RTC or manual) that arrives while the sampling FSM is busy is discarded, not queued; no deadlock");
        wr(A_ALARM, 32'd5);
        wr(A_FCLR, 32'h1); cyc(2);
    endtask

    // ---------------------------------------------------------------- WRP-3
    // Fill to 16 autonomously, 17th dropped, drain 16 in order; pop on the
    // same PCLK as a push at occupancy 1, 8, 15.
    task automatic pop_with_push(input int occ, output bit ok);
        int g = 0;
        ok = 1'b0;
        // fill to `occ` with manual samples
        while (fq.size() < occ) manual_sample();
        wr(A_TRIG, 32'h1);
        while (!(uut.adc_valid_s1 && !uut.adc_valid_s2 && uut.u_ctrl.state == F_WDONE) && g < 3000) begin cyc(1); g++; end
        // valid_s1 just rose: the FSM writes 2 cycles from now; a read whose
        // ACCESS is next cycle pops in the same cycle
        begin
            int unsigned n0 = rw_same_occ[occ];
            logic [7:0] v; bit e;
            pop(v, e);
            cyc(1);
            ok = (rw_same_occ[occ] == n0 + 1);
        end
        wait_fsm_idle();
    endtask

    task automatic wrp3();
        logic [31:0] s;
        int unsigned n, d0, g;
        bit ok;
        $display("--- WRP-3 fill / drop / drain, pop and push in one cycle ---");
        wr(A_FCLR, 32'h1); cyc(2);
        wr(A_ALARM, 32'd1);
        set_poll(1'b1);
        g = 0;
        while (fq.size() < 16 && g < 60) begin
            int k = 0;
            while (!uut.rtc_trig && k < 4 * tick()) begin cyc(1); k++; end
            cyc(2); wait_fsm_idle();
            rd(A_STATUS, s);
            if (s[1:0] != ((fq.size() == 16) ? 2'b10 : 2'b01)) begin check(1'b0, $sformatf("WRP-3 status FIFO field at occupancy %0d", fq.size())); end
            g++;
        end
        check(fq.size() == 16 && uut.u_fifo.count == 16, "WRP-3 FIFO filled to 16 by autonomous sampling");
        d0 = n_drop;
        begin int k = 0; while (!uut.rtc_trig && k < 4 * tick()) begin cyc(1); k++; end end
        cyc(2); wait_fsm_idle();
        rd(A_STATUS, s);
        check(n_drop == d0 + 1 && uut.u_fifo.count == 16 && s[4] && s[1:0] == 2'b10, "WRP-3 the 17th sample is dropped, flag set");
        set_poll(1'b0);
        cyc(4);
        drain(n);
        rd(A_STATUS, s);
        check(n == 16 && n_pop_bad == 0 && s[1:0] == 2'b00, $sformatf("WRP-3 drained 16 in order (%0d), status empty", n));
        foreach (rw_same_occ[i]) rw_same_occ[i] = 0;
        pop_with_push(1, ok);  check(ok, "WRP-3 pop and push in the same PCLK at occupancy 1");
        pop_with_push(8, ok);  check(ok, "WRP-3 pop and push in the same PCLK at occupancy 8");
        pop_with_push(15, ok); check(ok, "WRP-3 pop and push in the same PCLK at occupancy 15");
        drain(n);
        check(n_pop_bad == 0 && sb_err == 0, "WRP-3 scoreboard exact through the simultaneous pop/push cases");
        $display("NOTE WRP-3: a push at occupancy 16 cannot happen - the FSM drops the sample at its pre-check (S_CHECK_FIFO), so pop+push at 16 is unreachable");
        wr(A_ALARM, 32'd5);
    endtask

    // ---------------------------------------------------------------- WRP-4
    task automatic wrp4();
        bit ok;
        int unsigned bad = 0, span = 0, n;
        logic [31:0] s;
        $display("--- WRP-4 FIFO_CLEAR at every PCLK of a conversion, each byte lane ---");
        set_poll(1'b0);
        wait_fsm_idle();
        for (int d = 0; d < 400; d++) begin
            logic [3:0] lane = 4'b0001 << (d % 4);
            int unsigned p0;
            wr(A_FCLR, 32'h1); cyc(2);
            manual_sample();                     // one older sample in the FIFO
            wr(A_TRIG, 32'h1);
            wait_fsm(F_ENABLE, 50, ok);
            p0 = n_push;
            if (d > 0) cyc(d);
            if (uut.u_ctrl.state == F_IDLE && d > 0) begin span = d; break; end
            wrs(A_FCLR, 32'hA5A5_A5A5, lane);
            wait_fsm_idle();
            // FIFO is empty (clear after or with the push) or holds exactly the later sample
            if (!(fq.size() == 0 || (fq.size() == 1 && n_push == p0 + 1))) bad++;
            if (uut.u_fifo.count != fq.size()) bad++;
        end
        check(bad == 0, $sformatf("WRP-4 clear at every PCLK of S_ENABLE..S_WRITE (%0d offsets): FIFO empty or holds exactly the later sample", span));
        // drop flag unchanged by a clear
        wr(A_FCLR, 32'h1); cyc(2);
        while (fq.size() < 16) manual_sample();
        manual_sample();                         // dropped
        rd(A_STATUS, s);
        check(s[4], "WRP-4 drop flag set");
        wrs(A_FCLR, 32'h0, 4'b0100);
        cyc(2);
        rd(A_STATUS, s);
        check(s[4] && s[1:0] == 2'b00, $sformatf("WRP-4 FIFO_CLEAR empties the FIFO and leaves the drop flag unchanged (0x%08h)", s));
        manual_sample();
        rd(A_STATUS, s);
        check(!s[4], "WRP-4 the flag clears on the next accepted sample, not on the clear");
        wrs(A_FCLR, 32'h0, 4'b0000);             // no lane strobed: no clear
        cyc(2);
        check(fq.size() == 1 && uut.u_fifo.count == 1, "WRP-4 FIFO_CLEAR with no byte lane strobed does nothing");
        wr(A_FCLR, 32'h1); cyc(2);
    endtask

    // ---------------------------------------------------------------- WRP-5
    task automatic wrp5();
        logic [15:0] regs [3] = '{A_PLL, A_AMUX, A_ALARM};
        logic [31:0] shadow [3];
        logic [31:0] r, cal0, ctl0;
        int unsigned bad = 0, xbad = 0;
        $display("--- WRP-5 walking 1 / walking 0 through each byte lane ---");
        set_poll(1'b0);
        wait_fsm_idle();
        foreach (regs[i]) begin wr(regs[i], 32'h0); shadow[i] = 32'h0; end
        rd(A_CAL, cal0); rd(A_RTCCTRL, ctl0);
        foreach (regs[i])
            for (int walk0 = 0; walk0 < 2; walk0++)
                for (int b = 0; b < 32; b++) begin
                    logic [31:0] v = walk0 ? ~(32'h1 << b) : (32'h1 << b);
                    logic [3:0]  lane = 4'b0001 << (b / 8);
                    // write through the lane holding the bit only
                    wrs(regs[i], v, lane);
                    shadow[i][8*(b/8) +: 8] = v[8*(b/8) +: 8];
                    rd(regs[i], r);
                    if (r != shadow[i]) begin
                        bad++;
                        if (bad < 5) $display("FAIL [%0t] WRP-5 reg 0x%03h bit %0d walk%0d: read 0x%08h, expected 0x%08h", $time, regs[i], b, walk0, r, shadow[i]);
                    end
                    foreach (regs[j]) if (j != i) begin
                        rd(regs[j], r);
                        if (r != shadow[j]) xbad++;
                    end
                    rd(A_CAL, r);     if (r != cal0) xbad++;
                    rd(A_RTCCTRL, r); if (r != ctl0) xbad++;
                    rd(A_MEAS_HI, r); if (r != 0) xbad++;
                end
        check(bad == 0, "WRP-5 walking 1 / walking 0 on PLL_CONTROL, AMUX, RTC_ALARM_OFFSET through each lane: exact read-back");
        check(xbad == 0, "WRP-5 no cross-register disturbance");
        wr(A_PLL, 32'h0); wr(A_AMUX, 32'h0); wr(A_ALARM, 32'd5);
        set_poll(1'b1);
    endtask

    // ---------------------------------------------------------------- ADC-6
    task automatic adc6();
        int unsigned a0, p0, d0, r0, s0, c0;
        logic [31:0] r;
        $display("--- ADC-6 every push is that conversion's result (ADC_CLK_DIV %0d) ---", ADC_CLK_DIV);
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1); cyc(2);
        a0 = n_acc; p0 = n_push; d0 = n_drop; r0 = n_raw_rise; s0 = n_sync_rise;
        for (int i = 0; i < 40; i++) begin
            wr(A_CAL, (i % 7 == 3) ? 32'h1 : 32'h0);     // some calibration conversions too
            wr(A_AMUX, i % 4);
            manual_sample();
            if (fq.size() >= 12) begin int unsigned n; drain(n); end
        end
        wr(A_CAL, 32'h0);
        // autonomous ones too
        wr(A_ALARM, 32'd1); set_poll(1'b1);
        for (int i = 0; i < 10; i++) begin
            int k = 0;
            while (!uut.rtc_trig && k < 4 * tick()) begin cyc(1); k++; end
            cyc(2); wait_fsm_idle();
            if (fq.size() >= 12) begin int unsigned n; drain(n); end
        end
        set_poll(1'b0); wait_fsm_idle();
        check(n_adc_bad == 0, $sformatf("ADC-6 every FIFO push equals the result of that conversion (%0d pushes)", n_push - p0));
        check(n_push + n_drop - p0 - d0 == n_acc - a0,
              $sformatf("ADC-6 exactly one push (or drop) per accepted trigger (%0d pushes, %0d drops, %0d accepted)",
                        n_push - p0, n_drop - d0, n_acc - a0));
        check(n_raw_rise - r0 == n_sync_rise - s0,
              $sformatf("ADC-6 every raw valid pulse (2*ADC_CLK_DIV = %0d PCLK wide) seen by the synchroniser (%0d raw, %0d sync)",
                        2 * ADC_CLK_DIV, n_raw_rise - r0, n_sync_rise - s0));
        wr(A_ALARM, 32'd5); wr(A_AMUX, 32'h0);
        set_poll(1'b1);
    endtask


    // ---------------------------------------------------------------- STALE
    // A trigger at every PCLK offset after a sample has been written (the
    // window in which sarlogic, which saw adc_en still high at its sDone edge,
    // is running a back-to-back conversion nobody asked for). Every sample
    // must come from a conversion started after its trigger, with the CAL
    // setting of that trigger. (Bug FSM-STALE, found by the WRP-6 soak.)
    task automatic stale();
        bit ok;
        int unsigned s0 = n_stale, c0 = n_calmis, a0 = n_age_checked;
        $display("--- STALE trigger right after a sample: sample age and CAL ---");
        set_poll(1'b0);
        wait_fsm_idle();
        for (int d = 0; d < 120; d++) begin
            bit want_cal = (d % 2 == 1);
            wr(A_CAL, 32'h0);
            wr(A_TRIG, 32'h1);
            wait_fsm(F_WRITE, 3000, ok);
            cyc(1);
            if (d > 0) cyc(d);
            if (want_cal) wr(A_CAL, 32'h1);
            wr(A_TRIG, 32'h1);
            cyc(2); wait_fsm_idle();
            if (fq.size() > 10) begin wr(A_FCLR, 32'h1); cyc(2); end
        end
        wr(A_CAL, 32'h0);
        check(n_stale == s0, $sformatf("STALE every sample's conversion started after its trigger (%0d samples, %0d stale)", n_age_checked - a0, n_stale - s0));
        check(n_calmis == c0, $sformatf("STALE every sample used the ADC_CAL setting of its trigger (%0d wrong)", n_calmis - c0));
        wr(A_FCLR, 32'h1); cyc(2);
        set_poll(1'b1);
    endtask

    // ---------------------------------------------- RTC cases at wrapper level
    task automatic sampling_continues(input string nm, input int max_ticks);
        int unsigned t0 = n_rtc_trig;
        int g = 0;
        while (n_rtc_trig == t0 && g < max_ticks * tick() + 100) begin cyc(1); g++; end
        check(n_rtc_trig > t0, {nm, ": autonomous sampling continues"});
    endtask
    task automatic rtc_wrapper();
        logic [31:0] now, r;
        $display("--- RTC-2/3/4/7/10 through the wrapper ---");
        wr(A_ALARM, 32'd2); set_poll(1'b1);
        sampling_continues("RTC-7w offset 2", 8);
        wait_rtc_parked();
        rd(A_RTCDR, now); wr(A_RTCMR, now - 32'd3);
        sampling_continues("RTC-2w RTCMR in the past", 4);
        wait_rtc_parked();
        rd(A_RTCDR, now); wr(A_RTCMR, now + 32'd1000);
        sampling_continues("RTC-2w RTCMR far future", 4);
        wait_rtc_parked();
        wr(A_RTCIMSC, 32'h0);
        sampling_continues("RTC-3w RTCIMSC = 0", 4);
        wait_rtc_parked();
        rd(A_RTCDR, now); wr(A_RTCLR, now - 32'd100);
        sampling_continues("RTC-4w RTCLR back by 100", 4);
        wait_rtc_parked();
        wr(A_RTCLR, uut.u_rtc.alarm_target + 32'd5);
        sampling_continues("RTC-4w RTCLR forward past the target", 4);
        wr(A_ALARM, 32'd5);
        sampling_continues("RTC-7w offset 2 -> 5", 8);
        wr(A_ALARM, 32'd1);
        sampling_continues("RTC-7w offset 5 -> 1", 8);
        sampling_continues("RTC-7w offset 1 applied", 3);
        // FIX-1 at wrapper level: four byte-lane writes in a row re-arm up to
        // four times and end on the final value; the new period applies at once
        wr(A_ALARM, 32'd5);
        sampling_continues("FIX-1w offset 5", 8);
        wait_rtc_parked();
        wrs(A_ALARM, 32'h0000_0002, 4'b0001);
        wrs(A_ALARM, 32'h0000_0000, 4'b0010);
        wrs(A_ALARM, 32'h0000_0000, 4'b0100);
        wrs(A_ALARM, 32'h0000_0000, 4'b1000);
        rd(A_ALARM, r);
        check(r == 32'd2, "FIX-1w four byte-lane writes leave RTC_ALARM_OFFSET = 2");
        begin int g = 0; while (g < 100 && !(uut.u_rtc.state == R_WAITING && uut.u_rtc.armed_offset == 2)) begin cyc(1); g++; end
              check(uut.u_rtc.armed_offset == 2, "FIX-1w the final value is armed without waiting for the old period"); end
        sampling_continues("FIX-1w sample within the new period + 1", 3);
        // RTC-10 at wrapper level: nPOR without PRESETn
        nPOR = 1'b0; cyc(20); nPOR = 1'b1;
        cyc(3 * tick());
        rd(A_RTCDR, now);
        cyc(3 * tick());
        rd(A_RTCDR, r);
        check(r > now && now < 8, $sformatf("RTC-10w nPOR pulse: the counter restarts and runs (%0d -> %0d)", now, r));
        sampling_continues("RTC-10w nPOR pulse", 4);
        wr(A_ALARM, 32'd5);
    endtask

    // ---------------------------------------------------------------- main
    initial begin
        bit adc_only;
        adc_only = $test$plusargs("adc_only");
        if ($test$plusargs("vcd")) begin $dumpfile("sens_closure_tb.vcd"); $dumpvars(0, sens_closure_tb); end
        cyc(5); nPOR = 1'b1; cyc(2); PRESETn = 1'b1; cyc(5);
        wait_rtc_parked();
        if (!adc_only) begin
            wrp1();
            wrp2();
            wrp3();
            wrp4();
            wrp5();
        end
        adc6();
        stale();
        if (!adc_only) rtc_wrapper();
        check(n_pslverr == 0, "PSLVERR never seen");
        check(sb_err == 0 && n_pop_bad == 0, "FIFO scoreboard: every pop matched the model");
        check(max_stall <= 13, $sformatf("longest APB stall %0d PCLK <= 13", max_stall));
        check(n_stale == 0 && n_calmis == 0, $sformatf("no sample from a conversion older than its trigger, all run (%0d samples checked)", n_age_checked));
        $display("--- %0d accepted / %0d ignored triggers, %0d pushes, %0d drops, %0d simultaneous pop+push ---",
                 n_acc, n_ign, n_push, n_drop, n_rd_wr_same);
        if (adc_only)
            $display("\n=== SENS-CLO[div%0d]: %0d PASSED, %0d FAILED ===", ADC_CLK_DIV, pass_count, fail_count);
        else
            $display("\n=== SENS-CLO: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $finish;
    end

    initial begin
        #2_000_000_000;
        $display("WATCHDOG TIMEOUT");
        if ($test$plusargs("adc_only"))
            $display("\n=== SENS-CLO[div%0d]: %0d PASSED, %0d FAILED (TIMEOUT) ===", ADC_CLK_DIV, pass_count, fail_count + 1);
        else
            $display("\n=== SENS-CLO: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end
endmodule
