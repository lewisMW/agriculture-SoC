// -----------------------------------------------------------------------------
// sensing_assertions.sv
//
// SVA sign-off assertions for the sensing peripheral (HANDOFF Task 1 harness
// item). Bound into the DUT modules so they hold under ANY testbench / stimulus
// (directed, random, or firmware-driven at RTL). Compile alongside a wrapper
// testbench with Verilator's --assert flag, e.g.  make -C Wrapper sva
//
// These formalise the same invariants the testbenches check procedurally, but
// as always-on temporal properties independent of the stimulus. On a violation
// Verilator prints the $error and flags the assertion failure.
//
// NOTE: SystemVerilog. Verilator supports this SVA subset with --assert; if your
// Verilator build rejects a construct, this file is optional (the procedural
// monitors in the testbenches cover the same properties in the default flow).
// -----------------------------------------------------------------------------

// ── FIFO invariants (fifo_apb_adc) ───────────────────────────────────────────
module fifo_sva #(
    parameter DEPTH = 16,
    parameter CW    = 5          // width of `count` = $clog2(DEPTH)+1
)(
    input logic          clk,
    input logic          rst_n,
    input logic [CW-1:0] count,
    input logic          fifo_full,
    input logic          fifo_empty
);
    // count can never exceed DEPTH (overflow-safety)
    a_count_le_depth: assert property (@(posedge clk) disable iff (!rst_n)
        count <= DEPTH)
        else $error("FIFO count %0d exceeds DEPTH %0d", count, DEPTH);

    // flags are exact functions of occupancy
    a_full_iff:  assert property (@(posedge clk) disable iff (!rst_n)
        fifo_full  == (count == DEPTH));
    a_empty_iff: assert property (@(posedge clk) disable iff (!rst_n)
        fifo_empty == (count == 0));
endmodule

bind fifo_apb_adc fifo_sva #(.DEPTH(16), .CW(5)) u_fifo_sva (
    .clk(clk), .rst_n(rst_n), .count(count),
    .fifo_full(fifo_full), .fifo_empty(fifo_empty)
);

// ── FSM invariants (wrapper_control) ─────────────────────────────────────────
module fsm_sva (
    input logic       clk,
    input logic       rstn,
    input logic [2:0] state,
    input logic       fifo_write_en,
    input logic       fifo_full
);
    // state stays within the legal encoding (no illegal/unreachable state)
    a_legal_state: assert property (@(posedge clk) disable iff (!rstn)
        state <= 3'd6)
        else $error("wrapper_control illegal state %0d", state);

    // the FSM must never push a sample while the FIFO is full
    a_no_write_when_full: assert property (@(posedge clk) disable iff (!rstn)
        !(fifo_write_en && fifo_full))
        else $error("wrapper_control wrote to a FULL FIFO");
endmodule

bind wrapper_control fsm_sva u_fsm_sva (
    .clk(clk), .rstn(rstn), .state(state),
    .fifo_write_en(fifo_write_en), .fifo_full(fifo_full)
);

// ── APB handshake legality (adc_apb_wrapper_rev1 external port) ───────────────
module apb_sva (
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PREADY
);
    // slave never stalls
    a_pready_high: assert property (@(posedge PCLK) disable iff (!PRESETn)
        PREADY);

    // ACCESS phase (PENABLE) can only occur while selected
    a_enable_needs_sel: assert property (@(posedge PCLK) disable iff (!PRESETn)
        PENABLE |-> PSEL);
endmodule

bind adc_apb_wrapper_rev1 apb_sva u_apb_sva (
    .PCLK(PCLK), .PRESETn(PRESETn),
    .PSEL(PSEL), .PENABLE(PENABLE), .PREADY(PREADY)
);
