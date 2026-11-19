`timescale 1ns/1ps
// =============================================================================
// sar_adc_cal_tb.sv -- closure bench for the SAR ADC digital (sar_adc +
// sarlogic) with the behavioural sar_afe model:
// tests ADC-1 .. ADC-5 (ADC-5 = this bench rebuilt with -GCLK_DIV=1/2/8).
//
//   ADC-1  DC inputs for codes 0x00 0x01 0x7F 0x80 0xFE 0xFF, walking-one and
//          walking-zero codes: code == ideal code; valid is one sar_clk wide and
//          the period is 10 sar_clk back to back, 11 from idle.
//   ADC-2  Calibration against comparator offsets 0, +-10, +-40, +-75, +-120 mV
//          (inside the trim range of +-155 mV) and +-200 mV (outside it):
//          1 + 40 + 1 sar_clk, returns 0x00, trim bits follow the 7-sample
//          majority votes, and - the point of a calibration - the trim it ends
//          on cancels the offset. Then ADC-2b drives the comparator decisions
//          directly (sar_afe mode 3) to check the vote/trim logic bit by bit,
//          including the 4:3 and 3:4 majority boundaries.
//   ADC-3  cal toggled at every clock of a running conversion / calibration;
//          en dropped at every clock of a conversion and of a calibration.
//   ADC-4  rstn asserted in each of the six states (incl. mid-calibration),
//          released at eight points of the PCLK period.
//   Always on: ctlp == ~ctln, trima == ~trimb, cal_count in 0..14, comp never
//   x when sampled, every clkc pulse half a sar_clk wide and only while
//   en_co_clk is 1, result changes only on the clock edge that leaves sDone.
//
// Checks that fail because sarlogic (analog-owned RTL, not edited here) does
// something its own purpose says it should not are printed as
//   FAIL [SUSPECTED RTL BUG <id>] ...
// and counted in the summary; they are not weakened.
//
// Run:  make -C agriculture_soc_main/ADC cal      (and `make div` for ADC-5)
// Ends with "=== SAR_ADC_CAL[divN]: N PASSED, M FAILED (...) ===".
// =============================================================================
module sar_adc_cal_tb;
    parameter real TCLK    = 30.0;   // ns: PCLK
    parameter int  CLK_DIV = 4;

    localparam real TSAR = 2.0 * CLK_DIV * TCLK;      // sar_clk period (ns)
    localparam logic [2:0] S_INIT = 3'd0, S_WAIT = 3'd1, S_SAMPLE = 3'd2,
                           S_CONV = 3'd3, S_DONE = 3'd4, S_CAL = 3'd5;

    logic       clk = 1'b0, rstn = 1'b0, en = 1'b0, cal = 1'b0;
    wire        valid;
    wire  [7:0] result;

    always #(TCLK/2.0) clk = ~clk;

    sar_adc #(.CLK_DIV(CLK_DIV)) dut (
        .clk(clk), .rstn(rstn), .en(en), .cal(cal),
        .valid(valid), .result(result),
        .vinp(1'b0), .vinn(1'b0)      // the behavioural macro makes its own input
    );

    wire [2:0] st = dut.u_logic.state;

    // ------------------------------------------------------------- checking
    int pass_count = 0, fail_count = 0, bug_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) pass_count++;
        else begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction
    function automatic void bugcheck(input bit c, input string id, input string name);
        if (c) pass_count++;
        else begin
            fail_count++; bug_count++;
            $display("FAIL [%0t] [SUSPECTED RTL BUG %s] %s", $time, id, name);
        end
    endfunction

    // Ideal code for vinp - vinn = vd with trims ta/tb (see sar_afe_model.v):
    // the largest code below x, clamped to 0..255.
    function automatic int exp_code(input real vd, input int ta, input int tb);
        real x;
        int  d;
        x = 128.0 + 128.0 * (1.0 + dut.u_afe.cpar)
                  * (vd + dut.u_afe.vos - (ta - tb) * dut.u_afe.vtrim_lsb) / dut.u_afe.vref;
        if (x <= 0.0)       d = 0;
        else if (x > 255.0) d = 255;
        else begin
            d = $rtoi(x);
            if ($itor(d) == x) d = d - 1;
        end
        return d;
    endfunction
    // Differential input that puts the ideal result in the middle of code c
    // (x = c + 0.5) for the present trim and offset; far outside for the rails.
    function automatic real vd_for_code(input real x);
        int ta, tb;
        ta = dut.trima; tb = dut.trimb;
        return (x - 128.0) * dut.u_afe.vref / 128.0 - dut.u_afe.vos + (ta - tb) * dut.u_afe.vtrim_lsb;
    endfunction

    // ----------------------------------------------------------- monitors
    int n_ctl_bad = 0, n_trim_bad = 0, n_calcnt_bad = 0, n_comp_x = 0, n_comp_used = 0;
    int n_clkc = 0, n_clkc_bad = 0, n_clkc_gated = 0, n_res_bad = 0, n_state_bad = 0;
    real t_clkc_rise = 0.0, t_done_edge = -1.0;

    always @(clk) if (rstn) begin
        #0.1;
        if (rstn && dut.ctlp !== ~dut.ctln)   n_ctl_bad++;
        if (rstn && dut.trima !== ~dut.trimb) n_trim_bad++;
    end
    always @(posedge dut.sar_clk) if (rstn) begin
        if (st > S_CAL) n_state_bad++;
        if (st == S_CAL && dut.u_logic.cal_count > 4'd14) n_calcnt_bad++;
        if (st == S_CONV || (st == S_CAL && dut.u_logic.cal_itt != 4'd7)) begin
            n_comp_used++;
            if (dut.comp !== 1'b0 && dut.comp !== 1'b1) n_comp_x++;
        end
        if (st == S_DONE) t_done_edge = $realtime;
    end
    // A clkc pulse that is high when rstn falls is the ADC-CLKC defect (checked
    // by the ADC-4 bugcheck): it stays high until sar_clk next moves after the
    // release. Such a pulse is counted separately and not width-checked; every
    // other pulse must be exactly half a sar_clk period.
    bit clkc_spans_rst = 1'b0;
    int n_clkc_rst = 0;
    always @(posedge dut.clkc) begin
        t_clkc_rise = $realtime;
        clkc_spans_rst = 1'b0;
        if (rstn && dut.u_logic.en_co_clk !== 1'b1) n_clkc_gated++;
    end
    always @(negedge rstn) if (dut.clkc === 1'b1) clkc_spans_rst = 1'b1;
    always @(negedge dut.clkc) if (rstn) begin
        if (clkc_spans_rst) n_clkc_rst++;
        else begin
            n_clkc++;
            if (($realtime - t_clkc_rise) != CLK_DIV * TCLK) n_clkc_bad++;
        end
        clkc_spans_rst = 1'b0;
    end
    always @(result) if (rstn && $realtime != t_done_edge) n_res_bad++;

    // valid pulse width / conversion period (back-to-back checks)
    real t_valid_rise = 0.0, t_prev_valid_rise = 0.0, t_valid_w = 0.0;
    always @(posedge valid) begin t_prev_valid_rise = t_valid_rise; t_valid_rise = $realtime; end
    always @(negedge valid) t_valid_w = $realtime - t_valid_rise;

    // Reference model of the calibration vote, from the comparator samples
    // sarlogic sees: a trial bit is kept when the comparator read 0 in the
    // majority of its 7 samples (verilog.v:126-127, as written).
    int   ref_zeros = 0, ref_ones = 0, n_cal_comp0 = 0, n_cal_comp1 = 0;
    logic [4:0] ref_trim = 5'd0, ref_mask = 5'd0;
    always @(posedge dut.sar_clk) if (rstn) begin
        if (st == S_SAMPLE && dut.u_logic.calibrate) begin
            ref_trim = 5'd0; ref_mask = 5'b10000; ref_zeros = 0; ref_ones = 0;
        end else if (st == S_CAL) begin
            if (dut.u_logic.cal_itt == 4'd7) begin
                if (ref_zeros > ref_ones) ref_trim = ref_trim | ref_mask;
                ref_mask = ref_mask >> 1; ref_zeros = 0; ref_ones = 0;
            end else if (dut.comp === 1'b1) begin ref_ones++;  n_cal_comp1++; end
            else                            begin ref_zeros++; n_cal_comp0++; end
        end
    end

    // ADC-2b: comparator decisions scripted per trim trial and sample. In
    // sCal the model compares its live inputs, so driving vext_p/vext_n
    // (mode 3) a volt apart fixes each decision whatever the trim is.
    bit        script_on = 1'b0;
    bit [6:0]  script [5];          // [trial 0 = MSB][sample] : 1 -> comp = 1
    function automatic int trial_of(input logic [4:0] m);
        case (m)
            5'b10000: return 0; 5'b01000: return 1; 5'b00100: return 2;
            5'b00010: return 3; default:  return 4;
        endcase
    endfunction
    always @(posedge dut.sar_clk) if (rstn && script_on) begin
        #1;
        if (st == S_CAL && dut.u_logic.cal_itt < 4'd7) begin
            if (script[trial_of(dut.u_logic.trim_mask)][dut.u_logic.cal_itt]) begin
                dut.u_afe.vext_p = 1.4; dut.u_afe.vext_n = 0.4;
            end else begin
                dut.u_afe.vext_p = 0.4; dut.u_afe.vext_n = 1.4;
            end
        end
    end

    // ------------------------------------------------------------- helpers
    task automatic sar_edges(input int n);
        repeat (n) @(posedge dut.sar_clk);
        #1;
    endtask
    task automatic wait_state(input logic [2:0] s, input int max_clk, output bit ok);
        ok = 1'b0;
        for (int i = 0; i <= max_clk; i++) begin
            if (st == s) begin ok = 1'b1; break; end
            @(posedge dut.sar_clk); #1;
        end
    endtask
    task automatic wait_idle();
        bit ok;
        en = 1'b0;
        wait_state(S_WAIT, 60, ok);
        check(ok, "sarlogic returns to sWait with en low");
        sar_edges(1);
    endtask
    task automatic do_reset();
        bit ok;
        rstn = 1'b0; en = 1'b0;
        repeat (3) @(posedge clk);
        #1 rstn = 1'b1;
        wait_state(S_WAIT, 6, ok);
    endtask

    // Raise en from idle and return just after the clock edge that enters
    // sSample (t_start). en stays high.
    real t_start;
    task automatic start_hold();
        bit ok;
        @(posedge clk); #1 en = 1'b1;
        ok = 1'b0;
        for (int i = 0; i < 8 && !ok; i++) begin
            @(posedge dut.sar_clk); #1;
            ok = (st == S_SAMPLE);
        end
        check(ok, "conversion starts within one sar_clk of en");
        t_start = $realtime - 1.0;
    endtask
    // Wait for valid; dur = time from the sSample edge to valid rising.
    task automatic finish(input int max_clk, output logic [7:0] code, output real dur);
        bit ok;
        ok = 1'b0;
        for (int i = 0; i < max_clk && !ok; i++) begin
            @(posedge dut.sar_clk); #1;
            ok = (valid === 1'b1);
        end
        check(ok, "conversion completes (valid rises)");
        dur  = $realtime - 1.0 - t_start;
        code = result;
    endtask
    // One conversion with en dropped during sSample, so no back-to-back tail.
    task automatic conv_single(output logic [7:0] code, output real dur);
        start_hold();
        en = 1'b0;
        finish(60, code, dur);
        sar_edges(2);
    endtask
    // The wrapper FSM's handshake: en held until valid is seen.
    task automatic conv_handshake(output logic [7:0] code);
        int guard;
        @(posedge clk); #1 en = 1'b1;
        guard = 0;
        while (valid !== 1'b0 && guard < 4000) begin @(posedge clk); guard++; end
        while (valid !== 1'b1 && guard < 4000) begin @(posedge clk); guard++; end
        check(guard < 4000, "en/valid handshake completes");
        #2 code = result;
        @(posedge clk); #1 en = 1'b0;
        // en was still high at sDone: sarlogic ran one more conversion
        repeat (14 * 2 * CLK_DIV) @(posedge clk);
        wait_idle();
    endtask

    task automatic set_dc(input real vd);
        dut.u_afe.mode = 2; dut.u_afe.vdc = vd;
    endtask

    // ------------------------------------------------------------- ADC-1
    task automatic adc1_codes();
        logic [7:0] code;
        real        dur, vd;
        int         c, e;
        int         codes [18] = '{8'h00, 8'h01, 8'h7F, 8'h80, 8'hFE, 8'hFF,
                                   8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40,
                                   8'hFD, 8'hFB, 8'hF7, 8'hEF, 8'hDF, 8'hBF};
        $display("--- ADC-1 DC codes ---");
        foreach (codes[i]) begin
            c  = codes[i];
            vd = vd_for_code(c + 0.5);
            set_dc(vd);
            e = exp_code(vd, dut.trima, dut.trimb);
            conv_handshake(code);
            check(e == c, $sformatf("ADC-1 stimulus for code 0x%02h is the ideal input for it", c));
            check(code == c, $sformatf("ADC-1 DC %.4f V -> code 0x%02h (got 0x%02h)", vd, c, code));
            conv_single(code, dur);
            check(code == c && dur == 10.0 * TSAR,
                  $sformatf("ADC-1 single conversion: code 0x%02h in 10 sar_clk after sSample (got 0x%02h, %.1f)", c, code, dur / TSAR));
        end
        // well outside the range: clamps, no wrap
        set_dc(-1.79); conv_single(code, dur); check(code == 8'h00, "ADC-1 far below range clamps to 0x00");
        set_dc( 1.79); conv_single(code, dur); check(code >= 8'hFE, "ADC-1 far above range clamps to the top codes");
        // back to back: en held, five conversions
        set_dc(vd_for_code(8'h5A + 0.5));
        start_hold();
        repeat (5) begin @(posedge valid); #2; check(result == 8'h5A, "ADC-1 back-to-back code"); end
        check(t_valid_rise - t_prev_valid_rise == 10.0 * TSAR, "ADC-1 back-to-back period is 10 sar_clk");
        @(negedge valid); #1;
        check(t_valid_w == TSAR, "ADC-1 valid is one sar_clk wide back to back");
        wait_idle();
        // from idle: en seen in sWait on one edge, valid 11 edges after it
        @(posedge clk); #1 en = 1'b1;
        @(posedge dut.sar_clk); t_start = $realtime;
        @(posedge valid);
        check($realtime - t_start == 11.0 * TSAR - 0.0 || $realtime - t_start == 10.0 * TSAR,
              "ADC-1 from idle: valid 11 sar_clk after the edge that saw en (10 after sSample)");
        check($realtime - t_start == 10.0 * TSAR, "ADC-1 from idle: 1 (sWait) + 10 sar_clk");
        wait_idle();
    endtask

    // ------------------------------------------------------------- ADC-2
    // Trim a correct calibration would end on: the largest trima for which
    // the vinp side still wins, i.e. vos - (2*t - 31)*lsb > 0, clamped.
    function automatic int ideal_trim(input real vos);
        int t;
        t = 0;
        for (int k = 0; k <= 31; k++)
            if (vos - (2 * k - 31) * dut.u_afe.vtrim_lsb > 0.0) t = k;
        return t;
    endfunction

    task automatic cal_run(output logic [7:0] code, output real dur);
        cal = 1'b1;
        start_hold();
        en = 1'b0;
        finish(60, code, dur);
        cal = 1'b0;
        sar_edges(2);
    endtask

    task automatic adc2_one(input real vos, input bit in_range);
        logic [7:0] code, code1;
        real        dur, resid;
        int         t_act, t_id, ta, tb, e1;
        do_reset();
        set_dc(0.0);
        dut.u_afe.vos = vos;
        conv_single(code, dur);                 // a normal conversion first
        cal_run(code, dur);
        t_act = dut.u_logic.trim_val;
        t_id  = ideal_trim(vos);
        check(dur == 42.0 * TSAR, $sformatf("ADC-2 vos %.0f mV: calibration takes 1 + 40 + 1 sar_clk (%.1f)", vos * 1e3, dur / TSAR));
        check(code == 8'h00, $sformatf("ADC-2 vos %.0f mV: calibration returns 0x00", vos * 1e3));
        check(t_act == ref_trim, $sformatf("ADC-2 vos %.0f mV: trim bits follow the 7-sample majority votes (trim %0d, votes %0d)",
                                           vos * 1e3, t_act, ref_trim));
        check(dut.trima == t_act && dut.trimb == (~t_act & 5'h1F),
              $sformatf("ADC-2 vos %.0f mV: trima = trim, trimb = ~trim after calibration", vos * 1e3));
        check(t_act == 0 || t_act == 31 || in_range,
              $sformatf("ADC-2 vos %.0f mV: out-of-range offset ends on a rail (no wrap)", vos * 1e3));
        // What calibration is for: the trim cancels the comparator offset.
        resid = vos - (2 * t_act - 31) * dut.u_afe.vtrim_lsb;
        bugcheck(t_act == t_id, "ADC-CAL",
                 $sformatf("ADC-2 vos %.0f mV: final trim %0d = trim predicted from VTRIM_LSB %0d (offset left %.0f mV)",
                           vos * 1e3, t_act, t_id, resid * 1e3));
        conv_single(code1, dur);
        ta = dut.trima; tb = dut.trimb;
        e1 = exp_code(0.0, ta, tb);
        check(code1 == e1, $sformatf("ADC-2 vos %.0f mV: the next conversion uses the new trim (0x%02h, model 0x%02h)", vos * 1e3, code1, e1));
        if (in_range)
            bugcheck(code1 >= 8'd126 && code1 <= 8'd129, "ADC-CAL",
                     $sformatf("ADC-2 vos %.0f mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x%02h)", vos * 1e3, code1));
        cal_run(code, dur);                     // calibration after a calibration
        check(code == 8'h00 && dur == 42.0 * TSAR, $sformatf("ADC-2 vos %.0f mV: repeated calibration", vos * 1e3));
        cal = 1'b1; start_hold();               // back to back: en held through sDone
        @(posedge valid); @(posedge valid); #2;
        check(t_valid_rise - t_prev_valid_rise == 42.0 * TSAR, "ADC-2 back-to-back calibrations are 42 sar_clk apart");
        cal = 1'b0;
        wait_idle();
    endtask

    task automatic adc2_directed(input bit [6:0] s0, input bit [6:0] s1, input bit [6:0] s2,
                                 input bit [6:0] s3, input bit [6:0] s4, input string nm);
        logic [7:0] code, code1;
        real        dur;
        int         expt, e1, ta, tb;
        bit [6:0]   s [5];
        s = '{s0, s1, s2, s3, s4};
        expt = 0;
        foreach (s[i]) if ($countones(~s[i]) > $countones(s[i])) expt |= (16 >> i);   // majority of 0s keeps the bit
        script = s; script_on = 1'b1;
        dut.u_afe.mode = 3; dut.u_afe.vext_p = 0.9; dut.u_afe.vext_n = 0.9;
        cal_run(code, dur);
        script_on = 1'b0;
        check(dut.u_logic.trim_val == expt && code == 8'h00 && dur == 42.0 * TSAR,
              $sformatf("ADC-2b %s: trim %0d from the scripted votes (expected %0d)", nm, dut.u_logic.trim_val, expt));
        set_dc(0.05);
        conv_single(code1, dur);
        ta = dut.trima; tb = dut.trimb;
        e1 = exp_code(0.05, ta, tb);
        check(code1 == e1, $sformatf("ADC-2b %s: conversion with trim %0d reads the ideal code for that trim", nm, expt));
    endtask

    task automatic adc2_cal();
        real vos_in [9]  = '{0.0, 0.010, -0.010, 0.040, -0.040, 0.075, -0.075, 0.120, -0.120};
        real vos_out [2] = '{0.200, -0.200};
        int  c0, c1;
        $display("--- ADC-2 calibration vs comparator offset ---");
        c0 = n_cal_comp0; c1 = n_cal_comp1;
        foreach (vos_in[i])  adc2_one(vos_in[i], 1'b1);
        foreach (vos_out[i]) adc2_one(vos_out[i], 1'b0);
        // ADC-CAL as the spec words it: can the comparator read 0 in sCal at all?
        check(n_cal_comp0 > c0 && n_cal_comp1 > c1,
              $sformatf("ADC-2 the comparator read both 0 (%0d) and 1 (%0d) during calibration", n_cal_comp0 - c0, n_cal_comp1 - c1));
        dut.u_afe.vos = 0.0;
        do_reset();
        $display("--- ADC-2b scripted comparator decisions ---");
        adc2_directed(7'h00, 7'h7F, 7'h7F, 7'h7F, 7'h7F, "10000");
        adc2_directed(7'h7F, 7'h7F, 7'h00, 7'h7F, 7'h00, "00101");
        adc2_directed(7'h00, 7'h7F, 7'h00, 7'h7F, 7'h00, "10101");
        adc2_directed(7'h7F, 7'h00, 7'h7F, 7'h00, 7'h7F, "01010");
        adc2_directed(7'h00, 7'h00, 7'h00, 7'h00, 7'h7F, "11110");
        adc2_directed(7'h7F, 7'h7F, 7'h7F, 7'h7F, 7'h00, "00001");
        adc2_directed(7'h00, 7'h00, 7'h00, 7'h00, 7'h00, "11111");
        adc2_directed(7'h7F, 7'h7F, 7'h7F, 7'h7F, 7'h7F, "00000");
        // majority boundaries: four 0s of seven keeps, three drops, any order
        adc2_directed(7'b0000111, 7'b1110000, 7'b0101010, 7'b1010101, 7'b0001111, "4:3 / 3:4 votes a");
        adc2_directed(7'b0001111, 7'b0000111, 7'b1010101, 7'b0101010, 7'b1110000, "4:3 / 3:4 votes b");
        adc2_directed(7'b1000000, 7'b0111111, 7'b0000001, 7'b1111110, 7'b0010000, "6:1 / 1:6 votes");
        do_reset();
    endtask

    // ------------------------------------------------------------- ADC-3
    task automatic adc3_cal_en();
        logic [7:0] code;
        real        dur, vd;
        int         e;
        bit         ok;
        $display("--- ADC-3 cal / en changed during a conversion ---");
        vd = vd_for_code(8'hA5 + 0.5);
        // cal raised at clock k of a normal conversion: still a normal conversion
        for (int k = 0; k <= 9; k++) begin
            set_dc(vd);
            start_hold(); en = 1'b0;
            if (k > 0) sar_edges(k);
            cal = 1'b1;
            finish(60, code, dur);
            cal = 1'b0;
            check(code == 8'hA5 && dur == 10.0 * TSAR,
                  $sformatf("ADC-3 cal raised %0d sar_clk into a conversion: unaffected (0x%02h, %.1f sar_clk)", k, code, dur / TSAR));
            sar_edges(2);
        end
        check(dut.trima == 5'd16, "ADC-3 no calibration ran: trim still at its reset value");
        // cal dropped at clock k of a calibration: it still completes
        for (int k = 0; k <= 41; k++) begin
            do_reset();
            set_dc(0.0);
            cal = 1'b1;
            start_hold(); en = 1'b0;
            if (k > 0) sar_edges(k);
            cal = 1'b0;
            finish(60, code, dur);
            check(code == 8'h00 && dur == 42.0 * TSAR && dut.u_logic.trim_val == ref_trim,
                  $sformatf("ADC-3 cal dropped %0d sar_clk into a calibration: unaffected (%.1f sar_clk)", k, dur / TSAR));
            sar_edges(2);
        end
        do_reset();
        // en dropped at clock k of a conversion
        for (int k = 0; k <= 9; k++) begin
            set_dc(vd);
            start_hold();
            if (k > 0) sar_edges(k);
            en = 1'b0;
            if (k < 9) finish(60, code, dur);
            else begin @(posedge dut.sar_clk); #1; dur = $realtime - 1.0 - t_start; code = result; end
            check(valid === 1'b1 && code == 8'hA5 && dur == 10.0 * TSAR,
                  $sformatf("ADC-3 en dropped %0d sar_clk into a conversion: it completes with the right code", k));
            sar_edges(1);
            check(st == S_WAIT && valid === 1'b1 && result == 8'hA5,
                  $sformatf("ADC-3 en dropped at %0d: back in sWait, valid and result held", k));
            sar_edges(3);
            check(st == S_WAIT && valid === 1'b1, "ADC-3 idle: stays in sWait with valid held");
            set_dc(vd_for_code(8'h3C + 0.5));
            conv_single(code, dur);
            check(code == 8'h3C, "ADC-3 next conversion after an early en drop is correct");
        end
        // en dropped at clock k of a calibration
        for (int k = 0; k <= 41; k += 1) begin
            do_reset();
            set_dc(0.0);
            cal = 1'b1;
            start_hold();
            if (k > 0) sar_edges(k);
            en = 1'b0;
            if (k < 41) finish(60, code, dur);
            else begin @(posedge dut.sar_clk); #1; dur = $realtime - 1.0 - t_start; code = result; end
            cal = 1'b0;
            check(valid === 1'b1 && code == 8'h00 && dur == 42.0 * TSAR,
                  $sformatf("ADC-3 en dropped %0d sar_clk into a calibration: it completes", k));
            sar_edges(1);
            check(st == S_WAIT, "ADC-3 calibration with en dropped ends in sWait");
        end
        do_reset();
        e = 0;
    endtask

    // ------------------------------------------------------------- ADC-4
    // lowph: assert the reset in the low half of sar_clk (clkc high) instead
    // of the high half.
    task automatic reset_in(input logic [2:0] s, input bit calib, input real rel_frac, input bit lowph, input string nm);
        logic [7:0] code;
        real        dur;
        bit         ok;
        int         cx0;
        cx0 = n_comp_x;
        set_dc(vd_for_code(8'hC3 + 0.5));
        if (s == S_INIT) begin
            rstn = 1'b0; repeat (2) @(posedge clk); #1 rstn = 1'b1;
            #(TCLK * 0.3);
            ok = (st == S_INIT);
        end else if (s == S_WAIT) begin
            wait_idle(); ok = (st == S_WAIT);
        end else begin
            wait_idle();
            cal = calib;
            start_hold();
            if (s != S_DONE) en = 1'b0;
            wait_state(s, 50, ok);
            if (s == S_CAL || s == S_CONV) sar_edges(3);
            if (lowph) @(negedge dut.sar_clk);
            #(TCLK * 0.4);
        end
        check(ok && st == s, {nm, ": precondition, sarlogic in the target state"});
        rstn = 1'b0;                              // asynchronous assert
        #1;
        check(valid === 1'b0 && result == 8'h00 && st == S_INIT && dut.sar_clk === 1'b0,
              {nm, ": reset drives valid 0, result 0, state sInit, sar_clk low"});
        // en_co_clk is 0 in reset, so the comparator clock must be low. In
        // the low half of sar_clk it is not: sarlogic's `always @(clk)` block
        // (verilog.v:63-65) does not re-evaluate when only en_co_clk changes.
        if (lowph) bugcheck(dut.clkc === 1'b0, "ADC-CLKC", {nm, ": clkc low in reset (en_co_clk is 0)"});
        else       check(dut.clkc === 1'b0, {nm, ": clkc low in reset"});
        en = 1'b0; cal = 1'b0;
        repeat (2) @(posedge clk);
        #(TCLK * rel_frac) rstn = 1'b1;           // release at a chosen point of the PCLK period
        wait_state(S_WAIT, 6, ok);
        check(ok && dut.trima == 5'd16 && dut.trimb == 5'd15 && valid === 1'b0,
              {nm, ": after sInit trima 16 / trimb 15, valid 0"});
        conv_single(code, dur);
        check(code == 8'hC3 && dur == 10.0 * TSAR, {nm, ": next conversion correct"});
        check(n_comp_x == cx0, {nm, ": comp never x when sampled"});
    endtask

    task automatic adc4_resets();
        real fr [8] = '{0.05, 0.2, 0.35, 0.45, 0.55, 0.7, 0.85, 0.95};
        $display("--- ADC-4 reset in every state ---");
        foreach (fr[i]) begin
            reset_in(S_INIT,   1'b0, fr[i], 1'b0, $sformatf("ADC-4 reset in sInit, release %.2f", fr[i]));
            reset_in(S_WAIT,   1'b0, fr[i], 1'b0, $sformatf("ADC-4 reset in sWait, release %.2f", fr[i]));
            reset_in(S_SAMPLE, 1'b0, fr[i], 1'b0, $sformatf("ADC-4 reset in sSample, release %.2f", fr[i]));
            reset_in(S_CONV,   1'b0, fr[i], 1'b0, $sformatf("ADC-4 reset in sConv, release %.2f", fr[i]));
            reset_in(S_DONE,   1'b0, fr[i], 1'b0, $sformatf("ADC-4 reset in sDone, release %.2f", fr[i]));
            reset_in(S_CAL,    1'b1, fr[i], 1'b0, $sformatf("ADC-4 reset in sCal, release %.2f", fr[i]));
        end
        // the same with the reset asserted in the low half of sar_clk
        reset_in(S_WAIT,   1'b0, 0.2, 1'b1, "ADC-4 reset in sWait, sar_clk low");
        reset_in(S_SAMPLE, 1'b0, 0.2, 1'b1, "ADC-4 reset in sSample, sar_clk low");
        reset_in(S_CONV,   1'b0, 0.2, 1'b1, "ADC-4 reset in sConv, sar_clk low");
        reset_in(S_DONE,   1'b0, 0.2, 1'b1, "ADC-4 reset in sDone, sar_clk low");
        reset_in(S_CAL,    1'b1, 0.2, 1'b1, "ADC-4 reset in sCal, sar_clk low");
    endtask

    // ---------------------------------------------------------------- main
    initial begin
        bit ok;
        if ($test$plusargs("vcd")) begin
            $dumpfile("sar_adc_cal_tb.vcd");
            $dumpvars(0, sar_adc_cal_tb);
        end
        repeat (5) @(posedge clk);
        #1 rstn = 1'b1;
        wait_state(S_WAIT, 6, ok);
        check(ok && valid === 1'b0 && dut.trima == 5'd16 && dut.trimb == 5'd15,
              "reset: sWait, valid low, trima 16 / trimb 15");

        adc1_codes();
        adc2_cal();
        adc3_cal_en();
        adc4_resets();
        adc1_codes();                 // codes again after everything above

        $display("--- monitors: clkc pulses %0d (+%0d spanning a reset, ADC-CLKC), comp samples %0d ---", n_clkc, n_clkc_rst, n_comp_used);
        check(n_ctl_bad == 0,    $sformatf("ctlp == ~ctln at every clock edge (%0d bad)", n_ctl_bad));
        check(n_trim_bad == 0,   $sformatf("trima == ~trimb at every clock edge (%0d bad)", n_trim_bad));
        check(n_calcnt_bad == 0, "cal_count stays within 0..14");
        check(n_state_bad == 0,  "sarlogic state stays within sInit..sCal");
        check(n_comp_used > 0 && n_comp_x == 0, "comp never x when sarlogic samples it");
        check(n_clkc > 0 && n_clkc_bad == 0, $sformatf("every clkc pulse is half a sar_clk period (%0d wrong)", n_clkc_bad));
        check(n_clkc_gated == 0, "no clkc pulse while en_co_clk is 0");
        check(n_res_bad == 0,    $sformatf("result changes only on the clock edge leaving sDone (%0d elsewhere)", n_res_bad));

        $display("\n=== SAR_ADC_CAL[div%0d]: %0d PASSED, %0d FAILED (%0d of them suspected RTL bugs) ===",
                 CLK_DIV, pass_count, fail_count, bug_count);
        $finish;
    end

    initial begin
        #(400_000_000.0 * CLK_DIV);
        $display("WATCHDOG TIMEOUT");
        $display("\n=== SAR_ADC_CAL[div%0d]: %0d PASSED, %0d FAILED (TIMEOUT) ===", CLK_DIV, pass_count, fail_count + 1);
        $finish;
    end
endmodule
