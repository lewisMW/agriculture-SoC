//-----------------------------------------------------------------------------
// hostio4-axis Testbench
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2024, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_hostio4( );

  //-----------------------------------------
  // System options

localparam CLOCK_PHASE = 5;

`define MEC_INIT 1;

`ifdef ADP_FILE
  localparam ASC_FILENAME=`ADP_FILE;
`else
  localparam ASC_FILENAME="src/soclabs_nanosoc_hostio4_1.0.0/tb/asc-test.txt";
`endif

`ifdef VCD_SIM
initial begin
  $dumpfile("waves.vcd");
  $dumpvars(6,u_hostio4_controller);
  end                 
`endif // VCD_SIM

// IO's defined from target-side
  wire       clk;
  wire       C_clk; // Controller clock
  wire       T_clk; // Target clock
  wire       resetn;
  wire       testmode;
// 4-channel AXIS interface - Manager side
  wire       C_axis_rx0_tready;
  wire       C_axis_rx0_tvalid;
  wire [7:0] C_axis_rx0_tdata8;
  wire       C_axis_rx1_tready;
  wire       C_axis_rx1_tvalid;
  wire [7:0] C_axis_rx1_tdata8;
  wire       C_axis_tx0_tready;
  wire       C_axis_tx0_tvalid;
  wire [7:0] C_axis_tx0_tdata8;
  wire       C_axis_tx1_tready;
  wire       C_axis_tx1_tvalid;
  wire [7:0] C_axis_tx1_tdata8;
// 4-channel AXIS interface - Subordinate side
  wire       T_axis_rx0_tready;
  wire       T_axis_rx0_tvalid;
  wire [7:0] T_axis_rx0_tdata8;
  wire       T_axis_rx1_tready;
  wire       T_axis_rx1_tvalid;
  wire [7:0] T_axis_rx1_tdata8;
  wire       T_axis_tx0_tready;
  wire       T_axis_tx0_tvalid;
  wire [7:0] T_axis_tx0_tdata8;
  wire       T_axis_tx1_tready;
  wire       T_axis_tx1_tvalid;
  wire [7:0] T_axis_tx1_tdata8;
// external io interface
  tri  [3:0] iodata4;
  wire [3:0] C_iodata4_i;
  wire [3:0] C_iodata4_o;
  wire [3:0] C_iodata4_e;
  wire [3:0] C_iodata4_t;
  wire [3:0] T_iodata4_i;
  wire [3:0] T_iodata4_o;
  wire [3:0] T_iodata4_e;
  wire [3:0] T_iodata4_t;
  wire       ioreq1;
  wire       ioreq2;
  wire       ioack;

wire C_end_of_file1;
wire C_end_of_file2;
wire C_end_of_file;

wire T_end_of_file1;
wire T_end_of_file2;
wire T_end_of_file;

assign testmode = 1'b0;
assign C_clk =  clk;
assign T_clk = !clk;

hostio4_controller u_hostio4_controller
  (
  .clk             ( C_clk             ),
  .resetn          ( resetn            ),
  .testmode        ( testmode          ),
// RX 4-channel C_axis interface
  .axis_rx0_tready ( C_axis_rx0_tready ),
  .axis_rx0_tvalid ( C_axis_rx0_tvalid ),
  .axis_rx0_tdata8 ( C_axis_rx0_tdata8 ),
  .axis_rx1_tready ( C_axis_rx1_tready ),
  .axis_rx1_tvalid ( C_axis_rx1_tvalid ),
  .axis_rx1_tdata8 ( C_axis_rx1_tdata8 ),
  .axis_tx0_tready ( C_axis_tx0_tready ),
  .axis_tx0_tvalid ( C_axis_tx0_tvalid ),
  .axis_tx0_tdata8 ( C_axis_tx0_tdata8 ),
  .axis_tx1_tready ( C_axis_tx1_tready ),
  .axis_tx1_tvalid ( C_axis_tx1_tvalid ),
  .axis_tx1_tdata8 ( C_axis_tx1_tdata8 ),
// external io interface
  .iodata4_a       ( C_iodata4_i       ),
  .iodata4_o       ( C_iodata4_o       ),
  .iodata4_e       ( C_iodata4_e       ),
  .iodata4_t       ( C_iodata4_t       ),
  .ioreq1_o        ( ioreq1            ),
  .ioreq2_o        ( ioreq2            ),
  .ioack_a         ( ioack             )
  );

// tristate buffer emulation
   bufif0 #1 (iodata4[3], C_iodata4_o[3], C_iodata4_t[3]);
   bufif0 #1 (iodata4[2], C_iodata4_o[2], C_iodata4_t[2]);
   bufif0 #1 (iodata4[1], C_iodata4_o[1], C_iodata4_t[1]);
   bufif0 #1 (iodata4[0], C_iodata4_o[0], C_iodata4_t[0]);
   assign C_iodata4_i = iodata4;

hostio4_target u_hostio4_target
  (
  .clk             ( T_clk             ),
  .resetn          ( resetn            ),
  .testmode        ( testmode          ),
// RX 4-channel AXIS interface
  .axis_rx0_tready ( T_axis_rx0_tready ),
  .axis_rx0_tvalid ( T_axis_rx0_tvalid ),
  .axis_rx0_tdata8 ( T_axis_rx0_tdata8 ),
  .axis_rx1_tready ( T_axis_rx1_tready ),
  .axis_rx1_tvalid ( T_axis_rx1_tvalid ),
  .axis_rx1_tdata8 ( T_axis_rx1_tdata8 ),
  .axis_tx0_tready ( T_axis_tx0_tready ),
  .axis_tx0_tvalid ( T_axis_tx0_tvalid ),
  .axis_tx0_tdata8 ( T_axis_tx0_tdata8 ),
  .axis_tx1_tready ( T_axis_tx1_tready ),
  .axis_tx1_tvalid ( T_axis_tx1_tvalid ),
  .axis_tx1_tdata8 ( T_axis_tx1_tdata8 ),
// external io interface
  .iodata4_i       ( T_iodata4_i       ),
  .iodata4_o       ( T_iodata4_o       ),
  .iodata4_e       ( T_iodata4_e       ),
  .iodata4_t       ( T_iodata4_t       ),
  .ioreq1_a        ( ioreq1            ),
  .ioreq2_a        ( ioreq2            ),
  .ioack_o         ( ioack             )
  );

// tristate buffer emulation
   bufif0 #1 (iodata4[3], T_iodata4_o[3], T_iodata4_t[3]);
   bufif0 #1 (iodata4[2], T_iodata4_o[2], T_iodata4_t[2]);
   bufif0 #1 (iodata4[1], T_iodata4_o[1], T_iodata4_t[1]);
   bufif0 #1 (iodata4[0], T_iodata4_o[0], T_iodata4_t[0]);
   assign T_iodata4_i = iodata4;

// bidirectional/HiZ pullups to suppress X-inputs
  pullup(iodata4[ 0]);
  pullup(iodata4[ 1]);
  pullup(iodata4[ 2]);
  pullup(iodata4[ 3]);

reg [19:0] cycle_count;
integer C_tx0_byte_count ;
integer C_tx1_byte_count ;
integer C_rx0_byte_count ;
integer C_rx1_byte_count ;
integer T_tx0_byte_count ;
integer T_tx1_byte_count ;
integer T_rx0_byte_count ;
integer T_rx1_byte_count ;

always @(posedge C_clk or negedge resetn)
  if (!resetn)
    cycle_count <= 0;
  else
    cycle_count <= cycle_count +1;

// allow up to 32 cycles per transaction
// up to 4 competing transactions per slot
// test synchronized modulo 128

wire start_burst = !(|cycle_count[7:0]); // start of test frame
wire [3:0] C_chan_ack;
reg  [3:0] C_chan_req_en;
always @(posedge C_clk or negedge resetn)
  if (!resetn) begin
      C_chan_req_en <= 4'b0000;
    end
  else begin
    if (start_burst)
      C_chan_req_en <= ({4{cycle_count[12]}} ^cycle_count[11:8]);
    else if (C_chan_req_en[0] & C_chan_ack[0])
      C_chan_req_en[0] <= 1'b0;
    else if (C_chan_req_en[1] & C_chan_ack[1])
      C_chan_req_en[1] <= 1'b0;
    else if (C_chan_req_en[2] & C_chan_ack[2])
      C_chan_req_en[2] <= 1'b0;
    else if (C_chan_req_en[3] & C_chan_ack[3])
      C_chan_req_en[3] <= 1'b0;
  end

wire [3:0] T_chan_ack;
reg  [3:0] T_chan_req_en;
always @(posedge T_clk or negedge resetn)
  if (!resetn)
    T_chan_req_en <= 4'b0000;
  else begin
    if (!cycle_count[16])
      T_chan_req_en <= 4'b1111;
    else if (start_burst)
      T_chan_req_en <=  ({4{cycle_count[13]}} ^cycle_count[11:8]);
    else if (T_chan_req_en[0] & T_chan_ack[0])
      T_chan_req_en[0] <= 1'b0;
    else if (T_chan_req_en[1] & T_chan_ack[1])
      T_chan_req_en[1] <= 1'b0;
    else if (T_chan_req_en[2] & T_chan_ack[2])
      T_chan_req_en[2] <= 1'b0;
    else if (T_chan_req_en[3] & T_chan_ack[3])
      T_chan_req_en[3] <= 1'b0;
  end

// transfer byte counters
always @(posedge C_clk or negedge resetn)
  if (!resetn)
    C_tx0_byte_count = 0;
  else if (C_axis_tx0_tready & C_axis_tx0_tvalid)
    C_tx0_byte_count = C_tx0_byte_count + 1;

always @(posedge C_clk or negedge resetn)
  if (!resetn)
    C_tx1_byte_count = 0;
  else if (C_axis_tx1_tready & C_axis_tx1_tvalid)
    C_tx1_byte_count = C_tx1_byte_count + 1;

always @(posedge C_clk or negedge resetn)
  if (!resetn)
    C_rx0_byte_count = 0;
  else if (C_axis_rx0_tready & C_axis_rx0_tvalid)
    C_rx0_byte_count = C_rx0_byte_count + 1;

always @(posedge C_clk or negedge resetn)
  if (!resetn)
    C_rx1_byte_count = 0;
  else if (C_axis_rx1_tready & C_axis_rx1_tvalid)
    C_rx1_byte_count = C_rx1_byte_count + 1;

always @(posedge T_clk or negedge resetn)
  if (!resetn)
    T_tx0_byte_count = 0;
  else if (T_axis_tx0_tready & T_axis_tx0_tvalid)
    T_tx0_byte_count = T_tx0_byte_count + 1;

always @(posedge T_clk or negedge resetn)
  if (!resetn)
    T_tx1_byte_count = 0;
  else if (T_axis_tx1_tready & T_axis_tx1_tvalid)
    T_tx1_byte_count = T_tx1_byte_count + 1;

always @(posedge T_clk or negedge resetn)
  if (!resetn)
    T_rx0_byte_count = 0;
  else if (T_axis_rx0_tready & T_axis_rx0_tvalid)
    T_rx0_byte_count = T_rx0_byte_count + 1;

always @(posedge T_clk or negedge resetn)
  if (!resetn)
    T_rx1_byte_count = 0;
  else if (T_axis_rx1_tready & T_axis_rx1_tvalid)
    T_rx1_byte_count = T_rx1_byte_count + 1;

  wire C_axis_rx0_tready1;
  wire C_axis_rx0_tvalid1;
// Controller side testbench stream stimulus
  tb_axi_stream_io8_txd_from_file #(
    .TXDFILENAME(ASC_FILENAME)
  ) u_tb_axi_stream_io_8_txd_from_file_C_chan0 (
    .aclk       (C_clk),
    .aresetn    (resetn),
    .txd8_ready (C_axis_rx0_tready1),
    .txd8_valid (C_axis_rx0_tvalid1),
    .txd8_data  (C_axis_rx0_tdata8)
  );

  assign C_axis_rx0_tready1 = C_axis_rx0_tready & C_chan_req_en[0];
  assign C_axis_rx0_tvalid  = C_axis_rx0_tvalid1 & C_chan_req_en[0];
  assign C_chan_ack[0]      = (C_axis_rx0_tready & C_axis_rx0_tvalid);

  wire C_axis_tx0_tready1;
  wire C_axis_tx0_tvalid1;
  tb_axi_stream_io8_rxd_to_file#(
    .RXDFILENAME("C_rxd0_out.log")
  ) u_tb_axi_stream_io_8_rxd_to_file_C_chan0 (
    .aclk         (C_clk),
    .aresetn      (resetn),
    .end_of_file  (C_end_of_file1),
    .rxd8_ready   (C_axis_tx0_tready1),
    .rxd8_valid   (C_axis_tx0_tvalid1),
    .rxd8_data    (C_axis_tx0_tdata8)
  );
  assign C_axis_tx0_tvalid1 = C_axis_tx0_tvalid & C_chan_req_en[1];
  assign C_axis_tx0_tready  = C_axis_tx0_tready1 & C_chan_req_en[1] & !C_end_of_file1;
  assign C_chan_ack[1] = (C_axis_tx0_tready & C_axis_tx0_tvalid);

  wire C_axis_rx1_tready1;
  wire C_axis_rx1_tvalid1;
  tb_axi_stream_io8_txd_from_file #(
    .TXDFILENAME(ASC_FILENAME)
  ) u_tb_axi_stream_io_8_txd_from_file_C_chan1 (
    .aclk       (C_clk),
    .aresetn    (resetn),
    .txd8_ready (C_axis_rx1_tready1),
    .txd8_valid (C_axis_rx1_tvalid1),
    .txd8_data  (C_axis_rx1_tdata8)
  );

  assign C_axis_rx1_tready1 = C_axis_rx1_tready & C_chan_req_en[2];
  assign C_axis_rx1_tvalid  = C_axis_rx1_tvalid1 & C_chan_req_en[2];
  assign C_chan_ack[2]      = (C_axis_rx1_tready & C_axis_rx1_tvalid);

  wire C_axis_tx1_tready1;
  wire C_axis_tx1_tvalid1;
  tb_axi_stream_io8_rxd_to_file#(
    .RXDFILENAME("C_rxd1_out.log")
  ) u_tb_axi_stream_io_8_rxd_to_file_C_chan1 (
    .aclk         (C_clk),
    .aresetn      (resetn),
    .end_of_file  (C_end_of_file2),
    .rxd8_ready   (C_axis_tx1_tready1),
    .rxd8_valid   (C_axis_tx1_tvalid1),
    .rxd8_data    (C_axis_tx1_tdata8)
  );
  assign C_axis_tx1_tvalid1 = C_axis_tx1_tvalid & C_chan_req_en[3];
  assign C_axis_tx1_tready  = C_axis_tx1_tready1 & C_chan_req_en[3] & !C_end_of_file2;
  assign C_chan_ack[3] = (C_axis_tx1_tready & C_axis_tx1_tvalid);

  assign C_end_of_file = C_end_of_file1 & C_end_of_file2;


// Target side back-pressure tester

  wire T_axis_rx0_tready1;
  wire T_axis_rx0_tvalid1;
// Target side testbench stream stinulus
  tb_axi_stream_io8_txd_from_file #(
    .TXDFILENAME(ASC_FILENAME)
  ) u_tb_axi_stream_io_8_txd_from_file_T_chan0 (
    .aclk       (T_clk),
    .aresetn    (resetn),
    .txd8_ready (T_axis_rx0_tready1),
    .txd8_valid (T_axis_rx0_tvalid1),
    .txd8_data  (T_axis_rx0_tdata8)
  );

  assign T_axis_rx0_tready1 = T_axis_rx0_tready & T_chan_req_en[0];
  assign T_axis_rx0_tvalid  = T_axis_rx0_tvalid1 & T_chan_req_en[0];
  assign T_chan_ack[0]      = (T_axis_rx0_tready & T_axis_rx0_tvalid);

  wire T_axis_tx0_tready1;
  wire T_axis_tx0_tvalid1;
  tb_axi_stream_io8_rxd_to_file#(
    .RXDFILENAME("T_rxd0_out.log")
  ) u_tb_axi_stream_io_8_rxd_to_file_T_chan0 (
    .aclk         (T_clk),
    .aresetn      (resetn),
    .end_of_file  (T_end_of_file1),
    .rxd8_ready   (T_axis_tx0_tready1),
    .rxd8_valid   (T_axis_tx0_tvalid1), // & T_chan_req_en[1]),
    .rxd8_data    (T_axis_tx0_tdata8)
  );
  assign T_axis_tx0_tvalid1 = T_axis_tx0_tvalid & T_chan_req_en[1];
  assign T_axis_tx0_tready  = T_axis_tx0_tready1 & T_chan_req_en[1];
  assign T_chan_ack[1] = (T_axis_tx0_tready & T_axis_tx0_tvalid);

  wire T_axis_rx1_tready1;
  wire T_axis_rx1_tvalid1;
  tb_axi_stream_io8_txd_from_file #(
    .TXDFILENAME(ASC_FILENAME)
  ) u_tb_axi_stream_io_8_txd_from_file_T_chan1 (
    .aclk       (T_clk),
    .aresetn    (resetn),
    .txd8_ready (T_axis_rx1_tready1),
    .txd8_valid (T_axis_rx1_tvalid1),
    .txd8_data  (T_axis_rx1_tdata8)
  );

  assign T_axis_rx1_tready1 = T_axis_rx1_tready & T_chan_req_en[2];
  assign T_axis_rx1_tvalid  = T_axis_rx1_tvalid1 & T_chan_req_en[2];
  assign T_chan_ack[2]      = (T_axis_rx1_tready & T_axis_rx1_tvalid);

  wire T_axis_tx1_tready1;
  wire T_axis_tx1_tvalid1;
  tb_axi_stream_io8_rxd_to_file#(
    .RXDFILENAME("T_rxd1_out.log")
  ) u_tb_axi_stream_io_8_rxd_to_file_T_chan1 (
    .aclk         (T_clk),
    .aresetn      (resetn),
    .end_of_file  (T_end_of_file2),
    .rxd8_ready   (T_axis_tx1_tready1),
    .rxd8_valid   (T_axis_tx1_tvalid1), //  & T_chan_req_en[3]),
    .rxd8_data    (T_axis_tx1_tdata8)
  );
  assign T_axis_tx1_tready  = T_axis_tx1_tready1 & T_chan_req_en[3];
  assign T_axis_tx1_tvalid1 = T_axis_tx1_tvalid & T_chan_req_en[3];
  assign T_chan_ack[3] = (T_axis_tx1_tready & T_axis_tx1_tvalid);

  assign T_end_of_file = T_end_of_file1 & T_end_of_file2;


//-----------------------------------------------------------------------------
// Abstract : Simple clock and power on reset generator
//-----------------------------------------------------------------------------

  reg osc_q;
  reg poreset;
  initial
    begin
      osc_q     <= 1'b1;
      poreset     <= 1'b1;
      #(3 * CLOCK_PHASE) osc_q <= 1'b0;
      #(2 * CLOCK_PHASE) poreset <= 1'b0;
    end

  always @(osc_q)
   #CLOCK_PHASE
       osc_q <= !osc_q;

  assign clk = osc_q;

  assign resetn = !poreset;

  always @(posedge clk)
    begin // : eof_terminate
      if (C_end_of_file & T_end_of_file) begin
        #10000
        $display("hostio4 cycle count     = %d", cycle_count);
        $display("hostio4 M rx0 byte count  = %d", C_rx0_byte_count);
        $display("hostio4 M tx0 byte count  = %d", C_tx0_byte_count);
        $display("hostio4 M rx1 byte count  = %d", C_rx1_byte_count);
        $display("hostio4 M tx1 byte count  = %d", C_tx1_byte_count);
        $display("hostio4 S rx0 byte count  = %d", T_rx0_byte_count);
        $display("hostio4 S tx0 byte count  = %d", T_tx0_byte_count);
        $display("hostio4 S rx1 byte count  = %d", T_rx1_byte_count);
        $display("hostio4 S tx1 byte count  = %d", T_tx1_byte_count);
        $display("clocks per byte (approx) = %f",
              (cycle_count/(C_rx0_byte_count+ C_rx1_byte_count + C_tx0_byte_count+C_tx1_byte_count)));
        $finish();
        end
    end //

endmodule
