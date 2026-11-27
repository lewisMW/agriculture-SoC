//-----------------------------------------------------------------------------
// nanosoc in the ChipFoundry OpenFrame user-project wrapper (SKY130, experiment)
//
// The port list is the one from chipfoundry/openframe_user_project
// verilog/rtl/openframe_project_wrapper.v (Efabless, Apache-2.0) and must not
// change: the padframe is fixed and the wrapper's pins are placed from its DEF
// template. Inside, this is nanosoc_chip_pads.v without the sky130 pad ring:
// the same nanosoc_chip_cfg + nanosoc_chip, with each pad replaced by one
// CF_gpio_config (ChipFoundry's pad-configuration block) on an OpenFrame GPIO.
//
// GPIO map (index: wrapper edge, as placed by the template DEF). It is laid out
// for ChipFoundry's Caravel development board, which an OpenFrame chip fits
// (their "OpenFrame I/O Mapping" article): on that board GPIO 1-4 go to the FTDI
// chip's SPI lines, 5 and 6 to its UART through switches, 36 and 37 to the SPI
// flash's IO2/IO3, 38 to the clock generator, 39-42 to the flash's CSB, CLK, IO0
// and IO1, and 43 to the LED; the rest reach header pins only.
//   38      bottom  CLK                   the board's clock generator (10 MHz)
//   5, 6    right   P1[4], P1[5]          UART2 RXD / TXD (with P1[7] high): the
//                                         board's USB UART; HOSTIO4 data 1, 2 otherwise
//   0       right   P1[0]                 the host link's FT1248 MISO, an input (low:
//                                         the host has data), or HOSTIO4 req1, an
//                                         output. While the chip does not drive it
//                                         the pad has its pull-up, so that a board
//                                         with no host connected sends the chip
//                                         nothing.
//   7-10    right   P1[1], P1[2], P1[3],  the rest of the host link, on header pins:
//                   P1[6]                 FT1248 clock, data, select; HOSTIO4 req2,
//                                         ack, data 0, data 3
//   11      right   P1[7]                 the host-link mode strap, an input with the
//                                         pad's pull-up: FT1248 + UART2 unless the pin
//                                         is tied low (HOSTIO4). P1[7] cannot drive it.
//   39-42   bottom  P1[8..11]             the board's SPI flash: CSB, CLK, IO0 (to the
//                                         flash), IO1 (from the flash). The boot ROM
//                                         reads a program from it (sw/bootrom). While
//                                         nothing drives CSB (the chip in reset, or
//                                         P1[8] an input) the pad has its pull-up, so
//                                         the flash is not selected.
//   36, 37  left    P1[13], P1[14]        the flash's IO2/IO3 (its write-protect and
//                                         hold inputs in plain SPI mode)
//   14      right   FLASH_PROG            input with the pad's pull-down. High: the
//                                         chip is held in reset and the FTDI's SPI
//                                         lines are passed straight through to the
//                                         flash, so the board's USB port can program
//                                         it: GPIO 3 (CSB) -> 39, 4 (SCK) -> 40,
//                                         2 (SDI) -> 41, and 42 (IO1) -> 1 (SDO)
//   23      top     P1[12]                header pin
//   24-35   left    P0[0..11]             header pins
//   1-4     right   P0[12..15]            also the FTDI's SPI lines: leave as inputs
//                                         while the FTDI is in use
//   43      bottom  P1[15]                the board's LED
//   18, 19  top     TEST, SE              inputs with the pad's pull-down: low unless driven
//   20, 21  top     SWDCK (pull-down), SWDIO     header pins
//   15-17   top     ADC_VREF, ADC_VINP, ADC_VINN (analog_io): the three top pads
//                   nearest the frame's vdda1/vssa1 pins (top right); their
//                   neighbours 14 and 18-21 are pins that stay still in normal use
//   12, 13, 22      unused: analog mode, input buffer off (ChipFoundry's setting
//                   for an unused OpenFrame pad)
// Reset: nrst = resetb_l AND porb_l AND NOT FLASH_PROG: the frame's 1.8 V master
// reset and its power-on reset (both active low), and the programming strap.
// porb_h, por_l, resetb_h, gpio_in_h, mask_rev and analog_noesd_io are left
// unconnected.
// Supplies: vccd1/vssd1 are the core 1.8 V rails (VDD/VSS of the chip flow);
// vdda1/vssa1 feed the sar_afe macro's vdda/vss; ADC_VREF is a supply net to the
// macro's vref pin (see ../Cadence/inputs/openframe_project_wrapper.upf) and
// is put on the analog_io[15] port and pin in the power plan.
//-----------------------------------------------------------------------------
`ifndef OPENFRAME_IO_PADS
`define OPENFRAME_IO_PADS 44
`endif
// The chip flow reads RTL with -define POWER_PINS; the OpenFrame template guards
// its supply ports with USE_POWER_PINS.
`ifdef POWER_PINS
`ifndef USE_POWER_PINS
`define USE_POWER_PINS
`endif
`endif
`include "gen_defines.v"

module openframe_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda,		// User area 0 3.3V supply
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa,		// User area 0 analog ground
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd,		// Common 1.8V supply
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd,		// Common digital ground
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
    inout vddio,	// Common 3.3V ESD supply
    inout vssio,	// Common ESD ground
`endif

    /* Signals exported from the frame area to the user project */
    /* The user may elect to use any of these inputs.		*/

    input	 porb_h,	// power-on reset, sense inverted, 3.3V domain
    input	 porb_l,	// power-on reset, sense inverted, 1.8V domain
    input	 por_l,		// power-on reset, noninverted, 1.8V domain
    input	 resetb_h,	// master reset, sense inverted, 3.3V domain
    input	 resetb_l,	// master reset, sense inverted, 1.8V domain
    input [31:0] mask_rev,	// 32-bit user ID, 1.8V domain

    /* GPIOs.  There are 44 GPIOs (19 left, 19 right, 6 bottom). */
    /* These must be configured appropriately by the user project. */

    /* Basic bidirectional I/O.  Input gpio_in_h is in the 3.3V domain;  all
     * others are in the 1.8v domain.  OEB is output enable, sense inverted.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in_h,
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,
    output [`OPENFRAME_IO_PADS-1:0] gpio_inp_dis,	// a.k.a. ieb

    /* Pad configuration.  These signals are usually static values.
     * See the documentation for the sky130_fd_io__gpiov2 cell signals
     * and their use.
     */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ib_mode_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_vtrip_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_slow_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_holdover,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_en,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_pol,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm2,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm1,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm0,

    /* These signals correct directly to the pad.  Pads using analog I/O
     * connections should keep the digital input and output buffers turned
     * off.  Both signals connect to the same pad.  The "noesd" signal
     * is a direct connection to the pad;  the other signal connects through
     * a series resistor which gives it minimal ESD protection.  Both signals
     * have basic over- and under-voltage protection at the pad.  These
     * signals may be expected to attenuate heavily above 50MHz.
     */
    inout  [`OPENFRAME_IO_PADS-1:0] analog_io,
    inout  [`OPENFRAME_IO_PADS-1:0] analog_noesd_io,

    /* These signals are constant one and zero in the 1.8V domain, one for
     * each GPIO pad, and can be looped back to the control signals on the
     * same GPIO pad to set a static configuration at power-up.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_one,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_zero
);

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
wire [GPIO_TIO-1:0] soc_scan_out; //soc test status outputs
wire        soc_bist_mode;
wire        soc_bist_enable;
wire [GPIO_TIO-1:0] soc_bist_in; //soc test status outputs
wire [GPIO_TIO-1:0] soc_bist_out; //soc test status outputs
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

wire pad_se_i;

// SAR ADC analog inputs: analog pad P_CORE -> nanosoc_chip ADC_VINP/ADC_VINN ->
// sar_adc u_adc -> sar_afe u_afe vinp/vinn. Analog nets: P&R must not buffer them.
wire pad_adc_vinp;
wire pad_adc_vinn;
// VREF for the ADC - again should not buffer
wire ADC_VREF;

// connect up high order GPIOs
assign soc_gpio_port0_i[15:GPIO_TIO] = pad_gpio_port0_i[15:GPIO_TIO];
assign pad_gpio_port0_o[15:GPIO_TIO] = soc_gpio_port0_o[15:GPIO_TIO];
assign pad_gpio_port0_e[15:GPIO_TIO] = soc_gpio_port0_e[15:GPIO_TIO];
assign pad_gpio_port0_z[15:GPIO_TIO] = soc_gpio_port0_z[15:GPIO_TIO];
assign soc_gpio_port1_i[15:GPIO_TIO] = pad_gpio_port1_i[15:GPIO_TIO];
assign pad_gpio_port1_o[15:GPIO_TIO] = soc_gpio_port1_o[15:GPIO_TIO];
assign pad_gpio_port1_e[15:GPIO_TIO] = soc_gpio_port1_e[15:GPIO_TIO];
assign pad_gpio_port1_z[15:GPIO_TIO] = soc_gpio_port1_z[15:GPIO_TIO];

wire tiehi = 1'b1;
wire tielo = 1'b0;


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
  ,.pad_altin_i      (pad_se_i      )  // SWCLK/UARTRXD/SCAN-ENABLE
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

// Memory sizes: the address width in bytes of each region, which selects the
// DFFRAM macros behind it (sl_sram_dffram.v, or sl_ahb_sram_hold.v for blocks
// from the DFFRAM compiler). nanosoc_chip passes no parameters down, so they are
// set on nanosoc_system from here. The RTL default is 14 (16 kbyte) for all four.
// The values come from of_mem_config.vh, which the flow's config.tcl writes for
// the chosen memory set: 12/10/9/9 (4 kbyte, 1 kbyte, 512 byte, 512 byte) for
// ChipFoundry's pre-hardened blocks, 12/11/11/11 (4 + 2 + 2 + 2 kbyte) for
// compiler-built ones.
`include "of_mem_config.vh"
defparam u_nanosoc_chip.u_system.IMEM_RAM_ADDR_W     = `OF_IMEM_AW;
defparam u_nanosoc_chip.u_system.DMEM_RAM_ADDR_W     = `OF_DMEM_AW;
defparam u_nanosoc_chip.u_system.EXPRAM_L_RAM_ADDR_W = `OF_EXPRAM_L_AW;
defparam u_nanosoc_chip.u_system.EXPRAM_H_RAM_ADDR_W = `OF_EXPRAM_H_AW;

  nanosoc_chip u_nanosoc_chip (
//`ifdef ASIC_TEST_PORTS
  .diag_mode   (soc_diag_mode     ),
  .diag_ctrl   (soc_diag_ctrl     ),
  .scan_mode   (soc_scan_mode     ),
  .scan_enable (soc_scan_enable   ),
  .scan_in     (soc_scan_in       ), // soc test scan chain inputs
  .scan_out    (soc_scan_out      ),       // soc test scan chain outputs
  .bist_mode   (soc_bist_mode     ),
  .bist_enable (soc_bist_enable   ),
  .bist_in     (soc_bist_in       ), // soc bist control inputs
  .bist_out    (soc_bist_out      ),       // soc test status outputs
  .alt_mode    (soc_alt_mode      ),// ALT MODE = UART
  .uart_rxd_i  (soc_uart_rxd_i    ), // UART RXD
  .uart_txd_o  (soc_uart_txd_o    ), // UART TXD
  .swd_mode    (soc_swd_mode      ),    // SWD mode
//`endif
  .clk_i(pad_clk_i),
  .test_i(soc_scan_mode),
  .nrst_i(soc_nreset),
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
  .swdclk_i(pad_swdclk_i),
  .ADC_VINP(pad_adc_vinp), // SAR ADC analog inputs, from uPAD_ADC_VINP/VINN
  .ADC_VINN(pad_adc_vinn)
);

//------------------------------------
// OpenFrame GPIOs. CF_gpio_config MODE: 0 ANALOG, 1 INPUT, 2 INPUT_PD, 3 INPUT_PU,
// 4 OUTPUT, 5 BIDIR (direction from io_oeb, 1 = high impedance, like the pad OE_N).
//------------------------------------
`define OF_GPIO(IDX, MODEV, OUTV, INV, OEBV) \
  CF_gpio_config #(.MODE(MODEV)) u_gpio_cfg_``IDX ( \
    .io_out(OUTV), .io_in(INV), .io_oeb(OEBV), \
    .gpio_zero(gpio_loopback_zero[IDX]), .gpio_one(gpio_loopback_one[IDX]), .gpio_in(gpio_in[IDX]), \
    .gpio_dm({gpio_dm2[IDX], gpio_dm1[IDX], gpio_dm0[IDX]}), .gpio_inp_dis(gpio_inp_dis[IDX]), \
    .gpio_oeb_out(gpio_oeb[IDX]), .gpio_out_val(gpio_out[IDX]), \
    .gpio_analog_en(gpio_analog_en[IDX]), .gpio_analog_sel(gpio_analog_sel[IDX]), .gpio_analog_pol(gpio_analog_pol[IDX]), \
    .gpio_ib_mode_sel(gpio_ib_mode_sel[IDX]), .gpio_vtrip_sel(gpio_vtrip_sel[IDX]), .gpio_slow_sel(gpio_slow_sel[IDX]), \
    .gpio_holdover(gpio_holdover[IDX]));

// The two GPIO ports and SWDIO: bidirectional, direction from the chip.
`define OF_P0(IDX, B) `OF_GPIO(IDX, 3'd5, pad_gpio_port0_o[B], pad_gpio_port0_i[B], pad_gpio_port0_z[B])
`define OF_P1(IDX, B) `OF_GPIO(IDX, 3'd5, pad_gpio_port1_o[B], pad_gpio_port1_i[B], pad_gpio_port1_z[B])

// Flash programming. With FLASH_PROG high the chip is in reset (below) and four
// pads carry the FTDI's SPI lines to the board's flash and back, so that the flash
// can be written from the board's USB port; the other flash and FTDI pads are
// inputs. With it low (the pad's pull-down) every pad is an ordinary port pin.
// The paths are combinational, pad to pad.
wire flash_prog;
wire ftdi_sdi = pad_gpio_port0_i[13];   // GPIO 2, FTDI -> chip
wire ftdi_csb = pad_gpio_port0_i[14];   // GPIO 3
wire ftdi_sck = pad_gpio_port0_i[15];   // GPIO 4
wire flash_do = pad_gpio_port1_i[11];   // GPIO 42, the flash's IO1
// a port pad that carries a passed-through signal while FLASH_PROG is high
`define OF_PT_OUT(IDX, PO, PI, PZ, SRC) `OF_GPIO(IDX, 3'd5, (flash_prog ? SRC : PO), PI, (~flash_prog & PZ))
// a port pad that is an input while FLASH_PROG is high
`define OF_PT_IN(IDX, PO, PI, PZ)       `OF_GPIO(IDX, 3'd5, PO, PI, (flash_prog | PZ))

// right edge
// GPIO 0, P1[0]. In HOSTIO4 mode the chip drives it (request 1); in FT1248 mode it
// is MISO, an input that is low when the host has data, and with no host connected
// nothing else gives the pin a level. So this one pad is not a CF_gpio_config: it
// has that block's bidirectional setting while the chip drives and its
// input-with-pull-up setting while it does not (drive mode 110 or 111, the
// output driver always enabled, the output value 1 in the weak mode). P1[0]'s
// output enable follows the mode strap, so the drive mode is static in use.
wire p1_0_hiz = pad_gpio_port1_z[0];
assign pad_gpio_port1_i[0] = gpio_in[0];
assign gpio_dm2[0]         = gpio_loopback_one[0];
assign gpio_dm1[0]         = gpio_loopback_one[0];
assign gpio_dm0[0]         = p1_0_hiz;
assign gpio_out[0]         = p1_0_hiz | pad_gpio_port1_o[0];
assign gpio_oeb[0]         = gpio_loopback_zero[0];
assign gpio_inp_dis[0]     = gpio_loopback_zero[0];
assign gpio_analog_en[0]   = gpio_loopback_zero[0];
assign gpio_analog_sel[0]  = gpio_loopback_zero[0];
assign gpio_analog_pol[0]  = gpio_loopback_zero[0];
assign gpio_ib_mode_sel[0] = gpio_loopback_zero[0];
assign gpio_vtrip_sel[0]   = gpio_loopback_zero[0];
assign gpio_slow_sel[0]    = gpio_loopback_zero[0];
assign gpio_holdover[0]    = gpio_loopback_zero[0];
`OF_PT_OUT(1, pad_gpio_port0_o[12], pad_gpio_port0_i[12], pad_gpio_port0_z[12], flash_do)
`OF_PT_IN(2, pad_gpio_port0_o[13], pad_gpio_port0_i[13], pad_gpio_port0_z[13])
`OF_PT_IN(3, pad_gpio_port0_o[14], pad_gpio_port0_i[14], pad_gpio_port0_z[14])
`OF_PT_IN(4, pad_gpio_port0_o[15], pad_gpio_port0_i[15], pad_gpio_port0_z[15])
`OF_P1(5, 4)
`OF_P1(6, 5)
`OF_P1(7, 1)
`OF_P1(8, 2)
`OF_P1(9, 3)
`OF_P1(10, 6)
// the host-link mode strap: an input with the pad's pull-up, so that it reads 1
// (FT1248 + UART2, the mode the board's USB UART needs) with nothing connected
`OF_GPIO(11, 3'd3, 1'b1, pad_gpio_port1_i[7], 1'b1)
// unused pads: analog mode (DM 000, input buffer off, output off), the setting
// ChipFoundry's knowledge base asks for on every unused OpenFrame pad
`OF_GPIO(12, 3'd0, 1'b0, , 1'b1)
`OF_GPIO(13, 3'd0, 1'b0, , 1'b1)
// the programming strap: low unless driven
`OF_GPIO(14, 3'd2, 1'b0, flash_prog, 1'b1)

// top edge. Analog pads: digital buffers off, the pad reaches the core on analog_io
`OF_GPIO(15, 3'd0, 1'b0, , 1'b1)
`OF_GPIO(16, 3'd0, 1'b0, , 1'b1)
`OF_GPIO(17, 3'd0, 1'b0, , 1'b1)
assign pad_adc_vinp = analog_io[16];
assign pad_adc_vinn = analog_io[17];
// analog_io[15] carries ADC_VREF. That is a supply net in the power intent (the
// macro's vref is a power pin), so the port is put on it in the power plan
// (connect_global_net -type net), not in RTL.

// TEST, SE and the SWD clock: inputs with the pad's weak pull-down, so that
// they are low when nothing drives them (the frame's pads have no default)
`OF_GPIO(18, 3'd2, 1'b0, pad_test_i,   1'b1)
`OF_GPIO(19, 3'd2, 1'b0, pad_se_i,     1'b1)
`OF_GPIO(20, 3'd2, 1'b0, pad_swdclk_i, 1'b1)
`OF_GPIO(21, 3'd5, pad_swdio_o, pad_swdio_i, pad_swdio_z)
`OF_GPIO(22, 3'd0, 1'b0, , 1'b1)
`OF_P1(23, 12)

// left edge
`OF_P0(24, 0)
`OF_P0(25, 1)
`OF_P0(26, 2)
`OF_P0(27, 3)
`OF_P0(28, 4)
`OF_P0(29, 5)
`OF_P0(30, 6)
`OF_P0(31, 7)
`OF_P0(32, 8)
`OF_P0(33, 9)
`OF_P0(34, 10)
`OF_P0(35, 11)
`OF_PT_IN(36, pad_gpio_port1_o[13], pad_gpio_port1_i[13], pad_gpio_port1_z[13])
`OF_PT_IN(37, pad_gpio_port1_o[14], pad_gpio_port1_i[14], pad_gpio_port1_z[14])

// bottom edge: the clock, the board's flash, the LED
`OF_GPIO(38, 3'd1, 1'b0, pad_clk_i, 1'b1)
// GPIO 39, the flash's CSB (P1[8], or the FTDI's CSB while FLASH_PROG is high).
// On a Caravel chip this pin is always driven. Here nothing would hold it while
// the chip is in reset or the program leaves P1[8] an input, and a flash whose
// select floats may be selected. So, like GPIO 0, this pad is not a
// CF_gpio_config: the bidirectional setting while something drives it, the
// input-with-pull-up setting while nothing does.
wire fl_csb_hiz = ~flash_prog & pad_gpio_port1_z[8];
assign pad_gpio_port1_i[8]  = gpio_in[39];
assign gpio_dm2[39]         = gpio_loopback_one[39];
assign gpio_dm1[39]         = gpio_loopback_one[39];
assign gpio_dm0[39]         = fl_csb_hiz;
assign gpio_out[39]         = fl_csb_hiz | (flash_prog ? ftdi_csb : pad_gpio_port1_o[8]);
assign gpio_oeb[39]         = gpio_loopback_zero[39];
assign gpio_inp_dis[39]     = gpio_loopback_zero[39];
assign gpio_analog_en[39]   = gpio_loopback_zero[39];
assign gpio_analog_sel[39]  = gpio_loopback_zero[39];
assign gpio_analog_pol[39]  = gpio_loopback_zero[39];
assign gpio_ib_mode_sel[39] = gpio_loopback_zero[39];
assign gpio_vtrip_sel[39]   = gpio_loopback_zero[39];
assign gpio_slow_sel[39]    = gpio_loopback_zero[39];
assign gpio_holdover[39]    = gpio_loopback_zero[39];
`OF_PT_OUT(40, pad_gpio_port1_o[9],  pad_gpio_port1_i[9],  pad_gpio_port1_z[9],  ftdi_sck)
`OF_PT_OUT(41, pad_gpio_port1_o[10], pad_gpio_port1_i[10], pad_gpio_port1_z[10], ftdi_sdi)
`OF_PT_IN(42, pad_gpio_port1_o[11], pad_gpio_port1_i[11], pad_gpio_port1_z[11])
`OF_P1(43, 15)

// reset from the frame (1.8 V domain, active low like NRST): the reset pad, and
// the frame's power-on reset so that the chip is in reset from power-up without
// anything driving the reset pad. The programming strap holds the chip in reset
// as well: its release starts the chip from the flash it has just had written.
assign pad_nrst_i = resetb_l & porb_l & ~flash_prog;

endmodule
