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
            forever begin
                // Explicit reset each cycle: a variable declared inside the
                // `forever` body is NOT re-initialised per iteration under
                // this simulator version, so without it the last push was
                // re-published every cycle.
                s = null;
                @(posedge vif.clk);
                if (!vif.rst_n) continue;
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
        int unsigned n_checks, n_errors, n_samples_checked, n_drops, n_waited, max_wait;

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
                check(t.rdata[31:6] == 0, $sformatf("STATUS reserved bits set: 0x%08h", t.rdata));
            end else if (!is_mapped(t.addr)) begin
                check(t.rdata == 0, $sformatf("unmapped 0x%03h must read 0, got 0x%08h", t.addr, t.rdata));
            end
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("SB", $sformatf("checks=%0d errors=%0d samples-checked=%0d drops=%0d waited-xfers=%0d max-wait=%0d",
                      n_checks, n_errors, n_samples_checked, n_drops, n_waited, max_wait), UVM_NONE)
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
        function new(string name = "sensing_base_seq"); super.new(name); endfunction

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
            phase.drop_objection(this);
        endtask
    endclass
endpackage
