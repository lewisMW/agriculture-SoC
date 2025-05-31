//-----------------------------------------------------------------------------
// NanoSoC DMA Subsystem - Contains DMA Controllers
// - Version with DMA Controller 0 instantiated as DMA230 and DMA 1 disconnected
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module nanosoc_ss_dma #(
    parameter    SYS_ADDR_W         = 32,  // System Address Width
    parameter    SYS_DATA_W         = 32,  // System Data Width
    parameter    DMAC_0_CFG_ADDR_W  = 12,  // DMAC 0 Configuration Port Address Width
    parameter    DMAC_1_CFG_ADDR_W  = 12,  // DMAC 1 Configuration Port Address Width
    parameter    DMAC_0_CHANNEL_NUM = 2,   // DMAC 0 Number of DMA Channels 
    parameter    DMAC_1_CHANNEL_NUM = 2    // DMAC 1 Number of DMA Channels
)(
    // System AHB Clocks and Resets 
    input wire                           SYS_HCLK,
    input wire                           SYS_HRESETn,
    input wire                           SYS_PCLKEN,          // APB clock enable

    // DMAC 0 AHB Lite Port
    output wire          [SYS_ADDR_W-1:0] DMAC_0_HADDR,       // Address bus
    output wire                     [1:0] DMAC_0_HTRANS,      // Transfer type
    output wire                           DMAC_0_HWRITE,      // Transfer direction
    output wire                     [2:0] DMAC_0_HSIZE,       // Transfer size
    output wire                     [2:0] DMAC_0_HBURST,      // Burst type
    output wire                     [3:0] DMAC_0_HPROT,       // Protection control
    output wire          [SYS_DATA_W-1:0] DMAC_0_HWDATA,      // Write data
    output wire                           DMAC_0_HMASTLOCK,   // Locked Sequence
    input  wire          [SYS_DATA_W-1:0] DMAC_0_HRDATA,      // Read data bus
    input  wire                           DMAC_0_HREADY,      // HREADY feedback
    input  wire                           DMAC_0_HRESP,       // Transfer response
    
    // DMAC 0 APB Configurtation Port
    input  wire                           DMAC_0_PSEL,        // APB peripheral select
    input  wire                           DMAC_0_PEN,         // APB transfer enable
    input  wire                           DMAC_0_PWRITE,      // APB transfer direction
    input  wire   [DMAC_0_CFG_ADDR_W-1:0] DMAC_0_PADDR,       // APB address
    input  wire          [SYS_DATA_W-1:0] DMAC_0_PWDATA,      // APB write data
    output wire          [SYS_DATA_W-1:0] DMAC_0_PRDATA,      // APB read data
    output wire                           DMAC_0_PREADY,      // APB Ready
    output wire                           DMAC_0_PSLVERR,     // APB Slave Error
    
    // DMAC 0 DMA Request and Status Port
    input  wire  [DMAC_0_CHANNEL_NUM-1:0] DMAC_0_DMA_REQ,     // DMA transfer request
    output wire  [DMAC_0_CHANNEL_NUM-1:0] DMAC_0_DMA_DONE,    // DMA transfer done
    output wire                           DMAC_0_DMA_ERR,     // DMA slave response not OK

    // DMAC 1 AHB Lite Port
    output wire          [SYS_ADDR_W-1:0] DMAC_1_HADDR,       // Address bus
    output wire                     [1:0] DMAC_1_HTRANS,      // Transfer type
    output wire                           DMAC_1_HWRITE,      // Transfer direction
    output wire                     [2:0] DMAC_1_HSIZE,       // Transfer size
    output wire                     [2:0] DMAC_1_HBURST,      // Burst type
    output wire                     [3:0] DMAC_1_HPROT,       // Protection control
    output wire          [SYS_DATA_W-1:0] DMAC_1_HWDATA,      // Write data
    output wire                           DMAC_1_HMASTLOCK,   // Locked Sequence
    input  wire          [SYS_DATA_W-1:0] DMAC_1_HRDATA,      // Read data bus
    input  wire                           DMAC_1_HREADY,      // HREADY feedback
    input  wire                           DMAC_1_HRESP,       // Transfer response
    
    // DMAC 1 APB Configurtation Port
    input  wire                           DMAC_1_PSEL,        // APB peripheral select
    input  wire                           DMAC_1_PSEL_HI,
    input  wire                           DMAC_1_PEN,         // APB transfer enable
    input  wire                           DMAC_1_PWRITE,      // APB transfer direction
    input  wire   [DMAC_1_CFG_ADDR_W-1:0] DMAC_1_PADDR,       // APB address
    input  wire          [SYS_DATA_W-1:0] DMAC_1_PWDATA,      // APB write data
    output wire          [SYS_DATA_W-1:0] DMAC_1_PRDATA,      // APB read data
    output wire                           DMAC_1_PREADY,      // APB Ready
    output wire                           DMAC_1_PSLVERR,     // APB Slave Error
    
`ifdef DMAC_DMA350 
`ifdef DMA350_STREAM_2
    //  DMAC Channel 0 AXI stream out
    output wire                     DMAC_STR_OUT_0_TVALID,
    input  wire                     DMAC_STR_OUT_0_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_0_TDATA,
    output wire [4-1:0]            DMAC_STR_OUT_0_TSTRB,
    output wire                     DMAC_STR_OUT_0_TLAST,

    //  DMAC Channel 0 AXI Stream in
    input  wire                     DMAC_STR_IN_0_TVALID,
    output wire                     DMAC_STR_IN_0_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_0_TDATA,
    input  wire [4-1:0]            DMAC_STR_IN_0_TSTRB,
    input  wire                     DMAC_STR_IN_0_TLAST,
    output wire                     DMAC_STR_IN_0_FLUSH,

    //  DMAC Channel 1 AXI Stream out
    output wire                     DMAC_STR_OUT_1_TVALID,
    input  wire                     DMAC_STR_OUT_1_TREADY,
    output wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_1_TDATA,
    output wire [4-1:0]            DMAC_STR_OUT_1_TSTRB,
    output wire                     DMAC_STR_OUT_1_TLAST,

    //  DMAC Channel 1 AXI Stream out
    input  wire                     DMAC_STR_IN_1_TVALID,
    output wire                     DMAC_STR_IN_1_TREADY,
    input  wire [SYS_DATA_W-1:0]    DMAC_STR_IN_1_TDATA,
    input  wire [4-1:0]            DMAC_STR_IN_1_TSTRB,
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
`endif

    // DMAC 1 DMA Request and Status Port
    input  wire  [DMAC_1_CHANNEL_NUM-1:0] DMAC_1_DMA_REQ,     // DMA transfer request
    output wire  [DMAC_1_CHANNEL_NUM-1:0] DMAC_1_DMA_DONE,    // DMA transfer done
    output wire                           DMAC_1_DMA_ERR      // DMA slave response not OK
);

`ifdef DMAC_DMA350 
    //-------------------------------
    //DMA Controller 0 Instantiation
    //-------------------------------

    wire DMAC_1_PSEL_IN;
    assign DMAC_1_PSEL_IN = DMAC_1_PSEL | DMAC_1_PSEL_HI;

    // DMA Status Tie-off signals
    assign DMAC_1_DMA_DONE  = {DMAC_0_CHANNEL_NUM{1'b0}};
    assign DMAC_1_DMA_ERR   = 1'b0;
    
    sldma350_ahb #( 
        .SYS_ADDR_W  (SYS_ADDR_W),
        .SYS_DATA_W  (SYS_DATA_W),
        .CFG_ADDR_W  (13),
        .CHANNEL_NUM (DMAC_0_CHANNEL_NUM)
    ) u_dmac (
        // AHB Clocks and Resets
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB Lite Port 0
        .HADDR_0(DMAC_0_HADDR),
        .HTRANS_0(DMAC_0_HTRANS),
        .HWRITE_0(DMAC_0_HWRITE),
        .HSIZE_0(DMAC_0_HSIZE),
        .HBURST_0(DMAC_0_HBURST),
        .HPROT_0(DMAC_0_HPROT),
        .HWDATA_0(DMAC_0_HWDATA),
        .HMASTLOCK_0(DMAC_0_HMASTLOCK),
        .HRDATA_0(DMAC_0_HRDATA),
        .HREADY_0(DMAC_0_HREADY),
        .HRESP_0(DMAC_0_HRESP),

        // AHB Lite Port 1
        .HADDR_1(DMAC_1_HADDR),
        .HTRANS_1(DMAC_1_HTRANS),
        .HWRITE_1(DMAC_1_HWRITE),
        .HSIZE_1(DMAC_1_HSIZE),
        .HBURST_1(DMAC_1_HBURST),
        .HPROT_1(DMAC_1_HPROT),
        .HWDATA_1(DMAC_1_HWDATA),
        .HMASTLOCK_1(DMAC_1_HMASTLOCK),
        .HRDATA_1(DMAC_1_HRDATA),
        .HREADY_1(DMAC_1_HREADY),
        .HRESP_1(DMAC_1_HRESP),

        // APB Configuration Port
        .PCLKEN(SYS_PCLKEN),
        .PSEL(DMAC_1_PSEL_IN),
        .PEN(DMAC_1_PEN),
        .PWRITE(DMAC_1_PWRITE),
        .PADDR({DMAC_1_PSEL_HI, DMAC_1_PADDR}),
        .PWDATA(DMAC_1_PWDATA),
        .PRDATA(DMAC_1_PRDATA),
        .PREADY(DMAC_1_PREADY),
        .PSLVERR(DMAC_1_PSLVERR),
        // DMA Request and Status Port
`ifdef DMA350_STREAM_2
        .DMAC_STR_OUT_0_TVALID(DMAC_STR_OUT_0_TVALID),
        .DMAC_STR_OUT_0_TREADY(DMAC_STR_OUT_0_TREADY),
        .DMAC_STR_OUT_0_TDATA(DMAC_STR_OUT_0_TDATA),
        .DMAC_STR_OUT_0_TSTRB(DMAC_STR_OUT_0_TSTRB),
        .DMAC_STR_OUT_0_TLAST(DMAC_STR_OUT_0_TLAST),
        .DMAC_STR_IN_0_TVALID(DMAC_STR_IN_0_TVALID),
        .DMAC_STR_IN_0_TREADY(DMAC_STR_IN_0_TREADY),
        .DMAC_STR_IN_0_TDATA(DMAC_STR_IN_0_TDATA),
        .DMAC_STR_IN_0_TSTRB(DMAC_STR_IN_0_TSTRB),
        .DMAC_STR_IN_0_TLAST(DMAC_STR_IN_0_TLAST),
        .DMAC_STR_IN_0_FLUSH(DMAC_STR_IN_0_FLUSH),
        .DMAC_STR_OUT_1_TVALID(DMAC_STR_OUT_1_TVALID),
        .DMAC_STR_OUT_1_TREADY(DMAC_STR_OUT_1_TREADY),
        .DMAC_STR_OUT_1_TDATA(DMAC_STR_OUT_1_TDATA),
        .DMAC_STR_OUT_1_TSTRB(DMAC_STR_OUT_1_TSTRB),
        .DMAC_STR_OUT_1_TLAST(DMAC_STR_OUT_1_TLAST),
        .DMAC_STR_IN_1_TVALID(DMAC_STR_IN_1_TVALID),
        .DMAC_STR_IN_1_TREADY(DMAC_STR_IN_1_TREADY),
        .DMAC_STR_IN_1_TDATA(DMAC_STR_IN_1_TDATA),
        .DMAC_STR_IN_1_TSTRB(DMAC_STR_IN_1_TSTRB),
        .DMAC_STR_IN_1_TLAST(DMAC_STR_IN_1_TLAST),
        .DMAC_STR_IN_1_FLUSH(DMAC_STR_IN_1_FLUSH),
`endif
`ifdef DMA350_STREAM_3
        .DMAC_STR_OUT_2_TVALID(DMAC_STR_OUT_2_TVALID),
        .DMAC_STR_OUT_2_TREADY(DMAC_STR_OUT_2_TREADY),
        .DMAC_STR_OUT_2_TDATA(DMAC_STR_OUT_2_TDATA),
        .DMAC_STR_OUT_2_TSTRB(DMAC_STR_OUT_2_TSTRB),
        .DMAC_STR_OUT_2_TLAST(DMAC_STR_OUT_2_TLAST),
        .DMAC_STR_IN_2_TVALID(DMAC_STR_IN_2_TVALID),
        .DMAC_STR_IN_2_TREADY(DMAC_STR_IN_2_TREADY),
        .DMAC_STR_IN_2_TDATA(DMAC_STR_IN_2_TDATA),
        .DMAC_STR_IN_2_TSTRB(DMAC_STR_IN_2_TSTRB),
        .DMAC_STR_IN_2_TLAST(DMAC_STR_IN_2_TLAST),
        .DMAC_STR_IN_2_FLUSH(DMAC_STR_IN_2_FLUSH),
`endif
        .DMA_REQ(DMAC_0_DMA_REQ),
        .DMA_DONE(DMAC_0_DMA_DONE),
        .DMA_ERR(DMAC_0_DMA_ERR)

    );

    
    // APB Tie-off signals
    assign DMAC_0_PREADY  = 1'b1;
    assign DMAC_0_PSLVERR = 1'b1;
    assign DMAC_0_PRDATA    = 32'd0;

`else
`ifdef DMAC_0_PL230
    // -------------------------------
    // DMA Controller 0 Instantiation
    // -------------------------------
    sldma230 #(
        .SYS_ADDR_W  (SYS_ADDR_W),
        .SYS_DATA_W  (SYS_DATA_W),
        .CFG_ADDR_W  (DMAC_0_CFG_ADDR_W),
        .CHANNEL_NUM (DMAC_0_CHANNEL_NUM)
    ) u_dmac_0 (
        // AHB Clocks and Resets
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB Lite Port
        .HADDR(DMAC_0_HADDR),
        .HTRANS(DMAC_0_HTRANS),
        .HWRITE(DMAC_0_HWRITE),
        .HSIZE(DMAC_0_HSIZE),
        .HBURST(DMAC_0_HBURST),
        .HPROT(DMAC_0_HPROT),
        .HWDATA(DMAC_0_HWDATA),
        .HMASTLOCK(DMAC_0_HMASTLOCK),
        .HRDATA(DMAC_0_HRDATA),
        .HREADY(DMAC_0_HREADY),
        .HRESP(DMAC_0_HRESP),

        // APB Configuration Port
        .PCLKEN(SYS_PCLKEN),
        .PSEL(DMAC_0_PSEL),
        .PEN(DMAC_0_PEN),
        .PWRITE(DMAC_0_PWRITE),
        .PADDR(DMAC_0_PADDR),
        .PWDATA(DMAC_0_PWDATA),
        .PRDATA(DMAC_0_PRDATA),

        // DMA Request and Status Port
        .DMA_REQ(DMAC_0_DMA_REQ),
        .DMA_DONE(DMAC_0_DMA_DONE),
        .DMA_ERR(DMAC_0_DMA_ERR)
    );
    
    // APB Assignments
    //--------------------------
    assign DMAC_0_PREADY  = 1'b1;
    assign DMAC_0_PSLVERR = 1'b0;
`else
    // -------------------------------
    // DMA Controller 0 Instantiation - Not implemented
    // -------------------------------
    // AHB Tie-off signals
    assign DMAC_0_HADDR     = 32'd0;
    assign DMAC_0_HTRANS    = 2'd0;
    assign DMAC_0_HWRITE    = 1'd0;
    assign DMAC_0_HSIZE     = 3'd0;
    assign DMAC_0_HBURST    = 3'd0;
    assign DMAC_0_HPROT     = 4'd0;
    assign DMAC_0_HWDATA    = 32'd0;
    assign DMAC_0_HMASTLOCK = 1'd0;
    
    assign DMAC_0_PREADY  = 1'b1;
    assign DMAC_0_PSLVERR = 1'b1;
    
    // APB Tie-off signals
    assign DMAC_0_PRDATA    = 32'd0;
    
    // DMA Status Tie-off signals
    assign DMAC_0_DMA_DONE  = {DMAC_0_CHANNEL_NUM{1'b0}};
    assign DMAC_0_DMA_ERR   = 1'b0;
`endif 

`ifdef DMAC_1_PL230

    // -------------------------------
    // DMA Controller 0 Instantiation
    // -------------------------------
    sldma230 #(
        .SYS_ADDR_W  (SYS_ADDR_W),
        .SYS_DATA_W  (SYS_DATA_W),
        .CFG_ADDR_W  (DMAC_1_CFG_ADDR_W),
        .CHANNEL_NUM (DMAC_1_CHANNEL_NUM)
    ) u_dmac_1 (
        // AHB Clocks and Resets
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB Lite Port
        .HADDR(DMAC_1_HADDR),
        .HTRANS(DMAC_1_HTRANS),
        .HWRITE(DMAC_1_HWRITE),
        .HSIZE(DMAC_1_HSIZE),
        .HBURST(DMAC_1_HBURST),
        .HPROT(DMAC_1_HPROT),
        .HWDATA(DMAC_1_HWDATA),
        .HMASTLOCK(DMAC_1_HMASTLOCK),
        .HRDATA(DMAC_1_HRDATA),
        .HREADY(DMAC_1_HREADY),
        .HRESP(DMAC_1_HRESP),

        // APB Configuration Port
        .PCLKEN(SYS_PCLKEN),
        .PSEL(DMAC_1_PSEL),
        .PEN(DMAC_1_PEN),
        .PWRITE(DMAC_1_PWRITE),
        .PADDR(DMAC_1_PADDR),
        .PWDATA(DMAC_1_PWDATA),
        .PRDATA(DMAC_1_PRDATA),

        // DMA Request and Status Port
        .DMA_REQ(DMAC_1_DMA_REQ),
        .DMA_DONE(DMAC_1_DMA_DONE),
        .DMA_ERR(DMAC_1_DMA_ERR)
    );
    
    // APB Assignments
    //--------------------------
    assign DMAC_1_PREADY  = 1'b1;
    assign DMAC_1_PSLVERR = 1'b0;
`else
    // -------------------------------
    // DMA Controller 1 Instantiation - Not implemented
    // -------------------------------
    // AHB Tie-off signals
    assign DMAC_1_HADDR     = 32'd0;
    assign DMAC_1_HTRANS    = 2'd0;
    assign DMAC_1_HWRITE    = 1'd0;
    assign DMAC_1_HSIZE     = 3'd0;
    assign DMAC_1_HBURST    = 3'd0;
    assign DMAC_1_HPROT     = 4'd0;
    assign DMAC_1_HWDATA    = 32'd0;
    assign DMAC_1_HMASTLOCK = 1'd0;

    assign DMAC_1_PREADY  = 1'b1;
    assign DMAC_1_PSLVERR = 1'b1;
    
    // APB Tie-off signals
    assign DMAC_1_PRDATA    = 32'd0;
    
    // DMA Status Tie-off signals
    assign DMAC_1_DMA_DONE  = {DMAC_1_CHANNEL_NUM{1'b0}};
    assign DMAC_1_DMA_ERR   = 1'b0;
`endif 
`endif
    
endmodule