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

 module f232h_ft1248_stream #
 (
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Stream Bus Interface rxd8
    parameter integer C_rxd8_TDATA_WIDTH    = 8,

    // Parameters of Axi Stream Bus Interface txd8
    parameter integer C_txd8_TDATA_WIDTH    = 8
 )
  (
  input  wire  ft_clk_i,         // SCLK
  input  wire  ft_ssn_i,         // SS_N
  output wire  ft_miso_o,        // MISO
//  inout  wire  ft_miosio_io,   // MIOSIO tristate output control
  input  wire ft_miosio_i,
  output wire ft_miosio_o,
  output wire ft_miosio_z,

  input  wire  aclk,             // external primary clock
  input  wire  aresetn,          // external reset (active low)
  
  // Ports of Axi stream Bus Interface TXD
  output wire  txd_tvalid_o,
  output wire [7 : 0] txd_tdata8_o,
  input  wire  txd_tready_i,

  // Ports of Axi stream Bus Interface RXD
  output wire  rxd_tready_o,
  input  wire [7 : 0] rxd_tdata8_i,
  input  wire  rxd_tvalid_i

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

// tristate enable for miosio (deselected status or serialized data for read command)
wire   ft_miosio_e = ft_ssn_i | (ft_cmd_rxd & !ft_state[4] & ft_state[3]);
assign ft_miosio_z = !ft_miosio_e;

// capture (ft_cmd_txd) serial data out on falling edge of clock
// bit [0] indicated byte valid
reg [7:0] rxd_sr;
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    rxd_sr <= 8'b00000000;
  else if (ft_ssn) // sync reset
    rxd_sr <= 8'b00000000;
  else if (ft_clk_falling & ft_cmd_txd & (ft_state[4:3] == 2'b01))  //serial shift
    rxd_sr <= {ft_miosio_i_del, rxd_sr[7:1]};
   
// AXI STREAM handshake interfaces
// TX stream delivers valid FT1248 read data transfer
// 8-bit write port with extra top-bit used as valid qualifer
reg [8:0] txstream;
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    txstream <= 9'b000000000;
  else if (txstream[8] & txd_tready_i) // priority clear stream data valid when accepted
    txstream[8] <= 1'b0;
  else if (ft_clk_falling & ft_cmd_txd & (ft_state==5'b01111))  //load as last shift arrives
    txstream[8:0] <= {1'b1, ft_miosio_i_del, rxd_sr[7:1]};

assign txd_tvalid_o = txstream[8];
assign txd_tdata8_o = txstream[7:0];


// AXI STREAM handshake interfaces
// RX stream accepts 8-bit data to transfer over FT1248 channel
// 8-bit write port with extra top-bit used as valid qualifer

/*
reg [8:0] rxstream;
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    rxstream <= 9'b000000000;
  else if (!rxstream[8] & rxd_tvalid_i) // if empty can accept valid RX stream data
    rxstream[8:0] <= {1'b1,rxd_tdata8_i};
  else if (rxstream[8] & ft_clk_rising & ft_cmd_rxd &  (ft_state==5'b01111)) // hold until final shift completion
    rxstream[8] <= 1'b0;
assign rxd_tready_o = !rxstream[8]; // ready until loaded
*/

// shift TXD on rising edge of clock
reg [8:0] txd_sr;
// rewrite for clocked
always @(posedge aclk or negedge aresetn)
  if (!aresetn)
    txd_sr <= 8'b00000000;
  else if (ft_ssn) // sync reset
    txd_sr <= 8'b00000000;
  else if (ft_clk_falling & ft_cmd_rxd &  rxd_tvalid_i & (ft_state == 5'b00111))
    txd_sr <=  rxd_tdata8_i;
  else if (ft_clk_rising & ft_cmd_rxd & (ft_state[4:3] == 2'b01))  //serial shift
    txd_sr <= {1'b0,txd_sr[7:1]};

assign  rxd_tready_o = (ft_clk_rising & ft_cmd_rxd & (ft_state==5'b01110)); // hold until final shift

//FT1248 FIFO status signals

// ft_miso_o reflects TXF when deselected
assign ft_miosio_o =  (ft_ssn_i) ? txstream[8] : txd_sr[0];

// ft_miso_o reflects RXE when deselected
//assign ft_miso_o = (ft_ssn_i) ? rxstream[8] : (ft_state == 5'b00111);
assign ft_miso_o = (ft_ssn_i) ? !rxd_tvalid_i : ((ft_state == 5'b00111) & ((ft_cmd_txd) ? txstream[8]: !rxd_tvalid_i));

endmodule
