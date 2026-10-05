// -----------------------------------------------------------------------------
// fifo_cov.sv
//
// Functional-coverage model for fifo_apb_adc. Bound into every instance of the
// FIFO (see the `bind` at the bottom), so ANY testbench that instantiates the
// FIFO — the block TBs, the wrapper TBs, the full SoC — collects these bins
// without being edited. Compile it alongside the design with --coverage.
//
// What "covered" means here (the questions a reviewer would ask of the FIFO):
//   cp_occupancy  : did we see empty, 1 entry, mid, almost-full and full?
//   cp_op         : idle / write-only / read-only / simultaneous R+W cycles
//   x_occ_op      : every op at every occupancy -> incl. the corner cases
//                   overflow attempt (write while full), underflow attempt
//                   (read while empty), simultaneous R+W at full and at empty
//   cp_fill_edges : occupancy edges 0->1, 1->0, DEPTH-1->DEPTH, DEPTH->DEPTH-1
//   cp_wr_wrap    : write pointer wrapped DEPTH-1 -> 0 (ring buffer wrap)
//   cp_rd_wrap    : read pointer wrapped DEPTH-1 -> 0
//   cp_clear_occ  : fifo_clear while empty / partially full / full
//   cp_data       : sample corner values (all-zeros, all-ones, other)
//
// Notes for Verilator 5.052:
//   - sampled explicitly from an always block (not `@(posedge clk)` on the
//     covergroup) so reset gating is explicit and the values are the pre-edge
//     values the DUT acts on;
//   - no `with` filters / `[*N]` / fixed-size `bins x[N]` / `binsof`
//     cross selections (all unsupported);
//   - illegal_bins aborts the sim WITHOUT writing coverage.dat, so the
//     "count > DEPTH" check is left to the testbench / SVA instead.
// -----------------------------------------------------------------------------
module fifo_cov #(
    parameter DATA_WIDTH = 64,
    parameter DEPTH      = 16,
    parameter PW         = 4,    // pointer width  = $clog2(DEPTH)
    parameter CW         = 5     // count width    = $clog2(DEPTH)+1
)(
    input logic                  clk,
    input logic                  rst_n,
    input logic                  adc_wr_en,
    input logic [DATA_WIDTH-1:0] adc_data,
    input logic                  apb_rd_en,
    input logic                  fifo_clear,
    input logic                  fifo_full,
    input logic                  fifo_empty,
    input logic [CW-1:0]         count,
    input logic [PW-1:0]         wr_ptr,
    input logic [PW-1:0]         rd_ptr
);

    // Transitions are covered as {previous, current} VALUE bins rather than
    // `(a => b)` transition bins: in Verilator 5.052 a transition bin accepts
    // only literal numbers - a parameter or expression such as (DEPTH-1 => DEPTH)
    // crashes the compiler (internal error). Value bins accept parameters.
    logic [CW-1:0] count_q;
    logic [PW-1:0] wr_ptr_q, rd_ptr_q;
    logic          hist_valid;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q <= '0; wr_ptr_q <= '0; rd_ptr_q <= '0; hist_valid <= 1'b0;
        end else begin
            count_q <= count; wr_ptr_q <= wr_ptr; rd_ptr_q <= rd_ptr; hist_valid <= 1'b1;
        end
    end

    covergroup cg_fifo;
        option.per_instance = 1;

        cp_occupancy : coverpoint count {
            bins empty       = {0};
            bins one         = {1};
            bins mid         = {[2:DEPTH-2]};
            bins almost_full = {DEPTH-1};
            bins full        = {DEPTH};
        }

        cp_op : coverpoint {adc_wr_en, apb_rd_en} iff (!fifo_clear) {
            bins idle    = {2'b00};
            bins rd_only = {2'b01};
            bins wr_only = {2'b10};
            bins rd_wr   = {2'b11};
        }

        // Every op at every occupancy. The interesting corners are
        //   <full, wr_only>  overflow attempt (must be dropped)
        //   <empty, rd_only> underflow attempt (must not advance)
        //   <full, rd_wr> / <empty, rd_wr> simultaneous R+W at the boundaries
        x_occ_op : cross cp_occupancy, cp_op;

        cp_fill_edges : coverpoint {count_q, count} iff (hist_valid) {
            bins fill_first  = {{CW'(0),       CW'(1)}};
            bins drain_last  = {{CW'(1),       CW'(0)}};
            bins become_full = {{CW'(DEPTH-1), CW'(DEPTH)}};
            bins leave_full  = {{CW'(DEPTH),   CW'(DEPTH-1)}};
        }

        cp_wr_wrap : coverpoint {wr_ptr_q, wr_ptr} iff (hist_valid) {
            bins wrap = {{PW'(DEPTH-1), PW'(0)}};
        }

        cp_rd_wrap : coverpoint {rd_ptr_q, rd_ptr} iff (hist_valid) {
            bins wrap = {{PW'(DEPTH-1), PW'(0)}};
        }

        // fifo_clear at each fill level. (Verilator 5.052 has no binsof /
        // explicit cross bins, so this is an iff-guarded coverpoint instead of
        // a filtered cross.)
        cp_clear_occ : coverpoint count iff (fifo_clear) {
            bins clr_empty   = {0};
            bins clr_partial = {[1:DEPTH-1]};
            bins clr_full    = {DEPTH};
        }

        cp_data : coverpoint adc_data iff (adc_wr_en && !fifo_full) {
            bins zero  = {'0};
            bins ones  = {{DATA_WIDTH{1'b1}}};
            bins other = default;
        }
    endgroup

    cg_fifo cg = new;

    always @(posedge clk) begin
        if (rst_n) cg.sample();
    end

endmodule

// Attach to every fifo_apb_adc in the design (parameters follow the instance).
bind fifo_apb_adc fifo_cov #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH     (DEPTH),
    .PW        ($clog2(DEPTH)),
    .CW        ($clog2(DEPTH)+1)
) u_fifo_cov (
    .clk       (clk),
    .rst_n     (rst_n),
    .adc_wr_en (adc_wr_en),
    .adc_data  (adc_data),
    .apb_rd_en (apb_rd_en),
    .fifo_clear(fifo_clear),
    .fifo_full (fifo_full),
    .fifo_empty(fifo_empty),
    .count     (count),
    .wr_ptr    (wr_ptr),
    .rd_ptr    (rd_ptr)
);
