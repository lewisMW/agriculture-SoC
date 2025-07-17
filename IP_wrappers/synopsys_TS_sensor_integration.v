// To DO
//      - Calibration mode signals
//      - Signature mode 
//      - Test control


module synopsys_TS_sensor_integration(
    input  wire             PCLK,
    input  wire             PRESETn,

    input  wire             PSELx,     
    input  wire [3:0]       PADDR,    
    input  wire             PENABLE, 
    input  wire [2:0]       PPROT, 
    input  wire [3:0]       PSTRB,
    input  wire             PWRITE,   
    input  wire [31:0]      PWDATA,   
    output wire [31:0]      PRDATA,   
    output wire             PREADY,   
    output wire             PSLVERR,

    input  wire             ts_vcal,
    inout  wire             ts_an_test_0,
    inout  wire             ts_an_test_1,
    inout  wire             ts_an_test_2,
    inout  wire             ts_an_test_3,

    output wire             ts_vss_sense,
    output wire             irq_ts_rdy
);


// APB memory map
// 0x00 - 31-25 RESERVED
//      - 24    ts_ready_reg
//      - 23-17 RESERVED
//      - 16    ts_local_reset
//      - 15-8  ts_clk_div
//      - 7-4   RESERVED
//      - 3     ts_ready_reg_clr
//      - 2     ts_run_continuous_reg
//      - 1     ts_enable_reg
//      - 0     ts_run_reg
//
// 0x04 - 31-25 RESERVED
//      - 24    data2 write ack
//      - 23-17 RESERVED
//      - 16    data0 write ack
//      - 15-12 RESERVED
//      - 11-0  ts_data
//
// 0x08 - 31-25 RESERVED
//      - 19-16 ts_tm_an
//      - 15-9  RESERVED
//      - 8     ts_sig_en
//      - 7-1   RESERVED
//      - 0     ts_cal
//
// 0x0C - 31-0  ID


// ts Signals
//  ts Clock divider signals
wire ts_enable;
wire ts_pd;
wire [7:0] ts_clock_div;
reg [7:0]  ts_clock_counter;
wire ts_clkg;
reg  ts_slow_clock;
wire ts_local_reset;

// ts Signals
wire [11:0] ts_data;

wire [3:0] ts_tm_an;
wire ts_sig_en;
wire ts_cal;

// ts Conversion
wire    ts_run;
reg     ts_ready_reg;
reg     ts_ready_last;
wire    ts_ready;
wire    ts_faultn;



// APB interface
  // Register module interface signals
  wire  [3:0]              reg_addr;
  wire                     reg_read_en;
  wire                     reg_write_en;
  wire  [3:0]              reg_byte_strobe;
  wire  [31:0]             reg_wdata;
  reg  [31:0]              reg_rdata;

 // Interface to convert APB signals to simple read and write controls
 cmsdk_apb4_eg_slave_interface
   #(.ADDRWIDTH (4))
   u_apb_eg_slave_interface(

  .pclk            (PCLK),     // pclk
  .presetn         (PRESETn),  // reset

  .psel            (PSELx),     // apb interface inputs
  .paddr           (PADDR),
  .penable         (PENABLE),
  .pwrite          (PWRITE),
  .pwdata          (PWDATA),
  .pstrb           (PSTRB),

  .prdata          (PRDATA),   // apb interface outputs
  .pready          (PREADY),
  .pslverr         (PSLVERR),

  // Register interface
  .addr            (reg_addr),
  .read_en         (reg_read_en),
  .write_en        (reg_write_en),
  .byte_strobe     (reg_byte_strobe),
  .wdata           (reg_wdata),
  .rdata           (reg_rdata)

  );
// address decoding for write operations
wire [2:0] wr_sel;
assign wr_sel[0] = ((reg_addr[3:2]==2'h0)&(reg_write_en)) ? 1'b1: 1'b0;
//assign wr_sel[1] = ((reg_addr[3:2]==2'h1)&(reg_write_en)) ? 1'b1: 1'b0;
assign wr_sel[2] = ((reg_addr[3:2]==2'h2)&(reg_write_en)) ? 1'b1: 1'b0;
//assign wr_sel[3] = ((reg_addr[3:2]==2'h3)&(reg_write_en)) ? 1'b1: 1'b0;

reg    [31:0]            data0;
reg    [31:0]            data2;
reg   data0_write_req;
reg   data2_write_req;


reg    [31:0]            ts_data0;
reg    [31:0]            ts_data2;
reg  data0_write_ack;
reg  data2_write_ack;


always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        data0_write_req <= 1'b0;
        data0[7:0] <= {8{1'b0}};
        data0[15:8] <= {8'h19}; // clock div 50
        data0[23:16] <= {8{1'b0}};
        data0[31:24] <= {8{1'b0}};
    end else if(wr_sel[0]) begin
        data0_write_req <= 1'b1;
        if(reg_byte_strobe[0])
            data0[ 7: 0] <= reg_wdata[ 7: 0];
        if(reg_byte_strobe[1])
            data0[15: 8] <= reg_wdata[15: 8];
        if(reg_byte_strobe[2])
            data0[23:16] <= reg_wdata[23:16];
        if(reg_byte_strobe[3])
            data0[31:24] <= reg_wdata[31:24];
    end else if (data0_write_ack) begin
        data0_write_req <= 1'b0;
    end
end

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        data2_write_req <= 1'b0;
        data2[7:0] <= {8{1'b0}}; //Process detection + Parallel data
        data2[15:8] <= {8'h00};  // SVT delay chain
        data2[23:16] <= {8{1'b0}}; // A=16 W=255
        data2[31:24] <= {8{1'b0}}; // Load 0
    end else if(wr_sel[2]) begin
        data2_write_req <= 1'b1;
        if(reg_byte_strobe[0])
            data2[ 7: 0] <= reg_wdata[ 7: 0];
        if(reg_byte_strobe[1])
            data2[15: 8] <= reg_wdata[15: 8];
        if(reg_byte_strobe[2])
            data2[23:16] <= reg_wdata[23:16];
        if(reg_byte_strobe[3])
            data2[31:24] <= reg_wdata[31:24];
    end else if(data2_write_ack) begin
        data2_write_req <= 1'b0;
    end
end

always @(reg_read_en or reg_addr or data0 or ts_data or data2) begin
    case(reg_read_en)
        1'b1: begin
            case(reg_addr[3:2])
                3'h0: reg_rdata = {{7{1'b0}},ts_ready_reg,data0[23:17],data0[16:0]};
                3'h1: reg_rdata = {{7{1'b0}},data2_write_ack,{7{1'b0}},data0_write_ack,{4{1'b0}},ts_data};
                3'h2: reg_rdata = data2;
                3'h3: reg_rdata = 32'h736E7473;
            endcase
        end
        1'b0: begin
            reg_rdata = {32{1'b0}};
        end
    endcase
end

// reg 0 assignments in PCLK domain
assign ts_clock_div = data0[15:8];
assign ts_enable = data0[1];

// ts Clock generation
assign ts_clkg = PCLK & ts_enable;
always @(posedge ts_clkg or negedge PRESETn) begin
    if(~PRESETn) begin
        ts_clock_counter <= 8'h00;
        ts_slow_clock <= 1'b0;
    end else begin
        ts_clock_counter <= ts_clock_counter + 1;
        if(ts_clock_counter == ts_clock_div) begin
            ts_clock_counter <= 8'h00;
            ts_slow_clock <= ~ts_slow_clock;
        end
    end
end


// CDC for APB write of registers 0 and 2
always @(posedge ts_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        data0_write_ack <= 1'b0;
        data2_write_ack <= 1'b0;
        ts_data0 <= 32'd0;
        ts_data2 <= 32'd0;
    end else begin
        if(data0_write_req) begin
            ts_data0 <= data0;
            data0_write_ack <= 1'b1;
        end else begin
            data0_write_ack <= 1'b0;
        end

        if(data2_write_req) begin
            ts_data2 <= data2;
            data2_write_ack <= 1'b1;
        end else begin
            data2_write_ack <= 1'b0;
        end
    end
end

// ts Ready register clear on ts_slow_clock domain
always @(posedge ts_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        ts_ready_last <= 1'b0;
        ts_ready_reg <= 1'b0;
    end else begin
        ts_ready_last <= ts_ready;
        if(ts_ready & ~ts_ready_last) begin
            ts_ready_reg <= 1'b1;
        end else if (data0[3]) begin
            ts_ready_reg <= 1'b0;
        end
    end
end

// reg 0 assignments in ts CLK domain
assign ts_run = ts_data0[0];
assign ts_local_reset = ts_data0[16];
assign ts_pd = ts_data0[1];

assign ts_tm_an = ts_data2[19:16];
assign ts_sig_en = ts_data2[8];
assign ts_cal = ts_data2[0];

// ts Combinational Logic
assign irq_ts_rdy = ts_ready_reg;

mr74127 u_synopsys_ts(
`ifdef MR74127_GATE_PW_SIM
    .VDD(),                // Digital supply
    .VDDA(),               // Analog supply
    .VSS(),                // Combined ground
`endif
    .clk(ts_slow_clock),          // TS Clock
    .pd(~ts_pd),       // TS Power Down Control (active high)
    .run(ts_run),          // TS Run (active high)
    .rstn(ts_local_reset),        // TS Reset (active low)
    .vcal(ts_vcal),               // TS Analog calibration voltage
    .cal(ts_cal),                // TS Enable for analog trim (active high)
    .ser_en(1'b0),         // TS Serial data output enable (active high)
    .sgn_en(ts_sig_en),    // TS Signature enable (active high)
    .tm_an0(ts_tm_an[0]),             // TS Test access control - bit 0 (LSB)
    .tm_an1(ts_tm_an[1]),             // TS Test access control - bit 1 (LSB)
    .tm_an2(ts_tm_an[2]),             // TS Test access control - bit 2 (LSB)
    .tm_an3(ts_tm_an[3]),             // TS Test access control - bit 3 (LSB)
    .rdy(ts_ready),                // TS Ready (active high)
    .dout0(ts_data[0]),              // TS Data Out - bit 0 (LSB)
    .dout1(ts_data[1]),              // TS Data Out - bit 1
    .dout2(ts_data[2]),              // TS Data Out - bit 2
    .dout3(ts_data[3]),              // TS Data Out - bit 3
    .dout4(ts_data[4]),              // TS Data Out - bit 4
    .dout5(ts_data[5]),              // TS Data Out - bit 5
    .dout6(ts_data[6]),              // TS Data Out - bit 6
    .dout7(ts_data[7]),              // TS Data Out - bit 7
    .dout8(ts_data[8]),              // TS Data Out - bit 8
    .dout9(ts_data[9]),              // TS Data Out - bit 9
    .dout10(ts_data[10]),             // TS Data Out - bit 10
    .dout11(ts_data[11]),             // TS Data Out - bit 11 (MSB)
    .digo(),               // TS Bitstream Out
    .an_test0(ts_an_test_0),           // TS Analog test access - signal 0
    .an_test1(ts_an_test_1),           // TS Analog test access - signal 1
    .an_test2(ts_an_test_2),           // TS Analog test access - signal 2
    .an_test3(ts_an_test_3),           // TS Analog test access - signal 3
    .vss_sense(ts_vss_sense)           // vss sense (for cal)
);

endmodule