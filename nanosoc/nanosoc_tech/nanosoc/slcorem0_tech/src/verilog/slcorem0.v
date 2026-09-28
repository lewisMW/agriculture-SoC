//-----------------------------------------------------------------------------
// SoCLabs SLCore-M0 - Basic Cortex-M0 CPU Subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn    (d.w.flynn@soton.ac.uk)
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
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
  parameter        INCLUDE_JTAG     = 0,   // Do not Include JTAG feature
  // EXTERNAL_DAP=0: instantiate the per-core CORTEXM0DAP and expose CORE_SWDI/SWCLK/SWDO/SWDOEN
  //                (legacy behaviour, default -- RTL is bit-identical to pre-bypass).
  // EXTERNAL_DAP=1: omit CORTEXM0DAP and drive the Cortex-M0 debug slave bus from the new
  //                DBGAHB_* ports so a system-level CoreSight SoC-400 AHB-AP can own the DAP.
  parameter        EXTERNAL_DAP     = 0,
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

  // Serial-Wire Debug (active when EXTERNAL_DAP = 0; tied to safe values when EXTERNAL_DAP = 1)
  input  wire          CORE_SWDI,             // SWD data input
  input  wire          CORE_SWCLK,            // SWD clock
  output wire          CORE_SWDO,             // SWD data output
  output wire          CORE_SWDOEN,           // SWD data output enable

  // Debug AHB-AP slave bus (active when EXTERNAL_DAP = 1; ignored when EXTERNAL_DAP = 0).
  // Driven by a system-level CoreSight DAP. Existing instances may leave these unconnected.
  input  wire   [31:0] DBGAHB_SLVADDR,        // Debug slave address from system DAP
  input  wire   [31:0] DBGAHB_SLVWDATA,       // Debug slave write data
  input  wire    [1:0] DBGAHB_SLVTRANS,       // Debug slave transfer type
  input  wire          DBGAHB_SLVWRITE,       // Debug slave write enable
  input  wire    [1:0] DBGAHB_SLVSIZE,        // Debug slave transfer size
  output wire   [31:0] DBGAHB_SLVRDATA,       // Debug slave read data to system DAP
  output wire          DBGAHB_SLVREADY,       // Debug slave ready to system DAP
  output wire          DBGAHB_SLVRESP         // Debug slave response to system DAP
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

  // ---------------------------------------------------
  // Cortex-M0 Debug Access Port (DAP)
  // ---------------------------------------------------

  wire        cfg_dbg = DBG != 0;

  // ROM Table Value Calculation
  wire [31:0] ROMTABLE_VAL = {ROMTABLE_BASE[31:2], 2'd3};

  // Cortex-M0 debug slave bus presented to slcorem0_integration. The source of
  // these signals is selected by the EXTERNAL_DAP parameter:
  //   EXTERNAL_DAP = 0: driven by the internal CORTEXM0DAP from CORE_SWDI/SWCLK
  //   EXTERNAL_DAP = 1: driven by the DBGAHB_* ports from a system-level CoreSight DAP
  wire [31:0] slv_addr;
  wire [31:0] slv_wdata;
  wire [ 1:0] slv_trans;
  wire        slv_write;
  wire [ 1:0] slv_size;

  // Core -> DAP read response (from slcorem0_integration debug slave port)
  wire [31:0] slv_rdata;
  wire        slv_ready;
  wire        slv_resp;

  generate if (EXTERNAL_DAP != 0) begin : g_external_dap
    // ---------------------------------------------------------------
    // External DAP path: the SoC-level CoreSight DAP owns the slave bus.
    // The internal CORTEXM0DAP is omitted; CORE_SWD* pins are inactive.
    // ---------------------------------------------------------------
    assign slv_addr  = cfg_dbg ? DBGAHB_SLVADDR  : {32{1'b0}};
    assign slv_wdata = cfg_dbg ? DBGAHB_SLVWDATA : {32{1'b0}};
    assign slv_trans = cfg_dbg ? DBGAHB_SLVTRANS : {2{1'b0}};
    assign slv_write = cfg_dbg ? DBGAHB_SLVWRITE : 1'b0;
    assign slv_size  = cfg_dbg ? DBGAHB_SLVSIZE  : {2{1'b0}};

    // Read response routed back to the system DAP
    assign DBGAHB_SLVRDATA = cfg_dbg ? slv_rdata : {32{1'b0}};
    assign DBGAHB_SLVREADY = cfg_dbg ? slv_ready : 1'b1;
    assign DBGAHB_SLVRESP  = cfg_dbg ? slv_resp  : 1'b0;

    // SWD pins inactive (system DAP handles the protocol externally).
    // CORE_SWCLK / CORE_SWDI / CORE_CDBGPWRUPACK are unused inputs in this
    // path -- clocking and AP reset are owned by the system DAP.
    //
    // CORE_CDBGPWRUPREQ is tied high so the PMU acks debug-power-up and
    // releases CORE_DBGRESETn. With it tied low, the integration's debug
    // slave port stays in reset and silently drops DBGAHB transactions.
    assign CORE_SWDO         = 1'b0;
    assign CORE_SWDOEN       = 1'b0;
    assign CORE_CDBGPWRUPREQ = 1'b1;
  end else begin : g_internal_dap
    // ---------------------------------------------------------------
    // Legacy internal-DAP path (default): instantiate CORTEXM0DAP and
    // route the SLV bus from the internal DAP. RTL is bit-identical to
    // the pre-bypass implementation.
    // ---------------------------------------------------------------

    // DAP DP reset (synchronised)
    wire        dp_reset_n;

    // DAP -> Core interconnect
    wire [31:0] slv_addr_dap;
    wire [31:0] slv_wdata_dap;
    wire [ 1:0] slv_trans_dap;
    wire        slv_write_dap;
    wire [ 1:0] slv_size_dap;
    wire        sw_do;
    wire        sw_do_en;
    wire        cdbg_pwrup_req;

    // Tie off debug signals when no debug is implemented
    wire        device_en      = cfg_dbg ? 1'b1          : 1'b0;
    wire [31:0] slv_rdata_dap  = cfg_dbg ? slv_rdata     : {32{1'b0}};
    wire        slv_ready_dap  = cfg_dbg ? slv_ready     : 1'b0;
    wire        slv_resp_dap   = cfg_dbg ? slv_resp      : 1'b0;

    // DAP DP reset synchronizer
    cm0_dbg_reset_sync #(
      .PRESENT(DBG)
    ) u_dpreset_sync (
      .RSTIN     (SYS_PORESETn),
      .CLK       (CORE_SWCLK),
      .SE        (SYS_SCANENABLE),
      .RSTBYPASS (SYS_TESTMODE),
      .RSTOUT    (dp_reset_n)
    );

    // Cortex-M0 Debug Access Port instantiation
    CORTEXM0DAP #(
      .JTAGnSW(INCLUDE_JTAG),
      .DBG(DBG),
      .RAR(RESET_ALL_REGS)
    ) u_dap (
      // Outputs
      .SWDO                           (sw_do),
      .SWDOEN                         (sw_do_en),
      .TDO                            (),
      .nTDOEN                         (),
      .CDBGPWRUPREQ                   (cdbg_pwrup_req),
      .SLVADDR                        (slv_addr_dap[31:0]),
      .SLVWDATA                       (slv_wdata_dap[31:0]),
      .SLVTRANS                       (slv_trans_dap[1:0]),
      .SLVWRITE                       (slv_write_dap),
      .SLVSIZE                        (slv_size_dap[1:0]),
      // Inputs
      .SWCLKTCK                       (CORE_SWCLK),
      .nTRST                          (1'b1),
      .DPRESETn                       (dp_reset_n),
      .APRESETn                       (CORE_DBGRESETn),
      .SWDITMS                        (cfg_dbg ? CORE_SWDI : 1'b1),
      .TDI                            (1'b0),
      .CDBGPWRUPACK                   (cfg_dbg ? CORE_CDBGPWRUPACK : 1'b0),
      .DEVICEEN                       (device_en),
      .DCLK                           (CORE_DCLK),
      .SLVRDATA                       (slv_rdata_dap[31:0]),
      .SLVREADY                       (slv_ready_dap),
      .SLVRESP                        (slv_resp_dap),
      .BASEADDR                       (ROMTABLE_VAL),
      .ECOREVNUM                      (8'd0),
      .SE                             (SYS_SCANENABLE)
    );

    // Forward DAP master signals to slcorem0_integration debug slave bus
    assign slv_addr  = cfg_dbg ? slv_addr_dap  : {32{1'b0}};
    assign slv_wdata = cfg_dbg ? slv_wdata_dap : {32{1'b0}};
    assign slv_trans = cfg_dbg ? slv_trans_dap : {2{1'b0}};
    assign slv_write = cfg_dbg ? slv_write_dap : 1'b0;
    assign slv_size  = cfg_dbg ? slv_size_dap  : {2{1'b0}};

    // Debug output assignments
    assign CORE_SWDO         = cfg_dbg ? sw_do          : 1'b0;
    assign CORE_SWDOEN       = cfg_dbg ? sw_do_en       : 1'b0;
    assign CORE_CDBGPWRUPREQ = cfg_dbg ? cdbg_pwrup_req : 1'b0;

    // External DBGAHB outputs unused in legacy mode -- driven to safe defaults
    assign DBGAHB_SLVRDATA = {32{1'b0}};
    assign DBGAHB_SLVREADY = 1'b1;
    assign DBGAHB_SLVRESP  = 1'b0;
  end endgenerate

  // -------------------------------
  // Cortex-M0 CPU Instantiation
  // -------------------------------

  // Cortex-M0 Logic Instantiation
  slcorem0_integration #(
    .ACG           (CLKGATE_PRESENT), // Architectural clock gating
    .BE            (BE),              // Big-endian
    .BKPT          (BKPT),            // Number of breakpoint comparators
    .DBG           (DBG),             // Debug configuration
    .NUMIRQ        (NUMIRQ),          // Number of Interrupts
    .RAR           (RESET_ALL_REGS),  // Reset All Registers
    .SMUL          (SMUL),            // Multiplier configuration
    .SYST          (SYST),            // SysTick
    .WIC           (WIC),             // Wake-up interrupt controller support
    .WICLINES      (WICLINES),        // Supported WIC lines
    .WPT           (WPT)              // Number of DWT comparators
  ) u_slcorem0_integration (
    // System inputs
    .FCLK          (SYS_FCLK),       // FCLK
    .SCLK          (CORE_SCLK),      // SCLK generated from PMU
    .HCLK          (CORE_HCLK),      // HCLK generated from PMU
    .DCLK          (CORE_DCLK),      // DCLK generated from PMU
    .HRESETn       (CORE_HRESETn),
    .DBGRESETn     (CORE_DBGRESETn),
    .SE            (SYS_SCANENABLE),

    // Power management inputs
    .SLEEPHOLDREQn (CORE_SLEEPHOLDREQn),
    .WICENREQ      (CORE_WICENREQ),
    .CDBGPWRUPACK  (CORE_CDBGPWRUPACK),

    // Power management outputs
    .SLEEPHOLDACKn (CORE_SLEEPHOLDACKn),
    .WICENACK      (CORE_WICENACK),

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

    .ECOREVNUM     (20'd0),

    // Systick
    .STCLKEN       (CORE_STCLKEN),
    .STCALIB       (CORE_STCALIB),

    // Debug slave port (DAP connection)
    .SLVADDR       (slv_addr[31:0]),
    .SLVWDATA      (slv_wdata[31:0]),
    .SLVTRANS      (slv_trans[1:0]),
    .SLVWRITE      (slv_write),
    .SLVSIZE       (slv_size[1:0]),
    .SLVRDATA      (slv_rdata[31:0]),
    .SLVREADY      (slv_ready),
    .SLVRESP       (slv_resp),

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
