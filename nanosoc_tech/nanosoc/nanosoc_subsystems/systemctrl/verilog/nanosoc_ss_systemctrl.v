//-----------------------------------------------------------------------------
// NanoSoC System Control and Peripheral Subsystem
// - Contains Clock Control, Pin Mux, System Peripherals and System ROM table
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

module nanosoc_ss_systemctrl #(
    parameter    SYS_ADDR_W    = 32,  // System Address Width
    parameter    SYS_DATA_W    = 32,  // System Data Width
    parameter    APB_ADDR_W    = 12,  // APB Peripheral Address Width
    parameter    APB_DATA_W    = 32,  // APB Peripheral Data Width
    
    parameter    SYSTABLE_BASE = 32'hf000_0000,   // Base Address of System ROM Table
    parameter    SOCLABS_JEPID = 7'd0,
    parameter    NANOSOC_PARTNUMBER = 12'd0,
    parameter    NANOSOC_REVISION   = 4'h0,
    
    parameter    CLKGATE_PRESENT = 0
)(
    // Free-running and Crystal Clock Output
    input  wire                   SYS_CLK,              // System Input Clock
    output wire                   SYS_FCLK,             // Free-running system clock
    output wire                   SYS_XTALCLK_OUT,      // Crystal Clock Output
    
    // System Input Clocks and Resets
    input  wire                   SYS_SYSRESETn,        // System Reset
    input  wire                   SYS_PORESETn,         // Power-On-Reset reset (active-low)
    input  wire                   SYS_TESTMODE,         // Reset bypass in scan test
    input  wire                   SYS_HCLK,             // AHB clock
    input  wire                   SYS_HRESETn,          // AHB reset (active-low)

    // SYSIO AHB interface
    input  wire                   SYSIO_HSEL,           // AHB region select
    input  wire  [SYS_ADDR_W-1:0] SYSIO_HADDR,          // AHB address
    input  wire            [ 2:0] SYSIO_HBURST,         // AHB burst
    input  wire                   SYSIO_HMASTLOCK,      // AHB lock
    input  wire            [ 3:0] SYSIO_HPROT,          // AHB prot
    input  wire            [ 2:0] SYSIO_HSIZE,          // AHB size
    input  wire            [ 1:0] SYSIO_HTRANS,         // AHB transfer
    input  wire  [SYS_DATA_W-1:0] SYSIO_HWDATA,         // AHB write data
    input  wire                   SYSIO_HWRITE,         // AHB write
    input  wire                   SYSIO_HREADY,         // AHB ready
    output  wire [SYS_DATA_W-1:0] SYSIO_HRDATA,         // AHB read-data
    output  wire                  SYSIO_HRESP,          // AHB response
    output  wire                  SYSIO_HREADYOUT,      // AHB ready out
    
    // System ROM Table AHB interface
    input  wire                   SYSTABLE_HSEL,           // AHB region select
    input  wire  [SYS_ADDR_W-1:0] SYSTABLE_HADDR,          // AHB address
    input  wire            [ 2:0] SYSTABLE_HBURST,         // AHB burst
    input  wire                   SYSTABLE_HMASTLOCK,      // AHB lock
    input  wire            [ 3:0] SYSTABLE_HPROT,          // AHB prot
    input  wire            [ 2:0] SYSTABLE_HSIZE,          // AHB size
    input  wire            [ 1:0] SYSTABLE_HTRANS,         // AHB transfer
    input  wire  [SYS_DATA_W-1:0] SYSTABLE_HWDATA,         // AHB write data
    input  wire                   SYSTABLE_HWRITE,         // AHB write
    input  wire                   SYSTABLE_HREADY,         // AHB ready
    output  wire [SYS_DATA_W-1:0] SYSTABLE_HRDATA,         // AHB read-data
    output  wire                  SYSTABLE_HRESP,          // AHB response
    output  wire                  SYSTABLE_HREADYOUT,      // AHB ready out

    // APB clocking control
    output wire                   SYS_PCLK,             // Peripheral clock
    output wire                   SYS_PCLKG,            // Gated Peripheral bus clock
    output wire                   SYS_PRESETn,          // Peripheral system and APB reset
    output wire                   SYS_PCLKEN,           // Clock divide control for AHB to APB bridge

    // APB external Slave Interfaces
    output wire                   SYSIO_PENABLE,
    output wire                   SYSIO_PWRITE,
    output wire  [APB_ADDR_W-1:0] SYSIO_PADDR,
    output wire  [APB_DATA_W-1:0] SYSIO_PWDATA,
    
    output wire                   USRT_PSEL,
    input  wire  [APB_DATA_W-1:0] USRT_PRDATA,
    input  wire                   USRT_PREADY,
    input  wire                   USRT_PSLVERR,
    
    output wire                   DMAC_0_PSEL,
    input  wire  [APB_DATA_W-1:0] DMAC_0_PRDATA,
    input  wire                   DMAC_0_PREADY,
    input  wire                   DMAC_0_PSLVERR,
    
    output wire                   DMAC_1_PSEL,
    output wire                   DMAC_1_PSEL_HI,
    input  wire  [APB_DATA_W-1:0] DMAC_1_PRDATA,
    input  wire                   DMAC_1_PREADY,
    input  wire                   DMAC_1_PSLVERR,

    // CPU sideband signalling
    output wire                   SYS_NMI,          // watchdog_interrupt;
    output wire           [31:0]  SYS_APB_IRQ,      // apbsubsys_interrupt;
    output wire           [15:0]  SYS_GPIO0_IRQ,    // GPIO 0 IRQs
    output wire           [15:0]  SYS_GPIO1_IRQ,    // GPIO 0 IRQs

    // CPU power/reset control
    output wire                   SYS_REMAP_CTRL,       // REMAP control bit
    output wire                   SYS_WDOGRESETREQ,     // Watchdog reset request
    output wire                   SYS_LOCKUPRESET,      // System Controller Config - Reset if lockup
    
    // System Reset Request Signals
    input  wire                   CPU_SYSRESETREQ,       // System Request from CPUs
    input  wire                   CPU_PRMURESETREQ,      // CPU Control Reset Request (PMU and Reset Unit)
    
    // Power Management Control and Status
    output wire                   SYS_PMUENABLE,        // System Controller cfg - Enable PMU
    input  wire                   SYS_PMUDBGRESETREQ,   // Power Management Debug Reset Req
    
    // CPU Status Signals
    input  wire                   CPU_LOCKUP,           // Processor status - Locked up
    input  wire                   CPU_SLEEPING,
    input  wire                   CPU_SLEEPDEEP,
  
    // GPIO
    input  wire            [15:0] P0_IN,            // GPIO 0 inputs
    output wire            [15:0] P0_OUT,           // GPIO 0 outputs
    output wire            [15:0] P0_OUTEN,         // GPIO 0 output enables
    output wire            [15:0] P0_ALTFUNC,       // GPIO 0 alternate function (pin mux)
    input  wire            [15:0] P1_IN,            // GPIO 1 inputs
    output wire            [15:0] P1_OUT,           // GPIO 1 outputs
    output wire            [15:0] P1_OUTEN,         // GPIO 1 output enables
    output wire            [15:0] P1_ALTFUNC,       // GPIO 1 alternate function (pin mux)
    output wire            [15:0] P1_OUT_MUX,       // GPIO 1 aOutput Port Drive
    output wire            [15:0] P1_OUT_EN_MUX     // Active High output drive enable (pad tech dependent)
);
    // -------------------------------
    // Internal Wiring
    // -------------------------------
    wire apbactive;
    
    wire uart0_rxd;        // Uart 0 receive data
    wire uart0_txd;        // Uart 0 transmit data
    wire uart0_txen;       // Uart 0 transmit data enable
    wire uart1_rxd;        // Uart 1 receive data
    wire uart1_txd;        // Uart 1 transmit data
    wire uart1_txen;       // Uart 1 transmit data enable
    wire uart2_rxd;        // Uart 2 receive data
    wire uart2_txd;        // Uart 2 transmit data
    wire uart2_txen;       // Uart 2 transmit data enable
    wire timer0_extin;     // Timer 0 external input
    wire timer1_extin;     // Timer 1 external input
    
    // -------------------------------
    // NanoSoC Clock Control Instantiation
    // -------------------------------
    nanosoc_clkctrl #(
        .CLKGATE_PRESENT  (CLKGATE_PRESENT)
    ) u_clkctrl(
        // inputs
        .XTAL1            (SYS_CLK),
        .NRST             (SYS_SYSRESETn),

        .APBACTIVE        (apbactive),
        .SLEEPING         (CPU_SLEEPING),
        .SLEEPDEEP        (CPU_SLEEPDEEP),
        .LOCKUP           (CPU_LOCKUP),
        .LOCKUPRESET      (SYS_LOCKUPRESET),
        .SYSRESETREQ      (CPU_PRMURESETREQ),
        .DBGRESETREQ      (SYS_PMUDBGRESETREQ),
        .CGBYPASS         (SYS_TESTMODE),
        .RSTBYPASS        (SYS_TESTMODE),

        // outputs
        .XTAL2            (SYS_XTALCLK_OUT),

        .FCLK             (SYS_FCLK),

        .PCLK             (SYS_PCLK),
        .PCLKG            (SYS_PCLKG),
        .PCLKEN           (SYS_PCLKEN),
        .PRESETn          (SYS_PRESETn)
    );
    
    // -------------------------------
    // NanoSoC Pin Mux Instantiation
    // -------------------------------
    nanosoc_pin_mux u_pin_mux (
        // UART
        .uart0_rxd        (uart0_rxd),
        .uart0_txd        (uart0_txd),
        .uart0_txen       (uart0_txen),
        .uart1_rxd        (uart1_rxd),
        .uart1_txd        (uart1_txd),
        .uart1_txen       (uart1_txen),
        .uart2_rxd        (uart2_rxd),
        .uart2_txd        (uart2_txd),
        .uart2_txen       (uart2_txen),

        // Timer
        .timer0_extin     (timer0_extin),
        .timer1_extin     (timer1_extin),

        // IO Ports
        .p0_in            ( ), // was (p0_in) now from pad inputs),
        .p0_out           (P0_OUT),
        .p0_outen         (P0_OUTEN),
        .p0_altfunc       (P0_ALTFUNC),

        .p1_in            ( ), // was(p1_in) now from pad inputs),
        .p1_out           (P1_OUT),
        .p1_outen         (P1_OUTEN),
        .p1_altfunc       (P1_ALTFUNC),

        // Debug
        // .i_trst_n         ( ),
        // .i_swditms        ( ), //i_swditms),
        // .i_swclktck       ( ), //i_swclktck),
        // .i_tdi            ( ),
        // .i_tdo            ( ),
        // .i_tdoen_n        ( ),
        // .i_swdo           ( ),
        // .i_swdoen         ( ),

        // IO pads
        .p1_out_mux       (P1_OUT_MUX),
        .p1_out_en_mux    (P1_OUT_EN_MUX),
        .P0               ( ), //P0),
        .P1               ( ) //P1),

        // .nTRST            (1'b1),  // Not needed if serial-wire debug is used
        // .TDI              (1'b0),  // Not needed if serial-wire debug is used
        // .SWDIOTMS         ( ), //SWDIOTMS),
        // .SWCLKTCK         ( ), //SWCLKTCK),
        // .TDO              ( )     // Not needed if serial-wire debug is used
    );
    
    // -------------------------------
    // SYSIO Region Instantiation
    // -------------------------------
    nanosoc_region_sysio #(
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        .APB_ADDR_W(APB_ADDR_W),
        .APB_DATA_W(APB_DATA_W)
    ) u_region_sysio (
        // Clock and Reset
        .FCLK(SYS_FCLK),
        .PORESETn(SYS_PORESETn),

        // AHB interface
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),
        .HSEL(SYSIO_HSEL),
        .HADDR(SYSIO_HADDR),
        .HBURST(SYSIO_HBURST),
        .HMASTLOCK(SYSIO_HMASTLOCK),
        .HPROT(SYSIO_HPROT),
        .HSIZE(SYSIO_HSIZE),
        .HTRANS(SYSIO_HTRANS),
        .HWDATA(SYSIO_HWDATA),
        .HWRITE(SYSIO_HWRITE),
        .HREADY(SYSIO_HREADY),
        .HRDATA(SYSIO_HRDATA),
        .HRESP(SYSIO_HRESP),
        .HREADYOUT(SYSIO_HREADYOUT),

        // APB clocking control
        .PCLK(SYS_PCLK),
        .PCLKG(SYS_PCLKG),
        .PRESETn(SYS_PRESETn),
        .PCLKEN(SYS_PCLKEN),

        // APB external Slave Interface
        .exp12_psel(DMAC_1_PSEL),
        .exp13_psel(DMAC_1_PSEL_HI),
        .exp14_psel(USRT_PSEL),
        .exp15_psel(DMAC_0_PSEL),
        .exp_penable(SYSIO_PENABLE),
        .exp_pwrite(SYSIO_PWRITE),
        .exp_paddr(SYSIO_PADDR),
        .exp_pwdata(SYSIO_PWDATA),
        .exp12_prdata(DMAC_1_PRDATA),
        .exp12_pready(DMAC_1_PREADY),
        .exp12_pslverr(DMAC_1_PSLVERR),
        .exp13_prdata(DMAC_1_PRDATA),
        .exp13_pready(DMAC_1_PREADY),
        .exp13_pslverr(DMAC_1_PSLVERR),
        .exp14_prdata(USRT_PRDATA),
        .exp14_pready(USRT_PREADY),
        .exp14_pslverr(USRT_PSLVERR),
        .exp15_prdata(DMAC_0_PRDATA),
        .exp15_pready(DMAC_0_PREADY),
        .exp15_pslverr(DMAC_0_PSLVERR),

        // CPU sideband signaling
        .SYS_NMI(SYS_NMI),
        .SYS_APB_IRQ(SYS_APB_IRQ),
        .SYS_GPIO0_IRQ(SYS_GPIO0_IRQ),
        .SYS_GPIO1_IRQ(SYS_GPIO1_IRQ),

        // CPU power/reset control
        .REMAP_CTRL(SYS_REMAP_CTRL),
        .APBACTIVE(apbactive),
        .SYSRESETREQ(CPU_SYSRESETREQ),
        .WDOGRESETREQ(SYS_WDOGRESETREQ),
        .LOCKUP(CPU_LOCKUP),
        .LOCKUPRESET(SYS_LOCKUPRESET),
        .PMUENABLE(SYS_PMUENABLE),

        // IO signaling
        .uart0_rxd(uart1_txd), // crossover
        .uart0_txd(uart0_txd),
        .uart0_txen(uart0_txen),
        .uart1_rxd(uart0_txd),  // crossover
        .uart1_txd(uart1_txd),
        .uart1_txen(uart1_txen),
        .uart2_rxd(uart2_rxd),
        .uart2_txd(uart2_txd),
        .uart2_txen(uart2_txen),
        .timer0_extin(timer0_extin),
        .timer1_extin(timer1_extin),

        // GPIO
        .p0_in(P0_IN),
        .p0_out(P0_OUT),
        .p0_outen(P0_OUTEN),
        .p0_altfunc(P0_ALTFUNC),
        .p1_in(P1_IN),
        .p1_out(P1_OUT),
        .p1_outen(P1_OUTEN),
        .p1_altfunc(P1_ALTFUNC)
    );

    // --------------------------------------
    // System ROM Table Region Instantiation
    // --------------------------------------
    nanosoc_region_systable #(
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        .SYSTABLE_BASE(SYSTABLE_BASE),
        .SOCLABS_JEPID(SOCLABS_JEPID),
        .NANOSOC_PARTNUMBER(NANOSOC_PARTNUMBER),
        .NANOSOC_REVISION(NANOSOC_REVISION)
    ) u_region_systable (
        // Clock 
        .HCLK(SYS_HCLK),

        // AHB connection to Initiator
        .HSEL(SYSTABLE_HSEL),
        .HADDR(SYSTABLE_HADDR),
        .HBURST(SYSTABLE_HBURST),
        .HMASTLOCK(SYSTABLE_HMASTLOCK),
        .HPROT(SYSTABLE_HPROT),
        .HSIZE(SYSTABLE_HSIZE),
        .HTRANS(SYSTABLE_HTRANS),
        .HWDATA(SYSTABLE_HWDATA),
        .HWRITE(SYSTABLE_HWRITE),
        .HREADY(SYSTABLE_HREADY),
        .HRDATA(SYSTABLE_HRDATA),
        .HRESP(SYSTABLE_HRESP),
        .HREADYOUT(SYSTABLE_HREADYOUT)
    );
endmodule