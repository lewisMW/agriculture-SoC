// -----------------------------------------------------------------------------
// fsm_cov.sv
//
// Functional-coverage model for the sampling FSM (wrapper_control_2). Bound
// into every instance, so the FSM block TBs, the wrapper TBs and the full SoC
// all collect it.
//
//   cp_state      : every state visited
//   cp_arc        : every legal state transition, incl. the stall self-loops
//                   (WAIT_START/WAIT_DONE holding while the ADC converts)
//   cp_trig_ctx   : a trigger arriving in IDLE (accepted) vs while busy
//                   (ignored — e.g. an RTC alarm landing mid-conversion)
//   cp_full_check : FIFO full / not full at the CHECK_FIFO decision
//   cp_err        : sticky err_fifo_full set (0->1) and cleared (1->0)
//   cp_cycle      : the two complete happy/drop paths seen back-to-back
//
// The simulator's own --coverage-fsm also extracts state/arc coverage
// automatically; this model adds the *context* bins (trigger-while-busy,
// error-flag lifecycle) that automatic FSM coverage cannot express.
// -----------------------------------------------------------------------------
module fsm_cov (
    input logic       clk,
    input logic       rstn,
    input logic [2:0] state,
    input logic       sample_trig,
    input logic       fifo_full,
    input logic       adc_valid,
    input logic       err_fifo_full
);
    // Mirrors wrapper_control_2's localparams (kept local: bind can't see them)
    localparam logic [2:0]
        S_IDLE       = 3'd0,
        S_CHECK_FIFO = 3'd1,
        S_ENABLE     = 3'd2,
        S_WAIT_START = 3'd3,
        S_WAIT_DONE  = 3'd4,
        S_WRITE      = 3'd5,
        S_ERR_FULL   = 3'd6;

    // Transitions are covered as {previous, current} value bins: Verilator
    // 5.052 transition bins `(a => b)` only accept literal numbers (a named
    // constant crashes the compiler), and named states are far more readable.
    logic [2:0] st_q, st_q2;
    logic [1:0] hist;          // how many history samples are valid
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin st_q <= S_IDLE; st_q2 <= S_IDLE; hist <= 2'd0; end
        else begin
            st_q <= state; st_q2 <= st_q;
            if (hist != 2'd2) hist <= hist + 2'd1;
        end
    end

    covergroup cg_fsm;
        option.per_instance = 1;

        cp_state : coverpoint state {
            bins idle       = {S_IDLE};
            bins check_fifo = {S_CHECK_FIFO};
            bins enable     = {S_ENABLE};
            bins wait_start = {S_WAIT_START};
            bins wait_done  = {S_WAIT_DONE};
            bins write      = {S_WRITE};
            bins err_full   = {S_ERR_FULL};
            illegal_bins unused = {3'd7};
        }

        cp_arc : coverpoint {st_q, state} iff (hist != 0) {
            bins idle_hold        = {{S_IDLE,       S_IDLE}};
            bins idle_to_check    = {{S_IDLE,       S_CHECK_FIFO}};
            bins check_to_enable  = {{S_CHECK_FIFO, S_ENABLE}};
            bins check_to_err     = {{S_CHECK_FIFO, S_ERR_FULL}};
            bins enable_to_wstart = {{S_ENABLE,     S_WAIT_START}};
            bins wstart_hold      = {{S_WAIT_START, S_WAIT_START}};
            bins wstart_to_wdone  = {{S_WAIT_START, S_WAIT_DONE}};
            bins wdone_hold       = {{S_WAIT_DONE,  S_WAIT_DONE}};
            bins wdone_to_write   = {{S_WAIT_DONE,  S_WRITE}};
            bins write_to_idle    = {{S_WRITE,      S_IDLE}};
            bins err_to_idle      = {{S_ERR_FULL,   S_IDLE}};
        }

        cp_trig_ctx : coverpoint state iff (sample_trig) {
            bins accepted          = {S_IDLE};
            bins ignored_checking  = {S_CHECK_FIFO};
            bins ignored_enabling  = {S_ENABLE};
            bins ignored_converting= {S_WAIT_START, S_WAIT_DONE};
            bins ignored_writing   = {S_WRITE, S_ERR_FULL};
        }

        cp_full_check : coverpoint fifo_full iff (state == S_CHECK_FIFO) {
            bins room = {1'b0};
            bins full = {1'b1};
        }

        cp_err : coverpoint err_fifo_full {
            bins set   = (1'b0 => 1'b1);
            bins clear = (1'b1 => 1'b0);
        }

        // A successful sample immediately followed by a dropped one, and the
        // recovery after a drop (drop -> next successful write).
        cp_cycle : coverpoint {st_q2, st_q, state} iff (hist == 2'd2) {
            bins write_then_check = {{S_WRITE,    S_IDLE, S_CHECK_FIFO}};
            bins drop_then_check  = {{S_ERR_FULL, S_IDLE, S_CHECK_FIFO}};
        }
    endgroup

    cg_fsm cg = new;

    always @(posedge clk) begin
        if (rstn) cg.sample();
    end

endmodule

bind wrapper_control_2 fsm_cov u_fsm_cov (
    .clk          (clk),
    .rstn         (rstn),
    .state        (state),
    .sample_trig  (sample_trig),
    .fifo_full    (fifo_full),
    .adc_valid    (adc_valid),
    .err_fifo_full(err_fifo_full)
);
