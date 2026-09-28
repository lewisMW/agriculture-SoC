`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// dummy_adc.v
//
// Behavioural stand-in for the real SAR ADC (analog/.../adc_top_lib/sar, whose
// digital core is adc_digital_lib/sarlogic). Matches the DIGITAL-facing port
// list of the real block so it is a drop-in replacement in the synthesis flow:
//
//   inputs : clk, rstn (active-low), en (start/hold), cal (calibration mode)
//   outputs: valid (conversion complete, held until the next en), result[7:0]
//
// The comparator feedback (`comp`) and analog nets (vp/vn/vdd/vss) of the real
// block are internal / analog-only and are not modelled here. ANALOG_IN is a
// placeholder for the sampled analog input.
//
// Timing mirrors sarlogic: while idle, asserting `en` clears `valid`, runs a
// CONV_CYCLES conversion (SAR converts one bit per cycle), then asserts `valid`
// and presents `result`. `result`/`valid` stay put until the next `en`, so the
// consumer must wait for valid to fall (conversion started) and rise again
// (conversion done). `cal` just lengthens the conversion, mirroring the sCal
// path. Sample values come from an LFSR (deterministic, seed-controlled).
// -----------------------------------------------------------------------------
module dummy_adc #(
    parameter RESULT_WIDTH = 8,
    parameter CONV_CYCLES  = 8,     // conversion length (1 SAR bit per cycle)
    parameter CAL_CYCLES   = 8,     // extra cycles when calibrating
    parameter RAND_SEED    = 8'h5A  // non-zero LFSR seed
)(
    input  wire                    clk,
    input  wire                    rstn,      // active-low
    input  wire                    en,        // start/enable a conversion
    input  wire                    cal,       // calibration mode
    input  wire                    ANALOG_IN, // placeholder for analog input
    output reg                     valid,     // conversion complete (level)
    output reg  [RESULT_WIDTH-1:0] result
);
    localparam [1:0] S_WAIT = 2'd0, S_CONV = 2'd1, S_DONE = 2'd2;

    reg [1:0] state;
    reg [5:0] cnt;
    reg [RESULT_WIDTH-1:0] lfsr;

    // Feedback taps for an 8-bit maximal LFSR (x^8+x^6+x^5+x^4+1)
    wire fb = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state  <= S_WAIT;
            valid  <= 1'b0;
            result <= {RESULT_WIDTH{1'b0}};
            cnt    <= 6'd0;
            lfsr   <= RAND_SEED[RESULT_WIDTH-1:0] | {{(RESULT_WIDTH-1){1'b0}}, 1'b1};
        end else begin
            case (state)
                S_WAIT: begin
                    if (en) begin
                        valid <= 1'b0;   // clear on a fresh conversion
                        cnt   <= cal ? (CONV_CYCLES + CAL_CYCLES) : CONV_CYCLES;
                        state <= S_CONV;
                    end
                end

                S_CONV: begin
                    lfsr <= {lfsr[RESULT_WIDTH-2:0], fb};  // churn the sample source
                    if (cnt == 6'd0)
                        state <= S_DONE;
                    else
                        cnt <= cnt - 6'd1;
                end

                S_DONE: begin
                    result <= lfsr;
                    valid  <= 1'b1;
                    state  <= S_WAIT;
                end

                default: state <= S_WAIT;
            endcase
        end
    end
endmodule
