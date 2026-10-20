`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// sar_adc.v
//
// Synthesisable 8-bit SAR ADC of the sensing peripheral: the digital half of
// the converter around the sar_afe hard macro (ASIC_ours/macros/sar_afe). It
// has dummy_adc's digital interface (clk rstn en cal valid result) plus the
// two analog inputs, and replaces dummy_adc in adc_apb_wrapper_rev2.
//
//   clk -> divider -> sar_clk -> u_logic (sarlogic)
//                                  | sample, ctlp/ctln, trima/trimb, clkc
//                                  v
//   vinp/vinn ----------------> u_afe (sar_afe macro) -- outp/outn --> u_latch
//                                  ^                                     |
//                                  +-------------- comp <----------------+
//
// Instances (stable names, referenced by sar_adc.sdc and the physical flow).
// In the nanosoc chip this module is
//   u_nanosoc_chip/u_system/u_ss_expansion/u_region_exp/u_ss_accelerator/sensor_wrapper/u_adc
//   sar_clk_reg  the divider's output flop: sar_clk = clk / (2*CLK_DIV)
//   u_logic      sarlogic, the SAR state machine
//                (analog/cadence/sar_adc/sarlogic/functional/verilog.v);
//                synthesis may flatten it, and nothing refers inside it
//   u_latch      sar_comp_latch: NAND SR latch of two sky130_fd_sc_hd__nand2_1,
//                u_latch/u_nand_q and u_latch/u_nand_qn (dont_touch)
//   u_afe        sar_afe hard macro: bootstrapped switches, CDACs, comparator
//                (dont_touch). Place it at the bottom-left of the core, with the
//                SAR logic and the latch to its right, next to its right-edge
//                digital pins (see the macro README).
// sar_adc.sdc finds the instance from u_afe, so it also works on a netlist in
// which synthesis has flattened this level (names then become u_adc_<name>);
// u_latch keeps its level because it is dont_touch.
//
// Clocking (constraints in sar_adc.sdc)
//   - sar_clk comes from ONE flop, toggled every CLK_DIV cycles of clk, on the
//     FALLING edge of clk. sar_clk is a divided clk, so the two domains are
//     related. Running the divider on the falling edge puts every sar_clk edge
//     half a clk period away from the clk-domain logic: en and cal (clk domain)
//     reach sarlogic with half a period of setup and hold, and the RTL
//     simulation has no same-time-step race between the two domains.
//   - clkc = ~sar_clk & en_co_clk (inside sarlogic) clocks the comparator. The
//     enable changes just after the rising edge of sar_clk, while ~sar_clk is
//     low, so clkc cannot glitch. The comparator decides on the rising edge of
//     clkc (falling edge of sar_clk) and sarlogic samples comp on the next
//     rising edge of sar_clk, half a sar_clk period later.
//   - valid and result change on sar_clk. The wrapper synchronises valid into
//     the clk domain (3 flops) and captures result on its synchronised rising
//     edge; result then holds until the next conversion completes.
//
// Conversion timing (sarlogic, PR #130): sSample + 8 x sConv + sDone = 10
// sar_clk periods back to back, 11 when started from idle; calibration takes
// 1 + 40 + 1. With en still high at sDone the next conversion starts at once,
// so valid is high for one sar_clk period (2*CLK_DIV clk cycles).
//
// Supplies
//   vdd/vss/vdda/vref exist with USE_POWER_PINS (powered netlists, as for the
//   sky130 cells and the sar_afe port list) and in the AMS flow (SAR_AMS),
//   where sar_ams_shim supplies the SPICE-bound macro. Plain RTL simulation and
//   synthesis have neither; the physical flow connects the macro's supply pins
//   with connect_global_net. vdda is the macro's analog supply for the
//   bootstrapped switches; vref is the CDAC reference (Hee's bit-driver
//   inverters), a pin of its own so it can be decoupled on its own.
//
// Analog inputs
//   vinp/vinn go straight to the macro and carry no logic. In the chip they
//   come from two analog pads through the hierarchy as ADC_VINP/ADC_VINN
//   (nanosoc_chip -> nanosoc_system -> nanosoc_ss_expansion ->
//   nanosoc_region_exp -> accelerator_subsystem -> adc_apb_wrapper_rev2).
//   Plain RTL simulation uses the sim-only behavioural model of the macro
//   (ADC/sim/sar_afe_model.v), which makes its own input from parameters and
//   plusargs and ignores these wires.
// -----------------------------------------------------------------------------

// Supply pins: powered netlists, or the AMS flow (see "Supplies" above).
`ifdef USE_POWER_PINS
  `define SAR_ADC_PG
`elsif SAR_AMS
  `define SAR_ADC_PG
`endif

module sar_adc #(
    parameter CLK_DIV = 4   // clk cycles per sar_clk half period (>= 1);
                            // sar_adc.sdc's SAR_ADC_CLK_DIV must match
)(
`ifdef SAR_ADC_PG
    inout  wire       vdd,
    inout  wire       vss,
    inout  wire       vdda,     // macro analog supply: sampling switches
    inout  wire       vref,     // macro CDAC reference: bit-driver inverters
`endif
    input  wire       clk,      // PCLK
    input  wire       rstn,     // active-low, asynchronous
    input  wire       en,       // start / hold conversions (wrapper_control_2 adc_en)
    input  wire       cal,      // next conversion runs the comparator calibration
    output wire       valid,    // conversion complete (sar_clk domain)
    output wire [7:0] result,   // last result, held until the next one (sar_clk domain)
    input  wire       vinp,     // analog input, + side
    input  wire       vinn      // analog input, - side
);

    // ------------------------------------------------------------------------
    // Clock divider: sar_clk = clk / (2*CLK_DIV), from one flop (sar_clk_reg)
    // on the falling edge of clk. div_ph is the divider's phase; sar_clk_reg
    // retimes it, so the clock flop's D is plain data rather than its own
    // (clock) output fed back.
    // ------------------------------------------------------------------------
    localparam             DIV_W    = (CLK_DIV > 1) ? $clog2(CLK_DIV) : 1;
    localparam integer     DIV_MAX  = CLK_DIV - 1;
    localparam [DIV_W-1:0] DIV_LAST = DIV_MAX[DIV_W-1:0];

    reg [DIV_W-1:0] div_cnt;
    reg             div_ph;
    reg             sar_clk;

    always @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            div_cnt <= {DIV_W{1'b0}};
            div_ph  <= 1'b0;
            sar_clk <= 1'b0;
        end else begin
            sar_clk <= div_ph;
            if (div_cnt == DIV_LAST) begin
                div_cnt <= {DIV_W{1'b0}};
                div_ph  <= ~div_ph;
            end else begin
                div_cnt <= div_cnt + 1'b1;
            end
        end
    end

    // ------------------------------------------------------------------------
    // SAR state machine
    // ------------------------------------------------------------------------
    wire       comp;            // latched comparator decision
    wire       comp_n;
    wire       sample;
    wire [7:0] ctlp, ctln;
    wire [4:0] trima, trimb;
    wire       clkc;            // comparator clock
    wire       outp, outn;      // comparator outputs

    sarlogic u_logic (
        .clk    (sar_clk),
        .rstn   (rstn),
        .en     (en),
        .comp   (comp),
        .cal    (cal),
        .valid  (valid),
        .result (result),
        .sample (sample),
        .ctlp   (ctlp),
        .ctln   (ctln),
        .trima  (trima),
        .trimb  (trimb),
        .clkc   (clkc)
    );

    // ------------------------------------------------------------------------
    // Comparator latch (two sky130 nand2, dont_touch in sar_adc.sdc)
    // ------------------------------------------------------------------------
    sar_comp_latch u_latch (
`ifdef USE_POWER_PINS
        .vdd  (vdd),
        .vss  (vss),
`endif
        .outp (outp),
        .outn (outn),
        .q    (comp),
        .qn   (comp_n)
    );

    // ------------------------------------------------------------------------
    // Analog front end: the sar_afe hard macro
    // ------------------------------------------------------------------------
    sar_afe u_afe (
`ifdef SAR_ADC_PG
        .vdd    (vdd),
        .vss    (vss),
        .vdda   (vdda),
        .vref   (vref),
`endif
        .vinp   (vinp),
        .vinn   (vinn),
        .sample (sample),
        .clk    (clkc),
        .ctlp   (ctlp),
        .ctln   (ctln),
        .trima  (trima),
        .trimb  (trimb),
        .outp   (outp),
        .outn   (outn)
    );

endmodule

`ifdef SAR_ADC_PG
  `undef SAR_ADC_PG
`endif
