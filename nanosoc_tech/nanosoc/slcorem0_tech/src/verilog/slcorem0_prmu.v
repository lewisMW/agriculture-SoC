//-----------------------------------------------------------------------------
// SoCLabs SLCore-M0 PRMU - Cortex-M0 CPU Power and Reset Management Unit
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module slcorem0_prmu #(
    parameter CLKGATE_PRESENT = 0
)(
    // Input Clocks and Resets
    input  wire          SYS_FCLK,         // Free running clock
    input  wire          SYS_SYSRESETn,    // System Reset
    input  wire          SYS_SCANENABLE,   // Scan Mode Enable
    input  wire          SYS_TESTMODE,     // Test Mode Enable (Override Synchronisers)
    
    // Generated Clocks and Resets 
    output wire          CORE_SCLK,             // System clock
    output wire          CORE_HCLK,             // AHB Clock
    output wire          CORE_HRESETn,          // AHB Reset
    output wire          CORE_DCLK,             // Debug clock
    output wire          CORE_DBGRESETn,        // Debug reset
    
    output wire          SYS_HCLK,              // Power on reset
    output wire          SYS_HRESETn,           // Power on reset
    output wire          SYS_PORESETn,          // Power on reset
    
    // System Reset Request
    input  wire          SYS_SYSRESETREQ,       // System Reset Request
    
    // Power Management Control Signals
    input  wire          CORE_PMUENABLE,        // PMU Enable from System Register
    input  wire          CORE_WAKEUP,           // Wakeup Signaling from Core
    input  wire          CORE_SLEEPDEEP,        // Debug Power Up Request
    input  wire          CORE_GATEHCLK,         // Control Signal from Core to Control Clock Gating of HCLK
    
    // Power Management Request signals
    input  wire          CORE_CDBGPWRUPREQ,     // Core Debug Power Up Request
    output wire          CORE_WICENREQ,         // WIC enable request from PMU
    output wire          CORE_SLEEPHOLDREQn,    // Core Sleep Hold Request
    
    // System Reset Request Signals
    output wire          CORE_PRMURESETREQ,      // Power and Reset Management System Reset Request
    output wire          CORE_PMUDBGRESETREQ,    // Power Management Unit Debug Reset Request
    
    // Power Management Ackowledge signals
    input  wire          CORE_WICENACK,         // Wake-on-Interrupt Enable ACK from Core
    input  wire          CORE_SLEEPHOLDACKn,    // Sleep Hold Acknowledgement
    output wire          CORE_CDBGPWRUPACK      // Core Debug Power Up Acknowledge
);
    
    // -------------------------------
    // Cortex-M0 Control System Reset Req
    // -------------------------------
    wire     CORE_RSTCTLHRESETREQ;
    wire     CORE_PMUHRESETREQ;
    
    assign   CORE_PRMURESETREQ = CORE_PMUHRESETREQ | CORE_RSTCTLHRESETREQ;
    
    // -------------------------------
    // Core Power Down Detection
    // -------------------------------
    // System Power Down Signals
    wire     CORE_SYSPWRDOWN;
    wire     CORE_SYSPWRDOWNACK;
    
    // Debug Power Down Signals
    wire     CORE_DBGPWRDOWN;
    wire     CORE_DBGPWRDOWNACK;
    
    // In this example system, power control takes place immediately.
    // In a real circuit you might need to add delays in the next two
    // signal assignments for correct operation.
    assign   CORE_SYSPWRDOWNACK = CORE_SYSPWRDOWN;
    assign   CORE_DBGPWRDOWNACK = CORE_DBGPWRDOWN;
    
    // -------------------------------
    // Core Power Management Unit
    // -------------------------------
    // Connectivity - Clock Generation
    wire    CORE_HCLKG; // Gated Core HCLK
    wire    CORE_DCLKG; // Gated Core DCLK
    wire    CORE_SCLKG; // Gated Core SCLK
    
    assign  CORE_HCLK = (CLKGATE_PRESENT==0) ? SYS_FCLK : CORE_HCLKG;
    assign  CORE_DCLK = (CLKGATE_PRESENT==0) ? SYS_FCLK : CORE_DCLKG;
    assign  CORE_SCLK = (CLKGATE_PRESENT==0) ? SYS_FCLK : CORE_SCLKG;
    
    // System HCLK needs to be assigned to System Free-running Clock
    // so other managers can still access bus when CPU is sleeping
    assign SYS_HCLK = SYS_FCLK;
    
    // Power Management Unit Instantiation
    cortexm0_pmu u_cortexm0_pmu ( 
        // Power Management Unit Inputs
        .FCLK             (SYS_FCLK),
        .PORESETn         (SYS_PORESETn),
        .HRESETREQ        (SYS_SYSRESETREQ),     // from Cores / Watchdog / Debug Controller
        .PMUENABLE        (CORE_PMUENABLE),      // from System Controller
        .WICENACK         (CORE_WICENACK),       // from WIC in integration

        .WAKEUP           (CORE_WAKEUP),         // from WIC in integration
        .CDBGPWRUPREQ     (CORE_CDBGPWRUPREQ),

        .SLEEPDEEP        (CORE_SLEEPDEEP),
        .SLEEPHOLDACKn    (CORE_SLEEPHOLDACKn),
        .GATEHCLK         (CORE_GATEHCLK),
        .SYSPWRDOWNACK    (CORE_SYSPWRDOWNACK),
        .DBGPWRDOWNACK    (CORE_DBGPWRDOWNACK),
        .CGBYPASS         (SYS_TESTMODE),

        // Power Management Unit Outputs
        .HCLK             (CORE_HCLKG),
        .DCLK             (CORE_DCLKG),
        .SCLK             (CORE_SCLKG),
        .WICENREQ         (CORE_WICENREQ),
        .CDBGPWRUPACK     (CORE_CDBGPWRUPACK),
        .SYSISOLATEn      ( ),
        .SYSRETAINn       ( ),
        .SYSPWRDOWN       (CORE_SYSPWRDOWN),
        .DBGISOLATEn      ( ),
        .DBGPWRDOWN       (CORE_DBGPWRDOWN),
        .SLEEPHOLDREQn    (CORE_SLEEPHOLDREQn),
        .PMUDBGRESETREQ   (CORE_PMUDBGRESETREQ),
        .PMUHRESETREQ     (CORE_PMUHRESETREQ)
    );
    
    // -------------------------------
    // Reset Control
    // -------------------------------
    slcorem0_rstctrl u_rstctrl (
        // Inputs
        .SYS_GLOBALRESETn    (SYS_SYSRESETn),
        .SYS_FCLK            (SYS_FCLK),
        .SYS_HCLK            (SYS_HCLK),
        .CORE_HCLK           (CORE_HCLK),
        .CORE_DCLK           (CORE_DCLK),
        .SYS_SYSRESETREQ     (SYS_SYSRESETREQ),
        .CORE_PMUHRESETREQ   (CORE_PMUHRESETREQ),
        .CORE_PMUDBGRESETREQ (CORE_PMUDBGRESETREQ),
        .SYS_RSTBYPASS       (SYS_TESTMODE),
        .SYS_SE              (SYS_SCANENABLE),

        // Outputs
        .SYS_HRESETREQ      (CORE_RSTCTLHRESETREQ),
        .SYS_PORESETn       (SYS_PORESETn),
        .SYS_HRESETn        (SYS_HRESETn),
        .CORE_HRESETn       (CORE_HRESETn),
        .CORE_DBGRESETn     (CORE_DBGRESETn)
    );
endmodule