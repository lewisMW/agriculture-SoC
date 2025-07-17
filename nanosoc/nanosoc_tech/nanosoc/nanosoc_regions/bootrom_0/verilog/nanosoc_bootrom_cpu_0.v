//-----------------------------------------------------------------------------
// NanoSoC CPU 0 Bootrom
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_bootrom_cpu_0 #(
    parameter    SYS_DATA_W     = 32,  // System Data Width
    parameter    BOOTROM_ADDR_W = 10   // Size of Bootrom (Based on Address Width) - Default 1KB
)(
  input  wire                      HCLK,      // Clock
  input  wire                      HSEL,      // Device select
  input  wire [BOOTROM_ADDR_W-1:0] HADDR,     // Address
  input  wire                [1:0] HTRANS,    // Transfer control
  input  wire                [2:0] HSIZE,     // Transfer size
  input  wire                      HWRITE,    // Write control
  input  wire     [SYS_DATA_W-1:0] HWDATA,    // Write data - not used
  input  wire                      HREADY,    // Transfer phase done
  output wire                      HREADYOUT, // Device ready
  output wire     [SYS_DATA_W-1:0] HRDATA,    // Read data output
  output wire                      HRESP      // Device response (always OKAY)
);
  //------------------------
  // Internal Wiring
  //------------------------
  wire   EN;
  assign EN = HSEL & HTRANS[1] & HREADY & !HWRITE;
  
  //------------------------
  // Bootrom Instantiation
  //------------------------
  bootrom u_bootrom (
    .CLK     (HCLK),
    .EN      (EN),
    .W_ADDR  (HADDR[BOOTROM_ADDR_W-1:2]),
    .RDATA   (HRDATA)
  );
  
  // Output Signal Response Constant other than Data
  assign HREADYOUT = 1'b1;
  assign HRESP = 1'b0;

endmodule
