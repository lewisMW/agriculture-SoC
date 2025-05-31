//-----------------------------------------------------------------------------
// NanoSoC System Integration Level
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

module nanosoc_system #(
    // System Parameters
    parameter    SYS_ADDR_W           = 32,  // System Address Width
    parameter    SYS_DATA_W           = 32,  // System Data Width
    
    // Widths of System Peripheral APB Subsystem
    parameter    APB_ADDR_W           = 12,  // APB Peripheral Address Width
    parameter    APB_DATA_W           = 32,  // APB Peripheral Data Width
    
    // Bootrom 0 Parameters
    parameter    BOOTROM_ADDR_W       = 10,          // Size of Bootrom (Based on Address Width) - Default 1KB
    
    // IMEM 0 Parameters
    parameter    IMEM_RAM_ADDR_W      = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    IMEM_RAM_DATA_W      = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    parameter    IMEM_MEM_FPGA_IMG    = "image.hex", // Image to Preload into SRAM
    
    // DMEM 0 Parameters
    parameter    DMEM_RAM_ADDR_W      = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    DMEM_RAM_DATA_W      = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    
    // Expansion SRAM Low Parameters
    parameter    EXPRAM_L_RAM_ADDR_W  = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    EXPRAM_L_RAM_DATA_W  = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    
    // Expansion SRAM High Parameters
    parameter    EXPRAM_H_RAM_ADDR_W  = 14,          // Width of IMEM RAM Address - Default 16KB
    parameter    EXPRAM_H_RAM_DATA_W  = 32,          // Width of IMEM RAM Data Bus - Default 32 bits
    
    // CPU Parameters
    parameter CLKGATE_PRESENT         = 0,
    parameter BE                      = 0,   // 1: Big endian 0: little endian
    parameter BKPT                    = 4,   // Number of breakpoint comparators
    parameter DBG                     = 1,   // Debug configuration
    parameter NUMIRQ                  = 32,  // NUM of IRQ
    parameter SMUL                    = 0,   // Multiplier configuration
    parameter SYST                    = 1,   // SysTick
    parameter WIC                     = 1,   // Wake-up interrupt controller support
    parameter WICLINES                = 34,  // Supported WIC lines
    parameter WPT                     = 2,   // Number of DWT comparators
    parameter RESET_ALL_REGS          = 0,   // Do not reset all registers
    parameter INCLUDE_JTAG            = 0,   // Do not Include JTAG feature
      
    // DMA Parameters  
    parameter    DMAC_0_CHANNEL_NUM   = 4,   // DMAC 0 Number of DMA Channels : Add EXTDATA TX, RX
    parameter    DMAC_1_CHANNEL_NUM   = 2,   // DMAC 1 Number of DMA Channels
      
    // SoCDebug Parameters  
    parameter         PROMPT_CHAR     = "]",
    parameter integer FT1248_WIDTH	  = 1,     // FTDI Interface 1,2,4 width supported
    parameter integer FT1248_CLKON	  = 1,     // FTDI clock always on - else quiet when no access
    parameter [7:0]   FT1248_CLKDIV	  = 8'd15, // Clock Division Ratio (4x4 for RP-PIO)
    
    // Address of System ROM Table
    parameter    SYSTABLE_BASE        = 32'hF000_0000,  // Base Address of System ROM Table
    
    // SoCLabs Manufacture ID
    parameter    SOCLABS_JEPID = 7'h51, //- SL (SoCLabs)
    
    // NanoSoC Part and Revision Numbers
    parameter    NANOSOC_PARTNUMBER = 12'h001,
    parameter    NANOSOC_REVISION   = 4'h1
) (
    // Free-running and Crystal Clock Output
    input  wire                     SYS_CLK,              // System Input Clock
    input  wire                     SYS_SYSRESETn,        // System Reset
    output wire                     SYS_XTALCLK_OUT,      // Crystal Clock Output
    
    // Scan Wiring
    input  wire                     SYS_SCANENABLE,      // Scan Mode Enable
    input  wire                     SYS_TESTMODE,        // Test Mode Enable (Override Synchronisers)
    input  wire                     SYS_SCANINHCLK,      // HCLK scan input  wire
    output wire                     SYS_SCANOUTHCLK,     // Scan Chain Output
    
    // Serial-Wire Debug
    input  wire                     CPU_0_SWDI,         // SWD data input
    input  wire                     CPU_0_SWCLK,        // SWD clock
    output wire                     CPU_0_SWDO,         // SWD data output
    output wire                     CPU_0_SWDOEN,       // SWD data output enable
    
    // GPIO
    input  wire               [15:0] P0_IN,            // GPIO 0 inputs
    output wire               [15:0] P0_OUT,           // GPIO 0 outputs
    output wire               [15:0] P0_OUTEN,         // GPIO 0 output enables
    input  wire               [15:0] P1_IN,            // GPIO 1 inputs
    output wire               [15:0] P1_OUT,           // GPIO 1 outputs
    output wire               [15:0] P1_OUTEN          // GPIO 1 output enables
);

// system General purpose I/O ports - before NANOSOC specific mappings
    wire    [15:0] SYS_P0_ALTFUNC;       // GPIO 0 alternate function (pin mux)
    wire    [15:0] SYS_P1_ALTFUNC;       // GPIO 1 alternate function (pin mux)
    wire    [15:0] SYS_P0_IN;            // GPIO 0 inputs
    wire    [15:0] SYS_P0_OUT;           // GPIO 0 outputs
    wire    [15:0] SYS_P0_OUTEN;         // GPIO 0 output enables
    wire    [15:0] SYS_P1_IN;            // GPIO 1 inputs
    wire    [15:0] SYS_P1_OUT;           // GPIO 1 outputs
    wire    [15:0] SYS_P1_OUTEN;         // GPIO 1 output enables
    wire    [15:0] SYS_P1_OUT_MUX;       // GPIO 1 Output Port Drive
    wire    [15:0] SYS_P1_OUT_EN_MUX;    // Active High output drive enable (pad tech dependent)

    wire                     FT_CLK_O;    // SCLK
    wire                     FT_SSN_O;    // SS_N
    wire                     FT_MISO_I;   // MISO
    wire  [FT1248_WIDTH-1:0] FT_MIOSIO_O; // MIOSIO tristate output when enabled
    wire  [FT1248_WIDTH-1:0] FT_MIOSIO_E; // MIOSIO tristate output enable (active hi)
    wire  [FT1248_WIDTH-1:0] FT_MIOSIO_Z; // MIOSIO tristate output enable (active lo)
    wire  [FT1248_WIDTH-1:0] FT_MIOSIO_I; // MIOSIO tristate input

    //--------------------------
    // Local Parameters
    //--------------------------
    localparam    DMAC_0_CFG_ADDR_W  = APB_ADDR_W;  // DMAC 0 Configuration Port Address Width
    localparam    DMAC_1_CFG_ADDR_W  = APB_ADDR_W;  // DMAC 1 Configuration Port Address Width
    
    //--------------------------
    // System Wiring
    //--------------------------
    // System Input Clocks and Resets
    wire          SYS_FCLK;              // Free running clock

    // System Reset Request Signals
    wire          SYS_SYSRESETREQ;       // System Request from System Managers
        
    // AHB Clocks and Resets 
    wire          SYS_PORESETn;          // System Power On Reset
    wire          SYS_HCLK;              // AHB Clock
    wire          SYS_HRESETn;           // AHB and System reset
        
    // APB Clocks and Resets
    wire          SYS_PCLK;   
    wire          SYS_PCLKG;  
    wire          SYS_PRESETn;
    wire          SYS_PCLKEN;            // APB clock enable
    
    // Power Management Signals
    wire          SYS_PMUENABLE;        // Power Management Enable
    wire          SYS_PMUDBGRESETREQ;   // Power Management Debug Reset Req

    // Sysio APB driving signals - To all APB Components
    wire                   SYSIO_PENABLE;
    wire                   SYSIO_PWRITE;
    wire  [APB_ADDR_W-1:0] SYSIO_PADDR;
    wire  [APB_DATA_W-1:0] SYSIO_PWDATA;
    
    // CPU sideband signalling - TO CPU Subsystem
    wire           [31:0]  SYS_APB_IRQ;      // apbsubsys_interrupt;
    wire           [15:0]  SYS_GPIO0_IRQ;    // GPIO 0 IRQs
    wire           [15:0]  SYS_GPIO1_IRQ;    // GPIO 0 IRQs
    wire                   SYS_NMI;          // watchdog_interrupt;
    
    // Combined CPU Signals
    wire          CPU_SYSRESETREQ;       // System Request from CPUs
    wire          CPU_PRMURESETREQ;      // System Request from CPUs
    wire          CPU_LOCKUP;            // Combined Lockup from CPUs
    wire          CPU_SLEEPDEEP;         // Combined Sleepdeep from CPUs
    wire          CPU_SLEEPING;          // Combined sleeping from CPUs


    // ADP GPIO interface
    wire               [7:0] ADP_GPO8;
    wire               [7:0] ADP_GPI8 = ADP_GPO8;
        
    //--------------------------
    // CPU Subsystem
    //--------------------------
    
    // Internal Wiring
    //--------------------------
    
    // CPU 0 AHB Wiring - To Interconnect Subsystem
    wire   [31:0] CPU_0_HADDR;            // Address bus
    wire    [1:0] CPU_0_HTRANS;           // Transfer type
    wire          CPU_0_HWRITE;           // Transfer direction
    wire    [2:0] CPU_0_HSIZE;            // Transfer size
    wire    [2:0] CPU_0_HBURST;           // Burst type
    wire    [3:0] CPU_0_HPROT;            // Protection control
    wire   [31:0] CPU_0_HWDATA;           // Write data
    wire          CPU_0_HMASTLOCK;        // Locked Sequence
    wire   [31:0] CPU_0_HRDATA;           // Read data bus
    wire          CPU_0_HREADY;           // HREADY feedback
    wire          CPU_0_HRESP;            // Transfer response
    
    // Bootrom 0 Region Wiring - To Interconnect Subsystem
    wire          BOOTROM_0_HSEL;         // Select
    wire   [31:0] BOOTROM_0_HADDR;        // Address bus
    wire    [1:0] BOOTROM_0_HTRANS;       // Transfer type
    wire          BOOTROM_0_HWRITE;       // Transfer direction
    wire    [2:0] BOOTROM_0_HSIZE;        // Transfer size
    wire    [2:0] BOOTROM_0_HBURST;       // Burst type
    wire    [3:0] BOOTROM_0_HPROT;        // Protection control
    wire   [31:0] BOOTROM_0_HWDATA;       // Write data
    wire          BOOTROM_0_HMASTLOCK;    // Locked Sequence
    wire   [31:0] BOOTROM_0_HRDATA;       // Read data bus
    wire          BOOTROM_0_HREADY;       // HREADY feedback
    wire          BOOTROM_0_HREADYOUT;    // HREADY feedback
    wire          BOOTROM_0_HRESP;        // Transfer response
    
    // Instruction Memory 0 Region Wiring - To Interconnect Subsystem
    wire          IMEM_0_HSEL;            // Select
    wire   [31:0] IMEM_0_HADDR;           // Address bus
    wire    [1:0] IMEM_0_HTRANS;          // Transfer type
    wire          IMEM_0_HWRITE;          // Transfer direction
    wire    [2:0] IMEM_0_HSIZE;           // Transfer size
    wire    [2:0] IMEM_0_HBURST;          // Burst type
    wire    [3:0] IMEM_0_HPROT;           // Protection control
    wire   [31:0] IMEM_0_HWDATA;          // Write data
    wire          IMEM_0_HMASTLOCK;       // Locked Sequence
    wire   [31:0] IMEM_0_HRDATA;          // Read data bus
    wire          IMEM_0_HREADY;          // HREADY feedback
    wire          IMEM_0_HREADYOUT;       // HREADY feedback
    wire          IMEM_0_HRESP;           // Transfer response
    
    // Data Memory 0 Region Wiring - To Interconnect Subsystem
    wire          DMEM_0_HSEL;            // Select
    wire   [31:0] DMEM_0_HADDR;           // Address bus
    wire    [1:0] DMEM_0_HTRANS;          // Transfer type
    wire          DMEM_0_HWRITE;          // Transfer direction
    wire    [2:0] DMEM_0_HSIZE;           // Transfer size
    wire    [2:0] DMEM_0_HBURST;          // Burst type
    wire    [3:0] DMEM_0_HPROT;           // Protection control
    wire   [31:0] DMEM_0_HWDATA;          // Write data
    wire          DMEM_0_HMASTLOCK;       // Locked Sequence
    wire   [31:0] DMEM_0_HRDATA;          // Read data bus
    wire          DMEM_0_HREADY;          // HREADY feedback
    wire          DMEM_0_HREADYOUT;       // HREADY feedback
    wire          DMEM_0_HRESP;           // Transfer response
    
    // CPU Sideband Signaling  - To System Control Subsystem
    wire          CPU_0_NMI;              // Non-Maskable Interrupt request
    wire   [31:0] CPU_0_IRQ;              // Maskable Interrupt requests
    wire          CPU_0_TXEV;             // Send Event (SEV) output
    wire          CPU_0_RXEV;             // Receive Event input
    wire          CPU_0_LOCKUP;           // Wake up request from WIC
    wire          CPU_0_SYSRESETREQ;      // System reset request
    wire          CPU_0_PRMURESETREQ;     // PRMU reset request
    wire          CPU_0_PMUENABLE;        // PRMU Enable
    wire          CPU_0_PMUDBGRESETREQ;   // Power Management Debug Reset Req

    wire          CPU_0_SLEEPING;         // Processor status - sleeping
    wire          CPU_0_SLEEPDEEP;        // Processor status - deep sleep
    
    // Interrupt Wiring
    //--------------------------
    assign CPU_0_NMI = SYS_NMI;
    
    // PRMU Wiring
    //--------------------------
    assign CPU_0_PMUENABLE = SYS_PMUENABLE;
    
    // Instantiate Subsystem
    //--------------------------

    nanosoc_ss_cpu #(
        .CLKGATE_PRESENT   (CLKGATE_PRESENT),
        .BE                (BE),
        .BKPT              (BKPT),
        .DBG               (DBG),
        .NUMIRQ            (NUMIRQ),
        .SMUL              (SMUL),
        .SYST              (SYST),
        .WIC               (WIC),
        .WICLINES          (WICLINES),
        .WPT               (WPT),
        .RESET_ALL_REGS    (RESET_ALL_REGS),
        .INCLUDE_JTAG      (INCLUDE_JTAG),
        .ROMTABLE_BASE     (SYSTABLE_BASE),
        .BOOTROM_ADDR_W    (BOOTROM_ADDR_W),
        .IMEM_RAM_ADDR_W   (IMEM_RAM_ADDR_W),
        .IMEM_RAM_DATA_W   (IMEM_RAM_DATA_W),
        .IMEM_MEM_FPGA_IMG (IMEM_MEM_FPGA_IMG),
        .DMEM_RAM_ADDR_W   (DMEM_RAM_ADDR_W),
        .DMEM_RAM_DATA_W   (DMEM_RAM_DATA_W)
    ) u_ss_cpu (
        // System Input Clocks and Resets
        .SYS_FCLK(SYS_FCLK),              
        .SYS_SYSRESETn(SYS_SYSRESETn),         
        .SYS_SCANENABLE(SYS_SCANENABLE),        
        .SYS_TESTMODE(SYS_TESTMODE),          
        
        // System Reset Request Signals
        .SYS_SYSRESETREQ(SYS_SYSRESETREQ),       
        .CPU_0_PRMURESETREQ(CPU_0_PRMURESETREQ),      
        
        // Generated Clocks and Resets 
        .SYS_PORESETn(SYS_PORESETn),          
        .SYS_HCLK(SYS_HCLK),              
        .SYS_HRESETn(SYS_HRESETn),           
        
        // Power Management Signals
        .CPU_0_PMUENABLE(CPU_0_PMUENABLE),        
        .CPU_0_PMUDBGRESETREQ(CPU_0_PMUDBGRESETREQ),   

        // CPU 0 AHB Lite port
        .CPU_0_HADDR(CPU_0_HADDR),            
        .CPU_0_HTRANS(CPU_0_HTRANS),           
        .CPU_0_HWRITE(CPU_0_HWRITE),           
        .CPU_0_HSIZE(CPU_0_HSIZE),            
        .CPU_0_HBURST(CPU_0_HBURST),          
        .CPU_0_HPROT(CPU_0_HPROT),            
        .CPU_0_HWDATA(CPU_0_HWDATA),           
        .CPU_0_HMASTLOCK(CPU_0_HMASTLOCK),        
        .CPU_0_HRDATA(CPU_0_HRDATA),           
        .CPU_0_HREADY(CPU_0_HREADY),           
        .CPU_0_HRESP(CPU_0_HRESP),            

        // Bootrom 0 AHB Lite port
        .BOOTROM_0_HSEL(BOOTROM_0_HSEL),        
        .BOOTROM_0_HADDR(BOOTROM_0_HADDR),        
        .BOOTROM_0_HTRANS(BOOTROM_0_HTRANS),       
        .BOOTROM_0_HWRITE(BOOTROM_0_HWRITE),       
        .BOOTROM_0_HSIZE(BOOTROM_0_HSIZE),        
        .BOOTROM_0_HBURST(BOOTROM_0_HBURST),       
        .BOOTROM_0_HPROT(BOOTROM_0_HPROT),        
        .BOOTROM_0_HWDATA(BOOTROM_0_HWDATA),       
        .BOOTROM_0_HMASTLOCK(BOOTROM_0_HMASTLOCK),    
        .BOOTROM_0_HRDATA(BOOTROM_0_HRDATA),       
        .BOOTROM_0_HREADY(BOOTROM_0_HREADY),       
        .BOOTROM_0_HRESP(BOOTROM_0_HRESP),        
        .BOOTROM_0_HREADYOUT(BOOTROM_0_HREADYOUT),        

        // IMEM 0 AHB Lite port
        .IMEM_0_HSEL(IMEM_0_HSEL),           
        .IMEM_0_HADDR(IMEM_0_HADDR),           
        .IMEM_0_HTRANS(IMEM_0_HTRANS),          
        .IMEM_0_HWRITE(IMEM_0_HWRITE),          
        .IMEM_0_HSIZE(IMEM_0_HSIZE),           
        .IMEM_0_HBURST(IMEM_0_HBURST),          
        .IMEM_0_HPROT(IMEM_0_HPROT),           
        .IMEM_0_HWDATA(IMEM_0_HWDATA),          
        .IMEM_0_HMASTLOCK(IMEM_0_HMASTLOCK),       
        .IMEM_0_HRDATA(IMEM_0_HRDATA),          
        .IMEM_0_HREADY(IMEM_0_HREADY),          
        .IMEM_0_HRESP(IMEM_0_HRESP),           
        .IMEM_0_HREADYOUT(IMEM_0_HREADYOUT),           
        
        // DMEM 0 AHB Lite port
        .DMEM_0_HSEL(DMEM_0_HSEL),           
        .DMEM_0_HADDR(DMEM_0_HADDR),           
        .DMEM_0_HTRANS(DMEM_0_HTRANS),          
        .DMEM_0_HWRITE(DMEM_0_HWRITE),          
        .DMEM_0_HSIZE(DMEM_0_HSIZE),           
        .DMEM_0_HBURST(DMEM_0_HBURST),          
        .DMEM_0_HPROT(DMEM_0_HPROT),           
        .DMEM_0_HWDATA(DMEM_0_HWDATA),          
        .DMEM_0_HMASTLOCK(DMEM_0_HMASTLOCK),       
        .DMEM_0_HRDATA(DMEM_0_HRDATA),          
        .DMEM_0_HREADY(DMEM_0_HREADY),          
        .DMEM_0_HRESP(DMEM_0_HRESP),           
        .DMEM_0_HREADYOUT(DMEM_0_HREADYOUT),           

        // CPU Sideband signalling
        .CPU_0_NMI(CPU_0_NMI),              
        .CPU_0_IRQ(CPU_0_IRQ),              
        .CPU_0_TXEV(CPU_0_TXEV),             
        .CPU_0_RXEV(CPU_0_RXEV),             
        .CPU_0_LOCKUP(CPU_0_LOCKUP),           
        .CPU_0_SYSRESETREQ(CPU_0_SYSRESETREQ),      

        .CPU_0_SLEEPING(CPU_0_SLEEPING),         
        .CPU_0_SLEEPDEEP(CPU_0_SLEEPDEEP),        

        // Serial-Wire Debug
        .CPU_0_SWDI(CPU_0_SWDI),             
        .CPU_0_SWCLK(CPU_0_SWCLK),            
        .CPU_0_SWDO(CPU_0_SWDO),             
        .CPU_0_SWDOEN(CPU_0_SWDOEN)            
    );

    //--------------------------
    // DMA Subsystem
    //--------------------------
    
    // Internal Wiring
    //--------------------------
    
    // DMAC 0 AHB Lite Port  - To Interconnect Subsystem
    wire          [SYS_ADDR_W-1:0] DMAC_0_HADDR;       // Address bus
    wire                     [1:0] DMAC_0_HTRANS;      // Transfer type
    wire                           DMAC_0_HWRITE;      // Transfer direction
    wire                     [2:0] DMAC_0_HSIZE;       // Transfer size
    wire                     [2:0] DMAC_0_HBURST;      // Burst type
    wire                     [3:0] DMAC_0_HPROT;       // Protection control
    wire          [SYS_DATA_W-1:0] DMAC_0_HWDATA;      // Write data
    wire                           DMAC_0_HMASTLOCK;   // Locked Sequence
    wire          [SYS_DATA_W-1:0] DMAC_0_HRDATA;      // Read data bus
    wire                           DMAC_0_HREADY;      // HREADY feedback
    wire                           DMAC_0_HRESP;       // Transfer response
    
    // DMAC 0 APB Configurtation Port - To System Control Subsystem
    wire                           DMAC_0_PSEL;        // APB peripheral select
    wire          [SYS_DATA_W-1:0] DMAC_0_PRDATA;      // APB read data
    wire                           DMAC_0_PREADY;      // APB Ready Signal
    wire                           DMAC_0_PSLVERR;     // APB Error Signal
    
    // DMAC 0 DMA Request and Status Port - To Expansion Subsystem
    wire  [DMAC_0_CHANNEL_NUM-1:0] DMAC_0_DMA_REQ;     // DMA transfer request
    wire  [DMAC_0_CHANNEL_NUM-1:0] DMAC_0_DMA_DONE;    // DMA transfer done
    wire                           DMAC_0_DMA_ERR;     // DMA slave response not OK

    // DMAC 1 AHB Lite Port  - To Interconnect Subsystem
    wire          [SYS_ADDR_W-1:0] DMAC_1_HADDR;       // Address bus
    wire                     [1:0] DMAC_1_HTRANS;      // Transfer type
    wire                           DMAC_1_HWRITE;      // Transfer direction
    wire                     [2:0] DMAC_1_HSIZE;       // Transfer size
    wire                     [2:0] DMAC_1_HBURST;      // Burst type
    wire                     [3:0] DMAC_1_HPROT;       // Protection control
    wire          [SYS_DATA_W-1:0] DMAC_1_HWDATA;      // Write data
    wire                           DMAC_1_HMASTLOCK;   // Locked Sequence
    wire          [SYS_DATA_W-1:0] DMAC_1_HRDATA;      // Read data bus
    wire                           DMAC_1_HREADY;      // HREADY feedback
    wire                           DMAC_1_HRESP;       // Transfer response
    
    // DMAC 1 APB Configurtation Port - To System Control Subsystem
    wire                           DMAC_1_PSEL;        // APB peripheral select
    wire                           DMAC_1_PSEL_HI;
    wire          [SYS_DATA_W-1:0] DMAC_1_PRDATA;      // APB read data
    wire                           DMAC_1_PREADY;      // APB Ready Signal
    wire                           DMAC_1_PSLVERR;     // APB Error Signal
    
    // DMAC 1 DMA Request and Status Port - To Expansion Subsystem
    wire  [DMAC_1_CHANNEL_NUM-1:0] DMAC_1_DMA_REQ;     // DMA transfer request
    wire  [DMAC_1_CHANNEL_NUM-1:0] DMAC_1_DMA_DONE;    // DMA transfer done
    wire                           DMAC_1_DMA_ERR;     // DMA slave response not OK
    
    
    // DMA Request Wiring
    //--------------------------
    
    wire   DMAC_ANY_DONE;
    wire   DMAC_ANY_ERROR;
    
    wire   DMAC_0_ANY_DONE;
    wire   DMAC_1_ANY_DONE;
    
    assign DMAC_0_ANY_DONE = |DMAC_0_DMA_DONE;
    assign DMAC_1_ANY_DONE = |DMAC_1_DMA_DONE;
    
    assign DMAC_ANY_DONE   = DMAC_0_ANY_DONE | DMAC_1_ANY_DONE;
    assign DMAC_ANY_ERROR  = DMAC_0_DMA_ERR  | DMAC_1_DMA_ERR;
    
    assign DMAC_1_DMA_REQ = {DMAC_1_CHANNEL_NUM{1'b0}};
    
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
    //  DMAC Channel 0 AXI stream out
    wire                     DMAC_STR_OUT_0_TVALID;
    wire                     DMAC_STR_OUT_0_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_0_TDATA;
    wire [4-1:0]            DMAC_STR_OUT_0_TSTRB;
    wire                     DMAC_STR_OUT_0_TLAST;
//  DMAC Channel 0 AXI Stream in
    wire                     DMAC_STR_IN_0_TVALID;
    wire                     DMAC_STR_IN_0_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_IN_0_TDATA;
    wire [4-1:0]            DMAC_STR_IN_0_TSTRB;
    wire                     DMAC_STR_IN_0_TLAST;
    wire                     DMAC_STR_IN_0_FLUSH;
//  DMAC Channel 1 AXI Stream out
    wire                     DMAC_STR_OUT_1_TVALID;
    wire                     DMAC_STR_OUT_1_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_1_TDATA;
    wire [4-1:0]            DMAC_STR_OUT_1_TSTRB;
    wire                     DMAC_STR_OUT_1_TLAST;
//  DMAC Channel 1 AXI Stream out
    wire                     DMAC_STR_IN_1_TVALID;
    wire                     DMAC_STR_IN_1_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_IN_1_TDATA;
    wire [4-1:0]            DMAC_STR_IN_1_TSTRB;
    wire                     DMAC_STR_IN_1_TLAST;
    wire                     DMAC_STR_IN_1_FLUSH;
`endif
`ifdef DMA350_STREAM_3
//  DMAC Channel 2 AXI Stream out
    wire                     DMAC_STR_OUT_2_TVALID;
    wire                     DMAC_STR_OUT_2_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_OUT_2_TDATA;
    wire [4-1:0]            DMAC_STR_OUT_2_TSTRB;
    wire                     DMAC_STR_OUT_2_TLAST;
//  DMAC Channel 2 AXI Stream out
    wire                     DMAC_STR_IN_2_TVALID;
    wire                     DMAC_STR_IN_2_TREADY;
    wire [SYS_DATA_W-1:0]    DMAC_STR_IN_2_TDATA;
    wire [4-1:0]            DMAC_STR_IN_2_TSTRB;
    wire                     DMAC_STR_IN_2_TLAST;
    wire                     DMAC_STR_IN_2_FLUSH;
`endif
`endif

    // Instantiate Subsystem
    //--------------------------
    
    nanosoc_ss_dma #(
        // System Parameters
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        
        // DMA Parameters
        .DMAC_0_CFG_ADDR_W(DMAC_0_CFG_ADDR_W),
        .DMAC_1_CFG_ADDR_W(DMAC_1_CFG_ADDR_W),
        .DMAC_0_CHANNEL_NUM(DMAC_0_CHANNEL_NUM),
        .DMAC_1_CHANNEL_NUM(DMAC_1_CHANNEL_NUM)
    ) u_ss_dma (
        // System AHB Clocks and Resets
        .SYS_HCLK(SYS_HCLK),
        .SYS_HRESETn(SYS_HRESETn),
        .SYS_PCLKEN(SYS_PCLKEN),
        
        // DMAC 0 AHB Lite Port
        .DMAC_0_HADDR(DMAC_0_HADDR),
        .DMAC_0_HTRANS(DMAC_0_HTRANS),
        .DMAC_0_HWRITE(DMAC_0_HWRITE),
        .DMAC_0_HSIZE(DMAC_0_HSIZE),
        .DMAC_0_HBURST(DMAC_0_HBURST),
        .DMAC_0_HPROT(DMAC_0_HPROT),
        .DMAC_0_HWDATA(DMAC_0_HWDATA),
        .DMAC_0_HMASTLOCK(DMAC_0_HMASTLOCK),
        .DMAC_0_HRDATA(DMAC_0_HRDATA),
        .DMAC_0_HREADY(DMAC_0_HREADY),
        .DMAC_0_HRESP(DMAC_0_HRESP),
        
        // DMAC 0 APB Configurtation Port
        .DMAC_0_PSEL(DMAC_0_PSEL),
        .DMAC_0_PEN(SYSIO_PENABLE),
        .DMAC_0_PWRITE(SYSIO_PWRITE),
        .DMAC_0_PADDR(SYSIO_PADDR),
        .DMAC_0_PWDATA(SYSIO_PWDATA),
        .DMAC_0_PRDATA(DMAC_0_PRDATA),
        .DMAC_0_PREADY(DMAC_0_PREADY),
        .DMAC_0_PSLVERR(DMAC_0_PSLVERR),
        
        // DMAC 0 DMA Request and Status Port
        .DMAC_0_DMA_REQ(DMAC_0_DMA_REQ),
        .DMAC_0_DMA_DONE(DMAC_0_DMA_DONE),
        .DMAC_0_DMA_ERR(DMAC_0_DMA_ERR),
        
        // DMAC 1 AHB Lite Port
        .DMAC_1_HADDR(DMAC_1_HADDR),
        .DMAC_1_HTRANS(DMAC_1_HTRANS),
        .DMAC_1_HWRITE(DMAC_1_HWRITE),
        .DMAC_1_HSIZE(DMAC_1_HSIZE),
        .DMAC_1_HBURST(DMAC_1_HBURST),
        .DMAC_1_HPROT(DMAC_1_HPROT),
        .DMAC_1_HWDATA(DMAC_1_HWDATA),
        .DMAC_1_HMASTLOCK(DMAC_1_HMASTLOCK),
        .DMAC_1_HRDATA(DMAC_1_HRDATA),
        .DMAC_1_HREADY(DMAC_1_HREADY),
        .DMAC_1_HRESP(DMAC_1_HRESP),
        
        // DMAC 1 APB Configurtation Port
        .DMAC_1_PSEL(DMAC_1_PSEL),
        .DMAC_1_PSEL_HI(DMAC_1_PSEL_HI),
        .DMAC_1_PEN(SYSIO_PENABLE),
        .DMAC_1_PWRITE(SYSIO_PWRITE),
        .DMAC_1_PADDR(SYSIO_PADDR),
        .DMAC_1_PWDATA(SYSIO_PWDATA),
        .DMAC_1_PRDATA(DMAC_1_PRDATA),
        .DMAC_1_PREADY(DMAC_1_PREADY),
        .DMAC_1_PSLVERR(DMAC_1_PSLVERR),
        
`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2

        .DMAC_STR_OUT_0_TVALID(DMAC_STR_OUT_0_TVALID),
        .DMAC_STR_OUT_0_TREADY(DMAC_STR_OUT_0_TREADY),
        .DMAC_STR_OUT_0_TDATA(DMAC_STR_OUT_0_TDATA),
        .DMAC_STR_OUT_0_TSTRB(DMAC_STR_OUT_0_TSTRB),
        .DMAC_STR_OUT_0_TLAST(DMAC_STR_OUT_0_TLAST),

        .DMAC_STR_IN_0_TVALID(DMAC_STR_IN_0_TVALID),
        .DMAC_STR_IN_0_TREADY(DMAC_STR_IN_0_TREADY),
        .DMAC_STR_IN_0_TDATA(DMAC_STR_IN_0_TDATA),
        .DMAC_STR_IN_0_TSTRB(DMAC_STR_IN_0_TSTRB),
        .DMAC_STR_IN_0_TLAST(DMAC_STR_IN_0_TLAST),
        .DMAC_STR_IN_0_FLUSH(DMAC_STR_IN_0_FLUSH),

        .DMAC_STR_OUT_1_TVALID(DMAC_STR_OUT_1_TVALID),
        .DMAC_STR_OUT_1_TREADY(DMAC_STR_OUT_1_TREADY),
        .DMAC_STR_OUT_1_TDATA(DMAC_STR_OUT_1_TDATA),
        .DMAC_STR_OUT_1_TSTRB(DMAC_STR_OUT_1_TSTRB),
        .DMAC_STR_OUT_1_TLAST(DMAC_STR_OUT_1_TLAST),

        .DMAC_STR_IN_1_TVALID(DMAC_STR_IN_1_TVALID),
        .DMAC_STR_IN_1_TREADY(DMAC_STR_IN_1_TREADY),
        .DMAC_STR_IN_1_TDATA(DMAC_STR_IN_1_TDATA),
        .DMAC_STR_IN_1_TSTRB(DMAC_STR_IN_1_TSTRB),
        .DMAC_STR_IN_1_TLAST(DMAC_STR_IN_1_TLAST),
        .DMAC_STR_IN_1_FLUSH(DMAC_STR_IN_1_FLUSH),  
`endif
`ifdef DMA350_STREAM_3

        .DMAC_STR_OUT_2_TVALID(DMAC_STR_OUT_2_TVALID),
        .DMAC_STR_OUT_2_TREADY(DMAC_STR_OUT_2_TREADY),
        .DMAC_STR_OUT_2_TDATA(DMAC_STR_OUT_2_TDATA),
        .DMAC_STR_OUT_2_TSTRB(DMAC_STR_OUT_2_TSTRB),
        .DMAC_STR_OUT_2_TLAST(DMAC_STR_OUT_2_TLAST),

        .DMAC_STR_IN_2_TVALID(DMAC_STR_IN_2_TVALID),
        .DMAC_STR_IN_2_TREADY(DMAC_STR_IN_2_TREADY),
        .DMAC_STR_IN_2_TDATA(DMAC_STR_IN_2_TDATA),
        .DMAC_STR_IN_2_TSTRB(DMAC_STR_IN_2_TSTRB),
        .DMAC_STR_IN_2_TLAST(DMAC_STR_IN_2_TLAST),
        .DMAC_STR_IN_2_FLUSH(DMAC_STR_IN_2_FLUSH),  
`endif
`endif

        // DMAC 1 DMA Request and Status Port
        .DMAC_1_DMA_REQ(DMAC_1_DMA_REQ),
        .DMAC_1_DMA_DONE(DMAC_1_DMA_DONE),
        .DMAC_1_DMA_ERR(DMAC_1_DMA_ERR)
    );

    //--------------------------
    // Debug Subsystem
    //--------------------------
    
    // Internal Wiring
    //--------------------------
    // SocDebug AHB-lite Interface - To Interconnect Subsystem
    wire              [31:0] DEBUG_HADDR;
    wire              [ 2:0] DEBUG_HBURST;
    wire                     DEBUG_HMASTLOCK;
    wire              [ 3:0] DEBUG_HPROT;
    wire              [ 2:0] DEBUG_HSIZE;
    wire              [ 1:0] DEBUG_HTRANS;
    wire              [31:0] DEBUG_HWDATA;
    wire                     DEBUG_HWRITE;
    wire              [31:0] DEBUG_HRDATA;
    wire                     DEBUG_HREADY;
    wire                     DEBUG_HRESP;
        
    // USRT APB Interface - To System Control Subsystem
    wire                     DEBUG_PSEL;      // Device select
    wire              [31:0] DEBUG_PRDATA;    // Read data
    wire                     DEBUG_PREADY;    // Device ready
    wire                     DEBUG_PSLVERR;   // Device error response
    
    // Debug Reset Request
    wire                     DEBUG_RESETREQ;
    
    // Reset Request Wiring
    //--------------------------
    
    assign DEBUG_RESETREQ = ADP_GPO8[0];

    // USRT0 TXD axi byte stream
    wire                   USRT0_TXD_TVALID;
    wire           [ 7:0]  USRT0_TXD_TDATA ;
    wire                   USRT0_TXD_TREADY;
    // USRT0 RXD axi byte stream
    wire                   USRT0_RXD_TVALID;
    wire           [ 7:0]  USRT0_RXD_TDATA ;
    wire                   USRT0_RXD_TREADY;
    // USRT1 TXD axi byte stream
    wire                   USRT1_TXD_TVALID;
    wire           [ 7:0]  USRT1_TXD_TDATA ;
    wire                   USRT1_TXD_TREADY;
    // USRT1 RXD axi byte stream
    wire                   USRT1_RXD_TVALID;
    wire           [ 7:0]  USRT1_RXD_TDATA ;
    wire                   USRT1_RXD_TREADY;

    wire                     ADP_RXD_TVALID;
    wire            [ 7:0]   ADP_RXD_TDATA ;
    wire                     ADP_RXD_TREADY;
    wire                     ADP_TXD_TVALID;
    wire             [ 7:0]  ADP_TXD_TDATA ;
    wire                     ADP_TXD_TREADY;

    // STDIN to ADP controller
    wire                     STD_RXD_TVALID;
    wire             [ 7:0]  STD_RXD_TDATA;
    wire                     STD_RXD_TREADY;
    // STDOUT to ADP controller
    wire                     STD_TXD_TVALID;
    wire             [ 7:0]  STD_TXD_TDATA;
    wire                     STD_TXD_TREADY;

    wire FT1248MODE = P1_IN[7]; // added to support EXTIO mapping

    // Sideband Wiring
    //--------------------------
    
    wire [7:0] FT_CLKDIV;
   // assign FT_CLKDIV = FT1248_CLKDIV; // now from socdebug_usrt_control

    assign CPU_0_RXEV = DMAC_ANY_DONE;
    
    // Instantiate Subsystem
    //--------------------------
    nanosoc_ss_debug #(
        // System Parameters
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        // SoCDebug Parameters
        .PROMPT_CHAR(PROMPT_CHAR)
    ) u_ss_debug (
        // System Clocks and Resets
        .SYS_HCLK(SYS_HCLK),
        .SYS_HRESETn(SYS_HRESETn),
        .SYS_PCLK(SYS_PCLK),
        .SYS_PCLKG(SYS_PCLKG),
        .SYS_PRESETn(SYS_PRESETn),
        
        // AHB-lite Master Interface - ADP
        .DEBUG_HADDR(DEBUG_HADDR),
        .DEBUG_HBURST(DEBUG_HBURST),
        .DEBUG_HMASTLOCK(DEBUG_HMASTLOCK),
        .DEBUG_HPROT(DEBUG_HPROT),
        .DEBUG_HSIZE(DEBUG_HSIZE),
        .DEBUG_HTRANS(DEBUG_HTRANS),
        .DEBUG_HWDATA(DEBUG_HWDATA),
        .DEBUG_HWRITE(DEBUG_HWRITE),
        .DEBUG_HRDATA(DEBUG_HRDATA),
        .DEBUG_HREADY(DEBUG_HREADY),
        .DEBUG_HRESP(DEBUG_HRESP),
        
        .ADP_RXD_TVALID_o(ADP_RXD_TVALID),
        .ADP_RXD_TDATA_o( ADP_RXD_TDATA ),
        .ADP_RXD_TREADY_i(ADP_RXD_TREADY),
        .ADP_TXD_TVALID_i(ADP_TXD_TVALID),
        .ADP_TXD_TDATA_i (ADP_TXD_TDATA ),
        .ADP_TXD_TREADY_o(ADP_TXD_TREADY),

        .STD_RXD_TVALID_o(STD_RXD_TVALID),
        .STD_RXD_TDATA_o( STD_RXD_TDATA ),
        .STD_RXD_TREADY_i(STD_RXD_TREADY),
        .STD_TXD_TVALID_i(STD_TXD_TVALID),
        .STD_TXD_TDATA_i (STD_TXD_TDATA ),
        .STD_TXD_TREADY_o(STD_TXD_TREADY),

        // GPIO interface
        .GPO8(ADP_GPO8),
        .GPI8(ADP_GPI8)
    );

    // Instantiation of USRT Controller
    socdebug_usrt_control u_usrt_control (
        // APB Clock and Reset Signals
        .PCLK              (SYS_PCLK),
        .PCLKG             (SYS_PCLKG),    // Gated PCLK for bus
        .PRESETn           (SYS_PRESETn),

        // APB Interface Signals
        .PSEL              (DEBUG_PSEL),
        .PADDR             (SYSIO_PADDR[11:2]),
        .PENABLE           (SYSIO_PENABLE),
        .PWRITE            (SYSIO_PWRITE),
        .PWDATA            (SYSIO_PWDATA),
        .PRDATA            (DEBUG_PRDATA),
        .PREADY            (DEBUG_PREADY),
        .PSLVERR           (DEBUG_PSLVERR),

        .ECOREVNUM         (4'h0),

        // ADP Interface - From USRT to ADP
        .TX_VALID_o        (STD_TXD_TVALID),
        .TX_DATA8_o        (STD_TXD_TDATA ),
        .TX_READY_i        (STD_TXD_TREADY),

        // ADP Interface - From ADP to USRT
        .RX_VALID_i        (STD_RXD_TVALID),
        .RX_DATA8_i        (STD_RXD_TDATA ),
        .RX_READY_o        (STD_RXD_TREADY),
        .INVBAUDDIV8_o     (FT_CLKDIV),
        // Interrupt Interfaces
        .TXINT             ( ),       // Transmit Interrupt
        .RXINT             ( ),       // Receive  Interrupt
        .TXOVRINT          ( ),       // Transmit Overrun Interrupt
        .RXOVRINT          ( ),       // Receive  Overrun Interrupt
        .UARTINT           ( )        // Combined Interrupt
    );


wire       FT_ADP_RXD_TVALID ;
wire [7:0] FT_ADP_RXD_TDATA  ;
wire       FT_ADP_RXD_TREADY ;
wire       FT_ADP_TXD_TVALID ;
wire [7:0] FT_ADP_TXD_TDATA  ;
wire       FT_ADP_TXD_TREADY ;

wire       EXT_ADP_RXD_TVALID ;
wire [7:0] EXT_ADP_RXD_TDATA  ;
wire       EXT_ADP_RXD_TREADY ;
wire       EXT_ADP_TXD_TVALID ;
wire [7:0] EXT_ADP_TXD_TDATA  ;
wire       EXT_ADP_TXD_TREADY ;

wire       EXT_DAT_RXD_TVALID ;
wire [7:0] EXT_DAT_RXD_TDATA  ;
wire       EXT_DAT_RXD_TREADY ;
wire       EXT_DAT_TXD_TVALID ;
wire [7:0] EXT_DAT_TXD_TDATA  ;
wire       EXT_DAT_TXD_TREADY ;

/// See the AXI stream muxes by EXTIO interface (below)

    // Instantiation of FT1248 Controller
    socdebug_ft1248_control #(
        .FT1248_WIDTH (FT1248_WIDTH),
        .FT1248_CLKON (FT1248_CLKON)
    ) u_ft1248_control (
        .clk              (SYS_HCLK),
        .resetn           (SYS_HRESETn),
        .ft_clkdiv        (FT_CLKDIV),
        .ft_clk_o         (FT_CLK_O),
        .ft_ssn_o         (FT_SSN_O),
        .ft_miso_i        (FT_MISO_I),
        .ft_miosio_o      (FT_MIOSIO_O),
        .ft_miosio_e      (FT_MIOSIO_E),
        .ft_miosio_z      (FT_MIOSIO_Z),
        .ft_miosio_i      (FT_MIOSIO_I),

        // ADP Interface - FT1248 to ADP
        .txd_tvalid       (FT_ADP_TXD_TVALID),
        .txd_tdata        (FT_ADP_TXD_TDATA ),
        .txd_tready       (FT_ADP_TXD_TREADY),
        .txd_tlast        ( ),

        // ADP Interface - FT_ADP to FT1248
        .rxd_tvalid       (FT_ADP_RXD_TVALID),
        .rxd_tdata        (FT_ADP_RXD_TDATA ),
        .rxd_tready       (FT_ADP_RXD_TREADY),
        .rxd_tlast        (1'b0)
    );

    //--------------------------
    // Expansion Subsystem
    //--------------------------

    // Internal Wiring
    //--------------------------
        
    // Expansion Region AHB Port - To Interconnect Subsystem
    wire                   EXP_HSEL;
    wire  [SYS_ADDR_W-1:0] EXP_HADDR;
    wire             [1:0] EXP_HTRANS;
    wire             [2:0] EXP_HSIZE;
    wire             [3:0] EXP_HPROT;
    wire                   EXP_HWRITE;
    wire                   EXP_HREADY;
    wire            [31:0] EXP_HWDATA;
    wire             [2:0] EXP_HBURST;
            
    wire                   EXP_HREADYOUT;
    wire                   EXP_HRESP;
    wire            [31:0] EXP_HRDATA;
    
    wire                   EXP_HMASTLOCK;      // AHB lock - Unused
    
    // SRAM Low Region AHB Port - To Interconnect Subsystem
    wire                   EXPRAM_L_HSEL;
    wire  [SYS_ADDR_W-1:0] EXPRAM_L_HADDR;
    wire             [1:0] EXPRAM_L_HTRANS;
    wire             [2:0] EXPRAM_L_HSIZE;
    wire             [3:0] EXPRAM_L_HPROT;
    wire                   EXPRAM_L_HWRITE;
    wire                   EXPRAM_L_HREADY;
    wire            [31:0] EXPRAM_L_HWDATA;
    wire             [2:0] EXPRAM_L_HBURST;
            
    wire                   EXPRAM_L_HREADYOUT;
    wire                   EXPRAM_L_HRESP;
    wire            [31:0] EXPRAM_L_HRDATA;
    
    wire                   EXPRAM_L_HMASTLOCK;      // AHB lock - Unused
    
    
    // SRAM High Region AHB Port - To Interconnect Subsystem
    wire                   EXPRAM_H_HSEL;
    wire  [SYS_ADDR_W-1:0] EXPRAM_H_HADDR;
    wire             [1:0] EXPRAM_H_HTRANS;
    wire             [2:0] EXPRAM_H_HSIZE;
    wire             [3:0] EXPRAM_H_HPROT;
    wire                   EXPRAM_H_HWRITE;
    wire                   EXPRAM_H_HREADY;
    wire            [31:0] EXPRAM_H_HWDATA;
    wire             [2:0] EXPRAM_H_HBURST;
            
    wire                   EXPRAM_H_HREADYOUT;
    wire                   EXPRAM_H_HRESP;
    wire            [31:0] EXPRAM_H_HRDATA;
    
    wire                   EXPRAM_H_HMASTLOCK;      // AHB lock - Unused
    
    // Interrupt Connections - TO CPU Subsystem
    wire             [3:0] EXP_IRQ;
    
    // DMA Connections - To DMA Subsystem
    wire             [1:0] EXP_DRQ;
    wire             [1:0] EXP_DLAST;
    
    // Expansion DRQ Wiring
    //--------------------------
    assign EXP_DLAST [1:0] = 2'b00;
    assign DMAC_0_DMA_REQ[1:0]  = EXP_DRQ;
    assign DMAC_0_DMA_REQ[2]    = EXT_DAT_RXD_TREADY & SYS_P1_OUT[2];
    assign DMAC_0_DMA_REQ[3]    = EXT_DAT_TXD_TVALID &  & SYS_P1_OUT[3];
    
    // Instantiate Subsystem
    //--------------------------
    nanosoc_ss_expansion #(
        // System Parameters
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        
        // SRAM Low Parameters
        .EXPRAM_L_RAM_ADDR_W(EXPRAM_L_RAM_ADDR_W),
        .EXPRAM_L_RAM_DATA_W(EXPRAM_L_RAM_DATA_W),
        
        // SRAM High Parameters
        .EXPRAM_H_RAM_ADDR_W(EXPRAM_H_RAM_ADDR_W),
        .EXPRAM_H_RAM_DATA_W(EXPRAM_H_RAM_DATA_W)
    ) u_ss_expansion (
        // System Clocks and Resets
        .SYS_HCLK(SYS_HCLK),
        .SYS_HRESETn(SYS_HRESETn),
        
        // Expansion Region AHB Port
        .EXP_HSEL(EXP_HSEL),
        .EXP_HADDR(EXP_HADDR),
        .EXP_HTRANS(EXP_HTRANS),
        .EXP_HSIZE(EXP_HSIZE),
        .EXP_HPROT(EXP_HPROT),
        .EXP_HWRITE(EXP_HWRITE),
        .EXP_HREADY(EXP_HREADY),
        .EXP_HWDATA(EXP_HWDATA),
        .EXP_HREADYOUT(EXP_HREADYOUT),
        .EXP_HRESP(EXP_HRESP),
        .EXP_HRDATA(EXP_HRDATA),

`ifdef DMAC_DMA350
`ifdef DMA350_STREAM_2
        .EXP_STR_IN_0_TVALID(DMAC_STR_OUT_0_TVALID),
        .EXP_STR_IN_0_TREADY(DMAC_STR_OUT_0_TREADY),
        .EXP_STR_IN_0_TDATA(DMAC_STR_OUT_0_TDATA),
        .EXP_STR_IN_0_TSTRB(DMAC_STR_OUT_0_TSTRB),
        .EXP_STR_IN_0_TLAST(DMAC_STR_OUT_0_TLAST),

        .EXP_STR_OUT_0_TVALID(DMAC_STR_IN_0_TVALID),
        .EXP_STR_OUT_0_TREADY(DMAC_STR_IN_0_TREADY),
        .EXP_STR_OUT_0_TDATA(DMAC_STR_IN_0_TDATA),
        .EXP_STR_OUT_0_TSTRB(DMAC_STR_IN_0_TSTRB),
        .EXP_STR_OUT_0_TLAST(DMAC_STR_IN_0_TLAST),
        .EXP_STR_OUT_0_FLUSH(DMAC_STR_IN_0_FLUSH),

        .EXP_STR_IN_1_TVALID(DMAC_STR_OUT_1_TVALID),
        .EXP_STR_IN_1_TREADY(DMAC_STR_OUT_1_TREADY),
        .EXP_STR_IN_1_TDATA(DMAC_STR_OUT_1_TDATA),
        .EXP_STR_IN_1_TSTRB(DMAC_STR_OUT_1_TSTRB),
        .EXP_STR_IN_1_TLAST(DMAC_STR_OUT_1_TLAST),
        
        .EXP_STR_OUT_1_TVALID(DMAC_STR_IN_1_TVALID),
        .EXP_STR_OUT_1_TREADY(DMAC_STR_IN_1_TREADY),
        .EXP_STR_OUT_1_TDATA(DMAC_STR_IN_1_TDATA),
        .EXP_STR_OUT_1_TSTRB(DMAC_STR_IN_1_TSTRB),
        .EXP_STR_OUT_1_TLAST(DMAC_STR_IN_1_TLAST),
        .EXP_STR_OUT_1_FLUSH(DMAC_STR_IN_1_FLUSH),
`endif
`ifdef DMA350_STREAM_2

        .EXP_STR_IN_2_TVALID(DMAC_STR_OUT_2_TVALID),
        .EXP_STR_IN_2_TREADY(DMAC_STR_OUT_2_TREADY),
        .EXP_STR_IN_2_TDATA(DMAC_STR_OUT_2_TDATA),
        .EXP_STR_IN_2_TSTRB(DMAC_STR_OUT_2_TSTRB),
        .EXP_STR_IN_2_TLAST(DMAC_STR_OUT_2_TLAST),
        
        .EXP_STR_OUT_2_TVALID(DMAC_STR_IN_2_TVALID),
        .EXP_STR_OUT_2_TREADY(DMAC_STR_IN_2_TREADY),
        .EXP_STR_OUT_2_TDATA(DMAC_STR_IN_2_TDATA),
        .EXP_STR_OUT_2_TSTRB(DMAC_STR_IN_2_TSTRB),
        .EXP_STR_OUT_2_TLAST(DMAC_STR_IN_2_TLAST),
        .EXP_STR_OUT_2_FLUSH(DMAC_STR_IN_2_FLUSH),
`endif
`endif

        
        // SRAM Low Region AHB Port
        .EXPRAM_L_HSEL(EXPRAM_L_HSEL),
        .EXPRAM_L_HADDR(EXPRAM_L_HADDR),
        .EXPRAM_L_HTRANS(EXPRAM_L_HTRANS),
        .EXPRAM_L_HSIZE(EXPRAM_L_HSIZE),
        .EXPRAM_L_HPROT(EXPRAM_L_HPROT),
        .EXPRAM_L_HWRITE(EXPRAM_L_HWRITE),
        .EXPRAM_L_HREADY(EXPRAM_L_HREADY),
        .EXPRAM_L_HWDATA(EXPRAM_L_HWDATA),
        .EXPRAM_L_HREADYOUT(EXPRAM_L_HREADYOUT),
        .EXPRAM_L_HRESP(EXPRAM_L_HRESP),
        .EXPRAM_L_HRDATA(EXPRAM_L_HRDATA),
        
        // SRAM High Region AHB Port
        .EXPRAM_H_HSEL(EXPRAM_H_HSEL),
        .EXPRAM_H_HADDR(EXPRAM_H_HADDR),
        .EXPRAM_H_HTRANS(EXPRAM_H_HTRANS),
        .EXPRAM_H_HSIZE(EXPRAM_H_HSIZE),
        .EXPRAM_H_HPROT(EXPRAM_H_HPROT),
        .EXPRAM_H_HWRITE(EXPRAM_H_HWRITE),
        .EXPRAM_H_HREADY(EXPRAM_H_HREADY),
        .EXPRAM_H_HWDATA(EXPRAM_H_HWDATA),
        .EXPRAM_H_HREADYOUT(EXPRAM_H_HREADYOUT),
        .EXPRAM_H_HRESP(EXPRAM_H_HRESP),
        .EXPRAM_H_HRDATA(EXPRAM_H_HRDATA),
        
        // Interrupt and DMAC Connections
        .EXP_IRQ(EXP_IRQ),
        .EXP_DRQ(EXP_DRQ),
        .EXP_DLAST(EXP_DLAST)
    );

    //--------------------------
    // System Control Subsystem
    //--------------------------
    
    // Internal Wiring
    //--------------------------

    // SYSIO AHB interface - To Interconnect Subsystem
    wire                   SYSIO_HSEL;           // AHB region select
    wire  [SYS_ADDR_W-1:0] SYSIO_HADDR;          // AHB address
    wire            [ 2:0] SYSIO_HBURST;         // AHB burst
    wire                   SYSIO_HMASTLOCK;      // AHB lock
    wire            [ 3:0] SYSIO_HPROT;          // AHB prot
    wire            [ 2:0] SYSIO_HSIZE;          // AHB size
    wire            [ 1:0] SYSIO_HTRANS;         // AHB transfer
    wire  [SYS_DATA_W-1:0] SYSIO_HWDATA;         // AHB write data
    wire                   SYSIO_HWRITE;         // AHB write
    wire                   SYSIO_HREADY;         // AHB ready
    wire  [SYS_DATA_W-1:0] SYSIO_HRDATA;         // AHB read-data
    wire                   SYSIO_HRESP;          // AHB response
    wire                   SYSIO_HREADYOUT;      // AHB ready out
    
    // System ROM Table AHB interface - To Interconnect Subsystem
    wire                   SYSTABLE_HSEL;           // AHB region select
    wire  [SYS_ADDR_W-1:0] SYSTABLE_HADDR;          // AHB address
    wire            [ 2:0] SYSTABLE_HBURST;         // AHB burst
    wire                   SYSTABLE_HMASTLOCK;      // AHB lock
    wire            [ 3:0] SYSTABLE_HPROT;          // AHB prot
    wire            [ 2:0] SYSTABLE_HSIZE;          // AHB size
    wire            [ 1:0] SYSTABLE_HTRANS;         // AHB transfer
    wire  [SYS_DATA_W-1:0] SYSTABLE_HWDATA;         // AHB write data
    wire                   SYSTABLE_HWRITE;         // AHB write
    wire                   SYSTABLE_HREADY;         // AHB ready
    wire  [SYS_DATA_W-1:0] SYSTABLE_HRDATA;         // AHB read-data
    wire                   SYSTABLE_HRESP;          // AHB response
    wire                   SYSTABLE_HREADYOUT;      // AHB ready out
    


    // Bus Matrix Remap Control - To Interconnect Subsystem
    wire                   SYSIO_REMAP_CTRL; // REMAP control bit
    wire            [3:0]  SYS_REMAP_CTRL;   // REMAP control bit
    
    // Lockup Signals - To System
    wire                   SYS_WDOGRESETREQ;   // Watchdog reset request
    wire                   SYS_LOCKUPRESET;    // System Controller cfg - Reset if lockup
    
    // Interrupt Wiring
    //--------------------------
    wire SYS_GPIO0_ANY_IRQ;
    wire SYS_GPIO1_ANY_IRQ;
    
    assign SYS_GPIO0_ANY_IRQ = |SYS_GPIO0_IRQ;
    assign SYS_GPIO1_ANY_IRQ = |SYS_GPIO1_IRQ;
    
    // Remap Wiring
    //--------------------------
    assign SYS_REMAP_CTRL [3:0] = { 3'b000, !SYSIO_REMAP_CTRL};
    
        
    // Combined CPU Wiring
    //--------------------------
    
    assign CPU_SYSRESETREQ    = CPU_0_SYSRESETREQ;
    assign CPU_LOCKUP         = CPU_0_LOCKUP;
    assign CPU_PRMURESETREQ   = CPU_0_PRMURESETREQ;
    assign CPU_SLEEPING       = CPU_0_SLEEPING;
    assign CPU_SLEEPDEEP      = CPU_0_SLEEPDEEP;
    
    // Reset Request Wiring
    //--------------------------
    
    
    assign SYS_PMUDBGRESETREQ = CPU_0_PMUDBGRESETREQ;
    
    assign SYS_SYSRESETREQ    = CPU_SYSRESETREQ 
                              | DEBUG_RESETREQ 
                              | SYS_WDOGRESETREQ
                              | (SYS_LOCKUPRESET & CPU_LOCKUP);
    
    // Instantiate Subsystem
    //--------------------------
    
    nanosoc_ss_systemctrl #(
        // System Parameters
        .SYS_ADDR_W(SYS_ADDR_W),
        .SYS_DATA_W(SYS_DATA_W),
        .APB_ADDR_W(APB_ADDR_W),
        .APB_DATA_W(APB_DATA_W),
        .SYSTABLE_BASE(SYSTABLE_BASE),
        .SOCLABS_JEPID(SOCLABS_JEPID),
        .NANOSOC_PARTNUMBER(NANOSOC_PARTNUMBER),
        .NANOSOC_REVISION(NANOSOC_REVISION),
        .CLKGATE_PRESENT(CLKGATE_PRESENT)
    ) u_ss_systemctrl (
        // Free-running and Crystal Clock Output
        .SYS_CLK (SYS_CLK),                // System Input Clock
        .SYS_FCLK(SYS_FCLK),               // Free-running system clock
        .SYS_XTALCLK_OUT(SYS_XTALCLK_OUT), // Crystal Clock Output
        
        // System Input Clocks and Resets
        .SYS_SYSRESETn(SYS_SYSRESETn),
        .SYS_PORESETn(SYS_PORESETn),       // Power-On-Reset reset (active-low)
        .SYS_TESTMODE(SYS_TESTMODE),       // Reset bypass in scan test
        .SYS_HCLK(SYS_HCLK),               // AHB clock
        .SYS_HRESETn(SYS_HRESETn),         // AHB reset (active-low)
        
        // SYSIO AHB interface
        .SYSIO_HSEL(SYSIO_HSEL),           // AHB region select
        .SYSIO_HADDR(SYSIO_HADDR),         // AHB address
        .SYSIO_HBURST(SYSIO_HBURST),       // AHB burst
        .SYSIO_HMASTLOCK(SYSIO_HMASTLOCK), // AHB lock
        .SYSIO_HPROT(SYSIO_HPROT),         // AHB prot
        .SYSIO_HSIZE(SYSIO_HSIZE),         // AHB size
        .SYSIO_HTRANS(SYSIO_HTRANS),       // AHB transfer
        .SYSIO_HWDATA(SYSIO_HWDATA),       // AHB write data
        .SYSIO_HWRITE(SYSIO_HWRITE),       // AHB write
        .SYSIO_HREADY(SYSIO_HREADY),       // AHB ready
        .SYSIO_HRDATA(SYSIO_HRDATA),       // AHB read-data
        .SYSIO_HRESP(SYSIO_HRESP),         // AHB response
        .SYSIO_HREADYOUT(SYSIO_HREADYOUT), // AHB ready out
        
        // System ROM Table AHB interface
        .SYSTABLE_HSEL(SYSTABLE_HSEL),           // AHB region select
        .SYSTABLE_HADDR(SYSTABLE_HADDR),         // AHB address
        .SYSTABLE_HBURST(SYSTABLE_HBURST),       // AHB burst
        .SYSTABLE_HMASTLOCK(SYSTABLE_HMASTLOCK), // AHB lock
        .SYSTABLE_HPROT(SYSTABLE_HPROT),         // AHB prot
        .SYSTABLE_HSIZE(SYSTABLE_HSIZE),         // AHB size
        .SYSTABLE_HTRANS(SYSTABLE_HTRANS),       // AHB transfer
        .SYSTABLE_HWDATA(SYSTABLE_HWDATA),       // AHB write data
        .SYSTABLE_HWRITE(SYSTABLE_HWRITE),       // AHB write
        .SYSTABLE_HREADY(SYSTABLE_HREADY),       // AHB ready
        .SYSTABLE_HRDATA(SYSTABLE_HRDATA),       // AHB read-data
        .SYSTABLE_HRESP(SYSTABLE_HRESP),         // AHB response
        .SYSTABLE_HREADYOUT(SYSTABLE_HREADYOUT), // AHB ready out
        
        // APB clocking control
        .SYS_PCLK(SYS_PCLK),       // Peripheral clock
        .SYS_PCLKG(SYS_PCLKG),     // Gated Peripheral bus clock
        .SYS_PRESETn(SYS_PRESETn), // Peripheral system and APB reset
        .SYS_PCLKEN(SYS_PCLKEN),   // Clock divide control for AHB to APB bridge
        
        // APB external Slave Interfaces
        .SYSIO_PENABLE(SYSIO_PENABLE),
        .SYSIO_PWRITE(SYSIO_PWRITE),
        .SYSIO_PADDR(SYSIO_PADDR),
        .SYSIO_PWDATA(SYSIO_PWDATA),
        
        .USRT_PSEL(DEBUG_PSEL),
        .USRT_PRDATA(DEBUG_PRDATA),
        .USRT_PREADY(DEBUG_PREADY),
        .USRT_PSLVERR(DEBUG_PSLVERR),
        
        .DMAC_0_PSEL(DMAC_0_PSEL),
        .DMAC_0_PRDATA(DMAC_0_PRDATA),
        .DMAC_0_PREADY(DMAC_0_PREADY),
        .DMAC_0_PSLVERR(DMAC_0_PSLVERR),
        
        .DMAC_1_PSEL(DMAC_1_PSEL),
        .DMAC_1_PSEL_HI(DMAC_1_PSEL_HI),
        .DMAC_1_PRDATA(DMAC_1_PRDATA),
        .DMAC_1_PREADY(DMAC_1_PREADY),
        .DMAC_1_PSLVERR(DMAC_1_PSLVERR),
        
        // CPU sideband signalling
        .SYS_NMI(SYS_NMI),
        .SYS_APB_IRQ(SYS_APB_IRQ),
        .SYS_GPIO0_IRQ(SYS_GPIO0_IRQ),
        .SYS_GPIO1_IRQ(SYS_GPIO1_IRQ),
        
        // CPU power/reset control
        .SYS_REMAP_CTRL(SYSIO_REMAP_CTRL),
        .SYS_WDOGRESETREQ(SYS_WDOGRESETREQ),
        .SYS_LOCKUPRESET(SYS_LOCKUPRESET),
        
        // System Reset Request Signals
        .CPU_SYSRESETREQ(CPU_SYSRESETREQ),
        .CPU_PRMURESETREQ(CPU_PRMURESETREQ),
        
        // Power Management Control and Status
        .SYS_PMUENABLE(SYS_PMUENABLE),
        .SYS_PMUDBGRESETREQ(SYS_PMUDBGRESETREQ),
        
        // CPU Status Signals
        .CPU_LOCKUP(CPU_LOCKUP),
        .CPU_SLEEPING(CPU_SLEEPING),
        .CPU_SLEEPDEEP(CPU_SLEEPDEEP),

        // USRT0
        .USRT0_TXD_TVALID (USRT0_TXD_TVALID),
        .USRT0_TXD_TDATA  (USRT0_TXD_TDATA ),
        .USRT0_TXD_TREADY (USRT0_TXD_TREADY),
        .USRT0_RXD_TVALID (USRT0_RXD_TVALID),
        .USRT0_RXD_TDATA  (USRT0_RXD_TDATA ),
        .USRT0_RXD_TREADY (USRT0_RXD_TREADY),
        // USRT1
        .USRT1_TXD_TVALID (USRT1_TXD_TVALID),
        .USRT1_TXD_TDATA  (USRT1_TXD_TDATA ),
        .USRT1_TXD_TREADY (USRT1_TXD_TREADY),
        .USRT1_RXD_TVALID (USRT1_RXD_TVALID),
        .USRT1_RXD_TDATA  (USRT1_RXD_TDATA ),
        .USRT1_RXD_TREADY (USRT1_RXD_TREADY),
        
        // GPIO
        .P0_IN          (SYS_P0_IN),
        .P0_OUT         (SYS_P0_OUT),
        .P0_OUTEN       (SYS_P0_OUTEN),
        .P0_ALTFUNC     (SYS_P0_ALTFUNC),
        .P1_IN          (SYS_P1_IN),
        .P1_OUT         (SYS_P1_OUT),
        .P1_OUTEN       (SYS_P1_OUTEN),
        .P1_ALTFUNC     (SYS_P1_ALTFUNC),
        .P1_OUT_MUX     (SYS_P1_OUT_MUX),
        .P1_OUT_EN_MUX  (SYS_P1_OUT_EN_MUX)
    );


// ADP input routing
    assign   ADP_RXD_TREADY     = (FT1248MODE) ? FT_ADP_RXD_TREADY : EXT_ADP_RXD_TREADY;
    assign   ADP_TXD_TVALID     = (FT1248MODE) ? FT_ADP_TXD_TVALID : EXT_ADP_TXD_TVALID;
    assign   ADP_TXD_TDATA      = (FT1248MODE) ? FT_ADP_TXD_TDATA  : EXT_ADP_TXD_TDATA;

// FT1248 ADP output routing
    assign   FT_ADP_RXD_TVALID  = (FT1248MODE) ? ADP_RXD_TVALID    : 1'b0;
    assign   FT_ADP_RXD_TDATA   = (FT1248MODE) ? ADP_RXD_TDATA     : 8'b00000000;
    assign   FT_ADP_TXD_TREADY  = (FT1248MODE) ? ADP_TXD_TREADY    : 1'b0;

// EXTIO ADP output routing
    assign   EXT_ADP_RXD_TVALID = (FT1248MODE) ? 1'b0              : ADP_RXD_TVALID;
    assign   EXT_ADP_RXD_TDATA  = (FT1248MODE) ? 8'b00000000       : ADP_RXD_TDATA;
    assign   EXT_ADP_TXD_TREADY = (FT1248MODE) ? 1'b0              : ADP_TXD_TREADY;

// USRT0 input loopback test - or disable
    assign USRT0_RXD_TVALID = (FT1248MODE) ? USRT1_TXD_TVALID : 1'b0;
    assign USRT0_RXD_TDATA  = (FT1248MODE) ? USRT1_TXD_TDATA  : 8'b00000000;
    assign USRT0_TXD_TREADY = (FT1248MODE) ? USRT1_RXD_TREADY : 1'b0;

// USRT1 input loopback - or EXT DAT
    assign USRT1_RXD_TVALID = (FT1248MODE) ? USRT0_TXD_TVALID : EXT_DAT_TXD_TVALID ;
    assign USRT1_RXD_TDATA  = (FT1248MODE) ? USRT0_TXD_TDATA  : EXT_DAT_TXD_TDATA;
    assign USRT1_TXD_TREADY = (FT1248MODE) ? USRT0_RXD_TREADY : EXT_DAT_RXD_TREADY;

// EXT DAT RXD
    assign EXT_DAT_RXD_TVALID = (FT1248MODE) ? 1'b0        : USRT1_TXD_TVALID;
    assign EXT_DAT_RXD_TDATA  = (FT1248MODE) ? 8'b00000000 : USRT1_TXD_TDATA ;
    assign EXT_DAT_TXD_TREADY = (FT1248MODE) ? 1'b0        : USRT1_RXD_TREADY;


wire [3:0] iodata4_i;
wire [3:0] iodata4_o;
wire [3:0] iodata4_e;
wire [3:0] iodata4_t;
wire       ioreq1_o;
wire       ioreq2_o;
wire       ioack_i ;


extio8x4_axis_initiator u_extio8x4_axis_initiator
  (
  .clk             ( SYS_HCLK          ),
  .resetn          ( SYS_HRESETn       ),
  .testmode        ( SYS_TESTMODE      ),
// RX 4-channel AXIS interface
  .axis_rx0_tvalid ( EXT_ADP_RXD_TVALID ),
  .axis_rx0_tdata8 ( EXT_ADP_RXD_TDATA  ),
  .axis_rx0_tready ( EXT_ADP_RXD_TREADY ),
  .axis_rx1_tvalid ( EXT_DAT_RXD_TVALID ),
  .axis_rx1_tdata8 ( EXT_DAT_RXD_TDATA  ),
  .axis_rx1_tready ( EXT_DAT_RXD_TREADY ),
  .axis_tx0_tvalid ( EXT_ADP_TXD_TVALID ),
  .axis_tx0_tdata8 ( EXT_ADP_TXD_TDATA  ),
  .axis_tx0_tready ( EXT_ADP_TXD_TREADY ),
  .axis_tx1_tvalid ( EXT_DAT_TXD_TVALID ),
  .axis_tx1_tdata8 ( EXT_DAT_TXD_TDATA  ),
  .axis_tx1_tready ( EXT_DAT_TXD_TREADY ),
// external io interface
  .iodata4_a       ( iodata4_i       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_o        ),
  .ioreq2_o        ( ioreq2_o        ),
  .ioack_a         ( ioack_i         )
  );

 // --------------------------------------------------------------------------------
 // EXTIO8x4 stream interface - enabled when P1[7] input is low
 //   default in previous testbenches was pullup (for FT1248, UART2)
 //
 //          v1 mapping was:    v2 config
 //   P1[0] - ft_miso_in        ioreq1_o
 //   P1[1] - ft_clk_out        ioreq2_o
 //   P1[2] - ft_miosio_io      ioack_i
 //   P1[3] - ft_ssn_out        iodata[0]
 //   P1[4] - uart2_rxd         iodata[1]
 //   P1[5] - uart2_txd         iodata[2]
 //   P1[6] - reserved (pullup) iodata[3]
 //   P1[7] - reserved (pullup) 1'b0
 // --------------------------------------------------------------------------------


// SOC specific IO mapping - PORT0
    assign  SYS_P0_IN[15:0]  = P0_IN[15:0];
    assign  P0_OUT[15:0]     = SYS_P0_OUT[15:0];
    assign  P0_OUTEN[15:0]   = SYS_P0_OUTEN[15:0];


// PORT 1 [7] - low for EXTIO, high for FT1248/UART2

// reassign PORT1[3:0] to FT1248x1 interface
    assign  FT_MISO_I       = (FT1248MODE) ? P1_IN[0] : 1'b0; // FT_MISO INPUT pad configuration
    assign  P1_OUTEN[0]     = (FT1248MODE) ? 1'b0 : 1'b1;     // IOREQ1 output
    assign  P1_OUT[0]       = (FT1248MODE) ? 1'b0 : ioreq1_o;
    assign  SYS_P1_IN[0]    = (FT1248MODE) ? 1'b0 : ioreq1_o; // P1_IN[0]

    assign  P1_OUT[1]       = (FT1248MODE) ? FT_CLK_O : ioreq2_o;  // FT_CLK OUTPUT pad configuration
    assign  P1_OUTEN[1]     = (FT1248MODE) ? 1'b1 : 1'b1;
    assign  SYS_P1_IN[1]    = (FT1248MODE) ? 1'b0 : ioreq2_o; // P1_IN[1]

    assign  FT_MIOSIO_I[0]  = (FT1248MODE) ? P1_IN[2] : 1'b0; // FT_MIOSIO INOUT pad configuration
    assign  P1_OUT[2]       = (FT1248MODE) ? FT_MIOSIO_O[0] : 1'b0;
    assign  P1_OUTEN[2]     = (FT1248MODE) ? FT_MIOSIO_E[0] : 1'b0;
    assign  SYS_P1_IN[2]    = (FT1248MODE) ? 1'b0 : P1_IN[2]; // P1_IN[2];
    assign  ioack_i         = (FT1248MODE) ? 1'b1 : P1_IN[2];

    assign  P1_OUT[3]       = (FT1248MODE) ? FT_SSN_O : iodata4_o[0];  // FT_SSN OUTPUT pad configuration
    assign  P1_OUTEN[3]     = (FT1248MODE) ? 1'b1 : iodata4_e[0];
    assign  SYS_P1_IN[3]    = (FT1248MODE) ? 1'b1 : P1_IN[3];
    assign  iodata4_i[0]    = (FT1248MODE) ? 1'b1 : P1_IN[3];

    assign  P1_OUT[4]       = (FT1248MODE) ? SYS_P1_OUT_MUX[4] : iodata4_o[1];
    assign  P1_OUTEN[4]     = (FT1248MODE) ? SYS_P1_OUT_EN_MUX[4] : iodata4_e[1];
    assign  SYS_P1_IN[4]    = (FT1248MODE) ? P1_IN[4] : SYS_P1_OUT_MUX[5];
    assign  iodata4_i[1]    = (FT1248MODE) ? 1'b1 : P1_IN[4];

    assign  P1_OUT[5]       = (FT1248MODE) ? SYS_P1_OUT_MUX[5] : iodata4_o[2];
    assign  P1_OUTEN[5]     = (FT1248MODE) ? SYS_P1_OUT_EN_MUX[5] : iodata4_e[2];
    assign  SYS_P1_IN[5]    = P1_IN[5];
    assign  iodata4_i[2]    = (FT1248MODE) ? 1'b1 : P1_IN[5];

    assign  P1_OUT[6]       = (FT1248MODE) ? SYS_P1_OUT_MUX[6] : iodata4_o[3];
    assign  P1_OUTEN[6]     = (FT1248MODE) ? SYS_P1_OUT_EN_MUX[6] : iodata4_e[3];
    assign  SYS_P1_IN[6]    = P1_IN[6];
    assign  iodata4_i[3]    = (FT1248MODE) ? 1'b1 : P1_IN[6];

    assign  P1_OUT[7]       = SYS_P1_OUT_MUX[7];
    assign  P1_OUTEN[7]     = SYS_P1_OUT_EN_MUX[7];
    assign  SYS_P1_IN[7]    = P1_IN[7];

// the rest of PORT1[3:0] is GPIO/AltFunction
    assign  SYS_P1_IN[15:8]  = P1_IN[15:8];
    assign  P1_OUT[15:8]     = SYS_P1_OUT_MUX[15:8];
    assign  P1_OUTEN[15:8]   = SYS_P1_OUT_EN_MUX[15:8];

    //--------------------------
    // Interrupt Wiring
    //--------------------------
    
    assign CPU_0_IRQ [ 3: 0] = SYS_APB_IRQ[ 3: 0]; // nanansocv1: EXP_IRQ[3:0];
    assign CPU_0_IRQ [ 5: 4] = SYS_APB_IRQ[ 5: 4];
    assign CPU_0_IRQ [ 6]    = SYS_APB_IRQ[ 6] | SYS_GPIO0_ANY_IRQ;
    assign CPU_0_IRQ [ 7]    = SYS_APB_IRQ[ 7] | SYS_GPIO1_ANY_IRQ;
    assign CPU_0_IRQ [10: 8] = SYS_APB_IRQ[10: 8];
    assign CPU_0_IRQ [14:11] = EXP_IRQ[3:0]; // nanosocv1: SYS_APB_IRQ[14:11];
    assign CPU_0_IRQ [15]    = SYS_APB_IRQ[15] | DMAC_ANY_DONE | DMAC_ANY_ERROR;
    assign CPU_0_IRQ [31:16] = SYS_APB_IRQ[31:16] | SYS_GPIO0_IRQ[15:0];
    
    //--------------------------
    // Interconnect Subsystem
    //--------------------------
    
    // Instantiate Subsystem
    //--------------------------
    
    nanosoc_ss_interconnect #(
        .SYS_ADDR_W   (SYS_ADDR_W),  // System Address Width
        .SYS_DATA_W   (SYS_DATA_W)   // System Data Width
    ) u_ss_interconnect (
        // System Clocks, Resets, and Control
        .SYS_HCLK(SYS_HCLK),
        .SYS_HRESETn(SYS_HRESETn),
        .SYS_SCANENABLE(SYS_SCANENABLE),
        .SYS_SCANINHCLK(SYS_SCANINHCLK),
        .SYS_SCANOUTHCLK(SYS_SCANOUTHCLK),

        // System Address Remap control
        .SYS_REMAP_CTRL(SYS_REMAP_CTRL),

        // Debug Master Port
        .DEBUG_HADDR(DEBUG_HADDR),
        .DEBUG_HTRANS(DEBUG_HTRANS),
        .DEBUG_HWRITE(DEBUG_HWRITE),
        .DEBUG_HSIZE(DEBUG_HSIZE),
        .DEBUG_HBURST(DEBUG_HBURST),
        .DEBUG_HPROT(DEBUG_HPROT),
        .DEBUG_HWDATA(DEBUG_HWDATA),
        .DEBUG_HMASTLOCK(DEBUG_HMASTLOCK),
        .DEBUG_HRDATA(DEBUG_HRDATA),
        .DEBUG_HREADY(DEBUG_HREADY),
        .DEBUG_HRESP(DEBUG_HRESP),

        // DMA Controller 0 Master Port
        .DMAC_0_HADDR(DMAC_0_HADDR),
        .DMAC_0_HTRANS(DMAC_0_HTRANS),
        .DMAC_0_HWRITE(DMAC_0_HWRITE),
        .DMAC_0_HSIZE(DMAC_0_HSIZE),
        .DMAC_0_HBURST(DMAC_0_HBURST),
        .DMAC_0_HPROT(DMAC_0_HPROT),
        .DMAC_0_HWDATA(DMAC_0_HWDATA),
        .DMAC_0_HMASTLOCK(DMAC_0_HMASTLOCK),
        .DMAC_0_HRDATA(DMAC_0_HRDATA),
        .DMAC_0_HREADY(DMAC_0_HREADY),
        .DMAC_0_HRESP(DMAC_0_HRESP),

        // DMAC Controller 1 Master Port
        .DMAC_1_HADDR(DMAC_1_HADDR),
        .DMAC_1_HTRANS(DMAC_1_HTRANS),
        .DMAC_1_HWRITE(DMAC_1_HWRITE),
        .DMAC_1_HSIZE(DMAC_1_HSIZE),
        .DMAC_1_HBURST(DMAC_1_HBURST),
        .DMAC_1_HPROT(DMAC_1_HPROT),
        .DMAC_1_HWDATA(DMAC_1_HWDATA),
        .DMAC_1_HMASTLOCK(DMAC_1_HMASTLOCK),
        .DMAC_1_HRDATA(DMAC_1_HRDATA),
        .DMAC_1_HREADY(DMAC_1_HREADY),
        .DMAC_1_HRESP(DMAC_1_HRESP),
        
        // CPU 0 Master Port
        .CPU_0_HADDR(CPU_0_HADDR),
        .CPU_0_HTRANS(CPU_0_HTRANS),
        .CPU_0_HWRITE(CPU_0_HWRITE),
        .CPU_0_HSIZE(CPU_0_HSIZE),
        .CPU_0_HBURST(CPU_0_HBURST),
        .CPU_0_HPROT(CPU_0_HPROT),
        .CPU_0_HWDATA(CPU_0_HWDATA),
        .CPU_0_HMASTLOCK(CPU_0_HMASTLOCK),
        .CPU_0_HRDATA(CPU_0_HRDATA),
        .CPU_0_HREADY(CPU_0_HREADY),
        .CPU_0_HRESP(CPU_0_HRESP),

        // Bootrom 0 Region Slave Port
        .BOOTROM_0_HRDATA(BOOTROM_0_HRDATA),
        .BOOTROM_0_HREADYOUT(BOOTROM_0_HREADYOUT),
        .BOOTROM_0_HRESP(BOOTROM_0_HRESP),
        .BOOTROM_0_HSEL(BOOTROM_0_HSEL),
        .BOOTROM_0_HADDR(BOOTROM_0_HADDR),
        .BOOTROM_0_HTRANS(BOOTROM_0_HTRANS),
        .BOOTROM_0_HWRITE(BOOTROM_0_HWRITE),
        .BOOTROM_0_HSIZE(BOOTROM_0_HSIZE),
        .BOOTROM_0_HBURST(BOOTROM_0_HBURST),
        .BOOTROM_0_HPROT(BOOTROM_0_HPROT),
        .BOOTROM_0_HWDATA(BOOTROM_0_HWDATA),
        .BOOTROM_0_HMASTLOCK(BOOTROM_0_HMASTLOCK),
        .BOOTROM_0_HREADYMUX(BOOTROM_0_HREADY),

        // CPU 0 Instruction Memory Region Slave Port
        .IMEM_0_HRDATA(IMEM_0_HRDATA),
        .IMEM_0_HREADYOUT(IMEM_0_HREADYOUT),
        .IMEM_0_HRESP(IMEM_0_HRESP),
        .IMEM_0_HSEL(IMEM_0_HSEL),
        .IMEM_0_HADDR(IMEM_0_HADDR),
        .IMEM_0_HTRANS(IMEM_0_HTRANS),
        .IMEM_0_HWRITE(IMEM_0_HWRITE),
        .IMEM_0_HSIZE(IMEM_0_HSIZE),
        .IMEM_0_HBURST(IMEM_0_HBURST),
        .IMEM_0_HPROT(IMEM_0_HPROT),
        .IMEM_0_HWDATA(IMEM_0_HWDATA),
        .IMEM_0_HMASTLOCK(IMEM_0_HMASTLOCK),
        .IMEM_0_HREADYMUX(IMEM_0_HREADY),

        // CPU 0 Data Memory Region Slave Port
        .DMEM_0_HRDATA(DMEM_0_HRDATA),
        .DMEM_0_HREADYOUT(DMEM_0_HREADYOUT),
        .DMEM_0_HRESP(DMEM_0_HRESP),
        .DMEM_0_HSEL(DMEM_0_HSEL),
        .DMEM_0_HADDR(DMEM_0_HADDR),
        .DMEM_0_HTRANS(DMEM_0_HTRANS),
        .DMEM_0_HWRITE(DMEM_0_HWRITE),
        .DMEM_0_HSIZE(DMEM_0_HSIZE),
        .DMEM_0_HBURST(DMEM_0_HBURST),
        .DMEM_0_HPROT(DMEM_0_HPROT),
        .DMEM_0_HWDATA(DMEM_0_HWDATA),
        .DMEM_0_HMASTLOCK(DMEM_0_HMASTLOCK),
        .DMEM_0_HREADYMUX(DMEM_0_HREADY),

        // System Peripheral Region Slave Port
        .SYSIO_HRDATA(SYSIO_HRDATA),
        .SYSIO_HREADYOUT(SYSIO_HREADYOUT),
        .SYSIO_HRESP(SYSIO_HRESP),
        .SYSIO_HSEL(SYSIO_HSEL),
        .SYSIO_HADDR(SYSIO_HADDR),
        .SYSIO_HTRANS(SYSIO_HTRANS),
        .SYSIO_HWRITE(SYSIO_HWRITE),
        .SYSIO_HSIZE(SYSIO_HSIZE),
        .SYSIO_HBURST(SYSIO_HBURST),
        .SYSIO_HPROT(SYSIO_HPROT),
        .SYSIO_HWDATA(SYSIO_HWDATA),
        .SYSIO_HMASTLOCK(SYSIO_HMASTLOCK),
        .SYSIO_HREADYMUX(SYSIO_HREADY),

        // Expansion Memory Low Region Slave Port
        .EXPRAM_L_HRDATA(EXPRAM_L_HRDATA),
        .EXPRAM_L_HREADYOUT(EXPRAM_L_HREADYOUT),
        .EXPRAM_L_HRESP(EXPRAM_L_HRESP),
        .EXPRAM_L_HSEL(EXPRAM_L_HSEL),
        .EXPRAM_L_HADDR(EXPRAM_L_HADDR),
        .EXPRAM_L_HTRANS(EXPRAM_L_HTRANS),
        .EXPRAM_L_HWRITE(EXPRAM_L_HWRITE),
        .EXPRAM_L_HSIZE(EXPRAM_L_HSIZE),
        .EXPRAM_L_HBURST(EXPRAM_L_HBURST),
        .EXPRAM_L_HPROT(EXPRAM_L_HPROT),
        .EXPRAM_L_HWDATA(EXPRAM_L_HWDATA),
        .EXPRAM_L_HMASTLOCK(EXPRAM_L_HMASTLOCK),
        .EXPRAM_L_HREADYMUX(EXPRAM_L_HREADY),

        // Expansion Memory High Region Slave Port
        .EXPRAM_H_HRDATA(EXPRAM_H_HRDATA),
        .EXPRAM_H_HREADYOUT(EXPRAM_H_HREADYOUT),
        .EXPRAM_H_HRESP(EXPRAM_H_HRESP),
        .EXPRAM_H_HSEL(EXPRAM_H_HSEL),
        .EXPRAM_H_HADDR(EXPRAM_H_HADDR),
        .EXPRAM_H_HTRANS(EXPRAM_H_HTRANS),
        .EXPRAM_H_HWRITE(EXPRAM_H_HWRITE),
        .EXPRAM_H_HSIZE(EXPRAM_H_HSIZE),
        .EXPRAM_H_HBURST(EXPRAM_H_HBURST),
        .EXPRAM_H_HPROT(EXPRAM_H_HPROT),
        .EXPRAM_H_HWDATA(EXPRAM_H_HWDATA),
        .EXPRAM_H_HMASTLOCK(EXPRAM_H_HMASTLOCK),
        .EXPRAM_H_HREADYMUX(EXPRAM_H_HREADY),

        // Expansion Region Slave Port
        .EXP_HRDATA(EXP_HRDATA),
        .EXP_HREADYOUT(EXP_HREADYOUT),
        .EXP_HRESP(EXP_HRESP),
        .EXP_HSEL(EXP_HSEL),
        .EXP_HADDR(EXP_HADDR),
        .EXP_HTRANS(EXP_HTRANS),
        .EXP_HWRITE(EXP_HWRITE),
        .EXP_HSIZE(EXP_HSIZE),
        .EXP_HBURST(EXP_HBURST),
        .EXP_HPROT(EXP_HPROT),
        .EXP_HWDATA(EXP_HWDATA),
        .EXP_HMASTLOCK(EXP_HMASTLOCK),
        .EXP_HREADYMUX(EXP_HREADY),

        // System ROM Table Region Slave Port
        .SYSTABLE_HRDATA(SYSTABLE_HRDATA),
        .SYSTABLE_HREADYOUT(SYSTABLE_HREADYOUT),
        .SYSTABLE_HRESP(SYSTABLE_HRESP),
        .SYSTABLE_HSEL(SYSTABLE_HSEL),
        .SYSTABLE_HADDR(SYSTABLE_HADDR),
        .SYSTABLE_HTRANS(SYSTABLE_HTRANS),
        .SYSTABLE_HWRITE(SYSTABLE_HWRITE),
        .SYSTABLE_HSIZE(SYSTABLE_HSIZE),
        .SYSTABLE_HBURST(SYSTABLE_HBURST),
        .SYSTABLE_HPROT(SYSTABLE_HPROT),
        .SYSTABLE_HWDATA(SYSTABLE_HWDATA),
        .SYSTABLE_HMASTLOCK(SYSTABLE_HMASTLOCK),
        .SYSTABLE_HREADYMUX(SYSTABLE_HREADY)
    );

endmodule
