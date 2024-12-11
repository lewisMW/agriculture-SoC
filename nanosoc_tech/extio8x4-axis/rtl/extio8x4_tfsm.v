//-----------------------------------------------------------------------------
// 8-bit extio transfer over 4-bit data plane - target
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2024, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Initiator state machine and sequencer
//-----------------------------------------------------------------------------


module extio8x4_tfsm
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
wire rx0_axis_req;
wire rx1_axis_req;
wire tx0_axis_req;
wire tx1_axis_req;
// axis request acknowledge per channel, from FSM, 1-cycle pulse
wire rx0_axis_ack;
wire rx1_axis_ack;
wire tx0_axis_ack;
wire tx1_axis_ack;

reg req_rx0;
reg req_rx1;
reg req_tx0;
reg req_tx1;

// data ports
wire [7:0] tx_axis_rdata8;
wire [7:0] rx0_axis_wdata8;
wire [7:0] rx1_axis_wdata8;


wire ack_nxt = ioreq1_s ^ ioreq2_s;

reg ack;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    ack <= 1'b0;
  else
    ack <= ack_nxt;
end

wire ack_change = ack ^ ack_nxt;


// state[0] = ACK
// state[1] = CTL4_EN
// state[2] = RD4H_EN
// state[3] = RD4L_EN
// state[4] = STAT_EN
// state[5] = WD4H_EN
// state[6] = WD4L_EN
              

localparam STAT = 8'b0_001_000_0;
localparam RXC1 = 8'b0_000_001_1;
localparam RXDH = 8'b0_000_010_0;                     
localparam RXDL = 8'b0_000_100_1;                     
localparam RXDZ = 8'b0_000_000_0;                     
localparam STAZ = 8'b0_001_000_1;

localparam TXCZ = 8'b1_000_000_0;                     
localparam TXDH = 8'b1_010_000_1;                     
localparam TXDL = 8'b1_100_000_0;                     

reg  [7:0] fsm_state;
reg  [7:0] nxt_fsm_state;

// ifsm next-state seqeuncer                                             
always @(*)
  case (fsm_state)
  STAT: nxt_fsm_state = ( ioreq1_s) ? RXC1 : STAT;
  RXC1: nxt_fsm_state = (!ioreq2_s) ? RXC1 : (iodata4_i[0]) ? TXCZ : RXDH;
  RXDH: nxt_fsm_state = ( ioreq2_s) ? RXDH : RXDL;
  RXDL: nxt_fsm_state = (!ioreq2_s) ? RXDL : RXDZ;
  RXDZ: nxt_fsm_state = ( ioreq2_s) ? RXDZ : STAZ;
  STAZ: nxt_fsm_state = ( ioreq1_s) ? STAZ : STAT;
  TXCZ: nxt_fsm_state = ( ioreq2_s) ? TXCZ : TXDH;
  TXDH: nxt_fsm_state = (!ioreq2_s) ? TXDH : TXDL;
  TXDL: nxt_fsm_state = ( ioreq2_s) ? TXDL : STAZ;
  default:  nxt_fsm_state = STAT;
  endcase

// state update
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    fsm_state <= STAT;
  end else
    fsm_state <= nxt_fsm_state;
  end

assign ioack_o = fsm_state[0];
// 3 input sample enable
wire cmd_state = fsm_state[1];
wire rdh_state = fsm_state[2];
wire rdl_state = fsm_state[3];
// 3 output enable
wire fif_state = fsm_state[4];
wire wdh_state = fsm_state[5];
wire wdl_state = fsm_state[6];

// command resister
reg [3:0] cmd4;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    cmd4 <= 4'b1111; // invalid xfer pattern
  else if (cmd_state & ack_change)
    cmd4 <= iodata4_i[3:0];
end

wire [3:0] fifo_stat = ~{req_tx1, req_rx1, req_tx0, req_rx0 };
// IO Write Data
assign iodata4_o = ({4{fif_state}} & fifo_stat)
                 | ({4{wdh_state}} & ((cmd4[1]) ? rx1_axis_wdata8[7:4] : rx0_axis_wdata8[7:4]))
                 | ({4{wdl_state}} & ((cmd4[1]) ? rx1_axis_wdata8[3:0] : rx0_axis_wdata8[3:0]))
                 ;

assign iodata4_e = {4{|(fsm_state[6:4])}};
assign iodata4_t = {4{!iodata4_e}};

// and ack
assign rx0_axis_ack = !cmd4[1] &  cmd4[0] & wdl_state & ack_change;
assign rx1_axis_ack =  cmd4[1] &  cmd4[0] & wdl_state & ack_change;

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

assign tx_axis_rdata8 = {rd4_hi[3:0],iodata4_i[3:0]};

// then ack with 8-bit data to selected axis buffer
assign tx0_axis_ack = !cmd4[1] & !cmd4[0] & rdl_state & ack_change;
assign tx1_axis_ack =  cmd4[1] & !cmd4[0] & rdl_state & ack_change;

// stream buffers with valid qualifiers
reg [8:0] rx0_reg9;
reg [8:0] rx1_reg9;
reg [8:0] tx0_reg9;
reg [8:0] tx1_reg9;

// axis RX1 port interface
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx0_reg9 <= 9'b0_00000000;
  else begin
    if (!rx0_reg9[8] & axis_rx0_tvalid) rx0_reg9 <= {1'b1,axis_rx0_tdata8[7:0]};
    else if (rx0_reg9[8] & rx0_axis_ack) rx0_reg9[8] <= 1'b0;
    end
end
assign axis_rx0_tready = !rx0_reg9[8];
assign rx0_axis_wdata8 =  rx0_reg9[7:0];
assign rx0_axis_req    =  rx0_reg9[8] & !fsm_state[2] & !fsm_state[3];

// axis RX2 port interface
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx1_reg9 <= 9'b0_00000000;
  else begin
    if (!rx1_reg9[8] & axis_rx1_tvalid) rx1_reg9 <= {1'b1,axis_rx1_tdata8[7:0]};
    else if (rx1_reg9[8] & rx1_axis_ack)  rx1_reg9[8] <= 1'b0;
    end
end
assign axis_rx1_tready = !rx1_reg9[8];
assign rx1_axis_wdata8 =  rx1_reg9[7:0];
assign rx1_axis_req    =  rx1_reg9[8] & !fsm_state[2] & !fsm_state[3];

// axis TX1 port interface
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    tx0_reg9 <= 9'b0_00000000;
  else begin
    if (!tx0_reg9[8] & tx0_axis_ack) tx0_reg9 <= {1'b1,tx_axis_rdata8[7:0]};
    else if (tx0_reg9[8] & axis_tx0_tready)  tx0_reg9[8] <= 1'b0;
    end
end
assign axis_tx0_tvalid = tx0_reg9[8];
assign axis_tx0_tdata8[7:0] = tx0_reg9[7:0];
assign tx0_axis_req = !tx0_reg9[8];

// axis tx2 port interextio8x4_ifsmface
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    tx1_reg9 <= 9'b0_00000000;
  else begin
    if (!tx1_reg9[8] & tx1_axis_ack) tx1_reg9 <= {1'b1,tx_axis_rdata8[7:0]};
    else if (tx1_reg9[8] & axis_tx1_tready)  tx1_reg9[8] <= 1'b0;
    end
end
assign axis_tx1_tvalid = tx1_reg9[8];
assign axis_tx1_tdata8[7:0] = tx1_reg9[7:0];
assign tx1_axis_req = !tx1_reg9[8];


// request handshake
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    req_rx0 <= 1'b0; // avoid X propagation
  else if (rx0_axis_req & !req_rx0) // capture rx_req front edge
    req_rx0 <= 1'b1;
  else if (rx0_axis_ack & req_rx0)
    req_rx0 <= 1'b0;
end
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    req_rx1 <= 1'b0; // avoid X propagation
  else if (rx1_axis_req & !req_rx1) // capture rx_req front edge
    req_rx1 <= 1'b1;
  else if (rx1_axis_ack & req_rx1)
    req_rx1 <= 1'b0;
end

// request handshake
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    req_tx0 <= 1'b0; // avoid X propagation
  else if (tx0_axis_req & !req_tx0) // capture tx_req front edge
    req_tx0 <= 1'b1;
  else if (tx0_axis_ack & req_tx0)
    req_tx0 <= 1'b0;
end
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    req_tx1 <= 1'b0; // avoid X propagation
  else if (tx1_axis_req & !req_tx1) // capture tx_req front edge
    req_tx1 <= 1'b1;
  else if (tx1_axis_ack & req_tx1)
    req_tx1 <= 1'b0;
end

endmodule

/*
extio8x4_ifsm u_extio8x4_tfsm
  (
  .clk             ( clk             ),
  .resetn          ( resetn          ),
// RX 4-channel AXIS interface
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
