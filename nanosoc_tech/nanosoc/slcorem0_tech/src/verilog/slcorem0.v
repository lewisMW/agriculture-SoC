//-----------------------------------------------------------------------------
// SoCLabs SLCore-M0 - Basic Cortex-M0 CPU Subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn    (d.w.flynn@soton.ac.uk)
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module slcorem0 #(
  parameter        CLKGATE_PRESENT  = 0,
  parameter        BE               = 0,   // 1: Big endian 0: little endian
  parameter        BKPT             = 4,   // Number of breakpoint comparators
  parameter        DBG              = 1,   // Debug configuration
  parameter        NUMIRQ           = 32,  // NUM of IRQ
  parameter        SMUL             = 0,   // Multiplier configuration
  parameter        SYST             = 1,   // SysTick
  parameter        WIC              = 1,   // Wake-up interrupt controller support
  parameter        WICLINES         = 34,  // Supported WIC lines
  parameter        WPT              = 2,   // Number of DWT comparators
  parameter        RESET_ALL_REGS   = 0,   // Do not reset all registers
  parameter        INCLUDE_JTAG     = 0,    // Do not Include JTAG feature
  parameter [31:0] ROMTABLE_BASE    = 32'hE00FF000 // Defaultly Points to Core ROM Table
)(
  // System Input Clocks and Resets
  input  wire          SYS_FCLK,              // Free running clock
  input  wire          SYS_SYSRESETn,         // System Reset
  input  wire          SYS_SCANENABLE,        // Scan Mode Enable
  input  wire          SYS_TESTMODE,          // Test Mode Enable (Override Synchronisers)
  
  // System Reset Request Signals
  input  wire          SYS_SYSRESETREQ,        // System Request from System Managers
  output wire          CORE_PRMURESETREQ,      // CPU Control Reset Request (PMU and Reset Unit)
  
  // Generated Clocks and Resets 
  output wire          SYS_PORESETn,          // System Power On Reset
  output wire          SYS_HCLK,              // AHB Clock
  output wire          SYS_HRESETn,           // AHB and System reset
  
  // Power Management Signals
  input  wire          CORE_PMUENABLE,        // Power Management Enable
  output wire          CORE_PMUDBGRESETREQ,   // Power Management Debug Reset Req

  // AHB Lite port
  output wire   [31:0] HADDR,            // Address bus
  output wire    [1:0] HTRANS,           // Transfer type
  output wire          HWRITE,           // Transfer direction
  output wire    [2:0] HSIZE,            // Transfer size
  output wire    [2:0] HBURST,           // Burst type
  output wire    [3:0] HPROT,            // Protection control
  output wire   [31:0] HWDATA,           // Write data
  output wire          HMASTLOCK,        // Locked Sequence
  input  wire   [31:0] HRDATA,           // Read data bus
  input  wire          HREADY,           // HREADY feedback
  input  wire          HRESP,            // Transfer response

  // Sideband CPU signalling
  input  wire          CORE_NMI,              // Non-Maskable Interrupt request
  input  wire   [31:0] CORE_IRQ,              // Maskable Interrupt requests
  output wire          CORE_TXEV,             // Send Event (SEV) output
  input  wire          CORE_RXEV,             // Receive Event input
  output wire          CORE_LOCKUP,           // Wake up request from WIC
  output wire          CORE_SYSRESETREQ,      // System reset request
  
  output wire          CORE_SLEEPING,         // Processor status - sleeping
  output wire          CORE_SLEEPDEEP,        // Processor status - deep sleep

  // Serial-Wire Debug
  input  wire          CORE_SWDI,             // SWD data input
  input  wire          CORE_SWCLK,            // SWD clock
  output wire          CORE_SWDO,             // SWD data output
  output wire          CORE_SWDOEN            // SWD data output enable
);          
  
  // ---------------------------------------------------
  // Cortex-M0 Power Management and Reset Control Unit
  // ---------------------------------------------------
  // Cortex-M0 Control to Core Connectivity
  wire       CORE_GATEHCLK;              // Control Signal from CPU to Control CLock Gating of HCLK
  wire       CORE_WAKEUP;                // Wake-up Signaling from Core
  wire       CORE_CDBGPWRUPREQ;          // Core Debug Power Up Request
  wire       CORE_CDBGPWRUPACK;          // Core Debug Power Up Acknowledge
  wire       CORE_WICENREQ;              // WIC enable request from PMU
  wire       CORE_WICENACK;              // Wake-on-Interrupt Enable ACK from Core
  wire       CORE_SLEEPHOLDREQn;         // Core Sleep Hold Request
  wire       CORE_SLEEPHOLDACKn;         // Core Sleep Hold Acknowledgement
  
  // Internal Clock Signals
  wire       CORE_HCLK;        // AHB Clock
  wire       CORE_HRESETn;     // AHB and System reset
  wire       CORE_SCLK;        // System clock
  wire       CORE_DCLK;        // Debug clock
  wire       CORE_DBGRESETn;   // Debug reset
  
  // Cortex-M0 Control Instantiation
  slcorem0_prmu #(
    .CLKGATE_PRESENT(CLKGATE_PRESENT)
  ) u_core_prmu (
    // Input Clocks and Resets
    .SYS_FCLK       (SYS_FCLK),             // Free running clock
    .SYS_SYSRESETn  (SYS_SYSRESETn),        // System Reset
    .SYS_SCANENABLE (SYS_SCANENABLE),       // Scan Mode Enable
    .SYS_TESTMODE   (SYS_TESTMODE),         // Test Mode Enable (Override Synchronisers)

    // Core Generated Clocks and Resets 
    .CORE_SCLK         (CORE_SCLK),         // Core-Subsystem clock
    .CORE_HCLK         (CORE_HCLK),         // Core AHB Clock
    .CORE_HRESETn      (CORE_HRESETn),      // Core AHB Reset
    .CORE_DCLK         (CORE_DCLK),         // Core Debug clock
    .CORE_DBGRESETn    (CORE_DBGRESETn),    // Core Debug reset

    // System Generated Clocks and Resets 
    .SYS_HCLK          (SYS_HCLK),          // System AHB Clock
    .SYS_HRESETn       (SYS_HRESETn),       // System AHB Reset
    .SYS_PORESETn      (SYS_PORESETn),      // System Power on reset
    
    // System Reset Request
    .SYS_SYSRESETREQ   (SYS_SYSRESETREQ),   // System Reset Request

    // Power Management Control Signals
    .CORE_PMUENABLE    (CORE_PMUENABLE),       // PMU Enable from System Register
    .CORE_WAKEUP       (CORE_WAKEUP),           // Wake-up Signaling from Core
    .CORE_SLEEPDEEP    (CORE_SLEEPDEEP),        // Debug Power Up Request
    .CORE_GATEHCLK     (CORE_GATEHCLK),         // Control Signal from Core to Control Clock Gating of HCLK

    // Power Management Request signals
    .CORE_CDBGPWRUPREQ      (CORE_CDBGPWRUPREQ),     // Core Debug Power Up Request
    .CORE_WICENREQ          (CORE_WICENREQ),         // Core WIC enable request from PMU
    .CORE_SLEEPHOLDREQn     (CORE_SLEEPHOLDREQn),    // Core Sleep Hold Request

    .CORE_PRMURESETREQ       (CORE_PRMURESETREQ),      // Core Control System Reset Request
    .CORE_PMUDBGRESETREQ     (CORE_PMUDBGRESETREQ),    // Core Power Management Unit Debug Reset Request
    
    // Power Management Ackowledge signals
    .CORE_WICENACK           (CORE_WICENACK),         // Wake-on-Interrupt Enable ACK from Core
    .CORE_SLEEPHOLDACKn      (CORE_SLEEPHOLDACKn),    // Sleep Hold Acknowledgement
    .CORE_CDBGPWRUPACK       (CORE_CDBGPWRUPACK)      // Core Debug Power Up Acknowledge
  );
  
  // -------------------------------
  // SysTick signals
  // -------------------------------
  // SysTick Timer Signals
  wire              CORE_STCLKEN;
  wire     [25:0]   CORE_STCALIB;
  
  // SysTick Control Instantiation
  slcorem0_stclkctrl #(
    .DIV_RATIO (18'd01000)
  ) u_stclkctrl (
    .FCLK      (SYS_FCLK),
    .SYSRESETn (SYS_SYSRESETn),

    .STCLKEN   (CORE_STCLKEN),
    .STCALIB   (CORE_STCALIB)
  );

  // -------------------------------
  // Cortex-M0 CPU Instantiation
  // -------------------------------
  
  // Cortex-M0 Logic Instantiation
  slcorem0_integration #(
    .ACG           (CLKGATE_PRESENT), // Architectural clock gating
    .BE            (BE),              // Big-endian
    .BKPT          (BKPT),            // Number of breakpoint comparators
    .DBG           (DBG),             // Debug configuration
    .JTAGnSW       (INCLUDE_JTAG),    // Debug port interface: JTAGnSW
    .NUMIRQ        (NUMIRQ),          // Number of Interrupts
    .RAR           (RESET_ALL_REGS),  // Reset All Registers
    .SMUL          (SMUL),            // Multiplier configuration
    .SYST          (SYST),            // SysTick
    .WIC           (WIC),             // Wake-up interrupt controller support
    .WICLINES      (WICLINES),        // Supported WIC lines
    .WPT           (WPT),             // Number of DWT comparators
    .ROMTABLE_BASE (ROMTABLE_BASE)
  ) u_slcorem0_integration (
    // System inputs
    .FCLK          (SYS_FCLK),       // FCLK
    .SCLK          (CORE_SCLK),      // SCLK generated from PMU
    .HCLK          (CORE_HCLK),      // HCLK generated from PMU
    .DCLK          (CORE_DCLK),      // DCLK generated from PMU
    .PORESETn      (SYS_PORESETn),
    .HRESETn       (CORE_HRESETn),
    .DBGRESETn     (CORE_DBGRESETn),
    .RSTBYPASS     (SYS_TESTMODE),
    .SE            (SYS_SCANENABLE),

    // Power management inputs
    .SLEEPHOLDREQn (CORE_SLEEPHOLDREQn),
    .WICENREQ      (CORE_WICENREQ),
    .CDBGPWRUPACK  (CORE_CDBGPWRUPACK),

    // Power management outputs
    .SLEEPHOLDACKn (CORE_SLEEPHOLDACKn),
    .WICENACK      (CORE_WICENACK),
    .CDBGPWRUPREQ  (CORE_CDBGPWRUPREQ),

    .WAKEUP        (CORE_WAKEUP),
    .WICSENSE      ( ),
    .GATEHCLK      (CORE_GATEHCLK),
    .SYSRESETREQ   (CORE_SYSRESETREQ),

    // System bus
    .HADDR         (HADDR),
    .HTRANS        (HTRANS),
    .HSIZE         (HSIZE),
    .HBURST        (HBURST),
    .HPROT         (HPROT),
    .HMASTLOCK     (HMASTLOCK),
    .HWRITE        (HWRITE),
    .HWDATA        (HWDATA),
    .HRDATA        (HRDATA),
    .HREADY        (HREADY),
    .HRESP         (HRESP),
    .HMASTER       ( ),

    .CODEHINTDE    ( ),
    .SPECHTRANS    ( ),
    .CODENSEQ      ( ),

    // Interrupts
    .IRQ           (CORE_IRQ[31:0]),
    .NMI           (CORE_NMI),
    .IRQLATENCY    (8'h00),

    .ECOREVNUM     (28'd0),
    
    // Systick
    .STCLKEN       (CORE_STCLKEN),
    .STCALIB       (CORE_STCALIB),

    // Debug - JTAG or Serial wire
    .nTRST         (1'b1),
    .SWDITMS       (CORE_SWDI),
    .SWCLKTCK      (CORE_SWCLK),
    .TDI           (1'b0),
    .TDO           ( ),
    .nTDOEN        ( ),
    .SWDO          (CORE_SWDO),
    .SWDOEN        (CORE_SWDOEN),

    .DBGRESTART    (1'b0), // Unused - Multi-Core synchronous restart from halt
    .DBGRESTARTED  ( ),    // Unused - Multi-Core synchronous restart from halt

    // Event communication
    .TXEV          (CORE_TXEV),
    .RXEV          (CORE_RXEV),
    .EDBGRQ        (1'b0), // Unused - Multi-Core synchronous halt request
    
    // Status output - TODO: Map into APB Register Block
    .HALTED        ( ),
    .LOCKUP        (CORE_LOCKUP),
    .SLEEPING      (CORE_SLEEPING),
    .SLEEPDEEP     (CORE_SLEEPDEEP)
  );

endmodule
