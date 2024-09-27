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
    
    parameter         APB_ADDR_W    = 12,  // APB Address Width
    parameter         APB_DATA_W    = 32,  // APB Data Width
    
    // SoCDebug Parameters
    parameter         PROMPT_CHAR   = "]",
    parameter integer FT1248_WIDTH	= 1, // FTDI Interface 1,2,4 width supported
    parameter integer FT1248_CLKON	= 1, // FTDI clock always on - else quiet when no access
    parameter [7:0]   FT1248_CLKDIV	= 8'd03  // Clock Division Ratio
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
    
    // APB Slave Interface - USRT
    input  wire                     DEBUG_PSEL,      // Device select
    input  wire    [APB_ADDR_W-1:0] DEBUG_PADDR,     // Address
    input  wire                     DEBUG_PENABLE,   // Transfer control
    input  wire                     DEBUG_PWRITE,    // Write control
    input  wire    [APB_DATA_W-1:0] DEBUG_PWDATA,    // Write data
    output wire    [APB_DATA_W-1:0] DEBUG_PRDATA,    // Read data
    output wire                     DEBUG_PREADY,    // Device ready
    output wire                     DEBUG_PSLVERR,   // Device error response
    
    // FT1248 Interace - FT1248
    output wire                     FT_CLK_O,    // SCLK
    output wire                     FT_SSN_O,    // SS_N
    input  wire                     FT_MISO_I,   // MISO
    output wire  [FT1248_WIDTH-1:0] FT_MIOSIO_O, // MIOSIO tristate output when enabled
    output wire  [FT1248_WIDTH-1:0] FT_MIOSIO_E, // MIOSIO tristate output enable (active hi)
    output wire  [FT1248_WIDTH-1:0] FT_MIOSIO_Z, // MIOSIO tristate output enable (active lo)
    input  wire  [FT1248_WIDTH-1:0] FT_MIOSIO_I, // MIOSIO tristate input
    
    // GPIO interface
    output wire               [7:0] GPO8,
    input  wire               [7:0] GPI8
);
    
    //---------------------------
    // SoCDebug Instantiation
    //---------------------------
    socdebug_ahb #(
        .PROMPT_CHAR(PROMPT_CHAR),
        .FT1248_WIDTH(FT1248_WIDTH),
        .FT1248_CLKON(FT1248_CLKON),        
        .FT1248_CLKDIV(FT1248_CLKDIV)
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

        // APB Slave Interface - USRT
        .PCLK(SYS_PCLK),
        .PCLKG(SYS_PCLKG),
        .PRESETn(SYS_PRESETn),
        .PSEL_i(DEBUG_PSEL),
        .PADDR_i(DEBUG_PADDR[APB_ADDR_W-1:2]),
        .PENABLE_i(DEBUG_PENABLE),
        .PWRITE_i(DEBUG_PWRITE),
        .PWDATA_i(DEBUG_PWDATA),
        .PRDATA_o(DEBUG_PRDATA),
        .PREADY_o(DEBUG_PREADY),
        .PSLVERR_o(DEBUG_PSLVERR),

        // FT1248 Interace - FT1248
        .FT_CLK_O(FT_CLK_O),
        .FT_SSN_O(FT_SSN_O),
        .FT_MISO_I(FT_MISO_I),
        .FT_MIOSIO_O(FT_MIOSIO_O),
        .FT_MIOSIO_E(FT_MIOSIO_E),
        .FT_MIOSIO_Z(FT_MIOSIO_Z),
        .FT_MIOSIO_I(FT_MIOSIO_I),

        // GPIO interface
        .GPO8_o(GPO8),
        .GPI8_i(GPI8)
    );

endmodule