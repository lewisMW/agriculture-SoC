//-----------------------------------------------------------------------------
// 4 channel 8-bit hostio transfer over 4-bit data bus
//
//  Controller Finite State Machine
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
// Abstract : Initiator (SOC) state machine and sequencer
//-----------------------------------------------------------------------------


module hostio4_controller_fsm
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
  input  wire       ioclken,
  input  wire [3:0] iodata4_i,
  input  wire [3:0] iodata4_s,
  output wire [3:0] iodata4_o,
  output wire [3:0] iodata4_e,
  output wire [3:0] iodata4_t,
  output wire       ioreq1_o,
  output wire       ioreq2_o,
  output wire       ioreq_e,
  output wire       ioreq_t,
  input  wire       ioack_s
  );


// probability functions for fair arbitration
wire [1:0] prob1in2; // in in two
wire [2:0] prob1in3; // in in three
wire [3:0] prob1in4; // one in four
// derived from a 12-stage counter, advanced per transfer
reg [3:0] seq_cnt12;

// fair priority arbiter function given up to four requests to arbitrate
function [3:0] FNpriority_sel;
input [3:0] req4;
input [1:0] prob1in2;
input [2:0] prob1in3;
input [3:0] prob1in4;
case (req4[3:0])
4'b0001: FNpriority_sel = 4'b0001; // chan 0
4'b0010: FNpriority_sel = 4'b0010; // chan 1
4'b0011: FNpriority_sel = (prob1in2[0]) ? 4'b0001 : 4'b0010; // chan 0/1
4'b0100: FNpriority_sel = 4'b0100; // chan 2
4'b0101: FNpriority_sel = (prob1in2[0]) ? 4'b0001 : 4'b0100; // chan 0/2
4'b0110: FNpriority_sel = (prob1in2[0]) ? 4'b0010 : 4'b0100; // chan 1/2
4'b0111: FNpriority_sel = (prob1in3[0]) ? 4'b0001 : (prob1in3[1]) ? 4'b0010: 4'b0100; // chan 0/1/2
4'b1000: FNpriority_sel = 4'b1000; // chan 3
4'b1001: FNpriority_sel = (prob1in2[0]) ? 4'b0001 : 4'b1000; // chan 0/3
4'b1010: FNpriority_sel = (prob1in2[0]) ? 4'b0010 : 4'b1000; // chan 1/3
4'b1011: FNpriority_sel = (prob1in3[0]) ? 4'b0001 : (prob1in3[1]) ? 4'b0010: 4'b1000;// chan 0/1/3
4'b1100: FNpriority_sel = (prob1in2[0]) ? 4'b0100 : 4'b1000; // chan 2/3
4'b1101: FNpriority_sel = (prob1in3[0]) ? 4'b0001 : (prob1in3[1]) ? 4'b0100: 4'b1000; // chan 0/2/3
4'b1110: FNpriority_sel = (prob1in3[0]) ? 4'b0010 : (prob1in3[1]) ? 4'b0100: 4'b1000; // chan 1/2/3
4'b1111: FNpriority_sel = (prob1in4[0]) ? 4'b0001 : (prob1in4[1]) ? 4'b0010 : (prob1in4[2]) ? 4'b0100: 4'b1000; // chan 0/1/2/3
default: FNpriority_sel = 4'b0000; // (no requests)
endcase
endfunction

// edge detecter on (synchronised IOACK)
reg ack_r;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    ack_r <= 1'b0;
  else if (ioclken)
    ack_r <= ioack_s;
end
wire ack_change = ack_r ^ ioack_s;

// *************************************************************
//
// XIO 4-channel, 8-bit virtual channel protocol
//  Initiator Finte State Machine
//
//  ************************************************************

// FSM states defined from the SOC Initiator perspective
// Transmit commands and write data to target/Host
// Receive status and read data from target/Host
// and explciticly manage tri-state HIZ turnaround slots

// state[0] = ioreq1
// state[1] = ioreq2
// state[2] = CTL4_EN
// state[3] = WD4H_EN
// state[4] = WD4L_EN
// state[5] = WDONE
// state[6] = RD4H_EN
// state[7] = RD4L_EN
// state[8] = RDONE
// state[9] = TX
//state[10] = ACTIVE/REQ-enable

localparam OFFZ = 11'b00_000_0000_00; // off/deselected from reset
localparam STAZ = 11'b10_000_0000_00; // HiZ status phase
localparam TXC1 = 11'b10_000_0000_01; // Initiate command nibble send
localparam TXC2 = 11'b10_000_0001_11; // complete command nibble send
localparam TXDH = 11'b10_000_0010_01; // send data hi-nibble
localparam TXDL = 11'b10_000_0100_11; // send data lo-nibble
localparam TXDZ = 11'b10_000_1000_01; // HiZ after send data
localparam RXDH = 11'b11_001_0000_01; // request data hi-nibble
localparam RXDL = 11'b11_010_0000_11; // request data lo-nibble
localparam RXDZ = 11'b11_100_0000_01; // read data done

reg  [10:0] fsm_state;
reg  [10:0] nxt_fsm_state;

reg [3:0] cmd4;

// Commands supported are:
// xx00 TX0 -> Host RX0
// xx01 RX0 <- Hoxt TX0
// xx10 TX1 -> Host RX1
// xx11 RX1 <- Host TX1
// CMD4[3:2] == 00 for byte, reserved for 01,10,11
//  CMD4[0] = read
//  CMD4[1] = chan1
wire start_xfer;

// ifsm next-state seqeuncer                                             
always @(*)
  case (fsm_state)
  OFFZ: nxt_fsm_state = ( ioack_s) ? OFFZ : STAZ; // hold idle if ACK high from reset
  STAZ: nxt_fsm_state = (!ioack_s & (start_xfer)) ? TXC1 : STAZ;
  TXC1: nxt_fsm_state = ( ioack_s) ? TXC2 : TXC1;
  TXC2: nxt_fsm_state = (!ioack_s) ? ((cmd4[0]) ? RXDH : TXDH) : TXC2;
  TXDH: nxt_fsm_state = ( ioack_s) ? TXDL : TXDH;
  TXDL: nxt_fsm_state = (!ioack_s) ? TXDZ : TXDL;
  TXDZ: nxt_fsm_state = ( ioack_s) ? STAZ : TXDZ;
  RXDH: nxt_fsm_state = ( ioack_s) ? RXDL : RXDH;
  RXDL: nxt_fsm_state = (!ioack_s) ? RXDZ : RXDL;
  RXDZ: nxt_fsm_state = ( ioack_s) ? STAZ : RXDZ;
  default:  nxt_fsm_state = STAZ;
  endcase

// state update
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    fsm_state <= OFFZ;
  end else if (ioclken) begin
    fsm_state <= nxt_fsm_state;
  end
end

// (synchrnoized) status valid to sample when RQ1 is low
wire status_valid = !fsm_state[0];

// fsm decodes:
// request signalling
assign ioreq1_o  = fsm_state[0];
assign ioreq2_o  = fsm_state[1];
// dataout mux
wire cmd_state = fsm_state[2];
wire wdh_state = fsm_state[3];
wire wdl_state = fsm_state[4];
wire wdone     = fsm_state[5];
// datain sel
wire rdh_state = fsm_state[6];
wire rdl_state = fsm_state[7];
wire rdone     = fsm_state[8];

assign ioreq_e = fsm_state[10];
assign ioreq_t =!fsm_state[10];

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
// AXI stream transfers pending
reg pending_rx0;
reg pending_rx1;
reg pending_tx0;
reg pending_tx1;

reg [7:0] wdata8;
reg [3:0] rd4_hi;
reg [3:0] rd4_lo;

// transfer data
wire [7:0] tx_xfer_rdata8;
wire [7:0] rx0_xfer_wdata8;
wire [7:0] rx1_xfer_wdata8;

// IO Write Data
assign iodata4_o = ({4{cmd_state}} & cmd4)
                 | ({4{wdh_state}} & wdata8[7:4])
                 | ({4{wdl_state}} & wdata8[3:0])
                 | ({4{wdone}} & wdata8[3:0])
                 ;

assign iodata4_e = {4{|(fsm_state[4:2])}};
assign iodata4_t = ~iodata4_e;


hostio4_controller_axis_txport # (
  .WIDTH(8)
  )
  u_hostio4_controller_axis_txport0
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

hostio4_controller_axis_txport # (
  .WIDTH(8)
  )
  u_hostio4_controller_axis_txport1
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

hostio4_controller_axis_rxport # (
  .WIDTH(8)
  )
  u_hostio4_controller_axis_rxport0
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

hostio4_controller_axis_rxport # (
  .WIDTH(8)
  )
  u_hostio4_controller_axis_rxport1
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



// virtual channel requests, only valid during status phase
//  *Synchronized* channel ready & request to transfer
wire vtx0_rdy = status_valid & iodata4_s[0] & pending_tx0;
wire vrx0_rdy = status_valid & iodata4_s[1] & pending_rx0;
wire vtx1_rdy = status_valid & iodata4_s[2] & pending_tx1;
wire vrx1_rdy = status_valid & iodata4_s[3] & pending_rx1;

// up to 4 active requests on all four channels
wire [3:0] active_req4 = {vtx1_rdy, vrx1_rdy, vtx0_rdy, vrx0_rdy};
wire [3:0] active_pri4; // the priority channels that need servicing
wire [3:0] active_sel4; // the priority selected channel

// any active request initiated a command request
wire cmd_req = (vtx1_rdy | vrx1_rdy | vtx0_rdy | vrx0_rdy);
assign start_xfer = (cmd_req & !ioack_s);

// sequence counter for rotating arbitration priority
// 12 cycle sequencer counter
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    seq_cnt12 <= 4'b0000;
  else if (ioclken)
    if (start_xfer) seq_cnt12 <= (seq_cnt12 >= 11) ? 4'b0000 : (seq_cnt12+4'b0001);
end

// proabability distributions derived
assign prob1in2[0] = !seq_cnt12[0];
assign prob1in2[1] =  seq_cnt12[0];
assign prob1in3[0] = (seq_cnt12 == 0) | (seq_cnt12 == 3) | (seq_cnt12 == 6) | (seq_cnt12 == 9);
assign prob1in3[1] = (seq_cnt12 == 1) | (seq_cnt12 == 4) | (seq_cnt12 == 7) | (seq_cnt12 == 10);
assign prob1in3[2] = (seq_cnt12 == 2) | (seq_cnt12 == 5) | (seq_cnt12 == 8) | (seq_cnt12 == 11);
assign prob1in4[0] = !seq_cnt12[1] & !seq_cnt12[0];
assign prob1in4[1] = !seq_cnt12[1] &  seq_cnt12[0];
assign prob1in4[2] =  seq_cnt12[1] & !seq_cnt12[0];
assign prob1in4[3] =  seq_cnt12[1] &  seq_cnt12[0];

wire [3:0] cmd4_nxt;

// four-bit request history per channel
reg [3:0] hist4_rq0;
reg [3:0] hist4_rq1;
reg [3:0] hist4_rq2;
reg [3:0] hist4_rq3;

wire [3:0] pending_req4; // active but not acknowledged
assign pending_req4 = active_req4 & ~active_sel4;

// build histogram of last 3 requests not yet granted
// start as zero and push until serviced
// 3-bit shift registers
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    hist4_rq0 <= 4'b0000; // clear history
    hist4_rq1 <= 4'b0000;
    hist4_rq2 <= 4'b0000;
    hist4_rq3 <= 4'b0000;
    end
  else if ((ioclken) & start_xfer) begin
    hist4_rq0 <= (pending_req4[0]) ? {hist4_rq0[2:0],1'b1} : 4'b0000; // req  history
    hist4_rq1 <= (pending_req4[1]) ? {hist4_rq1[2:0],1'b1} : 4'b0000;
    hist4_rq2 <= (pending_req4[2]) ? {hist4_rq2[2:0],1'b1} : 4'b0000;
    hist4_rq3 <= (pending_req4[3]) ? {hist4_rq3[2:0],1'b1} : 4'b0000;
    end
end

// bitwise OR history bits to determine max no of requests in contention
wire [3:0] max_pending = hist4_rq0 | hist4_rq1 | hist4_rq2 | hist4_rq3;

// priority to longest waiting requests
assign active_pri4[3:0]
          = (max_pending[3]) ? {hist4_rq3[3],hist4_rq2[3],hist4_rq1[3],hist4_rq0[3]}
          : (max_pending[2]) ? {hist4_rq3[2],hist4_rq2[2],hist4_rq1[2],hist4_rq0[2]}
          : (max_pending[1]) ? {hist4_rq3[1],hist4_rq2[1],hist4_rq1[1],hist4_rq0[1]}
          : (max_pending[0]) ? {hist4_rq3[0],hist4_rq2[0],hist4_rq1[0],hist4_rq0[0]}
          : active_req4
          ;

assign active_sel4[3:0] = FNpriority_sel(active_pri4,prob1in2,prob1in3,prob1in4);

// resolve the command to issue depending on channel arbitration
// decoded command bits [1:0]
assign cmd4_nxt[0] =  active_sel4[1] | active_sel4[3]; // read command (else write)
assign cmd4_nxt[1] =  active_sel4[2] | active_sel4[3]; // channel 1 (else channel 0)
assign cmd4_nxt[3:2] = 2'b00; // fixed 8-bit transfer supported only

// command resister
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    cmd4 <= 4'b0000; // invalid xfer pattern
  else if ((ioclken) & start_xfer)
    cmd4 <= cmd4_nxt;
end

// request handshake
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    pending_rx0 <= 1'b0; // avoid X propagation
  else if (rx0_xfer_req & !pending_rx0) // capture rx_req front edge
    pending_rx0 <= 1'b1;
  else if (rx0_xfer_ack & pending_rx0)
    pending_rx0 <= 1'b0;
end
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    pending_rx1 <= 1'b0; // avoid X propagation
  else if (rx1_xfer_req & !pending_rx1) // capture rx_req front edge
    pending_rx1 <= 1'b1;
  else if (rx1_xfer_ack & pending_rx1)
    pending_rx1 <= 1'b0;
end

// and ack
assign rx0_xfer_ack = (ioclken) & !cmd4[1] & !cmd4[0] & wdone & ack_change;
assign rx1_xfer_ack = (ioclken) &  cmd4[1] & !cmd4[0] & wdone & ack_change;

// request handshake
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    pending_tx0 <= 1'b0; // avoid X propagation
  else if (tx0_xfer_req & !pending_tx0) // capture tx_req front edge
    pending_tx0 <= 1'b1;
  else if (tx0_xfer_ack & pending_tx0)
    pending_tx0 <= 1'b0;
end

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    pending_tx1 <= 1'b0; // avoid X propagation
  else if (tx1_xfer_req & !pending_tx1) // capture tx_req front edge
    pending_tx1 <= 1'b1;
  else if (tx1_xfer_ack & pending_tx1)
    pending_tx1 <= 1'b0;
end

// write data resister - for the committed channel
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    wdata8 <= 8'b00000000; // avoid X propagation
  else if ((ioclken) & start_xfer & !cmd4_nxt[0]) // capture selected wdata
    wdata8 <= (cmd4_nxt[1]) ? rx1_xfer_wdata8[7:0] : rx0_xfer_wdata8[7:0];
end

// IO Read data
// first high nibble read data - async-data safe by protocol
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rd4_hi <= 4'b0000; // initialize
  else if ((ioclken) & rdh_state & ack_change)
    rd4_hi <= iodata4_i[3:0];
end

// second low nibble read data - async-data safe by protocol
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rd4_lo <= 4'b0000; // initialize
  else if ((ioclken) & rdl_state & ack_change)
    rd4_lo <= iodata4_i[3:0];
end

assign tx_xfer_rdata8 = {rd4_hi[3:0],rd4_lo[3:0]};

// then ack with 8-bit data to selected axis buffer
assign tx0_xfer_ack = (ioclken) & !cmd4[1] &  cmd4[0] & rdone & ack_change;
assign tx1_xfer_ack = (ioclken) &  cmd4[1] &  cmd4[0] & rdone & ack_change;
           
endmodule

/*
extio8x4_fsm u_extio8x4_fsm
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
  .ioclken         ( 1'b1            ) ,
  .iodata4_i       ( iodata4_i       ),
  .iodata4_s       ( iodata4_s       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_o        ),
  .ioreq2_o        ( ioreq2_o        ),
  .ioack_s         ( ioack_s         )
  );

*/
