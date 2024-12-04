//-----------------------------------------------------------------------------
// NanoSoC Expansion Subsystem - Contains Expansion Region and 2x SRAMs
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
// Daniel Newbrook (d.newbrook@soton.ac.uk)
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module nanosoc_ss_expansion #(
    // System Parameters
    parameter    SYS_ADDR_W     = 32,  // System Address Width
    parameter    SYS_DATA_W     = 32,  // System Data Width
    
    // SRAM Low Parameters
    parameter    EXPRAM_L_RAM_ADDR_W   = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    EXPRAM_L_RAM_DATA_W   = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    
    // SRAM High Parameters
    parameter    EXPRAM_H_RAM_ADDR_W   = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    EXPRAM_H_RAM_DATA_W   = 32           // Width of IMEM RAM Data Bus - Default 32 bits
)(
    // System Clocks and Resets
    input  wire                   SYS_HCLK,
    input  wire                   SYS_HRESETn,
    
    // Expansion Region AHB Port
    input  wire                   EXP_HSEL,
    input  wire  [SYS_ADDR_W-1:0] EXP_HADDR,
    input  wire             [1:0] EXP_HTRANS,
    input  wire             [2:0] EXP_HSIZE,
    input  wire             [3:0] EXP_HPROT,
    input  wire                   EXP_HWRITE,
    input  wire                   EXP_HREADY,
    input  wire            [31:0] EXP_HWDATA,
            
    output wire                   EXP_HREADYOUT,
    output wire                   EXP_HRESP,
    output wire            [31:0] EXP_HRDATA,
    
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

    // SRAM Low Region AHB Port
    input  wire                   EXPRAM_L_HSEL,
    input  wire  [SYS_ADDR_W-1:0] EXPRAM_L_HADDR,
    input  wire             [1:0] EXPRAM_L_HTRANS,
    input  wire             [2:0] EXPRAM_L_HSIZE,
    input  wire             [3:0] EXPRAM_L_HPROT,
    input  wire                   EXPRAM_L_HWRITE,
    input  wire                   EXPRAM_L_HREADY,
    input  wire            [31:0] EXPRAM_L_HWDATA,
            
    output wire                   EXPRAM_L_HREADYOUT,
    output wire                   EXPRAM_L_HRESP,
    output wire            [31:0] EXPRAM_L_HRDATA,
    
    // SRAM High Region AHB Port
    input  wire                   EXPRAM_H_HSEL,
    input  wire  [SYS_ADDR_W-1:0] EXPRAM_H_HADDR,
    input  wire             [1:0] EXPRAM_H_HTRANS,
    input  wire             [2:0] EXPRAM_H_HSIZE,
    input  wire             [3:0] EXPRAM_H_HPROT,
    input  wire                   EXPRAM_H_HWRITE,
    input  wire                   EXPRAM_H_HREADY,
    input  wire            [31:0] EXPRAM_H_HWDATA,
            
    output wire                   EXPRAM_H_HREADYOUT,
    output wire                   EXPRAM_H_HRESP,
    output wire            [31:0] EXPRAM_H_HRDATA,
    
    // Interrupt and DMAC Connections
    output wire             [3:0] EXP_IRQ,
    output wire             [1:0] EXP_DRQ,
    input  wire             [1:0] EXP_DLAST
);

    // -------------------------------
    // Expansion Region Instantiation
    // -------------------------------
    nanosoc_region_exp #(
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W)
    ) u_region_exp (
        // Clock and Reset
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB Subordinate Port
        .HSEL(EXP_HSEL),
        .HADDR(EXP_HADDR),
        .HTRANS(EXP_HTRANS),
        .HSIZE(EXP_HSIZE),
        .HPROT(EXP_HPROT),
        .HWRITE(EXP_HWRITE),
        .HREADY(EXP_HREADY),
        .HWDATA(EXP_HWDATA),

        // AHB Master Interface
        .HREADYOUT(EXP_HREADYOUT),
        .HRESP(EXP_HRESP),
        .HRDATA(EXP_HRDATA),
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

        // Interrupt and DMAC Connections
        .EXP_IRQ(EXP_IRQ),
        .EXP_DRQ(EXP_DRQ),
        .EXP_DLAST(EXP_DLAST)
    );
    
    // ----------------------------------------
    // Expansion SRAM Low Region Instantiation
    // ----------------------------------------
    nanosoc_region_expram_l #(
        .SYS_ADDR_W          (SYS_ADDR_W),
        .SYS_DATA_W          (SYS_DATA_W),
        .EXPRAM_L_RAM_ADDR_W (EXPRAM_L_RAM_ADDR_W),
        .EXPRAM_L_RAM_DATA_W (EXPRAM_L_RAM_DATA_W)
    ) u_region_expram_l (
        // Clock and Reset
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB connection to Initiator
        .HSEL(EXPRAM_L_HSEL),
        .HADDR(EXPRAM_L_HADDR),
        .HTRANS(EXPRAM_L_HTRANS),
        .HSIZE(EXPRAM_L_HSIZE),
        .HPROT(EXPRAM_L_HPROT),
        .HWRITE(EXPRAM_L_HWRITE),
        .HREADY(EXPRAM_L_HREADY),
        .HWDATA(EXPRAM_L_HWDATA),

        // AHB Master Interface
        .HREADYOUT(EXPRAM_L_HREADYOUT),
        .HRESP(EXPRAM_L_HRESP),
        .HRDATA(EXPRAM_L_HRDATA)
    );
    
    // -----------------------------------------
    // Expansion SRAM High Region Instantiation
    // -----------------------------------------
    nanosoc_region_expram_h #(
        .SYS_ADDR_W          (SYS_ADDR_W),
        .SYS_DATA_W          (SYS_DATA_W),
        .EXPRAM_H_RAM_ADDR_W (EXPRAM_H_RAM_ADDR_W),
        .EXPRAM_H_RAM_DATA_W (EXPRAM_H_RAM_DATA_W)
    ) u_region_expram_h (
        // Clock and Reset
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB connection to Initiator
        .HSEL(EXPRAM_H_HSEL),
        .HADDR(EXPRAM_H_HADDR),
        .HTRANS(EXPRAM_H_HTRANS),
        .HSIZE(EXPRAM_H_HSIZE),
        .HPROT(EXPRAM_H_HPROT),
        .HWRITE(EXPRAM_H_HWRITE),
        .HREADY(EXPRAM_H_HREADY),
        .HWDATA(EXPRAM_H_HWDATA),

        // AHB Master Interface
        .HREADYOUT(EXPRAM_H_HREADYOUT),
        .HRESP(EXPRAM_H_HRESP),
        .HRDATA(EXPRAM_H_HRDATA)
    );
endmodule