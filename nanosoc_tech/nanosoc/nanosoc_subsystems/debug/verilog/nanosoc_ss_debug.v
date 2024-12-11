//-----------------------------------------------------------------------------
// NanoSoC Debug Subsystem - Contains SoCDebug Module
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_ss_debug #(
    // System Parameters
    parameter         SYS_ADDR_W    = 32,  // System Address Width
    parameter         SYS_DATA_W    = 32,  // System Data Width
    // SoCDebug Parameters
    parameter         PROMPT_CHAR   = "]"
)(  
    // System Clocks and Resets
    input  wire                     SYS_HCLK,
    input  wire                     SYS_HRESETn,
    input  wire                     SYS_PCLK,   
    input  wire                     SYS_PCLKG,  
    input  wire                     SYS_PRESETn,
    
    // AHB-lite Master Interface - ADP
    output wire    [SYS_ADDR_W-1:0] DEBUG_HADDR,
    output wire              [ 2:0] DEBUG_HBURST,
    output wire                     DEBUG_HMASTLOCK,
    output wire              [ 3:0] DEBUG_HPROT,
    output wire              [ 2:0] DEBUG_HSIZE,
    output wire              [ 1:0] DEBUG_HTRANS,
    output wire    [SYS_DATA_W-1:0] DEBUG_HWDATA,
    output wire                     DEBUG_HWRITE,
    input  wire    [SYS_DATA_W-1:0] DEBUG_HRDATA,
    input  wire                     DEBUG_HREADY,
    input  wire                     DEBUG_HRESP,

    // USRT0 TXD axi byte stream
    output wire                     ADP_RXD_TVALID_o,
    output wire            [ 7:0]   ADP_RXD_TDATA_o ,
    input  wire                     ADP_RXD_TREADY_i,
      // USRT0 RXD axi byte stream
    input  wire                     ADP_TXD_TVALID_i,
    input  wire             [ 7:0]  ADP_TXD_TDATA_i ,
    output wire                     ADP_TXD_TREADY_o,
    
    // USRT0 TXD axi byte stream
    output wire                     STD_RXD_TVALID_o,
    output wire            [ 7:0]   STD_RXD_TDATA_o ,
    input  wire                     STD_RXD_TREADY_i,
      // USRT0 RXD axi byte stream
    input  wire                     STD_TXD_TVALID_i,
    input  wire             [ 7:0]  STD_TXD_TDATA_i ,
    output wire                     STD_TXD_TREADY_o,

    // GPIO interface
    output wire               [7:0] GPO8,
    input  wire               [7:0] GPI8
);

    //---------------------------
    // SoCDebug Instantiation
    //---------------------------
    socdebug_ahb #(
        .PROMPT_CHAR(PROMPT_CHAR)
    ) u_socdebug (
        // AHB-lite Master Interface - ADP
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),
        .HADDR32_o(DEBUG_HADDR),
        .HBURST3_o(DEBUG_HBURST),
        .HMASTLOCK_o(DEBUG_HMASTLOCK),
        .HPROT4_o(DEBUG_HPROT),
        .HSIZE3_o(DEBUG_HSIZE),
        .HTRANS2_o(DEBUG_HTRANS),
        .HWDATA32_o(DEBUG_HWDATA),
        .HWRITE_o(DEBUG_HWRITE),
        .HRDATA32_i(DEBUG_HRDATA),
        .HREADY_i(DEBUG_HREADY),
        .HRESP_i(DEBUG_HRESP),

        .ADP_RXD_TVALID_o(ADP_RXD_TVALID_o),
        .ADP_RXD_TDATA_o( ADP_RXD_TDATA_o ),
        .ADP_RXD_TREADY_i(ADP_RXD_TREADY_i),
        .ADP_TXD_TVALID_i(ADP_TXD_TVALID_i),
        .ADP_TXD_TDATA_i (ADP_TXD_TDATA_i ),
        .ADP_TXD_TREADY_o(ADP_TXD_TREADY_o),

        .STD_RXD_TVALID_o(STD_RXD_TVALID_o),
        .STD_RXD_TDATA_o( STD_RXD_TDATA_o ),
        .STD_RXD_TREADY_i(STD_RXD_TREADY_i),
        .STD_TXD_TVALID_i(STD_TXD_TVALID_i),
        .STD_TXD_TDATA_i (STD_TXD_TDATA_i ),
        .STD_TXD_TREADY_o(STD_TXD_TREADY_o),

        // GPIO interface
        .GPO8_o(GPO8),
        .GPI8_i(GPI8)
    );

endmodule
