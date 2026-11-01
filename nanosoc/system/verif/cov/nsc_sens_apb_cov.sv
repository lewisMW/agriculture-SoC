`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_sens_apb_cov.sv — sensing peripheral register interface, gap coverage.
//
// Bound into adc_apb_wrapper_rev2 (see nsc_bind_sensing.sv). Complements the
// pre-existing agriculture_soc_main/verif/cov/wrapper_cov.sv (which covers
// register x direction, trigger sources, FIFO status, clear contexts) with the
// things a tape-out review asks for and nothing measured before:
//
//   cg_sens_reg   sub-word writes (PSTRB) per register, reserved-offset and
//                 misaligned accesses, address aliasing above 4 KB (nanosoc
//                 drives a 16-bit PADDR into 12-bit decode — finding F5),
//                 read-only registers written / write-only registers read,
//                 reserved bits written as 1, PPROT user vs privileged,
//                 first access after reset per register (reset values),
//                 access latency after reset release, write->read same reg,
//                 empty-FIFO reads that return never-written storage (F18),
//                 fifo_clear coincident with a push / a pop.
//   cg_sens_rst   PRESETn asserted mid-APB-transfer, mid-conversion, with data
//                 in the FIFO, while the RTC FSM is mid-arm; warm vs POR.
//
// viol_* bins must stay at 0 (holes.py reports them as ERRORs):
//   viol_reset_value     first read after reset returned a non-reset value
//   viol_pslverr         wrapper signalled PSLVERR (HANDOFF decision #2)
// -----------------------------------------------------------------------------
module nsc_sens_apb_cov #(
    parameter int ADDR_WIDTH = 12
)(
    input logic                  PCLK,
    input logic                  PRESETn,
    input logic                  nPOR,
    input logic                  PSEL,
    input logic                  PENABLE,
    input logic                  PWRITE,
    input logic [ADDR_WIDTH-1:0] PADDR,
    input logic [31:0]           PWDATA,
    input logic [31:0]           PRDATA,
    input logic [3:0]            PSTRB,
    input logic [2:0]            PPROT,
    input logic                  PREADY,
    input logic                  PSLVERR,
    input logic                  adc_en,
    input logic                  fifo_empty,
    input logic                  fifo_write_en,
    input logic                  fifo_rd_en,
    input logic                  fifo_clear,
    input logic [4:0]            rtc_state,
    input logic [3:0]            fifo_rd_ptr,
    input logic [3:0]            fifo_wr_ptr
);
    // ---------------- register decode (mirrors adc_apb_wrapper_rev2) --------
    typedef enum logic [3:0] {
        R_STATUS, R_MEAS_HI, R_MEAS_LO, R_PLL, R_AMUX, R_TRIG, R_CAL,
        R_RTC, R_FCLR, R_ALARM, R_RTCCTRL, R_UNMAPPED
    } reg_e;

    wire [11:0] off    = PADDR[11:0];
    wire        hi_set = (ADDR_WIDTH > 12) ? (|(PADDR >> 12)) : 1'b0;
    wire        rtc_rg = ((off & 12'hFE0) == 12'h200);   // same mask the RTL uses

    function automatic reg_e decode(input logic [ADDR_WIDTH-1:0] a);
        if (((a[11:0] & 12'hFE0) == 12'h200)) return R_RTC;   // aliases with upper bits (F5)
        if ((ADDR_WIDTH > 12) && (|(a >> 12))) return R_UNMAPPED;
        case (a[11:0])
            12'h004: return R_STATUS;
            12'h008: return R_MEAS_HI;
            12'h00C: return R_MEAS_LO;
            12'h100: return R_PLL;
            12'h104: return R_AMUX;
            12'h108: return R_TRIG;
            12'h10C: return R_CAL;
            12'h220: return R_FCLR;
            12'h224: return R_ALARM;
            12'h228: return R_RTCCTRL;
            default: return R_UNMAPPED;
        endcase
    endfunction

    wire  xfer   = PSEL && PENABLE && PREADY;
    wire  wr     = xfer && PWRITE;
    wire  rd     = xfer && !PWRITE;
    reg_e r;
    assign r = decode(PADDR);

    // reserved-bit content of a write (bits the register does not implement)
    logic resv_bits;
    always_comb begin
        case (r)
            R_AMUX:    resv_bits = |PWDATA[31:2];
            R_CAL:     resv_bits = |PWDATA[31:1];
            R_TRIG:    resv_bits = |PWDATA[31:1];
            R_RTCCTRL: resv_bits = |PWDATA[31:1];
            default:   resv_bits = 1'b0;
        endcase
    end

    // ---------------- first access after reset (reset values) --------------
    logic [11:0] touched;          // one bit per reg_e: accessed since reset
    logic [31:0] cyc_since_rst;
    logic        any_access;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            touched <= '0; cyc_since_rst <= 0; any_access <= 1'b0;
        end else begin
            if (cyc_since_rst != 32'hFFFF_FFFF) cyc_since_rst <= cyc_since_rst + 1;
            if (xfer) begin touched[r] <= 1'b1; any_access <= 1'b1; end
        end
    end
    wire first_rd = rd && !touched[r];

    function automatic logic reset_value_ok(input reg_e rr, input logic [31:0] d);
        case (rr)
            R_STATUS:  return d[31:6] == 0;               // live status; upper bits 0
            R_MEAS_HI: return d == 32'h0;
            R_PLL:     return d == 32'h0;
            R_AMUX:    return d == 32'h0;
            R_CAL:     return d == 32'h0;
            R_ALARM:   return d == 32'd5;                // DEFAULT_ALARM_OFFSET
            R_RTCCTRL: return d == 32'h1;                // polling enabled
            R_TRIG, R_FCLR, R_UNMAPPED: return d == 32'h0; // WO / unmapped read 0
            default:   return 1'b1;                      // MEAS_LO / RTC: data-dependent
        endcase
    endfunction

    // ---------------- previous transfer (write -> read same register) -------
    reg_e last_r;  logic last_wr, last_valid;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin last_valid <= 1'b0; last_wr <= 1'b0; last_r <= R_UNMAPPED; end
        else if (xfer) begin last_valid <= 1'b1; last_wr <= PWRITE; last_r <= r; end
    end

    // ---------------- FIFO slots written since reset (F18) ------------------
    logic [15:0] slot_written;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)                          slot_written <= '0;
        else if (fifo_write_en && !fifo_clear) slot_written[fifo_wr_ptr] <= 1'b1;
    end

    // ---------------- APB protocol as seen by the slave ----------------------
    // A master must hold an ACCESS until PREADY, and must not stay in ACCESS
    // after the completing edge (PENABLE low or PSEL low next). Both were
    // violated by existing benches (finding F20), which makes any wait-state
    // result from those benches meaningless - so the stimulus is checked here.
    logic acc_q, done_q;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin acc_q <= 1'b0; done_q <= 1'b0; end
        else begin
            acc_q  <= PSEL && PENABLE && !PREADY;   // stalled ACCESS pending
            done_q <= PSEL && PENABLE &&  PREADY;   // ACCESS completed
        end
    end
    wire abandoned  = acc_q  && !(PSEL && PENABLE);
    wire held_after = done_q &&  (PSEL && PENABLE);

    covergroup cg_sens_reg;
        option.per_instance = 1;

        // Sub-word writes: the RTL ignores PSTRB (finding F6).
        cp_wr_reg : coverpoint r iff (wr) {
            bins status = {R_STATUS}; bins meas_hi = {R_MEAS_HI}; bins meas_lo = {R_MEAS_LO};
            bins pll = {R_PLL}; bins amux = {R_AMUX}; bins adc_trigger = {R_TRIG};
            bins adc_cal = {R_CAL}; bins rtc_region = {R_RTC}; bins fifo_clear = {R_FCLR};
            bins alarm_offset = {R_ALARM}; bins rtc_ctrl = {R_RTCCTRL};
            bins unmapped = {R_UNMAPPED};
        }
        cp_wr_strb : coverpoint PSTRB iff (wr) {
            bins word       = {4'b1111};
            bins half_lo    = {4'b0011};
            bins half_hi    = {4'b1100};
            bins byte_lane[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins other      = default;
        }
        x_wr_reg_strb : cross cp_wr_reg, cp_wr_strb;

        // Reserved / misaligned offsets inside the 4 KB decode
        cp_reserved_off : coverpoint off iff (xfer && r == R_UNMAPPED && !hi_set) {
            bins off_000          = {12'h000};
            bins below_100        = {[12'h010:12'h0FC]};
            bins between_110_1fc  = {[12'h110:12'h1FC]};
            bins above_22c        = {[12'h22C:12'hFFF]};
        }
        cp_misaligned : coverpoint off[1:0] iff (xfer) {
            bins aligned = {2'b00};
            bins misaligned = {[2'b01:2'b11]};  // PADDR[1:0] ignored by the decode
        }
        // Aliasing above 4 KB (16-bit PADDR in nanosoc, F5)
        cp_alias : coverpoint {hi_set, rtc_rg} iff (xfer) {
            bins in_window      = {2'b00, 2'b01};
            bins other_alias    = {2'b10};     // reads 0 / write ignored
            bins rtc_alias      = {2'b11};     // reaches the PL031!
        }
        cp_alias_dir : coverpoint PWRITE iff (xfer && hi_set) { bins read = {1'b0}; bins write = {1'b1}; }

        // Wrong-direction accesses (must be harmless)
        cp_ro_written : coverpoint r iff (wr) {
            bins status  = {R_STATUS};
            bins meas_hi = {R_MEAS_HI};
            bins meas_lo = {R_MEAS_LO};       // must NOT pop / push
        }
        cp_wo_read : coverpoint r iff (rd) {
            bins adc_trigger = {R_TRIG};
            bins fifo_clear  = {R_FCLR};
        }
        cp_resv_bits : coverpoint r iff (wr && resv_bits) {
            bins amux = {R_AMUX}; bins adc_cal = {R_CAL};
            bins adc_trigger = {R_TRIG}; bins rtc_ctrl = {R_RTCCTRL};
        }
        cp_trig_noop : coverpoint PWDATA[0] iff (wr && r == R_TRIG) {
            bins write_zero = {1'b0};          // write without the trigger bit
            bins write_one  = {1'b1};
        }
        cp_pprot : coverpoint {PPROT[0], PPROT[2]} iff (xfer) {
            bins user_data = {2'b00};
            bins priv_data = {2'b10};
            bins instr     = {2'b01, 2'b11};   // instruction fetch from a peripheral
        }

        // Reset values: first access to each register after PRESETn
        cp_first_read : coverpoint r iff (first_rd) {
            bins status = {R_STATUS}; bins meas_hi = {R_MEAS_HI}; bins meas_lo = {R_MEAS_LO};
            bins pll = {R_PLL}; bins amux = {R_AMUX}; bins adc_trigger = {R_TRIG};
            bins adc_cal = {R_CAL}; bins rtc_region = {R_RTC}; bins fifo_clear = {R_FCLR};
            bins alarm_offset = {R_ALARM}; bins rtc_ctrl = {R_RTCCTRL};
        }
        cp_reset_value : coverpoint reset_value_ok(r, PRDATA) iff (first_rd) {
            bins ok = {1'b1};
            bins viol_reset_value = {1'b0};
        }
        cp_first_access_latency : coverpoint cyc_since_rst iff (xfer && !any_access) {
            bins immediate = {[0:3]};
            bins soon      = {[4:31]};
            bins later     = {[32:$]};
        }
        cp_wr_then_rd : coverpoint (last_valid && last_wr && rd && last_r == r) {
            bins readback = {1'b1};
        }

        // MEAS_LO read while empty: returns stale or never-written storage (F18)
        cp_empty_read : coverpoint slot_written[fifo_rd_ptr] iff (rd && r == R_MEAS_LO && fifo_empty) {
            bins stale_sample  = {1'b1};
            bins never_written = {1'b0};       // X in 4-state sim / random on silicon
        }
        // fifo_clear racing with FIFO traffic (count clears synchronously, F19)
        cp_clear_race : coverpoint {fifo_write_en, fifo_rd_en} iff (fifo_clear) {
            bins with_push = {2'b10};
            // fifo_clear and fifo_rd_en are both 1-cycle pulses registered from
            // the ACCESS phase of their own APB transfer; one APB master cannot
            // have two ACCESS phases in one cycle, so these cannot occur.
            ignore_bins with_pop  = {2'b01};
            ignore_bins with_both = {2'b11};
        }
        cp_apb_master_protocol : coverpoint {abandoned, held_after} {
            bins legal = {2'b00};
            bins viol_access_abandoned_while_stalled = {2'b10, 2'b11};
            bins viol_access_held_after_completion   = {2'b01};
        }
        cp_pslverr : coverpoint PSLVERR iff (PSEL && PENABLE && PREADY) {
            bins okay = {1'b0};
            bins viol_pslverr = {1'b1};
        }
    endgroup

    // ---------------- reset in the middle of activity ----------------------
    logic psel_q, pen_q, adc_en_q, empty_q;
    logic [4:0] rtc_state_q;
    always @(posedge PCLK) begin
        psel_q <= PSEL; pen_q <= PENABLE; adc_en_q <= adc_en;
        empty_q <= fifo_empty; rtc_state_q <= rtc_state;
    end

    covergroup cg_sens_rst;
        option.per_instance = 1;
        cp_rst_bus : coverpoint {psel_q, pen_q} {
            bins idle   = {2'b00};
            bins setup  = {2'b10};
            bins access = {2'b11};             // incl. a stalled RTC passthrough
        }
        cp_rst_conv  : coverpoint adc_en_q { bins idle = {1'b0}; bins converting = {1'b1}; }
        cp_rst_fifo  : coverpoint empty_q  { bins empty = {1'b1}; bins holding_data = {1'b0}; }
        cp_rst_rtc   : coverpoint rtc_state_q {
            bins idle    = {5'd0};
            bins waiting = {5'd10};
            bins arming  = {[5'd1:5'd9], 5'd14};
            bins servicing = {[5'd11:5'd13]};
        }
        cp_rst_kind  : coverpoint nPOR { bins warm = {1'b1}; bins power_on = {1'b0}; }
        x_rst_bus_kind : cross cp_rst_bus, cp_rst_kind;
    endgroup

    cg_sens_reg cg_reg = new;
    cg_sens_rst cg_rst = new;
    always @(posedge PCLK) if (PRESETn) cg_reg.sample();
    always @(negedge PRESETn) cg_rst.sample();
endmodule
