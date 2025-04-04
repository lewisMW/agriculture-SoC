// ************************************************************
// Design : Hell Fire SoC Top 
// Author: Srimanth Tenneti 
// Date: 27th August 2023 
// Version : 0.02
// ************************************************************

module agriculture_soc #(
   parameter W = 32,
   parameter W_APB_ADDR = 16
   )
   (
   // Global Clock and Reset 
   input wire clk, 
   input wire reset, 

   // LED Out 
   output wire [3:0] LED

   // Debug 
   // input wire  TDI, 
   // input wire  TCK, 
   // inout wire  TMS, 
   // inout wire TDO
);

// Clocking 
wire fclk; // Free Running Clock 
assign fclk = clk; 

wire resetn = reset; 

// MUX2CPU Response and Data
wire mux2cpu_hready; 
wire [W - 1 : 0] mux2cpu_hrdata; 

// Mux Select 
wire [1:0] muxsel; 

// Peripheral Select 
wire hsel_memory; 
wire hsel_gpio; 
wire hsel_nomap;
wire hsel_ahb_apb_bridge; 

// Peripheral HREADY 
wire hready_memory; 
wire hready_gpio; 
wire hready_ahb_apb_bridge; 
wire hready_nomap; 

// Peripheral Data Connections 
wire [W - 1  : 0] hrdata_memory; 
wire [W - 1  : 0] hrdata_gpio; 
wire [W - 1  : 0] hrdata_ahb_apb_bridge; 
wire [W - 1  : 0] hrdata_nomap; 

// Side Bank Signals 
wire lockup; 
wire lockup_reset_req; 
wire sys_reset_req; 
wire txev; 
wire sleeping; 
wire [31:0] irq; 

// Interrupt Signals 
assign irq = 0; 

// Reset Sync 
reg [4:0] reset_sync_reg; 

always @ (posedge fclk or negedge resetn) begin
   if (~resetn) begin
      reset_sync_reg <= 0; 
   end
   else 
     begin
       reset_sync_reg[3:0] <= {reset_sync_reg[2:0], 1'b1}; 
       reset_sync_reg[4] <= reset_sync_reg[2] & ~(sys_reset_req); 
     end
end

// CPU AHB-Lite Bus 

wire hresetn = reset_sync_reg[4]; 
wire hmastlock_soc; 
wire hwrite_soc; 

wire [1:0] htrans_soc; 

wire [2:0] hsize_soc; 
wire [2:0] hburst_soc; 

wire [3:0] hprot_soc; 

wire [W - 1 : 0] haddr_soc; 
wire [W - 1 : 0] hwdata_soc; 

wire [1:0] hresp_soc = 2'b00; // No Error Response
wire exeresp_soc = 0; 


wire          dbg_tdo;             
wire          dbg_tdo_nen; 

wire          dbg_swdo;                 
wire          dbg_swdo_en; 

wire          dbg_jtag_nsw;             
wire          dbg_swo;  

wire          tdo_enable     = !dbg_tdo_nen | !dbg_jtag_nsw;

wire          tdo_tms        = dbg_jtag_nsw         ? dbg_tdo    : dbg_swo;
assign        TMS            = dbg_swdo_en          ? dbg_swdo   : 1'bz;
assign        TDO            = tdo_enable           ? tdo_tms    : 1'bz;


// Debug Power Controller 
wire cdbgpwrupack, cdbgpwrupreq; 
assign cdbgpwrupack = cdbgpwrupreq; 

// SRAM Connections
wire [15:0]sram_addr;
wire [3:0]sram_w_en;
wire [31:0]sram_w_data;
wire [31:0]sram_r_data;
wire sram_cs;

CORTEXM0INTEGRATION cpu0(

     .FCLK(fclk),
     .SCLK(fclk),
     .HCLK(fclk),
     .DCLK(fclk),

     .PORESETn(reset_sync_reg[2]),
     .DBGRESETn(reset_sync_reg[3]),
     .HRESETn(hresetn),

     .SWCLKTCK(TCK),
     .nTRST(1'b1),

     // AHB-LITE MASTER PORT
     .HADDR(haddr_soc),
     .HBURST(hburst_soc),
     .HMASTLOCK(hmastlock_soc),
     .HPROT(hprot_soc),
     .HSIZE(hsize_soc),
     .HTRANS(htrans_soc),
     .HWDATA(hwdata_soc),
     .HWRITE(hwrite_soc),
     .HRDATA(mux2cpu_hrdata),
     .HREADY(mux2cpu_hready),
     .HRESP(hresp_soc),
     .HMASTER(),

     // CODE SEQUENTIALITY AND SPECULATION
     .CODENSEQ(),
     .CODEHINTDE(),
     .SPECHTRANS(),
     
     // DEBUG
     .SWDITMS(TMS),
     .TDI(TDI),
     .SWDO(dbg_swdo),
     .SWDOEN(dbg_swdo_en),
     .TDO(dbg_tdo),
     .nTDOEN(dbg_tdo_nen),
     .DBGRESTART(1'b0),
     .DBGRESTARTED(),
     .EDBGRQ(1'b0),
     .HALTED(),

     // MISC
     .NMI(1'b0),
     .IRQ(irq),
     .TXEV(),
     .RXEV(1'b0),
     .LOCKUP(lockup),
     .SYSRESETREQ(sys_reset_req),
     .STCALIB({1'b1, 1'b0, 24'h007A11F}),
     .STCLKEN(1'b0),
     .IRQLATENCY(8'h00),
     .ECOREVNUM(28'h0), 

     // POWER MANAGEMENT
     .GATEHCLK(),
     .SLEEPING(),
     .SLEEPDEEP(),
     .WAKEUP(),
     .WICSENSE(),
     .SLEEPHOLDREQn(1'b1),
     .SLEEPHOLDACKn(),
     .WICENREQ(1'b0),
     .WICENACK(),
     .CDBGPWRUPREQ(cdbgpwrupreq),
     .CDBGPWRUPACK(cdbgpwrupack),
     // SCAN IO
     .SE(1'b0),
     .RSTBYPASS(1'b0)
);

// TODO: connect the correct peripherals
AHBDCD Peripheral_Decoder (
    // Input Address
   .HADDR(haddr_soc), 
    // Peripheral Select 
   .hsel_s0(hsel_memory), 
   .hsel_s1(hsel_gpio), 
   .hsel_s2(hsel_ahb_apb_bridge), 
   .hsel_s3(),
   .hsel_nomap(hsel_nomap),
    // Mux Select  
   .mux_sel_out(muxsel)  
); 

// TODO: connect the correct peripherals
AHBMUX Peripheral_MUX(
  // Clock and Reset 
  . HCLK(fclk), 
  . HRESETn(hresetn), 
  // Mux Select Genenrated by decoder 
  .mux_sel(muxsel), 
  // HRDATA Slaves 
  .hrdata_s0(hrdata_memory), 
  .hrdata_s1(hrdata_gpio), 
  .hrdata_s2(hrdata_ahb_apb_bridge), 
  .hrdata_s3(), 
  .hrdata_nomap(hrdata_nomap), 
  // HREADY Slaves 
  . hready_s0(hready_memory), 
  . hready_s1(hready_gpio), 
  . hready_s2(hready_ahb_apb_bridge), 
  . hready_s3(), 
  . hready_nomap(hready_nomap), 
  // To Master 
  .hrdata_out(mux2cpu_hrdata), 
  .hready_out(mux2cpu_hready)

); 

// ***************************************************
//     AHB Peripherals 
// ***************************************************

// TODO: Reconfigure SRAM for CMDSK SRAM IP

// SRAM interface - Device0
cmsdk_ahb_to_sram SRAM_Interface (
   // Clock and Reset
   .HCLK(fclk),
   .HRESETn(hresetn),

   // AHB Control Signals
   .HSEL(hsel_memory),
   .HREADY(mux2cpu_hready),
   .HTRANS(htrans_soc),
   .HSIZE(hsize_soc),
   .HWRITE(hwrite_soc),
   .HADDR(haddr_soc),
   .HWDATA(hwdata_soc),
   .HREADYOUT(hready_memory),
   .HRESP(hresp_soc),
   .HRDATA(hrdata_memory),
   //  .HBURST(hburst_soc),   //TODO: this is not present in the IP interface

   // SRAM Connections
   .SRAMRDATA(sram_r_data),
   .SRAMADDR(sram_addr),
   .SRAMWEN(sram_w_en),
   .SRAMWDATA(sram_w_data),
   .SRAMCS(sram_cs)
); 

// Mock SRAM
cmsdk_fpga_sram #(.MEMFILE("code.hex")) SRAM_Bank0 (
   // Clock and Reset
   .CLK(fclk),
   // .RESETn(hresetn),    // This module doesn't have a reset
   // Address and Control
   .ADDR(sram_addr),
   .WREN(sram_w_en),
   .CS(sram_cs),
   // Data
   .WDATA(sram_w_data),
   .RDATA(sram_r_data)
);

// GPIO Bank - Device1
cmsdk_ahb_gpio #(
   .ALTERNATE_FUNC_MASK     (16'h0000), // No pin muxing for Port #0
   .ALTERNATE_FUNC_DEFAULT  (16'h0000), // All pins default to GPIO
   .BE                      (1)         // 1: Big endian 0: little endian
   )
   u_ahb_to_gpio  (
   // AHB Inputs
   .HCLK         (fclk),
   .HRESETn      (hresetn),
   .FCLK         (fclk),
   .HSEL         (hsel_gpio),
   .HREADY       (mux2cpu_hready),
   .HTRANS       (htrans_soc),
   .HSIZE        (hsize_soc),
   .HWRITE       (hwrite_soc),
   .HADDR        (haddr_soc),
   .HWDATA       (hwdata_soc),

   // AHB Outputs
   .HREADYOUT    (hready_gpio),
   .HRESP        (),
   .HRDATA       (hrdata_gpio),

   .ECOREVNUM    (),// Engineering-change-order revision bits

   // TODO: connect to ADC?
   .PORTIN       (),   // GPIO Interface inputs
   .PORTOUT      (),  // GPIO Interface outputs
   .PORTEN       (),
   .PORTFUNC     (), // Alternate function control

   .GPIOINT      (),  // Interrupt outputs
   .COMBINT      ()
);

cmsdk_ahb_to_apb  #(
  .ADDRWIDTH(W_APB_ADDR),
  .REGISTER_RDATA(1),
  .REGISTER_WDATA(1)
) ahb_to_apb_bridge (
  /*input  wire*/.HCLK(fclk),       // Main Clock
  /*input  wire*/.HRESETn(hresetn), // Reset
  /*input  wire*/.PCLKEN(1),        // APB clock enable signal - If PCLK is same as HCLK, set PCLKEN to 1
  /*input  wire*/.HSEL(hsel_ahb_apb_bridge),   // Device select
  /*input  wire*/.HADDR(haddr_soc),            // Address
  /*input  wire*/.HTRANS(htrans_soc),          // Transfer control
  /*input  wire*/.HSIZE(hsize_soc),            // Transfer size
  /*input  wire*/.HPROT(hprot_soc),            // Protection control
  /*input  wire*/.HWRITE(hwrite_soc),          // Write control
  /*input  wire*/.HREADY(mux2cpu_hready),      // Transfer phase done
  /*input  wire*/.HWDATA(hwdata_soc),    // Write data
  /*output reg*/ .HREADYOUT(hready_ahb_apb_bridge),  // Device ready
  /*output wire*/.HRDATA(hrdata_ahb_apb_bridge),    // Read data output
  /*output wire*/.HRESP(),     // Device response
// APB Output:
  /*output wire*/.PADDR(apb_addr),     // APB Address
  /*output wire*/.PENABLE(apb_wrapper_en),   // APB Enable
  /*output wire*/.PWRITE(apb_wen),    // APB Write
  /*output wire*/.PSTRB(),     // APB Byte Strobe
  /*output wire*/.PPROT(),     // APB Prot
  /*output wire*/.PWDATA(apb_wdata),    // APB write data
  /*output wire*/.PSEL(apb_wrapper_sel),      // APB Select
  /*output wire*/.APBACTIVE(), // APB bus is active, for clock gating of APB bus
// APB Input:
  /*input  wire*/.PRDATA(apb_rdata),    // Read data for each APB slave
  /*input  wire*/.PREADY(apb_wrapper_ready),    // Ready for each APB slave
  /*input  wire*/.PSLVERR());  // Error state for each APB slave

wire [W-1:0] apb_wdata;
wire apb_wen;
wire [W-1:0] apb_rdata;
wire [W_APB_ADDR-1:0] apb_addr;
wire apb_wrapper_ready;
wire apb_wrapper_sel;
wire apb_wrapper_en;

adc_apb_wrapper #(
   .ADDR_WIDTH(W_APB_ADDR),
   .DATA_WIDTH(W)
) sensor_wrapper (
   // Clock and Reset
   .PCLK(fclk),
   .PRESETn(hresetn),
   // Address and Control
   .PSEL(apb_wrapper_sel),
   .PADDR(apb_addr),
   .PENABLE(apb_wrapper_en),
   .PWRITE(apb_wen),
   // Data
   .PWDATA(apb_wdata),
   // Handshake
   .PRDATA(apb_rdata),
   .PREADY(apb_wrapper_ready),
   .PSLVERR()
);

endmodule
