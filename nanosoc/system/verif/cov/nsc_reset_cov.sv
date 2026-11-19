`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_reset_cov.sv — reset, clock control and system-control registers (batch 3)
//
//   nsc_reset_cov    bound into nanosoc_system. Reset CAUSE (pin, CPU
//                    SYSRESETREQ, debugger GPO, watchdog, lockup) x what the bus
//                    was doing when it hit (CPU/debug transfer, sensing
//                    transfer, sysio transfer, CPU asleep); release ORDERING of
//                    PORESETn / HRESETn / PRESETn; pulse width; a second request
//                    while still in reset.
//   nsc_clkctrl_cov  bound into nanosoc_clkctrl. PRESETn reset by SYSRESETREQ /
//                    LOCKUP&LOCKUPRESET; PCLKEN / gating activity (constant with
//                    CLKGATE_PRESENT=0 — confirms the tie-off); XTAL2 with
//                    SLEEPDEEP; DFT bypasses.
//   nsc_sysctrl_cov  bound into nanosoc_sysctrl (0x4001_F000). Every register and
//                    reserved range x direction x size; byte-lane writes to bit0
//                    registers (only lane 0 takes effect); REMAP/PMUENABLE/
//                    LOCKUPRESET written 0 and 1; RESETINFO set by each cause,
//                    W1C per bit, write-0 no-clear, sticky across warm reset,
//                    cleared by POR; reset values on first read (viol_ if wrong).
// -----------------------------------------------------------------------------
module nsc_reset_cov (
    input logic       SYS_FCLK,
    input logic       SYS_SYSRESETn,      // chip NRST pin (after pad)
    input logic       SYS_PORESETn,
    input logic       SYS_HRESETn,
    input logic       SYS_PRESETn,
    input logic       CPU_SYSRESETREQ,
    input logic       DEBUG_RESETREQ,     // ADP GPO8[0]
    input logic       SYS_WDOGRESETREQ,
    input logic       SYS_LOCKUPRESET,
    input logic       CPU_LOCKUP,
    input logic       SYS_SYSRESETREQ,
    input logic       CPU_SLEEPING,
    input logic       SYS_TESTMODE,
    input logic [1:0] CPU_0_HTRANS,
    input logic [1:0] DEBUG_HTRANS,
    input logic [1:0] DMAC_0_HTRANS,
    input logic       EXP_HSEL,
    input logic [1:0] EXP_HTRANS,
    input logic       EXP_HREADYOUT,
    input logic       SYSIO_HSEL,
    input logic [1:0] SYSIO_HTRANS
);
    // ---------------- cause of a reset request (rising edge) ----------------
    logic req_q, pin_q;
    logic [3:0] cause_q;
    always @(posedge SYS_FCLK) begin
        req_q <= SYS_SYSRESETREQ;
        pin_q <= SYS_SYSRESETn;
    end
    wire req_rise = SYS_SYSRESETREQ && !req_q;
    wire pin_fall = !SYS_SYSRESETn && pin_q;
    wire [3:0] cause = {CPU_LOCKUP && SYS_LOCKUPRESET, SYS_WDOGRESETREQ, DEBUG_RESETREQ, CPU_SYSRESETREQ};

    // bus activity snapshot (one FCLK earlier than the reset edge)
    logic cpu_busy, dbg_busy, dma_busy, exp_busy, exp_stalled, sysio_busy, sleeping;
    always @(posedge SYS_FCLK) begin
        cpu_busy    <= CPU_0_HTRANS[1];
        dbg_busy    <= DEBUG_HTRANS[1];
        dma_busy    <= DMAC_0_HTRANS[1];
        exp_busy    <= EXP_HSEL && EXP_HTRANS[1];
        exp_stalled <= !EXP_HREADYOUT;
        sysio_busy  <= SYSIO_HSEL && SYSIO_HTRANS[1];
        sleeping    <= CPU_SLEEPING;
    end

    // ---------------- release ordering ---------------------------------------
    logic po_q, h_q, p_q;
    always @(posedge SYS_FCLK) begin po_q <= SYS_PORESETn; h_q <= SYS_HRESETn; p_q <= SYS_PRESETn; end
    wire po_rise = SYS_PORESETn && !po_q;
    wire h_rise  = SYS_HRESETn  && !h_q;
    wire p_rise  = SYS_PRESETn  && !p_q;
    wire h_fall  = !SYS_HRESETn && h_q;

    int unsigned h_low_cycles;
    always @(posedge SYS_FCLK) h_low_cycles <= SYS_HRESETn ? 0 : h_low_cycles + 1;

    covergroup cg_reset_cause;
        option.per_instance = 1;
        cp_cause : coverpoint cause iff (req_rise) {
            bins cpu_sysresetreq = {4'b0001};
            bins debugger_gpo    = {4'b0010};
            bins watchdog        = {4'b0100};
            bins lockup          = {4'b1000};
            bins simultaneous    = {4'b0011, 4'b0101, 4'b0110, 4'b0111, 4'b1001, 4'b1010,
                                    4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        }
        cp_ctx : coverpoint {cpu_busy, dbg_busy, exp_busy, sysio_busy, sleeping} iff (req_rise || pin_fall) {
            wildcard bins cpu_transfer    = {5'b1????};
            wildcard bins debug_transfer  = {5'b?1???};
            wildcard bins sensing_transfer = {5'b??1??};
            wildcard bins sysio_transfer  = {5'b???1?};
            wildcard bins cpu_asleep      = {5'b????1};
            bins quiet = {5'b00000};
        }
        x_cause_ctx : cross cp_cause, cp_ctx;
        cp_pin : coverpoint pin_fall { bins nrst_pin_asserted = {1'b1}; }
        cp_pin_ctx : coverpoint {cpu_busy, dbg_busy, exp_busy} iff (pin_fall) {
            bins quiet = {3'b000}; bins busy = {[3'b001:3'b111]};
        }
        cp_exp_stalled_at_reset : coverpoint exp_stalled iff (req_rise || pin_fall) {
            bins sensing_wait_state_in_progress = {1'b1};
        }
        cp_dma_at_reset : coverpoint dma_busy iff (req_rise || pin_fall) {
            bins dma_transfer = {1'b1};               // unreachable: no DMA (F14)
        }
        cp_req_during_reset : coverpoint (SYS_SYSRESETREQ && !SYS_HRESETn) {
            bins request_while_in_reset = {1'b1};
        }
        cp_testmode : coverpoint SYS_TESTMODE { bins functional = {1'b0}; bins dft_bypass = {1'b1}; }
    endgroup

    covergroup cg_reset_order;
        option.per_instance = 1;
        // HRESETn release relative to the other domains
        cp_h_release : coverpoint {SYS_PORESETn, SYS_PRESETn} iff (h_rise) {
            bins after_po_before_p = {2'b10};
            bins after_po_and_p    = {2'b11};
            bins viol_before_po    = {2'b00, 2'b01};
        }
        cp_p_release : coverpoint {SYS_PORESETn, SYS_HRESETn} iff (p_rise) {
            bins after_po_and_h    = {2'b11};
            bins before_h          = {2'b10};
            bins viol_before_po    = {2'b00, 2'b01};
        }
        cp_same_cycle : coverpoint {h_rise, p_rise} {
            bins h_and_p_same_cycle = {2'b11};
        }
        cp_po_release : coverpoint po_rise { bins poreset_released = {1'b1}; }
        cp_h_assert_kind : coverpoint SYS_PORESETn iff (h_fall) {
            bins warm = {1'b1};          // POR stays high: RESETINFO etc. must survive
            bins cold = {1'b0};
        }
        cp_pulse_width : coverpoint h_low_cycles iff (h_rise) {
            bins short_lt4 = {[0:3]}; bins normal = {[4:31]}; bins long_32plus = {[32:$]};
        }
        cp_p_without_h : coverpoint {SYS_HRESETn, SYS_PRESETn} {
            bins presetn_only = {2'b10};  // APB domain in reset, AHB running
            bins hresetn_only = {2'b01};
        }
    endgroup

    cg_reset_cause cg_c = new;
    cg_reset_order cg_o = new;
    always @(posedge SYS_FCLK) begin cg_c.sample(); cg_o.sample(); end
endmodule

// -----------------------------------------------------------------------------
module nsc_clkctrl_cov (
    input logic XTAL1,
    input logic NRST,
    input logic APBACTIVE,
    input logic SLEEPING,
    input logic SLEEPDEEP,
    input logic SYSRESETREQ,
    input logic DBGRESETREQ,
    input logic LOCKUP,
    input logic LOCKUPRESET,
    input logic CGBYPASS,
    input logic RSTBYPASS,
    input logic XTAL2,
    input logic PCLKEN,
    input logic PRESETn
);
    logic presetn_q;
    always @(posedge XTAL1) presetn_q <= PRESETn;
    wire p_fall = !PRESETn && presetn_q;

    covergroup cg_clkctrl;
        option.per_instance = 1;
        cp_preset_cause : coverpoint {NRST, SYSRESETREQ, LOCKUP && LOCKUPRESET} iff (p_fall) {
            bins pin          = {3'b000, 3'b001, 3'b010, 3'b011};
            bins sysresetreq  = {3'b110};
            bins lockup       = {3'b101};
            bins both_req     = {3'b111};
        }
        cp_lockup_no_reset : coverpoint {LOCKUP, LOCKUPRESET} {
            bins lockup_reset_disabled = {2'b10};     // CPU locked, no auto-reset
            bins lockup_reset_enabled  = {2'b11};
        }
        cp_dbgresetreq : coverpoint DBGRESETREQ { bins requested = {1'b1}; }
        cp_pclken : coverpoint PCLKEN { bins enabled = {1'b1}; bins divided = {1'b0}; }
        cp_apbactive : coverpoint APBACTIVE { bins idle = {1'b0}; bins active = {1'b1}; }
        cp_xtal2_deep : coverpoint SLEEPDEEP { bins awake = {1'b0}; bins deep_sleep_xtal2_low = {1'b1}; }
        cp_sleep_apb : coverpoint {SLEEPING, APBACTIVE} { bins asleep_apb_active = {2'b11}; }
        cp_dft : coverpoint {CGBYPASS, RSTBYPASS} { bins functional = {2'b00}; bins bypass = {[1:3]}; }
    endgroup

    cg_clkctrl cg = new;
    always @(posedge XTAL1) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_sysctrl_cov (
    input logic        HCLK,
    input logic        HRESETn,
    input logic        FCLK,
    input logic        PORESETn,
    input logic        HSEL,
    input logic        HREADY,
    input logic [1:0]  HTRANS,
    input logic [2:0]  HSIZE,
    input logic        HWRITE,
    input logic [11:0] HADDR,
    input logic [31:0] HWDATA,
    input logic        SYSRESETREQ,
    input logic        WDOGRESETREQ,
    input logic        LOCKUP,
    input logic        reg_remap,
    input logic        reg_pmuenable,
    input logic        reg_lockupreset,
    input logic [2:0]  reg_resetinfo,
    input logic        reg_write_enable,
    input logic        reg_read_enable,
    input logic [11:2] reg_addr,
    input logic [3:0]  reg_byte_strobe,
    input logic [31:0] read_mux_le
);
    typedef enum logic [3:0] {
        S_REMAP, S_PMUEN, S_LOCKRST, S_RSVD_00C, S_RESETINFO, S_RSVD_014,
        S_RSVD_MID, S_PID, S_CID, S_RSVD_FC0
    } sreg_e;
    function automatic sreg_e sdec(input logic [11:2] a);
        if (a == 10'h000) return S_REMAP;
        if (a == 10'h001) return S_PMUEN;
        if (a == 10'h002) return S_LOCKRST;
        if (a == 10'h003) return S_RSVD_00C;
        if (a == 10'h004) return S_RESETINFO;
        if (a <= 10'h007) return S_RSVD_014;
        if (a[11:6] != 6'h3F) return S_RSVD_MID;
        if (a[5:2] < 4'h4) return S_RSVD_FC0;        // 0xFC0..0xFCC
        if (a[5:2] < 4'hC) return S_PID;             // 0xFD0..0xFEC
        return S_CID;                                // 0xFF0..0xFFC
    endfunction

    wire   ap = HSEL && HTRANS[1] && HREADY;
    sreg_e ar; assign ar = sdec(HADDR[11:2]);
    sreg_e dr; assign dr = sdec(reg_addr);         // data-phase register

    // first data-phase read per register since HRESETn
    logic [9:0] touched;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) touched <= '0;
        else if ((reg_read_enable || reg_write_enable) && HREADY) touched[dr] <= 1'b1;
    wire first_rd = reg_read_enable && !touched[dr];
    function automatic logic reset_ok(input sreg_e r, input logic [31:0] d);
        case (r)
            S_REMAP:   return d == 32'h1;
            S_PMUEN:   return d == 32'h0;
            S_LOCKRST: return d == 32'h0;
            S_RESETINFO: return d[31:3] == 0;
            default:   return 1'b1;
        endcase
    endfunction

    wire wr_dp = reg_write_enable;   // data phase of a write (HWDATA valid)
    logic [2:0] ri_q;  logic h_q, po_q;
    always @(posedge FCLK) begin ri_q <= reg_resetinfo; h_q <= HRESETn; po_q <= PORESETn; end
    wire h_rise = HRESETn && !h_q;
    wire po_fall = !PORESETn && po_q;
    wire [2:0] ri_set = reg_resetinfo & ~ri_q;

    covergroup cg_sysctrl;
        option.per_instance = 1;
        cp_reg : coverpoint ar iff (ap) {
            bins remap = {S_REMAP}; bins pmuenable = {S_PMUEN}; bins lockupreset = {S_LOCKRST};
            bins rsvd_00c = {S_RSVD_00C}; bins resetinfo = {S_RESETINFO}; bins rsvd_014_01c = {S_RSVD_014};
            bins rsvd_020_fbc = {S_RSVD_MID}; bins rsvd_fc0_fcc = {S_RSVD_FC0};
            bins pid = {S_PID}; bins cid = {S_CID};
        }
        cp_dir  : coverpoint HWRITE iff (ap) { bins read = {0}; bins write = {1}; }
        cp_size : coverpoint HSIZE iff (ap) { bins byte_ = {0}; bins half = {1}; bins word = {2}; }
        x_reg_dir  : cross cp_reg, cp_dir;
        x_reg_size : cross cp_reg, cp_size;
        // bit0 registers only update when byte lane 0 is strobed
        cp_lane0 : coverpoint reg_byte_strobe[0] iff (wr_dp && (dr == S_REMAP || dr == S_PMUEN || dr == S_LOCKRST || dr == S_RESETINFO)) {
            bins lane0_written = {1'b1};
            bins other_lane_only_no_effect = {1'b0};
        }
        cp_remap_val : coverpoint HWDATA[0] iff (wr_dp && dr == S_REMAP && reg_byte_strobe[0]) {
            bins remap_off_imem_at_0 = {1'b0}; bins remap_on_bootrom_at_0 = {1'b1};
        }
        cp_pmuen_val : coverpoint HWDATA[0] iff (wr_dp && dr == S_PMUEN && reg_byte_strobe[0]) {
            bins pmu_disable = {1'b0}; bins pmu_enable = {1'b1};
        }
        cp_lockrst_val : coverpoint HWDATA[0] iff (wr_dp && dr == S_LOCKRST && reg_byte_strobe[0]) {
            bins disable_ = {1'b0}; bins enable = {1'b1};
        }
        cp_resv_bits : coverpoint (|HWDATA[31:1]) iff (wr_dp && (dr == S_REMAP || dr == S_PMUEN || dr == S_LOCKRST)) {
            bins reserved_bits_written_one = {1'b1};
        }
        cp_ri_set : coverpoint ri_set {
            bins by_sysresetreq = {3'b001}; bins by_watchdog = {3'b010}; bins by_lockup = {3'b100};
            bins several = {3'b011, 3'b101, 3'b110, 3'b111};
        }
        cp_ri_w1c : coverpoint (HWDATA[2:0] & reg_resetinfo) iff (wr_dp && dr == S_RESETINFO && reg_byte_strobe[0]) {
            bins clear_bit0 = {3'b001}; bins clear_bit1 = {3'b010}; bins clear_bit2 = {3'b100};
            bins clear_several = {3'b011, 3'b101, 3'b110, 3'b111};
            bins write_zero_no_clear = {3'b000};
        }
        cp_ri_survives_warm : coverpoint (reg_resetinfo != 0) iff (h_rise && PORESETn) {
            bins kept_across_warm_reset = {1'b1};
            bins empty_after_warm_reset = {1'b0};
        }
        cp_ri_por_clear : coverpoint (ri_q != 0) iff (po_fall) { bins por_clears_nonzero = {1'b1}; }
        cp_first_read : coverpoint dr iff (first_rd) {
            bins remap = {S_REMAP}; bins pmuenable = {S_PMUEN}; bins lockupreset = {S_LOCKRST};
            bins resetinfo = {S_RESETINFO};
        }
        cp_reset_value : coverpoint reset_ok(dr, read_mux_le) iff (first_rd) {
            bins ok = {1'b1}; bins viol_reset_value = {1'b0};
        }
        cp_state : coverpoint {reg_remap, reg_pmuenable, reg_lockupreset} {
            bins reset_state      = {3'b100};
            bins imem_at_zero     = {3'b000};
            wildcard bins pmu_enabled = {3'b?1?};
            wildcard bins lockup_reset_armed = {3'b??1};
        }
    endgroup

    cg_sysctrl cg = new;
    always @(posedge HCLK) cg.sample();
endmodule
