//-----------------------------------------------------------------------------
// Nanosoc Expansion Region
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module nanosoc_region_exp #(
    parameter    SYS_ADDR_W      = 32,  // System Address Width
    parameter    SYS_DATA_W      = 32   // System Data Width
)(
    input  wire                  HCLK,       // Clock
    input  wire                  HRESETn,    // Reset

    // AHB Subortinate Port
    input  wire                   HSEL,
    input  wire  [SYS_ADDR_W-1:0] HADDR,
    input  wire             [1:0] HTRANS,
    input  wire             [2:0] HSIZE,
    input  wire             [3:0] HPROT,
    input  wire                   HWRITE,
    input  wire                   HREADY,
    input  wire  [SYS_DATA_W-1:0] HWDATA,

    output wire                   HREADYOUT,
    output wire                   HRESP,
    output wire  [SYS_DATA_W-1:0] HRDATA,
    // DMAC Stream interfaces
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
    input  wire                     EXP_STR_IN_0_TVALID,
    output wire                     EXP_STR_IN_0_TREADY,
    input  wire [SYS_DATA_W-1:0]    EXP_STR_IN_0_TDATA,
    input  wire [3:0]              EXP_STR_IN_0_TSTRB,
    input  wire                     EXP_STR_IN_0_TLAST,

    output wire                     EXP_STR_OUT_0_TVALID,
    input  wire                     EXP_STR_OUT_0_TREADY,
    output wire [SYS_DATA_W-1:0]    EXP_STR_OUT_0_TDATA,
    output wire [3:0]              EXP_STR_OUT_0_TSTRB,
    output wire                     EXP_STR_OUT_0_TLAST,
    input  wire                     EXP_STR_OUT_0_FLUSH,

    input  wire                     EXP_STR_IN_1_TVALID,
    output wire                     EXP_STR_IN_1_TREADY,
    input  wire [SYS_DATA_W-1:0]    EXP_STR_IN_1_TDATA,
    input  wire [3:0]              EXP_STR_IN_1_TSTRB,
    input  wire                     EXP_STR_IN_1_TLAST,

    output wire                     EXP_STR_OUT_1_TVALID,
    input  wire                     EXP_STR_OUT_1_TREADY,
    output wire [SYS_DATA_W-1:0]    EXP_STR_OUT_1_TDATA,
    output wire [3:0]              EXP_STR_OUT_1_TSTRB,
    output wire                     EXP_STR_OUT_1_TLAST,
    input  wire                     EXP_STR_OUT_1_FLUSH,
`endif 
`ifdef DMA350_STREAM_3

    input  wire                     EXP_STR_IN_2_TVALID,
    output wire                     EXP_STR_IN_2_TREADY,
    input  wire [SYS_DATA_W-1:0]    EXP_STR_IN_2_TDATA,
    input  wire [3:0]              EXP_STR_IN_2_TSTRB,
    input  wire                     EXP_STR_IN_2_TLAST,

    output wire                     EXP_STR_OUT_2_TVALID,
    input  wire                     EXP_STR_OUT_2_TREADY,
    output wire [SYS_DATA_W-1:0]    EXP_STR_OUT_2_TDATA,
    output wire [3:0]              EXP_STR_OUT_2_TSTRB,
    output wire                     EXP_STR_OUT_2_TLAST,
    input  wire                     EXP_STR_OUT_2_FLUSH,
`endif 
`endif 

    // Interrupt and DMAC Connections
    output wire             [3:0] EXP_IRQ,
    output wire             [1:0] EXP_DRQ,
    input  wire             [1:0] EXP_DLAST
);

`ifdef ACCELERATOR_SUBSYSTEM
    // Instantiate Accelerator Subsystem
    accelerator_subsystem #(
        .SYS_ADDR_W (SYS_ADDR_W),
        .SYS_DATA_W (SYS_DATA_W)
    ) u_ss_accelerator (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HPROT(HPROT),
        .HWRITE(HWRITE),
        .HREADY(HREADY),
        .HWDATA(HWDATA),
        .HREADYOUT(HREADYOUT),
        .HRESP(HRESP),
        .HRDATA(HRDATA),
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
        .EXP_STR_IN_0_TVALID(EXP_STR_IN_0_TVALID),
        .EXP_STR_IN_0_TREADY(EXP_STR_IN_0_TREADY),
        .EXP_STR_IN_0_TDATA(EXP_STR_IN_0_TDATA),
        .EXP_STR_IN_0_TSTRB(EXP_STR_IN_0_TSTRB),
        .EXP_STR_IN_0_TLAST(EXP_STR_IN_0_TLAST),

        .EXP_STR_OUT_0_TVALID(EXP_STR_OUT_0_TVALID),
        .EXP_STR_OUT_0_TREADY(EXP_STR_OUT_0_TREADY),
        .EXP_STR_OUT_0_TDATA(EXP_STR_OUT_0_TDATA),
        .EXP_STR_OUT_0_TSTRB(EXP_STR_OUT_0_TSTRB),
        .EXP_STR_OUT_0_TLAST(EXP_STR_OUT_0_TLAST),
        .EXP_STR_OUT_0_FLUSH(EXP_STR_OUT_0_FLUSH),

        .EXP_STR_IN_1_TVALID(EXP_STR_IN_1_TVALID),
        .EXP_STR_IN_1_TREADY(EXP_STR_IN_1_TREADY),
        .EXP_STR_IN_1_TDATA(EXP_STR_IN_1_TDATA),
        .EXP_STR_IN_1_TSTRB(EXP_STR_IN_1_TSTRB),
        .EXP_STR_IN_1_TLAST(EXP_STR_IN_1_TLAST),

        .EXP_STR_OUT_1_TVALID(EXP_STR_OUT_1_TVALID),
        .EXP_STR_OUT_1_TREADY(EXP_STR_OUT_1_TREADY),
        .EXP_STR_OUT_1_TDATA(EXP_STR_OUT_1_TDATA),
        .EXP_STR_OUT_1_TSTRB(EXP_STR_OUT_1_TSTRB),
        .EXP_STR_OUT_1_TLAST(EXP_STR_OUT_1_TLAST),
        .EXP_STR_OUT_1_FLUSH(EXP_STR_OUT_1_FLUSH),
`endif 
`ifdef DMA350_STREAM_3

        .EXP_STR_IN_2_TVALID(EXP_STR_IN_2_TVALID),
        .EXP_STR_IN_2_TREADY(EXP_STR_IN_2_TREADY),
        .EXP_STR_IN_2_TDATA(EXP_STR_IN_2_TDATA),
        .EXP_STR_IN_2_TSTRB(EXP_STR_IN_2_TSTRB),
        .EXP_STR_IN_2_TLAST(EXP_STR_IN_2_TLAST),

        .EXP_STR_OUT_2_TVALID(EXP_STR_OUT_2_TVALID),
        .EXP_STR_OUT_2_TREADY(EXP_STR_OUT_2_TREADY),
        .EXP_STR_OUT_2_TDATA(EXP_STR_OUT_2_TDATA),
        .EXP_STR_OUT_2_TSTRB(EXP_STR_OUT_2_TSTRB),
        .EXP_STR_OUT_2_TLAST(EXP_STR_OUT_2_TLAST),
        .EXP_STR_OUT_2_FLUSH(EXP_STR_OUT_2_FLUSH),
`endif 
`endif 

        .EXP_IRQ(EXP_IRQ),
        .EXP_DRQ(EXP_DRQ),
        .EXP_DLAST(EXP_DLAST)
    );
`else 
    // Default slave - if no expansion region
    cmsdk_ahb_default_slave u_ss_accelerator_default (
        .HCLK         (HCLK),
        .HRESETn      (HRESETn),
        .HSEL         (HSEL),
        .HTRANS       (HTRANS),
        .HREADY       (HREADY),
        .HREADYOUT    (HREADYOUT),
        .HRESP        (HRESP)
    );


    assign   HRDATA  = 32'heaedeaed; // Tie off Expansion Address Expansion Data
    assign   EXP_IRQ = 4'd0;
    assign   EXP_DRQ = 2'd0;
`endif

endmodule