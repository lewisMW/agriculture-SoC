// -----------------------------------------------------------------------------
// sensing_assertions.sv
//
// SVA sign-off assertions for the sensing peripheral, bound into the DUT
// modules so they hold under ANY testbench / stimulus. Compile alongside a
// bench with Verilator's --assert flag (gap, closure, soak, sva, the unit
// benches and the UVM bench all do). A violation prints
//   %Error: sensing_assertions.sv:<line>: Assertion failed in <path>.<name>
// and stops the simulation (the bench then has no summary line, which the
// regression treats as a failure).
//
// Groups:
//   apb_sva   adc_apb_wrapper_rev2   APB slave behaviour
//   wrap_sva  adc_apb_wrapper_rev2   internal pulses, sample capture, status
//   fifo_sva  fifo_apb_adc           pointer / count invariants
//   fsm_sva   wrapper_control_2      sampling FSM legality
//   rtc_sva   rtc_control_2          controller + the PL031 port protocol
//   sar_sva   sarlogic               SAR state machine
//   sar_clk_sva sar_adc              comparator clock gating
//
// Only constructs Verilator 5.052 supports: |->, |=>, bounded ##[a:b], $past,
// $rose, $fell, $stable. No s_eventually, no unbounded ranges, no local
// variables. Each property has been shown able to fail (verif/sva_mut).
//
// `SVA_FSM_UNIT: defined by the FSM unit bench only. Its FSM-4 case raises
// fifo_full between the pre-check and the write, which cannot happen in the
// wrapper (only the FSM pushes); a_no_write_when_full is a property of the
// integrated design and is left out of that one build.
// -----------------------------------------------------------------------------

// ── FIFO invariants (fifo_apb_adc) ───────────────────────────────────────────
module fifo_sva #(
    parameter DEPTH = 16,
    parameter DW    = 8,
    parameter PW    = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter CW    = PW + 1
)(
    input logic          clk,
    input logic          rst_n,
    input logic [CW-1:0] count,
    input logic [PW-1:0] wr_ptr,
    input logic [PW-1:0] rd_ptr,
    input logic          fifo_full,
    input logic          fifo_empty,
    input logic          fifo_clear,
    input logic [DW-1:0] apb_rd_data
);
    // $past / $stable refer to the previous clock edge: only meaningful from
    // the second edge after a reset (the clock may not even run during reset).
    logic past_ok;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) past_ok <= 1'b0;
        else        past_ok <= 1'b1;
    end

    // count can never exceed DEPTH (overflow-safety)
    a_count_le_depth: assert property (@(posedge clk) disable iff (!rst_n)
        count <= DEPTH)
        else $error("FIFO count %0d exceeds DEPTH %0d", count, DEPTH);

    // flags are exact functions of occupancy
    a_full_iff:  assert property (@(posedge clk) disable iff (!rst_n)
        fifo_full  == (count == DEPTH));
    a_empty_iff: assert property (@(posedge clk) disable iff (!rst_n)
        fifo_empty == (count == 0));

    // the pointers and the count agree (modulo DEPTH; DEPTH is a power of 2)
    a_ptr_count: assert property (@(posedge clk) disable iff (!rst_n)
        PW'(wr_ptr - rd_ptr) == count[PW-1:0])
        else $error("FIFO wr_ptr %0d - rd_ptr %0d != count %0d", wr_ptr, rd_ptr, count);

    // occupancy moves by at most one per cycle, except on a clear
    a_count_step: assert property (@(posedge clk) disable iff (!rst_n)
        (past_ok && !$past(fifo_clear)) |-> (count == $past(count)) ||
                               (count == $past(count) + 1'b1) ||
                               (count + 1'b1 == $past(count)))
        else $error("FIFO count jumped %0d -> %0d", $past(count), count);

    // clear empties the FIFO and rewinds both pointers in the next cycle
    a_clear: assert property (@(posedge clk) disable iff (!rst_n)
        fifo_clear |=> (count == 0) && (wr_ptr == 0) && (rd_ptr == 0));

    // an empty FIFO reads 0, never stale storage (F18)
    a_empty_data: assert property (@(posedge clk) disable iff (!rst_n)
        fifo_empty |-> (apb_rd_data == '0));
endmodule

bind fifo_apb_adc fifo_sva #(.DEPTH(DEPTH), .DW(DATA_WIDTH)) u_fifo_sva (
    .clk(clk), .rst_n(rst_n), .count(count), .wr_ptr(wr_ptr), .rd_ptr(rd_ptr),
    .fifo_full(fifo_full), .fifo_empty(fifo_empty), .fifo_clear(fifo_clear),
    .apb_rd_data(apb_rd_data)
);

// ── Sampling FSM (wrapper_control_2) ─────────────────────────────────────────
module fsm_sva #(
    parameter CONV_TIMEOUT = 1344
)(
    input logic       clk,
    input logic       rstn,
    input logic [2:0] state,
    input logic       fifo_write_en,
    input logic       fifo_full,
    input logic       adc_en,
    input logic       err_fifo_full
);
    localparam logic [2:0] S_IDLE = 3'd0, S_CHECK_FIFO = 3'd1, S_ENABLE = 3'd2,
                           S_WAIT_START = 3'd3, S_WAIT_DONE = 3'd4, S_WRITE = 3'd5,
                           S_ERR_FULL = 3'd6, S_ERR_TIMEOUT = 3'd7;

    // $past / $stable refer to the previous clock edge: only meaningful from
    // the second edge after a reset (the clock may not even run during reset).
    logic past_ok;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) past_ok <= 1'b0;
        else        past_ok <= 1'b1;
    end

    // FIX-2: every 3-bit encoding is a state now (S_ERR_TIMEOUT = 7), so the
    // legal-state check is replaced by the bound the timeout guarantees:
    // adc_en is never high for more than CONV_TIMEOUT + 3 cycles
    int unsigned en_run;
    always @(posedge clk or negedge rstn)
        if (!rstn) en_run <= 0; else en_run <= adc_en ? en_run + 1 : 0;
    a_adc_en_bounded: assert property (@(posedge clk) disable iff (!rstn)
        en_run <= CONV_TIMEOUT + 3)
        else $error("adc_en high for %0d cycles (CONV_TIMEOUT %0d)", en_run, CONV_TIMEOUT);

`ifndef SVA_FSM_UNIT
    // the FSM must never push a sample while the FIFO is full
    a_no_write_when_full: assert property (@(posedge clk) disable iff (!rstn)
        !(fifo_write_en && fifo_full))
        else $error("wrapper_control_2 wrote to a FULL FIFO");
`endif

    // the push strobe is exactly one cycle
    a_write_one_cycle: assert property (@(posedge clk) disable iff (!rstn)
        fifo_write_en |=> !fifo_write_en);

    // the ADC is enabled in ENABLE / WAIT_START / WAIT_DONE and nowhere else
    a_adc_en_states: assert property (@(posedge clk) disable iff (!rstn)
        adc_en == (state == S_ENABLE || state == S_WAIT_START || state == S_WAIT_DONE));

    // only the legal arcs
    a_arc_idle:   assert property (@(posedge clk) disable iff (!rstn)
        (state == S_IDLE)       |=> (state == S_IDLE || state == S_CHECK_FIFO));
    a_arc_check:  assert property (@(posedge clk) disable iff (!rstn)
        (state == S_CHECK_FIFO) |=> (state == S_ENABLE || state == S_ERR_FULL));
    a_arc_enable: assert property (@(posedge clk) disable iff (!rstn)
        (state == S_ENABLE)     |=> (state == S_WAIT_START));
    a_arc_wstart: assert property (@(posedge clk) disable iff (!rstn)
        (state == S_WAIT_START) |=> (state == S_WAIT_START || state == S_WAIT_DONE || state == S_ERR_TIMEOUT));
    a_arc_wdone:  assert property (@(posedge clk) disable iff (!rstn)
        (state == S_WAIT_DONE)  |=> (state == S_WAIT_DONE || state == S_WRITE || state == S_ERR_TIMEOUT));
    a_arc_write:  assert property (@(posedge clk) disable iff (!rstn)
        (state == S_WRITE)      |=> (state == S_IDLE));
    a_arc_err:    assert property (@(posedge clk) disable iff (!rstn)
        (state == S_ERR_FULL)   |=> (state == S_IDLE));
    a_arc_timeout: assert property (@(posedge clk) disable iff (!rstn)
        (state == S_ERR_TIMEOUT) |=> (state == S_IDLE));

    // the drop flag rises only in the cycle after S_ERR_FULL
    a_err_rise: assert property (@(posedge clk) disable iff (!rstn)
        (past_ok && $rose(err_fifo_full)) |-> ($past(state) == S_ERR_FULL));
endmodule

bind wrapper_control_2 fsm_sva #(.CONV_TIMEOUT(CONV_TIMEOUT)) u_fsm_sva (
    .clk(clk), .rstn(rstn), .state(state),
    .fifo_write_en(fifo_write_en), .fifo_full(fifo_full),
    .adc_en(adc_en), .err_fifo_full(err_fifo_full)
);

// ── APB slave behaviour (adc_apb_wrapper_rev2 external port) ─────────────────
module apb_sva #(
    parameter ADDR_WIDTH = 12
)(
    input logic                  PCLK,
    input logic                  PRESETn,
    input logic                  PSEL,
    input logic                  PENABLE,
    input logic                  PWRITE,
    input logic [ADDR_WIDTH-1:0] PADDR,
    input logic [31:0]           PRDATA,
    input logic                  PREADY,
    input logic                  PSLVERR,
    input logic                  rtc_region
);
    // Wait states are legal on an RTC-passthrough collision (by design;
    // never PSLVERR). What the design promises instead: a stalled ACCESS completes
    // within a bounded number of cycles (worst case 13 PCLK; 40 leaves margin).
    a_stall_bounded: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE && !PREADY) |-> ##[1:40] PREADY)
        else $error("APB stall exceeded 40 PCLK");

    // ACCESS phase (PENABLE) can only occur while selected (checks the master)
    a_enable_needs_sel: assert property (@(posedge PCLK) disable iff (!PRESETn)
        PENABLE |-> PSEL);

    // never an error response (by design)
    a_no_pslverr: assert property (@(posedge PCLK) disable iff (!PRESETn)
        !PSLVERR)
        else $error("PSLVERR asserted");

    // only an RTC-region access may be stalled
    a_pready_non_rtc: assert property (@(posedge PCLK) disable iff (!PRESETn)
        !rtc_region |-> PREADY)
        else $error("PREADY low outside the RTC region (PADDR 0x%0h)", PADDR);

    // PRDATA is 0 whenever the slave is not in a read ACCESS
    a_prdata_idle_zero: assert property (@(posedge PCLK) disable iff (!PRESETn)
        !(PSEL && PENABLE && !PWRITE) |-> (PRDATA == 32'h0))
        else $error("PRDATA 0x%08h outside a read ACCESS", PRDATA);

    // reserved offsets and the write-only registers read 0
    wire mapped_rd = (PADDR == 'h004) || (PADDR == 'h008) || (PADDR == 'h00C) ||
                     (PADDR == 'h100) || (PADDR == 'h104) || (PADDR == 'h10C) ||
                     (PADDR == 'h224) || (PADDR == 'h228);
    a_reserved_reads_zero: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (PSEL && PENABLE && !PWRITE && !rtc_region && !mapped_rd) |-> (PRDATA == 32'h0))
        else $error("reserved offset 0x%0h read 0x%08h", PADDR, PRDATA);
endmodule

bind adc_apb_wrapper_rev2 apb_sva #(.ADDR_WIDTH(ADDR_WIDTH)) u_apb_sva (
    .PCLK(PCLK), .PRESETn(PRESETn),
    .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE), .PADDR(PADDR),
    .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR), .rtc_region(rtc_region)
);

// ── Wrapper internals (adc_apb_wrapper_rev2) ─────────────────────────────────
module wrap_sva #(
    parameter SAMPLE_WIDTH = 8
)(
    input logic                    PCLK,
    input logic                    PRESETn,
    input logic                    manual_trig,
    input logic                    fifo_clear,
    input logic                    fifo_rd_en,
    input logic                    fifo_empty,
    input logic                    adc_valid_rise,
    input logic [SAMPLE_WIDTH-1:0] adc_sample,
    input logic [31:0]             status_reg,
    // RTC passthrough as forwarded to rtc_control_2
    input logic                    rtc_psel,
    input logic                    PWRITE,
    input logic [2:0]              rtc_word,      // PADDR[4:2]: 3 = RTCCR
    input logic [31:0]             rtc_pwdata
);
    // $past / $stable refer to the previous clock edge: only meaningful from
    // the second edge after a reset (the clock may not even run during reset).
    logic past_ok;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) past_ok <= 1'b0;
        else        past_ok <= 1'b1;
    end

    // one APB write / read = one pulse (also checks the master: an ACCESS
    // held past its completing edge would stretch these)
    a_manual_trig_pulse: assert property (@(posedge PCLK) disable iff (!PRESETn)
        manual_trig |=> !manual_trig);
    a_fifo_clear_pulse:  assert property (@(posedge PCLK) disable iff (!PRESETn)
        fifo_clear |=> !fifo_clear);
    a_fifo_rd_en_pulse:  assert property (@(posedge PCLK) disable iff (!PRESETn)
        fifo_rd_en |=> !fifo_rd_en);

    // a pop is never issued to an empty FIFO
    a_no_pop_when_empty: assert property (@(posedge PCLK) disable iff (!PRESETn)
        fifo_rd_en |-> !fifo_empty)
        else $error("fifo_rd_en while the FIFO is empty");

    // the captured sample changes only on the synchronised rising edge of valid
    a_sample_capture: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (past_ok && !$stable(adc_sample)) |-> $past(adc_valid_rise))
        else $error("adc_sample changed without adc_valid_rise");

    // reserved status bits read 0
    a_status_reserved: assert property (@(posedge PCLK) disable iff (!PRESETn)
        status_reg[31:7] == 25'd0)     // [6] = ADC timeout (FIX-2)
        else $error("status_reg reserved bits set: 0x%08h", status_reg);

    // FIX-3: RTCCR.start is set-only at the wrapper - a firmware RTCCR write
    // reaches rtc_control_2 / the PL031 with bit 0 set, so it can never stop
    // the counter (the real PL031 clears start on a write of 0).
    a_rtccr_never_cleared: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (rtc_psel && PWRITE && rtc_word == 3'd3) |-> rtc_pwdata[0])
        else $error("RTCCR write forwarded with start = 0 (data 0x%08h)", rtc_pwdata);
endmodule

bind adc_apb_wrapper_rev2 wrap_sva #(.SAMPLE_WIDTH(SAMPLE_WIDTH)) u_wrap_sva (
    .PCLK(PCLK), .PRESETn(PRESETn),
    .manual_trig(manual_trig), .fifo_clear(fifo_clear), .fifo_rd_en(fifo_rd_en),
    .fifo_empty(fifo_empty), .adc_valid_rise(adc_valid_rise),
    .adc_sample(adc_sample), .status_reg(status_reg),
    .rtc_psel(rtc_psel), .PWRITE(PWRITE), .rtc_word(PADDR[4:2]), .rtc_pwdata(rtc_pwdata)
);

// ── RTC controller and the PL031 port (rtc_control_2) ────────────────────────
module rtc_sva (
    input logic        PCLK,
    input logic        PRESETn,
    input logic [4:0]  state,
    input logic        rtc_trig,
    input logic        ext_sel,
    input logic        fsm_psel,
    input logic        poll_enable,
    input logic [31:0] wd_ticks,
    input logic        pt_setup_done,
    input logic [31:0] eff_offset,
    input logic [31:0] armed_offset,
    input logic        por_fresh,
    input logic        PSEL,
    // the PL031 (Rtc) port
    input logic        rtc_psel,
    input logic        rtc_penable,
    input logic        rtc_pwrite,
    input logic [9:0]  rtc_paddr,
    input logic [31:0] rtc_pwdata
);
    localparam logic [4:0] S_READ_SETUP = 5'd3, S_WAITING = 5'd10, S_PULSE_TRIG = 5'd13, S_READ_CAPTURE = 5'd14;

    // $past / $stable refer to the previous clock edge: only meaningful from
    // the second edge after a reset (the clock may not even run during reset).
    logic past_ok;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) past_ok <= 1'b0;
        else        past_ok <= 1'b1;
    end

    a_legal_state: assert property (@(posedge PCLK) disable iff (!PRESETn)
        state <= S_READ_CAPTURE)
        else $error("rtc_control_2 illegal state %0d", state);

    // rtc_trig: one cycle, and only out of S_PULSE_TRIG
    a_trig_one_cycle: assert property (@(posedge PCLK) disable iff (!PRESETn)
        rtc_trig |=> !rtc_trig);
    a_trig_source: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (past_ok && rtc_trig) |-> ($past(state) == S_PULSE_TRIG))
        else $error("rtc_trig without S_PULSE_TRIG");

    // the FSM and a granted passthrough never drive the PL031 bus together
    a_bus_exclusive: assert property (@(posedge PCLK) disable iff (!PRESETn)
        !(ext_sel && fsm_psel))
        else $error("passthrough granted while the FSM drives the PL031 bus");

    // PL031 port protocol (the PL031 has no PREADY): every ACCESS directly
    // follows a SETUP with the same address, direction and write data ...
    a_pl031_access_after_setup: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (past_ok && rtc_penable) |-> (rtc_psel && $past(rtc_psel && !rtc_penable) &&
                         $stable(rtc_paddr) && $stable(rtc_pwrite) &&
                         (!rtc_pwrite || $stable(rtc_pwdata))))
        else $error("PL031 port: ACCESS without a matching SETUP (word %0d)", rtc_paddr);
    // ... and every SETUP is followed by its ACCESS in the next cycle
    a_pl031_setup_then_access: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (rtc_psel && !rtc_penable) |=> (rtc_psel && rtc_penable))
        else $error("PL031 port: SETUP not followed by ACCESS");

    // the missed-alarm watchdog count is frozen while polling is paused
    a_wd_frozen_paused: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (state == S_WAITING && !poll_enable) |=> $stable(wd_ticks))
        else $error("wd_ticks moved while polling is paused");

    // FIX-1: the offset re-arm (WAITING -> READ_SETUP) never pulses rtc_trig
    a_rearm_no_trig: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (past_ok && state == S_READ_SETUP && $past(state) == S_WAITING) |-> !rtc_trig)
        else $error("rtc_trig on the offset re-arm path");
    // FIX-1: parked in WAITING for 3 cycles with no passthrough and a stable
    // offset => the armed offset is the current one
    a_offset_armed: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (past_ok && state == S_WAITING && $past(state) == S_WAITING && $past(state, 2) == S_WAITING &&
         !$past(ext_sel) && !$past(ext_sel, 2) &&
         eff_offset == $past(eff_offset) && eff_offset == $past(eff_offset, 2)) |-> (armed_offset == eff_offset))
        else $error("armed_offset %0d != alarm offset %0d while parked", armed_offset, eff_offset);

    // a passthrough SETUP is only recorded for a transfer that is in flight
    a_setup_done_needs_psel: assert property (@(posedge PCLK) disable iff (!PRESETn)
        pt_setup_done |-> PSEL);

    // FIX-4: after a warm reset (PL031 not reset by nPOR) the FSM never unmasks
    // the PL031 interrupt (RTCIMSC = 1) before it has cleared it (RTCICR = 1),
    // so an alarm re-raised by the reset is never serviced twice.
    wire fsm_wr = rtc_psel && rtc_penable && rtc_pwrite && !ext_sel;
    logic warm_unclr;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)                                warm_unclr <= 1'b1;
        else if (por_fresh)                          warm_unclr <= 1'b0;
        else if (fsm_wr && rtc_paddr == 10'h007)     warm_unclr <= 1'b0;
    end
    a_warm_arm_clears: assert property (@(posedge PCLK) disable iff (!PRESETn)
        (fsm_wr && rtc_paddr == 10'h004) |-> !warm_unclr)
        else $error("FSM unmasked the PL031 interrupt after a warm reset without clearing it first");
endmodule

bind rtc_control_2 rtc_sva u_rtc_sva (
    .PCLK(PCLK), .PRESETn(PRESETn), .state(state), .rtc_trig(rtc_trig),
    .ext_sel(ext_sel), .fsm_psel(fsm_psel), .poll_enable(poll_enable),
    .wd_ticks(wd_ticks), .pt_setup_done(pt_setup_done), .PSEL(PSEL),
    .eff_offset(eff_offset), .armed_offset(armed_offset), .por_fresh(por_fresh),
    .rtc_psel(rtc_psel), .rtc_penable(rtc_penable), .rtc_pwrite(rtc_pwrite),
    .rtc_paddr(rtc_paddr), .rtc_pwdata(rtc_pwdata)
);

// ── SAR state machine (sarlogic; clk = sar_clk) ──────────────────────────────
module sar_sva (
    input logic       clk,
    input logic       rstn,
    input logic [2:0] state,
    input logic       valid,
    input logic [7:0] result
);
    localparam logic [2:0] S_SAMPLE = 3'd2, S_DONE = 3'd4, S_CAL = 3'd5;

    // $past / $stable refer to the previous clock edge: only meaningful from
    // the second edge after a reset (the clock may not even run during reset).
    logic past_ok;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) past_ok <= 1'b0;
        else        past_ok <= 1'b1;
    end

    a_legal_state: assert property (@(posedge clk) disable iff (!rstn)
        state <= S_CAL)
        else $error("sarlogic illegal state %0d", state);

    // result is updated only by the clock edge that leaves sDone
    a_result_only_in_done: assert property (@(posedge clk) disable iff (!rstn)
        (past_ok && !$stable(result)) |-> ($past(state) == S_DONE))
        else $error("sarlogic result changed outside sDone");

    // valid is low again one sar_clk after a conversion starts sampling
    a_valid_falls: assert property (@(posedge clk) disable iff (!rstn)
        (state == S_SAMPLE) |=> !valid)
        else $error("valid still high after sSample");
endmodule

bind sarlogic sar_sva u_sar_sva (
    .clk(clk), .rstn(rstn), .state(state), .valid(valid), .result(result)
);

// ── Comparator clock gating (sar_adc; clk = PCLK, sar_clk moves on its
// ── falling edge, so everything is settled at the rising edge) ───────────────
// Not checked between a reset and the first sar_clk high phase after it:
// sarlogic's `always @(clk) clkc <= ~clk & en_co_clk` is not sensitive to
// en_co_clk, so a reset asserted while sar_clk is low and the comparator clock
// is enabled leaves clkc at 1 in RTL simulation until sar_clk next moves
// (synthesis builds the AND gate, which drops at once). That is recorded as
// SUSPECTED RTL BUG ADC-CLKC by ADC/tb/sar_adc_cal_tb.sv (analog-owned RTL).
module sar_clk_sva (
    input logic clk,
    input logic rstn,
    input logic sar_clk,
    input logic clkc,
    input logic en_co_clk
);
    logic clkc_refreshed;
    always @(posedge clk or negedge rstn) begin
        if (!rstn)        clkc_refreshed <= 1'b0;
        else if (sar_clk) clkc_refreshed <= 1'b1;
    end

    a_clkc_gated: assert property (@(posedge clk) disable iff (!rstn)
        (clkc_refreshed && !en_co_clk) |-> !clkc)
        else $error("clkc high while en_co_clk is 0");
endmodule

bind sar_adc sar_clk_sva u_sar_clk_sva (
    .clk(clk), .rstn(rstn), .sar_clk(sar_clk), .clkc(clkc), .en_co_clk(u_logic.en_co_clk)
);
