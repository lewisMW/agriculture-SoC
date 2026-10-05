// -----------------------------------------------------------------------------
// fifo_uvm_pkg.sv — UVM environment for fifo_apb_adc.
//
//   fifo_item        one clock cycle of stimulus (+ the observed outputs)
//   fifo_driver      drives an item onto fifo_if on the falling edge
//   fifo_monitor     samples every cycle on the rising edge -> analysis port
//   fifo_scoreboard  queue reference model; checks read data and flags
//   fifo_coverage    transaction-level covergroup (uvm_subscriber)
//   fifo_agent/env   the usual containers
//   sequences        random (biased), fill/overflow, drain/underflow, clear
//   tests            fifo_smoke_test, fifo_full_test (closes coverage)
//
// Design-level coverage (verif/cov/fifo_cov.sv) is bound into the DUT too, so
// a run reports BOTH what the stimulus asked for (this package) and what the
// design actually did (the bound model).
// -----------------------------------------------------------------------------
package fifo_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 4;

    // ── Transaction ──────────────────────────────────────────────────────────
    class fifo_item extends uvm_sequence_item;
        rand bit                  wr;
        rand bit                  rd;
        rand bit                  clear;
        rand bit [DATA_WIDTH-1:0] data;
        // observed by the monitor (pre-edge values the DUT acts on)
        bit                  full;
        bit                  empty;
        bit [DATA_WIDTH-1:0] rd_data;

        // wr/rd/clear are biased by the SEQUENCE (see fifo_rand_seq), not by
        // `dist` here: Verilator 5.052 reports a dist with variable weights
        // (e.g. `1 := wr_pct`) as unsatisfiable. Constant-weight dist is fine.
        // corner data values show up often enough to be covered
        constraint c_data  { data dist {8'h00 := 10, 8'hFF := 10, [8'h01:8'hFE] :/ 80}; }

        `uvm_object_utils(fifo_item)
        function new(string name = "fifo_item"); super.new(name); endfunction

        function string convert2string();
            return $sformatf("wr=%0b rd=%0b clr=%0b data=%02h | full=%0b empty=%0b rd_data=%02h",
                             wr, rd, clear, data, full, empty, rd_data);
        endfunction
    endclass

    typedef uvm_sequencer #(fifo_item) fifo_sequencer;

    // ── Driver ───────────────────────────────────────────────────────────────
    class fifo_driver extends uvm_driver #(fifo_item);
        `uvm_component_utils(fifo_driver)
        virtual fifo_if vif;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "fifo_if not set")
        endfunction

        task run_phase(uvm_phase phase);
            vif.adc_wr_en  <= 0; vif.apb_rd_en <= 0;
            vif.fifo_clear <= 0; vif.adc_data  <= '0;
            forever begin
                seq_item_port.get_next_item(req);
                @(negedge vif.clk);
                vif.adc_wr_en  <= req.wr;
                vif.apb_rd_en  <= req.rd;
                vif.fifo_clear <= req.clear;
                vif.adc_data   <= req.data;
                seq_item_port.item_done();
            end
        endtask
    endclass

    // ── Monitor ──────────────────────────────────────────────────────────────
    class fifo_monitor extends uvm_monitor;
        `uvm_component_utils(fifo_monitor)
        virtual fifo_if vif;
        uvm_analysis_port #(fifo_item) ap;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "fifo_if not set")
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                fifo_item t;
                @(posedge vif.clk);
                if (!vif.rst_n) continue;
                t = fifo_item::type_id::create("t");
                t.wr      = vif.adc_wr_en;
                t.rd      = vif.apb_rd_en;
                t.clear   = vif.fifo_clear;
                t.data    = vif.adc_data;
                t.full    = vif.fifo_full;
                t.empty   = vif.fifo_empty;
                t.rd_data = vif.apb_rd_data;
                ap.write(t);
            end
        endtask
    endclass

    // ── Scoreboard: queue reference model ───────────────────────────────────
    class fifo_scoreboard extends uvm_subscriber #(fifo_item);
        `uvm_component_utils(fifo_scoreboard)
        bit [DATA_WIDTH-1:0] model[$];
        int unsigned n_checks, n_errors, n_pushes, n_pops, n_drops, n_underflows;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        function void check(bit cond, string what, fifo_item t);
            n_checks++;
            if (!cond) begin
                n_errors++;
                `uvm_error("SB", $sformatf("%s  [model size=%0d] %s", what, model.size(), t.convert2string()))
            end
        endfunction

        function void write(fifo_item t);
            // Flags reflect the occupancy BEFORE this edge
            check(t.full  == (model.size() == DEPTH), "fifo_full mismatch", t);
            check(t.empty == (model.size() == 0),     "fifo_empty mismatch", t);

            if (t.clear) begin
                model.delete();
                return;
            end
            // Read data is combinational from rd_ptr: check it before popping
            if (t.rd && model.size() > 0) begin
                check(t.rd_data == model[0], $sformatf("read data exp %02h", model[0]), t);
            end
            begin
                bit do_wr = t.wr && (model.size() < DEPTH);
                bit do_rd = t.rd && (model.size() > 0);
                if (t.wr && !do_wr) n_drops++;
                if (t.rd && !do_rd) n_underflows++;
                if (do_rd) begin void'(model.pop_front()); n_pops++; end
                if (do_wr) begin model.push_back(t.data);  n_pushes++; end
            end
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("SB", $sformatf("checks=%0d errors=%0d pushes=%0d pops=%0d dropped-writes=%0d underflow-reads=%0d",
                      n_checks, n_errors, n_pushes, n_pops, n_drops, n_underflows), UVM_NONE)
        endfunction
    endclass

    // ── Transaction-level coverage ──────────────────────────────────────────
    // Covers the STIMULUS + observed flags. (The bound fifo_cov covers the
    // design's internal state: pointers, count transitions.)
    class fifo_coverage extends uvm_subscriber #(fifo_item);
        `uvm_component_utils(fifo_coverage)
        fifo_item t;

        covergroup cg_txn;
            option.per_instance = 1;
            cp_op : coverpoint {t.wr, t.rd} iff (!t.clear) {
                bins idle = {2'b00}; bins rd_only = {2'b01};
                bins wr_only = {2'b10}; bins rd_wr = {2'b11};
            }
            cp_flags : coverpoint {t.full, t.empty} {
                bins partial = {2'b00}; bins empty = {2'b01}; bins full = {2'b10};
            }
            x_op_flags : cross cp_op, cp_flags;
            cp_clear_flags : coverpoint {t.full, t.empty} iff (t.clear) {
                bins clr_partial = {2'b00}; bins clr_empty = {2'b01}; bins clr_full = {2'b10};
            }
            cp_data : coverpoint t.data iff (t.wr) {
                bins zero = {8'h00}; bins ones = {8'hFF};
                bins low = {[8'h01:8'h7F]}; bins high = {[8'h80:8'hFE]};
            }
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            cg_txn = new;
        endfunction

        function void write(fifo_item t);
            this.t = t;
            cg_txn.sample();
        endfunction

        function real coverage(); return cg_txn.get_inst_coverage(); endfunction
    endclass

    // ── Agent / Env ─────────────────────────────────────────────────────────
    class fifo_agent extends uvm_agent;
        `uvm_component_utils(fifo_agent)
        fifo_sequencer sqr;
        fifo_driver    drv;
        fifo_monitor   mon;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            sqr = fifo_sequencer::type_id::create("sqr", this);
            drv = fifo_driver   ::type_id::create("drv", this);
            mon = fifo_monitor  ::type_id::create("mon", this);
        endfunction
        function void connect_phase(uvm_phase phase);
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class fifo_env extends uvm_env;
        `uvm_component_utils(fifo_env)
        fifo_agent      agt;
        fifo_scoreboard sb;
        fifo_coverage   cov;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            agt = fifo_agent     ::type_id::create("agt", this);
            sb  = fifo_scoreboard::type_id::create("sb",  this);
            cov = fifo_coverage  ::type_id::create("cov", this);
        endfunction
        function void connect_phase(uvm_phase phase);
            agt.mon.ap.connect(sb.analysis_export);
            agt.mon.ap.connect(cov.analysis_export);
        endfunction
    endclass

    // ── Sequences ───────────────────────────────────────────────────────────
    // Biased random: wr_pct/rd_pct steer the FIFO toward full or empty.
    class fifo_rand_seq extends uvm_sequence #(fifo_item);
        `uvm_object_utils(fifo_rand_seq)
        int unsigned n         = 100;
        int unsigned wr_pct    = 50;
        int unsigned rd_pct    = 50;
        int unsigned clear_pct = 2;
        function new(string name = "fifo_rand_seq"); super.new(name); endfunction
        task body();
            repeat (n) begin
                bit w = ($urandom_range(0, 99) < wr_pct);
                bit r = ($urandom_range(0, 99) < rd_pct);
                bit c = ($urandom_range(0, 99) < clear_pct);
                req = fifo_item::type_id::create("req");
                start_item(req);
                if (!req.randomize() with { wr == local::w; rd == local::r; clear == local::c; })
                    `uvm_fatal("RAND", "fifo_item randomize failed")
                finish_item(req);
            end
        endtask
    endclass

    // Directed single-cycle op (used to build boundary scenarios).
    class fifo_op_seq extends uvm_sequence #(fifo_item);
        `uvm_object_utils(fifo_op_seq)
        bit wr, rd, clear;
        int unsigned repeat_n = 1;
        function new(string name = "fifo_op_seq"); super.new(name); endfunction
        task body();
            repeat (repeat_n) begin
                req = fifo_item::type_id::create("req");
                start_item(req);
                if (!req.randomize() with { wr == local::wr; rd == local::rd; clear == local::clear; })
                    `uvm_fatal("RAND", "fifo_item randomize failed")
                finish_item(req);
            end
        endtask
    endclass

    // ── Tests ───────────────────────────────────────────────────────────────
    class fifo_base_test extends uvm_test;
        `uvm_component_utils(fifo_base_test)
        fifo_env env;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            env = fifo_env::type_id::create("env", this);
        endfunction

        task op(bit wr, bit rd, bit clear, int unsigned n = 1);
            fifo_op_seq s = fifo_op_seq::type_id::create("op");
            s.wr = wr; s.rd = rd; s.clear = clear; s.repeat_n = n;
            s.start(env.agt.sqr);
        endtask

        task rand_phase(int unsigned n, int unsigned wr_pct, int unsigned rd_pct, int unsigned clear_pct = 2);
            fifo_rand_seq s = fifo_rand_seq::type_id::create("rnd");
            s.n = n; s.wr_pct = wr_pct; s.rd_pct = rd_pct; s.clear_pct = clear_pct;
            s.start(env.agt.sqr);
        endtask

        function void report_phase(uvm_phase phase);
            uvm_report_server rs = uvm_report_server::get_server();
            int errs = rs.get_severity_count(UVM_ERROR) + rs.get_severity_count(UVM_FATAL);
            $display("FIFO-UVM transaction coverage: %0.2f%%", env.cov.coverage());
            // Same summary format as every other block TB, so `make verify` can aggregate it.
            $display("\n=== FIFO-UVM: %0d PASSED, %0d FAILED ===", env.sb.n_checks - env.sb.n_errors, errs);
        endfunction
    endclass

    // Short random run — a quick sanity check.
    class fifo_smoke_test extends fifo_base_test;
        `uvm_component_utils(fifo_smoke_test)
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            rand_phase(200, 50, 50);
            phase.drop_objection(this);
        endtask
    endclass

    // Directed boundary scenarios + biased random phases. Aims to close both
    // the transaction coverage here and the bound design coverage (fifo_cov).
    class fifo_full_test extends fifo_base_test;
        `uvm_component_utils(fifo_full_test)
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            op(0, 1, 0, 2);            // underflow: read while empty
            op(1, 1, 0, 1);            // simultaneous R+W at empty
            op(1, 0, 0, DEPTH + 2);    // fill to full, then overflow attempts
            op(1, 1, 0, 2);            // simultaneous R+W at full (pops one: no longer full)
            op(1, 0, 0, 2);            // refill to full
            op(0, 0, 0, 2);            // idle while full
            op(0, 0, 1, 1);            // clear while full
            op(1, 0, 0, 2);            // partial ...
            op(0, 0, 1, 1);            // ... clear while partial
            op(0, 0, 1, 1);            // clear while empty
            op(1, 0, 0, DEPTH);        // fill
            op(0, 1, 0, DEPTH + 1);    // drain to empty (+1 underflow)
            repeat (4) begin           // pointer wrap-arounds + mixed traffic
                rand_phase(60, 80, 30, 0);   // fill-heavy
                rand_phase(60, 30, 80, 0);   // drain-heavy
            end
            rand_phase(400, 50, 50, 2);      // unbiased soak with occasional clears
            op(0, 0, 0, 3);            // let the last transaction be sampled
            phase.drop_objection(this);
        endtask
    endclass

endpackage
