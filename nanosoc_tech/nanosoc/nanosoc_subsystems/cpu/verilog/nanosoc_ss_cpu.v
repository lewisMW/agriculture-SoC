//-----------------------------------------------------------------------------
// NanoSoC CPU Subsystem - Contains CPU Core, Memory and Clock and Reset Control
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_ss_cpu #(
    // System Parameters
    parameter    SYS_ADDR_W     = 32,  // System Address Width
    parameter    SYS_DATA_W     = 32,  // System Data Width
    
    // CPU Parameters
    parameter CLKGATE_PRESENT   = 0,
    parameter BE                = 0,   // 1: Big endian 0: little endian
    parameter BKPT              = 4,   // Number of breakpoint comparators
    parameter DBG               = 1,   // Debug configuration
    parameter NUMIRQ            = 32,  // NUM of IRQ
    parameter SMUL              = 0,   // Multiplier configuration
    parameter SYST              = 1,   // SysTick
    parameter WIC               = 1,   // Wake-up interrupt controller support
    parameter WICLINES          = 34,  // Supported WIC lines
    parameter WPT               = 2,   // Number of DWT comparators
    parameter RESET_ALL_REGS    = 0,   // Do not reset all registers
    parameter INCLUDE_JTAG      = 0,   // Do not Include JTAG feature
    
    // ROM Table Base Address
    parameter [31:0] ROMTABLE_BASE = 32'hE00FF003,  // Defaultly Points to Core ROM Table
    
    // Bootrom 0 Parameters
    parameter    BOOTROM_ADDR_W    = 10,  // Size of Bootrom (Based on Address Width) - Default 1KB
    
    // IMEM 0 Parameters
    parameter    IMEM_RAM_ADDR_W   = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    IMEM_RAM_DATA_W   = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    parameter    IMEM_MEM_FPGA_IMG = "image.hex", // Image to Preload into SRAM
    
    // DMEM 0 Parameters
    parameter    DMEM_RAM_ADDR_W   = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    DMEM_RAM_DATA_W   = 32           // Width of IMEM RAM Data Bus - Default 32 bits
)(
    // System Input Clocks and Resets
    input  wire          SYS_FCLK,              // Free running clock
    input  wire          SYS_SYSRESETn,         // System Reset
    input  wire          SYS_SCANENABLE,        // Scan Mode Enable
    input  wire          SYS_TESTMODE,          // Test Mode Enable (Override Synchronisers)
    
    // System Reset Request Signals
    input  wire          SYS_SYSRESETREQ,       // System Request from System Managers
    output wire          CPU_0_PRMURESETREQ,      // CPU Control Reset Request (PMU and Reset Unit)
    
    // Generated Clocks and Resets 
    output wire          SYS_PORESETn,          // System Power On Reset
    output wire          SYS_HCLK,              // AHB Clock
    output wire          SYS_HRESETn,           // AHB and System reset
    
    // Power Management Signals
    input  wire          CPU_0_PMUENABLE,        // Power Management Enable
    output wire          CPU_0_PMUDBGRESETREQ,   // Power Management Debug Reset Req

    // CPU 0 AHB Lite port
    output wire   [31:0] CPU_0_HADDR,            // Address bus
    output wire    [1:0] CPU_0_HTRANS,           // Transfer type
    output wire          CPU_0_HWRITE,           // Transfer direction
    output wire    [2:0] CPU_0_HSIZE,            // Transfer size
    output wire    [2:0] CPU_0_HBURST,           // Burst type
    output wire    [3:0] CPU_0_HPROT,            // Protection control
    output wire   [31:0] CPU_0_HWDATA,           // Write data
    output wire          CPU_0_HMASTLOCK,        // Locked Sequence
    input  wire   [31:0] CPU_0_HRDATA,           // Read data bus
    input  wire          CPU_0_HREADY,           // HREADY feedback
    input  wire          CPU_0_HRESP,            // Transfer response
    
    // Bootrom 0 AHB Lite port
    input  wire          BOOTROM_0_HSEL,         // Select
    input  wire   [31:0] BOOTROM_0_HADDR,        // Address bus
    input  wire    [1:0] BOOTROM_0_HTRANS,       // Transfer type
    input  wire          BOOTROM_0_HWRITE,       // Transfer direction
    input  wire    [2:0] BOOTROM_0_HSIZE,        // Transfer size
    input  wire    [2:0] BOOTROM_0_HBURST,       // Burst type
    input  wire    [3:0] BOOTROM_0_HPROT,        // Protection control
    input  wire   [31:0] BOOTROM_0_HWDATA,       // Write data
    input  wire          BOOTROM_0_HMASTLOCK,    // Locked Sequence
    input  wire          BOOTROM_0_HREADY,       // HREADY feedback
    output wire   [31:0] BOOTROM_0_HRDATA,       // Read data bus
    output wire          BOOTROM_0_HRESP,        // Transfer response
    output wire          BOOTROM_0_HREADYOUT,    // AHB ready out
    
    // IMEM 0 AHB Lite port
    input  wire          IMEM_0_HSEL,            // Select
    input  wire   [31:0] IMEM_0_HADDR,           // Address bus
    input  wire    [1:0] IMEM_0_HTRANS,          // Transfer type
    input  wire          IMEM_0_HWRITE,          // Transfer direction
    input  wire    [2:0] IMEM_0_HSIZE,           // Transfer size
    input  wire    [2:0] IMEM_0_HBURST,          // Burst type
    input  wire    [3:0] IMEM_0_HPROT,           // Protection control
    input  wire   [31:0] IMEM_0_HWDATA,          // Write data
    input  wire          IMEM_0_HMASTLOCK,       // Locked Sequence
    input  wire          IMEM_0_HREADY,          // HREADY feedback
    output wire   [31:0] IMEM_0_HRDATA,          // Read data bus
    output wire          IMEM_0_HRESP,           // Transfer response
    output wire          IMEM_0_HREADYOUT,       // AHB ready out
    
    // DMEM 0 AHB Lite port
    input  wire          DMEM_0_HSEL,            // Select
    input  wire   [31:0] DMEM_0_HADDR,           // Address bus
    input  wire    [1:0] DMEM_0_HTRANS,          // Transfer type
    input  wire          DMEM_0_HWRITE,          // Transfer direction
    input  wire    [2:0] DMEM_0_HSIZE,           // Transfer size
    input  wire    [2:0] DMEM_0_HBURST,          // Burst type
    input  wire    [3:0] DMEM_0_HPROT,           // Protection control
    input  wire   [31:0] DMEM_0_HWDATA,          // Write data
    input  wire          DMEM_0_HMASTLOCK,       // Locked Sequence
    input  wire          DMEM_0_HREADY,          // HREADY feedback
    output wire   [31:0] DMEM_0_HRDATA,          // Read data bus
    output wire          DMEM_0_HRESP,           // Transfer response
    output wire          DMEM_0_HREADYOUT,       // AHB ready out

    // CPU Sideband signalling
    input  wire          CPU_0_NMI,              // Non-Maskable Interrupt request
    input  wire   [31:0] CPU_0_IRQ,              // Maskable Interrupt requests
    output wire          CPU_0_TXEV,             // Send Event (SEV) output
    input  wire          CPU_0_RXEV,             // Receive Event input
    output wire          CPU_0_LOCKUP,           // Wake up request from WIC
    output wire          CPU_0_SYSRESETREQ,      // System reset request
    
    output wire          CPU_0_SLEEPING,         // Processor status - sleeping
    output wire          CPU_0_SLEEPDEEP,        // Processor status - deep sleep

    // Serial-Wire Debug
    input  wire          CPU_0_SWDI,             // SWD data input
    input  wire          CPU_0_SWCLK,            // SWD clock
    output wire          CPU_0_SWDO,             // SWD data output
    output wire          CPU_0_SWDOEN            // SWD data output enable
);  
    // -------------------------------
    // CPU Core 0 Instantiation
    // -------------------------------
    slcorem0 #(
        .CLKGATE_PRESENT (CLKGATE_PRESENT), // Architectural clock gating
        .BE              (BE),              // Big-endian
        .BKPT            (BKPT),            // Number of breakpoint comparators
        .DBG             (DBG),             // Debug configuration
        .INCLUDE_JTAG    (INCLUDE_JTAG),    // Debug port interface: JTAGnSW
        .NUMIRQ          (NUMIRQ),          // Number of Interrupts
        .RESET_ALL_REGS  (RESET_ALL_REGS),  // Reset All Registers
        .SMUL            (SMUL),            // Multiplier configuration
        .SYST            (SYST),            // SysTick
        .WIC             (WIC),             // Wake-up interrupt controller support
        .WICLINES        (WICLINES),        // Supported WIC lines
        .WPT             (WPT),             // Number of DWT comparators
        .ROMTABLE_BASE   (ROMTABLE_BASE)
    ) u_cpu_0 (
        // System Input Clocks and Resets
        .SYS_FCLK(SYS_FCLK),
        .SYS_SYSRESETn(SYS_SYSRESETn),
        .SYS_SCANENABLE(SYS_SCANENABLE),
        .SYS_TESTMODE(SYS_TESTMODE),
        
        // System Reset Request Signals
        .SYS_SYSRESETREQ(SYS_SYSRESETREQ),
        .CORE_PRMURESETREQ(CPU_0_PRMURESETREQ),
        
        // Generated Clocks and Resets 
        .SYS_PORESETn(SYS_PORESETn),
        .SYS_HCLK(SYS_HCLK),
        .SYS_HRESETn(SYS_HRESETn),
        
        // Power Management Signals
        .CORE_PMUENABLE(CPU_0_PMUENABLE),
        .CORE_PMUDBGRESETREQ(CPU_0_PMUDBGRESETREQ),

        // AHB Lite port
        .HADDR(CPU_0_HADDR),
        .HTRANS(CPU_0_HTRANS),
        .HWRITE(CPU_0_HWRITE),
        .HSIZE(CPU_0_HSIZE),
        .HBURST(CPU_0_HBURST),
        .HPROT(CPU_0_HPROT),
        .HWDATA(CPU_0_HWDATA),
        .HMASTLOCK(CPU_0_HMASTLOCK),
        .HRDATA(CPU_0_HRDATA),
        .HREADY(CPU_0_HREADY),
        .HRESP(CPU_0_HRESP),

        // Sideband CPU signalling
        .CORE_NMI(CPU_0_NMI),
        .CORE_IRQ(CPU_0_IRQ),
        .CORE_TXEV(CPU_0_TXEV),
        .CORE_RXEV(CPU_0_RXEV),
        .CORE_LOCKUP(CPU_0_LOCKUP),
        .CORE_SYSRESETREQ(CPU_0_SYSRESETREQ),
        
        .CORE_SLEEPING(CPU_0_SLEEPING),
        .CORE_SLEEPDEEP(CPU_0_SLEEPDEEP),

        // Serial-Wire Debug
        .CORE_SWDI(CPU_0_SWDI),
        .CORE_SWCLK(CPU_0_SWCLK),
        .CORE_SWDO(CPU_0_SWDO),
        .CORE_SWDOEN(CPU_0_SWDOEN)
    );
    
    // ----------------------------------
    // CPU 0 Bootrom Region Instantiation
    // ----------------------------------
    nanosoc_region_bootrom_0 #(
        .SYS_ADDR_W      (SYS_ADDR_W),
        .SYS_DATA_W      (SYS_DATA_W),
        .BOOTROM_ADDR_W  (BOOTROM_ADDR_W)
    ) u_region_bootrom_0 (
        // Clock (No Reset on Bootrom)
        .HCLK(SYS_HCLK),

        // AHB connection to Initiator
        .HSEL(BOOTROM_0_HSEL),
        .HADDR(BOOTROM_0_HADDR),
        .HTRANS(BOOTROM_0_HTRANS),
        .HSIZE(BOOTROM_0_HSIZE),
        .HPROT(BOOTROM_0_HPROT),
        .HWRITE(BOOTROM_0_HWRITE),
        .HREADY(BOOTROM_0_HREADY),
        .HWDATA(BOOTROM_0_HWDATA),

        // Outputs
        .HREADYOUT(BOOTROM_0_HREADYOUT),
        .HRESP(BOOTROM_0_HRESP),
        .HRDATA(BOOTROM_0_HRDATA)
    );
    
    // -----------------------------------------------
    // CPU 0 Instruction Memory Region Instantiation
    // -----------------------------------------------
    nanosoc_region_imem_0 #(
        .SYS_ADDR_W        (SYS_ADDR_W),
        .SYS_DATA_W        (SYS_DATA_W),
        .IMEM_RAM_ADDR_W   (IMEM_RAM_ADDR_W),
        .IMEM_RAM_DATA_W   (IMEM_RAM_DATA_W),
        .IMEM_MEM_FPGA_IMG (IMEM_MEM_FPGA_IMG)
    ) u_region_imem_0 (
        // Clock and Reset
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB connection to Initiator
        .HSEL(IMEM_0_HSEL),
        .HADDR(IMEM_0_HADDR),
        .HTRANS(IMEM_0_HTRANS),
        .HSIZE(IMEM_0_HSIZE),
        .HPROT(IMEM_0_HPROT),
        .HWRITE(IMEM_0_HWRITE),
        .HREADY(IMEM_0_HREADY),
        .HWDATA(IMEM_0_HWDATA),

        // Outputs
        .HREADYOUT(IMEM_0_HREADYOUT),
        .HRESP(IMEM_0_HRESP),
        .HRDATA(IMEM_0_HRDATA)
    );
    
    // ---------------------------------------
    // CPU 0 Data Memory Region Instantiation
    // ---------------------------------------
    nanosoc_region_dmem_0 #(
        .SYS_ADDR_W        (SYS_ADDR_W),
        .SYS_DATA_W        (SYS_DATA_W),
        .DMEM_RAM_ADDR_W   (DMEM_RAM_ADDR_W),
        .DMEM_RAM_DATA_W   (DMEM_RAM_DATA_W)
    ) u_region_dmem_0 (
        // Clock and Reset
        .HCLK(SYS_HCLK),
        .HRESETn(SYS_HRESETn),

        // AHB connection to Initiator
        .HSEL(DMEM_0_HSEL),
        .HADDR(DMEM_0_HADDR),
        .HTRANS(DMEM_0_HTRANS),
        .HSIZE(DMEM_0_HSIZE),
        .HPROT(DMEM_0_HPROT),
        .HWRITE(DMEM_0_HWRITE),
        .HREADY(DMEM_0_HREADY),
        .HWDATA(DMEM_0_HWDATA),

        // Outputs
        .HREADYOUT(DMEM_0_HREADYOUT),
        .HRESP(DMEM_0_HRESP),
        .HRDATA(DMEM_0_HRDATA)
    );
    
    
endmodule