//-----------------------------------------------------------------------------
// Nanosoc System Peripheral Region (SYSIO)
// - Region Mapped to: 0x40000000-0x4fffffff
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
// David Flynn    (d.w.flynn@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module nanosoc_region_sysio #(
    parameter    SYS_ADDR_W=32,  // System Address Width
    parameter    SYS_DATA_W=32,  // System Data Width
    parameter    APB_ADDR_W=12,  // APB Peripheral Address Width
    parameter    APB_DATA_W=32   // APB Peripheral Data Width
  )(
    input  wire                   FCLK,             // Free-running system clock
    input  wire                   PORESETn,         // Power-On-Reset reset (active-low)
    
    // AHB interface
    input  wire                   HCLK,             // AHB clock
    input  wire                   HRESETn,          // AHB reset (active-low)
    input  wire                   HSEL,             // AHB region select
    input  wire  [SYS_ADDR_W-1:0] HADDR,            // AHB address
    input  wire            [ 2:0] HBURST,           // AHB burst
    input  wire                   HMASTLOCK,        // AHB lock
    input  wire            [ 3:0] HPROT,            // AHB prot
    input  wire            [ 2:0] HSIZE,            // AHB size
    input  wire            [ 1:0] HTRANS,           // AHB transfer
    input  wire  [SYS_DATA_W-1:0] HWDATA,           // AHB write data
    input  wire                   HWRITE,           // AHB write
    input  wire                   HREADY,           // AHB ready
    output  wire [SYS_DATA_W-1:0] HRDATA,           // AHB read-data
    output  wire                  HRESP,            // AHB response
    output  wire                  HREADYOUT,        // AHB ready out
    
    // APB clocking control
    input  wire                   PCLK,             // Peripheral clock
    input  wire                   PCLKG,            // Gated Peripheral bus clock
    input  wire                   PRESETn,          // Peripheral system and APB reset
    input  wire                   PCLKEN,           // Clock divide control for AHB to APB bridge
    
    // APB external Slave Interface
    output wire                   exp12_psel,
    output wire                   exp13_psel,
    output wire                   exp14_psel,
    output wire                   exp15_psel,
    output wire                   exp_penable,
    output wire                   exp_pwrite,
    output wire  [APB_ADDR_W-1:0] exp_paddr,
    output wire  [APB_DATA_W-1:0] exp_pwdata,
    input  wire  [APB_DATA_W-1:0] exp12_prdata,
    input  wire                   exp12_pready,
    input  wire                   exp12_pslverr,
    input  wire  [APB_DATA_W-1:0] exp13_prdata,
    input  wire                   exp13_pready,
    input  wire                   exp13_pslverr,
    input  wire  [APB_DATA_W-1:0] exp14_prdata,
    input  wire                   exp14_pready,
    input  wire                   exp14_pslverr,
    input  wire  [APB_DATA_W-1:0] exp15_prdata,
    input  wire                   exp15_pready,
    input  wire                   exp15_pslverr,

    // CPU sideband signalling
    output wire                 SYS_NMI,          // watchdog_interrupt;
    output wire         [31:0]  SYS_APB_IRQ,      // apbsubsys_interrupt;
    output wire         [15:0]  SYS_GPIO0_IRQ,    // GPIO 0 irqs
    output wire         [15:0]  SYS_GPIO1_IRQ,    // GPIO 0 irqs
    
    // CPU power/reset control
    output wire                 REMAP_CTRL,       // REMAP control bit
    output wire                 APBACTIVE,        // APB bus active (for clock gating of PCLKG)
    input  wire                 SYSRESETREQ,      // Processor control - system reset request
    output wire                 WDOGRESETREQ,     // Watchdog reset request
    input  wire                 LOCKUP,           // Processor status - Locked up
    output wire                 LOCKUPRESET,      // System Controller cfg - reset if lockup
    output wire                 PMUENABLE,        // System Controller cfg - Enable PMU

    // IO signalling
    input  wire                 uart0_rxd,        // Uart 0 receive data
    output wire                 uart0_txd,        // Uart 0 transmit data
    output wire                 uart0_txen,       // Uart 0 transmit data enable
    input  wire                 uart1_rxd,        // Uart 1 receive data
    output wire                 uart1_txd,        // Uart 1 transmit data
    output wire                 uart1_txen,       // Uart 1 transmit data enable
    input  wire                 uart2_rxd,        // Uart 2 receive data
    output wire                 uart2_txd,        // Uart 2 transmit data
    output wire                 uart2_txen,       // Uart 2 transmit data enable
    input  wire                 timer0_extin,     // Timer 0 external input
    input  wire                 timer1_extin,     // Timer 1 external input

    // GPIO
    input  wire          [15:0] p0_in,            // GPIO 0 inputs
    output wire          [15:0] p0_out,           // GPIO 0 outputs
    output wire          [15:0] p0_outen,         // GPIO 0 output enables
    output wire          [15:0] p0_altfunc,       // GPIO 0 alternate function (pin mux)
    input  wire          [15:0] p1_in,            // GPIO 1 inputs
    output wire          [15:0] p1_out,           // GPIO 1 outputs
    output wire          [15:0] p1_outen,         // GPIO 1 output enables
    output wire          [15:0] p1_altfunc        // GPIO 1 alternate function (pin mux)
  );

  // Sysctrl base address
  localparam BASEADDR_APBSS       = 32'h4000_0000; // GPIO0 peripheral base address
  localparam BASEADDR_GPIO0       = 32'h4001_0000; // GPIO0 peripheral base address
  localparam BASEADDR_GPIO1       = 32'h4001_1000; // GPIO1 peripheral base address
  localparam BASEADDR_SYSCTRL     = 32'h4001_f000; // Sysctrl peripheral base address
  localparam BASEADDR_ADC         = 32'h4002_0000; // ADC Peripheral base address
  localparam BE                   = 0;
  
   // ------------------------------------------------------------
   // Local wires
   // ------------------------------------------------------------

  wire                        defslv_hsel;   // AHB default slave signals
  wire                        defslv_hreadyout;
  wire     [SYS_DATA_W-1:0]   defslv_hrdata;
  wire                        defslv_hresp;

  wire                        apbsys_hsel;  // APB subsystem AHB interface signals
  wire                        apbsys_hreadyout;
  wire     [SYS_DATA_W-1:0]   apbsys_hrdata;
  wire                        apbsys_hresp;

  wire                        gpio0_hsel;   // AHB GPIO bus interface signals
  wire                        gpio0_hreadyout;
  wire     [SYS_DATA_W-1:0]   gpio0_hrdata;
  wire                        gpio0_hresp;

  wire                        gpio1_hsel;   // AHB GPIO bus interface signals
  wire                        gpio1_hreadyout;
  wire     [SYS_DATA_W-1:0]   gpio1_hrdata;
  wire                        gpio1_hresp;

  wire                        sysctrl_hsel;  // System control bus interface signals
  wire                        sysctrl_hreadyout;
  wire     [SYS_DATA_W-1:0]   sysctrl_hrdata;
  wire                        sysctrl_hresp;

  wire                        adcsys_hsel;  // ADC subsystem AHB interface signals
  wire                        adcsys_hreadyout;
  wire     [SYS_DATA_W-1:0]   adcsys_hrdata;
  wire                        adcsys_hresp;

  wire                        pvtsys_hsel;  // ADC subsystem AHB interface signals
  wire                        pvtsys_hreadyout;
  wire     [SYS_DATA_W-1:0]   pvtsys_hrdata;
  wire                        pvtsys_hresp;


  // AHB address decode
  nanosoc_sysio_decode #(
     .BASEADDR_APBSS       (BASEADDR_APBSS),
     .BASEADDR_GPIO0       (BASEADDR_GPIO0),
     .BASEADDR_GPIO1       (BASEADDR_GPIO1),
     .BASEADDR_SYSCTRL     (BASEADDR_SYSCTRL),
     .BASEADDR_ADC         (BASEADDR_ADC)
  ) u_addr_decode (
    // System Address
    .hsel         (HSEL),
    .haddr        (HADDR),
    .apbsys_hsel  (apbsys_hsel),
    .gpio0_hsel   (gpio0_hsel),
    .gpio1_hsel   (gpio1_hsel),
    .sysctrl_hsel (sysctrl_hsel),
  `ifdef AMS_PERIPHERALS
    .adcsys_hsel  (adcsys_hsel),
  `endif
  `ifdef SNPS_PVT_MONITORING
    .pvtsys_hsel  (pvtsys_hsel),
  `endif
    .defslv_hsel  (defslv_hsel)
  );
`ifdef AMS_PERIPHERALS
  parameter AMS_PERIPHERAL_PORT = 1;
`else 
  parameter AMS_PERIPHERAL_PORT = 0;
`endif
`ifdef SNPS_PVT_MONITORING
  parameter SNPS_PERIPHERAL_PORT = 1;
`else
  parameter SNPS_PERIPHERAL_PORT = 0;
`endif 
  // AHB slave multiplexer
  cmsdk_ahb_slave_mux #(
    .PORT0_ENABLE  (1), // APB subsystem bridge
    .PORT1_ENABLE  (1), // GPIO Port 0
    .PORT2_ENABLE  (1), // GPIO Port 1
    .PORT3_ENABLE  (1), // SYS control
    .PORT4_ENABLE  (1), // Default
    .PORT5_ENABLE  (AMS_PERIPHERAL_PORT), // ADC Region
    .PORT6_ENABLE  (SNPS_PERIPHERAL_PORT), // Synopsys PVT monitoring region
    .PORT7_ENABLE  (0),
    .PORT8_ENABLE  (0),
    .PORT9_ENABLE  (0),
    .DW            (32)
  ) u_ahb_slave_mux_sys_bus (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .HREADY       (HREADY),
    .HSEL0        (apbsys_hsel),     // Input Port 0
    .HREADYOUT0   (apbsys_hreadyout),
    .HRESP0       (apbsys_hresp),
    .HRDATA0      (apbsys_hrdata),
    .HSEL1        (gpio0_hsel),      // Input Port 1
    .HREADYOUT1   (gpio0_hreadyout),
    .HRESP1       (gpio0_hresp),
    .HRDATA1      (gpio0_hrdata),
    .HSEL2        (gpio1_hsel),      // Input Port 2
    .HREADYOUT2   (gpio1_hreadyout),
    .HRESP2       (gpio1_hresp),
    .HRDATA2      (gpio1_hrdata),
    .HSEL3        (sysctrl_hsel),    // Input Port 3
    .HREADYOUT3   (sysctrl_hreadyout),
    .HRESP3       (sysctrl_hresp),
    .HRDATA3      (sysctrl_hrdata),
    .HSEL4        (defslv_hsel),     // Input Port 4
    .HREADYOUT4   (defslv_hreadyout),
    .HRESP4       (defslv_hresp),
    .HRDATA4      (defslv_hrdata),
    .HSEL5        (adcsys_hsel),     // Input Port 5
    .HREADYOUT5   (adcsys_hreadyout),
    .HRESP5       (adcsys_hresp),
    .HRDATA5      (adcsys_hrdata),
    .HSEL6        (pvtsys_hsel),     // Input Port 6
    .HREADYOUT6   (pvtsys_hreadyout),
    .HRESP6       (pvtsys_hresp),
    .HRDATA6      (pvtsys_hrdata),
    .HSEL7        (1'b0),     // Input Port 7
    .HREADYOUT7   (defslv_hreadyout),
    .HRESP7       (defslv_hresp),
    .HRDATA7      (defslv_hrdata),
    .HSEL8        (1'b0),     // Input Port 8
    .HREADYOUT8   (defslv_hreadyout),
    .HRESP8       (defslv_hresp),
    .HRDATA8      (defslv_hrdata),
    .HSEL9        (1'b0),     // Input Port 9
    .HREADYOUT9   (defslv_hreadyout),
    .HRESP9       (defslv_hresp),
    .HRDATA9      (defslv_hrdata),

    .HREADYOUT    (HREADYOUT),   // Outputs
    .HRESP        (HRESP),
    .HRDATA       (HRDATA)
  );

  // Default slave
  cmsdk_ahb_default_slave u_ahb_default_slave_1 (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .HSEL         (defslv_hsel),
    .HTRANS       (HTRANS),
    .HREADY       (HREADY),
    .HREADYOUT    (defslv_hreadyout),
    .HRESP        (defslv_hresp)
  );

  assign   defslv_hrdata = 32'h00000000; // Default slave do not have read data

  // -------------------------------
  // Peripherals
  // -------------------------------

  nanosoc_sysctrl #(
    .BE (BE)
  ) u_sysctrl (
   // AHB Inputs
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .FCLK         (FCLK),
    .PORESETn     (PORESETn),
    .HSEL         (sysctrl_hsel),
    .HREADY       (HREADY),
    .HTRANS       (HTRANS),
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HADDR        (HADDR[11:0]),
    .HWDATA       (HWDATA),
   // AHB Outputs
    .HREADYOUT    (sysctrl_hreadyout),
    .HRESP        (sysctrl_hresp),
    .HRDATA       (sysctrl_hrdata),
   // Reset information
    .SYSRESETREQ  (SYSRESETREQ),
    .WDOGRESETREQ (WDOGRESETREQ),
    .LOCKUP       (LOCKUP),
    // Engineering-change-order revision bits
    .ECOREVNUM    (4'h0),
   // System control signals
    .REMAP        (REMAP_CTRL),
    .PMUENABLE    (PMUENABLE),
    .LOCKUPRESET  (LOCKUPRESET)
   );

  // GPIO is driven from the AHB
  cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK     (16'h0000), // No pin muxing for Port #0
    .ALTERNATE_FUNC_DEFAULT  (16'h0000), // All pins default to GPIO
    .BE                      (BE)
    )
    u_gpio_0  (
   // AHB Inputs
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .FCLK         (FCLK),
    .HSEL         (gpio0_hsel),
    .HREADY       (HREADY),
    .HTRANS       (HTRANS),
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HADDR        (HADDR[11:0]),
    .HWDATA       (HWDATA),
   // AHB Outputs
    .HREADYOUT    (gpio0_hreadyout),
    .HRESP        (gpio0_hresp),
    .HRDATA       (gpio0_hrdata),

    .ECOREVNUM    (4'h0),// Engineering-change-order revision bits

    .PORTIN       (p0_in),   // GPIO Interface inputs
    .PORTOUT      (p0_out),  // GPIO Interface outputs
    .PORTEN       (p0_outen),
    .PORTFUNC     (p0_altfunc), // Alternate function control

    .GPIOINT      (SYS_GPIO0_IRQ[15:0]),  // Interrupt outputs
    .COMBINT      ()
  );


  cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK     (16'h002A), // pin muxing for Port #1
    .ALTERNATE_FUNC_DEFAULT  (16'h0000), // All pins default to GPIO
    .BE                      (BE)
  ) u_gpio_1 (
   // AHB Inputs
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .FCLK         (FCLK),
    .HSEL         (gpio1_hsel),
    .HREADY       (HREADY),
    .HTRANS       (HTRANS),
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HADDR        (HADDR[11:0]),
    .HWDATA       (HWDATA),
   // AHB Outputs
    .HREADYOUT    (gpio1_hreadyout),
    .HRESP        (gpio1_hresp),
    .HRDATA       (gpio1_hrdata),

    .ECOREVNUM    (4'h0),// Engineering-change-order revision bits

    .PORTIN       (p1_in),   // GPIO Interface inputs
    .PORTOUT      (p1_out),  // GPIO Interface outputs
    .PORTEN       (p1_outen),
    .PORTFUNC     (p1_altfunc), // Alternate function control

    .GPIOINT      (SYS_GPIO1_IRQ[15:0]),  // Interrupt outputs
    .COMBINT      ( )
  );

  // APB subsystem for timers, UARTs
  nanosoc_sysio_apb_ss #(
    .APB_EXT_PORT12_ENABLE   (1), // DMAC 1
    .APB_EXT_PORT13_ENABLE   (1), // Not Used
    .APB_EXT_PORT14_ENABLE   (1), // USRT
    .APB_EXT_PORT15_ENABLE   (1), // DMAC 0
    .INCLUDE_IRQ_SYNCHRONIZER(0),  // require IRQs to be HCLK synchronous
    .INCLUDE_APB_TEST_SLAVE  (1),  // Include example test slave
    .INCLUDE_APB_TIMER0      (1),  // Include simple timer #0
    .INCLUDE_APB_TIMER1      (1),  // Include simple timer #1
    .INCLUDE_APB_DUALTIMER0  (1),  // Include dual timer module
    .INCLUDE_APB_UART0       (0),  // Exclude simple UART #0
    .INCLUDE_APB_UART1       (0),  // Exclude simple UART #1
    .INCLUDE_APB_UART2       (1),  // Include simple UART #2.
    .INCLUDE_APB_WATCHDOG    (1),  // Include APB watchdog module
    .BE                      (BE)
  ) u_sysio_apb_ss (
  // AHB interface for AHB to APB bridge
    .HCLK          (HCLK),
    .HRESETn       (HRESETn),

    .HSEL          (apbsys_hsel),
    .HADDR         (HADDR[15:0]),
    .HTRANS        (HTRANS[1:0]),
    .HWRITE        (HWRITE),
    .HSIZE         (HSIZE),
    .HPROT         (HPROT),
    .HREADY        (HREADY),
    .HWDATA        (HWDATA[31:0]),

    .HREADYOUT     (apbsys_hreadyout),
    .HRDATA        (apbsys_hrdata),
    .HRESP         (apbsys_hresp),

  // APB clock and reset
    .PCLK          (PCLK),
    .PCLKG         (PCLKG),
    .PCLKEN        (PCLKEN),
    .PRESETn       (PRESETn),

  // APB extension ports
    .PADDR         (exp_paddr[11:0]),
    .PWRITE        (exp_pwrite),
    .PWDATA        (exp_pwdata[31:0]),
    .PENABLE       (exp_penable),

    .ext12_psel    (exp12_psel),
    .ext13_psel    (exp13_psel),
    .ext14_psel    (exp14_psel),
    .ext15_psel    (exp15_psel),

  // Input from APB devices on APB expansion ports
    .ext12_prdata  (exp12_prdata),
    .ext12_pready  (exp12_pready),
    .ext12_pslverr (exp12_pslverr),
    .ext13_prdata  (exp13_prdata),
    .ext13_pready  (exp13_pready),
    .ext13_pslverr (exp13_pslverr),
    .ext14_prdata  (exp14_prdata),
    .ext14_pready  (exp14_pready),
    .ext14_pslverr (exp14_pslverr),
    .ext15_prdata  (exp15_prdata),
    .ext15_pready  (exp15_pready),
    .ext15_pslverr (exp15_pslverr),

    .APBACTIVE     (APBACTIVE),  // Status Output for clock gating

  // Peripherals
    // UART
    .uart0_rxd     (uart0_rxd),
    .uart0_txd     (uart0_txd),
    .uart0_txen    (uart0_txen),

    .uart1_rxd     (uart1_rxd),
    .uart1_txd     (uart1_txd),
    .uart1_txen    (uart1_txen),

    .uart2_rxd     (uart2_rxd),
    .uart2_txd     (uart2_txd),
    .uart2_txen    (uart2_txen),

    // Timer
    .timer0_extin  (timer0_extin),
    .timer1_extin  (timer1_extin),

  // Interrupt outputs
    .apbsubsys_interrupt (SYS_APB_IRQ),
    .watchdog_interrupt  (SYS_NMI),
    
   // reset output
    .watchdog_reset      (WDOGRESETREQ)
  );

`ifdef AMS_PERIPHERALS
  nanosoc_sysio_adc_ss #(
`ifdef ADC_0_INCLUDE
    .ADC_0_ENABLE            (1),
`endif 
`ifdef ADC_1_INCLUDE
    .ADC_1_ENABLE            (1),
`endif 
`ifdef ADC_2_INCLUDE
    .ADC_2_ENABLE            (1),
`endif
`ifdef ADC_3_INCLUDE
    .ADC_3_ENABLE            (1),
`endif
    .INCLUDE_IRQ_SYNCHRONIZER(0),  // require IRQs to be HCLK synchronous
    .INCLUDE_APB_TEST_SLAVE  (1),  // Include example test slave
    .BE                      (BE)
  ) u_sysio_adc_ss (
`ifdef ADC_0_ENABLE
      .adc_0_in(),
      .i_adc_0_irq(),
`endif
`ifdef ADC_1_ENABLE
      .adc_1_in(),
      .i_adc_1_irq(),
`endif
`ifdef ADC_2_ENABLE
      .adc_2_in(),
      .i_adc_1_irq(),
`endif
`ifdef ADC_3_ENABLE
      .adc_3_in(),
      .i_adc_1_irq(),
`endif

      .HCLK(HCLK),
      .HRESETn(HRESETn),

      .HSEL(adcsys_hsel),
      .HADDR(HADDR[15:0]),
      .HTRANS(HTRANS[1:0]),
      .HWRITE(HWRITE),
      .HSIZE(HSIZE),
      .HPROT(HPROT),
      .HREADY(HREADY),
      .HWDATA(HWDATA[31:0]),

      .HREADYOUT(adcsys_hreadyout),
      .HRDATA(adcsys_hrdata),
      .HRESP(adcsys_hresp),

      .PCLK(PCLK),    // Peripheral clock
      .PCLKG(PCLKG),   // Gate PCLK for bus interface only
      .PCLKEN(PCLKEN),  // Clock divider for AHB to APB bridge
      .PRESETn(PRESETn) // APB reset

  );
`endif

`ifdef SNPS_PVT_MONITORING
  nanosoc_sysio_snps_pvt_ss #(
  `ifdef SNPS_PVT_TS_0_INCLUDE
      .SNPS_PVT_TS_0_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_TS_1_INCLUDE
      .SNPS_PVT_TS_1_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_TS_2_INCLUDE
      .SNPS_PVT_TS_2_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_TS_3_INCLUDE
      .SNPS_PVT_TS_3_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_TS_4_INCLUDE
      .SNPS_PVT_TS_4_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_TS_5_INCLUDE
      .SNPS_PVT_TS_5_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_VM_0_INCLUDE
      .SNPS_PVT_VM_0_ENABLE  (1),
  `endif 
  `ifdef SNPS_PVT_PD_0_INCLUDE
      .SNPS_PVT_PD_0_ENABLE  (1),
  `endif 
    .INCLUDE_IRQ_SYNCHRONIZER(0),  // require IRQs to be HCLK synchronous
    .INCLUDE_APB_TEST_SLAVE  (1),  // Include example test slave
    .BE                      (BE)

  ) u_nanosoc_sysio_snps_pvt_ss(
      .HCLK(HCLK),
      .HRESETn(HRESETn),

      .HSEL(pvtsys_hsel),
      .HADDR(HADDR[15:0]),
      .HTRANS(HTRANS[1:0]),
      .HWRITE(HWRITE),
      .HSIZE(HSIZE),
      .HPROT(HPROT),
      .HREADY(HREADY),
      .HWDATA(HWDATA[31:0]),

      .HREADYOUT(pvtsys_hreadyout),
      .HRDATA(pvtsys_hrdata),
      .HRESP(pvtsys_hresp),

      .PCLK(PCLK),    // Peripheral clock
      .PCLKG(PCLKG),   // Gate PCLK for bus interface only
      .PCLKEN(PCLKEN),  // Clock divider for AHB to APB bridge
      .PRESETn(PRESETn) // APB reset
  );
`endif
endmodule
