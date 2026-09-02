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


wire [SYS_DATA_W-1:0] PWDATA;
wire PWRITE;
wire [SYS_DATA_W-1:0] PRDATA;
wire [ACC_ADDR_W-1:0] PADDR;
wire PREADY;
wire PSEL;
wire PENABLE;
wire PSLVERR;
wire [3:0] PSTRB;
wire [2:0] PPROT;
wire APBACTIVE;
  
  //-------------------------------------------
  // Instantiate your accelerator/wrapper here
  //-------------------------------------------
  // APB bridge <-> wrapper nets (declared before first use - strict Verilog)
  wire [SYS_DATA_W-1:0] PWDATA;
  wire PWRITE;
  wire [SYS_DATA_W-1:0] PRDATA;
  wire [ACC_ADDR_W-1:0] PADDR;
  wire PREADY;
  wire PSEL;
  wire PENABLE;
  wire PSLVERR;
  wire [3:0] PSTRB;
  wire [2:0] PPROT;
  wire APBACTIVE;

  cmsdk_ahb_to_apb  #(
  .ADDRWIDTH(SYS_ADDR_W),
  .REGISTER_RDATA(1),
  .REGISTER_WDATA(1)
) ahb_to_apb_bridge (
  /*input  wire*/.HCLK(HCLK),       // Main Clock
  /*input  wire*/.HRESETn(HRESETn), // Reset
  /*input  wire*/.PCLKEN(1),        // APB clock enable signal - If PCLK is same as HCLK, set PCLKEN to 1
// AHB Input
  /*input  wire*/.HSEL(HSEL),   // Device select
  /*input  wire*/.HADDR(HADDR),            // Address
  /*input  wire*/.HTRANS(HTRANS),          // Transfer control
  /*input  wire*/.HSIZE(HSIZE),            // Transfer size
  /*input  wire*/.HPROT(HPROT),            // Protection control
  /*input  wire*/.HWRITE(HWRITE),          // Write control
  /*input  wire*/.HREADY(HREADY),      // Transfer phase done
  /*input  wire*/.HWDATA(HWDATA),    // Write data
// AHB Output:
  /*output reg*/ .HREADYOUT(HREADYOUT),  // Device ready
  /*output wire*/.HRESP(HRESP),     // Device response
  /*output wire*/.HRDATA(HRDATA),    // Read data output

// APB Output:
  /*output wire*/.PADDR(PADDR),     // APB Address
  /*output wire*/.PENABLE(PENABLE),   // APB Enable
  /*output wire*/.PWRITE(PWRITE),    // APB Write
  /*output wire*/.PSTRB(PSTRB),     // APB Byte Strobe
  /*output wire*/.PPROT(PPROT),     // APB Prot
  /*output wire*/.PWDATA(PWDATA),    // APB write data
  /*output wire*/.PSEL(PSEL),      // APB Select
  /*output wire*/.APBACTIVE(APBACTIVE), // APB bus is active, for clock gating of APB bus
// APB Input:
  /*input  wire*/.PRDATA(PRDATA),    // Read data for each APB slave
  /*input  wire*/.PREADY(PREADY),    // Ready for each APB slave
  /*input  wire*/.PSLVERR(PSLVERR));  // Error state for each APB slave


// ---------------------------------------------------------------------------
// RTC support signals for the sensing peripheral (mirrors agriculture_soc.v).
// The nanosoc integration only exposes HCLK/HRESETn here, so the wrapper's
// CLK1HZ and nPOR must be generated locally — otherwise they float and the RTC
// never ticks or leaves power-on reset (autonomous polling + passthrough dead).
// ---------------------------------------------------------------------------

// Power-on reset for the RTC. Ideally this survives a warm HRESETn pulse (so RTC
// time persists across a system reset), but nanosoc only exposes HRESETn at this
// boundary, so we drive nPOR from HRESETn: the RTC comes out of power-on reset at
// boot and runs. (A POR that truly survives a warm reset needs a dedicated signal
// from the reset controller — a later refinement; not exercised by the tests.)
wire nPOR = HRESETn;

// ~1 Hz tick for the RTC, divided from HCLK. Reset from HRESETn so clk1hz_ctr /
// clk1hz_reg initialise cleanly (no X-propagation) and CLK1HZ starts toggling
// immediately after reset deasserts. CLK1HZ_DIV sets the half-period divide;
// this value is sim-friendly. For real hardware set it to (HCLK_hz / 2).
localparam [31:0] CLK1HZ_DIV = 32'd50;
reg  [31:0] clk1hz_ctr;
reg         clk1hz_reg;
always @(posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) begin
      clk1hz_ctr <= 32'd0;
      clk1hz_reg <= 1'b0;
   end else if (clk1hz_ctr >= (CLK1HZ_DIV - 32'd1)) begin
      clk1hz_ctr <= 32'd0;
      clk1hz_reg <= ~clk1hz_reg;
   end else begin
      clk1hz_ctr <= clk1hz_ctr + 32'd1;
   end
end
wire clk1hz = clk1hz_reg;

adc_apb_wrapper_rev2 #(
   .ADDR_WIDTH(ACC_ADDR_W),
   .DATA_WIDTH(SYS_DATA_W)
) sensor_wrapper (
   // Clock and Reset
   .PCLK(HCLK),
   .CLK1HZ(clk1hz),      // ~1 Hz RTC tick (divided from HCLK)
   .PRESETn(HRESETn),
   .nPOR(nPOR),          // power-on reset (survives warm HRESETn; keeps RTC time)
   // Address and Control
   .PSEL(PSEL),
   .PADDR(PADDR),
   .PENABLE(PENABLE),
   .PWRITE(PWRITE),
   // Data
   .PWDATA(PWDATA),
   // Other
   .APBACTIVE(APBACTIVE),
   .PPROT(PPROT),
   .PSTRB(PSTRB),
   // Handshake
   .PRDATA(PRDATA),
   .PREADY(PREADY),
   .PSLVERR(PSLVERR)
);



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
