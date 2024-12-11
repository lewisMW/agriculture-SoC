//-----------------------------------------------------------------------------
// SoC Labs Accelerator Subsystem for SecWorks AES-128 Accelerator
// A joint work commissioned on behalf of SoC Labs; under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
// David Flynn    (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023; SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module accelerator_subsystem #(
  parameter SYS_ADDR_W = 32,
  parameter SYS_DATA_W = 32,
  parameter ACC_ADDR_W = 16,
  parameter IRQ_NUM    = 4
) (
  input  wire                      HCLK,       // Clock
  input  wire                      HRESETn,    // Reset

  // AHB connection to Initiator
  input  wire                      HSEL,
  input  wire   [SYS_ADDR_W-1:0]   HADDR,
  input  wire   [1:0]              HTRANS,
  input  wire   [2:0]              HSIZE,
  input  wire   [3:0]              HPROT,
  input  wire                      HWRITE,
  input  wire                      HREADY,
  input  wire   [SYS_DATA_W-1:0]   HWDATA,

  output wire                      HREADYOUT,
  output wire                      HRESP,
  output wire   [SYS_DATA_W-1:0]   HRDATA,

  // Data Request Signal to DMAC
  output wire   [1:0]              EXP_DRQ,
  input  wire   [1:0]              EXP_DLAST,
   // DMAC Stream interfaces
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
  input  wire                      EXP_STR_IN_0_TVALID,
  output wire                      EXP_STR_IN_0_TREADY,
  input  wire [SYS_DATA_W-1:0]     EXP_STR_IN_0_TDATA,
  input  wire [3:0]               EXP_STR_IN_0_TSTRB,
  input  wire                      EXP_STR_IN_0_TLAST,

  output wire                      EXP_STR_OUT_0_TVALID,
  input  wire                      EXP_STR_OUT_0_TREADY,
  output wire [SYS_DATA_W-1:0]     EXP_STR_OUT_0_TDATA,
  output wire [3:0]               EXP_STR_OUT_0_TSTRB,
  output wire                      EXP_STR_OUT_0_TLAST,
  input  wire                      EXP_STR_OUT_0_FLUSH,

  input  wire                      EXP_STR_IN_1_TVALID,
  output wire                      EXP_STR_IN_1_TREADY,
  input  wire [SYS_DATA_W-1:0]     EXP_STR_IN_1_TDATA,
  input  wire [3:0]               EXP_STR_IN_1_TSTRB,
  input  wire                      EXP_STR_IN_1_TLAST,

  output wire                      EXP_STR_OUT_1_TVALID,
  input  wire                      EXP_STR_OUT_1_TREADY,
  output wire [SYS_DATA_W-1:0]     EXP_STR_OUT_1_TDATA,
  output wire [3:0]               EXP_STR_OUT_1_TSTRB,
  output wire                      EXP_STR_OUT_1_TLAST,
  input  wire                      EXP_STR_OUT_1_FLUSH,
`endif 
`ifdef DMA350_STREAM_3

  input  wire                      EXP_STR_IN_2_TVALID,
  output wire                      EXP_STR_IN_2_TREADY,
  input  wire [SYS_DATA_W-1:0]     EXP_STR_IN_2_TDATA,
  input  wire [3:0]               EXP_STR_IN_2_TSTRB,
  input  wire                      EXP_STR_IN_2_TLAST,

  output wire                      EXP_STR_OUT_2_TVALID,
  input  wire                      EXP_STR_OUT_2_TREADY,
  output wire [SYS_DATA_W-1:0]     EXP_STR_OUT_2_TDATA,
  output wire [3:0]               EXP_STR_OUT_2_TSTRB,
  output wire                      EXP_STR_OUT_2_TLAST,
  input  wire                      EXP_STR_OUT_2_FLUSH,
`endif 
`endif 

  // Interrupts
  output wire   [IRQ_NUM-1:0]      EXP_IRQ
);
  
  //-------------------------------------------
  // Instantiate your accelerator/wrapper here
  //-------------------------------------------

// Default IRQ and DMA REQ
assign EXP_IRQ = 2'b00;
assign EXP_DRQ = 2'b00;

// Default DMA350 stream loopback
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
  assign EXP_STR_OUT_0_TVALID = EXP_STR_IN_0_TVALID;
  assign EXP_STR_IN_0_TREADY = EXP_STR_OUT_0_TREADY;
  assign EXP_STR_OUT_0_TDATA = EXP_STR_IN_0_TDATA;
  assign EXP_STR_OUT_0_TSTRB = EXP_STR_IN_0_TSTRB;
  assign EXP_STR_OUT_0_TLAST = EXP_STR_IN_0_TLAST;

  assign EXP_STR_OUT_1_TVALID = EXP_STR_IN_1_TVALID;
  assign EXP_STR_IN_1_TREADY = EXP_STR_OUT_1_TREADY;
  assign EXP_STR_OUT_1_TDATA = EXP_STR_IN_1_TDATA;
  assign EXP_STR_OUT_1_TSTRB = EXP_STR_IN_1_TSTRB;
  assign EXP_STR_OUT_1_TLAST = EXP_STR_IN_1_TLAST;
`endif 
`ifdef DMA350_STREAM_3

  assign EXP_STR_OUT_2_TVALID = EXP_STR_IN_2_TVALID;
  assign EXP_STR_IN_2_TREADY = EXP_STR_OUT_2_TREADY;
  assign EXP_STR_OUT_2_TDATA = EXP_STR_IN_2_TDATA;
  assign EXP_STR_OUT_2_TSTRB = EXP_STR_IN_2_TSTRB;
  assign EXP_STR_OUT_2_TLAST = EXP_STR_IN_2_TLAST;
`endif 
`endif 

endmodule
