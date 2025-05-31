//-----------------------------------------------------------------------------
// Nanosoc CPU Instruction Memory Region (IMEM) - SRAM
// - Region Mapped to: 0x20000000-0x2fffffff
// - Memory Exhibits Wrapping Behaviour
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_region_imem_0 #(
  parameter    SYS_ADDR_W        = 32,         // System Address Width
  parameter    SYS_DATA_W        = 32,         // System Data Width
  parameter    IMEM_RAM_ADDR_W   = 14,         // Width of IMEM RAM Address - Default 16KB
  parameter    IMEM_RAM_DATA_W   = 32,         // Width of IMEM RAM Data Bus - Default 32 bits
  parameter    IMEM_MEM_FPGA_IMG = "image.hex" // Image to Preload into SRAM - NOT USED
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

`ifdef IMEM_0_RAM_PRELOAD
  // ROM Instantiation
  sl_ahb_rom #(
    .SYS_DATA_W (SYS_DATA_W),
    .RAM_ADDR_W (IMEM_RAM_ADDR_W),
    .RAM_DATA_W (IMEM_RAM_DATA_W),
    .FILENAME   (IMEM_MEM_FPGA_IMG)
  ) u_imem_0 (
    // AHB Inputs
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .HSEL       (HSEL), 
    .HADDR      (HADDR [IMEM_RAM_ADDR_W-1:0]),
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
`else
  // SRAM Instantiation
  sl_ahb_sram #(
    .SYS_DATA_W (SYS_DATA_W),
    .RAM_ADDR_W (IMEM_RAM_ADDR_W),
    .RAM_DATA_W (IMEM_RAM_DATA_W)
  ) u_imem_0 (
    // AHB Inputs
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .HSEL       (HSEL), 
    .HADDR      (HADDR [IMEM_RAM_ADDR_W-1:0]),
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
`endif

    
endmodule