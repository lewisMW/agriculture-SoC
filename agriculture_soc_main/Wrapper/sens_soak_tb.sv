`timescale 1ns/1ps
// =============================================================================
// sens_soak_tb.sv - WRP-6 soak of the whole sensing peripheral.
//
// One seed (+seed=N) runs until at least PERIODS (+periods=, default 2000)
// autonomous RTC triggers have fired, with alarm_offset 1..3 and constrained-
// random APB traffic on top: every register read and written, random byte
// strobes, back-to-back bursts, polling pauses, FIFO clears, manual triggers,
// calibration, RTC passthrough reads and disturbing writes (RTCMR, RTCLR,
// RTCIMSC, RTCICR, RTCCR).
//
// Checked continuously:
//   - ADC: every FIFO push equals the result of the conversion just finished
//   - FIFO: every MEASUREMENT_LO pop read equals the model's front
//   - triggers: pushes = accepted triggers - drops - pushes lost to a clear in
//     the same cycle
//   - no PSLVERR, no APB stall > 13 PCLK (agreed bound)
//   - guarantee: while polling is enabled, consecutive rtc_trig pulses are at
//     most armed_offset + 2 ticks apart (+1 tick of arm window), unless a
//     firmware access to the RTC region was in flight across the service point
//     (deferral, RTC-8) - those intervals are excluded and counted
//   - bound SVA (--assert)
// Ends with "=== SENS-SOAK[seedN]: N PASSED, M FAILED ===".
// =============================================================================
module sens_soak_tb #(
    parameter int AW = 16
);
    localparam logic [15:0]
        A_STATUS = 16'h004, A_MEAS_HI = 16'h008, A_MEAS_LO = 16'h00C,
        A_PLL    = 16'h100, A_AMUX    = 16'h104, A_TRIG    = 16'h108, A_CAL = 16'h10C,
        A_RTCDR  = 16'h200, A_RTCMR   = 16'h204, A_RTCLR   = 16'h208, A_RTCCR = 16'h20C,
        A_RTCIMSC= 16'h210, A_RTCRIS  = 16'h214, A_RTCMIS  = 16'h218, A_RTCICR = 16'h21C,
        A_FCLR   = 16'h220, A_ALARM   = 16'h224, A_RTCCTRL = 16'h228;
    localparam logic [2:0] F_IDLE = 3'd0, F_ERR = 3'd6;
    localparam logic [4:0] R_MATCH_SETUP = 5'd6;
    localparam int TICK_HALF = 80;                 // CLK1HZ period 160 PCLK

    logic          PCLK = 1'b0, CLK1HZ = 1'b0, PRESETn = 1'b0, nPOR = 1'b0;
    logic          PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
    logic [AW-1:0] PADDR = '0;
    logic [31:0]   PWDATA = '0;
    logic [3:0]    PSTRB = 4'h0;
    wire  [31:0]   PRDATA;
    wire           PREADY, PSLVERR;

    adc_apb_wrapper_rev2 #(.ADDR_WIDTH(AW), .DEFAULT_ALARM_OFFSET(32'd2)) uut (
        .PCLK(PCLK), .CLK1HZ(CLK1HZ), .PRESETn(PRESETn), .nPOR(nPOR),
        .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .APBACTIVE(1'b1), .PPROT(3'b001), .PSTRB(PSTRB),
        .ADC_VINP(1'b0), .ADC_VINN(1'b0));

    always #5 PCLK = ~PCLK;
    int unsigned c1_cnt = 0;
    always @(negedge PCLK) begin
        if (c1_cnt + 1 >= TICK_HALF) begin CLK1HZ <= ~CLK1HZ; c1_cnt <= 0; end
        else c1_cnt <= c1_cnt + 1;
    end

    int pass_count = 0, fail_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) pass_count++;
        else begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction

    // ------------------------------------------------------- scoreboards
    logic [7:0] adc_q[$];
    logic [7:0] fq[$];
    int unsigned n_push = 0, n_drop = 0, n_acc = 0, n_ign = 0, n_clear_push = 0;
    int unsigned n_rtc_trig = 0, n_adc_bad = 0, n_pop_bad = 0, n_pop = 0, n_pslverr = 0;
    int unsigned stall_run = 0, max_stall = 0, n_xfer = 0, n_b2b = 0;
    logic adc_en_q = 1'b0;
    realtime t_raw_rise = 0, t_raw_fall = 0, t_en_rise = 0, t_en_fall = 0;
    always @(posedge uut.adc_raw_valid) if (PRESETn) begin t_raw_rise = $realtime; #0.1; adc_q.push_back(uut.adc_result); end
    always @(negedge uut.adc_raw_valid) t_raw_fall = $realtime;
    // event trace in a window (+trace_from=<ns> +trace_to=<ns>)
    longint unsigned tr_from = 0, tr_to = 0;
    initial begin if ($value$plusargs("trace_from=%d", tr_from)) ; if ($value$plusargs("trace_to=%d", tr_to)) ; end
    always @(posedge PCLK) if ($time >= tr_from && $time <= tr_to)
        $display("TRACE %0t fsm=%0d en=%b raw_valid=%b sync=%b sar_state=%0d trig=%b/%b | APB sel=%b en=%b wr=%b a=%h strb=%h rdy=%b | rtc st=%0d ext=%b psel=%b pen=%b pa=%0d setup_done=%b",
                 $time, uut.u_ctrl.state, uut.adc_en, uut.adc_raw_valid, uut.adc_valid_s2,
                 uut.u_adc.u_logic.state, uut.rtc_trig, uut.manual_trig,
                 PSEL, PENABLE, PWRITE, PADDR, PSTRB, PREADY,
                 uut.u_rtc.state, uut.u_rtc.ext_sel, uut.u_rtc.rtc_psel, uut.u_rtc.rtc_penable, uut.u_rtc.rtc_paddr, uut.u_rtc.pt_setup_done);
    always @(posedge uut.adc_en) t_en_rise = $realtime;
    always @(negedge uut.adc_en) t_en_fall = $realtime;
    always @(posedge PCLK) begin
        if (!PRESETn) begin fq.delete(); adc_q.delete(); adc_en_q <= 1'b0; end
        else begin
            adc_en_q <= uut.adc_en;
            if (uut.adc_en && !adc_en_q) adc_q.delete();
            if (uut.rtc_trig) n_rtc_trig++;
            if (uut.sample_trig) begin if (uut.u_ctrl.state == F_IDLE) n_acc++; else n_ign++; end
            if (uut.u_ctrl.state == F_ERR) n_drop++;
            if (uut.fifo_write_en) begin
                if (adc_q.size() == 0) begin
                    n_adc_bad++;
                    $display("FAIL [%0t] push with no finished conversion (en rose %0t fell %0t; raw valid rose %0t fell %0t; cal %b)",
                             $time, t_en_rise, t_en_fall, t_raw_rise, t_raw_fall, uut.cal_reg);
                end
                else begin
                    logic [7:0] e;
                    e = adc_q[$];
                    adc_q.delete();
                    if (uut.adc_sample !== e) begin
                        n_adc_bad++;
                        $display("FAIL [%0t] push 0x%02h != conversion result 0x%02h", $time, uut.adc_sample, e);
                    end
                end
            end
            if (uut.fifo_clear) begin
                if (uut.fifo_write_en && !uut.fifo_full) n_clear_push++;
                fq.delete();
            end else begin
                if (uut.fifo_rd_en && !uut.fifo_empty) begin void'(fq.pop_front()); n_pop++; end
                if (uut.fifo_write_en && !uut.fifo_full) begin fq.push_back(uut.adc_sample); n_push++; end
            end
            if (PSEL && PENABLE && PREADY && PSLVERR) n_pslverr++;
            if (PSEL && PENABLE && PREADY) n_xfer++;
            stall_run = (PSEL && PENABLE && !PREADY) ? stall_run + 1 : 0;
            if (stall_run > max_stall) max_stall = stall_run;
            if (stall_run == 14) $display("LONGSTALL [%0t] addr %h", $time, PADDR);
        end
    end


    // conversion age: a pushed sample's conversion started at or after the
    // trigger the FSM accepted, with that trigger's ADC_CAL (bug FSM-STALE)
    realtime conv_start_t = 0, done_start_t = 0, last_start_t = 0, t_acc = 0;
    bit      conv_cal = 0, done_cal = 0, last_cal = 0, acc_cal = 0;
    logic [2:0] sar_st_q = 3'd0;
    int unsigned n_stale = 0, n_calmis = 0, n_cal_checked = 0;
    bit cal_moved = 1'b0;      // ADC_CAL written to a new value since the accepted trigger
    always @(posedge PCLK) begin
        if (PRESETn && uut.cal_reg != acc_cal) cal_moved = 1'b1;
        sar_st_q <= uut.u_adc.u_logic.state;
        if (uut.u_adc.u_logic.state == 3'd2 && sar_st_q != 3'd2) begin conv_start_t = $realtime; conv_cal = uut.u_adc.u_logic.calibrate; end
        if (uut.u_adc.u_logic.state == 3'd4 && sar_st_q != 3'd4) begin done_start_t = conv_start_t; done_cal = conv_cal; end
        if (PRESETn && uut.sample_trig && uut.u_ctrl.state == F_IDLE) begin t_acc = $realtime; acc_cal = uut.cal_reg; cal_moved = 1'b0; end
        if (PRESETn && uut.fifo_write_en) begin
            if (!cal_moved) n_cal_checked++;
            if (last_start_t < t_acc) begin n_stale++; if (n_stale <= 3) $display("FAIL [%0t] stale sample (conversion %0t, trigger %0t)", $time, last_start_t, t_acc); end
            if (!cal_moved && last_cal != acc_cal) begin n_calmis++; if (n_calmis <= 3) $display("FAIL [%0t] sample cal=%b, ADC_CAL at the trigger %b", $time, last_cal, acc_cal); end
        end
    end
    always @(posedge uut.adc_raw_valid) begin last_start_t = done_start_t; last_cal = done_cal; end

    // guarantee monitor (ticks)
    int unsigned tick_count = 0;
    always @(posedge CLK1HZ) tick_count <= tick_count + 1;
    int unsigned g_last_tick = 0, g_arm_off = 1, g_bad = 0, g_gaps = 0, g_excl = 0, g_max = 0;
    bit          g_valid = 1'b0, g_dirty = 1'b0;
    logic [4:0]  rtc_st_q = 5'd0;             // WAITING -> READ_SETUP = an offset re-arm (FIX-1)
    always @(posedge PCLK) rtc_st_q <= uut.u_rtc.state;
    always @(posedge PCLK) begin
        if (uut.u_rtc.state == R_MATCH_SETUP) g_arm_off <= uut.u_rtc.armed_offset;
        // a pause, or a firmware RTC-region access while an alarm is due,
        // makes the current interval not subject to the bound
        // FIX-1: an offset change re-arms from now, i.e. starts a new interval
        if (!uut.poll_enable_reg || (uut.u_rtc.ext_sel && (uut.u_rtc.RTCINTR || uut.u_rtc.wd_expired)) ||
            (uut.u_rtc.state == 5'd3 && rtc_st_q == 5'd10))
            g_dirty <= 1'b1;
        if (!PRESETn) g_valid <= 1'b0;
        else if (uut.rtc_trig) begin
            int unsigned tg;
            tg = tick_count - g_last_tick;
            if (g_valid) begin
                if (g_dirty) g_excl++;
                else begin
                    g_gaps++;
                    if (tg > g_max) g_max = tg;
                    if (tg > g_arm_off + 2) begin
                        g_bad++;
                        $display("FAIL [%0t] guarantee: %0d ticks between rtc_trig, armed_offset %0d", $time, tg, g_arm_off);
                    end
                end
            end
            g_valid <= 1'b1; g_dirty <= 1'b0;
            g_last_tick <= tick_count;
        end
    end

    // ----------------------------------------------------------- APB master
    bit          keep_sel = 1'b0;     // back-to-back: next transfer has no idle cycle
    task automatic xfer(input bit wr, input logic [AW-1:0] a, input logic [31:0] d, input logic [3:0] strb,
                        output logic [31:0] r);
        int unsigned st = 0;
        logic [7:0] exp_v;
        bit         is_pop;
        if (keep_sel && PSEL) n_b2b++;
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE = wr; PADDR = a; PWDATA = wr ? d : 32'h0; PSTRB = wr ? strb : 4'h0;
        @(posedge PCLK); #1;
        PENABLE = 1'b1;
        forever begin
            @(negedge PCLK);
            if (PREADY) break;
            st++;
            if (st > 500) begin check(1'b0, "APB transfer completes"); break; end
        end
        r = PRDATA;
        is_pop = !wr && a == A_MEAS_LO;
        if (is_pop) begin
            exp_v = (fq.size() == 0) ? 8'h00 : fq[0];
            if (r !== {24'h0, exp_v}) begin
                n_pop_bad++;
                $display("FAIL [%0t] pop read 0x%08h, model 0x%02h", $time, r, exp_v);
            end
        end
        @(posedge PCLK); #1;
        if (!keep_sel) begin PSEL = 1'b0; PWRITE = 1'b0; end
        PENABLE = 1'b0; PSTRB = 4'h0;
    endtask

    function automatic logic [3:0] rand_strb();
        case ($urandom_range(0, 9))
            0: return 4'b0001; 1: return 4'b0010; 2: return 4'b0100; 3: return 4'b1000;
            4: return 4'b0011; 5: return 4'b1100; 6: return 4'b0000;
            default: return 4'b1111;
        endcase
    endfunction

    // One random operation (possibly a back-to-back burst).
    int unsigned n_op [16];
    task automatic random_op();
        logic [31:0] r, now;
        int unsigned k = $urandom_range(0, 99);
        int unsigned burst = ($urandom_range(0, 9) == 0) ? $urandom_range(2, 4) : 1;
        for (int b = 0; b < burst; b++) begin
            keep_sel = (b + 1 < burst);
            if      (k < 18) begin n_op[0]++;  xfer(1'b0, A_STATUS, 0, 0, r); if (r[31:7] != 0) check(1'b0, "STATUS[31:7] == 0"); end
            else if (k < 34) begin n_op[1]++;  xfer(1'b0, A_MEAS_LO, 0, 0, r); end
            else if (k < 37) begin n_op[2]++;  xfer(1'b0, A_MEAS_HI, 0, 0, r); if (r != 0) check(1'b0, "MEASUREMENT_HI == 0"); end
            else if (k < 42) begin n_op[3]++;  xfer(1'b1, A_PLL, $urandom, rand_strb(), r); end
            else if (k < 47) begin n_op[4]++;  xfer(1'b1, A_AMUX, $urandom, rand_strb(), r); end
            else if (k < 52) begin n_op[5]++;  xfer(1'b1, A_TRIG, 32'h1, ($urandom_range(0, 4) == 0) ? rand_strb() : 4'hF, r); end
            else if (k < 55) begin n_op[6]++;  xfer(1'b1, A_CAL, ($urandom_range(0, 3) == 0), 4'hF, r); end
            else if (k < 58) begin n_op[7]++;  xfer(1'b1, A_FCLR, $urandom, rand_strb(), r); end
            else if (k < 61) begin n_op[8]++;  xfer(1'b1, A_ALARM, $urandom_range(1, 3), ($urandom_range(0, 3) == 0) ? 4'b0001 : 4'hF, r); end
            else if (k < 64) begin n_op[9]++;  xfer(1'b1, A_RTCCTRL, $urandom_range(0, 4) != 0, 4'hF, r); end
            else if (k < 76) begin n_op[10]++; xfer(1'b0, 16'h200 + 4 * $urandom_range(0, 7), 0, 0, r); end
            else if (k < 80) begin n_op[11]++; xfer(1'b0, {$urandom_range(0, 3), 2'b00} | 16'h100, 0, 0, r); end
            else if (k < 83) begin                                     // unmapped
                logic [15:0] un [5] = '{16'h000, 16'h010, 16'h110, 16'h22C, 16'hFFC};
                n_op[12]++;
                xfer($urandom_range(0, 1), un[$urandom_range(0, 4)], $urandom, 4'hF, r);
            end
            else if (k < 86) begin n_op[13]++; xfer(1'b1, A_RTCIMSC, $urandom_range(0, 1), 4'hF, r); end
            else if (k < 89) begin n_op[14]++; xfer(1'b1, A_RTCICR, $urandom_range(0, 1), rand_strb(), r); end
            else if (k < 92) begin                                     // RTCMR near now / in the past
                n_op[15]++;
                keep_sel = 1'b0;
                xfer(1'b0, A_RTCDR, 0, 0, now);
                xfer(1'b1, A_RTCMR, now + $urandom_range(0, 4) - 2, 4'hF, r);
            end
            else if (k < 94) begin                                     // RTCLR small jump
                keep_sel = 1'b0;
                xfer(1'b0, A_RTCDR, 0, 0, now);
                xfer(1'b1, A_RTCLR, now + $urandom_range(0, 10) - 5, 4'hF, r);
            end
            else if (k < 95) xfer(1'b1, A_RTCCR, 32'h1, 4'hF, r);
            else begin
                // idle: a transfer left open for back-to-back must not turn into a
                // SETUP with no ACCESS (APB master rule) - close the bus first
                keep_sel = 1'b0; PSEL = 1'b0; PWRITE = 1'b0;
                repeat ($urandom_range(1, 60)) @(posedge PCLK); #1;
            end
        end
        keep_sel = 1'b0;
        if (PSEL) begin @(posedge PCLK); #1; PSEL = 1'b0; end
    endtask

    initial begin
        int unsigned seed = 1, periods = 2000;
        int unsigned iter = 0;
        logic [31:0] r;
        if ($value$plusargs("seed=%d", seed)) ;
        if ($value$plusargs("periods=%d", periods)) ;
        void'($urandom(seed));
        repeat (5) @(posedge PCLK); #1 nPOR = 1'b1;
        repeat (2) @(posedge PCLK); #1 PRESETn = 1'b1;
        repeat (20) @(posedge PCLK); #1;
        while (n_rtc_trig < periods && iter < 400_000) begin
            random_op();
            // idle time between operations keeps the bus mostly free
            repeat ($urandom_range(0, 20)) @(posedge PCLK); #1;
            iter++;
        end
        // settle: pause polling, let any conversion finish, drain through the bus
        xfer(1'b1, A_RTCCTRL, 32'h0, 4'hF, r);
        repeat (3000) @(posedge PCLK); #1;
        while (fq.size() > 0) xfer(1'b0, A_MEAS_LO, 0, 0, r);
        repeat (10) @(posedge PCLK); #1;

        check(n_rtc_trig >= periods, $sformatf("soak: %0d autonomous periods (>= %0d)", n_rtc_trig, periods));
        check(n_adc_bad == 0, "soak: every FIFO push is that conversion's result");
        check(n_pop_bad == 0, $sformatf("soak: every pop matches the scoreboard (%0d pops)", n_pop));
        check(n_push + n_clear_push == n_acc - n_drop || (n_push + n_clear_push + 1 == n_acc - n_drop && uut.u_ctrl.state != F_IDLE),
              $sformatf("soak: samples = accepted triggers - drops (%0d + %0d lost to clear, %0d accepted, %0d drops)",
                        n_push, n_clear_push, n_acc, n_drop));
        check(n_stale == 0 && n_calmis == 0, $sformatf("soak: no sample older than its trigger (%0d stale); ADC_CAL honoured when unchanged since the trigger (%0d checked, %0d wrong)", n_stale, n_cal_checked, n_calmis));
        check(n_pslverr == 0, "soak: no PSLVERR");
        check(max_stall <= 13, $sformatf("soak: longest stall %0d PCLK <= 13", max_stall));
        check(g_bad == 0, $sformatf("soak: guarantee held on %0d clean intervals (longest %0d ticks; %0d excluded)", g_gaps, g_max, g_excl));
        check(uut.u_fifo.count == 0 && fq.size() == 0, "soak: FIFO drained, model agrees");
        $display("--- seed %0d: %0d ops, %0d transfers (%0d back-to-back), %0d RTC triggers, %0d accepted / %0d ignored, %0d pushes, %0d drops, longest stall %0d ---",
                 seed, iter, n_xfer, n_b2b, n_rtc_trig, n_acc, n_ign, n_push, n_drop, max_stall);
        $display("\n=== SENS-SOAK[seed%0d]: %0d PASSED, %0d FAILED ===", seed, pass_count, fail_count);
        $finish;
    end

    initial begin
        int unsigned seed = 1;
        if ($value$plusargs("seed=%d", seed)) ;
        #3_000_000_000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== SENS-SOAK[seed%0d]: %0d PASSED, %0d FAILED (TIMEOUT) ===", seed, pass_count, fail_count + 1);
        $finish;
    end
endmodule
