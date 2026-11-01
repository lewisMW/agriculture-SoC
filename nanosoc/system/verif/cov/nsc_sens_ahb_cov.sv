`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_sens_ahb_cov.sv — the sensing peripheral as the SYSTEM sees it.
//
// Bound into accelerator_subsystem (nanosoc expansion region, base 0x6000_0000).
// Covers the AHB side of the cmsdk_ahb_to_apb bridge, which no block-level
// bench can see:
//   cp_size x cp_dir     byte / half / word reads and writes (PSTRB ignored, F6)
//   cp_window            canonical 0x6000_xxxx vs 64 KB aliases (0x6001..0x7FFF)
//                        vs the 0xA000..0xDFFF mirror (F5)
//   cp_offset            register / RTC / reserved offsets as issued on AHB
//   cp_wait              AHB wait states per transfer (bridge baseline vs RTC
//                        passthrough stall); viol_ above 64
//   cp_hresp             AHB ERROR from the peripheral (must never happen)
//   cp_b2b               transfer accepted in the cycle the previous completed
//   cp_hprot             user/privileged, data vs instruction fetch
//   cp_reset_busy        HRESETn asserted while a transfer is stalled
//   cp_clk1hz            CLK1HZ generated (divider alive, CLAUDE.md failure point)
//   cp_irq               EXP_IRQ lines (all tied 0 today — F3)
// -----------------------------------------------------------------------------
module nsc_sens_ahb_cov (
    input logic        HCLK,
    input logic        HRESETn,
    input logic        HSEL,
    input logic [31:0] HADDR,
    input logic [1:0]  HTRANS,
    input logic [2:0]  HSIZE,
    input logic [3:0]  HPROT,
    input logic        HWRITE,
    input logic        HREADY,
    input logic        HREADYOUT,
    input logic        HRESP,
    input logic        clk1hz,
    input logic [3:0]  EXP_IRQ
);
    wire addr_phase = HSEL && HTRANS[1] && HREADY;

    // data-phase bookkeeping
    logic        dp_valid;
    int unsigned waits;
    logic        resp_q;
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin dp_valid <= 1'b0; waits <= 0; resp_q <= 1'b0; end
        else begin
            resp_q <= HRESP;
            if (HREADY) begin dp_valid <= addr_phase; waits <= 0; end
            else if (dp_valid) waits <= waits + 1;
        end
    end
    wire dp_done = dp_valid && HREADY;           // data phase completes this cycle

    // CLK1HZ edges
    logic c1_q; int unsigned c1_edges;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) begin c1_q <= 1'b0; c1_edges <= 0; end
        else begin c1_q <= clk1hz; if (clk1hz && !c1_q && c1_edges < 100) c1_edges <= c1_edges + 1; end

    wire [15:0] off16 = HADDR[15:0];

    covergroup cg_sens_ahb;
        option.per_instance = 1;
        cp_size : coverpoint HSIZE iff (addr_phase) {
            bins byte_ = {3'd0}; bins half = {3'd1}; bins word = {3'd2};
            bins viol_wider = {[3'd3:3'd7]};
        }
        cp_dir : coverpoint HWRITE iff (addr_phase) { bins read = {0}; bins write = {1}; }
        x_size_dir : cross cp_size, cp_dir;
        cp_lane : coverpoint HADDR[1:0] iff (addr_phase && HSIZE != 3'd2) {
            bins lane[] = {[0:3]};
        }
        cp_window : coverpoint HADDR[31:16] iff (addr_phase) {
            bins canonical = {16'h6000};
            bins alias_6   = {[16'h6001:16'h7FFF]};
            bins mirror_ad = {[16'hA000:16'hDFFF]};
            bins other     = default;              // should be impossible (decode)
        }
        x_window_dir : cross cp_window, cp_dir;
        cp_offset : coverpoint off16 iff (addr_phase) {
            bins status    = {16'h0004}; bins meas_hi = {16'h0008}; bins meas_lo = {16'h000C};
            bins pll       = {16'h0100}; bins amux    = {16'h0104}; bins trig    = {16'h0108};
            bins cal       = {16'h010C}; bins rtc     = {[16'h0200:16'h021F]};
            bins fclr      = {16'h0220}; bins alarm   = {16'h0224}; bins rtcctrl = {16'h0228};
            bins rtc_alias = {16'h1200, 16'h2200, 16'h3200, 16'h4200, 16'h5200, 16'h6200,
                              16'h7200, 16'h8200, 16'h9200, 16'hA200, 16'hB200, 16'hC200,
                              16'hD200, 16'hE200, 16'hF200};
            bins reserved  = default;
        }
        x_offset_dir : cross cp_offset, cp_dir;
        cp_wait : coverpoint waits iff (dp_done) {
            bins zero = {0}; bins bridge = {[1:3]}; bins rtc_stall = {[4:16]};
            bins long_stall = {[17:64]}; bins viol_excessive = {[65:$]};
        }
        cp_hresp : coverpoint HRESP iff (dp_valid) { bins okay = {0}; bins viol_error = {1}; }
        cp_b2b : coverpoint (dp_done && addr_phase) { bins back_to_back = {1'b1}; }
        cp_hprot : coverpoint {HPROT[1], HPROT[0]} iff (addr_phase) {
            bins user_data = {2'b01}; bins priv_data = {2'b11};
            bins opcode_fetch = {2'b00, 2'b10};   // executing from the peripheral
        }
        cp_clk1hz : coverpoint c1_edges {
            bins dead = {0}; bins alive = {[1:9]}; bins running = {[10:$]};
        }
        cp_irq : coverpoint EXP_IRQ {
            bins irq0 = {4'b0001}; bins irq1 = {4'b0010}; bins irq2 = {4'b0100}; bins irq3 = {4'b1000};
        }
    endgroup

    // snapshot without reset so the negedge-HRESETn sample sees pre-reset state
    logic dpv_snap, hro_snap;
    always @(posedge HCLK) begin dpv_snap <= dp_valid && !HREADY; hro_snap <= HREADYOUT; end

    covergroup cg_sens_ahb_rst;
        option.per_instance = 1;
        cp_reset_busy : coverpoint {dpv_snap, hro_snap} {
            bins idle                 = {2'b00, 2'b01};
            bins mid_stalled_transfer = {2'b10, 2'b11};  // reset while the peripheral holds HREADY low
        }
    endgroup

    cg_sens_ahb     cg     = new;
    cg_sens_ahb_rst cg_rst = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
    always @(negedge HRESETn) cg_rst.sample();
endmodule
