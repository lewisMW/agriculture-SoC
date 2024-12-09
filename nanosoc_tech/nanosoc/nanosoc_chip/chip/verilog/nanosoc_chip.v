//-----------------------------------------------------------------------------
// Nanosoc Chip-level File
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
`include "gen_defines.v"

module nanosoc_chip #(
  parameter integer FT1248_WIDTH = 1, // Only 1-bit serial supported for min pincount
  parameter integer GPIO_TIO	 = 4 // reconfigure lowest four GPIO ports for test
)(
`ifdef POWER_PINS
  inout  wire          VDD,
  inout  wire          VSS,
  inout  wire          VDDACC,
`endif
//`ifdef ASIC_TEST_PORTS
  input  wire                diag_mode,
  input  wire                diag_ctrl,
  input  wire                scan_mode,
  input  wire                scan_enable,
  input  wire [GPIO_TIO-1:0] scan_in,     // soc test scan chain inputs
  output wire [GPIO_TIO-1:0] scan_out,    // soc test scan chain outputs
  input  wire                bist_mode,
  input  wire                bist_enable,
  input  wire [GPIO_TIO-1:0] bist_in,     // soc bist control inputs
  output wire [GPIO_TIO-1:0] bist_out,    // soc test status outputs
  input  wire                alt_mode,    // ALT MODE = UART
  input  wire                uart_rxd_i,  // UART RXD
  output wire                uart_txd_o,  // UART TXD
  input  wire                swd_mode,    // SWD mode
//`endif
  input  wire          clk_i,
//  output wire          xtal_clk_o,
  input  wire          test_i,
  input  wire          nrst_i,
  input  wire  [15:0]  p0_i, // level-shifted input from pad
  output wire  [15:0]  p0_o, // output port drive
  output wire  [15:0]  p0_e, // active high output drive enable (pad tech dependent)
  output wire  [15:0]  p0_z, // active low output drive enable (pad tech dependent)
  input  wire  [15:0]  p1_i, // level-shifted input from pad
  output wire  [15:0]  p1_o, // output port drive
  output wire  [15:0]  p1_e, // active high output drive enable (pad tech dependent)
  output wire  [15:0]  p1_z, // active low output drive enable (pad tech dependent)
  input  wire          swdio_i, // alternate test clock control
  output wire          swdio_o,
  output wire          swdio_e,
  output wire          swdio_z,
  input  wire          swdclk_i // alternate test scan enable
);

  //--------------------------
  // System Wiring
  //--------------------------
  // Free-running and Crystal Clock Output
  wire                     SYS_CLK;              // System Input Clock
  wire                     PLL_CLK;              // Phase-Locked Loop Clock
  wire                     SYS_XTALCLK_OUT;      // Crystal Clock Output
  
  // Scan Wiring
  wire                     SYS_SCANENABLE;      // Scan Mode Enable
  wire                     SYS_TESTMODE;        // Test Mode Enable (Override Synchronisers)
  wire                     SYS_SCANINHCLK;      // HCLK scan wire - TIE OFF
  wire                     SYS_SCANOUTHCLK;     // Scan Chain Output - UNUSED
  
  // Serial-Wire Debug
  wire                     CPU_0_SWDI;         // SWD data input
  wire                     CPU_0_SWCLK;        // SWD clock
  wire                     CPU_0_SWDO;         // SWD data output
  wire                     CPU_0_SWDOEN;       // SWD data enable
  
  // GPIO
  wire              [15:0] P0_IN;            // GPIO 0 inputs
  wire              [15:0] P0_OUT;           // GPIO 0 outputs
  wire              [15:0] P0_OUTEN;         // GPIO 0 output enables
  
  wire              [15:0] P1_IN;        // level-shifted input from pad
  wire              [15:0] P1_OUT;           // GPIO 1 outputs
  wire              [15:0] P1_OUTEN;         // GPIO 1 output enables
  
  //--------------------------
  // FPGA-Specific Wiring - Should be own Module
  //--------------------------
  
  // Technology-specific PLL/Frequecy synthesizer would generate
  //   CLK, FCLK (Free running system clock)
  // from
  //    clk_i
  
  assign PLL_CLK    = clk_i; // Default to no PLL

//`ifdef ASIC_TEST_PORTS
  assign SYS_SCANENABLE   = scan_enable;
  assign SYS_TESTMODE     = scan_mode;
  assign SYS_SCANINHCLK   = 1'b1;
///  assign scan_out         = scan_in;
  assign bist_out         = bist_in;
///  assign uart_txd_o       = uart_rxd_i;
//`else
//  assign SYS_SCANENABLE   = test_i & swdio_i; 
//  assign SYS_TESTMODE     = test_i;   
//  assign SYS_SCANINHCLK   = 1'b1;
//`endif

  //--------------------------
  // Clock Wiring
  //--------------------------
  
  assign SYS_CLK    = (SYS_TESTMODE) ? clk_i : PLL_CLK;
  
  //--------------------------
  // SWD Wiring
  //--------------------------
  
  assign CPU_0_SWCLK = swdclk_i;
  assign CPU_0_SWDI  = swdio_i;
  assign swdio_o     = CPU_0_SWDO;
  assign swdio_e     = CPU_0_SWDOEN;
  assign swdio_z     = !CPU_0_SWDOEN;
  
  //--------------------------
  // PIO pad control
  //--------------------------
  
  assign P0_IN = p0_i;
  assign p0_o  = P0_OUT;
  assign p0_e  = P0_OUTEN;
  assign p0_z  = ~P0_OUTEN;


  assign        P1_IN = p1_i;
  assign        p1_o[15:0] = P1_OUT[15:0];
  assign        p1_e[15:0] = P1_OUTEN[15:0];
  assign        p1_z[15:0] = ~P1_OUTEN[15:0];

  //--------------------------
  // System Instantiation
  //--------------------------
  
  nanosoc_system u_system (
      // Free-running and Crystal Clock Output
      .SYS_CLK(SYS_CLK),
      .SYS_XTALCLK_OUT(SYS_XTALCLK_OUT),
      .SYS_SYSRESETn(nrst_i),

      // Scan Wiring
      .SYS_SCANENABLE(SYS_SCANENABLE),
      .SYS_TESTMODE(SYS_TESTMODE),
      .SYS_SCANINHCLK(SYS_SCANINHCLK),
      .SYS_SCANOUTHCLK(SYS_SCANOUTHCLK),

      // Serial-Wire Debug
      .CPU_0_SWDI(CPU_0_SWDI),
      .CPU_0_SWCLK(CPU_0_SWCLK),
      .CPU_0_SWDO(CPU_0_SWDO),
      .CPU_0_SWDOEN(CPU_0_SWDOEN),

      // GPIO
      .P0_IN(P0_IN),
      .P0_OUT(P0_OUT),
      .P0_OUTEN(P0_OUTEN),
      .P1_IN(P1_IN), //_MUX),
      .P1_OUT(P1_OUT),
      .P1_OUTEN(P1_OUTEN)
  );

endmodule