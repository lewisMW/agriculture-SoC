//-----------------------------------------------------------------------------
// Nanosoc System ROM Table Region (SYSTABLE)
// - Region Mapped to: 0xF0000000-0xF0003FFF
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
// David Flynn    (d.w.flynn@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_region_systable #(
    parameter    SYS_ADDR_W    = 32,            // System Address Width
    parameter    SYS_DATA_W    = 32,            // System Data Width
    parameter    SYSTABLE_BASE = 32'hf000_0000, // Base Address for System ROM Table
    parameter    SOCLABS_JEPID = 7'd0,
    parameter    NANOSOC_PARTNUMBER = 12'd0,
    parameter    NANOSOC_REVISION   = 4'h0
)(
    input  wire                     HCLK,       // Clock

    // AHB connection to Initiator
    input  wire                     HSEL,             // AHB region select
    input  wire  [SYS_ADDR_W-1:0]   HADDR,            // AHB address
    input  wire            [ 2:0]   HBURST,           // AHB burst
    input  wire                     HMASTLOCK,        // AHB lock
    input  wire            [ 3:0]   HPROT,            // AHB prot
    input  wire            [ 2:0]   HSIZE,            // AHB size
    input  wire            [ 1:0]   HTRANS,           // AHB transfer
    input  wire  [SYS_DATA_W-1:0]   HWDATA,           // AHB write data
    input  wire                     HWRITE,           // AHB write
    input  wire                     HREADY,           // AHB ready
    output  wire [SYS_DATA_W-1:0]   HRDATA,           // AHB read-data
    output  wire                    HRESP,            // AHB response
    output  wire                    HREADYOUT         // AHB ready out
);

    // -------------------------------
    // System ROM Table
    // -------------------------------
    nanosoc_coresight_systable #(
        .BASE              (SYSTABLE_BASE),
        .JEPID             (SOCLABS_JEPID),
        .PARTNUMBER        (NANOSOC_PARTNUMBER),
        .REVISION          (NANOSOC_REVISION),
        // Entry 0 = Cortex-M0 Processor
        .ENTRY0BASEADDR    (32'hE00FF000),
        .ENTRY0PRESENT     (1'b1),
        // Entry 1 = CoreSight MTB-M0
        .ENTRY1BASEADDR    (32'hF0200000),
        .ENTRY1PRESENT     (0)
    ) u_system_rom_table (
        // ECO Revision
        .ECOREVNUM                         (4'h0),
        
        //Inputs
        .HCLK                              (HCLK),
        .HSEL                              (HSEL),
        .HADDR                             (HADDR),
        .HBURST                            (HBURST),
        .HMASTLOCK                         (HMASTLOCK),
        .HPROT                             (HPROT),
        .HSIZE                             (HSIZE),
        .HTRANS                            (HTRANS),
        .HWDATA                            (HWDATA),
        .HWRITE                            (HWRITE),
        .HREADY                            (HREADY),
        
        //Outputs
        .HRDATA                            (HRDATA),
        .HREADYOUT                         (HREADYOUT),
        .HRESP                             (HRESP)
    );
endmodule