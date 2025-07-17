module synopsys_VM_sensor_integration(
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

    input  wire             an_vm0,
    input  wire             an_vm1,
    input  wire             an_vm2,
    input  wire             an_vm3,
    input  wire             an_vm4,
    input  wire             an_vm5,
    input  wire             an_vm6,
    input  wire             an_vm7,

    output wire             irq_vm_rdy
);

// APB memory map
// 0x00 - 31-25 RESERVED
//      - 24    vm_ready_reg
//      - 23-17 RESERVED
//      - 16    vm_local_reset
//      - 15-8  vm_clk_div
//      - 7-4   RESERVED
//      - 3     vm_ready_reg_clr
//      - 2     vm_run_continuous_reg
//      - 1     vm_enable_reg
//      - 0     vm_run_reg
//
// 0x04 - 31-25 RESERVED
//      - 24    data2 write ack
//      - 23-17 RESERVED
//      - 16    data0 write ack
//      - 15-12 RESERVED
//      - 11-0  vm_data
//
// 0x08 - 31-25 RESERVED
//      - 19-16 
//      - 15-9  RESERVED
//      - 8     
//      - 7-1   RESERVED
//      - 0-3   vm_sel_vin
//
// 0x0C - 31-0  ID

// vm Signals
//  vm Clock divider signals
wire vm_enable;
wire vm_pd;
wire [7:0] vm_clock_div;
reg [7:0]  vm_clock_counter;
wire vm_clkg;
reg  vm_slow_clock;
wire vm_local_reset;

// vm Signals
wire [11:0] vm_data;
wire [3:0]  vm_sel_vin;
// vm Conversion
reg     vm_ready_reg;
reg     vm_ready_last;
wire    vm_ready;
wire    vm_run_req;
reg     vm_run;

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


reg    [31:0]            vm_data0;
reg    [31:0]            vm_data2;
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

always @(reg_read_en or reg_addr or data0 or vm_data or data2) begin
    case(reg_read_en)
        1'b1: begin
            case(reg_addr[3:2])
                3'h0: reg_rdata = {{7{1'b0}},vm_ready_reg,data0[23:17],data0[16:0]};
                3'h1: reg_rdata = {{7{1'b0}},data2_write_ack,{7{1'b0}},data0_write_ack,{4{1'b0}},vm_data};
                3'h2: reg_rdata = data2;
                3'h3: reg_rdata = 32'h736E766D;
            endcase
        end
        1'b0: begin
            reg_rdata = {32{1'b0}};
        end
    endcase
end

// reg 0 assignments in PCLK domain
assign vm_clock_div = data0[15:8];
assign vm_enable = data0[1];
assign vm_sel_vin = data2[3:0];
// vm Clock generation
assign vm_clkg = PCLK & vm_enable;
always @(posedge vm_clkg or negedge PRESETn) begin
    if(~PRESETn) begin
        vm_clock_counter <= 8'h00;
        vm_slow_clock <= 1'b0;
    end else begin
        vm_clock_counter <= vm_clock_counter + 1;
        if(vm_clock_counter == vm_clock_div) begin
            vm_clock_counter <= 8'h00;
            vm_slow_clock <= ~vm_slow_clock;
        end
    end
end

// CDC for APB write of registers 0 and 2
always @(posedge vm_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        data0_write_ack <= 1'b0;
        data2_write_ack <= 1'b0;
        vm_data0 <= 32'd0;
        vm_data2 <= 32'd0;
    end else begin
        if(data0_write_req) begin
            vm_data0 <= data0;
            data0_write_ack <= 1'b1;
        end else begin
            data0_write_ack <= 1'b0;
        end

        if(data2_write_req) begin
            vm_data2 <= data2;
            data2_write_ack <= 1'b1;
        end else begin
            data2_write_ack <= 1'b0;
        end
    end
end

// vm Ready register clear on vm_slow_clock domain
always @(posedge vm_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        vm_ready_last <= 1'b0;
        vm_ready_reg <= 1'b0;
    end else begin
        vm_ready_last <= vm_ready;
        if(vm_ready & ~vm_ready_last) begin
            vm_ready_reg <= 1'b1;
        end else if (data0[3]) begin
            vm_ready_reg <= 1'b0;
        end
    end
end

// vm run needs high until rdy
assign vm_run_req = vm_data0[0];

always @(posedge vm_slow_clock or negedge PRESETn) begin
    if(~PRESETn) begin
        vm_run <= 1'b0;
    end else begin
        if(~vm_ready & vm_run_req)
            vm_run <= 1'b1;
        else if (vm_ready & ~vm_run_req)
            vm_run <= 1'b0;
    end
end




// reg 0 assignments in vm CLK domain
assign vm_local_reset = vm_data0[16];
assign vm_pd = vm_data0[1];


// vm Combinational Logic
assign irq_vm_rdy = vm_ready_reg;

mr74140 u_snps_VM(
    .clk(vm_slow_clock),
    .pd(~vm_pd),
    .run(vm_run),
    .rstn(vm_local_reset),
    .sde(1'b0),
    .tm_se(1'b0),
    .tm_si(1'b0),
    .tm_tval(1'b0),
    .tm_ld(1'b0),
    .tm_te(1'b0),
    .sel_vin0(vm_sel_vin[0]),
    .sel_vin1(vm_sel_vin[1]),
    .sel_vin2(vm_sel_vin[2]),
    .sel_vin3(vm_sel_vin[3]),
    .trim0(1'b0),
    .trim1(1'b0),
    .trim2(1'b0),
    .trim3(1'b0),
    .tm_a0(1'b0),
    .tm_a1(1'b0),
    .tm_a2(1'b0),
    .tm_a3(1'b0),
    .an_vm0(an_vm0),
    .an_vm1(an_vm1),
    .an_vm2(an_vm2),
    .an_vm3(an_vm3),
    .an_vm4(an_vm4),
    .an_vm5(an_vm5),
    .an_vm6(an_vm6),
    .an_vm7(an_vm7),
    .an_vref(),
    .rdy(vm_ready),
    .dout0(vm_data[0]),
    .dout1(vm_data[1]),
    .dout2(vm_data[2]),
    .dout3(vm_data[3]),
    .dout4(vm_data[4]),
    .dout5(vm_data[5]),
    .dout6(vm_data[6]),
    .dout7(vm_data[7]),
    .dout8(vm_data[8]),
    .dout9(vm_data[9]),
    .dout10(vm_data[10]),
    .dout11(vm_data[11]),
    .tm_so()
);

endmodule
