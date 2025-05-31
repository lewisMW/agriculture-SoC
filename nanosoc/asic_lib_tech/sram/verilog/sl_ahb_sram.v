//-----------------------------------------------------------------------------
// SoCLabs FPGA SRAM Wrapper 
// - to be substitued with same name file in filelist when moving to ASIC
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sl_ahb_sram #(
    // System Parameters
    parameter SYS_DATA_W = 32,  // System Data Width
    parameter RAM_ADDR_W = 14,  // Size of SRAM
    parameter RAM_DATA_W = 32   // Data Width of RAM
)(
    `ifdef POWER_PINS
    inout  wire          VDD,
    inout  wire          VSS,
    `endif
    // --------------------------------------------------------------------------
    // Port Definitions
    // --------------------------------------------------------------------------
    input  wire                  HCLK,      // system bus clock
    input  wire                  HRESETn,   // system bus reset
    input  wire                  HSEL,      // AHB peripheral select
    input  wire                  HREADY,    // AHB ready input
    input  wire            [1:0] HTRANS,    // AHB transfer type
    input  wire            [2:0] HSIZE,     // AHB hsize
    input  wire                  HWRITE,    // AHB hwrite
    input  wire [RAM_ADDR_W-1:0] HADDR,     // AHB address bus
    input  wire [SYS_DATA_W-1:0] HWDATA,    // AHB write data bus
    output wire                  HREADYOUT, // AHB ready output to S->M mux
    output wire                  HRESP,     // AHB response
    output wire [SYS_DATA_W-1:0] HRDATA     // AHB read data bus
);
    
    // Internal Wiring
    wire  [RAM_ADDR_W-3:0] addr;
    wire  [RAM_DATA_W-1:0] wdata;
    wire  [RAM_DATA_W-1:0] rdata;
    wire             [3:0] wen;
    wire                   cs;
    
    // AHB to SRAM Conversion
    cmsdk_ahb_to_sram #(
        .AW (RAM_ADDR_W)
    ) u_ahb_to_sram (
        // AHB Inputs
        .HCLK       (HCLK),
        .HRESETn    (HRESETn),
        .HSEL       (HSEL),  
        .HADDR      (HADDR[RAM_ADDR_W-1:0]),
        .HTRANS     (HTRANS),
        .HSIZE      (HSIZE),
        .HWRITE     (HWRITE),
        .HWDATA     (HWDATA),
        .HREADY     (HREADY),

        // AHB Outputs
        .HREADYOUT  (HREADYOUT),
        .HRDATA     (HRDATA),
        .HRESP      (HRESP),

        // SRAM input
        .SRAMRDATA  (rdata),
        
        // SRAM Outputs
        .SRAMADDR   (addr),
        .SRAMWDATA  (wdata),
        .SRAMWEN    (wen),
        .SRAMCS     (cs)
   );

    // ASIC SRAM model
    sl_sram #(
        .AW (RAM_ADDR_W)
    ) u_sram (
        `ifdef POWER_PINS
        .VDD (VDD),
        .VSS  (VSS),
        `endif
        // SRAM Inputs
        .CLK        (HCLK),
        .ADDR       (addr),
        .WDATA      (wdata),
        .WREN       (wen),
        .CS         (cs),
        
        // SRAM Output
        .RDATA      (rdata)
    );
endmodule