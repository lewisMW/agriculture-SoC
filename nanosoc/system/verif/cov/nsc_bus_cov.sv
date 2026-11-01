`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_bus_cov.sv — nanosoc bus matrix coverage (batch 2).
//
//   nsc_ahb_port_cov   one per MASTER port of nanosoc_busmatrix (DEBUG,
//                      DMAC_0, DMAC_1, CPU_0): decoded region x direction x
//                      size, error responses per region, wait states,
//                      back-to-back / BUSY / bursts / locked, REMAP at
//                      0x0000_0000, unaligned (viol), master behaviour after
//                      an ERROR.
//   nsc_bus_cov        bound into nanosoc_busmatrix; instantiates the four
//                      port models and adds cross-master concurrency (debugger
//                      active while the CPU / a DMA is), REMAP transitions.
//   nsc_slave_port_cov bound into every nanosoc_target_output_<SLAVE>: which
//                      master owns each transfer (= every master->slave path),
//                      arbitration contention and held (stalled) requests,
//                      sub-word accesses per slave.
//
// Address map (CPU_0 / DEBUG decoders, nanosoc_matrix_decode_*):
//   0x0000_0000-0x0FFF_FFFF  BOOTROM (REMAP[0]=0) / IMEM (REMAP[0]=1)
//   0x1000_0000-0x1FFF_FFFF  BOOTROM_0          0x2000_0000-0x2FFF_FFFF IMEM_0
//   0x3000_0000-0x3FFF_FFFF  DMEM_0             0x4000_0000-0x5FFF_FFFF SYSIO
//   0x6000_0000-0x7FFF_FFFF  EXP (+ 0xA000_0000-0xDFFF_FFFF mirror)
//   0x8000_0000-0x8FFF_FFFF  EXPRAM_L           0x9000_0000-0x9FFF_FFFF EXPRAM_H
//   0xF000_0000-0xF003_FFFF  SYSTABLE           everything else: default slave
// DMAC decoders differ (no REMAP, 0x0 -> IMEM, no SYSTABLE); no DMA is
// configured for tape-out (finding F14) so the DMA ports are expected idle.
// -----------------------------------------------------------------------------
module nsc_ahb_port_cov #(
    parameter int MASTER_ID = 0     // 0 DEBUG, 1 DMAC_0, 2 DMAC_1, 3 CPU_0
)(
    input logic        HCLK,
    input logic        HRESETn,
    input logic        REMAP0,
    input logic [31:0] HADDR,
    input logic [1:0]  HTRANS,
    input logic        HWRITE,
    input logic [2:0]  HSIZE,
    input logic [2:0]  HBURST,
    input logic [3:0]  HPROT,
    input logic        HMASTLOCK,
    input logic        HREADY,      // layer ready (address phase accepted)
    input logic        HREADYOUT,   // to the master
    input logic        HRESP        // to the master (OKAY/ERROR)
);
    typedef enum logic [4:0] {
        RG_ZERO, RG_BOOTROM, RG_IMEM, RG_DMEM, RG_APBSS, RG_GPIO0, RG_GPIO1,
        RG_SYSCTRL, RG_SYSIO_DEF, RG_EXP_ACC, RG_EXP_ALIAS, RG_EXPRAM_L,
        RG_EXPRAM_H, RG_EXP_MIRROR, RG_PPB, RG_SYSTABLE, RG_UNMAPPED
    } region_e;

    function automatic region_e region(input logic [31:0] a);
        if (a < 32'h1000_0000)                         return RG_ZERO;
        if (a < 32'h2000_0000)                         return RG_BOOTROM;
        if (a < 32'h3000_0000)                         return RG_IMEM;
        if (a < 32'h4000_0000)                         return RG_DMEM;
        if (a < 32'h4001_0000)                         return RG_APBSS;
        if (a[31:12] == 20'h40010)                     return RG_GPIO0;
        if (a[31:12] == 20'h40011)                     return RG_GPIO1;
        if (a[31:12] == 20'h4001F)                     return RG_SYSCTRL;
        if (a < 32'h6000_0000)                         return RG_SYSIO_DEF;
        if (a < 32'h6001_0000)                         return RG_EXP_ACC;
        if (a < 32'h8000_0000)                         return RG_EXP_ALIAS;
        if (a < 32'h9000_0000)                         return RG_EXPRAM_L;
        if (a < 32'hA000_0000)                         return RG_EXPRAM_H;
        if (a < 32'hE000_0000)                         return RG_EXP_MIRROR;
        if (a < 32'hF000_0000)                         return RG_PPB;
        if (a < 32'hF004_0000)                         return RG_SYSTABLE;
        return RG_UNMAPPED;
    endfunction

    wire     addr_ph = HTRANS[1] && HREADY;
    region_e rg;
    assign   rg = region(HADDR);

    // data phase tracking
    logic        dp_valid, dp_write, dp_err_seen;
    region_e     dp_rg;
    int unsigned waits;
    logic        err_q;      // previous data phase ended in ERROR
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            dp_valid <= 1'b0; dp_write <= 1'b0; dp_rg <= RG_ZERO; waits <= 0;
            err_q <= 1'b0; dp_err_seen <= 1'b0;
        end else begin
            if (HREADY) begin
                dp_valid <= addr_ph; dp_write <= HWRITE; dp_rg <= rg; waits <= 0;
                dp_err_seen <= 1'b0;
                if (dp_valid) err_q <= HRESP;
            end else if (dp_valid) begin
                waits <= waits + 1;
                if (HRESP) dp_err_seen <= 1'b1;
            end
        end
    end
    wire dp_done = dp_valid && HREADY;
    wire dp_err  = dp_done && HRESP;

    logic prev_wr_done, prev_valid;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) begin prev_wr_done <= 1'b0; prev_valid <= 1'b0; end
        else if (dp_done) begin prev_wr_done <= dp_write; prev_valid <= 1'b1; end

    wire unaligned = (HSIZE == 3'd1 && HADDR[0]) || (HSIZE == 3'd2 && |HADDR[1:0]);

    // The Verilator coverage database merges all instances of a covergroup type in coverage.dat, so
    // the master is a coverpoint and every interesting point is crossed with it.
    wire [1:0] mid = MASTER_ID[1:0];

    covergroup cg_port;
        option.per_instance = 1;
        cp_master : coverpoint mid {
            bins debug = {2'd0}; bins dmac_0 = {2'd1}; bins dmac_1 = {2'd2}; bins cpu_0 = {2'd3};
        }
        cp_region : coverpoint rg iff (addr_ph) {
            bins zero_page = {RG_ZERO};       bins bootrom   = {RG_BOOTROM};
            bins imem      = {RG_IMEM};       bins dmem      = {RG_DMEM};
            bins apb_ss    = {RG_APBSS};      bins gpio0     = {RG_GPIO0};
            bins gpio1     = {RG_GPIO1};      bins sysctrl   = {RG_SYSCTRL};
            bins sysio_default = {RG_SYSIO_DEF};
            bins exp_sensing   = {RG_EXP_ACC};
            bins exp_alias_64k = {RG_EXP_ALIAS};
            bins expram_l  = {RG_EXPRAM_L};   bins expram_h  = {RG_EXPRAM_H};
            bins exp_mirror_a_d = {RG_EXP_MIRROR};
            bins ppb_0xe   = {RG_PPB};        bins systable  = {RG_SYSTABLE};
            bins unmapped_0xf = {RG_UNMAPPED};
        }
        cp_dir  : coverpoint HWRITE iff (addr_ph) { bins read = {0}; bins write = {1}; }
        cp_size : coverpoint HSIZE iff (addr_ph) {
            bins byte_ = {3'd0}; bins half = {3'd1}; bins word = {3'd2};
            bins viol_wider_than_bus = {[3'd3:3'd7]};
        }
        x_master_region_dir  : cross cp_master, cp_region, cp_dir;
        x_master_region_size : cross cp_master, cp_region, cp_size;
        cp_trans : coverpoint HTRANS {
            bins idle = {2'b00}; bins busy = {2'b01}; bins nonseq = {2'b10}; bins seq = {2'b11};
        }
        cp_burst : coverpoint HBURST iff (addr_ph) {
            bins single = {3'd0}; bins incr = {3'd1}; bins fixed_len = {[3'd2:3'd7]};
        }
        cp_prot : coverpoint {HPROT[1], HPROT[0]} iff (addr_ph) {
            bins user_opcode = {2'b00}; bins user_data = {2'b01};
            bins priv_opcode = {2'b10}; bins priv_data = {2'b11};
        }
        cp_lock : coverpoint HMASTLOCK iff (addr_ph) { bins locked = {1'b1}; }
        x_master_trans : cross cp_master, cp_trans;
        x_master_prot  : cross cp_master, cp_prot;
        cp_remap_zero : coverpoint REMAP0 iff (addr_ph && rg == RG_ZERO) {
            bins zero_is_bootrom = {1'b0};
            bins zero_is_imem    = {1'b1};
        }
        x_master_remap_zero : cross cp_master, cp_remap_zero;
        // Responses (data phase)
        cp_resp_region : coverpoint dp_rg iff (dp_done) {
            bins zero_page = {RG_ZERO};       bins bootrom   = {RG_BOOTROM};
            bins imem      = {RG_IMEM};       bins dmem      = {RG_DMEM};
            bins apb_ss    = {RG_APBSS};      bins gpio0     = {RG_GPIO0};
            bins gpio1     = {RG_GPIO1};      bins sysctrl   = {RG_SYSCTRL};
            bins sysio_default = {RG_SYSIO_DEF};
            bins exp_sensing   = {RG_EXP_ACC};
            bins exp_alias_64k = {RG_EXP_ALIAS};
            bins expram_l  = {RG_EXPRAM_L};   bins expram_h  = {RG_EXPRAM_H};
            bins exp_mirror_a_d = {RG_EXP_MIRROR};
            bins ppb_0xe   = {RG_PPB};        bins systable  = {RG_SYSTABLE};
            bins unmapped_0xf = {RG_UNMAPPED};
        }
        cp_resp : coverpoint HRESP iff (dp_done) { bins okay = {1'b0}; bins error = {1'b1}; }
        x_master_region_resp : cross cp_master, cp_resp_region, cp_resp;
        cp_wait : coverpoint waits iff (dp_done) {
            bins zero = {0}; bins one = {1}; bins two_three = {[2:3]};
            bins four_15 = {[4:15]}; bins sixteen_plus = {[16:$]};
        }
        x_master_wait : cross cp_master, cp_wait;
        cp_b2b : coverpoint {dp_done, addr_ph} {
            bins pipelined_back_to_back = {2'b11};
        }
        x_master_b2b : cross cp_master, cp_b2b;
        cp_after_error : coverpoint addr_ph iff (HREADY && err_q) {
            bins idle_after_error = {1'b0};
            bins next_transfer_after_error = {1'b1};
        }
        x_master_after_error : cross cp_master, cp_after_error;
        cp_turnaround : coverpoint {prev_wr_done, HWRITE} iff (addr_ph && prev_valid) {
            bins wr_then_rd = {2'b10}; bins rd_then_wr = {2'b01};
            bins wr_then_wr = {2'b11}; bins rd_then_rd = {2'b00};
        }
        x_master_turnaround : cross cp_master, cp_turnaround;
        cp_unaligned : coverpoint unaligned iff (addr_ph) {
            bins aligned = {1'b0}; bins viol_unaligned = {1'b1};
        }
    endgroup

    cg_port cg = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_bus_cov (
    input logic        HCLK,
    input logic        HRESETn,
    input logic [3:0]  REMAP,
    // DEBUG
    input logic [31:0] HADDR_DEBUG,  input logic [1:0] HTRANS_DEBUG, input logic HWRITE_DEBUG,
    input logic [2:0]  HSIZE_DEBUG,  input logic [2:0] HBURST_DEBUG, input logic [3:0] HPROT_DEBUG,
    input logic        HMASTLOCK_DEBUG, input logic HREADY_DEBUG, input logic HREADYOUT_DEBUG,
    input logic [1:0]  HRESP_DEBUG,
    // DMAC_0
    input logic [31:0] HADDR_DMAC_0, input logic [1:0] HTRANS_DMAC_0, input logic HWRITE_DMAC_0,
    input logic [2:0]  HSIZE_DMAC_0, input logic [2:0] HBURST_DMAC_0, input logic [3:0] HPROT_DMAC_0,
    input logic        HMASTLOCK_DMAC_0, input logic HREADY_DMAC_0, input logic HREADYOUT_DMAC_0,
    input logic [1:0]  HRESP_DMAC_0,
    // DMAC_1
    input logic [31:0] HADDR_DMAC_1, input logic [1:0] HTRANS_DMAC_1, input logic HWRITE_DMAC_1,
    input logic [2:0]  HSIZE_DMAC_1, input logic [2:0] HBURST_DMAC_1, input logic [3:0] HPROT_DMAC_1,
    input logic        HMASTLOCK_DMAC_1, input logic HREADY_DMAC_1, input logic HREADYOUT_DMAC_1,
    input logic [1:0]  HRESP_DMAC_1,
    // CPU_0
    input logic [31:0] HADDR_CPU_0,  input logic [1:0] HTRANS_CPU_0, input logic HWRITE_CPU_0,
    input logic [2:0]  HSIZE_CPU_0,  input logic [2:0] HBURST_CPU_0, input logic [3:0] HPROT_CPU_0,
    input logic        HMASTLOCK_CPU_0, input logic HREADY_CPU_0, input logic HREADYOUT_CPU_0,
    input logic [1:0]  HRESP_CPU_0
);
    nsc_ahb_port_cov #(.MASTER_ID(0)) u_debug (
        .HCLK(HCLK), .HRESETn(HRESETn), .REMAP0(REMAP[0]),
        .HADDR(HADDR_DEBUG), .HTRANS(HTRANS_DEBUG), .HWRITE(HWRITE_DEBUG), .HSIZE(HSIZE_DEBUG),
        .HBURST(HBURST_DEBUG), .HPROT(HPROT_DEBUG), .HMASTLOCK(HMASTLOCK_DEBUG),
        .HREADY(HREADY_DEBUG), .HREADYOUT(HREADYOUT_DEBUG), .HRESP(HRESP_DEBUG[0]));
    nsc_ahb_port_cov #(.MASTER_ID(1)) u_dmac_0 (
        .HCLK(HCLK), .HRESETn(HRESETn), .REMAP0(REMAP[0]),
        .HADDR(HADDR_DMAC_0), .HTRANS(HTRANS_DMAC_0), .HWRITE(HWRITE_DMAC_0), .HSIZE(HSIZE_DMAC_0),
        .HBURST(HBURST_DMAC_0), .HPROT(HPROT_DMAC_0), .HMASTLOCK(HMASTLOCK_DMAC_0),
        .HREADY(HREADY_DMAC_0), .HREADYOUT(HREADYOUT_DMAC_0), .HRESP(HRESP_DMAC_0[0]));
    nsc_ahb_port_cov #(.MASTER_ID(2)) u_dmac_1 (
        .HCLK(HCLK), .HRESETn(HRESETn), .REMAP0(REMAP[0]),
        .HADDR(HADDR_DMAC_1), .HTRANS(HTRANS_DMAC_1), .HWRITE(HWRITE_DMAC_1), .HSIZE(HSIZE_DMAC_1),
        .HBURST(HBURST_DMAC_1), .HPROT(HPROT_DMAC_1), .HMASTLOCK(HMASTLOCK_DMAC_1),
        .HREADY(HREADY_DMAC_1), .HREADYOUT(HREADYOUT_DMAC_1), .HRESP(HRESP_DMAC_1[0]));
    nsc_ahb_port_cov #(.MASTER_ID(3)) u_cpu_0 (
        .HCLK(HCLK), .HRESETn(HRESETn), .REMAP0(REMAP[0]),
        .HADDR(HADDR_CPU_0), .HTRANS(HTRANS_CPU_0), .HWRITE(HWRITE_CPU_0), .HSIZE(HSIZE_CPU_0),
        .HBURST(HBURST_CPU_0), .HPROT(HPROT_CPU_0), .HMASTLOCK(HMASTLOCK_CPU_0),
        .HREADY(HREADY_CPU_0), .HREADYOUT(HREADYOUT_CPU_0), .HRESP(HRESP_CPU_0[0]));

    // ---------------- cross-master concurrency ------------------------------
    // "active" = master has a transfer in address or data phase this cycle
    logic dbg_dp, dma0_dp, dma1_dp, cpu_dp;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) {dbg_dp, dma0_dp, dma1_dp, cpu_dp} <= '0;
        else begin
            if (HREADY_DEBUG) dbg_dp  <= HTRANS_DEBUG[1];
            if (HREADY_DMAC_0) dma0_dp <= HTRANS_DMAC_0[1];
            if (HREADY_DMAC_1) dma1_dp <= HTRANS_DMAC_1[1];
            if (HREADY_CPU_0) cpu_dp  <= HTRANS_CPU_0[1];
        end
    wire dbg_act  = HTRANS_DEBUG[1]  || dbg_dp;
    wire dma_act  = HTRANS_DMAC_0[1] || dma0_dp || HTRANS_DMAC_1[1] || dma1_dp;
    wire cpu_act  = HTRANS_CPU_0[1]  || cpu_dp;

    logic remap_q;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) remap_q <= REMAP[0]; else remap_q <= REMAP[0];

    covergroup cg_matrix;
        option.per_instance = 1;
        cp_concurrency : coverpoint {dbg_act, dma_act, cpu_act} {
            bins cpu_only        = {3'b001};
            bins debug_only      = {3'b100};
            bins dma_only        = {3'b010};
            bins debug_with_cpu  = {3'b101};
            bins debug_with_dma  = {3'b110};   // unreachable: no DMA configured (F14)
            bins dma_with_cpu    = {3'b011};   // unreachable: no DMA configured (F14)
            bins all_three       = {3'b111};   // unreachable: no DMA configured (F14)
        }
        cp_remap_edge : coverpoint {remap_q, REMAP[0]} {
            bins bootrom_to_imem = {2'b01};
            bins imem_to_bootrom = {2'b10};    // only via reset (sysctrl REMAP reset value)
        }
        cp_remap_ctrl_hi : coverpoint REMAP[3:1] { bins tied_zero = {3'b000}; bins viol_nonzero = {[1:7]}; }
    endgroup

    cg_matrix cg = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_slave_port_cov #(
    parameter int SLAVE_ID = 0   // 0 BOOTROM_0 1 IMEM_0 2 DMEM_0 3 SYSIO 4 EXPRAM_L 5 EXPRAM_H 6 EXP 7 SYSTABLE
)(
    input logic        HCLK,
    input logic        HRESETn,
    input logic        sel_op0, sel_op1, sel_op2, sel_op3,
    input logic [1:0]  trans_op0, trans_op1, trans_op2, trans_op3,
    input logic        held_tran_op0, held_tran_op1, held_tran_op2, held_tran_op3,
    input logic        active_op0, active_op1, active_op2, active_op3,
    input logic        HSELM,
    input logic [1:0]  HTRANSM,
    input logic        HWRITEM,
    input logic [2:0]  HSIZEM,
    input logic        HREADYMUXM
);
    wire issue = HSELM && HTRANSM[1] && HREADYMUXM;   // transfer issued to the slave
    wire [3:0] req  = {sel_op3 && trans_op3[1], sel_op2 && trans_op2[1],
                       sel_op1 && trans_op1[1], sel_op0 && trans_op0[1]};
    // held_tran_opN comes from master N's input stage and is broadcast to every
    // slave stage, so it only means "held for THIS slave" together with sel_opN.
    wire [3:0] held = {held_tran_op3 && sel_op3, held_tran_op2 && sel_op2,
                       held_tran_op1 && sel_op1, held_tran_op0 && sel_op0};
    wire [3:0] act  = {active_op3, active_op2, active_op1, active_op0};

    wire [2:0] sid = SLAVE_ID[2:0];

    covergroup cg_slave;
        option.per_instance = 1;
        cp_slave : coverpoint sid {
            bins bootrom_0 = {3'd0}; bins imem_0 = {3'd1}; bins dmem_0 = {3'd2}; bins sysio = {3'd3};
            bins expram_l = {3'd4}; bins expram_h = {3'd5}; bins exp = {3'd6}; bins systable = {3'd7};
        }
        // every master -> this slave path (port 0 DEBUG, 1 DMAC_0, 2 DMAC_1, 3 CPU_0)
        cp_path : coverpoint act iff (issue) {
            bins from_debug  = {4'b0001};
            bins from_dmac_0 = {4'b0010};
            bins from_dmac_1 = {4'b0100};
            bins from_cpu_0  = {4'b1000};
            bins viol_multiple_owners = {4'b0011, 4'b0101, 4'b0110, 4'b0111, 4'b1001, 4'b1010,
                                         4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        }
        cp_dir  : coverpoint HWRITEM iff (issue) { bins read = {0}; bins write = {1}; }
        x_slave_path     : cross cp_slave, cp_path;
        x_slave_path_dir : cross cp_slave, cp_path, cp_dir;
        cp_size : coverpoint HSIZEM iff (issue) { bins byte_ = {0}; bins half = {1}; bins word = {2}; }
        x_slave_path_size : cross cp_slave, cp_path, cp_size;
        // arbitration: two or more masters requesting this slave in one cycle
        cp_contention : coverpoint req {
            bins debug_and_cpu  = {4'b1001};
            bins debug_and_dma  = {4'b0011, 4'b0101, 4'b0111};
            bins cpu_and_dma    = {4'b1010, 4'b1100, 4'b1110};
            bins three_or_more  = {4'b1011, 4'b1101, 4'b1111};
        }
        x_slave_contention : cross cp_slave, cp_contention;
        cp_held : coverpoint held {
            bins debug_waited = {4'b0001};
            bins dmac_waited  = {4'b0010, 4'b0100};
            bins cpu_waited   = {4'b1000};
            bins several_waiting = {4'b0011, 4'b0101, 4'b0110, 4'b0111, 4'b1001, 4'b1010,
                                    4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        }
        x_slave_held : cross cp_slave, cp_held;
    endgroup

    cg_slave cg = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
endmodule
