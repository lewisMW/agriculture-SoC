//-----------------------------------------------------------------------------
// FT1248 1-bit-data to 8-bit AXI-Stream IO
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2022-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : FT1248 1-bit data off-chip interface (emulate FT232H device)
//-----------------------------------------------------------------------------

 module nanosoc_ft1248x1_track
  (
  input  wire  ft_clk_i,         // SCLK
  input  wire  ft_ssn_i,         // SS_N
  input  wire  ft_miso_i,        // MISO
  input  wire  ft_miosio_i,       // MIOSIO tristate signal input

  input  wire  aclk,             // external primary clock
  input  wire  aresetn,          // external reset (active low)
  
  output wire  FTDI_CLK2UART_o, // Clock (baud rate)
  output wire  FTDI_OP2UART_o, // Received data to UART capture
  output wire  FTDI_IP2UART_o  // Transmitted data to UART capture
  );

//wire ft_clk;
wire ft_clk_rising;
wire ft_clk_falling;

wire ft_ssn;
wire ft_miosio_i_del;

SYNCHRONIZER_EDGES u_sync_ft_clk (
	.testmode_i(1'b0),
	.clk_i(aclk),
	.reset_n_i(aresetn),
	.asyn_i(ft_clk_i),
	.syn_o(),
	.syn_del_o(),
	.posedge_o(ft_clk_rising),
	.negedge_o(ft_clk_falling)
	);

SYNCHRONIZER_EDGES u_sync_ft_ssn (
	.testmode_i(1'b0),
	.clk_i(aclk),
	.reset_n_i(aresetn),
	.asyn_i(ft_ssn_i),
	.syn_o(ft_ssn),
	.syn_del_o(),
	.posedge_o( ),
	.negedge_o( )
	);

SYNCHRONIZER_EDGES u_sync_ft_din (
	.testmode_i(1'b0),
	.clk_i(aclk),
	.reset_n_i(aresetn),
	.asyn_i(ft_miosio_i),
	.syn_o( ),
	.syn_del_o(ft_miosio_i_del),
	.posedge_o( ),
	.negedge_o( )
	);

//----------------------------------------------
//-- FT1248 1-bit protocol State Machine
//----------------------------------------------

reg [4:0] ft_state; // 17-state for bit-serial
wire [4:0] ft_nextstate = ft_state + 5'b00001;

// advance state count on rising edge of ft_clk
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    ft_state <= 5'b11111;  
  else if (ft_ssn) // sync reset
    ft_state <= 5'b11111;
  else if (ft_clk_rising) // loop if multi-data
//    ft_state <= (ft_state == 5'b01111) ? 5'b01000 : ft_nextstate;
    ft_state <= ft_nextstate;

// 16: bus turnaround (or bit[5])
// 0 for CMD3
// 3 for CMD2
// 5 for CMD1
// 6 for CMD0
// 7 for cmd turnaround
// 8 for data bit0
// 9 for data bit1
// 10 for data bit2
// 11 for data bit3
// 12 for data bit4
// 13 for data bit5
// 14 for data bit6
// 15 for data bit7

// capture 7-bit CMD on falling edge of clock (mid-data)
reg [7:0] ft_cmd;
// - valid sample ready after 7th edge (ready RX or TX data phase functionality)
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    ft_cmd <= 8'b00000001;
  else if (ft_ssn) // sync reset
    ft_cmd <= 8'b00000001;
  else if (ft_clk_falling & !ft_state[3] & !ft_nextstate[3]) // on shift if CMD phase)
    ft_cmd <= {ft_cmd[6:0],ft_miosio_i};

wire ft_cmd_valid = ft_cmd[7];
wire ft_cmd_rxd =  ft_cmd[7] & !ft_cmd[6] & !ft_cmd[3] & !ft_cmd[1] &  ft_cmd[0];
wire ft_cmd_txd =  ft_cmd[7] & !ft_cmd[6] & !ft_cmd[3] & !ft_cmd[1] & !ft_cmd[0];

// serial data formatted with start bit for UART capture (on rising uart-clock)
assign   FTDI_CLK2UART_o = !ft_clk_i;
// suitable for CMSDK UART capture IO
// inject a start bit low else mark high
assign FTDI_OP2UART_o = (ft_cmd_txd & (ft_state[4:3]) == 2'b01) ? ft_miosio_i_del : !(ft_cmd_txd & (ft_state == 5'b00111)); 
assign FTDI_IP2UART_o = (ft_cmd_rxd & (ft_state[4:3]) == 2'b01) ? ft_miosio_i     : !(ft_cmd_rxd & (ft_state == 5'b00111));

endmodule
