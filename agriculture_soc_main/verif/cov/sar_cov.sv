// -----------------------------------------------------------------------------
// sar_cov.sv
//
// Functional-coverage model for the SAR ADC digital: sarlogic (the SAR state
// machine, analog/cadence/sar_adc/sarlogic/functional/verilog.v) and the clock
// divider in sar_adc. Bound into every instance, so the ADC unit benches and
// every wrapper bench collect it. No ARM IP needed.
//
// cg_sar (sampled on sar_clk while out of reset):
//   cp_state         every state; an encoding of 6 or 7 is viol_
//   cp_arc           the 11 legal state arcs as {previous, current}; any other
//                    arc is viol_
//   cp_start_kind    conversion started from idle (sWait) / back to back (sDone)
//   cp_conv_kind_seq normal or calibration, after a normal or a calibration
//   cp_result        result classes; cp_bit0..7: every result bit seen 0 and 1
//   cp_cal_vote      majority vote at the end of each trim trial, both ways
//   cp_cal_comp      comparator read 1 and read 0 during calibration
//   cp_trim_final    trim_val a calibration ended on
//   cp_cal_latched   cal changed during a running conversion / calibration
//   cp_en_drop       en fell in sSample / sConv / sCal / sDone
// cg_sar_rst (sampled when rstn falls):
//   cp_rst_state     reset asserted in each of the 6 states
// cg_sar_div (sar_adc, sampled on clk):
//   cp_wrap          the divider counter wrapped
//   cp_sar_clk       sar_clk rose and fell
//
// Note (Verilator 5.052): no transition bins on named constants, so arcs are
// {previous, current} value bins; must-never-happen bins are viol_ normal bins
// (an illegal_bins hit aborts the run without writing coverage).
// -----------------------------------------------------------------------------
module sar_cov (
    input logic       clk,          // sar_clk
    input logic       rstn,
    input logic       en,
    input logic       cal,
    input logic       comp,
    input logic [2:0] state,
    input logic       calibrate,
    input logic [3:0] cal_itt,
    input logic [3:0] cal_count,
    input logic [4:0] trim_val,
    input logic [7:0] dig_result
);
    localparam logic [2:0] S_INIT = 3'd0, S_WAIT = 3'd1, S_SAMPLE = 3'd2,
                           S_CONV = 3'd3, S_DONE = 3'd4, S_CAL = 3'd5;

    logic [2:0] st_q;
    logic       hist, en_q;
    logic       was_cal;        // the conversion now finishing is a calibration
    logic       prev_cal;       // kind of the conversion before it
    logic       prev_valid;     // a conversion has completed since reset
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            st_q <= S_INIT; hist <= 1'b0; en_q <= 1'b0;
            was_cal <= 1'b0; prev_cal <= 1'b0; prev_valid <= 1'b0;
        end else begin
            st_q <= state; hist <= 1'b1; en_q <= en;
            if (state == S_SAMPLE) was_cal <= calibrate;
            if (state == S_DONE) begin prev_cal <= was_cal; prev_valid <= 1'b1; end
        end
    end
    wire en_fall = en_q && !en;

    covergroup cg_sar;
        option.per_instance = 1;

        cp_state : coverpoint state {
            bins s_init   = {S_INIT};
            bins s_wait   = {S_WAIT};
            bins s_sample = {S_SAMPLE};
            bins s_conv   = {S_CONV};
            bins s_done   = {S_DONE};
            bins s_cal    = {S_CAL};
            bins viol_illegal_state = {3'd6, 3'd7};
        }

        cp_arc : coverpoint {st_q, state} iff (hist) {
            bins init_to_wait   = {{S_INIT,   S_WAIT}};
            bins wait_hold      = {{S_WAIT,   S_WAIT}};
            bins wait_to_sample = {{S_WAIT,   S_SAMPLE}};
            bins sample_to_conv = {{S_SAMPLE, S_CONV}};
            bins sample_to_cal  = {{S_SAMPLE, S_CAL}};
            bins conv_hold      = {{S_CONV,   S_CONV}};
            bins conv_to_done   = {{S_CONV,   S_DONE}};
            bins cal_hold       = {{S_CAL,    S_CAL}};
            bins cal_to_done    = {{S_CAL,    S_DONE}};
            bins done_to_wait   = {{S_DONE,   S_WAIT}};
            bins done_to_sample = {{S_DONE,   S_SAMPLE}};
            // every other pair of legal states is an arc the RTL cannot take
            bins viol_arc_from_init   = {{S_INIT, S_INIT}, {S_INIT, S_SAMPLE}, {S_INIT, S_CONV},
                                         {S_INIT, S_DONE}, {S_INIT, S_CAL}};
            bins viol_arc_from_wait   = {{S_WAIT, S_INIT}, {S_WAIT, S_CONV}, {S_WAIT, S_DONE},
                                         {S_WAIT, S_CAL}};
            bins viol_arc_from_sample = {{S_SAMPLE, S_INIT}, {S_SAMPLE, S_WAIT}, {S_SAMPLE, S_SAMPLE},
                                         {S_SAMPLE, S_DONE}};
            bins viol_arc_from_conv   = {{S_CONV, S_INIT}, {S_CONV, S_WAIT}, {S_CONV, S_SAMPLE},
                                         {S_CONV, S_CAL}};
            bins viol_arc_from_done   = {{S_DONE, S_INIT}, {S_DONE, S_CONV}, {S_DONE, S_DONE},
                                         {S_DONE, S_CAL}};
            bins viol_arc_from_cal    = {{S_CAL, S_INIT}, {S_CAL, S_WAIT}, {S_CAL, S_SAMPLE},
                                         {S_CAL, S_CONV}};
        }

        cp_start_kind : coverpoint {st_q, state} iff (hist) {
            bins from_idle    = {{S_WAIT, S_SAMPLE}};   // 11 sar_clk to valid
            bins back_to_back = {{S_DONE, S_SAMPLE}};   // 10 sar_clk to valid
        }

        cp_conv_kind_seq : coverpoint {prev_cal, was_cal} iff (state == S_DONE && prev_valid) {
            bins normal_then_normal = {2'b00};
            bins normal_then_cal    = {2'b01};
            bins cal_then_normal    = {2'b10};
            bins cal_then_cal       = {2'b11};
        }

        cp_result : coverpoint dig_result iff (state == S_DONE && !was_cal) {
            bins zero      = {8'h00};
            bins all_ones  = {8'hFF};
            bins low_half  = {[8'h01:8'h7F]};
            bins high_half = {[8'h80:8'hFE]};
        }
        cp_bit0 : coverpoint dig_result[0] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit1 : coverpoint dig_result[1] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit2 : coverpoint dig_result[2] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit3 : coverpoint dig_result[3] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit4 : coverpoint dig_result[4] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit5 : coverpoint dig_result[5] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit6 : coverpoint dig_result[6] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }
        cp_bit7 : coverpoint dig_result[7] iff (state == S_DONE && !was_cal) { bins seen0 = {1'b0}; bins seen1 = {1'b1}; }

        // sarlogic keeps the trial bit when cal_count > 7 (verilog.v:126-127)
        cp_cal_vote : coverpoint (cal_count > 4'd7) iff (state == S_CAL && cal_itt == 4'd7) {
            bins keep_bit = {1'b1};
            bins drop_bit = {1'b0};
        }
        cp_cal_count : coverpoint cal_count iff (state == S_CAL) {
            bins in_range = {[4'd0:4'd14]};
            bins viol_out_of_range = {4'd15};
        }
        cp_cal_comp : coverpoint comp iff (state == S_CAL && cal_itt != 4'd7) {
            bins comp_one  = {1'b1};
            bins comp_zero = {1'b0};
        }
        cp_trim_final : coverpoint trim_val iff (state == S_DONE && was_cal) {
            bins zero    = {5'd0};
            bins low     = {[5'd1:5'd15]};
            bins mid     = {5'd16};
            bins high    = {[5'd17:5'd30]};
            bins all_set = {5'd31};
        }

        // cal is latched when a conversion starts; a later change must not
        // affect the running one
        cp_cal_latched : coverpoint {state == S_CAL, cal} iff ((state == S_CONV || state == S_CAL) && cal != calibrate) {
            bins cal_rose_during_conversion  = {2'b01};
            bins cal_fell_during_calibration = {2'b10};
        }

        cp_en_drop : coverpoint state iff (en_fall) {
            bins in_sample = {S_SAMPLE};
            bins in_conv   = {S_CONV};
            bins in_cal    = {S_CAL};
            bins in_done   = {S_DONE};
        }
    endgroup

    covergroup cg_sar_rst;
        option.per_instance = 1;
        cp_rst_state : coverpoint state {
            bins in_init   = {S_INIT};
            bins in_wait   = {S_WAIT};
            bins in_sample = {S_SAMPLE};
            bins in_conv   = {S_CONV};
            bins in_done   = {S_DONE};
            bins in_cal    = {S_CAL};
        }
    endgroup

    cg_sar     cg   = new;
    cg_sar_rst cg_r = new;

    always @(posedge clk) if (rstn) cg.sample();
    // rstn falls: sarlogic's reset uses non-blocking assignments, so `state`
    // still holds the pre-reset value here.
    always @(negedge rstn) cg_r.sample();
endmodule

module sar_div_cov #(
    parameter int CLK_DIV = 4
)(
    input logic        clk,
    input logic        rstn,
    input logic [31:0] div_cnt,
    input logic        sar_clk
);
    logic sar_q, hist;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin sar_q <= 1'b0; hist <= 1'b0; end
        else       begin sar_q <= sar_clk; hist <= 1'b1; end
    end

    covergroup cg_sar_div;
        option.per_instance = 1;
        cp_wrap : coverpoint (div_cnt == CLK_DIV - 1) {
            bins wrapped = {1'b1};
        }
        cp_sar_clk : coverpoint {sar_q, sar_clk} iff (hist) {
            bins rose = {2'b01};
            bins fell = {2'b10};
        }
    endgroup
    cg_sar_div cg = new;
    always @(posedge clk) if (rstn) cg.sample();
endmodule

bind sarlogic sar_cov u_sar_cov (
    .clk        (clk),
    .rstn       (rstn),
    .en         (en),
    .cal        (cal),
    .comp       (comp),
    .state      (state),
    .calibrate  (calibrate),
    .cal_itt    (cal_itt),
    .cal_count  (cal_count),
    .trim_val   (trim_val),
    .dig_result (dig_result)
);

bind sar_adc sar_div_cov #(.CLK_DIV(CLK_DIV)) u_sar_div_cov (
    .clk     (clk),
    .rstn    (rstn),
    .div_cnt (32'(div_cnt)),
    .sar_clk (sar_clk)
);
