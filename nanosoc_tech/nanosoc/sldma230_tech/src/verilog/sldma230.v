//-----------------------------------------------------------------------------
// SoCLabs SLDMA-230 - SoCLabs Arm PL230 DMA Controller Wrapper 
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sldma230 #(
    parameter    SYS_ADDR_W  = 32,  // System Address Width
    parameter    SYS_DATA_W  = 32,  // System Data Width
    parameter    CFG_ADDR_W  = 12,  // Configuration Port Address Width
    parameter    CHANNEL_NUM = 2    // Number of DMA Channels
)(
    // AHB Clocks and Resets 
    input wire                     HCLK,
    input wire                     HRESETn,

    // AHB Lite Port
    output wire   [SYS_ADDR_W-1:0] HADDR,       // Address bus
    output wire              [1:0] HTRANS,      // Transfer type
    output wire                    HWRITE,      // Transfer direction
    output wire              [2:0] HSIZE,       // Transfer size
    output wire              [2:0] HBURST,      // Burst type
    output wire              [3:0] HPROT,       // Protection control
    output wire   [SYS_DATA_W-1:0] HWDATA,      // Write data
    output wire                    HMASTLOCK,   // Locked Sequence
    input  wire   [SYS_DATA_W-1:0] HRDATA,      // Read data bus
    input  wire                    HREADY,      // HREADY feedback
    input  wire                    HRESP,       // Transfer response
    
    // APB Configurtation Port
    input  wire                    PCLKEN,      // APB clock enable
    input  wire                    PSEL,        // APB peripheral select
    input  wire                    PEN,         // APB transfer enable
    input  wire                    PWRITE,      // APB transfer direction
    input  wire   [CFG_ADDR_W-1:0] PADDR,       // APB address
    input  wire   [SYS_DATA_W-1:0] PWDATA,      // APB write data
    output wire   [SYS_DATA_W-1:0] PRDATA,      // APB read data
    
    // DMA Request and Status Port
    input  wire  [CHANNEL_NUM-1:0] DMA_REQ,     // DMA transfer request
    output wire  [CHANNEL_NUM-1:0] DMA_DONE,    // DMA transfer done
    output wire                    DMA_ERR      // DMA slave response not OK
);
    //----------------------------
    // Internal Wiring
    //----------------------------
    wire  [CHANNEL_NUM-1:0] WAITONREQ;
    assign                  WAITONREQ = {CHANNEL_NUM{1'b0}};
    
    //----------------------------
    // Module Instantiation
    //----------------------------
    pl230_udma u_pl230_udma (
        // Clock and Reset
        .hclk          (HCLK),
        .hresetn       (HRESETn),
        
        // DMA Control
        .dma_req       (DMA_REQ),
        .dma_sreq      (DMA_REQ),
        .dma_waitonreq (WAITONREQ),
        .dma_stall     (1'b0),
        .dma_active    (),
        .dma_done      (DMA_DONE),
        .dma_err       (DMA_ERR),
        
        // AHB-Lite Master Interface
        .hready        (HREADY),
        .hresp         (HRESP),
        .hrdata        (HRDATA),
        .htrans        (HTRANS),
        .hwrite        (HWRITE),
        .haddr         (HADDR),
        .hsize         (HSIZE),
        .hburst        (HBURST),
        .hmastlock     (HMASTLOCK),
        .hprot         (HPROT),
        .hwdata        (HWDATA),
        
        // APB Slave Interface
        .pclken        (PCLKEN),
        .psel          (PSEL),
        .pen           (PEN),
        .pwrite        (PWRITE),
        .paddr         (PADDR),
        .pwdata        (PWDATA),
        .prdata        (PRDATA)
    );
endmodule