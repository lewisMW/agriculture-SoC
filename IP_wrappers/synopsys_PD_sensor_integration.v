
module synopsys_PD_sensor_integration(
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
    output wire             irq_pd_rdy
);

// APB memory map
// 0x00 - 31-25 RESERVED
//      - 24    ready_reg
//      - 23-17 RESERVED
//      - 16    pd_faultn
//      - 15-8  pd_clock_div
//      - 7-4   RESERVED
//      - 3     pd_ready_reg_clr
//      - 2     RESERVED
//      - 1     pd_enable
//      - 0     pd_run
//
// 0x04 - 31-25 RESERVED
//      - 24    data2 write ack
//      - 23-17 RESERVED
//      - 16    data0 write ack
//      - 15-12 RESERVED
//      - 11-0  pd_data
//
// 0x08 - 31-25 RESERVED
//      - 24    pd_cload
//      - 23-16 pd_config_reg3
//      - 15-8  pd_config_reg2
//      - 7-0   pd_config_reg1
//
// 0x0C - 31-0  ID

// PD Signals
//  PD Clock divider signals
wire pd_enable;
wire [7:0] pd_clock_div;
reg [7:0]  pd_clock_counter;
wire pd_clkg;
reg  pd_slow_clock;


// PD Signals
wire [11:0] pd_data;

// PD Configuration
wire [7:0] pd_config_reg1;
wire [7:0] pd_config_reg2;
wire [7:0] pd_config_reg3;
wire pd_cload;

// PD Conversion
wire    pd_run;
reg     pd_ready_reg;
reg     pd_ready_last;
wire    pd_ready;
wire    pd_faultn;


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


reg    [31:0]            pd_data0;
reg    [31:0]            pd_data2;
reg  data0_write_ack;
reg  data2_write_ack;

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        data0_write_req <= 1'b0;
        data0[7:0] <= {8{1'b0}};
        data0[15:8] <= {8'h0a}; // clock div 20
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
        data2[15:8] <= {8'h60};  // SVT delay chain
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

always @(reg_read_en or reg_addr or data0 or pd_data or data2) begin
    case(reg_read_en)
        1'b1: begin
            case(reg_addr[3:2])
                3'h0: reg_rdata = {{7{1'b0}},pd_ready_reg,data0[23:17],~pd_faultn,data0[15:0]};
                3'h1: reg_rdata = {{7{1'b0}},data2_write_ack,{7{1'b0}},data0_write_ack,{4{1'b0}},pd_data};
                3'h2: reg_rdata = data2;
                3'h3: reg_rdata = 32'h736e7064;
            endcase
        end
        1'b0: begin
            reg_rdata = {32{1'b0}};
        end
    endcase
end

// reg 0 assignments in PCLK domain
assign pd_enable = data0[1];
assign pd_clock_div = data0[15:8];




// PD Clock generation
assign pd_clkg = PCLK & pd_enable;
always @(posedge pd_clkg or negedge PRESETn) begin
    if(~PRESETn) begin
        pd_clock_counter <= 8'h00;
        pd_slow_clock <= 1'b0;
    end else begin
        pd_clock_counter <= pd_clock_counter + 1;
        if(pd_clock_counter == pd_clock_div) begin
            pd_clock_counter <= 8'h00;
            pd_slow_clock <= ~pd_slow_clock;
        end
    end
end

// CDC for APB write of registers 0 and 2
always @(posedge pd_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        data0_write_ack <= 1'b0;
        data2_write_ack <= 1'b0;
        pd_data0 <= 32'd0;
        pd_data2 <= 32'd0;
    end else begin
        if(data0_write_req) begin
            pd_data0 <= data0;
            data0_write_ack <= 1'b1;
        end else begin
            data0_write_ack <= 1'b0;
        end

        if(data2_write_req) begin
            pd_data2 <= data2;
            data2_write_ack <= 1'b1;
        end else begin
            data2_write_ack <= 1'b0;
        end
    end
end


// PD Ready register clear on pd_slow_clock domain
always @(posedge pd_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        pd_ready_last <= 1'b0;
        pd_ready_reg <= 1'b0;
    end else begin
        pd_ready_last <= pd_ready;
        if(pd_ready & ~pd_ready_last) begin
            pd_ready_reg <= 1'b1;
        end else if (data0[3]) begin
            pd_ready_reg <= 1'b0;
        end
    end
end

// reg 0 assignments in PD CLK domain
assign pd_run = pd_data0[0];

// reg 2 assignments
assign pd_config_reg1 = pd_data2[7:0];
assign pd_config_reg2 = pd_data2[15:8];
assign pd_config_reg3 = pd_data2[23:16];
assign pd_cload = pd_data2[24];




// PD Combinational Logic
assign irq_pd_rdy = pd_ready_reg;



mr74125 u_synopsys_pd(
`ifdef MR74125_GATE_PW_SIM
    .VDD(),
    .VDDA(),
    .VSS(),
`endif
    .clk(pd_slow_clock),
    .run(pd_run),
    .rstn(PRESETn),
    .cload(pd_cload),
    .cfg1_0(pd_config_reg1[0]),
    .cfg1_1(pd_config_reg1[1]),
    .cfg1_2(pd_config_reg1[2]),
    .cfg1_3(pd_config_reg1[3]),
    .cfg1_4(pd_config_reg1[4]),
    .cfg1_5(pd_config_reg1[5]),
    .cfg1_6(pd_config_reg1[6]),
    .cfg1_7(pd_config_reg1[7]),
    .cfg2_0(pd_config_reg2[0]),
    .cfg2_1(pd_config_reg2[1]),
    .cfg2_2(pd_config_reg2[2]),
    .cfg2_3(pd_config_reg2[3]),
    .cfg2_4(pd_config_reg2[4]),
    .cfg2_5(pd_config_reg2[5]),
    .cfg2_6(pd_config_reg2[6]),
    .cfg2_7(pd_config_reg2[7]),
    .cfg3_0(pd_config_reg3[0]),
    .cfg3_1(pd_config_reg3[1]),
    .cfg3_2(pd_config_reg3[2]),
    .cfg3_3(pd_config_reg3[3]),
    .cfg3_4(pd_config_reg3[4]),
    .cfg3_5(pd_config_reg3[5]),
    .cfg3_6(pd_config_reg3[6]),
    .cfg3_7(pd_config_reg3[7]),
    .scan_in(1'b0),
    .scan_en(1'b0),
    .scan_test(1'b0),

    .dout0(pd_data[0]),
    .dout1(pd_data[1]),
    .dout2(pd_data[2]),
    .dout3(pd_data[3]),
    .dout4(pd_data[4]),
    .dout5(pd_data[5]),
    .dout6(pd_data[6]),
    .dout7(pd_data[7]),
    .dout8(pd_data[8]),
    .dout9(pd_data[9]),
    .dout10(pd_data[10]),
    .dout11(pd_data[11]),

    .rdy(pd_ready),
    .dout_type(),
    .faultn(pd_faultn),
    .scan_out()
);

endmodule
