`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_debug_pins_cov.sv — debug paths, pads / pin-mux, DMA tie-offs (batch 6)
//
//   nsc_adp_cov        bound into socdebug_adp_control (the ADP AHB debug master):
//                      every FSM state (6-bit binary: socdebug_adp_control.v
//                      hard-defines ADPFSMDESIGN; codes 45-63 illegal), every
//                      command letter, access size, bus-error reporting, GPO bits
//                      (bit0 = system reset request), GPI, STDIO tube in both
//                      directions, host back-pressure.
//   nsc_debug_path_cov bound into nanosoc_system: FT1248 vs hostio4/EXTIO mode
//                      (P1[7] strap), ADP and data-stream traffic in each mode,
//                      USRT0<->USRT1 loopback (FT mode), strap changing at run time.
//   nsc_pins_cov       bound into nanosoc_chip: per pad (P0[15:0], P1[15:0]):
//                      driven 0 / driven 1 / input 0 / input 1 / contention
//                      (chip drives and the pin reads back different);
//                      TEST pin; SWD clock activity; SWDIO driven.
//   nsc_pinmux_cov     bound into nanosoc_system: P1 alternate-function bits
//                      1/3/5 x FT1248MODE, who owns P1[0..7] in each mode.
//   nsc_dma_cov        bound into nanosoc_ss_dma: DMA masters issue transfers;
//                      DMA requests raised while no DMA controller is configured
//                      (requests silently lost, F14).
// -----------------------------------------------------------------------------
module nsc_adp_cov (
    input logic        HCLK,
    input logic        HRESETn,
    input logic [5:0]  adp_state,
    input logic [7:0]  adp_cmd,
    input logic        adp_bus_err,
    input logic [1:0]  HTRANS2_o,
    input logic [2:0]  HSIZE3_o,
    input logic        HWRITE_o,
    input logic        HREADY_i,
    input logic        HRESP_i,
    input logic [7:0]  GPO8_o,
    input logic [7:0]  GPI8_i,
    input logic        COMRX_TVALID_i, COMRX_TREADY_o, COMTX_TVALID_o, COMTX_TREADY_i,
    input logic        STDRX_TVALID_i, STDRX_TREADY_o, STDTX_TVALID_o, STDTX_TREADY_i
);
    localparam logic [5:0] ST_ACTION = 6'd22;   // ADP_ACTION (6'b010110)
    wire in_action = (adp_state == ST_ACTION);
    logic err_q; logic [7:0] gpo_q;
    always @(posedge HCLK) begin err_q <= adp_bus_err; gpo_q <= GPO8_o; end
    wire ap = HTRANS2_o[1] && HREADY_i;

    covergroup cg_adp;
        option.per_instance = 1;
        cp_state : coverpoint adp_state {
            bins st[] = {[0:44]};
            bins viol_illegal_code = {[45:63]};
        }
        cp_cmd : coverpoint adp_cmd iff (in_action) {
            bins addr_A = {"A", "a"}; bins ctrl_C = {"C", "c"}; bins read_R = {"R", "r"};
            bins stdin_S = {"S", "s"}; bins write_W = {"W", "w"}; bins exit_X = {"X", "x"};
            bins fill_F = {"F", "f"}; bins mask_M = {"M", "m"}; bins poll_P = {"P", "p"};
            bins upload_U = {"U", "u"}; bins value_V = {"V", "v"};
            bins empty_line = {"?"};
            bins unknown = default;
        }
        cp_size : coverpoint HSIZE3_o iff (ap) { bins byte_ = {0}; bins half = {1}; bins word = {2}; }
        cp_dir  : coverpoint HWRITE_o iff (ap) { bins read = {0}; bins write = {1}; }
        x_size_dir : cross cp_size, cp_dir;
        cp_bus_err : coverpoint (adp_bus_err && !err_q) { bins bus_error_flagged = {1'b1}; }
        cp_gpo_set : coverpoint (GPO8_o & ~gpo_q) {
            bins reset_request_bit0 = {8'h01};
            wildcard bins other_bits = {8'b???????1, 8'b??????1?, 8'b?????1??, 8'b????1???,
                                        8'b???1????, 8'b??1?????, 8'b?1??????, 8'b1???????};
        }
        cp_gpi : coverpoint (|GPI8_i) { bins gpi_seen = {1'b1}; }
        cp_std_rx : coverpoint (STDRX_TVALID_i && STDRX_TREADY_o) { bins stdin_byte = {1'b1}; }
        cp_std_tx : coverpoint (STDTX_TVALID_o && STDTX_TREADY_i) { bins stdout_byte = {1'b1}; }
        cp_com_bp : coverpoint (COMTX_TVALID_o && !COMTX_TREADY_i) { bins host_backpressure = {1'b1}; }
        cp_rx_bp  : coverpoint (COMRX_TVALID_i && !COMRX_TREADY_o) { bins adp_backpressure = {1'b1}; }
    endgroup
    cg_adp cg = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_debug_path_cov (
    input logic SYS_HCLK,
    input logic SYS_HRESETn,
    input logic FT1248MODE,
    input logic FT_ADP_RXD_TVALID, FT_ADP_TXD_TVALID,
    input logic EXT_ADP_RXD_TVALID, EXT_ADP_TXD_TVALID,
    input logic EXT_DAT_RXD_TVALID, EXT_DAT_TXD_TVALID,
    input logic USRT0_TXD_TVALID, USRT1_TXD_TVALID,
    input logic FT_CLK_O
);
    logic mode_q, ftclk_q;
    always @(posedge SYS_HCLK) begin mode_q <= FT1248MODE; ftclk_q <= FT_CLK_O; end
    covergroup cg_dbgpath;
        option.per_instance = 1;
        cp_mode : coverpoint FT1248MODE { bins extio_hostio4 = {1'b0}; bins ft1248 = {1'b1}; }
        // RXD (towards the ADP controller) is the mode-gated direction; the TXD
        // valids are raw transport outputs that the mux simply ignores.
        cp_adp_traffic : coverpoint {FT1248MODE, FT_ADP_RXD_TVALID, EXT_ADP_RXD_TVALID} {
            bins extio_adp = {3'b001}; bins ft_adp = {3'b110};
            bins viol_wrong_path = {3'b010, 3'b101, 3'b011, 3'b111};
        }
        cp_data_stream : coverpoint {FT1248MODE, EXT_DAT_RXD_TVALID || EXT_DAT_TXD_TVALID,
                                     USRT0_TXD_TVALID || USRT1_TXD_TVALID} {
            wildcard bins extio_data = {3'b01?};
            bins ft_usrt_loopback = {3'b101};
        }
        cp_ftclk : coverpoint (FT_CLK_O != ftclk_q) iff (FT1248MODE) { bins ft_clock_toggling = {1'b1}; }
        cp_mode_change : coverpoint (FT1248MODE != mode_q) { bins strap_changed_at_runtime = {1'b1}; }
    endgroup
    cg_dbgpath cg = new;
    always @(posedge SYS_HCLK) if (SYS_HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_pins_cov (
    input logic        clk_i,
    input logic        nrst_i,
    input logic        test_i,
    input logic [15:0] p0_i, p0_o, p0_e,
    input logic [15:0] p1_i, p1_o, p1_e,
    input logic        swdclk_i,
    input logic        swdio_e
);
    // 0 drive0, 1 drive1, 2 input0, 3 input1, 4 contention
    function automatic logic [2:0] pin_mode(input logic e, input logic o, input logic i);
        if (e && (i !== o)) return 3'd4;
        if (e) return o ? 3'd1 : 3'd0;
        return i ? 3'd3 : 3'd2;
    endfunction
    covergroup cg_pin with function sample(int pin, logic [2:0] m);
        option.per_instance = 1;
        cp_pin  : coverpoint pin { bins p0[] = {[0:15]}; bins p1[] = {[16:31]}; }
        cp_mode : coverpoint m {
            bins drive0 = {0}; bins drive1 = {1}; bins input0 = {2}; bins input1 = {3};
            bins contention = {4};
        }
        x_pin_mode : cross cp_pin, cp_mode;
    endgroup
    logic swd_q;
    always @(posedge clk_i) swd_q <= swdclk_i;
    covergroup cg_misc;
        option.per_instance = 1;
        cp_test : coverpoint test_i { bins functional = {0}; bins test_mode = {1}; }
        cp_swdclk : coverpoint (swdclk_i != swd_q) { bins swd_clock_activity = {1'b1}; }
        cp_swdio_drive : coverpoint swdio_e { bins target_drives_swdio = {1'b1}; }
    endgroup
    cg_pin  cgp = new;
    cg_misc cgm = new;
    logic [2:0] m0_q [16], m1_q [16];
    always @(posedge clk_i) if (nrst_i) begin
        cgm.sample();
        for (int b = 0; b < 16; b++) begin
            logic [2:0] a, c;
            a = pin_mode(p0_e[b], p0_o[b], p0_i[b]);
            c = pin_mode(p1_e[b], p1_o[b], p1_i[b]);
            if (a != m0_q[b]) cgp.sample(b, a);        // sample on change only
            if (c != m1_q[b]) cgp.sample(16 + b, c);
            m0_q[b] <= a; m1_q[b] <= c;
        end
    end
    initial for (int b = 0; b < 16; b++) begin m0_q[b] = 3'd7; m1_q[b] = 3'd7; end
endmodule

// -----------------------------------------------------------------------------
module nsc_pinmux_cov (
    input logic        SYS_HCLK,
    input logic        SYS_HRESETn,
    input logic        FT1248MODE,
    input logic [15:0] SYS_P1_ALTFUNC,
    input logic [15:0] P1_OUTEN,
    input logic [15:0] SYS_P1_OUT_EN_MUX
);
    covergroup cg_pinmux;
        option.per_instance = 1;
        cp_alt1 : coverpoint SYS_P1_ALTFUNC[1] { bins uart0_txd_alt = {1'b1}; }   // uart0 tx tied 1 (F13)
        cp_alt3 : coverpoint SYS_P1_ALTFUNC[3] { bins uart1_txd_alt = {1'b1}; }   // uart1 tx tied 1 (F13)
        cp_alt5 : coverpoint SYS_P1_ALTFUNC[5] { bins uart2_txd_alt = {1'b1}; }
        cp_mode : coverpoint FT1248MODE { bins extio = {0}; bins ft1248 = {1}; }
        x_alt5_mode : cross cp_alt5, cp_mode;   // in EXTIO mode the UART2 alt pin is overridden by hostio
        cp_gpio_owned_hi : coverpoint (|SYS_P1_OUT_EN_MUX[15:8]) { bins gpio1_drives_p1_hi = {1'b1}; }
        cp_gpio_owned_4_6 : coverpoint {FT1248MODE, |SYS_P1_OUT_EN_MUX[6:4]} {
            bins gpio_ft_mode = {2'b11};
            bins gpio_masked_by_hostio = {2'b01};  // GPIO enables P1[4:6] but hostio owns the pins
        }
        cp_p1_oe_low : coverpoint P1_OUTEN[7:0] { bins all_inputs = {8'h00}; bins some_outputs = {[1:255]}; }
    endgroup
    cg_pinmux cg = new;
    always @(posedge SYS_HCLK) if (SYS_HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_dma_cov (
    input logic       SYS_HCLK,
    input logic       SYS_HRESETn,
    input logic [1:0] DMAC_0_HTRANS,
    input logic [1:0] DMAC_1_HTRANS,
    input logic [3:0] DMAC_0_DMA_REQ,
    input logic       DMAC_0_PSEL,
    input logic       DMAC_1_PSEL
);
    covergroup cg_dma;
        option.per_instance = 1;
        cp_dmac0_master : coverpoint DMAC_0_HTRANS[1] { bins dmac0_transfer = {1'b1}; }
        cp_dmac1_master : coverpoint DMAC_1_HTRANS[1] { bins dmac1_transfer = {1'b1}; }
        cp_req : coverpoint DMAC_0_DMA_REQ {
            wildcard bins exp_drq0 = {4'b???1}; wildcard bins exp_drq1 = {4'b??1?};
            wildcard bins extio_rx_req = {4'b?1??}; wildcard bins extio_tx_req = {4'b1???};
        }
        cp_cfg_access : coverpoint {DMAC_0_PSEL, DMAC_1_PSEL} {
            bins dmac0_config_access = {2'b10}; bins dmac1_config_access = {2'b01};
        }
    endgroup
    cg_dma cg = new;
    always @(posedge SYS_HCLK) if (SYS_HRESETn) cg.sample();
endmodule
