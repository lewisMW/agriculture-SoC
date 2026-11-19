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
//
// Conversion timeout (FIX-2, pending team confirmation): a counter runs while
// the FSM waits for the ADC (S_WAIT_START / S_WAIT_DONE). After CONV_TIMEOUT
// such cycles without a completed conversion the FSM spends one cycle in
// S_ERR_TIMEOUT (adc_en low, no FIFO write, sticky err_adc_timeout set) and
// returns to IDLE, so a dead ADC no longer parks sampling until reset. The flag
// clears when the next sample is written. A conversion that completes on the
// last allowed cycle is accepted. Before FIX-2 the FSM waited forever.
// -----------------------------------------------------------------------------
module wrapper_control_2 #(
    parameter CONV_TIMEOUT = 1344   // PCLK; the wrapper passes 4 calibrations' worth
) (
    input  wire clk,
    input  wire rstn,            // active-low (matches PRESETn)

    input  wire sample_trig,     // pulse: begin one sampling cycle

    input  wire fifo_full,
    output reg  fifo_write_en,   // 1-cycle pulse: push a sample

    output reg  adc_en,          // enable/hold the ADC through the conversion
    input  wire adc_valid,       // ADC conversion complete (synchronised)

    output reg  err_fifo_full,   // set when a sample was dropped (FIFO full)
    output reg  err_adc_timeout  // set when a conversion timed out (FIX-2)
);

    localparam [2:0]
        S_IDLE       = 3'd0,   // waiting for a trigger
        S_CHECK_FIFO = 3'd1,   // pre-check the FIFO has room
        S_ENABLE     = 3'd2,   // assert adc_en
        S_WAIT_START = 3'd3,   // wait for the conversion to begin (valid low)
        S_WAIT_DONE  = 3'd4,   // wait for the conversion to complete (valid high)
        S_WRITE      = 3'd5,   // push the sample into the FIFO
        S_ERR_FULL   = 3'd6,   // FIFO full at pre-check: drop the sample
        S_ERR_TIMEOUT= 3'd7;   // FIX-2: the ADC did not complete within CONV_TIMEOUT

    localparam TW = (CONV_TIMEOUT > 1) ? $clog2(CONV_TIMEOUT) : 1;
    reg  [TW-1:0] tmo_cnt;     // cycles spent waiting for the ADC
    wire          tmo_hit = (tmo_cnt == CONV_TIMEOUT - 1);

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
            S_WAIT_START: if (tmo_hit)                  next_state = S_ERR_TIMEOUT;
                          else if (!adc_valid && adc_quiet) next_state = S_WAIT_DONE;  // our conversion started
            S_WAIT_DONE:  if (adc_valid)                next_state = S_WRITE;          // conversion done
                          else if (tmo_hit)             next_state = S_ERR_TIMEOUT;
            S_WRITE:      next_state = S_IDLE;
            S_ERR_FULL:   next_state = S_IDLE;
            S_ERR_TIMEOUT: next_state = S_IDLE;
        endcase   // all 8 encodings are states: no default
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
            err_adc_timeout <= 1'b0;
            tmo_cnt       <= {TW{1'b0}};
            adc_quiet     <= 1'b1;
            adc_valid_q   <= 1'b0;
        end else begin
            state       <= next_state;
            adc_valid_q <= adc_valid;
            if (state == S_WRITE)               adc_quiet <= 1'b0;   // ADC saw adc_en at its sDone edge
            else if (adc_valid && !adc_valid_q) adc_quiet <= 1'b1;   // that conversion has finished
            if (state == S_WAIT_START || state == S_WAIT_DONE) tmo_cnt <= tmo_cnt + 1'b1;
            else                                               tmo_cnt <= {TW{1'b0}};
            if (state == S_ERR_TIMEOUT)  err_adc_timeout <= 1'b1;
            else if (state == S_WRITE)   err_adc_timeout <= 1'b0;   // the next written sample clears it
            if (state == S_ERR_FULL)
                err_fifo_full <= 1'b1;               // latch the drop
            else if (state == S_CHECK_FIFO && !fifo_full)
                err_fifo_full <= 1'b0;               // clear on a successful new cycle
        end
    end

endmodule
