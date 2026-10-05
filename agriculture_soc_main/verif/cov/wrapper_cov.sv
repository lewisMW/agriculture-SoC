// -----------------------------------------------------------------------------
// wrapper_cov.sv
//
// Functional-coverage model for the APB-facing sensing peripheral
// (adc_apb_wrapper_rev2). Bound into every instance. Answers "has firmware /
// the testbench exercised the register interface the way real firmware will?"
// NEEDS ARM IP to compile (the wrapper instantiates rtc_control_2 -> PL031).
//
//   cp_reg x cp_dir : every register read and written (incl. unmapped
//                     addresses, which must read 0 and ignore writes)
//   cp_trig_src     : sample trigger from the RTC, from firmware (manual), and
//                     both in the same cycle
//   cp_manual_poll  : manual trigger with autonomous polling on and off
//   cp_status_fifo  : status FIFO field (empty / partial / full) as READ by
//                     firmware
//   cp_pop_ctx      : MEASUREMENT_LO read that pops vs. read while empty
//   cp_conv_cal     : conversions started with calibration off / on
//   cp_amux         : each analog mux input selected during a conversion
//   cp_clear_ctx    : fifo_clear while idle / while a conversion is running /
//                     while full
//   cp_wait         : APB access that saw wait states (RTC collision)
//   cp_b2b          : back-to-back transfers (PSEL held between transfers)
// -----------------------------------------------------------------------------
module wrapper_cov #(
    parameter ADDR_WIDTH = 12
)(
    input logic                  PCLK,
    input logic                  PRESETn,
    input logic                  PSEL,
    input logic                  PENABLE,
    input logic                  PWRITE,
    input logic [ADDR_WIDTH-1:0] PADDR,
    input logic                  PREADY,
    input logic [31:0]           status_reg,
    input logic                  rtc_trig,
    input logic                  manual_trig,
    input logic                  poll_enable_reg,
    input logic                  fifo_empty,
    input logic                  fifo_full,
    input logic                  fifo_clear,
    input logic                  adc_en,
    input logic                  cal_reg,
    input logic [1:0]            amux_sel
);
    wire xfer      = PSEL && PENABLE && PREADY;   // APB transfer completes
    wire stalled   = PSEL && PENABLE && !PREADY;

    logic adc_en_q, xfer_q;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin adc_en_q <= 1'b0; xfer_q <= 1'b0; end
        else          begin adc_en_q <= adc_en; xfer_q <= xfer; end
    end
    wire conv_start = adc_en && !adc_en_q;

    covergroup cg_wrap;
        option.per_instance = 1;

        cp_reg : coverpoint PADDR iff (xfer) {
            bins status       = {12'h004};
            bins meas_hi      = {12'h008};
            bins meas_lo      = {12'h00C};
            bins pll          = {12'h100};
            bins amux         = {12'h104};
            bins adc_trigger  = {12'h108};
            bins adc_cal      = {12'h10C};
            bins rtc_region   = {[12'h200:12'h21C]};
            bins fifo_clear   = {12'h220};
            bins alarm_offset = {12'h224};
            bins rtc_ctrl     = {12'h228};
            bins unmapped     = default;
        }
        cp_dir : coverpoint PWRITE iff (xfer) {
            bins read  = {1'b0};
            bins write = {1'b1};
        }
        // write-only / read-only registers: the "wrong" direction is still
        // worth covering (must be harmless), so nothing is excluded.
        x_reg_dir : cross cp_reg, cp_dir;

        cp_trig_src : coverpoint {rtc_trig, manual_trig} {
            bins manual = {2'b01};
            bins rtc    = {2'b10};
            bins both   = {2'b11};
        }
        // Manual trigger with autonomous polling on and off (no binsof in
        // this simulator version, so an iff-guarded coverpoint instead of a cross).
        cp_manual_poll : coverpoint poll_enable_reg iff (manual_trig) {
            bins poll_off = {1'b0};
            bins poll_on  = {1'b1};
        }

        cp_status_fifo : coverpoint status_reg[1:0] iff (xfer && !PWRITE && PADDR == 12'h004) {
            bins empty   = {2'b00};
            bins partial = {2'b01};
            bins full    = {2'b10};
        }
        cp_status_drop : coverpoint status_reg[4] iff (xfer && !PWRITE && PADDR == 12'h004) {
            bins drop_seen = {1'b1};
        }

        cp_pop_ctx : coverpoint fifo_empty iff (xfer && !PWRITE && PADDR == 12'h00C) {
            bins pop        = {1'b0};
            bins read_empty = {1'b1};
        }

        cp_conv_cal : coverpoint cal_reg iff (conv_start) {
            bins normal = {1'b0};
            bins cal    = {1'b1};
        }
        cp_amux : coverpoint amux_sel iff (conv_start) {
            bins sel[] = {[0:3]};
        }

        cp_clear_ctx : coverpoint {adc_en, fifo_full, fifo_empty} iff (fifo_clear) {
            bins idle_empty   = {3'b001};
            bins idle_partial = {3'b000};
            bins idle_full    = {3'b010};
            bins converting   = {3'b100, 3'b101, 3'b110};
        }

        cp_wait : coverpoint stalled {
            bins wait_state = {1'b1};
        }

        cp_b2b : coverpoint (xfer_q && PSEL && !PENABLE) {
            bins back_to_back = {1'b1};
        }
    endgroup

    cg_wrap cg = new;

    always @(posedge PCLK) begin
        if (PRESETn) cg.sample();
    end

endmodule

bind adc_apb_wrapper_rev2 wrapper_cov #(.ADDR_WIDTH(ADDR_WIDTH)) u_wrapper_cov (
    .PCLK           (PCLK),
    .PRESETn        (PRESETn),
    .PSEL           (PSEL),
    .PENABLE        (PENABLE),
    .PWRITE         (PWRITE),
    .PADDR          (PADDR),
    .PREADY         (PREADY),
    .status_reg     (status_reg),
    .rtc_trig       (rtc_trig),
    .manual_trig    (manual_trig),
    .poll_enable_reg(poll_enable_reg),
    .fifo_empty     (fifo_empty),
    .fifo_full      (fifo_full),
    .fifo_clear     (fifo_clear),
    .adc_en         (adc_en),
    .cal_reg        (cal_reg),
    .amux_sel       (amux_reg[1:0])
);
