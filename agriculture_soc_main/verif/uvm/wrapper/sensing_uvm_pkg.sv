// -----------------------------------------------------------------------------
// sensing_uvm_pkg.sv — UVM environment for the whole sensing peripheral
// (adc_apb_wrapper_rev2 = RTC controller + sampling FSM + ADC + FIFO), driven
// through its APB port exactly as firmware would drive it.
//
// NEEDS ARM IP for sign-off (the wrapper instantiates rtc_control_2 -> PL031).
// It can be compile/smoke-checked without ARM IP using verif/stubs/pl031_stub.v
// (make -C verif/uvm/wrapper STUB_RTC=1) — results from the stub are NOT
// sign-off results.
//
//   sensing_scoreboard  register mirror for the RW registers (read-back
//                       checks), unmapped reads return 0, PSLVERR is never
//                       asserted (decision #2), and END-TO-END sample
//                       integrity: every value pushed into the FIFO by the FSM
//                       (snooped via sample_if) must come back out of
//                       MEASUREMENT_LO in order, honouring drops and clears.
//   sensing_apb_cov     APB transaction coverage (register x direction,
//                       wait-state histogram for RTC accesses)
//   sequences           reg read-back, manual sampling, overflow, clear,
//                       RTC passthrough storm, poll pause/resume, random
//   tests               sensing_smoke_test, sensing_full_test
// -----------------------------------------------------------------------------
package sensing_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import apb_uvm_pkg::*;

    // ── Register map (keep in sync with adc_apb_wrapper_rev2 / sensing_ip.h) ─
    localparam bit [11:0] REG_STATUS    = 12'h004;
    localparam bit [11:0] REG_MEAS_HI   = 12'h008;
    localparam bit [11:0] REG_MEAS_LO   = 12'h00C;
    localparam bit [11:0] REG_PLL       = 12'h100;
    localparam bit [11:0] REG_AMUX      = 12'h104;
    localparam bit [11:0] REG_ADC_TRIG  = 12'h108;
    localparam bit [11:0] REG_ADC_CAL   = 12'h10C;
    localparam bit [11:0] REG_RTCDR     = 12'h200;
    localparam bit [11:0] REG_RTCMR     = 12'h204;
    localparam bit [11:0] REG_RTCLR     = 12'h208;
    localparam bit [11:0] REG_RTCCR     = 12'h20C;
    localparam bit [11:0] REG_RTCIMSC   = 12'h210;
    localparam bit [11:0] REG_RTCRIS    = 12'h214;
    localparam bit [11:0] REG_RTCMIS    = 12'h218;
    localparam bit [11:0] REG_RTCICR    = 12'h21C;
    localparam bit [11:0] REG_FIFO_CLR  = 12'h220;
    localparam bit [11:0] REG_ALARM_OFF = 12'h224;
    localparam bit [11:0] REG_RTC_CTRL  = 12'h228;
    localparam int        FIFO_DEPTH    = 16;

    // ── FIFO-push snoop (FSM -> FIFO), for end-to-end data checks ───────────
    class sample_item extends uvm_sequence_item;
        bit [7:0] data;
        bit       dropped;   // push attempted while full
        bit       clear;     // FIFO clear pulse (not a push)
        bit       reset;     // PRESETn asserted: every register and the FIFO reset
        `uvm_object_utils(sample_item)
        function new(string name = "sample_item"); super.new(name); endfunction
    endclass

    class sample_monitor extends uvm_monitor;
        `uvm_component_utils(sample_monitor)
        virtual sample_if vif;
        uvm_analysis_port #(sample_item) ap;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction
        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual sample_if)::get(this, "", "svif", vif))
                `uvm_fatal("NOVIF", "sample_if not set")
        endfunction
        task run_phase(uvm_phase phase);
            // Sample the push/clear at the rising edge where the FIFO acts on
            // it, but publish on the following falling edge: an APB read that
            // completes on that same rising edge saw the PRE-edge FIFO, so the
            // scoreboard must process the read first. Publishing mid-cycle
            // removes the same-timestep ordering race between the two monitors.
            sample_item s;
            bit in_reset = 0;
            forever begin
                // Explicit reset each cycle: a variable declared inside the
                // `forever` body is NOT re-initialised per iteration under
                // this simulator version, so without it the last push was
                // re-published every cycle.
                s = null;
                @(posedge vif.clk);
                if (!vif.rst_n) begin
                    // publish one reset item per reset pulse
                    if (!in_reset) begin
                        s = sample_item::type_id::create("rst");
                        s.reset = 1;
                        ap.write(s);
                        s = null;
                    end
                    in_reset = 1;
                    continue;
                end
                in_reset = 0;
                if (vif.clear) begin
                    s = sample_item::type_id::create("clr");
                    s.clear = 1;
                end else if (vif.push) begin
                    s = sample_item::type_id::create("push");
                    s.data = vif.data;
                    s.dropped = vif.full;
                end
                if (s != null) begin
                    @(negedge vif.clk);
                    ap.write(s);
                end
            end
        endtask
    endclass

    // ── Scoreboard ──────────────────────────────────────────────────────────
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_smp)

    class sensing_scoreboard extends uvm_component;
        `uvm_component_utils(sensing_scoreboard)
        uvm_analysis_imp_apb #(apb_item,    sensing_scoreboard) apb_export;
        uvm_analysis_imp_smp #(sample_item, sensing_scoreboard) smp_export;

        bit [31:0] mirror[bit [11:0]];   // RW register mirror
        bit [7:0]  fifo_model[$];
        int unsigned n_checks, n_errors, n_samples_checked, n_drops, n_waited, max_wait, n_resets;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            apb_export = new("apb_export", this);
            smp_export = new("smp_export", this);
        endfunction

        function void reset_model();
            mirror.delete();
            mirror[REG_PLL]       = 32'h0;
            mirror[REG_AMUX]      = 32'h0;
            mirror[REG_ADC_CAL]   = 32'h0;
            mirror[REG_ALARM_OFF] = 32'd5;     // DEFAULT_ALARM_OFFSET
            mirror[REG_RTC_CTRL]  = 32'h1;     // polling on
            fifo_model.delete();
        endfunction

        function void build_phase(uvm_phase phase); reset_model(); endfunction

        function void check(bit cond, string what);
            n_checks++;
            if (!cond) begin n_errors++; `uvm_error("SB", what) end
        endfunction

        function bit is_mapped(bit [11:0] a);
            return a inside {REG_STATUS, REG_MEAS_HI, REG_MEAS_LO, REG_PLL, REG_AMUX,
                             REG_ADC_TRIG, REG_ADC_CAL, REG_FIFO_CLR, REG_ALARM_OFF,
                             REG_RTC_CTRL} || (a >= 12'h200 && a <= 12'h21C);
        endfunction

        // FSM -> FIFO pushes
        function void write_smp(sample_item s);
            if (s.reset) begin reset_model(); n_resets++; return; end
            if (s.clear) begin fifo_model.delete(); return; end
            if (s.dropped) begin n_drops++; return; end
            fifo_model.push_back(s.data);
        endfunction

        // Completed APB transfers
        function void write_apb(apb_item t);
            check(!t.slverr, $sformatf("PSLVERR asserted (decision #2 forbids it): %s", t.convert2string()));
            if (t.waits > 0) n_waited++;
            if (t.waits > max_wait) max_wait = t.waits;

            if (t.write) begin
                case (t.addr)
                    REG_PLL, REG_AMUX, REG_ALARM_OFF: mirror[t.addr] = t.wdata;
                    REG_ADC_CAL, REG_RTC_CTRL:        mirror[t.addr] = {31'h0, t.wdata[0]};
                    default: ;
                endcase
                return;
            end

            // reads
            if (mirror.exists(t.addr)) begin
                check(t.rdata == mirror[t.addr],
                      $sformatf("readback 0x%03h exp 0x%08h got 0x%08h", t.addr, mirror[t.addr], t.rdata));
            end else if (t.addr == REG_MEAS_HI) begin
                check(t.rdata == 0, $sformatf("MEAS_HI must read 0 (8-bit ADC), got 0x%08h", t.rdata));
            end else if (t.addr == REG_MEAS_LO) begin
                if (fifo_model.size() > 0) begin
                    bit [7:0] exp = fifo_model.pop_front();
                    check(t.rdata == {24'h0, exp},
                          $sformatf("sample order/data: exp 0x%02h got 0x%08h", exp, t.rdata));
                    n_samples_checked++;
                end
            end else if (t.addr == REG_STATUS) begin
                check(t.rdata[31:7] == 0, $sformatf("STATUS reserved bits set: 0x%08h", t.rdata));
            end else if (!is_mapped(t.addr)) begin
                check(t.rdata == 0, $sformatf("unmapped 0x%03h must read 0, got 0x%08h", t.addr, t.rdata));
            end
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("SB", $sformatf("checks=%0d errors=%0d samples-checked=%0d drops=%0d waited-xfers=%0d max-wait=%0d resets=%0d",
                      n_checks, n_errors, n_samples_checked, n_drops, n_waited, max_wait, n_resets), UVM_NONE)
            check(max_wait <= 13, $sformatf("longest RTC passthrough stall %0d PCLK <= 13", max_wait));
        endfunction
    endclass

    // ── APB transaction coverage ────────────────────────────────────────────
    class sensing_apb_cov extends uvm_subscriber #(apb_item);
        `uvm_component_utils(sensing_apb_cov)
        apb_item t;
        covergroup cg_apb;
            option.per_instance = 1;
            cp_reg : coverpoint t.addr {
                bins status = {REG_STATUS}; bins meas_hi = {REG_MEAS_HI}; bins meas_lo = {REG_MEAS_LO};
                bins pll = {REG_PLL}; bins amux = {REG_AMUX}; bins adc_trig = {REG_ADC_TRIG};
                bins adc_cal = {REG_ADC_CAL}; bins rtcdr = {REG_RTCDR}; bins rtcmr = {REG_RTCMR};
                bins rtclr = {REG_RTCLR}; bins rtccr = {REG_RTCCR}; bins rtcimsc = {REG_RTCIMSC};
                bins rtcris = {REG_RTCRIS}; bins rtcmis = {REG_RTCMIS}; bins rtcicr = {REG_RTCICR};
                bins fifo_clr = {REG_FIFO_CLR}; bins alarm_off = {REG_ALARM_OFF}; bins rtc_ctrl = {REG_RTC_CTRL};
                bins unmapped = default;
            }
            cp_dir : coverpoint t.write { bins rd = {0}; bins wr = {1}; }
            x_reg_dir : cross cp_reg, cp_dir;
            cp_rtc_waits : coverpoint t.waits iff (t.addr >= 12'h200 && t.addr <= 12'h21C) {
                bins none = {0}; bins one = {1}; bins few = {[2:5]}; bins many = {[6:20]};
            }
        endgroup
        function new(string name, uvm_component parent);
            super.new(name, parent);
            cg_apb = new;
        endfunction
        function void write(apb_item t); this.t = t; cg_apb.sample(); endfunction
        function real coverage(); return cg_apb.get_inst_coverage(); endfunction
    endclass

    // ── Env ─────────────────────────────────────────────────────────────────
    class sensing_env extends uvm_env;
        `uvm_component_utils(sensing_env)
        apb_agent          apb;
        sample_monitor     smon;
        sensing_scoreboard sb;
        sensing_apb_cov    cov;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            apb  = apb_agent         ::type_id::create("apb",  this);
            smon = sample_monitor    ::type_id::create("smon", this);
            sb   = sensing_scoreboard::type_id::create("sb",   this);
            cov  = sensing_apb_cov   ::type_id::create("cov",  this);
        endfunction
        function void connect_phase(uvm_phase phase);
            apb.mon.ap.connect(sb.apb_export);
            apb.mon.ap.connect(cov.analysis_export);
            smon.ap.connect(sb.smp_export);
        endfunction
    endclass

    // ── Sequences ───────────────────────────────────────────────────────────
    class sensing_base_seq extends apb_base_seq;
        `uvm_object_utils(sensing_base_seq)
        virtual sample_if svif;
        function new(string name = "sensing_base_seq"); super.new(name); endfunction

        task pre_body();
            if (!uvm_config_db#(virtual sample_if)::get(null, "*", "svif", svif))
                `uvm_fatal("NOVIF", "sample_if not set")
        endtask

        // reset pulses, driven between transfers (the driver is idle)
        task warm_reset(int unsigned cycles = 4, int unsigned after = 3);
            repeat (2) @(posedge svif.clk);
            svif.seq_presetn = 1'b0;
            repeat (cycles) @(posedge svif.clk);
            svif.seq_presetn = 1'b1;
            repeat (after) @(posedge svif.clk);
        endtask
        task power_on_reset(bit with_presetn, int unsigned cycles = 6);
            repeat (2) @(posedge svif.clk);
            svif.seq_npor = 1'b0;
            if (with_presetn) svif.seq_presetn = 1'b0;
            repeat (cycles) @(posedge svif.clk);
            svif.seq_npor = 1'b1;
            repeat (2) @(posedge svif.clk);
            svif.seq_presetn = 1'b1;
            repeat (3) @(posedge svif.clk);
        endtask

        // Poll STATUS until the FIFO field is non-empty (or give up).
        task wait_fifo_nonempty(int unsigned max_polls = 200);
            bit [31:0] st;
            repeat (max_polls) begin
                rd(REG_STATUS, st, 2);
                if (st[1:0] != 2'b00) return;
            end
            `uvm_warning("SEQ", "FIFO never became non-empty")
        endtask

        // After an ADC trigger: wait until STATUS[3:2] (adc_en, held from
        // ENABLE through WAIT_DONE) reads idle. A fixed poll count was tuned for
        // dummy_adc and is too short for sar_adc (>=10 ADC clocks/conversion).
        // The first reads cover the FSM reaching ENABLE plus the STATUS register
        // delay; with the FIFO full the FSM never enables the ADC, so it returns.
        task wait_adc_idle(int unsigned max_polls = 400);
            bit [31:0] st;
            repeat (3) rd(REG_STATUS, st);
            repeat (max_polls) begin
                rd(REG_STATUS, st);
                if (st[3:2] == 2'b00) return;
            end
            `uvm_warning("SEQ", "ADC never returned to idle")
        endtask

        task drain(int unsigned max_reads = FIFO_DEPTH + 2);
            bit [31:0] st, d;
            repeat (max_reads) begin
                rd(REG_STATUS, st);
                if (st[1:0] == 2'b00) return;
                rd(REG_MEAS_LO, d);
            end
        endtask
    endclass

    // RW registers: write random values, read them back (scoreboard checks).
    class reg_rw_seq extends sensing_base_seq;
        `uvm_object_utils(reg_rw_seq)
        function new(string name = "reg_rw_seq"); super.new(name); endfunction
        task body();
            bit [31:0] d;
            repeat (3) begin
                wr(REG_PLL,  $urandom);       rd(REG_PLL,  d);
                wr(REG_AMUX, $urandom);       rd(REG_AMUX, d);
                wr(REG_ADC_CAL, $urandom);    rd(REG_ADC_CAL, d);
            end
            // read-only / write-only / unmapped behaviour
            rd(REG_MEAS_HI, d);
            rd(REG_ADC_TRIG, d);
            rd(REG_FIFO_CLR, d);
            rd(12'h010, d); rd(12'h0FC, d); rd(12'h300, d); rd(12'hFFC, d);
            wr(12'h300, 32'hDEAD_BEEF);       rd(12'h300, d);
            wr(REG_ADC_CAL, 0);
            wr(REG_AMUX, 0);
        endtask
    endclass

    // Manual one-shot samples (polling off so only manual triggers fire).
    class manual_sample_seq extends sensing_base_seq;
        `uvm_object_utils(manual_sample_seq)
        int unsigned n = 6;
        function new(string name = "manual_sample_seq"); super.new(name); endfunction
        task body();
            bit [31:0] d;
            wr(REG_RTC_CTRL, 0);
            for (int i = 0; i < n; i++) begin
                wr(REG_AMUX, i % 4);
                wr(REG_ADC_CAL, (i % 3) == 2);
                wr(REG_ADC_TRIG, 1);
                wait_fifo_nonempty();
                rd(REG_MEAS_LO, d);
            end
            wr(REG_ADC_CAL, 0);
            wr(REG_ADC_TRIG, 0);              // bit0 = 0: must NOT trigger
            wr(REG_RTC_CTRL, 1);
        endtask
    endclass

    // Overflow: more triggers than FIFO entries without draining -> drop bit.
    class overflow_seq extends sensing_base_seq;
        `uvm_object_utils(overflow_seq)
        function new(string name = "overflow_seq"); super.new(name); endfunction
        task body();
            bit [31:0] st, d;
            wr(REG_RTC_CTRL, 0);
            wr(REG_FIFO_CLR, 1);
            repeat (FIFO_DEPTH + 3) begin
                wr(REG_ADC_TRIG, 1);
                wait_adc_idle();                 // let the conversion finish
            end
            rd(REG_STATUS, st);
            if (!st[4]) `uvm_error("SEQ", $sformatf("drop bit not set after overflow, status=0x%08h", st))
            if (st[1:0] != 2'b10) `uvm_error("SEQ", $sformatf("FIFO not full after overflow, status=0x%08h", st))
            // read while full, then clear while full
            rd(REG_MEAS_LO, d);
            wr(REG_ADC_TRIG, 1); wait_adc_idle();
            wr(REG_FIFO_CLR, 1);
            rd(REG_STATUS, st);
            rd(REG_MEAS_LO, d);                  // read while empty
            wr(REG_RTC_CTRL, 1);
        endtask
    endclass

    // Firmware hammering the RTC passthrough while autonomous polling re-arms:
    // provokes collisions -> wait states (never PSLVERR).
    class rtc_passthru_seq extends sensing_base_seq;
        `uvm_object_utils(rtc_passthru_seq)
        int unsigned n = 150;
        function new(string name = "rtc_passthru_seq"); super.new(name); endfunction
        task body();
            bit [31:0] d;
            wr(REG_ALARM_OFF, 1);                // re-arm every second: many collisions
            for (int i = 0; i < n; i++) begin
                case ($urandom_range(0, 7))
                    0, 1, 2: rd(REG_RTCDR, d, 0);
                    3:       rd(REG_RTCRIS, d, 0);
                    4:       rd(REG_RTCMIS, d, 0);
                    5:       rd(REG_RTCCR, d, 0);
                    6:       rd(REG_RTCIMSC, d, 0);
                    7:       rd(REG_RTCMR, d, 0);
                endcase
                if (i % 16 == 0) drain();
            end
            wr(REG_RTCLR, 32'd1000);             // load the counter (time jump)
            rd(REG_RTCDR, d);
            wr(REG_ALARM_OFF, 0);                // edge case: zero offset
            repeat (20) rd(REG_RTCDR, d, 3);
            wr(REG_ALARM_OFF, 2);
            drain();
        endtask
    endclass

    // Pause / resume autonomous polling, incl. resuming with an alarm pending.
    class poll_toggle_seq extends sensing_base_seq;
        `uvm_object_utils(poll_toggle_seq)
        function new(string name = "poll_toggle_seq"); super.new(name); endfunction
        task body();
            bit [31:0] st;
            wr(REG_ALARM_OFF, 1);
            repeat (3) begin
                wr(REG_RTC_CTRL, 0);
                wr(REG_ADC_TRIG, 1);                     // manual while paused
                repeat (60) rd(REG_STATUS, st, 3);       // long enough for the alarm to fire
                wr(REG_RTC_CTRL, 1);                     // resume -> service pending alarm
                repeat (30) rd(REG_STATUS, st, 3);
                drain();
            end
            wr(REG_ALARM_OFF, 5);
        endtask
    endclass

    // Fully random register traffic (mapped + unmapped, both directions).
    class random_reg_seq extends sensing_base_seq;
        `uvm_object_utils(random_reg_seq)
        int unsigned n = 300;
        function new(string name = "random_reg_seq"); super.new(name); endfunction
        task body();
            bit [11:0] addrs[] = '{REG_STATUS, REG_MEAS_HI, REG_MEAS_LO, REG_PLL, REG_AMUX,
                                   REG_ADC_TRIG, REG_ADC_CAL, REG_RTCDR, REG_RTCRIS,
                                   REG_FIFO_CLR, REG_ALARM_OFF, REG_RTC_CTRL, 12'h014, 12'h400};
            bit [31:0] d;
            for (int i = 0; i < n; i++) begin
                bit [11:0] a = addrs[$urandom_range(0, addrs.size() - 1)];
                bit        w = $urandom_range(0, 1);
                bit [31:0] v = $urandom;
                // keep the alarm period short so the RTC stays active
                if (a == REG_ALARM_OFF) v = $urandom_range(1, 3);
                if (a == REG_RTC_CTRL)  v = $urandom_range(0, 3) != 0;   // mostly on
                if (w) wr(a, v, $urandom_range(0, 2));
                else   rd(a, d, $urandom_range(0, 2));
            end
            drain();
        endtask
    endclass


    // WRP-8: back-to-back (no idle) passthrough and register bursts, writes to
    // every PL031 register, long / mid / wrap offsets, simultaneous triggers.
    class rtc_b2b_seq extends sensing_base_seq;
        `uvm_object_utils(rtc_b2b_seq)
        function new(string name = "rtc_b2b_seq"); super.new(name); endfunction
        task body();
            bit [11:0] a[];
            bit        w[];
            bit [31:0] v[], r[];
            bit [31:0] d, now;
            // random_reg_seq may have left autonomous polling paused
            wr(REG_RTC_CTRL, 1);
            wr(REG_ALARM_OFF, 1);
            // back-to-back read bursts across alarms (deferral)
            repeat (20) begin
                int n = $urandom_range(2, 12);
                a = new[n]; w = new[n]; v = new[n];
                foreach (a[i]) begin
                    a[i] = (i % 3 == 2) ? REG_STATUS : 12'h200 + 4 * $urandom_range(0, 7);
                    w[i] = 0; v[i] = 0;
                end
                burst(a, w, v, r);
                drain();
            end
            // writes to every PL031 register, back to back with reads
            rd(REG_RTCDR, now);
            a = '{REG_RTCCR, REG_RTCIMSC, REG_RTCMR, REG_RTCICR, REG_RTCMIS, REG_RTCLR, REG_RTCICR, REG_RTCLR};
            w = '{1, 1, 1, 1, 1, 0, 0, 1};
            v = '{32'h1, 32'h1, now + 2, 32'h1, 32'h0, 32'h0, 32'h0, now};
            burst(a, w, v, r);
            repeat (10) rd(REG_RTCDR, d, 4);
            wr(REG_RTCIMSC, 0);                     // masked: the watchdog keeps sampling
            repeat (10) rd(REG_STATUS, d, 8);
            wr(REG_RTCIMSC, 1);
            rd(REG_RTCLR, d); rd(REG_RTCICR, d); rd(REG_RTCMIS, d);
            // mid / long / wrap offsets, then the RTCMR workaround to shorten them
            begin
                bit [31:0] offs[3] = '{32'd20, 32'd5000, 32'hFFFF_FFFF};
                foreach (offs[i]) begin
                    wr(REG_ALARM_OFF, offs[i]);
                    repeat (40) rd(REG_STATUS, d, 4);   // let the current period end and re-arm long
                    rd(REG_RTCDR, now);
                    wr(REG_RTCMR, now + 2);              // +2: a tick between the read and the write still matches
                    repeat (60) rd(REG_STATUS, d, 4);
                    drain();
                end
            end
            wr(REG_ALARM_OFF, 1);
            // simultaneous manual + RTC triggers: hammer ADC_TRIG back to back
            // across a few alarms so some writes land on the rtc_trig cycle
            repeat (6) begin
                a = new[24]; w = new[24]; v = new[24];
                foreach (a[i]) begin a[i] = REG_ADC_TRIG; w[i] = 1; v[i] = 1; end
                burst(a, w, v, r);
                drain();
            end
            // back-to-back register traffic mixing every wrapper register
            repeat (10) begin
                a = '{REG_PLL, REG_PLL, REG_AMUX, REG_AMUX, REG_ADC_CAL, REG_ADC_CAL, REG_STATUS, REG_MEAS_LO, REG_MEAS_HI, REG_ALARM_OFF};
                w = '{1, 0, 1, 0, 1, 0, 0, 0, 0, 0};
                v = '{$urandom, 0, $urandom, 0, 32'h0, 0, 0, 0, 0, 0};
                burst(a, w, v, r);
            end
            wr(REG_ALARM_OFF, 5);
            drain();
        endtask
    endclass

    // WRP-8: warm reset (PRESETn only: RTC time survives) and power-on resets
    // (nPOR alone, and nPOR with PRESETn), each followed by a check that the
    // registers are back at reset values and sampling restarts.
    class reset_seq extends sensing_base_seq;
        `uvm_object_utils(reset_seq)
        function new(string name = "reset_seq"); super.new(name); endfunction
        task body();
            bit [31:0] t0, t1, d;
            wr(REG_ALARM_OFF, 1);
            wr(REG_PLL, 32'hA5A5_0001);
            wr(REG_ADC_TRIG, 1);
            repeat (20) rd(REG_RTCDR, t0, 8);
            // warm reset, mid-traffic (a sample may be in flight)
            wr(REG_ADC_TRIG, 1);
            warm_reset();
            rd(REG_PLL, d);                        // scoreboard: back at 0
            rd(REG_ALARM_OFF, d);                  // back at 5
            rd(REG_RTC_CTRL, d);                   // back at 1
            rd(REG_RTCDR, t1);
            if (t1 < t0) `uvm_error("RST", $sformatf("RTC time went backwards across a warm reset (%0d -> %0d)", t0, t1))
            wr(REG_ALARM_OFF, 1);
            wait_fifo_nonempty(400);
            drain();
            // nPOR alone (counter domain only)
            power_on_reset(0);
            repeat (60) rd(REG_STATUS, d, 4);
            rd(REG_RTCDR, t0);
            repeat (40) rd(REG_STATUS, d, 4);
            rd(REG_RTCDR, t1);
            if (!(t1 > t0)) `uvm_error("RST", $sformatf("RTC counter not running after nPOR (%0d -> %0d)", t0, t1))
            wait_fifo_nonempty(400);
            drain();
            // full power-on reset
            power_on_reset(1);
            rd(REG_ALARM_OFF, d);
            wr(REG_ALARM_OFF, 1);
            wait_fifo_nonempty(600);
            drain();
            wr(REG_ALARM_OFF, 5);
        endtask
    endclass


    // WRP-8 coverage: traffic shapes the other sequences do not produce -
    // long back-to-back trigger bursts (trigger in every FSM state, RTC and
    // manual in one cycle, FSM back-to-back write/drop -> check), a long RTC
    // read burst over an alarm (deferral beyond the watchdog), fast polling
    // toggles (disable inside the RTCICR service), offset writes while arming,
    // RTC reads straight after a warm reset (stall in the enable states), and
    // 40 samples without a clear (FIFO pointer wrap).
    class cov_fill_seq extends sensing_base_seq;
        `uvm_object_utils(cov_fill_seq)
        function new(string name = "cov_fill_seq"); super.new(name); endfunction
        task trig_burst(int n);
            bit [11:0] a[]; bit w[]; bit [31:0] v[], r[];
            a = new[n]; w = new[n]; v = new[n];
            foreach (a[i]) begin a[i] = REG_ADC_TRIG; w[i] = 1; v[i] = 1; end
            burst(a, w, v, r);
        endtask
        task body();
            bit [11:0] a[]; bit w[]; bit [31:0] v[], r[];
            bit [31:0] d;
            wr(REG_RTC_CTRL, 1);
            wr(REG_ALARM_OFF, 1);
            wr(REG_FIFO_CLR, 1);
            // triggers back to back for longer than a conversion, FIFO not full
            repeat (4) begin trig_burst(150); drain(); end
            // ... and with the FIFO full (drop -> check back to back)
            repeat (FIFO_DEPTH + 2) begin wr(REG_ADC_TRIG, 1); wait_adc_idle(); end
            repeat (2) trig_burst(150);
            drain(); wr(REG_FIFO_CLR, 1);
            // a long RTC read burst across an alarm: deferred past the watchdog
            repeat (3) begin
                a = new[120]; w = new[120]; v = new[120];
                foreach (a[i]) begin a[i] = REG_RTCDR + 4 * (i % 8); w[i] = 0; v[i] = 0; end
                burst(a, w, v, r);
                drain();
            end
            // short bursts of 5..30 RTC reads (defer 9..64 cycles)
            for (int n = 5; n <= 30; n += 5) begin
                a = new[n]; w = new[n]; v = new[n];
                foreach (a[i]) begin a[i] = REG_RTCDR; w[i] = 0; v[i] = 0; end
                burst(a, w, v, r);
            end
            // fast polling toggles
            repeat (300) begin wr(REG_RTC_CTRL, 0); wr(REG_RTC_CTRL, 1); end
            drain();
            // offset rewritten (changing) at random points of the arm cycle
            repeat (40) begin wr(REG_ALARM_OFF, 2, $urandom_range(0, 5)); wr(REG_ALARM_OFF, 1, $urandom_range(0, 5)); end
            // RTC reads at 0..4 cycles after a warm reset release
            for (int k = 0; k < 5; k++) begin
                warm_reset(4, k);
                rd(REG_RTCDR, d, 0);
            end
            wr(REG_ALARM_OFF, 1);
            // 40 manual samples drained one by one, no clear: pointers wrap
            wr(REG_RTC_CTRL, 0);
            repeat (40) begin
                wr(REG_ADC_TRIG, 1);
                wait_fifo_nonempty();
                rd(REG_MEAS_LO, d);
            end
            wr(REG_RTC_CTRL, 1);
            wr(REG_ALARM_OFF, 5);
            drain();
        endtask
    endclass

    // ── Tests ───────────────────────────────────────────────────────────────
    class sensing_base_test extends uvm_test;
        `uvm_component_utils(sensing_base_test)
        sensing_env env;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            env = sensing_env::type_id::create("env", this);
        endfunction
        task run_seq(uvm_sequence #(apb_item) s); s.start(env.apb.sqr); endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server rs = uvm_report_server::get_server();
            int errs = rs.get_severity_count(UVM_ERROR) + rs.get_severity_count(UVM_FATAL);
            $display("SENSING-UVM APB transaction coverage: %0.2f%%", env.cov.coverage());
            $display("\n=== SENSING-UVM: %0d PASSED, %0d FAILED ===", env.sb.n_checks - env.sb.n_errors, errs);
        endfunction
    endclass

    class sensing_smoke_test extends sensing_base_test;
        `uvm_component_utils(sensing_smoke_test)
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            run_seq(reg_rw_seq::type_id::create("rw"));
            run_seq(manual_sample_seq::type_id::create("manual"));
            phase.drop_objection(this);
        endtask
    endclass

    class sensing_full_test extends sensing_base_test;
        `uvm_component_utils(sensing_full_test)
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            run_seq(reg_rw_seq::type_id::create("rw"));
            run_seq(manual_sample_seq::type_id::create("manual"));
            run_seq(overflow_seq::type_id::create("ovf"));
            run_seq(rtc_passthru_seq::type_id::create("pt"));
            run_seq(poll_toggle_seq::type_id::create("poll"));
            run_seq(random_reg_seq::type_id::create("rnd"));
            run_seq(rtc_b2b_seq::type_id::create("b2b"));
            run_seq(reset_seq::type_id::create("rst"));
            run_seq(cov_fill_seq::type_id::create("fill"));
            phase.drop_objection(this);
        endtask
    endclass
endpackage
