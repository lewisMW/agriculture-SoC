//-----------------------------------------------------------------------------
// DMA350 wrapper - Contains DMA Controllers with AXI interface
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access l
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sldma350_axi #(
    parameter   SYS_ADDR_W = 32,
    parameter   SYS_DATA_W = 128
)(
    input   wire                    SYS_HCLK,
    input   wire                    SYS_HRESETn,
    input   wire                    DMAC_PCLKen,
    input   wire                    DMAC_ACLKen,

    // Q Channel Signals
    input   wire                    DMAC_CLK_QREQN,
    output  wire                    DMAC_CLK_QACCEPTN,
    output  wire                    DMAC_CLK_QDENY,
    output  wire                    DMAC_CLK_QACTIVE,

    // P Channel Signals
    input  wire                     DMAC_PREQ,
    input  wire  [3:0]              DMAC_PSTATE,
    output wire                     DMAC_PACCEPT,
    output wire                     DMAC_PDENY,
    output wire [9:0]               DMAC_PACTIVE,
    input  wire                     DMAC_PWAKEUP,
    input  wire                     DMAC_PDEBUG,
    input  wire                     DMAC_PSEL,
    input  wire                     DMAC_PENABLE,
    input  wire  [2:0]              DMAC_PPROT,
    input  wire                     DMAC_PWRITE,
    input  wire  [12:0]             DMAC_PADDR,
    input  wire  [31:0]             DMAC_PWDATA,
    input  wire  [3:0]              DMAC_PSTRB,
    output wire                     DMAC_PREADY,
    output wire                     DMAC_PSLVERR,
    output wire [31:0]              DMAC_PRDATA,
    //  DMAC AXI Port
    output wire                     DMAC_AWAKEUP,
    output wire                     DMAC_AWVALID,
    output wire [SYS_ADDR_W-1:0]    DMAC_AWADDR,
    output wire [1:0]               DMAC_AWBURST,
    output wire [7:0]               DMAC_AWLEN,
    output wire [2:0]               DMAC_AWSIZE,
    output wire [3:0]               DMAC_AWQOS,
    output wire [2:0]               DMAC_AWPROT,
    input  wire                     DMAC_AWREADY,
    output wire [3:0]               DMAC_AWCACHE,
    output wire [3:0]               DMAC_AWINNER,
    output wire [1:0]               DMAC_AWDOMAIN,

    output wire                     DMAC_ARVALID,
    output wire [SYS_ADDR_W-1:0]    DMAC_ARADDR,
    output wire [1:0]               DMAC_ARBURST,
    output wire [7:0]               DMAC_ARLEN,
    output wire [2:0]               DMAC_ARSIZE,
    output wire [3:0]               DMAC_ARQOS,
    output wire [2:0]               DMAC_ARPROT,
    input  wire                     DMAC_ARREADY,
    output wire [3:0]               DMAC_ARCACHE,
    output wire [3:0]               DMAC_ARINNER,
    output wire [1:0]               DMAC_ARDOMAIN,
    output wire                     DMAC_ARCMDLINK,

    output wire                     DMAC_WVALID,
    output wire                     DMAC_WLAST,
    output wire [16-1:0]            DMAC_WSTRB,
    output wire [SYS_DATA_W-1:0]    DMAC_WDATA,
    input  wire                     DMAC_WREADY,

    input  wire                     DMAC_RVALID,
    input  wire                     DMAC_RLAST,
    input  wire  [SYS_DATA_W-1:0]   DMAC_RDATA,
    input  wire  [2-1:0]            DMAC_RPOISON,
    input  wire  [1:0]              DMAC_RRESP,
    output wire                     DMAC_RREADY,

    input  wire                     DMAC_BVALID,
    input  wire  [1:0]              DMAC_BRESP,
    output wire                     DMAC_BREADY,

    // Trigger 0 in
    input  wire                     DMAC_TRIG_IN_0_REQ,
    input  wire  [1:0]              DMAC_TRIG_IN_0_REQ_TYPE,
    output wire                     DMAC_TRIG_IN_0_ACK,
    output wire [1:0]               DMAC_TRIG_IN_0_ACK_TYPE,
    input  wire                     DMAC_TRIG_IN_1_REQ,
    input  wire  [1:0]              DMAC_TRIG_IN_1_REQ_TYPE,
    output wire                     DMAC_TRIG_IN_1_ACK,
    output wire [1:0]               DMAC_TRIG_IN_1_ACK_TYPE,
    output wire                     DMAC_TRIG_OUT_0_REQ,
    input  wire                     DMAC_TRIG_OUT_0_ACK,
    output wire                     DMAC_TRIG_OUT_1_REQ,
    input  wire                     DMAC_TRIG_OUT_1_ACK,
    output wire [2-1:0]             DMAC_IRQ_CHANNEL,
    output wire                     DMAC_IRQ_COMB_NONSEC,

    //  DMAC Channel 0 AXI stream out
    output wire                     DMAC_STR_OUT_0_TVALID,
    input  wire                     DMAC_STR_OUT_0_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_0_TDATA,
    output wire [16-1:0]            DMAC_STR_OUT_0_TSTRB,
    output wire                     DMAC_STR_OUT_0_TLAST,

    //  DMAC Channel 0 AXI Stream in
    input  wire                     DMAC_STR_IN_0_TVALID,
    output wire                     DMAC_STR_IN_0_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_0_TDATA,
    input  wire [16-1:0]            DMAC_STR_IN_0_TSTRB,
    input  wire                     DMAC_STR_IN_0_TLAST,
    output wire                     DMAC_STR_IN_0_FLUSH,

    //  DMAC Channel 1 AXI Stream out
    output wire                     DMAC_STR_OUT_1_TVALID,
    input  wire                     DMAC_STR_OUT_1_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_1_TDATA,
    output wire [16-1:0]            DMAC_STR_OUT_1_TSTRB,
    output wire                     DMAC_STR_OUT_1_TLAST,

    //  DMAC Channel 1 AXI Stream out
    input  wire                     DMAC_STR_IN_1_TVALID,
    output wire                     DMAC_STR_IN_1_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_1_TDATA,
    input  wire [16-1:0]            DMAC_STR_IN_1_TSTRB,
    input  wire                     DMAC_STR_IN_1_TLAST,
    output wire                     DMAC_STR_IN_1_FLUSH,

    input  wire                     DMAC_ALLCH_STOP_REQ_NONSEC,
    output wire                     DMAC_ALLCH_STOP_ACK_NONSEC,
    input  wire                     DMAC_ALLCH_PAUSE_REQ_NONSEC,
    output wire                     DMAC_ALLCH_PAUSE_ACK_NONSEC,
    output wire [2-1:0]             DMAC_CH_ENABLED,
    output wire [2-1:0]             DMAC_CH_ERR,
    output wire [2-1:0]             DMAC_CH_STOPPED,
    output wire [2-1:0]             DMAC_CH_PAUSED,
    output wire [2-1:0]             DMAC_CH_PRIV,

    input  wire                     DMAC_HALT_REQ,
    input  wire                     DMAC_RESTART_REQ,
    output wire                     DMAC_HALTED,

    input  wire                     DMAC_BOOT_EN,
    input  wire  [32-1:2]           DMAC_BOOT_ADDR,
    input  wire  [ 7:0]             DMAC_BOOT_MEMATTR,
    input  wire  [ 1:0]             DMAC_BOOT_SHAREATTR
);

// -------------------------------
// DMA Controller Instantiation
// -------------------------------
ada_top_sldma350 u_dmac_0(
    // Clock and Reset signals
    .clk(SYS_HCLK),
    .resetn(SYS_HRESETn),
    .aclken_m0(DMAC_ACLKen),
    .pclken(DMAC_PCLKen),
    // Q Channel signals
    .clk_qreqn(DMAC_CLK_QREQN),
    .clk_qacceptn(DMAC_CLK_QACCEPTN),
    .clk_qdeny(DMAC_CLK_QDENY),
    .clk_qactive(DMAC_CLK_QACTIVE),
    // P Channel Signals
    .preq(DMAC_PREQ),
    .pstate(DMAC_PSTATE),
    .paccept(DMAC_PACCEPT),
    .pdeny(DMAC_PDENY),
    .pactive(DMAC_PACTIVE),

    .pwakeup(DMAC_PWAKEUP),
    .pdebug(DMAC_PDEBUG),
    .psel(DMAC_PSEL),
    .penable(DMAC_PENABLE),
    .pprot(DMAC_PPROT),
    .pwrite(DMAC_PWRITE),
    .paddr(DMAC_PADDR),
    .pwdata(DMAC_PWDATA),
    .pstrb(DMAC_PSTRB),
    .pready(DMAC_PREADY),
    .pslverr(DMAC_PSLVERR),
    .prdata(DMAC_PRDATA),
    // AXI Write Channel Signals
    .awakeup_m0(DMAC_AWAKEUP),
    .awvalid_m0(DMAC_AWVALID),
    .awaddr_m0(DMAC_AWADDR),
    .awburst_m0(DMAC_AWBURST),
    .awid_m0(),
    .awlen_m0(DMAC_AWLEN),
    .awsize_m0(DMAC_AWSIZE),
    .awqos_m0(DMAC_AWQOS),
    .awprot_m0(DMAC_AWPROT),
    .awready_m0(DMAC_AWREADY),
    .awcache_m0(DMAC_AWCACHE),
    .awinner_m0(DMAC_AWINNER),
    .awdomain_m0(DMAC_AWDOMAIN),
    // AXI Read Channel Signals
    .arvalid_m0(DMAC_ARVALID),
    .araddr_m0(DMAC_ARADDR),
    .arburst_m0(DMAC_ARBURST),
    .arid_m0(),
    .arlen_m0(DMAC_ARLEN),
    .arsize_m0(DMAC_ARSIZE),
    .arqos_m0(DMAC_ARQOS),
    .arprot_m0(DMAC_ARPROT),
    .arready_m0(DMAC_ARREADY),
    .arcache_m0(DMAC_ARCACHE),
    .arinner_m0(DMAC_ARINNER),
    .ardomain_m0(DMAC_ARDOMAIN),
    .arcmdlink_m0(DMAC_ARCMDLINK),
    // AXI Write Data Signals
    .wvalid_m0(DMAC_WVALID),
    .wlast_m0(DMAC_WLAST),
    .wstrb_m0(DMAC_WSTRB),
    .wdata_m0(DMAC_WDATA),
    .wready_m0(DMAC_WREADY),
    // AXI Read Data Signals
    .rvalid_m0(DMAC_RVALID),
    .rid_m0(),
    .rlast_m0(DMAC_RLAST),
    .rdata_m0(DMAC_RDATA),
    .rpoison_m0(DMAC_RPOISON),
    .rresp_m0(DMAC_RRESP),
    .rready_m0(DMAC_RREADY),
    // AXI Write response signals
    .bvalid_m0(DMAC_BVALID),
    .bid_m0(),
    .bresp_m0(DMAC_BRESP),
    .bready_m0(DMAC_BREADY),
    // Trigger 0 in
    .trig_in_0_req(DMAC_TRIG_IN_0_REQ),
    .trig_in_0_req_type(DMAC_TRIG_IN_0_REQ_TYPE),
    .trig_in_0_ack(DMAC_TRIG_IN_0_ACK),
    .trig_in_0_ack_type(DMAC_TRIG_IN_0_ACK_TYPE),
    // Trigger 1 in
    .trig_in_1_req(DMAC_TRIG_IN_1_REQ),
    .trig_in_1_req_type(DMAC_TRIG_IN_1_REQ_TYPE),
    .trig_in_1_ack(DMAC_TRIG_IN_1_ACK),
    .trig_in_1_ack_type(DMAC_TRIG_IN_1_ACK_TYPE),
    // Trigger 0 out
    .trig_out_0_req(DMAC_TRIG_OUT_0_REQ),
    .trig_out_0_ack(DMAC_TRIG_OUT_0_ACK),
    // Trigger 1 out
    .trig_out_1_req(DMAC_TRIG_OUT_1_REQ),
    .trig_out_1_ack(DMAC_TRIG_OUT_1_ACK),
    // Interrupt Signals
    .irq_channel(DMAC_IRQ_CHANNEL),
    .irq_comb_nonsec(DMAC_IRQ_COMB_NONSEC),
    // AXI Stream 0 out
    .str_out_0_tvalid(DMAC_STR_OUT_0_TVALID),
    .str_out_0_tready(DMAC_STR_OUT_0_TREADY),
    .str_out_0_tdata(DMAC_STR_OUT_0_TDATA),
    .str_out_0_tstrb(DMAC_STR_OUT_0_TSTRB),
    .str_out_0_tlast(DMAC_STR_OUT_0_TLAST),
    // AXI Stream 0 In
    .str_in_0_tvalid(DMAC_STR_IN_0_TVALID),
    .str_in_0_tready(DMAC_STR_IN_0_TREADY),
    .str_in_0_tdata(DMAC_STR_IN_0_TDATA),
    .str_in_0_tstrb(DMAC_STR_IN_0_TSTRB),
    .str_in_0_tlast(DMAC_STR_IN_0_TLAST),
    .str_in_0_flush(DMAC_STR_IN_0_FLUSH),
    // AXI Stream 1 out
    .str_out_1_tvalid(DMAC_STR_OUT_1_TVALID),
    .str_out_1_tready(DMAC_STR_OUT_1_TREADY),
    .str_out_1_tdata(DMAC_STR_OUT_1_TDATA),
    .str_out_1_tstrb(DMAC_STR_OUT_1_TSTRB),
    .str_out_1_tlast(DMAC_STR_OUT_1_TLAST),
    // AXI Stream 1 in
    .str_in_1_tvalid(DMAC_STR_IN_1_TVALID),
    .str_in_1_tready(DMAC_STR_IN_1_TREADY),
    .str_in_1_tdata(DMAC_STR_IN_1_TDATA),
    .str_in_1_tstrb(DMAC_STR_IN_1_TSTRB),
    .str_in_1_tlast(DMAC_STR_IN_1_TLAST),
    .str_in_1_flush(DMAC_STR_IN_1_FLUSH),

    .allch_stop_req_nonsec(DMAC_ALLCH_STOP_REQ_NONSEC),
    .allch_stop_ack_nonsec(DMAC_ALLCH_STOP_ACK_NONSEC),
    .allch_pause_req_nonsec(DMAC_ALLCH_PAUSE_REQ_NONSEC),
    .allch_pause_ack_nonsec(DMAC_ALLCH_PAUSE_ACK_NONSEC),
    .ch_enabled(DMAC_CH_ENABLED),
    .ch_err(DMAC_CH_ERR),
    .ch_stopped(DMAC_CH_STOPPED),
    .ch_paused(DMAC_CH_PAUSED),
    .ch_priv(DMAC_CH_PRIV),
    .halt_req(DMAC_HALT_REQ),
    .restart_req(DMAC_RESTART_REQ),
    .halted(DMAC_HALTED),
    .boot_en(DMAC_BOOT_EN),
    .boot_addr(DMAC_BOOT_ADDR),
    .boot_memattr(DMAC_BOOT_MEMATTR),
    .boot_shareattr(DMAC_BOOT_SHAREATTR)
);



endmodule