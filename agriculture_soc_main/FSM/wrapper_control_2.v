`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// wrapper_control_2.v
//
// Sampling FSM for the sensing peripheral. On a trigger (from the RTC alarm, or
// a firmware "manual" trigger) it runs one ADC conversion and pushes the sample
// into the FIFO. This is the low-power polling engine: the RTC + this FSM drive
// the ADC so the CPU can sleep between samples.
//
// ADC handshake matches the real SAR block (adc_digital_lib/sarlogic): assert
// adc_en, wait for the conversion to start (valid falls) then complete (valid
// rises), then deassert adc_en. adc_valid must already be synchronised into
// this clock domain by the wrapper (the real ADC runs on a slower clock).
//
// One sample per trigger; the FIFO accumulates samples across many polls until
// firmware drains it. If the FIFO is full at the pre-check the sample is
// dropped and err_fifo_full is raised.
//
// Stale-conversion guard (bug FSM-STALE): sarlogic decides whether to start a
// back-to-back conversion on the same sar_clk edge that raises valid, and this
// FSM only sees valid through the wrapper's synchroniser, so adc_en is still
// high at that edge: after every sample the ADC runs one more conversion that
// nobody asked for. A trigger arriving while it runs finds valid already low;
// treating that as "our conversion started" stored a sample taken up to one
// conversion BEFORE the trigger, with the previous ADC_CAL setting. Now the
// FSM tracks it (adc_quiet): cleared in S_WRITE (an unrequested conversion is
// starting), set again by the next rising edge of valid (it finished). A
// valid fall only counts as the start of our conversion while adc_quiet is
// set; if the unrequested one is still running, its completion comes first,
// and because adc_en is then high at its sDone edge the ADC goes straight on
// into the conversion this trigger asked for. Out of reset the ADC is idle
// (valid low), so adc_quiet resets to 1. With an ADC that does not restart,
// adc_quiet simply waits for the requested conversion's own edges: at worst
// one extra conversion, never a hang (adc_en stays high meanwhile).
// -----------------------------------------------------------------------------
module wrapper_control_2 (
    input  wire clk,
    input  wire rstn,            // active-low (matches PRESETn)

    input  wire sample_trig,     // pulse: begin one sampling cycle

    input  wire fifo_full,
    output reg  fifo_write_en,   // 1-cycle pulse: push a sample

    output reg  adc_en,          // enable/hold the ADC through the conversion
    input  wire adc_valid,       // ADC conversion complete (synchronised)

    output reg  err_fifo_full    // set when a sample was dropped (FIFO full)
);

    localparam [2:0]
        S_IDLE       = 3'd0,   // waiting for a trigger
        S_CHECK_FIFO = 3'd1,   // pre-check the FIFO has room
        S_ENABLE     = 3'd2,   // assert adc_en
        S_WAIT_START = 3'd3,   // wait for the conversion to begin (valid low)
        S_WAIT_DONE  = 3'd4,   // wait for the conversion to complete (valid high)
        S_WRITE      = 3'd5,   // push the sample into the FIFO
        S_ERR_FULL   = 3'd6;   // FIFO full at pre-check: drop the sample

    reg [2:0] state, next_state;
    reg       adc_quiet;   // no unrequested conversion in flight (see header)
    reg       adc_valid_q; // adc_valid last cycle, for its rising edge

    // ── Next-state (combinational) ──────────────────────────────────────────
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:       if (sample_trig) next_state = S_CHECK_FIFO;
            S_CHECK_FIFO: next_state = fifo_full ? S_ERR_FULL : S_ENABLE;
            S_ENABLE:     next_state = S_WAIT_START;
            S_WAIT_START: if (!adc_valid && adc_quiet) next_state = S_WAIT_DONE;  // our conversion started
            S_WAIT_DONE:  if (adc_valid)   next_state = S_WRITE;      // conversion done
            S_WRITE:      next_state = S_IDLE;
            S_ERR_FULL:   next_state = S_IDLE;
            default:      next_state = S_IDLE;
        endcase
    end

    // ── Outputs (combinational, Moore) ──────────────────────────────────────
    always @(*) begin
        adc_en        = 1'b0;
        fifo_write_en = 1'b0;
        case (state)
            S_ENABLE, S_WAIT_START, S_WAIT_DONE: adc_en        = 1'b1;
            S_WRITE:                             fifo_write_en = 1'b1;
            default: ;
        endcase
    end

    // ── State register + sticky error flag ──────────────────────────────────
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state         <= S_IDLE;
            err_fifo_full <= 1'b0;
            adc_quiet     <= 1'b1;
            adc_valid_q   <= 1'b0;
        end else begin
            state       <= next_state;
            adc_valid_q <= adc_valid;
            if (state == S_WRITE)               adc_quiet <= 1'b0;   // ADC saw adc_en at its sDone edge
            else if (adc_valid && !adc_valid_q) adc_quiet <= 1'b1;   // that conversion has finished
            if (state == S_ERR_FULL)
                err_fifo_full <= 1'b1;               // latch the drop
            else if (state == S_CHECK_FIFO && !fifo_full)
                err_fifo_full <= 1'b0;               // clear on a successful new cycle
        end
    end

endmodule
