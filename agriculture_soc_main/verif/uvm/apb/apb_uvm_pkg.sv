// -----------------------------------------------------------------------------
// apb_uvm_pkg.sv — reusable APB3 master agent.
//
//   apb_item      one transfer: addr / write / wdata, plus observed rdata,
//                 slverr and the number of wait states (PREADY low cycles)
//   apb_driver    SETUP -> ACCESS, holds ACCESS until PREADY; returns the
//                 response (rdata/slverr/waits) in the same item
//   apb_monitor   publishes every completed transfer on an analysis port
//   apb_agent     sequencer + driver + monitor
//   apb_base_seq  helpers: wr(addr,data), rd(addr,data) for register sequences
// -----------------------------------------------------------------------------
package apb_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int APB_ADDR_WIDTH = 12;

    class apb_item extends uvm_sequence_item;
        rand bit [APB_ADDR_WIDTH-1:0] addr;
        rand bit                      write;
        rand bit [31:0]               wdata;
        rand int unsigned             idle_cycles;   // gap before this transfer
        // b2b: the NEXT item follows with no idle cycle (PSEL stays high, its
        // SETUP is driven on the edge this transfer completes). Only set by
        // apb_base_seq::burst, which supplies the next item in zero time.
        bit                           b2b;
        // response
        bit [31:0]   rdata;
        bit          slverr;
        int unsigned waits;

        constraint c_word   { addr[1:0] == 2'b00; }
        // A plain range, not `dist`: in Verilator 5.052 this dist combined with
        // an inline `idle_cycles == x` (as the wr/rd helpers do) is reported
        // unsatisfiable even when x is inside the distribution.
        constraint c_idle   { idle_cycles <= 10; }

        `uvm_object_utils(apb_item)
        function new(string name = "apb_item"); super.new(name); endfunction

        function string convert2string();
            return $sformatf("%s addr=0x%03h %s=0x%08h waits=%0d slverr=%0b",
                             write ? "WR" : "RD", addr, write ? "wdata" : "rdata",
                             write ? wdata : rdata, waits, slverr);
        endfunction
    endclass

    typedef uvm_sequencer #(apb_item) apb_sequencer;

    class apb_driver extends uvm_driver #(apb_item);
        `uvm_component_utils(apb_driver)
        virtual apb_if vif;
        int unsigned max_waits = 1000;   // watchdog: a stall must be bounded
        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "apb_if not set")
        endfunction

        task run_phase(uvm_phase phase);
            bit chained = 0;
            vif.PSEL <= 0; vif.PENABLE <= 0; vif.PWRITE <= 0;
            vif.PADDR <= '0; vif.PWDATA <= '0;
            forever begin
                seq_item_port.get_next_item(req);
                if (!vif.PRESETn) chained = 0;
                drive(req, chained);
                chained = req.b2b;
                seq_item_port.item_done();
            end
        endtask

        task drive(apb_item t, bit chained);
            if (!chained) begin
                repeat (t.idle_cycles) begin
                    @(posedge vif.PCLK);
                    vif.PSEL <= 0; vif.PENABLE <= 0;
                end
                // SETUP on the next edge (after an idle cycle)
                @(posedge vif.PCLK);
            end
            // (chained: we are on the edge the previous transfer completed on,
            // so this SETUP follows its ACCESS with no idle cycle)
            vif.PSEL    <= 1;
            vif.PENABLE <= 0;
            vif.PWRITE  <= t.write;
            vif.PADDR   <= t.addr;
            vif.PWDATA  <= t.write ? t.wdata : 32'h0;
            // ACCESS
            @(posedge vif.PCLK);
            vif.PENABLE <= 1;
            t.waits = 0;
            forever begin
                @(posedge vif.PCLK);
                if (vif.PREADY) break;
                t.waits++;
                if (t.waits > max_waits)
                    `uvm_fatal("APB_HANG", $sformatf("PREADY low for > %0d cycles: %s", max_waits, t.convert2string()))
            end
            t.rdata  = vif.PRDATA;
            t.slverr = vif.PSLVERR;
            if (!t.b2b) vif.PSEL <= 0;
            vif.PENABLE <= 0;
        endtask
    endclass

    class apb_monitor extends uvm_monitor;
        `uvm_component_utils(apb_monitor)
        virtual apb_if vif;
        uvm_analysis_port #(apb_item) ap;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "apb_if not set")
        endfunction

        task run_phase(uvm_phase phase);
            int unsigned waits = 0;
            forever begin
                @(posedge vif.PCLK);
                if (!vif.PRESETn) begin waits = 0; continue; end
                if (vif.PSEL && vif.PENABLE) begin
                    if (!vif.PREADY) waits++;
                    else begin
                        apb_item t = apb_item::type_id::create("t");
                        t.addr   = vif.PADDR;
                        t.write  = vif.PWRITE;
                        t.wdata  = vif.PWDATA;
                        t.rdata  = vif.PRDATA;
                        t.slverr = vif.PSLVERR;
                        t.waits  = waits;
                        waits = 0;
                        ap.write(t);
                    end
                end
            end
        endtask
    endclass

    class apb_agent extends uvm_agent;
        `uvm_component_utils(apb_agent)
        apb_sequencer sqr;
        apb_driver    drv;
        apb_monitor   mon;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        function void build_phase(uvm_phase phase);
            sqr = apb_sequencer::type_id::create("sqr", this);
            drv = apb_driver   ::type_id::create("drv", this);
            mon = apb_monitor  ::type_id::create("mon", this);
        endfunction
        function void connect_phase(uvm_phase phase);
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    // Base sequence with blocking register helpers.
    class apb_base_seq extends uvm_sequence #(apb_item);
        `uvm_object_utils(apb_base_seq)
        function new(string name = "apb_base_seq"); super.new(name); endfunction

        task wr(bit [APB_ADDR_WIDTH-1:0] addr, bit [31:0] data, int unsigned idle = 0);
            apb_item t = apb_item::type_id::create("wr");
            start_item(t);
            if (!t.randomize() with { addr == local::addr; write == 1; wdata == local::data; idle_cycles == local::idle; })
                `uvm_fatal("RAND", "apb wr randomize failed")
            finish_item(t);
        endtask

        // Back-to-back burst: n transfers with no idle cycle between them
        // (PSEL held). wr_mask[i] selects a write of wdata[i]; reads return in
        // rdata[i]. The items are issued in zero time, as the driver requires.
        task burst(bit [APB_ADDR_WIDTH-1:0] addr[], bit wr_mask[], bit [31:0] wdata[], output bit [31:0] rdata[]);
            apb_item t[];
            t = new[addr.size()];
            rdata = new[addr.size()];
            foreach (addr[i]) begin
                t[i] = apb_item::type_id::create("b2b");
                start_item(t[i]);
                if (!t[i].randomize() with { addr == local::addr[i]; write == local::wr_mask[i];
                                             wdata == local::wdata[i]; idle_cycles == 0; })
                    `uvm_fatal("RAND", "apb burst randomize failed")
                t[i].b2b = (i + 1 < addr.size());
                finish_item(t[i]);
                rdata[i] = t[i].rdata;
            end
        endtask

        task rd(bit [APB_ADDR_WIDTH-1:0] addr, output bit [31:0] data, input int unsigned idle = 0);
            apb_item t = apb_item::type_id::create("rd");
            start_item(t);
            if (!t.randomize() with { addr == local::addr; write == 0; idle_cycles == local::idle; })
                `uvm_fatal("RAND", "apb rd randomize failed")
            finish_item(t);
            data = t.rdata;
        endtask
    endclass
endpackage
