//-----------------------------------------------------------------------------
// Nanosoc CPU Data Memory Region (DMEM)
// - Region Mapped to: 0x30000000-0x3fffffff
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_region_dmem_0 #(
    parameter    SYS_ADDR_W      = 32, // System Address Width
    parameter    SYS_DATA_W      = 32, // System Data Width
    parameter    DMEM_RAM_ADDR_W = 14, // Width of DMEM RAM Address - Default 16KB
    parameter    DMEM_RAM_DATA_W = 32  // Width of DMEM RAM Data Bus - Default 32 bits
  )(
    input  wire                   HCLK,    
    input  wire                   HRESETn, 

    // AHB connection to Initiator
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
    output wire  [SYS_DATA_W-1:0] HRDATA
  );

    // SRAM Instantiation
    sl_ahb_sram #(
        .SYS_DATA_W (SYS_DATA_W),
        .RAM_DATA_W (DMEM_RAM_DATA_W),
        .RAM_ADDR_W (DMEM_RAM_ADDR_W)
    ) u_dmem_0 (
        // AHB Inputs
        .HCLK       (HCLK),
        .HRESETn    (HRESETn),
        .HSEL       (HSEL), 
        .HADDR      (HADDR [DMEM_RAM_ADDR_W-1:0]),
        .HTRANS     (HTRANS),
        .HSIZE      (HSIZE),
        .HWRITE     (HWRITE),
        .HWDATA     (HWDATA),
        .HREADY     (HREADY),

        // AHB Outputs
        .HREADYOUT  (HREADYOUT),
        .HRDATA     (HRDATA),
        .HRESP      (HRESP)
    );
    
endmodule