//-----------------------------------------------------------------------------
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_chip_cfg  #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter GPIO_TIO = 4  // number of GPIO TEST IO pins to reconfigure
 )
(
  // Primary Inputs
   input  wire                pad_clk_i    // CLK  pad input
  ,input  wire                pad_nrst_i   // NRST pad input
  ,input  wire                pad_test_i   // TEST pad input
  // Alternate/reconfigurable input and associated bidirectional inout
  ,input  wire                pad_altin_i  // SWCLK/UARTRXD/SCAN-ENABLE
  ,input  wire                pad_altio_i  // SWDIO/UARTTXD tristate input
  ,output wire                pad_altio_o  // SWDIO/UARTTXD trstate output
  ,output wire                pad_altio_e  // SWDIO/UARTTXD tristate output enable
  ,output wire                pad_altio_z  // SWDIO/UARTTXD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-0 (user)
  ,input  wire [GPIO_TIO-1:0] pad_gpio_port0_i  // GPIO PAD tristate input
  ,output wire [GPIO_TIO-1:0] pad_gpio_port0_o  // GPIO PAD trstate output
  ,output wire [GPIO_TIO-1:0] pad_gpio_port0_e  // GPIO PAD tristate output enable
  ,output wire [GPIO_TIO-1:0] pad_gpio_port0_z  // GPIO PAD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-1 (system)
  ,input  wire [GPIO_TIO-1:0] pad_gpio_port1_i  // GPIO PAD tristate input
  ,output wire [GPIO_TIO-1:0] pad_gpio_port1_o  // GPIO PAD trstate output
  ,output wire [GPIO_TIO-1:0] pad_gpio_port1_e  // GPIO PAD tristate output enable
  ,output wire [GPIO_TIO-1:0] pad_gpio_port1_z  // GPIO PAD tristate output hiz
  //SOC
  ,output wire                soc_nreset
  ,output wire                soc_diag_mode
  ,output wire                soc_diag_ctrl
  ,output wire                soc_scan_mode
  ,output wire                soc_scan_enable
  ,output wire [GPIO_TIO-1:0] soc_scan_in  // soc test scan chain inputs
  ,input  wire [GPIO_TIO-1:0] soc_scan_out // soc test scan chain outputs

  ,output wire                soc_bist_mode
  ,output wire                soc_bist_enable
  ,output wire [GPIO_TIO-1:0] soc_bist_in  // soc bist control inputs
  ,input  wire [GPIO_TIO-1:0] soc_bist_out // soc test status outputs

  ,output wire                soc_alt_mode    // ALT MODE = UART
  ,output wire                soc_uart_rxd_i  // UART RXD
  ,input  wire                soc_uart_txd_o  // UART TXD
  ,output wire                soc_swd_mode    // SWD mode
  ,output wire                soc_swd_clk_i   // SWDCLK
  ,output wire                soc_swd_dio_i   // SWDIO tristate input
  ,input  wire                soc_swd_dio_o   // SWDIO trstate output
  ,input  wire                soc_swd_dio_e   // SWDIO tristate output enable
  ,input  wire                soc_swd_dio_z   // SWDIO tristate output hiz

  ,output wire [GPIO_TIO-1:0] soc_gpio_port0_i  // GPIO SOC tristate input
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port0_o  // GPIO SOC trstate output
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port0_e  // GPIO SOC tristate output enable
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port0_z  // GPIO SOC tristate output hiz

  ,output wire [GPIO_TIO-1:0] soc_gpio_port1_i  // GPIO SOC tristate input
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port1_o  // GPIO SOC trstate output
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port1_e  // GPIO SOC tristate output enable
  ,input  wire [GPIO_TIO-1:0] soc_gpio_port1_z  // GPIO SOC tristate output hiz

);

// --------------------------------------------------------------------------
// Primary POR/Reset synchronizer
//  (Active-Low assertion for 9+ valid clocks)
// generate rising-edge synchornized resets:
//   nrst_early - early reset initialization of configuration mode state
//   soc_nrst   - soc reset (8/9-clock cycles after NRST deasserted)
// --------------------------------------------------------------------------

reg [7:0] sync_nrst_sr; // 8-sbit shift-right shift-reg

  always @(posedge pad_clk_i or negedge pad_nrst_i)
    if(!pad_nrst_i)
        sync_nrst_sr <= 8'b00000000;
    else if (!sync_nrst_sr[0]) // gate clock off after reset complete
        sync_nrst_sr <= {1'b1, sync_nrst_sr[7:1]};

wire nrst_early = sync_nrst_sr[6]; // 2nd register stage

wire cfg_window = !sync_nrst_sr[0]; // until final register stage

wire cfg_sample  = sync_nrst_sr[6] & !sync_nrst_sr[2]; // safe to sample config modes
wire cfg_capture = sync_nrst_sr[2] & !sync_nrst_sr[1]; // safe to capture config

// --------------------------------------------------------------------------
// test control synchronizer
//    independently synchronized to NRST so -1/0/+1 cyce relationship 
//  (requires 9+ valid clocks before fully initialised)
// generate rising-edge synchornized state decodes:
//   held-low during reset
//   rising-edge near reset deassertion (ALT-mode entry)
//   falling-edge near reset deassertion (BIST-mode entry)
//   held-high during reset (SCAN-mode entry
// --------------------------------------------------------------------------

reg [7:0] sync_tst_sr; // 8-bit shift-right shift-reg
// requires 8 clock cycles of reset to flush through as not resettable

  always @(posedge pad_clk_i)
    if (cfg_window) // gate clock after configuration window
        sync_tst_sr <= {pad_test_i, sync_tst_sr[7:1]};

wire test_heldlow = !(|sync_tst_sr[6:0]);
wire test_posedge =  ( sync_tst_sr[4] & !sync_tst_sr[3]);
wire test_negedge =  (!sync_tst_sr[4] &  sync_tst_sr[3]);
wire test_heldhi  =   &sync_tst_sr[6:0];

localparam SYSCONFIG  = 2'b00;
localparam ALTCONFIG  = 2'b01;
localparam BISTCONFIG = 2'b10;
localparam SCANCONFIG = 2'b11;

reg [1:0] cfg_mode;

  always @(posedge pad_clk_i or negedge nrst_early)
    if(!nrst_early) begin
        cfg_mode <= SYSCONFIG; // //pulldown
    end else if (cfg_sample) begin
      if      (test_posedge) cfg_mode <= ALTCONFIG;  // test timed with nrst
      else if (test_negedge) cfg_mode <= BISTCONFIG; // test timed with !nrst
      else if (test_heldhi ) cfg_mode <= SCANCONFIG; // pullup
    end

// --------------------------------------------------------------------------

reg [7:0] sync_alt_sr; // 8-bit shift-right shift-reg
// requires 8 clock cycles of reset to flush through as not resettable

  always @(posedge pad_clk_i)
    if (cfg_window) // gate clock after configuration window
        sync_alt_sr <= {pad_altin_i, sync_alt_sr[7:1]};

wire alt_heldlow  = !(|sync_alt_sr[6:0]);
wire alt_posedge  =  ( sync_alt_sr[4] & !sync_alt_sr[3]);
wire alt_negedge  =  (!sync_alt_sr[4] &  sync_alt_sr[3]);
wire alt_heldhi   =   &sync_alt_sr[6:0];

reg [1:0] cfg_diag;

  always @(posedge pad_clk_i or negedge nrst_early)
    if(!nrst_early) begin
        cfg_diag <= 2'b00; // unused - pulldown?
    end else if (cfg_sample) begin
      if      (alt_posedge ) cfg_diag <= 2'b01; // alt timed with nrst
      else if (alt_negedge ) cfg_diag <= 2'b10; // alt timed with !nrst
//      else if (alt_heldhi  ) cfg_diag <= 2'b11; // unused - pullup?
    end

// --------------------------------------------------------------------------

reg cfg_sys;
reg cfg_alt;
reg cfg_bist;
reg cfg_scan;
reg diag_mode;
reg diag_ctrl;

// (tristated IO depending on pullup/pulldowns when until cnfigured)

  always @(posedge pad_clk_i or negedge nrst_early)
    if(!nrst_early) begin
      cfg_sys    <= 1'b0;
      cfg_alt    <= 1'b0;
      cfg_bist   <= 1'b0;
      cfg_scan   <= 1'b0;
      diag_mode  <= 1'b0;
      diag_ctrl  <= 1'b0;
    end else if (cfg_capture) begin
      case (cfg_mode)
      SYSCONFIG  : cfg_sys   <= 1'b1;
      ALTCONFIG  : cfg_alt   <= 1'b1;
      BISTCONFIG : cfg_bist  <= 1'b1;
      SCANCONFIG : cfg_scan  <= 1'b1;
      endcase
      diag_mode   <= cfg_diag[0]; // !cfg_diag[1] &  cfg_diag[0];
      diag_ctrl   <= cfg_diag[1]; // cfg_diag[1] & !cfg_diag[0];
    end

// --------------------------------------------------------------------------
// SoC IO reconfiguration
// --------------------------------------------------------------------------

// ungated clock, no PLL/locked gating
assign soc_nreset = sync_nrst_sr[0];

assign soc_scan_mode    =  cfg_scan;
assign soc_scan_enable  =  cfg_scan & pad_altin_i;
assign soc_scan_in      = (cfg_scan) ? pad_gpio_port0_i : {GPIO_TIO{1'b0}};

assign soc_bist_mode    =  cfg_bist;
assign soc_bist_enable  =  cfg_bist & pad_altin_i;
assign soc_bist_in      = (cfg_bist) ? pad_gpio_port0_i : {GPIO_TIO{1'b0}};

wire   cfg_scan_or_bist = cfg_scan | cfg_bist;

wire [GPIO_TIO-1:0] scan_or_bist_out = ({GPIO_TIO{cfg_scan}} & soc_scan_out)
                                     | ({GPIO_TIO{cfg_bist}} & soc_bist_out);

assign pad_gpio_port0_o = (cfg_scan_or_bist) ? {GPIO_TIO{1'b0}} : soc_gpio_port0_o;
assign pad_gpio_port0_e = (cfg_scan_or_bist) ? {GPIO_TIO{1'b0}} : soc_gpio_port0_e;
assign pad_gpio_port0_z = ~pad_gpio_port0_e;
assign soc_gpio_port0_i =  pad_gpio_port0_i;

assign pad_gpio_port1_o = (cfg_scan_or_bist) ? scan_or_bist_out : soc_gpio_port1_o;
assign pad_gpio_port1_e = (cfg_scan_or_bist) ? {GPIO_TIO{1'b1}} : soc_gpio_port1_e;
assign pad_gpio_port1_z = ~pad_gpio_port1_e;
assign soc_gpio_port1_i =  pad_gpio_port1_i;

assign soc_swd_mode = cfg_sys;

assign soc_alt_mode = cfg_alt;

assign soc_swd_clk_i =  cfg_sys & pad_altin_i; // low unless configured
assign soc_swd_dio_i =  cfg_sys & pad_altio_i;

assign soc_uart_rxd_i =  !cfg_alt | pad_altin_i; // high unless configured

assign pad_altio_o = (cfg_sys & soc_swd_dio_o) | (cfg_alt & soc_uart_txd_o);
assign pad_altio_e = (cfg_sys & soc_swd_dio_e) | (cfg_alt);
assign pad_altio_z = !pad_altio_e;

assign soc_diag_mode = diag_mode;
assign soc_diag_ctrl = diag_ctrl;

endmodule

/* example usage:

//------------------------------------
// internal wires

localparam GPIO_TIO = 4;

wire        pad_clk_i;
wire        pad_nrst_i;
wire        pad_test_i;
wire        pad_swdclk_i;
wire        pad_swdio_i;
wire        pad_swdio_o;
wire        pad_swdio_e;
wire        pad_swdio_z;
wire [15:0] pad_gpio_port0_i ; 
wire [15:0] pad_gpio_port0_o ;
wire [15:0] pad_gpio_port0_e ;
wire [15:0] pad_gpio_port0_z ;
wire [15:0] pad_gpio_port1_i ;
wire [15:0] pad_gpio_port1_o ;
wire [15:0] pad_gpio_port1_e ;
wire [15:0] pad_gpio_port1_z ;
wire        soc_nreset;
wire        soc_diag_mode;
wire        soc_diag_ctrl;
wire        soc_scan_mode;
wire        soc_scan_enable;
wire [GPIO_TIO-1:0] soc_scan_in; //soc test status outputs
wire [GPIO_TIO-1:0] soc_scan_out = soc_scan_in; //soc test status outputs
wire        soc_bist_mode;
wire        soc_bist_enable;
wire [GPIO_TIO-1:0] soc_bist_in; //soc test status outputs
wire [GPIO_TIO-1:0] soc_bist_out = ~soc_bist_in; //soc test status outputs
wire        soc_alt_mode; // ALT MODE = UART
wire        soc_uart_rxd_i; // UART RXD
wire        soc_uart_txd_o = 1'b1; // UART TXD
wire        soc_swd_mode; // SWD mode
wire        soc_swd_clk_i; // SWDCLK
wire        soc_swd_dio_i; // SWDIO tristate input
wire        soc_swd_dio_o; // SWDIO trstate output
wire        soc_swd_dio_e; // SWDIO tristate output enable
wire        soc_swd_dio_z; // SWDIO tristate output hiz
wire [15:0] soc_gpio_port0_i; // GPIO SOC tristate input
wire [15:0] soc_gpio_port0_o; // GPIO SOC trstate output
wire [15:0] soc_gpio_port0_e; // GPIO SOC tristate output enable
wire [15:0] soc_gpio_port0_z; // GPIO SOC tristate output hiz
wire [15:0] soc_gpio_port1_i; // GPIO SOC tristate input
wire [15:0] soc_gpio_port1_o; // GPIO SOC trstate output
wire [15:0] soc_gpio_port1_e; // GPIO SOC tristate output enable
wire [15:0] soc_gpio_port1_z; // GPIO SOC tristate output hiz

// connect up high order GPIOs
assign soc_gpio_port0_i[15:GPIO_TIO] = pad_gpio_port0_i[15:GPIO_TIO];
assign pad_gpio_port0_o[15:GPIO_TIO] = soc_gpio_port0_o[15:GPIO_TIO];
assign pad_gpio_port0_e[15:GPIO_TIO] = soc_gpio_port0_e[15:GPIO_TIO];
assign pad_gpio_port0_z[15:GPIO_TIO] = soc_gpio_port0_z[15:GPIO_TIO];
assign soc_gpio_port1_i[15:GPIO_TIO] = pad_gpio_port1_i[15:GPIO_TIO];
assign pad_gpio_port1_o[15:GPIO_TIO] = soc_gpio_port1_o[15:GPIO_TIO];
assign pad_gpio_port1_e[15:GPIO_TIO] = soc_gpio_port1_e[15:GPIO_TIO];
assign pad_gpio_port1_z[15:GPIO_TIO] = soc_gpio_port1_z[15:GPIO_TIO];


nanosoc_chip_cfg #(
    .GPIO_TIO (GPIO_TIO)
  )
  u_nanosoc_chip_cfg
  (
  // Primary Inputs
   .pad_clk_i        (pad_clk_i         )
  ,.pad_nrst_i       (pad_nrst_i        )
  ,.pad_test_i       (pad_test_i        )
  // Alternate/reconfigurable IP and associated bidirectional I/O
  ,.pad_altin_i      (pad_swdclk_i      )  // SWCLK/UARTRXD/SCAN-ENABLE
  ,.pad_altio_i      (pad_swdio_i       )  // SWDIO/UARTTXD tristate input
  ,.pad_altio_o      (pad_swdio_o       )  // SWDIO/UARTTXD trstate output
  ,.pad_altio_e      (pad_swdio_e       )  // SWDIO/UARTTXD tristate output enable
  ,.pad_altio_z      (pad_swdio_z       )  // SWDIO/UARTTXD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-0 (user)
  ,.pad_gpio_port0_i (pad_gpio_port0_i[GPIO_TIO-1:0]) // GPIO PAD tristate input
  ,.pad_gpio_port0_o (pad_gpio_port0_o[GPIO_TIO-1:0]) // GPIO PAD trstate output
  ,.pad_gpio_port0_e (pad_gpio_port0_e[GPIO_TIO-1:0]) // GPIO PAD tristate output enable
  ,.pad_gpio_port0_z (pad_gpio_port0_z[GPIO_TIO-1:0]) // GPIO PAD tristate output hiz
  // Reconfigurable General Purpose bidirectional I/Os Port-1 (system)
  ,.pad_gpio_port1_i (pad_gpio_port1_i[GPIO_TIO-1:0]) // GPIO PAD tristate input
  ,.pad_gpio_port1_o (pad_gpio_port1_o[GPIO_TIO-1:0]) // GPIO PAD trstate output
  ,.pad_gpio_port1_e (pad_gpio_port1_e[GPIO_TIO-1:0]) // GPIO PAD tristate output enable
  ,.pad_gpio_port1_z (pad_gpio_port1_z[GPIO_TIO-1:0]) // GPIO PAD tristate output hiz
  //SOC
  ,.soc_nreset       (soc_nreset        )
  ,.soc_diag_mode    (soc_diag_mode     )
  ,.soc_diag_ctrl    (soc_diag_ctrl     )
  ,.soc_scan_mode    (soc_scan_mode     )
  ,.soc_scan_enable  (soc_scan_enable   )
  ,.soc_scan_in      (soc_scan_in       ) // soc test scan chain inputs
  ,.soc_scan_out     (soc_scan_out      ) // soc test scan chain outputs
  ,.soc_bist_mode    (soc_bist_mode     )
  ,.soc_bist_enable  (soc_bist_enable   )
  ,.soc_bist_in      (soc_bist_in       ) // soc bist control inputs
  ,.soc_bist_out     (soc_bist_out      ) // soc test status outputs
  ,.soc_alt_mode     (soc_alt_mode      )// ALT MODE = UART
  ,.soc_uart_rxd_i   (soc_uart_rxd_i    ) // UART RXD
  ,.soc_uart_txd_o   (soc_uart_txd_o    ) // UART TXD
  ,.soc_swd_mode     (soc_swd_mode      ) // SWD mode
  ,.soc_swd_clk_i    (soc_swd_clk_i     ) // SWDCLK
  ,.soc_swd_dio_i    (soc_swd_dio_i     ) // SWDIO tristate input
  ,.soc_swd_dio_o    (soc_swd_dio_o     ) // SWDIO trstate output
  ,.soc_swd_dio_e    (soc_swd_dio_e     ) // SWDIO tristate output enable
  ,.soc_swd_dio_z    (soc_swd_dio_z     ) // SWDIO tristate output hiz
  ,.soc_gpio_port0_i (soc_gpio_port0_i[GPIO_TIO-1:0]) // GPIO SOC tristate input
  ,.soc_gpio_port0_o (soc_gpio_port0_o[GPIO_TIO-1:0]) // GPIO SOC trstate output
  ,.soc_gpio_port0_e (soc_gpio_port0_e[GPIO_TIO-1:0]) // GPIO SOC tristate output enable
  ,.soc_gpio_port0_z (soc_gpio_port0_z[GPIO_TIO-1:0]) // GPIO SOC tristate output hiz
  ,.soc_gpio_port1_i (soc_gpio_port1_i[GPIO_TIO-1:0]) // GPIO SOC tristate input
  ,.soc_gpio_port1_o (soc_gpio_port1_o[GPIO_TIO-1:0]) // GPIO SOC trstate output
  ,.soc_gpio_port1_e (soc_gpio_port1_e[GPIO_TIO-1:0]) // GPIO SOC tristate output enable
  ,.soc_gpio_port1_z (soc_gpio_port1_z[GPIO_TIO-1:0]) // GPIO SOC tristate output hiz
);

 always @(posedge soc_nreset)
  begin
    $display(">>> soc_diag_mode     = %b", soc_diag_mode     );
    $display(">>> soc_diag_ctrl     = %b", soc_diag_ctrl     );
    $display(">>> soc_scan_mode     = %b", soc_scan_mode     );
    $display(">>> soc_scan_enable   = %b", soc_scan_enable   );
    $display(">>> soc_scan_in       = %b", soc_scan_in       );
    $display(">>> soc_scan_out      = %b", soc_scan_out      );
    $display(">>> soc_bist_mode     = %b", soc_bist_mode     );
    $display(">>> soc_bist_enable   = %b", soc_bist_enable   );
    $display(">>> soc_bist_in       = %b", soc_bist_in       );
    $display(">>> soc_bist_out      = %b", soc_bist_out      );
    $display(">>> soc_alt_mode      = %b", soc_alt_mode      );
    $display(">>> soc_uart_rxd_i    = %b", soc_uart_rxd_i    );
    $display(">>> soc_uart_txd_o    = %b", soc_uart_txd_o    );
    $display(">>> soc_swd_mode      = %b", soc_swd_mode      );
    $display(">>> soc_swd_clk_i     = %b", soc_swd_clk_i     );
    $display(">>> soc_swd_dio_i     = %b", soc_swd_dio_i     );
    $display(">>> soc_swd_dio_o     = %b", soc_swd_dio_o     );
    $display(">>> soc_swd_dio_e     = %b", soc_swd_dio_e     );
    $display(">>> soc_swd_dio_z     = %b", soc_swd_dio_z     );
    
    $display(">>> pad_swdclk_i      = %b", pad_swdclk_i      );
    $display(">>> pad_swdio_i       = %b", pad_swdio_i       );
    $display(">>> pad_swdio_o       = %b", pad_swdio_o       );
    $display(">>> pad_swdio_e       = %b", pad_swdio_e       );
    $display(">>> pad_swdio_z       = %b", pad_swdio_z       );
    
  end
 // --------------------------------------------------------------------------------
 // Cortex-M0 nanosoc Microcontroller
 // --------------------------------------------------------------------------------

  nanosoc_chip u_nanosoc_chip (
`ifdef POWER_PINS
  .VDD        (VDD),
  .VSS        (VSS),
  .VDDACC     (VDDACC),
`endif
`ifdef ASIC_TEST_PORTS
  .diag_mode   (soc_diag_mode     ),
  .diag_ctrl   (soc_diag_ctrl     ),
  .scan_mode   (soc_scan_mode     ),
  .scan_enable (soc_scan_enable   ),
  .scan_in     ({GPIO_TIO{1'b0}), // soc test scan chain inputs
  .scan_out    ( ),       // soc test scan chain outputs
  .bist_mode   (bist_mode         ),
  .bist_enable (bist_enable       ),
  .bist_in     ({GPIO_TIO{1'b1}), // soc bist control inputs
  .bist_out    ( ),       // soc test status outputs
  .alt_mode    (1'b0),    // ALT MODE = UART
  .uart_rxd_i  (1'b1),    // UART RXD
  .uart_txd_o  ( ),       // UART TXD
  .swd_mode    (1'b1),    // SWD mode
`endif
  .clk_i(pad_clk_i),
  .test_i(soc_scan_mode), //(test_i),
  .nrst_i(soc_nreset), //(nrst_i),
  .p0_i(soc_gpio_port0_i), // level-shifted input from pad
  .p0_o(soc_gpio_port0_o), // output port drive
  .p0_e(soc_gpio_port0_e), // active high output drive enable (pad tech dependent)
  .p0_z(soc_gpio_port0_z), // active low output drive enable (pad tech dependent)
  .p1_i(soc_gpio_port1_i), // level-shifted input from pad
  .p1_o(soc_gpio_port1_o), // output port drive
  .p1_e(soc_gpio_port1_e), // active high output drive enable (pad tech dependent)
  .p1_z(soc_gpio_port1_z), // active low output drive enable (pad tech dependent)
  .swdio_i(soc_swd_dio_i),
  .swdio_o(soc_swd_dio_o),
  .swdio_e(soc_swd_dio_e),
  .swdio_z(soc_swd_dio_z),
  .swdclk_i(soc_swd_clk_i)
  );

*/
