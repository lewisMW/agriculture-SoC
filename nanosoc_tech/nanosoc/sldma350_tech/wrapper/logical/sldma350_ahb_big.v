//-----------------------------------------------------------------------------
// DMA350 wrapper - Contains DMA Controllers with AHB interface
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access l
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module sldma350_ahb #(
    parameter    SYS_ADDR_W  = 32,
    parameter    SYS_DATA_W  = 32,
    parameter    CFG_ADDR_W  = 13,  // Configuration Port Address Width
    parameter    CHANNEL_NUM = 2    // Number of DMA Channels

    )(
    // AHB Clocks and Resets 
    input wire                      HCLK,
    input wire                      HRESETn,

    // AHB Lite Port 0
    output wire   [SYS_ADDR_W-1:0]  HADDR_0,       // Address bus
    output wire              [1:0]  HTRANS_0,      // Transfer type
    output wire                     HWRITE_0,      // Transfer direction
    output wire              [2:0]  HSIZE_0,       // Transfer size
    output wire              [2:0]  HBURST_0,      // Burst type
    output wire              [3:0]  HPROT_0,       // Protection control
    output wire   [SYS_DATA_W-1:0]  HWDATA_0,      // Write data
    output wire                     HMASTLOCK_0,   // Locked Sequence
    input  wire   [SYS_DATA_W-1:0]  HRDATA_0,      // Read data bus
    input  wire                     HREADY_0,      // HREADY feedback
    input  wire                     HRESP_0,       // Transfer response
    
    // AHB Lite Port 1
    output wire   [SYS_ADDR_W-1:0]  HADDR_1,       // Address bus
    output wire              [1:0]  HTRANS_1,      // Transfer type
    output wire                     HWRITE_1,      // Transfer direction
    output wire              [2:0]  HSIZE_1,       // Transfer size
    output wire              [2:0]  HBURST_1,      // Burst type
    output wire              [3:0]  HPROT_1,       // Protection control
    output wire   [SYS_DATA_W-1:0]  HWDATA_1,      // Write data
    output wire                     HMASTLOCK_1,   // Locked Sequence
    input  wire   [SYS_DATA_W-1:0]  HRDATA_1,      // Read data bus
    input  wire                     HREADY_1,      // HREADY feedback
    input  wire                     HRESP_1,       // Transfer response

    // APB Configurtation Port
    input  wire                     PCLKEN,      // APB clock enable
    input  wire                     PSEL,        // APB peripheral select
    input  wire                     PEN,         // APB transfer enable
    input  wire                     PWRITE,      // APB transfer direction
    input  wire   [CFG_ADDR_W-1:0]  PADDR,       // APB address
    input  wire   [SYS_DATA_W-1:0]  PWDATA,      // APB write data
    output wire   [SYS_DATA_W-1:0]  PRDATA,      // APB read data
    output wire                     PREADY,
    output wire                     PSLVERR,
`ifdef DMA350_STREAM_2
    //  DMAC Channel 0 AXI stream out
    output wire                     DMAC_STR_OUT_0_TVALID,
    input  wire                     DMAC_STR_OUT_0_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_0_TDATA,
    output wire [4-1:0]             DMAC_STR_OUT_0_TSTRB,
    output wire                     DMAC_STR_OUT_0_TLAST,

    //  DMAC Channel 0 AXI Stream in
    input  wire                     DMAC_STR_IN_0_TVALID,
    output wire                     DMAC_STR_IN_0_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_0_TDATA,
    input  wire [4-1:0]             DMAC_STR_IN_0_TSTRB,
    input  wire                     DMAC_STR_IN_0_TLAST,
    output wire                     DMAC_STR_IN_0_FLUSH,

    //  DMAC Channel 1 AXI Stream out
    output wire                     DMAC_STR_OUT_1_TVALID,
    input  wire                     DMAC_STR_OUT_1_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_1_TDATA,
    output wire [4-1:0]             DMAC_STR_OUT_1_TSTRB,
    output wire                     DMAC_STR_OUT_1_TLAST,

    //  DMAC Channel 1 AXI Stream out
    input  wire                     DMAC_STR_IN_1_TVALID,
    output wire                     DMAC_STR_IN_1_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_1_TDATA,
    input  wire [4-1:0]             DMAC_STR_IN_1_TSTRB,
    input  wire                     DMAC_STR_IN_1_TLAST,
    output wire                     DMAC_STR_IN_1_FLUSH,
`endif
`ifdef DMA350_STREAM_3
//  DMAC Channel 1 AXI Stream out
    output wire                     DMAC_STR_OUT_2_TVALID,
    input  wire                     DMAC_STR_OUT_2_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_2_TDATA,
    output wire [4-1:0]             DMAC_STR_OUT_2_TSTRB,
    output wire                     DMAC_STR_OUT_2_TLAST,

    //  DMAC Channel 1 AXI Stream out
    input  wire                     DMAC_STR_IN_2_TVALID,
    output wire                     DMAC_STR_IN_2_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_2_TDATA,
    input  wire [4-1:0]             DMAC_STR_IN_2_TSTRB,
    input  wire                     DMAC_STR_IN_2_TLAST,
    output wire                     DMAC_STR_IN_2_FLUSH,
`endif

    // DMA Request and Status Port
    input  wire  [CHANNEL_NUM-1:0] DMA_REQ,     // DMA transfer request
    output wire  [CHANNEL_NUM-1:0] DMA_DONE,    // DMA transfer done
    output wire                    DMA_ERR      // DMA slave response not OK
);
//  DMAC AXI Port
wire                     DMAC_AWAKEUP;
wire                     DMAC_AWVALID;
wire [SYS_ADDR_W-1:0]    DMAC_AWADDR;
wire [1:0]               DMAC_AWBURST;
wire [7:0]               DMAC_AWLEN;
wire [2:0]               DMAC_AWSIZE;
wire [3:0]               DMAC_AWQOS;
wire [2:0]               DMAC_AWPROT;
wire                     DMAC_AWREADY;
wire [3:0]               DMAC_AWCACHE;
wire [3:0]               DMAC_AWINNER;
wire [1:0]               DMAC_AWDOMAIN;

wire                     DMAC_ARVALID;
wire [SYS_ADDR_W-1:0]    DMAC_ARADDR;
wire [1:0]               DMAC_ARBURST;
wire [7:0]               DMAC_ARLEN;
wire [2:0]               DMAC_ARSIZE;
wire [3:0]               DMAC_ARQOS;
wire [2:0]               DMAC_ARPROT;
wire                     DMAC_ARREADY;
wire [3:0]               DMAC_ARCACHE;
wire [3:0]               DMAC_ARINNER;
wire [1:0]               DMAC_ARDOMAIN;
wire                     DMAC_ARCMDLINK;

wire                     DMAC_WVALID;
wire                     DMAC_WLAST;
wire [4-1:0]             DMAC_WSTRB;
wire [SYS_DATA_W-1:0]    DMAC_WDATA;
wire                     DMAC_WREADY;
wire                     DMAC_RVALID;
wire                     DMAC_RLAST;
wire  [SYS_DATA_W-1:0]   DMAC_RDATA;
wire  [2-1:0]            DMAC_RPOISON;
wire  [1:0]              DMAC_RRESP;
wire                     DMAC_RREADY;

wire                     DMAC_BVALID;
wire  [1:0]              DMAC_BRESP;
wire                     DMAC_BREADY;
wire  [1:0]              DMAC_BID;
wire  [1:0]              DMAC_WID;
wire  [1:0]              DMAC_RID;
wire  [1:0]              DMAC_ARID;
wire  [1:0]              DMAC_AWID;

//  DMAC AXI Port M1
wire                     DMAC_AWAKEUP_M1;
wire                     DMAC_AWVALID_M1;
wire [SYS_ADDR_W-1:0]    DMAC_AWADDR_M1;
wire [1:0]               DMAC_AWBURST_M1;
wire [7:0]               DMAC_AWLEN_M1;
wire [2:0]               DMAC_AWSIZE_M1;
wire [3:0]               DMAC_AWQOS_M1;
wire [2:0]               DMAC_AWPROT_M1;
wire                     DMAC_AWREADY_M1;
wire [3:0]               DMAC_AWCACHE_M1;
wire [3:0]               DMAC_AWINNER_M1;
wire [1:0]               DMAC_AWDOMAIN_M1;

wire                     DMAC_ARVALID_M1;
wire [SYS_ADDR_W-1:0]    DMAC_ARADDR_M1;
wire [1:0]               DMAC_ARBURST_M1;
wire [7:0]               DMAC_ARLEN_M1;
wire [2:0]               DMAC_ARSIZE_M1;
wire [3:0]               DMAC_ARQOS_M1;
wire [2:0]               DMAC_ARPROT_M1;
wire                     DMAC_ARREADY_M1;
wire [3:0]               DMAC_ARCACHE_M1;
wire [3:0]               DMAC_ARINNER_M1;
wire [1:0]               DMAC_ARDOMAIN_M1;
wire                     DMAC_ARCMDLINK_M1;

wire                     DMAC_WVALID_M1;
wire                     DMAC_WLAST_M1;
wire [4-1:0]             DMAC_WSTRB_M1;
wire [SYS_DATA_W-1:0]    DMAC_WDATA_M1;
wire                     DMAC_WREADY_M1;
wire                     DMAC_RVALID_M1;
wire                     DMAC_RLAST_M1;
wire  [SYS_DATA_W-1:0]   DMAC_RDATA_M1;
wire  [2-1:0]            DMAC_RPOISON_M1;
wire  [1:0]              DMAC_RRESP_M1;
wire                     DMAC_RREADY_M1;

wire                     DMAC_BVALID_M1;
wire  [1:0]              DMAC_BRESP_M1;
wire                     DMAC_BREADY_M1;
wire  [1:0]              DMAC_BID_M1;
wire  [1:0]              DMAC_WID_M1;
wire  [1:0]              DMAC_RID_M1;
wire  [1:0]              DMAC_ARID_M1;
wire  [1:0]              DMAC_AWID_M1;

// Trigger 0 in
wire                     DMAC_TRIG_IN_0_REQ;
wire  [1:0]              DMAC_TRIG_IN_0_REQ_TYPE;
wire                     DMAC_TRIG_IN_0_ACK;
wire [1:0]               DMAC_TRIG_IN_0_ACK_TYPE;
wire                     DMAC_TRIG_IN_1_REQ;
wire  [1:0]              DMAC_TRIG_IN_1_REQ_TYPE;
wire                     DMAC_TRIG_IN_1_ACK;
wire [1:0]               DMAC_TRIG_IN_1_ACK_TYPE;
wire                     DMAC_TRIG_IN_2_REQ;
wire  [1:0]              DMAC_TRIG_IN_2_REQ_TYPE;
wire                     DMAC_TRIG_IN_2_ACK;
wire [1:0]               DMAC_TRIG_IN_2_ACK_TYPE;
wire [2-1:0]             DMAC_IRQ_CHANNEL;
wire                     DMAC_IRQ_COMB_NONSEC;


wire                     DMAC_ALLCH_STOP_REQ_NONSEC;
wire                     DMAC_ALLCH_STOP_ACK_NONSEC;
wire                     DMAC_ALLCH_PAUSE_REQ_NONSEC;
wire                     DMAC_ALLCH_PAUSE_ACK_NONSEC;
wire [2-1:0]             DMAC_CH_ENABLED;
wire [2-1:0]             DMAC_CH_ERR;
wire [2-1:0]             DMAC_CH_STOPPED;
wire [2-1:0]             DMAC_CH_PAUSED;
wire [2-1:0]             DMAC_CH_PRIV;

wire                     DMAC_HALTED;

assign DMA_ERR = |DMAC_CH_ERR;

// AHB conversion WIRES
wire [6:0]      HPROT_0_int;
wire [6:0]      HPROT_1_int;

assign HPROT_0 = HPROT_0_int[3:0];
assign HPROT_1 = HPROT_1_int[3:0];

// -------------------------------
// DMA Controller Instantiation
// -------------------------------
ada_top_sldma350 u_dmac_0(
    // Clock and Reset signals
    .clk(HCLK),
    .resetn(HRESETn),
    .aclken_m0(1'b1),
    .aclken_m1(1'b1),
    .pclken(PCLKEN),
    // Q Channel signals
    .clk_qreqn(1'b1),
    .clk_qacceptn(),
    .clk_qdeny(),
    .clk_qactive(),
    // P Channel Signals
    .preq(1'b0),
    .pstate(4'b1000),
    .paccept(),
    .pdeny(),
    .pactive(),

    .pwakeup(1'b1),
    .pdebug(1'b0),
    .psel(PSEL),
    .penable(PEN),
    .pprot(3'b100),
    .pwrite(PWRITE),
    .paddr(PADDR),
    .pwdata(PWDATA),
    .pstrb(4'b1111),
    .pready(PREADY),
    .pslverr(PSLVERR),
    .prdata(PRDATA),
    // AXI Write Channel Signals
    .awakeup_m0(DMAC_AWAKEUP),
    .awvalid_m0(DMAC_AWVALID),
    .awaddr_m0(DMAC_AWADDR),
    .awburst_m0(DMAC_AWBURST),
    .awid_m0(DMAC_AWID),
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
    .arid_m0(DMAC_ARID),
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
    .rid_m0(DMAC_RID),
    .rlast_m0(DMAC_RLAST),
    .rdata_m0(DMAC_RDATA),
    .rpoison_m0(1'b0),
    .rresp_m0(DMAC_RRESP),
    .rready_m0(DMAC_RREADY),
    // AXI Write response signals
    .bvalid_m0(DMAC_BVALID),
    .bid_m0(DMAC_BID),
    .bresp_m0(DMAC_BRESP),
    .bready_m0(DMAC_BREADY),
    // AXI Write Channel Signals M1
    .awakeup_m1(DMAC_AWAKEUP_M1),
    .awvalid_m1(DMAC_AWVALID_M1),
    .awaddr_m1(DMAC_AWADDR_M1),
    .awburst_m1(DMAC_AWBURST_M1),
    .awid_m1(DMAC_AWID_M1),
    .awlen_m1(DMAC_AWLEN_M1),
    .awsize_m1(DMAC_AWSIZE_M1),
    .awqos_m1(DMAC_AWQOS_M1),
    .awprot_m1(DMAC_AWPROT_M1),
    .awready_m1(DMAC_AWREADY_M1),
    .awcache_m1(DMAC_AWCACHE_M1),
    .awinner_m1(DMAC_AWINNER_M1),
    .awdomain_m1(DMAC_AWDOMAIN_M1),
    // AXI Read Channel Signals
    .arvalid_m1(DMAC_ARVALID_M1),
    .araddr_m1(DMAC_ARADDR_M1),
    .arburst_m1(DMAC_ARBURST_M1),
    .arid_m1(DMAC_ARID_M1),
    .arlen_m1(DMAC_ARLEN_M1),
    .arsize_m1(DMAC_ARSIZE_M1),
    .arqos_m1(DMAC_ARQOS_M1),
    .arprot_m1(DMAC_ARPROT_M1),
    .arready_m1(DMAC_ARREADY_M1),
    .arcache_m1(DMAC_ARCACHE_M1),
    .arinner_m1(DMAC_ARINNER_M1),
    .ardomain_m1(DMAC_ARDOMAIN_M1),
    .arcmdlink_m1(DMAC_ARCMDLINK_M1),
    // AXI Write Data Signals
    .wvalid_m1(DMAC_WVALID_M1),
    .wlast_m1(DMAC_WLAST_M1),
    .wstrb_m1(DMAC_WSTRB_M1),
    .wdata_m1(DMAC_WDATA_M1),
    .wready_m1(DMAC_WREADY_M1),
    // AXI Read Data Signals
    .rvalid_m1(DMAC_RVALID_M1),
    .rid_m1(DMAC_RID_M1),
    .rlast_m1(DMAC_RLAST_M1),
    .rdata_m1(DMAC_RDATA_M1),
    .rpoison_m1(1'b0),
    .rresp_m1(DMAC_RRESP_M1),
    .rready_m1(DMAC_RREADY_M1),
    // AXI Write response signals
    .bvalid_m1(DMAC_BVALID_M1),
    .bid_m1(DMAC_BID_M1),
    .bresp_m1(DMAC_BRESP_M1),
    .bready_m1(DMAC_BREADY_M1),
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
    // Trigger 2 in
    .trig_in_2_req(DMAC_TRIG_IN_2_REQ),
    .trig_in_2_req_type(DMAC_TRIG_IN_2_REQ_TYPE),
    .trig_in_2_ack(DMAC_TRIG_IN_2_ACK),
    .trig_in_2_ack_type(DMAC_TRIG_IN_2_ACK_TYPE),
    // Interrupt Signals
    .irq_channel(DMA_DONE),
    .irq_comb_nonsec(DMAC_IRQ_COMB_NONSEC),
`ifdef DMA350_STREAM_2
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
`endif
`ifdef DMA350_STREAM_3
    // AXI Stream 1 out
    .str_out_2_tvalid(DMAC_STR_OUT_2_TVALID),
    .str_out_2_tready(DMAC_STR_OUT_2_TREADY),
    .str_out_2_tdata(DMAC_STR_OUT_2_TDATA),
    .str_out_2_tstrb(DMAC_STR_OUT_2_TSTRB),
    .str_out_2_tlast(DMAC_STR_OUT_2_TLAST),
    // AXI Stream 1 in
    .str_in_2_tvalid(DMAC_STR_IN_2_TVALID),
    .str_in_2_tready(DMAC_STR_IN_2_TREADY),
    .str_in_2_tdata(DMAC_STR_IN_2_TDATA),
    .str_in_2_tstrb(DMAC_STR_IN_2_TSTRB),
    .str_in_2_tlast(DMAC_STR_IN_2_TLAST),
    .str_in_2_flush(DMAC_STR_IN_2_FLUSH),
`endif
    .allch_stop_req_nonsec(1'b0),
    .allch_stop_ack_nonsec(DMAC_ALLCH_STOP_ACK_NONSEC),
    .allch_pause_req_nonsec(1'b0),
    .allch_pause_ack_nonsec(DMAC_ALLCH_PAUSE_ACK_NONSEC),
    .ch_enabled(DMAC_CH_ENABLED),
    .ch_err(DMAC_CH_ERR),
    .ch_stopped(DMAC_CH_STOPPED),
    .ch_paused(DMAC_CH_PAUSED),
    .ch_priv(DMAC_CH_PRIV),
    .halt_req(1'b0),
    .restart_req(1'b0),
    .halted(DMAC_HALTED),
    .boot_en(1'b0),
    .boot_addr(),
    .boot_memattr(),
    .boot_shareattr()
);

xhb500_axi_to_ahb_bridge_sldma350 u_xhb_0
(
    //-----------------------------------------------------------------------------
    // Clock and Reset
    //-----------------------------------------------------------------------------

    .clk(HCLK),
    .resetn(HRESETn),
    .clk_qactive(),
    .clk_qreqn(1'b1),
    .clk_qacceptn(),
    .clk_qdeny(),
    .pwr_qactive(),
    .pwr_qreqn(1'b1),
    .pwr_qacceptn(),
    .pwr_qdeny(),
    //-----------------------------------------------------------------------------
    // AXI Master Interface
    //-----------------------------------------------------------------------------

    // Write Address Channel signals
    .awvalid(DMAC_AWVALID),
    .awready(DMAC_AWREADY),
    .awaddr(DMAC_AWADDR),
    .awburst(DMAC_AWBURST),
    .awid(DMAC_AWID),
    .awlen(DMAC_AWLEN),
    .awsize(DMAC_AWSIZE),
    .awlock(1'b0),
    .awprot(DMAC_AWPROT),
    .awcache(DMAC_AWCACHE),
  
// Read Address Channel signals  
    .arvalid(DMAC_ARVALID),
    .arready(DMAC_ARREADY),
    .araddr(DMAC_ARADDR),
    .arburst(DMAC_ARBURST),
    .arid(DMAC_ARID),
    .arlen(DMAC_ARLEN),
    .arsize(DMAC_ARSIZE),
    .arlock(1'b0), 
    .arprot(DMAC_ARPROT),
    .arcache(DMAC_ARCACHE),
  
// Write Data Channel signals   
    .wvalid(DMAC_WVALID),
    .wready(DMAC_WREADY),
    .wlast(DMAC_WLAST),
    .wstrb(DMAC_WSTRB),
    .wdata(DMAC_WDATA),
  
// Read Data Channel signals 
    .rvalid(DMAC_RVALID),
    .rready(DMAC_RREADY),   
    .rid(DMAC_RID),
    .rlast(DMAC_RLAST),
    .rdata(DMAC_RDATA),
    .rresp(DMAC_RRESP),
  
// Write Response Channel signals 
    .bready(DMAC_BREADY),   
    .bvalid(DMAC_BVALID),
    .bid(DMAC_BID),
    .bresp(DMAC_BRESP),
  
    .ardomain(DMAC_ARDOMAIN),
    .awdomain(DMAC_AWDOMAIN),
    .awakeup(DMAC_AWAKEUP),
    .awnsaid(4'b0000),
    .arnsaid(4'b0000),
    .awqos(DMAC_AWQOS),
    .arqos(DMAC_ARQOS),
    .awregion(4'b0000),
    .arregion(4'b0000),
//-----------------------------------------------------------------------------
// AHB-Lite Slave Interface
//-----------------------------------------------------------------------------

// AHB-Lite Master signals
    .hnonsec(),
    .haddr(HADDR_0),
    .htrans(HTRANS_0),
    .hsize(HSIZE_0),
    .hwrite(HWRITE_0),
    .hprot(HPROT_0_int),
    .hburst(HBURST_0),
    .hmastlock(HMASTLOCK_0),
    .hwdata(HWDATA_0),
    .hexcl(),
  
// AHB-Lite Slave Response signals  
    .hrdata(HRDATA_0),
    .hready(HREADY_0),
    .hresp(HRESP_0),
    .hexokay(1'b0),

// Sideband AHB USER signals
    .hwstrb(),
    .hqos(),
    .hregion(),
    .hnsaid()
);

xhb500_axi_to_ahb_bridge_sldma350 u_xhb_1
(
    //-----------------------------------------------------------------------------
    // Clock and Reset
    //-----------------------------------------------------------------------------

    .clk(HCLK),
    .resetn(HRESETn),
    .clk_qactive(),
    .clk_qreqn(1'b1),
    .clk_qacceptn(),
    .clk_qdeny(),
    .pwr_qactive(),
    .pwr_qreqn(1'b1),
    .pwr_qacceptn(),
    .pwr_qdeny(),
    //-----------------------------------------------------------------------------
    // AXI Master Interface
    //-----------------------------------------------------------------------------

    // Write Address Channel signals
    .awvalid(DMAC_AWVALID_M1),
    .awready(DMAC_AWREADY_M1),
    .awaddr(DMAC_AWADDR_M1),
    .awburst(DMAC_AWBURST_M1),
    .awid(DMAC_AWID_M1),
    .awlen(DMAC_AWLEN_M1),
    .awsize(DMAC_AWSIZE_M1),
    .awlock(1'b0),
    .awprot(DMAC_AWPROT_M1),
    .awcache(DMAC_AWCACHE_M1),
  
// Read Address Channel signals  
    .arvalid(DMAC_ARVALID_M1),
    .arready(DMAC_ARREADY_M1),
    .araddr(DMAC_ARADDR_M1),
    .arburst(DMAC_ARBURST_M1),
    .arid(DMAC_ARID_M1),
    .arlen(DMAC_ARLEN_M1),
    .arsize(DMAC_ARSIZE_M1),
    .arlock(1'b0), 
    .arprot(DMAC_ARPROT_M1),
    .arcache(DMAC_ARCACHE_M1),
  
// Write Data Channel signals   
    .wvalid(DMAC_WVALID_M1),
    .wready(DMAC_WREADY_M1),
    .wlast(DMAC_WLAST_M1),
    .wstrb(DMAC_WSTRB_M1),
    .wdata(DMAC_WDATA_M1),
  
// Read Data Channel signals 
    .rvalid(DMAC_RVALID_M1),
    .rready(DMAC_RREADY_M1),   
    .rid(DMAC_RID_M1),
    .rlast(DMAC_RLAST_M1),
    .rdata(DMAC_RDATA_M1),
    .rresp(DMAC_RRESP_M1),
  
// Write Response Channel signals 
    .bready(DMAC_BREADY_M1),   
    .bvalid(DMAC_BVALID_M1),
    .bid(DMAC_BID_M1),
    .bresp(DMAC_BRESP_M1),
  
    .ardomain(DMAC_ARDOMAIN_M1),
    .awdomain(DMAC_AWDOMAIN_M1),
    .awakeup(DMAC_AWAKEUP_M1),
    .awnsaid(4'b0000),
    .arnsaid(4'b0000),
    .awqos(DMAC_AWQOS_M1),
    .arqos(DMAC_ARQOS_M1),
    .awregion(4'b0000),
    .arregion(4'b0000),
//-----------------------------------------------------------------------------
// AHB-Lite Slave Interface
//-----------------------------------------------------------------------------

// AHB-Lite Master signals
    .hnonsec(),
    .haddr(HADDR_1),
    .htrans(HTRANS_1),
    .hsize(HSIZE_1),
    .hwrite(HWRITE_1),
    .hprot(HPROT_1_int),
    .hburst(HBURST_1),
    .hmastlock(HMASTLOCK_1),
    .hwdata(HWDATA_1),
    .hexcl(),
  
// AHB-Lite Slave Response signals  
    .hrdata(HRDATA_1),
    .hready(HREADY_1),
    .hresp(HRESP_1),
    .hexokay(1'b0),

// Sideband AHB USER signals
    .hwstrb(),
    .hqos(),
    .hregion(),
    .hnsaid()
);

//-----------------------------------------------------------------------------
// DMA Trigger interface converter
//-----------------------------------------------------------------------------
sldma350_trig_converter u_trig_conv_0 (
    .clk(HCLK),
    .resetn(HRESETn),
    .trig_in_req(DMAC_TRIG_IN_0_REQ),
    .trig_in_req_type(DMAC_TRIG_IN_0_REQ_TYPE),
    .trig_in_ack(DMAC_TRIG_IN_0_ACK),
    .trig_in_ack_type(DMAC_TRIG_IN_0_ACK_TYPE),
    .DMAC_DMA_REQ(DMA_REQ[0]&~DMA_REQ[1]),
    .DMAC_DMA_REQ_ERR()
);

sldma350_trig_converter u_trig_conv_1 (
    .clk(HCLK),
    .resetn(HRESETn),
    .trig_in_req(DMAC_TRIG_IN_1_REQ),
    .trig_in_req_type(DMAC_TRIG_IN_1_REQ_TYPE),
    .trig_in_ack(DMAC_TRIG_IN_1_ACK),
    .trig_in_ack_type(DMAC_TRIG_IN_1_ACK_TYPE),
    .DMAC_DMA_REQ(~DMA_REQ[0]&DMA_REQ[1]),
    .DMAC_DMA_REQ_ERR()
);

sldma350_trig_converter u_trig_conv_2 (
    .clk(HCLK),
    .resetn(HRESETn),
    .trig_in_req(DMAC_TRIG_IN_2_REQ),
    .trig_in_req_type(DMAC_TRIG_IN_2_REQ_TYPE),
    .trig_in_ack(DMAC_TRIG_IN_2_ACK),
    .trig_in_ack_type(DMAC_TRIG_IN_2_ACK_TYPE),
    .DMAC_DMA_REQ(DMA_REQ[0]&DMA_REQ[1]),
    .DMAC_DMA_REQ_ERR()
);
endmodule
