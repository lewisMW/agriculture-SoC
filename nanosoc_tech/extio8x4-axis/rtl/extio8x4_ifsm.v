//-----------------------------------------------------------------------------
// 8-bit extio transfer over 4-bit data plane - initiator
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


module extio8x4_ifsm
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
  input  wire [3:0] iodata4_s,
  output wire [3:0] iodata4_o,
  output wire [3:0] iodata4_e,
  output wire [3:0] iodata4_t,
  output wire       ioreq1_o,
  output wire       ioreq2_o,
  input  wire       ioack_s
  );

// Fair priority sequencer
// return next 12 transactions - to support 1,2,3 and 4 requests 
function [23:0] FNpriority_seq12x2;
input [3:0] req4;
case (req4[3:0])
4'b0001: FNpriority_seq12x2 = 24'b00_00_00_00_00_00_00_00_00_00_00_00; // chan 0
4'b0010: FNpriority_seq12x2 = 24'b01_01_01_01_01_01_01_01_01_01_01_01; // chan 1
4'b0011: FNpriority_seq12x2 = 24'b01_00_01_00_01_00_01_00_01_00_01_00; // chan 0/1
4'b0100: FNpriority_seq12x2 = 24'b10_10_10_10_10_10_10_10_10_10_10_10; // chan 2
4'b0101: FNpriority_seq12x2 = 24'b10_00_10_00_10_00_10_00_10_00_10_00; // chan 0/2
4'b0110: FNpriority_seq12x2 = 24'b10_01_10_01_10_01_10_01_10_01_10_01; // chan 1/2
4'b0111: FNpriority_seq12x2 = 24'b10_01_00_10_01_00_10_01_00_10_01_00; // chan 0/1/2
4'b1000: FNpriority_seq12x2 = 24'b11_11_11_11_11_11_11_11_11_11_11_11; // chan 3
4'b1001: FNpriority_seq12x2 = 24'b11_00_11_00_11_00_11_00_11_00_11_00; // chan 0/3
4'b1010: FNpriority_seq12x2 = 24'b11_01_11_01_11_01_11_01_11_01_11_01; // chan 1/3
4'b1011: FNpriority_seq12x2 = 24'b11_01_00_11_01_00_11_01_00_11_01_00; // chan 0/1/3
4'b1100: FNpriority_seq12x2 = 24'b11_10_11_10_11_10_11_10_11_10_11_10; // chan 2/3
4'b1101: FNpriority_seq12x2 = 24'b11_10_00_11_10_00_11_10_00_11_10_00; // chan 0/2/3
4'b1110: FNpriority_seq12x2 = 24'b11_10_01_11_10_01_11_10_01_11_10_01; // chan 1/2/3
4'b1111: FNpriority_seq12x2 = 24'b11_10_01_00_11_10_01_00_11_10_01_00; // chan 0/1/2/3
default: FNpriority_seq12x2 = 24'b0; // (no requests)
endcase
endfunction

function [1:0] FNmap_patt2code2;
input [23:0] priority_seq12x2;
input [3:0] seq12_no;
case (seq12_no[3:0])
4'b0000: FNmap_patt2code2 = priority_seq12x2[ 1: 0];
4'b0001: FNmap_patt2code2 = priority_seq12x2[ 3: 2];
4'b0010: FNmap_patt2code2 = priority_seq12x2[ 5: 4];
4'b0011: FNmap_patt2code2 = priority_seq12x2[ 7: 6];
4'b0100: FNmap_patt2code2 = priority_seq12x2[ 9: 8];
4'b0101: FNmap_patt2code2 = priority_seq12x2[11:10];
4'b0110: FNmap_patt2code2 = priority_seq12x2[13:12];
4'b0111: FNmap_patt2code2 = priority_seq12x2[15:14];
4'b1000: FNmap_patt2code2 = priority_seq12x2[17:16];
4'b1001: FNmap_patt2code2 = priority_seq12x2[19:18];
4'b1010: FNmap_patt2code2 = priority_seq12x2[21:20];
4'b1011: FNmap_patt2code2 = priority_seq12x2[23:22];
default: FNmap_patt2code2 = 2'b00; // (illegal seq no)
endcase
endfunction


reg ack;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    ack <= 1'b0;
  else
    ack <= ioack_s;
end

wire ack_change = ack ^ ioack_s;


// state[0] = ioreq1
// state[1] = ioreq2
// state[2] = CTL4_EN
// state[3] = WD4H_EN
// state[4] = WD4L_EN
// state[5] = WDONE
// state[6] = RD4H_EN
// state[7] = RD4L_EN
// state[8] = RXDONE
// state[9] = TX

localparam STAT = 10'b0_000_0000_00;
localparam RXC1 = 10'b0_000_0000_01;
localparam RXC2 = 10'b0_000_0001_11;                     
localparam RXDH = 10'b0_001_0000_01;                     
localparam RXDL = 10'b0_010_0000_11;                     
localparam RXDZ = 10'b0_100_0000_01;                     
localparam TXDH = 10'b1_000_0010_01;                     
localparam TXDL = 10'b1_000_0100_11;                     
localparam TXDZ = 10'b1_000_1000_01;                     

reg  [9:0] fsm_state;
reg  [9:0] nxt_fsm_state;

reg [3:0] cmd4;

wire start_xfer;

// ifsm next-state seqeuncer                                             
always @(*)
  case (fsm_state)
  STAT: nxt_fsm_state = (!ioack_s & (start_xfer)) ? RXC1 : STAT;
  RXC1: nxt_fsm_state = ( ioack_s) ? RXC2 : RXC1;
  RXC2: nxt_fsm_state = (!ioack_s) ? ((cmd4[0]) ? RXDH : TXDH) : RXC2;
  RXDH: nxt_fsm_state = ( ioack_s) ? RXDL : RXDH;
  RXDL: nxt_fsm_state = (!ioack_s) ? RXDZ : RXDL;
  RXDZ: nxt_fsm_state = ( ioack_s) ? STAT : RXDZ;
  TXDH: nxt_fsm_state = ( ioack_s) ? TXDL : TXDH;
  TXDL: nxt_fsm_state = (!ioack_s) ? TXDZ : TXDL;
  TXDZ: nxt_fsm_state = ( ioack_s) ? STAT : TXDZ;
  default:  nxt_fsm_state = STAT;
  endcase

// state update
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    fsm_state <= 10'h000;
  end else begin
    fsm_state <= nxt_fsm_state;
  end
end

wire status_valid = !fsm_state[0];

// stream buffers with valid qualifiers
reg [8:0] rx0_reg9;
reg [8:0] rx1_reg9;
reg [8:0] tx0_reg9;
reg [8:0] tx1_reg9;

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


// axis RX1 port interface
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rx0_reg9 <= 9'b0_00000000;
  else begin
    if (!rx0_reg9[8] & axis_rx0_tvalid) rx0_reg9 <= {1'b1,axis_rx0_tdata8[7:0]};
    else if (rx0_reg9[8] & rx0_axis_ack)  rx0_reg9[8] <= 1'b0;
    end
end
assign axis_rx0_tready = !rx0_reg9[8];
assign rx0_axis_wdata8 =  rx0_reg9[7:0];
assign rx0_axis_req    =  rx0_reg9[8];

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
assign rx1_axis_req    =  rx1_reg9[8];

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

// virtual channel requests, only valid during status phase
wire vtx0_req = status_valid & !iodata4_s[0] & req_tx0;
wire vrx0_req = status_valid & !iodata4_s[1] & req_rx0;
wire vtx1_req = status_valid & !iodata4_s[2] & req_tx1;
wire vrx1_req = status_valid & !iodata4_s[3] & req_rx1;

wire [3:0] active_req4 = {vtx1_req, vrx1_req, vtx0_req, vrx0_req};

// any active request
wire cmd4_req = (vtx0_req | vrx0_req | vtx1_req | vrx1_req);
assign start_xfer = (cmd4_req & !ioack_s);

// 12 cycle sequencer counter
reg [3:0] seq_cnt12;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    seq_cnt12 <= 4'b0000;
  else
    if (start_xfer) seq_cnt12 <= (seq_cnt12 >= 11) ? 4'b0000 : (seq_cnt12+4'b0001);
end

wire [3:0] cmd4_nxt;

// command resister
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    cmd4 <= 4'b0000; // invalid xfer pattern
  else if (cmd4_req)
    cmd4 <= cmd4_nxt;
end


// simplest fixed priority scheme: RX0, RX1, TX0, TX1 (decreasing)
/*
assign cmd4_nxt[0] =  (vrx0_req | vrx1_req); // Read/not-write always has priority
assign cmd4_nxt[1] = !(vrx0_req | vtx0_req);
*/
assign cmd4_nxt[1:0] = FNmap_patt2code2(FNpriority_seq12x2(active_req4), seq_cnt12);
/* */

assign cmd4_nxt[3:2] = 2'b00; // fixed 8-bit transfer 

// write data resister - for the committed channel
reg [7:0] wdata8;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    wdata8 <= 8'b00000000; // avoid X propagation
  else if (start_xfer & !cmd4_nxt[0]) // capture selected wdata
    wdata8 <= (cmd4_nxt[1]) ? rx1_axis_wdata8[7:0] : rx0_axis_wdata8[7:0];
end

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

// IO Write Data
assign iodata4_o = ({4{cmd_state}} & cmd4)
                 | ({4{wdh_state}} & wdata8[7:4])
                 | ({4{wdl_state}} & wdata8[3:0])
                 | ({4{wdone}} & wdata8[3:0])
                 ;

assign iodata4_e = {4{|(fsm_state[4:2])}};
assign iodata4_t = ~iodata4_e;

// and ack
assign rx0_axis_ack = !cmd4[1] & !cmd4[0] & wdone & ack_change;
assign rx1_axis_ack =  cmd4[1] & !cmd4[0] & wdone & ack_change;

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

reg [3:0] rd4_lo;
always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    rd4_lo <= 4'b0000; // initialize
  else if (rdl_state & ack_change)
    rd4_lo <= iodata4_i[3:0];
end

assign tx_axis_rdata8 = {rd4_hi[3:0],rd4_lo[3:0]};

// then ack with 8-bit data to selected axis buffer
assign tx0_axis_ack = !cmd4[1] &  cmd4[0] & rdone & ack_change;
assign tx1_axis_ack =  cmd4[1] &  cmd4[0] & rdone & ack_change;
           
endmodule

/*
extio8x4_ifsm u_extio8x4_ifsm
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
  .iodata4_s       ( iodata4_s       ),
  .iodata4_o       ( iodata4_o       ),
  .iodata4_e       ( iodata4_e       ),
  .iodata4_t       ( iodata4_t       ),
  .ioreq1_o        ( ioreq1_o        ),
  .ioreq2_o        ( ioreq2_o        ),
  .ioack_s         ( ioack_s         )
  );

*/
