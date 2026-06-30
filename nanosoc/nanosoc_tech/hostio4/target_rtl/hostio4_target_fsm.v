//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  Target Finite State Machine
//
// A joint work commissioned on behalf of SoC Labs,
// under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2024-6, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Abstract : Target (HOST)  state machine and sequencer
//-----------------------------------------------------------------------------

module hostio4_target_fsm
  (
  input  wire       clk,
  input  wire       resetn,
// RX 4-channel AXIS interface
  output wire       axis_rx0_tready, 
  input  wire       axis_rx0_tvalid,
  input  wire [7:0] axis_rx0_tdata8,
  output wire       axis_rx1_tready, 
  input  wire       axis_rx1_tvalid,
  input  wire [7:0] axis_rx1_tdata8,
  input  wire       axis_tx0_tready, 
  output wire       axis_tx0_tvalid,
  output wire [7:0] axis_tx0_tdata8,
  input  wire       axis_tx1_tready, 
  output wire       axis_tx1_tvalid,
  output wire [7:0] axis_tx1_tdata8,
// external io interface
  input  wire [3:0] iodata4_i,
  output wire [3:0] iodata4_o,
  output wire [3:0] iodata4_e,
  output wire [3:0] iodata4_t,
  input  wire       ioreq1_s,
  input  wire       ioreq2_s,
  output wire       ioack_o
  );


// axis request per channel to FSM, hold until ack
wire rx0_xfer_req;
wire rx1_xfer_req;
wire tx0_xfer_req;
wire tx1_xfer_req;
// axis request acknowledge per channel, from FSM, 1-cycle pulse
wire rx0_xfer_ack;
wire rx1_xfer_ack;
wire tx0_xfer_ack;
wire tx1_xfer_ack;

reg rx0_xfer_pending;
reg rx1_xfer_pending;
reg tx0_xfer_pending;
reg tx1_xfer_pending;

// data ports
wire [7:0] tx_xfer_rdata8;
wire [7:0] rx0_xfer_wdata8;
wire [7:0] rx1_xfer_wdata8;

// ack edge detect
wire ack_nxt = ioreq1_s ^ ioreq2_s;
reg ack;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    ack <= 1'b0;
  else
    ack <= ack_nxt;
end
// ack change pulse on edge
wire ack_change = ack ^ ack_nxt;


// state[0] = ACK
// state[1] = CTL4_EN
// state[2] = RD4H_EN
// state[3] = RD4L_EN
// state[4] = STAT_EN
// state[5] = WD4H_EN
// state[6] = WD4L_EN
              
// FSM states defined from the target/Host perspective
// Transmit commands and write data to target/Host
// Receive status and read data from target/Host
// and explciticly manage tri-state HIZ turnaround slots


localparam TXST = 8'b0_001_000_0;
localparam RXC1 = 8'b0_000_001_1;
localparam RXDH = 8'b0_000_010_0;                     
localparam RXDL = 8'b0_000_100_1;                     
localparam RXDZ = 8'b0_000_000_0;                     
localparam TXSZ = 8'b0_001_000_1;

localparam TXCZ = 8'b1_000_000_0;                     
localparam TXDH = 8'b1_010_000_1;                     
localparam TXDL = 8'b1_100_000_0;                     

reg  [7:0] fsm_state;
reg  [7:0] nxt_fsm_state;

// ifsm next-state seqeuncer                                             
always @(*)
  case (fsm_state)
  TXST: nxt_fsm_state = ( ioreq1_s) ? RXC1 : TXST;
  RXC1: nxt_fsm_state = (!ioreq2_s) ? RXC1 : (iodata4_i[0]) ? TXCZ : RXDH;
  RXDH: nxt_fsm_state = ( ioreq2_s) ? RXDH : RXDL;
  RXDL: nxt_fsm_state = (!ioreq2_s) ? RXDL : RXDZ;
  RXDZ: nxt_fsm_state = ( ioreq2_s) ? RXDZ : TXSZ;
  TXCZ: nxt_fsm_state = ( ioreq2_s) ? TXCZ : TXDH;
  TXDH: nxt_fsm_state = (!ioreq2_s) ? TXDH : TXDL;
  TXDL: nxt_fsm_state = ( ioreq2_s) ? TXDL : TXSZ;
  TXSZ: nxt_fsm_state = ( ioreq1_s) ? TXSZ : TXST;
  default:  nxt_fsm_state = TXST;
  endcase

// state update
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    fsm_state <= TXSZ;
  end else
    fsm_state <= nxt_fsm_state;
  end

assign ioack_o = fsm_state[0]; // signal ACK handshake toggle
// 3 input sample enable
wire cmd_state = fsm_state[1]; // Read Command nibble
wire rdh_state = fsm_state[2]; // Read Data hi-nibble
wire rdl_state = fsm_state[3]; // Read Data lo-nibble
// 3 output enable
wire vcs_state = fsm_state[4]; // Virtual Channel Status
wire wdh_state = fsm_state[5]; // Write Data hi-nibble
wire wdl_state = fsm_state[6]; // Write Data lo-nibble

wire rdsafe_state = !fsm_state[2] & !fsm_state[3];

// command resister
reg [3:0] cmd4;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    cmd4 <= 4'b1111; // invalid xfer pattern
  else if (cmd_state & ack_change)
    cmd4 <= iodata4_i[3:0];
end

wire [3:0] vchan4_status = {tx1_xfer_pending, rx1_xfer_pending, tx0_xfer_pending, rx0_xfer_pending };
// IO Write Data
assign iodata4_o = ({4{vcs_state}} & vchan4_status)
                 | ({4{wdh_state}} & ((cmd4[1]) ? rx1_xfer_wdata8[7:4] : rx0_xfer_wdata8[7:4]))
                 | ({4{wdl_state}} & ((cmd4[1]) ? rx1_xfer_wdata8[3:0] : rx0_xfer_wdata8[3:0]))
                 ;

assign iodata4_e =  {4{|(fsm_state[6:4])}}; // active-high pad enable
assign iodata4_t = ~{4{|(fsm_state[6:4])}}; // active-low pad enable

// decode RX ack (of channel write command data, final nibble transfer)
assign rx0_xfer_ack = !cmd4[1] &  cmd4[0] & wdl_state & ack_change;
assign rx1_xfer_ack =  cmd4[1] &  cmd4[0] & wdl_state & ack_change;

// IO Read data
// first register high nibble read data
reg [3:0] rd4_hi;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rd4_hi <= 4'b0000; // initialize
  else if (rdh_state & ack_change)
    rd4_hi <= iodata4_i[3:0];
end

assign tx_xfer_rdata8 = {rd4_hi[3:0],iodata4_i[3:0]};

// decode TX ack (of channel read command data, final nibble transfer)
assign tx0_xfer_ack = !cmd4[1] & !cmd4[0] & rdl_state & ack_change;
assign tx1_xfer_ack =  cmd4[1] & !cmd4[0] & rdl_state & ack_change;

// channel transfer pending flags for channel status flags (inverted)

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx0_xfer_pending <= 1'b0; // avoid X propagation
  else if (rx0_xfer_req & rdsafe_state & !rx0_xfer_pending) // capture rx_req front edge
    rx0_xfer_pending <= 1'b1;
  else if (rx0_xfer_ack & rx0_xfer_pending)
    rx0_xfer_pending <= 1'b0;
end

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx1_xfer_pending <= 1'b0; // avoid X propagation
  else if (rx1_xfer_req & rdsafe_state & !rx1_xfer_pending) // capture rx_req front edge
    rx1_xfer_pending <= 1'b1;
  else if (rx1_xfer_ack & rx1_xfer_pending)
    rx1_xfer_pending <= 1'b0;
end

// request handshake
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    tx0_xfer_pending <= 1'b0; // avoid X propagation
  else if (tx0_xfer_req & !tx0_xfer_pending) // capture tx_req front edge
    tx0_xfer_pending <= 1'b1;
  else if (tx0_xfer_ack & tx0_xfer_pending)
    tx0_xfer_pending <= 1'b0;
end

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    tx1_xfer_pending <= 1'b0; // avoid X propagation
  else if (tx1_xfer_req & !tx1_xfer_pending) // capture tx_req front edge
    tx1_xfer_pending <= 1'b1;
  else if (tx1_xfer_ack & tx1_xfer_pending)
    tx1_xfer_pending <= 1'b0;
end

// AXI-Stream port buffers

hostio4_target_axis_rxport # (
  .WIDTH(8)
  )
  u_hostio4_target_axis_rxport0
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// 8-bit req/ack
  .rx_req          ( rx0_xfer_req    ),
  .rx_ack          ( rx0_xfer_ack    ),
  .rx_data         ( rx0_xfer_wdata8 ),
// 8-bit AXI Stream port
  .axis_rx_tready  ( axis_rx0_tready ),
  .axis_rx_tvalid  ( axis_rx0_tvalid ),
  .axis_rx_tdata   ( axis_rx0_tdata8 )
  );

hostio4_target_axis_rxport # (
  .WIDTH(8)
  )
  u_hostio4_target_axis_rxport1
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// 8-bit req/ack
  .rx_req          ( rx1_xfer_req    ),
  .rx_ack          ( rx1_xfer_ack    ),
  .rx_data         ( rx1_xfer_wdata8 ),
// 8-bit AXI Stream port
  .axis_rx_tready  ( axis_rx1_tready ),
  .axis_rx_tvalid  ( axis_rx1_tvalid ),
  .axis_rx_tdata   ( axis_rx1_tdata8 )
  );

hostio4_target_axis_txport # (
  .WIDTH(8)
  )
  u_hostio4_target_axis_txport0
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// 8-bit req/ack
  .tx_req          ( tx0_xfer_req    ),
  .tx_ack          ( tx0_xfer_ack    ),
  .tx_data         ( tx_xfer_rdata8  ),
// 8-bit AXI Stream port
  .axis_tx_tready  ( axis_tx0_tready ),
  .axis_tx_tvalid  ( axis_tx0_tvalid ),
  .axis_tx_tdata   ( axis_tx0_tdata8 )
  );

hostio4_target_axis_txport # (
  .WIDTH(8)
  )
  u_hostio4_target_axis_txport1
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// 8-bit req/ack
  .tx_req          ( tx1_xfer_req    ),
  .tx_ack          ( tx1_xfer_ack    ),
  .tx_data         ( tx_xfer_rdata8  ),
// 8-bit AXI Stream port
  .axis_tx_tready  ( axis_tx1_tready ),
  .axis_tx_tvalid  ( axis_tx1_tvalid ),
  .axis_tx_tdata   ( axis_tx1_tdata8 )
  );

endmodule

/*
hostio4_target_fsm u_hostio4_target_fsm
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// Target 4-channel AXIS interface
  .axis_rx0_tready ( axis_rx0_tready ), 
  .axis_rx0_tvalid ( axis_rx0_tvalid ),
  .axis_rx0_tdata8 ( axis_rx0_tdata8 ),
  .axis_rx1_tready ( axis_rx1_tready ), 
  .axis_rx1_tvalid ( axis_rx1_tvalid ),
  .axis_rx1_tdata8 ( axis_rx1_tdata8 ),
  .axis_tx0_tready ( axis_tx0_tready ), 
  .axis_tx0_tvalid ( axis_tx0_tvalid ),
  .axis_tx0_tdata8 ( axis_tx0_tdata8 ),
  .axis_tx1_tready ( axis_tx1_tready ), 
  .axis_tx1_tvalid ( axis_tx1_tvalid ),
  .axis_tx1_tdata8 ( axis_tx1_tdata8 ),
// external io interface
  .iodata4_i       ( iodata4_i       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_s        ( ioreq1_s        ),
  .ioreq2_s        ( ioreq2_s        ),
  .ioack_o         ( ioack_o         )
  );

*/
