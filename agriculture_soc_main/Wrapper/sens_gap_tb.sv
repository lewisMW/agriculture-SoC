`timescale 1ns/1ps
// =============================================================================
// sens_gap_tb.sv
//
// Self-checking block test that closes the sensing-peripheral coverage gaps
// found in the first coverage review (Batch 1 + the pre-existing block models). It
// drives adc_apb_wrapper_rev2 exactly as nanosoc instantiates it (16-bit PADDR,
// APB4 PSTRB/PPROT) with a protocol-correct APB master (holds ACCESS until
// PREADY is sampled high at the edge, optional back-to-back transfers), and
// owns CLK1HZ so RTC ticks can be placed on chosen PCLK cycles.
//
// RTC: every RTC check goes through the PL031 boundary only - bus accesses to
// 0x200-0x21C, RTCINTR as seen through status[5], CLK1HZ, nPOR/PRESETn - and
// the expected values come from the PL031 register definitions, never from
// pl031_stub.v internals, so the test runs unchanged against the real PL031.
// Results obtained with the stub must be re-run with the real RTL.
//
// Internal DUT signals are used only (a) to time stimulus (FSM state), and (b)
// in the FIFO scoreboard / trigger counters. Pass/fail is decided on bus
// responses wherever the bus can observe the property.
//
// Checks that fail because the design does something the spec (AMBA APB4, the
// register map, the design decisions) says it should not are reported as
//   FAIL [SUSPECTED RTL BUG <id>] ...
// and counted separately in the summary. They are NOT weakened to pass.
//
// Run (no ARM IP needed with the stub; sign-off needs the real PL031):
//   make -C verif/cov gap STUB_RTC=1      (coverage)
// =============================================================================
module sens_gap_tb #(
    parameter int          AW      = 16,      // nanosoc: ACC_ADDR_W = 16 (WRP-7 also builds 12)
    parameter logic [31:0] DEF_OFF = 32'd5    // DEFAULT_ALARM_OFFSET (WRP-7 also builds 1)
);

    localparam logic [15:0]
        A_STATUS = 16'h004, A_MEAS_HI = 16'h008, A_MEAS_LO = 16'h00C,
        A_PLL    = 16'h100, A_AMUX    = 16'h104, A_TRIG    = 16'h108, A_CAL = 16'h10C,
        A_RTCDR  = 16'h200, A_RTCMR   = 16'h204, A_RTCLR   = 16'h208, A_RTCCR = 16'h20C,
        A_RTCIMSC= 16'h210, A_RTCRIS  = 16'h214, A_RTCMIS  = 16'h218, A_RTCICR = 16'h21C,
        A_FCLR   = 16'h220, A_ALARM   = 16'h224, A_RTCCTRL = 16'h228,
        A_CLKDIV = 16'h110, A_SDIV    = 16'h114, A_IRQEN   = 16'h118, A_PRESC = 16'h22C;
    // reset values of the clock registers (wrapper defaults)
    localparam logic [31:0] CLKDIV_RST = 32'd4, SDIV_RST = 32'd8, PRESC_RST = 32'd5_000_000;

    // rtc_control_2 state encoding (used only to TIME stimulus)
    localparam logic [4:0] S_IDLE = 5'd0, S_ENABLE_SETUP = 5'd1, S_READ_SETUP = 5'd3,
                           S_WAITING = 5'd10, S_ICR_SETUP = 5'd11, S_ICR_ACCESS = 5'd12,
                           S_PULSE_TRIG = 5'd13;

    // PPROT = {instruction, non-secure, privileged}
    localparam logic [2:0] PROT_PRIV = 3'b001, PROT_USER = 3'b000, PROT_INSTR = 3'b101;

    localparam int TICK_PCLK = 100;   // auto CLK1HZ: 1 RTC second = 100 PCLK

    // ------------------------------------------------------------------ DUT
    logic          PCLK = 1'b0, CLK1HZ = 1'b0, PRESETn = 1'b0, nPOR = 1'b0;
    logic          PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
    logic [AW-1:0] PADDR = '0;
    logic [31:0]   PWDATA = '0;
    logic [3:0]    PSTRB = 4'h0;
    logic [2:0]    PPROT = PROT_PRIV;
    wire  [31:0]   PRDATA;
    wire           PREADY, PSLVERR, IRQ;
    wire  [31:0]   RTC_PRESCALE;

    adc_apb_wrapper_rev2 #(.ADDR_WIDTH(AW), .DEFAULT_ALARM_OFFSET(DEF_OFF)) uut (
        .PCLK(PCLK), .CLK1HZ(CLK1HZ), .RTC_PRESCALE(RTC_PRESCALE), .PRESETn(PRESETn), .nPOR(nPOR),
        .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .APBACTIVE(1'b1), .PPROT(PPROT), .PSTRB(PSTRB), .IRQ(IRQ),
        .ADC_VINP(1'b0), .ADC_VINN(1'b0)
    );

    always #5 PCLK = ~PCLK;

    // CLK1HZ: free-running (period TICK_PCLK PCLK) or driven edge by edge
    bit c1_auto = 1'b1;
    always begin
        if (c1_auto) begin #(TICK_PCLK*5); if (c1_auto) CLK1HZ = ~CLK1HZ; end
        else #10;
    end

    // -------------------------------------------------------------- checking
    int pass_count = 0, fail_count = 0, bug_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) begin pass_count++; $display("PASS [%0t] %s", $time, name); end
        else   begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction
    function automatic void bugcheck(input bit c, input string id, input string name);
        if (c) begin pass_count++; $display("PASS [%0t] %s", $time, name); end
        else begin
            fail_count++; bug_count++;
            $display("FAIL [%0t] [SUSPECTED RTL BUG %s] %s", $time, id, name);
        end
    endfunction

    // ------------------------------------------------------------ APB master
    logic [31:0] rdat;
    int          stalls;
    bit          slverr, in_b2b = 1'b0;
    int          n_hang = 0;

    // One APB4 transfer. now=1 starts SETUP in the current cycle (caller is at
    // posedge+#1); keep=1 leaves PSEL high for a back-to-back next transfer.
    task automatic xfer(input bit wr, input logic [AW-1:0] a, input logic [31:0] wd,
                        input logic [3:0] strb, input logic [2:0] prot,
                        input bit keep, input bit now);
        if (!in_b2b && !now) begin @(posedge PCLK); #1; end
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE = wr; PADDR = a;
        PWDATA = wr ? wd : 32'h0; PSTRB = wr ? strb : 4'h0; PPROT = prot;
        @(posedge PCLK); #1; PENABLE = 1'b1;
        stalls = 0;
        @(posedge PCLK);
        while (!PREADY && stalls <= 200) begin stalls++; @(posedge PCLK); end
        if (stalls > 200) n_hang++;
        rdat = PRDATA; slverr = PSLVERR;
        #1; PENABLE = 1'b0;
        if (!keep) begin PSEL = 1'b0; PWRITE = 1'b0; PSTRB = 4'h0; end
        in_b2b = keep;
    endtask
    task automatic wr(input logic [AW-1:0] a, input logic [31:0] d);
        xfer(1'b1, a, d, 4'hF, PROT_PRIV, 1'b0, 1'b0);
    endtask
    task automatic wrs(input logic [AW-1:0] a, input logic [31:0] d, input logic [3:0] s);
        xfer(1'b1, a, d, s, PROT_PRIV, 1'b0, 1'b0);
    endtask
    task automatic rd(input logic [AW-1:0] a, output logic [31:0] d);
        xfer(1'b0, a, 32'h0, 4'h0, PROT_PRIV, 1'b0, 1'b0); d = rdat;
    endtask
    task automatic rd_now(input logic [AW-1:0] a, output logic [31:0] d);
        xfer(1'b0, a, 32'h0, 4'h0, PROT_PRIV, 1'b0, 1'b1); d = rdat;
    endtask

    // Bus-wide monitors: no transfer ever completes with PSLVERR (decision #2);
    // stalls are bounded.
    int n_pslverr = 0, stall_run = 0, max_stall = 0;
    int stall_hist[0:40];
    always @(posedge PCLK) if (PRESETn) begin
        if (PSEL && PENABLE && PREADY && PSLVERR) n_pslverr++;
        if (PSEL && PENABLE && PREADY && stall_run <= 40) stall_hist[stall_run]++;
        stall_run = (PSEL && PENABLE && !PREADY) ? stall_run + 1 : 0;
        if (stall_run > max_stall) max_stall = stall_run;
    end

    // APB protocol at the PL031 port (an ARM IP boundary). Every ACCESS must
    // directly follow a SETUP of the same transfer, and every SETUP must be
    // followed by its ACCESS (the PL031 has no PREADY: ACCESS is one cycle).
    int  pl031_access_no_setup = 0, pl031_setup_no_access = 0;
    logic       pq_sel = 1'b0, pq_en = 1'b0, pq_wr = 1'b0;
    logic [9:0] pq_addr = '0;
    always @(posedge PCLK) begin
        if (PRESETn) begin
            if (uut.u_rtc.rtc_psel && uut.u_rtc.rtc_penable &&
                !(pq_sel && !pq_en && pq_addr == uut.u_rtc.rtc_paddr && pq_wr == uut.u_rtc.rtc_pwrite)) begin
                pl031_access_no_setup++;
                if (pl031_access_no_setup <= 3)
                    $display("NOTE [%0t] PL031 port: ACCESS without a preceding SETUP (word %0d, %s, src=%s)",
                             $time, uut.u_rtc.rtc_paddr, uut.u_rtc.rtc_pwrite ? "write" : "read",
                             uut.u_rtc.ext_sel ? "firmware" : "fsm");
            end
            if (pq_sel && !pq_en && !(uut.u_rtc.rtc_psel && uut.u_rtc.rtc_penable)) begin
                pl031_setup_no_access++;
                if (pl031_setup_no_access <= 3)
                    $display("NOTE [%0t] PL031 port: SETUP not followed by ACCESS", $time);
            end
        end
        pq_sel <= PRESETn & uut.u_rtc.rtc_psel; pq_en <= uut.u_rtc.rtc_penable;
        pq_wr  <= uut.u_rtc.rtc_pwrite;         pq_addr <= uut.u_rtc.rtc_paddr;
    end

    // ------------------------------------------- FIFO scoreboard / counters
    logic [7:0] sb[$];
    logic [7:0] last_pop;
    int n_push = 0, n_rtc_trig = 0, sb_err = 0, n_clear_push = 0, n_intr_rise_pt = 0;
    logic intr_q = 1'b0;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sb.delete();
            intr_q <= 1'b0;
        end else begin
            intr_q <= uut.u_rtc.RTCINTR;
            if (uut.u_rtc.RTCINTR && !intr_q && uut.u_rtc.ext_sel) n_intr_rise_pt++;
            if (uut.rtc_trig) n_rtc_trig++;
            if (uut.fifo_clear) begin
                if (uut.fifo_write_en) n_clear_push++;
                sb.delete();
            end else begin
                if (uut.fifo_rd_en && !uut.fifo_empty) begin
                    if (sb.size() == 0) sb_err++;
                    else begin last_pop = sb[0]; void'(sb.pop_front()); end
                end
                if (uut.fifo_write_en && !uut.fifo_full) begin
                    sb.push_back(uut.adc_sample);
                    n_push++;
                end
            end
        end
    end

    // ----------------------------------------------------------- helpers
    task automatic cycles(input int n);
        repeat (n) @(posedge PCLK);
        #1;
    endtask

    // posedge+#1 aligned wait for an rtc_control_2 state (timing only)
    task automatic wait_state(input logic [4:0] s, input int timeout, output bit ok);
        int i;
        ok = 1'b0;
        for (i = 0; i < timeout; i++) begin
            @(posedge PCLK); #1;
            if (uut.u_rtc.state == s) begin ok = 1'b1; break; end
        end
    endtask
    task automatic wait_parked(output bit ok);
        int i;
        ok = 1'b0;
        for (i = 0; i < 2000; i++) begin
            @(posedge PCLK); #1;
            if (uut.u_rtc.state == S_WAITING && !uut.u_rtc.fsm_psel) begin ok = 1'b1; break; end
        end
    endtask
    task automatic wait_fsm_idle();
        int i;
        // 2000, not 200: a SAR ADC conversion plus the FSM handshake can take
        // ~100+ PCLK, and giving up early let the sample land inside the NEXT
        // check's window (spurious T3/T4/T7 count failures).
        for (i = 0; i < 2000; i++) begin
            @(posedge PCLK); #1;
            if (uut.u_ctrl.state == 3'd0 && !uut.manual_trig && !uut.rtc_trig) break;
        end
        cycles(2);
    endtask

    // Manual CLK1HZ: one rising+falling edge, slow enough for any PCLK sync.
    task automatic tick();
        CLK1HZ = 1'b1; cycles(8);
        CLK1HZ = 1'b0; cycles(8);
    endtask
    task automatic clk1hz_manual();
        c1_auto = 1'b0; #20; CLK1HZ = 1'b0; cycles(10);
    endtask
    task automatic clk1hz_auto();
        c1_auto = 1'b1; cycles(2);
    endtask
    task automatic rtc_seconds(input int n);   // let n RTC seconds pass
        int i;
        if (c1_auto) cycles(n * TICK_PCLK);
        else for (i = 0; i < n; i++) tick();
    endtask

    task automatic set_poll(input bit en);
        wr(A_RTCCTRL, {31'h0, en});
    endtask

    // One manual sample, waited for (polling state untouched).
    task automatic manual_sample(output bit ok);
        int n0;
        n0 = n_push;
        wr(A_TRIG, 32'h1);
        wait_fsm_idle();
        ok = (n_push == n0 + 1);
    endtask

    task automatic read_meas_check(input string ctx);
        logic [31:0] d;
        logic [7:0]  e;
        int          sz;
        sz = sb.size();
        e  = (sz > 0) ? sb[0] : 8'h00;
        rd(A_MEAS_LO, d);
        cycles(1);
        if (sz > 0) check(d == {24'h0, e}, {ctx, ": MEAS_LO = FIFO head sample, zero-extended"});
        else        check(1'b1, {ctx, ": MEAS_LO read while empty completed"});
    endtask

    task automatic fifo_field(output logic [1:0] f);
        logic [31:0] d;
        rd(A_STATUS, d);
        f = d[1:0];
    endtask

    typedef struct { logic [31:0] pll, amux, cal, alarm, rtcctrl, clkdiv, sdiv, irqen, presc; } snap_t;
    task automatic snapshot(output snap_t s);
        rd(A_PLL, s.pll); rd(A_AMUX, s.amux); rd(A_CAL, s.cal);
        rd(A_ALARM, s.alarm); rd(A_RTCCTRL, s.rtcctrl);
        rd(A_CLKDIV, s.clkdiv); rd(A_SDIV, s.sdiv); rd(A_IRQEN, s.irqen); rd(A_PRESC, s.presc);
    endtask
    function automatic bit snap_eq(input snap_t a, input snap_t b);
        return a.pll == b.pll && a.amux == b.amux && a.cal == b.cal &&
               a.alarm == b.alarm && a.rtcctrl == b.rtcctrl && a.clkdiv == b.clkdiv &&
               a.sdiv == b.sdiv && a.irqen == b.irqen && a.presc == b.presc;
    endfunction

    // ------------------------------------------------------------ resets
    task automatic assert_reset(input bit por);
        if (por) nPOR = 1'b0;
        PRESETn = 1'b0;
        PSEL = 1'b0; PENABLE = 1'b0; PWRITE = 1'b0; PSTRB = 4'h0; in_b2b = 1'b0;
    endtask
    // Release so that the first bus access may start in the next cycle.
    task automatic release_reset(input bit por);
        if (por) begin cycles(2); nPOR = 1'b1; end
        cycles(3);
        PRESETn = 1'b1;
    endtask
    task automatic wait_rtc_out_of_reset(output bit ok);
        int i;
        ok = 1'b0;
        for (i = 0; i < 40 * TICK_PCLK; i++) begin
            @(posedge PCLK); #1;
            if (uut.u_rtc.nRTCRST) begin ok = 1'b1; break; end
            if (!c1_auto && (i % 20 == 0)) tick();
        end
    endtask

    // Register reset values, read in the first accesses after a reset (the
    // first read of each register is what cp_first_read / cp_reset_value use).
    // warm = PRESETn-only reset. The real PL031 keeps RTCMR/RTCIMSC across it
    // (nPOR domain), so an alarm that was being serviced when the reset hit is
    // visible again as STATUS[5] until the first arm clears it (FIX-4, ~12 PCLK)
    // - STATUS[5] is checked after that arm instead.
    task automatic check_reset_values(input string ctx, input bit warm = 1'b0);
        logic [31:0] d, t, tg;
        logic [1:0]  f;
        bit ok;
        rd(A_STATUS, d);
        check((d & (warm ? 32'hFFFF_FFDF : 32'hFFFF_FFFF)) == 32'h0,
              $sformatf("%s: STATUS = 0 (empty, ADC idle, no drop%s) (read 0x%0h)", ctx, warm ? "" : ", no RTC intr", d));
        if (warm && uut.u_rtc.nRTCRST) begin
            wait_state(S_WAITING, 8 * TICK_PCLK, ok);
            cycles(2);
            // An interrupt pending here is legitimate if the RTC has reached the
            // alarm armed at the time of the STATUS read (a tick can land during
            // the arm itself); that alarm is serviced and re-armed straight
            // after, so compare against the target captured with the read.
            rd(A_STATUS, d); tg = uut.u_rtc.alarm_target; rd(A_RTCDR, t);
            check(ok && (!d[5] || t >= tg),
                  $sformatf("%s: no RTC interrupt left pending once the first arm completes (FIX-4) (STATUS 0x%0h)", ctx, d));
        end
        rd(A_MEAS_HI, d); check(d == 32'h0, {ctx, ": MEAS_HI = 0"});
        rd(A_MEAS_LO, d); // empty FIFO, never written since reset: value undefined (F18)
        fifo_field(f);    check(f == 2'b00, {ctx, ": MEAS_LO read on empty FIFO leaves it empty"});
        rd(A_PLL, d);     check(d == 32'h0, {ctx, ": PLL_CONTROL = 0"});
        rd(A_AMUX, d);    check(d == 32'h0, {ctx, ": AMUX = 0"});
        rd(A_TRIG, d);    check(d == 32'h0, {ctx, ": ADC_TRIGGER (WO) reads 0"});
        rd(A_CAL, d);     check(d == 32'h0, {ctx, ": ADC_CAL = 0"});
        rd(A_FCLR, d);    check(d == 32'h0, {ctx, ": FIFO_CLEAR (WO) reads 0"});
        rd(A_ALARM, d);   check(d == DEF_OFF, {ctx, ": RTC_ALARM_OFFSET = DEFAULT_ALARM_OFFSET"});
        rd(A_RTCCTRL, d); check(d == 32'h1, {ctx, ": RTC_CTRL = 1 (polling on)"});
        rd(A_CLKDIV, d);  check(d == CLKDIV_RST, {ctx, ": ADC_CLKDIV = ADC_CLK_DIV"});
        rd(A_SDIV, d);    check(d == SDIV_RST, {ctx, ": ADC_SAMPLEDIV = ADC_SAMPLE_DIV"});
        rd(A_IRQEN, d);   check(d == 32'h0 && !IRQ, {ctx, ": IRQ_ENABLE = 0, IRQ low"});
        rd(A_PRESC, d);   check(d == PRESC_RST && RTC_PRESCALE == PRESC_RST,
                                {ctx, ": RTC_PRESCALE = RTC_PRESCALE_RESET, on the output too"});
        rd(16'h0F0, d);   check(d == 32'h0, {ctx, ": reserved offset 0x0F0 reads 0"});
    endtask

    // ----------------------------------------------- RTC arm (firmware means)
    // Make the controller arm NOW with `offset` using only firmware-visible
    // operations: pause polling, point RTCMR two seconds ahead, wait for the
    // match (RTCRIS), optionally hold the interrupt pending, then resume. Per
    // rtc_control_2's re-enable semantics the pending alarm is serviced (one
    // sample) and the alarm is re-armed from the current time with `offset`.
    // race_k >= 0 (manual CLK1HZ only): put a CLK1HZ rising edge race_k PCLK
    // after the controller starts its RTCDR read.
    task automatic force_arm(input logic [31:0] offset, input int race_k, input int hold,
                             output logic [31:0] mr, output bit ok);
        logic [31:0] t, ris, t_lo, t_hi, cap, eo;
        int i, trig0;
        bit got;
        wr(A_ALARM, offset);
        set_poll(1'b0);
        wait_parked(got);
        wr(A_RTCICR, 32'h1);
        rd(A_RTCDR, t);
        wr(A_RTCMR, t + 32'd2);
        got = 1'b0;
        for (i = 0; i < 12 && !got; i++) begin
            rtc_seconds(1);
            rd(A_RTCRIS, ris); got = ris[0];
        end
        check(got, "force_arm: firmware RTCMR match raises RTCRIS while polling paused");
        if (hold > 0) cycles(hold);
        rd(A_RTCDR, t_lo);
        trig0 = n_rtc_trig;
        set_poll(1'b1);
        if (race_k >= 0) begin
            wait_state(S_READ_SETUP, 60, got);
            if (race_k > 0) cycles(race_k);
            CLK1HZ = 1'b1; cycles(6); CLK1HZ = 1'b0; cycles(6);
        end
        wait_parked(got);
        rd(A_RTCMR, mr);
        rd(A_RTCDR, t_hi);
        // rtc_control_2 clamps alarm_offset 0 to 1 (F8-OFFSET0 fix).
        eo  = (offset == 32'd0) ? 32'd1 : offset;
        cap = mr - eo;
        // With a CLK1HZ edge injected after the re-arm and a 1 s offset, the new
        // alarm can legitimately fire prev_val the controller parks again.
        ok = got && (n_rtc_trig == trig0 + 1 || (race_k >= 0 && n_rtc_trig == trig0 + 2)) &&
             (cap >= t_lo) && (cap <= t_hi);
        check(n_rtc_trig == trig0 + 1 || (race_k >= 0 && eo == 32'd1 && n_rtc_trig == trig0 + 2),
              $sformatf("force_arm: resume services the pending alarm exactly once (%0d)", n_rtc_trig - trig0));
        check((cap >= t_lo) && (cap <= t_hi),
              $sformatf("force_arm: RTCMR (0x%08h) = RTC time at arm + offset %0d", mr, offset));
    endtask

    // Did the armed alarm fire within max_s RTC seconds?
    task automatic expect_fire(input int max_s, output bit fired);
        int trig0, i;
        trig0 = n_rtc_trig;
        fired = 1'b0;
        for (i = 0; i < max_s && !fired; i++) begin
            rtc_seconds(1);
            cycles(30);
            fired = (n_rtc_trig > trig0);
        end
    endtask

    // ============================================================== TESTS
    logic [31:0] d, t0, t1, mr, m0;
    logic [1:0]  f;
    bit          ok, fired;
    snap_t       s0, s1;
    int          i, k, n0, dead;

    // ---- T1: power-on reset, reset values, access while counter in reset --
    task automatic t1_por_reset_values();
        $display("\n--- T1 power-on reset: reset values, first access, RTC counter in reset ---");
        assert_reset(1'b1);
        release_reset(1'b1);
        // first access right after PRESETn release (cp_first_access_latency.immediate);
        // nRTCRST is still low (2 CLK1HZ edges after nPOR) -> passthrough while
        // the counter is in reset (cg_rtc_rst.cp_access_in_rtc_reset).
        check(uut.u_rtc.nRTCRST == 1'b0, "T1 precondition: RTC counter still in reset");
        rd(A_RTCDR, d);
        check(d == 32'h0 && stalls == 0, "T1 RTCDR reads 0 without stalling while the counter is in reset");
        check_reset_values("T1 POR");
        wait_rtc_out_of_reset(ok);
        check(ok, "T1 nRTCRST released after power-on");
    endtask

    // ---- T2: RW registers, write->read-back --------------------------------
    task automatic t2_rw_readback();
        $display("\n--- T2 RW registers: write then read back ---");
        wr(A_PLL, 32'hA5A5_5A5A);   rd(A_PLL, d);   check(d == 32'hA5A5_5A5A, "T2 PLL_CONTROL read-back");
        wr(A_AMUX, 32'h3);          rd(A_AMUX, d);  check(d == 32'h3, "T2 AMUX read-back");
        wr(A_CAL, 32'h1);           rd(A_CAL, d);   check(d == 32'h1, "T2 ADC_CAL read-back");
        wr(A_ALARM, 32'd7);         rd(A_ALARM, d); check(d == 32'd7, "T2 RTC_ALARM_OFFSET read-back");
        wr(A_RTCCTRL, 32'h0);       rd(A_RTCCTRL, d); check(d == 32'h0, "T2 RTC_CTRL read-back (paused)");
        wr(A_RTCCTRL, 32'h1);       rd(A_RTCCTRL, d); check(d == 32'h1, "T2 RTC_CTRL read-back (on)");
        wr(A_CLKDIV, 32'hFFFF_FF07); rd(A_CLKDIV, d); check(d == 32'h07, "T2 ADC_CLKDIV read-back ([7:0] only)");
        wr(A_SDIV, 32'hFFFF_FF0B);   rd(A_SDIV, d);   check(d == 32'h0B, "T2 ADC_SAMPLEDIV read-back ([7:0] only)");
        wr(A_IRQEN, 32'hFFFF_FFFE);  rd(A_IRQEN, d);  check(d == 32'h2, "T2 IRQ_ENABLE read-back ([1:0] only)");
        wr(A_PRESC, 32'hDEAD_BEEF);  rd(A_PRESC, d);
        check(d == 32'hDEAD_BEEF && RTC_PRESCALE == 32'hDEAD_BEEF, "T2 RTC_PRESCALE read-back, on the output too");
        wr(A_PLL, 32'h0); wr(A_AMUX, 32'h0); wr(A_CAL, 32'h0); wr(A_ALARM, 32'd5);
        wr(A_CLKDIV, CLKDIV_RST); wr(A_SDIV, SDIV_RST); wr(A_IRQEN, 32'h0); wr(A_PRESC, PRESC_RST);
    endtask

    // ---- T3: reserved offsets, misaligned, aliases above 4 KB (F5) --------
    task automatic t3_decode();
        logic [15:0] resv [7];
        bit ok2;
        $display("\n--- T3 reserved / misaligned / aliased offsets ---");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        wr(A_PLL, 32'hCAFE_F00D); wr(A_AMUX, 32'h2); wr(A_CAL, 32'h1); wr(A_ALARM, 32'd7);
        manual_sample(ok2);
        snapshot(s0);
        n0 = sb.size();
        resv = '{16'h000, 16'h010, 16'h0FC, 16'h11C, 16'h1FC, 16'h230, 16'hFFC};
        foreach (resv[j]) begin
            rd(resv[j], d);
            check(d == 32'h0, $sformatf("T3 reserved 0x%03h reads 0", resv[j]));
            wr(resv[j], 32'hFFFF_FFFF);
        end
        // misaligned (PADDR[1:0] != 0; unreachable through the CMSDK bridge)
        wr(16'h105, 32'h3);   rd(16'h105, d); check(d == 32'h0, "T3 misaligned 0x105 reads 0");
        wr(16'h101, 32'h0);
        rd(16'h00D, d);       check(d == 32'h0, "T3 misaligned 0x00D (MEAS_LO+1) reads 0");
        // aliases above 4 KB (only exist with a PADDR wider than 12 bits)
        if (AW > 12) begin
            rd(16'h1004, d);      check(d == 32'h0, "T3 alias 0x1004 reads 0 (unmapped)");
            rd(16'h800C, d);      check(d == 32'h0, "T3 alias 0x800C reads 0 and does not pop");
            wr(16'h1104, 32'h3);  wr(16'h1220, 32'h1); wr(16'hF228, 32'h0); wr(16'h1108, 32'h1);
            wr(16'h1110, 32'h1);  wr(16'h2114, 32'h1); wr(16'h1118, 32'h3); wr(16'h122C, 32'h1);
        end
        cycles(40);
        snapshot(s1);
        check(snap_eq(s0, s1), "T3 reserved/misaligned/aliased writes left every register unchanged");
        check(sb.size() == n0, "T3 no FIFO push/pop/clear from reserved/aliased accesses");
        // RTC-region alias: 0x1200-0x121C must be unmapped like every other
        // register above 4 KB (F5, fixed: full-width RTC region decode).
        if (AW > 12) begin
            rd(A_RTCMR, m0);
            wr(16'h1204, m0 ^ 32'h0000_5555);
            rd(A_RTCMR, d);
            check(d == m0, "T3 write to alias 0x1204 does not change PL031 RTCMR (F5)");
            wr(A_RTCMR, m0);
            rd(16'h1200, d);
            check(d == 32'h0, "T3 read of alias 0x1200 reads 0 like every other alias (F5)");
        end
        read_meas_check("T3");
        wr(A_PLL, 32'h0); wr(A_AMUX, 32'h0); wr(A_CAL, 32'h0); wr(A_ALARM, 32'd5);
    endtask

    // ---- T4: RO written, WO read, reserved bits, PPROT, manual poll-off -----
    task automatic t4_direction_bits_prot();
        logic [31:0] st0, a, b, c;
        bit ok2;
        $display("\n--- T4 wrong-direction accesses, reserved bits, PPROT ---");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        manual_sample(ok2); check(ok2, "T4 manual trigger with polling OFF produces one sample");
        manual_sample(ok2);
        rd(A_STATUS, st0);
        n0 = sb.size();
        wr(A_STATUS, 32'hFFFF_FFFF); wr(A_MEAS_HI, 32'hFFFF_FFFF); wr(A_MEAS_LO, 32'hFFFF_FFFF);
        cycles(30);
        rd(A_STATUS, d);
        // [5] (RTC interrupt pending) moves on its own when the paused alarm comes due
        check((d & ~32'h20) == (st0 & ~32'h20), "T4 writes to RO STATUS/MEAS_HI/MEAS_LO leave STATUS unchanged");
        check(sb.size() == n0 && n0 == 2, "T4 writes to RO registers neither push nor pop");
        read_meas_check("T4 head after RO writes");
        n0 = n_push;
        rd(A_TRIG, d);  check(d == 32'h0, "T4 ADC_TRIGGER read returns 0");
        rd(A_FCLR, d);  check(d == 32'h0, "T4 FIFO_CLEAR read returns 0");
        cycles(40);
        check(n_push == n0, "T4 reading ADC_TRIGGER does not trigger a conversion");
        check(sb.size() == 1, "T4 reading FIFO_CLEAR does not clear the FIFO");
        read_meas_check("T4 data intact after WO reads");
        n0 = n_push;
        wr(A_TRIG, 32'h0);          cycles(40); check(n_push == n0, "T4 ADC_TRIGGER write of 0 does nothing");
        wr(A_TRIG, 32'hFFFF_FFFE);  cycles(40); check(n_push == n0, "T4 ADC_TRIGGER bit0=0 with reserved bits set does nothing");
        wr(A_TRIG, 32'hFFFF_FFFF);  wait_fsm_idle(); check(n_push == n0 + 1, "T4 ADC_TRIGGER bit0=1 with reserved bits set triggers once");
        read_meas_check("T4 reserved-bit trigger sample");
        wr(A_CAL, 32'hFFFF_FFFE);   rd(A_CAL, d);   check(d == 32'h0, "T4 ADC_CAL reserved bits read 0 (bit0=0)");
        wr(A_CAL, 32'hFFFF_FFFF);   rd(A_CAL, d);   check(d == 32'h1, "T4 ADC_CAL reserved bits read 0 (bit0=1)");
        wr(A_CAL, 32'h0);
        wr(A_RTCCTRL, 32'hFFFF_FFFE); rd(A_RTCCTRL, d); check(d == 32'h0, "T4 RTC_CTRL reserved bits read 0 (paused)");
        wr(A_RTCCTRL, 32'hFFFF_FFFF); rd(A_RTCCTRL, d); check(d == 32'h1, "T4 RTC_CTRL reserved bits read 0 (on)");
        set_poll(1'b0);
        wr(A_AMUX, 32'hFFFF_FFFD);  rd(A_AMUX, d);  check(d == 32'hFFFF_FFFD, "T4 AMUX keeps all written bits (32-bit RW register)");
        wr(A_AMUX, 32'h0);
        // PPROT: the peripheral does not filter on privilege / instruction
        xfer(1'b0, A_ALARM, 0, 0, PROT_USER, 1'b0, 1'b0);  a = rdat;
        xfer(1'b0, A_ALARM, 0, 0, PROT_PRIV, 1'b0, 1'b0);  b = rdat;
        xfer(1'b0, A_ALARM, 0, 0, PROT_INSTR, 1'b0, 1'b0); c = rdat;
        check(a == 32'd5 && b == 32'd5 && c == 32'd5, "T4 reads identical for user / privileged / instruction PPROT");
        xfer(1'b1, A_PLL, 32'h1234_0001, 4'hF, PROT_USER, 1'b0, 1'b0);  rd(A_PLL, d);
        check(d == 32'h1234_0001, "T4 user-mode write takes effect");
        xfer(1'b1, A_PLL, 32'h1234_0002, 4'hF, PROT_INSTR, 1'b0, 1'b0); rd(A_PLL, d);
        check(d == 32'h1234_0002, "T4 instruction-PPROT write takes effect");
        wr(A_PLL, 32'h0);
    endtask

    // ---- T5: sub-word writes (PSTRB) to every register (F6) -----------------
    function automatic logic [31:0] lane_mask(input logic [3:0] s);
        return {{8{s[3]}}, {8{s[2]}}, {8{s[1]}}, {8{s[0]}}};
    endfunction
    task automatic pstrb_rw(input logic [15:0] a, input logic [31:0] impl, input string nm);
        logic [3:0]  sv [7];
        logic [31:0] base, pat, wd, exp;
        int          bad;
        sv   = '{4'hF, 4'h3, 4'hC, 4'h1, 4'h2, 4'h4, 4'h8};
        base = 32'h1122_3345 & impl;
        pat  = 32'hA1B2_C3D4;
        bad  = 0;
        foreach (sv[j]) begin
            wr(a, base);
            wd  = pat & lane_mask(sv[j]);
            wrs(a, wd, sv[j]);
            rd(a, d);
            exp = ((base & ~lane_mask(sv[j])) | wd) & impl;   // AMBA APB4: only strobed lanes written
            if (d != exp) begin
                bad++;
                if (bad == 1) $display("      %s PSTRB=%b: read 0x%08h, APB4 expects 0x%08h", nm, sv[j], d, exp);
            end
        end
        // one undefined-pattern strobe (0101) for cp_wr_strb.other
        wr(a, base); wrs(a, pat & lane_mask(4'h5), 4'h5);
        check(bad == 0, $sformatf("T5 %s: sub-word writes update only the strobed byte lanes (%0d/7 wrong)", nm, bad));
    endtask
    // RTC passthrough registers: the PL031 has no PSTRB, so the adopted policy
    // (adc_apb_wrapper_rev2 rtc_partial_wr) is that a sub-word write to ANY RTC
    // passthrough register is dropped: it completes with PREADY and no PSLVERR,
    // without wait states, and leaves the register unchanged.
    task automatic pstrb_rtc_dropped(input logic [15:0] a, input logic [31:0] full_val,
                                     input bit readable, input string nm);
        logic [3:0]  sv [7];
        logic [31:0] prev_val;
        int          bad, n_err0;
        sv  = '{4'h3, 4'hC, 4'h1, 4'h2, 4'h4, 4'h8, 4'h5};
        bad = 0; n_err0 = n_pslverr;
        if (full_val != 32'hFFFF_FFFF || readable) begin
            wr(a, full_val);                         // a full-word write is forwarded
            rd(a, d);
            if (readable && d != full_val) bad++;
        end
        rd(a, prev_val);
        foreach (sv[j]) begin
            wrs(a, ~full_val & lane_mask(sv[j]), sv[j]);
            if (stalls != 0 || slverr) bad++;        // completes at once, no error
            rd(a, d);
            if (readable && d != prev_val) begin
                bad++;
                if (bad == 1) $display("      %s PSTRB=%b: 0x%08h -> 0x%08h (must be unchanged)", nm, sv[j], prev_val, d);
            end
        end
        check(bad == 0 && n_pslverr == n_err0 && n_hang == 0,
              $sformatf("T5 %s: sub-word writes dropped - PREADY, no PSLVERR, register unchanged (%0d wrong)", nm, bad));
    endtask
    task automatic t5_pstrb();
        logic [3:0] sv [7];
        logic [31:0] st0;
        bit ok2;
        int bad;
        $display("\n--- T5 PSTRB sub-word writes to every register ---");
        sv = '{4'hF, 4'h3, 4'hC, 4'h1, 4'h2, 4'h4, 4'h8};
        set_poll(1'b0);
        wait_fsm_idle();
        pstrb_rw(A_PLL,   32'hFFFF_FFFF, "PLL_CONTROL");
        pstrb_rw(A_AMUX,  32'hFFFF_FFFF, "AMUX");
        pstrb_rw(A_CAL,   32'h0000_0001, "ADC_CAL");
        pstrb_rw(A_ALARM, 32'hFFFF_FFFF, "RTC_ALARM_OFFSET");
        pstrb_rw(A_PRESC, 32'hFFFF_FFFF, "RTC_PRESCALE");
        // byte-0 registers: only a write that strobes lane 0 changes them
        pstrb_rw(A_CLKDIV, 32'h0000_00FF, "ADC_CLKDIV");
        pstrb_rw(A_SDIV,   32'h0000_00FF, "ADC_SAMPLEDIV");
        pstrb_rw(A_IRQEN,  32'h0000_0003, "IRQ_ENABLE");
        wr(A_CLKDIV, CLKDIV_RST); wr(A_SDIV, SDIV_RST); wr(A_IRQEN, 32'h0); wr(A_PRESC, PRESC_RST);
        // RTC passthrough: polling is paused here, so nothing else
        // rewrites these registers during the check.
        wait_parked(ok2);
        pstrb_rtc_dropped(A_RTCMR,   32'h1122_3345, 1'b1, "RTC passthrough RTCMR");
        pstrb_rtc_dropped(A_RTCIMSC, 32'h0000_0001, 1'b1, "RTC passthrough RTCIMSC");
        pstrb_rtc_dropped(A_RTCCR,   32'h0000_0001, 1'b1, "RTC passthrough RTCCR");
        begin
            // RTCLR: a dropped sub-word write must not load the counter
            logic [31:0] ta, tb2;
            rd(A_RTCDR, ta);
            wrs(A_RTCLR, 32'h0000_0000, 4'h1); wrs(A_RTCLR, 32'hFFFF_0000, 4'hC);
            wrs(A_RTCLR, 32'h0000_0000, 4'h3);
            rd(A_RTCDR, tb2);
            check(tb2 >= ta && tb2 - ta <= 32'd3, "T5 RTC passthrough RTCLR: sub-word writes do not load the counter");
            // RTCICR: a dropped sub-word write must not clear a pending interrupt
            wr(A_RTCICR, 32'h1);
            rd(A_RTCDR, ta); wr(A_RTCMR, ta + 32'd2);
            rtc_seconds(4);
            rd(A_RTCRIS, d);
            check(d[0], "T5 precondition: match raised RTCRIS while paused");
            wrs(A_RTCICR, 32'h0000_0001, 4'h1); wrs(A_RTCICR, 32'h0001_0001, 4'h3);
            wrs(A_RTCICR, 32'hFFFF_0000, 4'hC);
            rd(A_RTCRIS, d);
            check(d[0], "T5 RTC passthrough RTCICR: sub-word writes do not clear the interrupt");
            wr(A_RTCICR, 32'h1);
            rd(A_RTCRIS, d);
            check(!d[0], "T5 RTC passthrough RTCICR: the full-word write clears it");
        end
        wr(A_PLL, 32'h0); wr(A_AMUX, 32'h0); wr(A_CAL, 32'h0); wr(A_ALARM, 32'd5);
        // ADC_TRIGGER: APB4 -> trigger iff lane 0 is strobed and bit0 = 1
        wr(A_FCLR, 32'h1);
        bad = 0;
        foreach (sv[j]) begin
            n0 = n_push;
            wrs(A_TRIG, 32'h0101_0101 & lane_mask(sv[j]), sv[j]);
            wait_fsm_idle();
            if ((n_push - n0) != (sv[j][0] ? 1 : 0)) bad++;
        end
        wrs(A_TRIG, 32'h0, 4'h5); wait_fsm_idle();
        check(bad == 0, "T5 ADC_TRIGGER sub-word writes trigger iff byte lane 0 carries bit0=1");
        // FIFO_CLEAR: "any write flushes the FIFO", whatever the strobes
        bad = 0;
        foreach (sv[j]) begin
            manual_sample(ok2);
            wrs(A_FCLR, 32'h1 & lane_mask(sv[j]), sv[j]);
            cycles(2);
            fifo_field(f);
            if (f != 2'b00 || sb.size() != 0) bad++;
        end
        manual_sample(ok2); wrs(A_FCLR, 32'h0, 4'h5);
        check(bad == 0, "T5 FIFO_CLEAR: every sub-word write flushes the FIFO");
        // RO registers with sub-word writes: harmless
        wr(A_FCLR, 32'h1); manual_sample(ok2); manual_sample(ok2);
        rd(A_STATUS, st0); n0 = sb.size();
        foreach (sv[j]) begin
            wrs(A_STATUS,  32'hFFFF_FFFF & lane_mask(sv[j]), sv[j]);
            wrs(A_MEAS_HI, 32'hFFFF_FFFF & lane_mask(sv[j]), sv[j]);
            wrs(A_MEAS_LO, 32'hFFFF_FFFF & lane_mask(sv[j]), sv[j]);
            wrs(16'h0F0,   32'hFFFF_FFFF & lane_mask(sv[j]), sv[j]);
        end
        rd(A_STATUS, d);
        check(d == st0 && sb.size() == n0, "T5 sub-word writes to RO/unmapped offsets change nothing");
        read_meas_check("T5 FIFO head intact");
        // RTC_CTRL: last, because a sub-word write can resume polling
        pstrb_rw(A_RTCCTRL, 32'h0000_0001, "RTC_CTRL");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        // RTCMR was rewritten above: re-arm cleanly (firmware means)
        force_arm(32'd5, -1, 0, mr, ok);
    endtask

    // ---- T6: every PL031 register through the passthrough (RTC boundary) ----
    task automatic t6_rtc_words();
        logic [31:0] dr, mrv, cr, imsc, ris, mis, lr, dr2;
        $display("\n--- T6 PL031 registers via passthrough (needs re-run with real PL031) ---");
        set_poll(1'b0);
        wait_parked(ok);
        rd(A_RTCDR, dr);   rd(A_RTCMR, mrv); rd(A_RTCLR, lr);
        rd(A_RTCCR, cr);   rd(A_RTCIMSC, imsc); rd(A_RTCRIS, ris);
        rd(A_RTCMIS, mis); rd(A_RTCICR, d);
        check(cr[0] == 1'b1, "T6 RTCCR.start reads 1 (counter enabled by the controller)");
        check(imsc[0] == 1'b1, "T6 RTCIMSC reads 1 (controller unmasked the alarm)");
        check(mis[0] == (ris[0] & imsc[0]), "T6 RTCMIS = RTCRIS & RTCIMSC");
        check((mrv - dr) <= 32'd5 || ris[0], "T6 RTCMR holds an alarm target <= alarm_offset ahead");
        // RTCDR is read-only: a write must not load the counter
        wr(A_RTCDR, 32'hFFFF_FFFF);
        rd(A_RTCDR, d);
        check(d != 32'hFFFF_FFFF && d >= dr && d <= dr + 2, "T6 write to read-only RTCDR is ignored");
        // RTCMR read/write, write-data classes 0 / 1 / all-ones / other
        wr(A_RTCMR, 32'h0);          rd(A_RTCMR, d); check(d == 32'h0, "T6 RTCMR write 0 read-back");
        wr(A_RTCMR, 32'h1);          rd(A_RTCMR, d); check(d == 32'h1, "T6 RTCMR write 1 read-back");
        wr(A_RTCMR, 32'hFFFF_FFFF);  rd(A_RTCMR, d); check(d == 32'hFFFF_FFFF, "T6 RTCMR write all-ones read-back");
        wr(A_RTCMR, mrv);            rd(A_RTCMR, d); check(d == mrv, "T6 RTCMR restore read-back");
        // RTCCR: once started the counter cannot be stopped. The wrapper
        // forwards RTCCR writes with bit 0 forced to 1 (FIX-3): the real PL031
        // clears start on a write of 0, which would leave rtc_control_2
        // believing the RTC runs while RTCDR reads 0.
        wr(A_RTCCR, 32'h0);
        rd(A_RTCCR, d);  check(d[0] == 1'b1, "T6 RTCCR write 0 does not clear start (wrapper FIX-3)");
        rd(A_RTCDR, t0); rtc_seconds(2); rd(A_RTCDR, t1);
        check(t1 > t0, "T6 RTC keeps counting after RTCCR write 0");
        // RTCIMSC write 0 / 1
        wr(A_RTCIMSC, 32'h0); rd(A_RTCIMSC, d); check(d[0] == 1'b0, "T6 RTCIMSC write 0 read-back");
        rd(A_RTCMIS, d);      check(d[0] == 1'b0, "T6 RTCMIS = 0 while masked");
        wr(A_RTCIMSC, 32'h1); rd(A_RTCIMSC, d); check(d[0] == 1'b1, "T6 RTCIMSC write 1 read-back");
        // read-only RTCRIS / RTCMIS writes ignored; RTCICR clears
        rd(A_RTCRIS, ris);
        wr(A_RTCRIS, 32'h1); rd(A_RTCRIS, d); check(d[0] == ris[0], "T6 write to read-only RTCRIS ignored");
        wr(A_RTCMIS, 32'h1); rd(A_RTCMIS, d); check(d[0] == (ris[0] & 1'b1), "T6 write to read-only RTCMIS ignored");
        // match raised by firmware: RTCMR = now + 2, wait, RIS/MIS/status[5]
        rd(A_RTCDR, t0);
        wr(A_RTCMR, t0 + 32'd2);
        rtc_seconds(4);
        rd(A_RTCRIS, ris); rd(A_RTCMIS, mis); rd(A_STATUS, d);
        check(ris[0] && mis[0], "T6 firmware RTCMR match sets RTCRIS and RTCMIS");
        check(d[5] == 1'b1, "T6 STATUS[5] mirrors the pending RTC interrupt");
        wr(A_RTCICR, 32'h1);
        rd(A_RTCRIS, ris); rd(A_STATUS, d);
        check(ris[0] == 1'b0, "T6 RTCICR write 1 clears RTCRIS");
        check(d[5] == 1'b0, "T6 STATUS[5] clears with the RTC interrupt");
        // RTCLR loads the counter
        rd(A_RTCDR, t0);
        wr(A_RTCLR, t0 + 32'd1000);
        rtc_seconds(2);
        rd(A_RTCDR, d);  rd(A_RTCLR, lr);
        check(d >= t0 + 32'd1000 && d <= t0 + 32'd1003, "T6 RTCLR write loads the counter");
        check(lr == t0 + 32'd1000, "T6 RTCLR reads back the last value written (PL031 TRM)");
        // controller's alarm target was overwritten above: re-arm (firmware means)
        force_arm(32'd5, -1, 0, mr, ok);
        expect_fire(7, fired);
        check(fired, "T6 autonomous sampling resumes after the firmware re-arm");
    endtask

    // ---- T7: alarm pending while paused for > 5000 PCLK, then resume -----
    task automatic t7_alarm_while_paused();
        int p0;
        $display("\n--- T7 RTC alarm held pending while polling is paused ---");
        set_poll(1'b0);
        wait_parked(ok);
        wait_fsm_idle();               // let any in-flight sample land first (a SAR
                                       // conversion is ~80-100 PCLK; the old fixed
                                       // 30 cycles was sized for dummy_adc)
        wr(A_FCLR, 32'h1);             // earlier phases may have filled the FIFO
        p0 = n_push;
        force_arm(32'd4, -1, 5200, mr, ok);
        wait_fsm_idle();               // the serviced trigger's conversion (~20 PCLK)
        check(n_push == p0 + 1, $sformatf("T7 exactly one sample for the alarm held while paused (got %0d)", n_push - p0));
        rd(A_RTCRIS, d);
        check(d[0] == 1'b0, "T7 resume services and clears the pending interrupt");
        expect_fire(6, fired);
        check(fired, "T7 periodic sampling continues after resume");
    endtask

    // ---- T8: alarm_offset classes and a CLK1HZ edge racing the arm (F8) -----
    task automatic arm_and_expect(input logic [31:0] off, input int race_k, input int max_s,
                                  input bit must_fire, input string id, input string nm);
        force_arm(off, race_k, 0, mr, ok);
        expect_fire(max_s, fired);
        if (must_fire) bugcheck(fired, id, nm);
        else           check(!fired, nm);
        if (!fired || !must_fire) begin
            // recover with a firmware re-arm (also proves recovery works)
            force_arm(32'd5, -1, 0, mr, ok);
            expect_fire(7, fired);
            check(fired, "T8 firmware re-arm (pause, RTCMR, resume) restores sampling");
        end
    endtask
    task automatic t8_offsets();
        $display("\n--- T8 alarm_offset classes and CLK1HZ edge in the arm window ---");
        clk1hz_manual();
        arm_and_expect(32'd5, -1, 7, 1'b1, "-", "T8 offset 5: alarm fires");
        arm_and_expect(32'd0, -1, 4, 1'b1, "F8-OFFSET0",
                       "T8 offset 0: autonomous sampling must not stop (dead alarm)");
        for (k = 0; k <= 6; k++)
            arm_and_expect(32'd0, k, 4, 1'b1, "F8-OFFSET0",
                           $sformatf("T8 offset 0, CLK1HZ edge %0d PCLK into the arm: sampling continues", k));
        arm_and_expect(32'd1, -1, 3, 1'b1, "-", "T8 offset 1 (no edge in the arm window): alarm fires");
        dead = 0;
        for (k = 0; k <= 12; k++) begin
            force_arm(32'd1, k, 0, mr, ok);
            expect_fire(3, fired);
            if (!fired) begin
                dead++;
                $display("      offset 1: CLK1HZ edge %0d PCLK into the arm -> alarm missed", k);
                force_arm(32'd5, -1, 0, mr, ok);
            end
        end
        bugcheck(dead == 0, "F8-OFFSET1",
                 $sformatf("T8 offset 1 with a CLK1HZ edge in the arm window: alarm never missed (%0d/13 missed)", dead));
        for (k = 0; k <= 6; k++)
            arm_and_expect(32'd3, k, 5, 1'b1, "-", $sformatf("T8 offset 3, CLK1HZ edge %0d PCLK into the arm: fires", k));
        arm_and_expect(32'd12, -1, 14, 1'b1, "-", "T8 offset 12: alarm fires");
        for (k = 0; k <= 6; k++)
            arm_and_expect(32'd12, k, 14, 1'b1, "-", $sformatf("T8 offset 12, CLK1HZ edge %0d PCLK into the arm: fires", k));
        arm_and_expect(32'd5000, -1, 6, 1'b0, "-", "T8 offset 5000: no alarm within 6 s (long period honoured)");
        arm_and_expect(32'hFFFF_FFFF, -1, 6, 1'b0, "-", "T8 offset 0xFFFFFFFF: armed one second behind (wrap), no alarm within 6 s");
        for (k = 0; k <= 6; k++)
            arm_and_expect(32'hFFFF_FFFF, k, 3, 1'b0, "-", $sformatf("T8 offset 0xFFFFFFFF, edge %0d into arm: no alarm", k));
        clk1hz_auto();
        force_arm(32'd5, -1, 0, mr, ok);
    endtask

    // ---- T9: firmware sets the clock forward via RTCLR ---------------------
    task automatic t9_rtclr_forward();
        $display("\n--- T9 firmware sets the RTC forward via RTCLR while polling ---");
        force_arm(32'd3, -1, 0, mr, ok);
        rd(A_RTCDR, t0);
        wr(A_RTCLR, t0 + 32'd100);
        // The real PL031 applies an RTCLR load a
        // cycle or two after the write: a read straight after it can still
        // return the old time (measured on the ARM PL031, 2026-11-16). One more
        // access later the new time is visible.
        rd(A_RTCDR, d);
        rd(A_RTCDR, d);
        check(d >= t0 + 32'd100 && d <= t0 + 32'd102, $sformatf("T9 RTCLR load moved the RTC forward (RTCDR %0d, loaded %0d)", d, t0 + 32'd100));
        expect_fire(12, fired);
        bugcheck(fired, "RTCLR-FWD",
                 "T9 autonomous sampling continues after firmware sets the RTC forward (RTCLR)");
        force_arm(32'd5, -1, 0, mr, ok);
        expect_fire(7, fired);
        check(fired, "T9 firmware re-arm restores sampling after the RTCLR jump");
    endtask

    // ---- T10: passthrough stalls at every point of an arm cycle -------------
    task automatic t10_stalls();
        logic [31:0] last;
        int lens[$];
        $display("\n--- T10 passthrough reads colliding with every arm-cycle phase ---");
        wr(A_ALARM, 32'd2);
        rd(A_RTCDR, last);
        for (k = 0; k <= 22; k++) begin
            wait_state(S_ICR_SETUP, 6 * TICK_PCLK, ok);
            if (k > 0) cycles(k);
            rd_now(A_RTCDR, d);
            lens.push_back(stalls);
            check(!slverr && stalls <= 40 && d >= last,
                  $sformatf("T10 read %0d PCLK into alarm service: completes, %0d wait states, time monotonic", k, stalls));
            last = d;
        end
        // the first arm after a warm reset goes through ENABLE as well
        for (k = 0; k <= 8; k++) begin
            rd(A_RTCDR, t0);
            assert_reset(1'b0);
            cycles(3);
            PRESETn = 1'b1;
            if (k > 0) cycles(k);
            rd_now(A_RTCDR, d);
            lens.push_back(stalls);
            check(!slverr && stalls <= 40 && d >= t0,
                  $sformatf("T10 read %0d PCLK after warm reset: completes, %0d wait states, RTC time kept", k, stalls));
        end
        $write("      stall lengths seen:");
        foreach (lens[j]) $write(" %0d", lens[j]);
        $display("");
    endtask

    // ---- T11: back-to-back passthrough reads across the alarm ---------------
    task automatic t11_b2b_burst();
        logic [31:0] last;
        int trig0, deferred, bad, waited;
        $display("\n--- T11 back-to-back passthrough reads across an alarm ---");
        force_arm(32'd2, -1, 0, mr, ok);
        // poll until one second prev_val the alarm
        for (i = 0; i < 1000; i++) begin rd(A_RTCDR, d); if (d + 1 >= mr) break; cycles(10); end
        trig0 = n_rtc_trig; bad = 0; last = d;
        n0 = n_intr_rise_pt;
        for (i = 0; i < 90; i++) begin
            xfer(1'b0, A_RTCDR, 0, 0, PROT_PRIV, (i != 89), 1'b0);
            if (stalls != 0 || slverr || rdat < last) bad++;
            last = rdat;
        end
        deferred = n_rtc_trig - trig0;
        check(bad == 0, "T11 90 back-to-back RTCDR reads: no wait states, no error, time monotonic");
        check(n_intr_rise_pt > n0, "T11 RTCINTR rose while a passthrough owned the PL031 bus");
        for (waited = 0; waited < 40 && n_rtc_trig == trig0; waited++) cycles(1);
        check(n_rtc_trig > trig0, "T11 alarm serviced once the passthrough burst ends");
        if (deferred == 0)
            $display("      NOTE: alarm service deferred for the whole burst (serviced %0d PCLK after it ended)", waited);
        wr(A_ALARM, 32'd5);
    endtask

    // ---- T12: FIFO_CLEAR racing a sample push --------------------------------
    task automatic t12_clear_race();
        int bad, nc0;
        $display("\n--- T12 FIFO_CLEAR in the same cycle as a sample push ---");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        bad = 0; nc0 = n_clear_push;
        // Sweep wide enough to cover a whole SAR ADC conversion (>= 10 ADC
        // clocks at PCLK/(2*ADC_CLK_DIV) plus the valid CDC, ~80-100 PCLK);
        // the old 0..30 range was sized for dummy_adc and never lined up.
        for (k = 0; k <= 200; k++) begin
            wr(A_TRIG, 32'h1);
            if (k > 0) cycles(k);
            wr(A_FCLR, 32'h1);
            wait_fsm_idle();
            fifo_field(f);
            if (!((f == 2'b00 && sb.size() == 0) || (f == 2'b01 && sb.size() == 1))) bad++;
            if (sb.size() == 1) read_meas_check("T12 sample pushed after the clear");
            fifo_field(f);
            if (f != 2'b00) bad++;
        end
        check(bad == 0, "T12 clear vs push: FIFO ends empty or with exactly the later sample, status consistent");
        check(n_clear_push > nc0, "T12 sweep produced a clear and a push in the same cycle");
        check(sb_err == 0, "T12 FIFO scoreboard consistent");
    endtask

    // ---- T14: interrupt and clock registers ---------------------------------
    // IRQ: a registered level, high while an enabled condition holds
    // (irq_enable [0] FIFO not empty, [1] FIFO full); it falls within three
    // PCLK of the read (or clear) that removes the condition.
    task automatic irq_falls_within(input int max_cyc, input string nm);
        int j;
        for (j = 0; j <= max_cyc && IRQ; j++) cycles(1);
        check(!IRQ, $sformatf("%s (fell after %0d PCLK, bound %0d)", nm, j, max_cyc));
    endtask
    // One manual conversion with the ADC clock at clkdiv / samplediv; returns
    // the PCLK cycles from the trigger write to the FIFO push (-1: no push).
    task automatic timed_sample(input logic [31:0] cdiv, input logic [31:0] sdiv, output int n);
        int j, p0;
        wr(A_CLKDIV, cdiv); wr(A_SDIV, sdiv);
        p0 = n_push;
        wr(A_TRIG, 32'h1);
        n = -1;
        for (j = 0; j < 200_000; j++) begin
            @(posedge PCLK); #1;
            if (n_push != p0) begin n = j; break; end
            if (uut.u_ctrl.state == 3'd7) break;          // timed out
        end
        for (j = 0; j < 100 && uut.u_ctrl.state != 3'd0; j++) cycles(1);
        cycles(2);
    endtask
    task automatic t14_irq_clock_regs();
        bit ok2;
        int j, n_a, n_b, n_c, n_d, n_e;
        $display("\n--- T14 interrupt and clock registers ---");
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        // enables off: samples never raise IRQ
        wr(A_IRQEN, 32'h0);
        manual_sample(ok2); manual_sample(ok2);
        cycles(3);
        check(ok2 && !IRQ, "T14 IRQ_ENABLE = 0: IRQ stays low with samples in the FIFO");
        // [0] sample ready: rises once enabled, stays while samples remain,
        // falls after the read that empties the FIFO
        wr(A_IRQEN, 32'h1);
        cycles(2);
        check(IRQ, "T14 IRQ_ENABLE[0]: enabling with samples waiting raises IRQ");
        read_meas_check("T14 first of two");
        cycles(3);
        check(IRQ, "T14 IRQ_ENABLE[0]: IRQ stays high while a sample remains");
        read_meas_check("T14 last sample");
        irq_falls_within(3, "T14 IRQ_ENABLE[0]: IRQ falls after the read that empties the FIFO");
        manual_sample(ok2);
        cycles(1);
        check(ok2 && IRQ, "T14 IRQ_ENABLE[0]: a new sample raises IRQ");
        wr(A_IRQEN, 32'h0);
        irq_falls_within(2, "T14 clearing the enable drops IRQ");
        wr(A_IRQEN, 32'h1);
        cycles(2);
        wr(A_FCLR, 32'h1);
        irq_falls_within(3, "T14 FIFO_CLEAR drops IRQ");
        // [1] FIFO full only
        wr(A_IRQEN, 32'h2);
        for (j = 0; j < 15; j++) manual_sample(ok2);
        cycles(3);
        check(sb.size() == 15 && !IRQ, "T14 IRQ_ENABLE[1]: 15 samples (not full): IRQ low");
        manual_sample(ok2);
        cycles(1);
        check(sb.size() == 16 && IRQ, "T14 IRQ_ENABLE[1]: the 16th sample (FIFO full) raises IRQ");
        n0 = n_push;
        wr(A_TRIG, 32'h1); wait_fsm_idle();
        rd(A_STATUS, d);
        check(n_push == n0 && d[4] && IRQ, "T14 IRQ_ENABLE[1]: a dropped sample keeps IRQ high (STATUS drop set)");
        read_meas_check("T14 pop from full");
        irq_falls_within(3, "T14 IRQ_ENABLE[1]: IRQ falls after the read that ends FIFO full");
        // both: a non-empty FIFO keeps IRQ high through the end of FIFO full
        wr(A_IRQEN, 32'h3);
        cycles(2);
        check(IRQ, "T14 IRQ_ENABLE = 3: IRQ high with samples waiting");
        while (sb.size() > 1) read_meas_check("T14 drain");
        cycles(3);
        check(IRQ, "T14 IRQ_ENABLE = 3: IRQ high while one sample remains");
        read_meas_check("T14 drain last");
        irq_falls_within(3, "T14 IRQ_ENABLE = 3: IRQ falls once the FIFO is empty");
        // RTC_PRESCALE drives the output for the tick divider
        wr(A_PRESC, 32'd50);
        check(RTC_PRESCALE == 32'd50, "T14 RTC_PRESCALE output follows the register");
        wr(A_PRESC, PRESC_RST);
        // ADC clock registers: a slower clock or a longer sampling phase
        // lengthens the conversion; 0 selects the default; divider 255 (the
        // slowest) converts within the FIX-2 timeout (TMO-DIV)
        wr(A_FCLR, 32'h1);
        timed_sample(32'd2, 32'd0, n_a);
        timed_sample(32'd8, 32'd0, n_b);
        timed_sample(32'd8, 32'd40, n_c);
        timed_sample(32'd0, 32'd0, n_d);
        $display("      conversion PCLK: clkdiv 2 -> %0d, 8 -> %0d, 8 + samplediv 40 -> %0d, 0 (default %0d) -> %0d",
                 n_a, n_b, n_c, CLKDIV_RST, n_d);
        check(n_a > 0 && n_b > n_a, "T14 ADC_CLKDIV: a slower ADC clock takes longer");
        check(n_c > n_b, "T14 ADC_SAMPLEDIV: a longer sampling phase takes longer");
        check(n_d > n_a && n_d < n_b, "T14 ADC_CLKDIV = 0 selects ADC_CLK_DIV");
        timed_sample(32'd255, 32'd255, n_e);
        rd(A_STATUS, d);
        check(n_e > 0 && !d[6], $sformatf("T14 slowest ADC clock (255/255) converts within the timeout (%0d of %0d PCLK)",
                                          n_e, uut.CONV_TIMEOUT));
        wr(A_CLKDIV, CLKDIV_RST); wr(A_SDIV, SDIV_RST);
        while (sb.size() > 0) read_meas_check("T14 drain timed");
        // leave IRQ high with a sample waiting: T13's resets must clear it
        manual_sample(ok2);
        wr(A_IRQEN, 32'h1);
        cycles(2);
        check(IRQ, "T14 IRQ high before the T13 resets");
        set_poll(1'b1);
    endtask

    // ---- T13: reset in the middle of activity --------------------------------
    // Assert a reset of `kind` with the bus in `phase` (0 idle, 1 SETUP,
    // 2 ACCESS of a stalled RTC passthrough), then check recovery.
    task automatic reset_mid(input bit por, input int phase, input string nm);
        logic [31:0] tb4, ta;
        bit ok2;
        // A power-on case needs a time well above the restart window, or the
        // "count restarted" check can't tell a reset from a counter that was
        // already small (back-to-back POR cases leave it at ~2 s).
        if (por) begin wr(A_RTCLR, 32'd1000); rd(A_RTCDR, tb4); end
        rd(A_RTCDR, tb4);
        if (phase == 0) cycles(2);     // bus idle for a full cycle prev_val the reset
        if (phase == 1) begin
            @(posedge PCLK); #1;
            PSEL = 1'b1; PENABLE = 1'b0; PWRITE = 1'b1; PADDR = A_PLL; PWDATA = 32'hDEAD_BEEF; PSTRB = 4'hF;
            cycles(1);
        end else if (phase == 2) begin
            wait_state(S_ICR_SETUP, 8 * TICK_PCLK, ok2);
            PSEL = 1'b1; PENABLE = 1'b0; PWRITE = 1'b0; PADDR = A_RTCDR; PSTRB = 4'h0;
            cycles(1); PENABLE = 1'b1;
            cycles(1);
            check(!PREADY, {nm, ": reset lands on a stalled passthrough ACCESS"});
        end
        assert_reset(por);
        cycles(4);
        release_reset(por);
        check_reset_values(nm, !por);
        if (por) begin
            wait_rtc_out_of_reset(ok2);
            rd(A_RTCDR, ta);
            check(ta <= 32'd2 && (tb4 > 32'd2), $sformatf("%s: power-on reset restarts the RTC count (RTCDR %0d after, %0d before)", nm, ta, tb4));
        end else begin
            rd(A_RTCDR, ta);
            check(ta >= tb4, {nm, ": warm reset keeps RTC time (decision #3)"});
        end
        expect_fire(8, fired);
        check(fired, {nm, ": autonomous sampling restarts after the reset"});
    endtask

    task automatic t13_resets();
        bit ok2;
        int j;
        $display("\n--- T13 reset during bus / conversion / FIFO / RTC activity ---");
        reset_mid(1'b0, 0, "T13 warm idle");
        reset_mid(1'b0, 1, "T13 warm SETUP");
        reset_mid(1'b0, 2, "T13 warm ACCESS");
        // make the RTC count large so a POR restart is visible
        rd(A_RTCDR, t0); wr(A_RTCLR, t0 + 32'd50);
        reset_mid(1'b1, 0, "T13 POR idle");
        wr(A_RTCLR, 32'd50);
        reset_mid(1'b1, 1, "T13 POR SETUP");
        wr(A_RTCLR, 32'd50);
        reset_mid(1'b1, 2, "T13 POR ACCESS");
        // during a conversion, with data in the FIFO
        set_poll(1'b0);
        wait_fsm_idle();
        wr(A_FCLR, 32'h1);
        manual_sample(ok2);
        wr(A_TRIG, 32'h1);
        for (j = 0; j < 50 && !uut.adc_en; j++) cycles(1);
        cycles(2);                     // conversion running for a couple of cycles
        check(uut.adc_en && sb.size() == 1,
              $sformatf("T13 precondition: conversion running (%0d), FIFO holding a sample (%0d)", uut.adc_en, sb.size()));
        assert_reset(1'b0); cycles(3); release_reset(1'b0);
        j = n_rtc_trig;                // polling is on again after the reset (rtc_ctrl resets to 1)
        cycles(40);
        fifo_field(f);
        check(f == 2'b00, "T13 reset mid-conversion: FIFO empty, aborted conversion not pushed");
        // ADC idle - unless autonomous polling (on out of reset) has legitimately
        // started a new conversion since the release: with DEFAULT_ALARM_OFFSET 1
        // (WRP-7 build) the first alarm comes within ~a tick of the release
        rd(A_STATUS, d); check(d[3:2] == 2'b00 || n_rtc_trig != j,
                               "T13 reset mid-conversion: ADC idle (or running a sample triggered after the reset)");
        manual_sample(ok2); check(ok2, "T13 manual sampling works after a reset mid-conversion");
        read_meas_check("T13 post-reset sample");
        // RTC controller arming / servicing / idle when reset hits
        wait_state(S_READ_SETUP, 8 * TICK_PCLK, ok2);
        check(ok2, "T13 precondition: controller starts an arm cycle");
        cycles(1);
        assert_reset(1'b0); cycles(3); release_reset(1'b0);
        check_reset_values("T13 warm while arming", 1'b1);
        wait_state(S_ICR_SETUP, 8 * TICK_PCLK, ok2);
        cycles(1);
        assert_reset(1'b0); cycles(3); release_reset(1'b0);
        check_reset_values("T13 warm while servicing", 1'b1);
        assert_reset(1'b1); cycles(3); release_reset(1'b1);   // counter in reset -> FSM idle
        cycles(5);
        check(uut.u_rtc.state == S_IDLE, "T13 precondition: controller idle (counter in reset)");
        assert_reset(1'b0); cycles(3);
        PRESETn = 1'b1;
        cycles(5);                     // soon (4-31 cycles) after release
        check_reset_values("T13 warm while RTC idle", 1'b1);
        wait_rtc_out_of_reset(ok2);
        expect_fire(8, fired);
        check(fired, "T13 autonomous sampling after the reset sequence");
    endtask

    // ================================================================ main
    initial begin
        $dumpfile("sens_gap_tb.vcd");
        $dumpvars(0, sens_gap_tb);
        for (int j = 0; j <= 40; j++) stall_hist[j] = 0;

        t1_por_reset_values();
        t2_rw_readback();
        t3_decode();
        t4_direction_bits_prot();
        t5_pstrb();
        t6_rtc_words();
        t7_alarm_while_paused();
        t8_offsets();
        t9_rtclr_forward();
        t10_stalls();
        t11_b2b_burst();
        t12_clear_race();
        t14_irq_clock_regs();
        t13_resets();

        $display("\n--- global checks ---");
        check(n_pslverr == 0, "G no transfer ever completed with PSLVERR (decision #2)");
        check(n_hang == 0, "G no transfer stalled for more than 200 PCLK");
        check(max_stall <= 40, $sformatf("G longest passthrough stall %0d PCLK (bound 40)", max_stall));
        check(sb_err == 0, "G FIFO scoreboard never popped an empty model");
        $write("      stall histogram (wait states:count):");
        for (int j = 0; j <= 40; j++) if (stall_hist[j] != 0) $write(" %0d:%0d", j, stall_hist[j]);
        $display("");
        bugcheck(pl031_access_no_setup == 0 && pl031_setup_no_access == 0, "PL031-APB",
                 $sformatf("G PL031 port sees only SETUP->ACCESS pairs (%0d ACCESS w/o SETUP, %0d SETUP w/o ACCESS)",
                           pl031_access_no_setup, pl031_setup_no_access));

        $display("\n=== SENS-GAP: %0d PASSED, %0d FAILED (%0d of them suspected RTL bugs) ===",
                 pass_count, fail_count, bug_count);
        #100 $finish;
    end

    initial begin
        #400_000_000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== SENS-GAP: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end
endmodule
