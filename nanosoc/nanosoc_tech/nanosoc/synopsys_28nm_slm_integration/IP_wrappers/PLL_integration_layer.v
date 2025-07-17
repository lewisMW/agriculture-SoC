// Integration layer for an APB to PLL interface

module snps_PLL_integration_layer #(
    parameter DEFAULT_DIVVCOP=4'h0,
    parameter DEFAULT_DIVVCOR=4'h0,
    parameter DEFAULT_FBDIV=7'h10,
    parameter DEFAULT_P = 6'h03,
    parameter DEFAULT_R = 6'h01,
    parameter DEFAULT_PREDIV = 5'h00
    )(
`ifdef POWER_PINS
    inout wire              agnd, 
    inout wire              avdd, 
    inout wire              avddhv, 
    inout wire              dgnd, 
    inout wire              dvdd, 
`endif
    input wire              ref_clk,
    input wire              resetn,

    output wire             pll_lock,
    output wire             out_clk1,
    output wire             out_clk2,
    inout wire              vp_vref,

    input  wire             PSELx,     
    input  wire [11:0]      PADDR,    
    input  wire             PENABLE, 
    input  wire [2:0]       PPROT, 
    input  wire [3:0]       PSTRB,
    input  wire             PWRITE,   
    input  wire [31:0]      PWDATA,   
    output wire [31:0]      PRDATA,   
    output wire             PREADY,   
    output wire             PSLVERR
);

//------------------------------------------------------------------------------
// internal wires
//------------------------------------------------------------------------------
  // Register module interface signals
  wire  [12-1:0]           reg_addr;
  wire                     reg_read_en;
  wire                     reg_write_en;
  wire  [3:0]              reg_byte_strobe;
  wire  [31:0]             reg_wdata;
  reg  [31:0]              reg_rdata;

  // PLL Regs interface signals
  wire [7:0]               pll_data_i;
  wire                     pll_read_en;
  wire [4:0]               pll_addr;
  wire                     pll_wr_en;
  wire [7:0]               pll_data_o;

 // Interface to convert APB signals to simple read and write controls
 cmsdk_apb4_eg_slave_interface
   #(.ADDRWIDTH (12))
   u_apb_eg_slave_interface(

  .pclk            (ref_clk),     // pclk
  .presetn         (resetn),  // reset

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
wire [4:0] wr_sel;
assign wr_sel[0] = ((reg_addr[11:2]==10'h000)&(reg_write_en)) ? 1'b1: 1'b0;
assign wr_sel[1] = ((reg_addr[11:2]==10'h001)&(reg_write_en)) ? 1'b1: 1'b0;
assign wr_sel[2] = ((reg_addr[11:2]==10'h002)&(reg_write_en)) ? 1'b1: 1'b0;

assign pll_wr_en = ((reg_addr[11:8]==4'h2)&(reg_write_en)) ? 1'b1: 1'b0;
assign pll_read_en = ((reg_addr[11:8]==4'h2)&(reg_read_en)) ? 1'b1: 1'b0;

assign pll_data_i = reg_wdata[7:0];
assign pll_addr = reg_addr[6:2];

reg    [31:0]            data0;
reg    [31:0]            data1;
reg    [31:0]            data2;

always @(posedge ref_clk or negedge resetn) begin 
    if(~resetn) begin 
        data0 <= {32{1'b0}};
    end else if(wr_sel[0]) begin 
        if(reg_byte_strobe[0])
            data0[ 7: 0] <= reg_wdata[ 7: 0];
        if(reg_byte_strobe[1])
            data0[15: 8] <= reg_wdata[15: 8];
        if(reg_byte_strobe[2])
            data0[23:16] <= reg_wdata[23:16];
        if(reg_byte_strobe[3])
            data0[31:24] <= reg_wdata[31:24];
    end
end

always @(posedge ref_clk or negedge resetn) begin 
    if(~resetn) begin 
        data1 <= {{4{1'b0}}, DEFAULT_DIVVCOP, {2{1'b0}}, DEFAULT_P, {4{1'b0}}, DEFAULT_DIVVCOR, {2{1'b0}}, DEFAULT_R};;
    end else if(wr_sel[1]) begin 
        if(reg_byte_strobe[0])
            data1[ 7: 0] <= reg_wdata[ 7: 0];
        if(reg_byte_strobe[1])
            data1[15: 8] <= reg_wdata[15: 8];
        if(reg_byte_strobe[2])
            data1[23:16] <= reg_wdata[23:16];
        if(reg_byte_strobe[3])
            data1[31:24] <= reg_wdata[31:24];
    end
end

always @(posedge ref_clk or negedge resetn) begin 
    if(~resetn) begin 
        data2 <= {{19{1'b0}}, DEFAULT_PREDIV, {1{1'b0}}, DEFAULT_FBDIV};;
    end else if(wr_sel[2]) begin 
        if(reg_byte_strobe[0])
            data2[ 7: 0] <= reg_wdata[ 7: 0];
        if(reg_byte_strobe[1])
            data2[15: 8] <= reg_wdata[15: 8];
        if(reg_byte_strobe[2])
            data2[23:16] <= reg_wdata[23:16];
        if(reg_byte_strobe[3])
            data2[31:24] <= reg_wdata[31:24];
    end
end

always @(reg_read_en or reg_addr or data0 or data1 or data2 or pll_lock or pll_data_o) begin 
    case(reg_read_en)
        1'b1: begin 
            if(reg_addr[11:8]==4'h0) begin
                case(reg_addr[4:2])
                    3'h0: reg_rdata = data0;
                    3'h1: reg_rdata = data1;
                    3'h2: reg_rdata = data2;
                    3'h3: reg_rdata = 32'hDEADBEAF;
                    3'h4: reg_rdata = 32'hDEADBEAF;
                    3'h5: reg_rdata = 32'h534E504C;
                    3'h6: reg_rdata = {{31{1'b0}}, pll_lock};
                endcase
            end 
            else if(reg_addr[11:8]==4'h2) begin 
                reg_rdata = {{24{1'b0}},pll_data_o};
            end
        end
        1'b0: begin
            reg_rdata = {32{1'b0}};
        end
    endcase 
end

// Control register
// Bypass ---------------------------------------------------------------------------------|
// Enable P -----------------------------------------------------------------------|       |
// Enable R ---------------------------------------------------------------------| |       |
// Gear Shift ---------------------------------------------------------------|   | |       |
// bit 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0

// 


dwc_z19606ts_ns u_snps_PLL(
`ifdef BEHAVIOURAL_SIM
    // .agnd(64'd0),    // Analog and digital clean ground
    // .avdd(64'h3FECCCCCCCCCCCCD),    // Analog clean 0.9V supply
    // .avddhv(64'h3FFCCCCCCCCCCCCD),  // Dedicated analog 1.8V supply
    // .dgnd(64'd0),    // Digital ground
    // .dvdd(64'h3FECCCCCCCCCCCCD),    // Digital 0.9V supply
    .vp_vref(64'h3FECCCCCCCCCCCCD),     // Input reference voltage (similar to AVDD)
`else
//     .agnd(agnd),
//     .avdd(avdd),
//     .avddhv(avddhv),
//     .dgnd(dgnd),
//     .dvdd(dvdd),
    .vp_vref(vp_vref),    
`endif
    // Clock Signals
    .ref_clk(ref_clk),     // Input reference clock signal
    .clkoutp(out_clk1),
    .clkoutr(out_clk2),

    .bypass(data0[0]),      //PLL Bypass mode (0: clk_out = PLL output 1:clk_out = ref_clk/(p/r))
    .divvcop(data1[27:24]),     //Output divider for clock P (3:0)
    .divvcor(data1[11:8]),     //Output divider for clock R (3:0)
    .enp(data0[4]),         // Enable output clock P (1: clk_out = PLL output 0: clk_out = 0 or ref_clock/p)
    .enr(data0[5]),         // Enable output clock R (1: clk_out = PLL output 0: clk_out = 0 or ref_clock/r)
    .fbdiv(data2[6:0]),       // Feedback multiplication facor (7 bits 8-131)
    .lock(pll_lock),        // PLL Lock State 
    .gear_shift(data0[7]),  // Locking control, set high for faster PLL locking at cost of phase margin and jitter
    .p(data1[21:16]),           // Post divider division factor P (1-64)
    .prediv(data2[12:8]),      // input frequency division factor (1-32)
    .pwron(data0[8]),       // Power on control
    .r(data1[5:0]),           // Post divider division factor R (1-64)
    .rst(~data0[9]),         // Reset signal (set high for 4us whenever PWRON goes high)

    .vregp(),       // Output voltage regulator for P clock
    .vregr(),       // Output voltage regulator for R clock


    // Test Signals
    .test_data_i(pll_data_i), //Data bus input control registers (7:0)
    .test_rd_en(pll_read_en),  // Control register read enable
    .test_rst(~data0[9]),    // Control register reset signal
    .test_sel(pll_addr),    // Select lines for control register (4:0)
    .test_wr_en(pll_wr_en),  // Control register write enable
    .test_data_o(pll_data_o), //Data bus output control registers (7:0)

    .atb_f_m(),     //Signal for sinking or sourcing currents to/from PLL (for internal debug)
    .atb_s_m(),     // Signal for sensing voltages internal to PLL (for internal debug)
    .atb_s_p()      // Signal for sensing voltages internal to PLL (for internal debug)
);

endmodule