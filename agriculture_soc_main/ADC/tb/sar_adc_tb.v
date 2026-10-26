`timescale 1ns/1ps
// =============================================================================
// sar_adc_tb.v -- self-checking RTL testbench of sar_adc with the behavioural
// sar_afe model (ADC/sim/sar_afe_model.v).
//
//   1. DC inputs across the range: every code equals the ideal SAR code.
//   2. Slow full-scale ramp, en held high (sarlogic's back-to-back mode):
//      every code ideal, monotonic, no missing codes; a conversion every
//      10 sar_clk, valid high for one sar_clk.
//   3. Sine (sar_ams_shim's stimulus, 5 kHz, +/-0.4 V per side): every code
//      ideal and the codes span the input.
//   4. The wrapper's handshake: the real wrapper_control_2 FSM plus a copy of
//      adc_apb_wrapper_rev2's 3-flop valid synchroniser and result capture,
//      300 randomly spaced triggers. One FIFO write per trigger, each holding
//      the result of a complete, correct conversion, within a latency bound.
//   5. Calibration: cal = 1 runs sCal (sample held for 1 + 40 sar_clk) and
//      returns valid with code 0x00 and a new trim, which the next conversion
//      uses. The trim the loop settles on is reported.
//   Throughout: every conversion's code is checked against the input the
//   macro held for it, every clkc pulse is exactly half a sar_clk period, and
//   comp is never x when sarlogic samples it.
//
// Run from the repo root:
//   iverilog -g2005 -o sar_adc_tb.vvp -f agriculture_soc_main/ADC/tb/sar_adc_tb.f && vvp sar_adc_tb.vvp
//   xrun -f agriculture_soc_main/ADC/tb/sar_adc_tb.f
// Ends with "=== SAR_ADC_TB: N PASSED, M FAILED ===".
// =============================================================================
module sar_adc_tb;
    parameter real TCLK    = 30.0;  // ns: the chip's PCLK (33.3 MHz)
    parameter      CLK_DIV = 4;

    localparam real TSAR = 2.0 * CLK_DIV * TCLK;   // sar_clk period (ns)
    localparam [2:0] S_SAMPLE = 3'd2, S_CONV = 3'd3, S_CAL = 3'd5;  // sarlogic state codes

    reg        clk = 1'b0, rstn = 1'b0, en_tb = 1'b0, cal = 1'b0;
    reg        use_fsm = 1'b0;
    wire       valid;
    wire [7:0] result;
    wire       fsm_adc_en;
    wire       en = use_fsm ? fsm_adc_en : en_tb;

    integer pass_count = 0, fail_count = 0;

    always #(TCLK/2.0) clk = ~clk;

    sar_adc #(.CLK_DIV(CLK_DIV)) dut (
        .clk    (clk),
        .rstn   (rstn),
        .en     (en),
        .cal    (cal),
        .valid  (valid),
        .result (result),
        .vinp   (1'b0),        // the behavioural macro makes its own input
        .vinn   (1'b0)
    );

    // -------------------------------------------------------------------------
    // Copy of adc_apb_wrapper_rev2's ADC handshake: wrapper_control_2, the
    // 3-flop valid synchroniser and the capture on the synchronised rising edge.
    // -------------------------------------------------------------------------
    reg        trig = 1'b0;
    wire       fifo_write_en, err_fifo_full;
    reg        adc_valid_s1, adc_valid_s2, adc_valid_s3;
    reg  [7:0] adc_sample;
    wire       adc_valid_sync = adc_valid_s2;
    wire       adc_valid_rise = adc_valid_s2 & ~adc_valid_s3;

    always @(posedge clk or negedge rstn)
        if (!rstn) {adc_valid_s1, adc_valid_s2, adc_valid_s3} <= 3'b000;
        else begin
            adc_valid_s1 <= valid;
            adc_valid_s2 <= adc_valid_s1;
            adc_valid_s3 <= adc_valid_s2;
        end

    always @(posedge clk or negedge rstn)
        if (!rstn)               adc_sample <= 8'h00;
        else if (adc_valid_rise) adc_sample <= result;

    wrapper_control_2 u_ctrl (
        .clk           (clk),
        .rstn          (rstn),
        .sample_trig   (trig),
        .fifo_full     (1'b0),
        .fifo_write_en (fifo_write_en),
        .adc_en        (fsm_adc_en),
        .adc_valid     (adc_valid_sync),
        .err_fifo_full (err_fifo_full)
    );

    // -------------------------------------------------------------------------
    // Checks
    // -------------------------------------------------------------------------
    task check;
        input            cond;
        input [8*80-1:0] name;
        begin
            if (cond) pass_count = pass_count + 1;
            else begin
                fail_count = fail_count + 1;
                $display("FAIL [%0t] %0s", $time, name);
            end
        end
    endtask

    // Ideal code for vinp - vinn = vd at trims ta/tb: the largest code below
    // x (see sar_afe_model.v). Sets exp_edge when x lies within 1e-6 LSB of a
    // code boundary, where the model's float compare may round the other way.
    reg exp_edge;
    function integer exp_code;
        input real    vd;
        input integer ta, tb;
        real    x;
        integer d;
        begin
            x = 128.0 + 128.0 * (1.0 + dut.u_afe.cpar)
                      * (vd + dut.u_afe.vos - (ta - tb) * dut.u_afe.vtrim_lsb) / dut.u_afe.vref;
            if (x <= 0.0)       d = 0;
            else if (x > 255.0) d = 255;
            else begin
                d = $rtoi(x);
                if ($itor(d) == x) d = d - 1;
            end
            exp_edge = ((x - $floor(x + 0.5)) < 1.0e-6) && ((x - $floor(x + 0.5)) > -1.0e-6);
            exp_code = d;
        end
    endfunction

    // Every completed conversion: compare with the ideal code of the input the
    // macro held for it. At valid's rising edge the next conversion (back to
    // back) is still sampling, so the model still holds this one's input.
    integer    n_conv = 0, n_conv_bad = 0, cur_exp;
    real       last_vd, last_hold_t;
    reg  [7:0] last_res;
    reg        last_ok = 1'b0;
    real       t_valid_rise = 0.0, t_prev_valid_rise, t_last_period = 0.0, t_valid_w = 0.0;
    real       t_hold = 0.0;                        // time the switches last opened
    reg        conv_is_cal = 1'b0;                  // the running conversion is a calibration

    always @(negedge dut.sample) t_hold = $realtime;
    always @(posedge dut.sar_clk) if (dut.u_logic.state == S_SAMPLE) conv_is_cal <= dut.u_logic.calibrate;

    always @(posedge valid) begin
        t_prev_valid_rise = t_valid_rise;
        t_valid_rise      = $realtime;
        t_last_period     = t_valid_rise - t_prev_valid_rise;
        #1;
        last_res    = result;
        last_hold_t = t_hold;
        last_vd     = dut.u_afe.vsp - dut.u_afe.vsn;
        cur_exp     = exp_code(last_vd, dut.trima, dut.trimb);
        last_ok     = (result == cur_exp) || (exp_edge && (result == cur_exp + 1 || result == cur_exp - 1));
        n_conv      = n_conv + 1;
        if (!conv_is_cal) begin                      // calibrations return 0x00 (checked in 5)
            check(last_ok, "conversion result equals the ideal SAR code");
            if (!last_ok) begin
                n_conv_bad = n_conv_bad + 1;
                if (n_conv_bad <= 10)
                    $display("    code 0x%02h, expected 0x%02h (vinp-vinn %.6f V, trima %0d, trimb %0d)",
                             result, cur_exp, last_vd, dut.trima, dut.trimb);
            end
        end
    end

    always @(negedge valid) t_valid_w = $realtime - t_valid_rise;

    // clkc pulses: exactly half a sar_clk period (no runts, no glitches)
    real    t_clkc_rise = 0.0;
    integer n_clkc = 0, n_clkc_bad = 0;
    always @(posedge dut.clkc) t_clkc_rise = $realtime;
    always @(negedge dut.clkc) if (rstn) begin
        n_clkc = n_clkc + 1;
        if (($realtime - t_clkc_rise) != CLK_DIV * TCLK) begin
            n_clkc_bad = n_clkc_bad + 1;
            if (n_clkc_bad <= 5)
                $display("FAIL [%0t] clkc pulse %.3f ns wide, expected %.3f",
                         $time, $realtime - t_clkc_rise, CLK_DIV * TCLK);
        end
    end

    // comp must be 0/1 whenever sarlogic uses it
    integer n_comp_x = 0, n_comp_used = 0;
    always @(posedge dut.sar_clk) if (rstn)
        if (dut.u_logic.state == S_CONV || dut.u_logic.state == S_CAL) begin
            n_comp_used = n_comp_used + 1;
            if (dut.comp !== 1'b0 && dut.comp !== 1'b1) n_comp_x = n_comp_x + 1;
        end

    // -------------------------------------------------------------------------
    // Direct handshake, as wrapper_control_2 does it: en high, wait for valid
    // low (started) then high (done), drop en. With en still high at sDone,
    // sarlogic starts one more conversion; wait_tail lets it finish.
    // -------------------------------------------------------------------------
    integer guard;
    task convert_once;
        output [7:0] code;
        begin
            @(posedge clk); en_tb = 1'b1;
            guard = 0;
            while (valid !== 1'b0 && guard < 4000) begin @(posedge clk); guard = guard + 1; end
            while (valid !== 1'b1 && guard < 4000) begin @(posedge clk); guard = guard + 1; end
            check(guard < 4000, "conversion handshake completes");
            #2 code = result;
            @(posedge clk); en_tb = 1'b0;
        end
    endtask

    task wait_tail;                 // idle for n sar_clk periods
        input integer n;
        begin repeat (n * 2 * CLK_DIV) @(posedge clk); end
    endtask

    // -------------------------------------------------------------------------
    // FSM mode (section 4): each FIFO write must hold the last completed result
    // -------------------------------------------------------------------------
    integer n_trig, n_wr, n_stale, max_lat, lat;
    real    t_trig;
    always @(posedge clk) if (use_fsm && fifo_write_en) begin
        n_wr = n_wr + 1;
        lat  = ($realtime - t_trig) / TCLK;
        if (lat > max_lat) max_lat = lat;
        check((adc_sample == last_res) && last_ok, "FIFO write holds the last complete, correct conversion");
        if (last_hold_t < t_trig) n_stale = n_stale + 1;
    end

    // -------------------------------------------------------------------------
    // Stimulus
    // -------------------------------------------------------------------------
    integer    i, k, seed, code_i, n_missing, n_nonmono, prev_code;
    integer    seen [0:255];
    integer    trim_cal, ta_i, tb_i;
    reg  [7:0] code, code0, code1, cmin, cmax, emin, emax, code_e;
    real       vds [0:11];
    real       t0, t_samp_rise, t_samp_fall, resid_mv;

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("sar_adc_tb.vcd");
            $dumpvars(0, sar_adc_tb);
        end

        // ---- reset ----
        repeat (5) @(posedge clk);
        rstn = 1'b1;
        wait_tail(3);
        check(valid === 1'b0, "valid low after reset");
        check(dut.trima == 5'd16 && dut.trimb == 5'd15, "reset trim: trima 16, trimb 15");

        // ---- 1. DC inputs ----
        $display("--- 1. DC inputs ---");
        dut.u_afe.mode = 2;
        vds[0] = -1.75;  vds[1] = -0.8;   vds[2] = -0.3;   vds[3] = -0.02;
        vds[4] =  0.0;   vds[5] =  0.004; vds[6] =  0.006; vds[7] =  0.1;
        vds[8] =  0.3;   vds[9] =  0.8;   vds[10] = 1.2;   vds[11] = 1.79;
        for (i = 0; i < 12; i = i + 1) begin
            dut.u_afe.vdc = vds[i];
            convert_once(code);
            wait_tail(12);
            code_i = exp_code(vds[i], 16, 15);
            $display("    vinp-vinn %8.4f V -> code 0x%02h (%3d), ideal %3d", vds[i], code, code, code_i);
            check(code == code_i, "DC code equals the ideal code");
        end

        // ---- 2. ramp, back to back ----
        $display("--- 2. full-scale ramp, en held high (back-to-back conversions) ---");
        for (k = 0; k < 256; k = k + 1) seen[k] = 0;
        t0 = $realtime;
        dut.u_afe.ramp_lo = -1.85;
        dut.u_afe.ramp_hi =  1.85;
        dut.u_afe.ramp_t  = 2.0e-3;           // ~830 conversions, ~3 per code
        dut.u_afe.ramp_t0 = t0 * 1.0e-9;
        dut.u_afe.mode    = 1;
        n_conv = 0; prev_code = -1; n_nonmono = 0;
        @(posedge clk); en_tb = 1'b1;
        while ($realtime < t0 + 2.0e6 - 3.0 * 10.0 * TSAR) begin   // stop before the wrap
            @(posedge valid); #2;
            seen[result] = seen[result] + 1;
            if (prev_code >= 0 && result < prev_code) n_nonmono = n_nonmono + 1;
            prev_code = result;
        end
        check(t_last_period == 10.0 * TSAR, "back-to-back conversion period is 10 sar_clk");
        @(negedge valid); #1;
        check(t_valid_w == TSAR, "valid is high for one sar_clk in back-to-back mode");
        @(posedge clk); en_tb = 1'b0;
        wait_tail(12);
        n_missing = 0;
        for (k = 1; k < 255; k = k + 1) if (seen[k] == 0) n_missing = n_missing + 1;
        $display("    %0d conversions, period %.0f ns (%.1f sar_clk), valid high %.0f ns (%.1f sar_clk)",
                 n_conv, t_last_period, t_last_period / TSAR, t_valid_w, t_valid_w / TSAR);
        $display("    codes 1..254 missing: %0d, non-monotonic steps: %0d, code 0x00 x%0d, 0xff x%0d",
                 n_missing, n_nonmono, seen[0], seen[255]);
        check(n_missing == 0, "ramp: no missing codes");
        check(n_nonmono == 0, "ramp: codes monotonic");
        check(seen[0] > 0 && seen[255] > 0, "ramp: reaches both ends of the range");

        // ---- 3. sine (sar_ams_shim's stimulus) ----
        $display("--- 3. sine, 5 kHz, VCM 0.9 V +/- 0.4 V per side ---");
        dut.u_afe.mode = 0;
        n_conv = 0; cmin = 255; cmax = 0;
        t0 = $realtime;
        @(posedge clk); en_tb = 1'b1;
        while ($realtime < t0 + 210.0e3) begin     // > one 200 us period
            @(posedge valid); #2;
            if (result < cmin) cmin = result;
            if (result > cmax) cmax = result;
        end
        @(posedge clk); en_tb = 1'b0;
        wait_tail(12);
        emin = exp_code(-0.8, 16, 15);
        emax = exp_code(0.8, 16, 15);
        $display("    %0d conversions, codes 0x%02h..0x%02h (ideal extremes 0x%02h..0x%02h)",
                 n_conv, cmin, cmax, emin, emax);
        check(cmin <= emin + 1 && cmax + 1 >= emax, "sine: codes span the input range");

        // ---- 4. the wrapper's handshake with random triggers ----
        $display("--- 4. wrapper_control_2 handshake, 300 random triggers ---");
        use_fsm = 1'b1; n_trig = 0; n_wr = 0; n_stale = 0; max_lat = 0;
        seed = 32'h5eed;
        for (i = 0; i < 300; i = i + 1) begin
            // spacing 1..400 clk: inside and outside the back-to-back tail
            repeat (1 + ({$random(seed)} % 400)) @(posedge clk);
            while (u_ctrl.state != 3'd0) @(posedge clk);  // FSM idle, as the trigger sources require
            #1 trig = 1'b1; t_trig = $realtime; n_trig = n_trig + 1;
            @(posedge clk); #1 trig = 1'b0;
        end
        guard = 0;
        while (u_ctrl.state != 3'd0 && guard < 5000) begin @(posedge clk); guard = guard + 1; end
        wait_tail(12);
        $display("    %0d triggers, %0d FIFO writes, max trigger->write latency %0d clk, %0d samples held before their trigger",
                 n_trig, n_wr, max_lat, n_stale);
        check(n_wr == n_trig, "one FIFO write per trigger");
        check(max_lat <= 2 * 11 * 2 * CLK_DIV + 12, "trigger->write latency within two conversions");
        check(err_fifo_full == 1'b0, "no FIFO-full error");
        use_fsm = 1'b0;

        // ---- 5. calibration ----
        $display("--- 5. calibration (cal = 1), inputs shorted, comparator offset +20 mV ---");
        dut.u_afe.mode = 2; dut.u_afe.vdc = 0.0; dut.u_afe.vos = 0.020;
        convert_once(code);
        wait_tail(12);
        code0 = code;
        $display("    before: trima %0d trimb %0d, code 0x%02h", dut.trima, dut.trimb, code0);
        cal = 1'b1;
        fork
            convert_once(code);
            begin
                @(posedge dut.sample); t_samp_rise = $realtime;
                @(negedge dut.sample); t_samp_fall = $realtime;
            end
        join
        cal = 1'b0;
        check(code == 8'h00, "calibration returns valid with code 0x00");
        check(t_samp_fall - t_samp_rise == 41.0 * TSAR, "calibration holds sample for sSample + 40 sCal sar_clk");
        wait_tail(50);                               // the back-to-back calibration
        trim_cal = dut.trima;
        convert_once(code);
        wait_tail(12);
        code1  = code;
        ta_i   = dut.trima;                          // integers: trima - trimb must not wrap
        tb_i   = dut.trimb;
        code_e = exp_code(0.0, ta_i, tb_i);
        resid_mv = 1000.0 * (dut.u_afe.vos - (ta_i - tb_i) * dut.u_afe.vtrim_lsb);
        $display("    sample held %.0f sar_clk; after: trima %0d trimb %0d, code 0x%02h (ideal for that trim 0x%02h), offset seen by the comparator %.1f mV (before: %.1f mV)",
                 (t_samp_fall - t_samp_rise) / TSAR, ta_i, tb_i, code1, code_e, resid_mv,
                 1000.0 * (dut.u_afe.vos - 1 * dut.u_afe.vtrim_lsb));
        check(code1 == code_e, "the next conversion uses the calibrated trim");
        if (trim_cal == 0 || trim_cal == 31)
            $display("    NOTE: the trim loop ran to its rail (trima %0d). sarlogic keeps a trial bit when comp is mostly 0, so it expects a higher trima to raise the vinp side; the macro (trima on the trim that loads vp), the AMS behavioural comparator and this model lower it.", trim_cal);
        dut.u_afe.vos = 0.0;

        // ---- summary ----
        $display("--- clkc pulses checked: %0d (%0d wrong width); comp samples %0d, x: %0d ---",
                 n_clkc, n_clkc_bad, n_comp_used, n_comp_x);
        check(n_clkc > 0 && n_clkc_bad == 0, "every clkc pulse is half a sar_clk period");
        check(n_comp_used > 0 && n_comp_x == 0, "comp never x when sarlogic samples it");
        $display("\n=== SAR_ADC_TB: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $finish;
    end

    initial begin
        #20_000_000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== SAR_ADC_TB: %0d PASSED, %0d FAILED ===", pass_count, fail_count + 1);
        $finish;
    end

endmodule
