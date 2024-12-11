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
    inout wire              vp_vref,
`endif
    input wire              ref_clk,
    input wire              resetn,

    output wire             pll_lock,
    output wire             out_clk1,
    output wire             out_clk2,

    input  wire             PSELx,     
    input  wire [9:0]       PADDR,    
    input  wire             PENABLE, 
    input  wire [2:0]       PPROT, 
    input  wire [3:0]       PSTRB,
    input  wire             PWRITE,   
    input  wire [31:0]      PWDATA,   
    output wire [31:0]      PRDATA,   
    output wire             PREADY,   
    output wire             PSLVERR
);

// Control register
// Bypass ---------------------------------------------------------------------------------|
// Enable P -----------------------------------------------------------------------|       |
// Enable R ---------------------------------------------------------------------| |       |
// Gear Shift ---------------------------------------------------------------|   | |       |
// bit 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0

// 
reg bypass_reg;
reg enp_reg;
reg enr_reg;
reg gear_shift_reg;

reg [15:0] gear_shift_counter;
reg [15:0] enable_counter;

reg [3:0] divvcop_reg;
reg [3:0] divvcor_reg;
reg [6:0] fbdiv_reg;
reg [5:0] p_reg;
reg [5:0] r_reg;
reg [4:0] prediv_reg;

reg pll_lock_reg;

reg [4:0] PLL_test_addr;
reg PLL_test_wr_en;
reg PLL_test_rd_en;
reg [2:0] APB_PLL_counter;
reg PLL_read_write_done;
reg [7:0] PLL_data_i;
wire [7:0] PLL_data_o;

// APB interface
localparam  APB_IDLE = 3'd0,
            APB_WRITE = 3'd1,
            APB_READ = 3'd2,
            APB_WRITE_PLL = 3'd3,
            APB_READ_PLL = 3'd4;

reg [2:0] apb_current_state;
reg [2:0] apb_next_state;

reg PSLVERR_reg;
reg [31:0] PRDATA_reg;

assign PRDATA = PRDATA_reg;
assign PSLVERR = PSLVERR_reg;

always @(posedge ref_clk or negedge resetn) begin
    if(~resetn) begin
        apb_current_state <= APB_IDLE;
        APB_PLL_counter   <= 3'h0;
    end else begin
        apb_current_state <= apb_next_state;
        if(apb_current_state == APB_WRITE_PLL || apb_current_state == APB_READ_PLL) begin
            APB_PLL_counter <= APB_PLL_counter + 3'h1;
        end else begin
            APB_PLL_counter <= 3'h0;
        end
    end
end

always @(posedge ref_clk or negedge resetn) begin
    if(~resetn) begin 
        gear_shift_counter  = 16'h0000;
        enable_counter      = 16'h0000;
    end else begin 
        if((gear_shift_reg == 1'b1)) begin
            gear_shift_counter = gear_shift_counter+1;
            if (gear_shift_counter>16'h3E88) begin
                gear_shift_counter = 16'h0000;
            end
        end else begin
            if((enp_reg==1'b0)||(enr_reg==1'b0)) begin
                enable_counter = enable_counter+1;
                if(enable_counter>16'h2718) begin
                    enable_counter = 16'h0000;
                end
            end
        end
    end    
end

always @(*) begin
    if(~resetn) begin
        bypass_reg          = 1'b0;
        enp_reg             = 1'b0; 
        enr_reg             = 1'b0;
        gear_shift_reg      = 1'b1;
        pll_lock_reg        = 1'b0;

        // Default startup of PLL
        // F_vco = 100*20/1 = 1.6 GHz
        // F_clkoutp = 400 MHz
        // F_clkoutr = 800 MHz
        divvcop_reg = DEFAULT_DIVVCOP; // Divvco = 1
        divvcor_reg = DEFAULT_DIVVCOR; // Divvco = 1
        fbdiv_reg   = DEFAULT_FBDIV;   // Feeback = 16
        p_reg       = DEFAULT_P;   // p = 4
        r_reg       = DEFAULT_R;   // r=2
        prediv_reg  = DEFAULT_PREDIV;   // prediv=1

        PSLVERR_reg         = 1'b0;
        PLL_read_write_done = 1'b0;
        PLL_test_wr_en      = 1'b0;
        PLL_test_rd_en      = 1'b0;
    end else begin
        if((gear_shift_reg == 1'b1)) begin
            if (gear_shift_counter>16'h3E80) begin
                gear_shift_reg = 1'b0;
            end
        end else begin
            if((enp_reg==1'b0)||(enr_reg==1'b0)) begin
                if(enable_counter>16'h2710) begin
                    enp_reg = 1'b1;
                    enr_reg = 1'b1;
                end
            end
        end
        if((enp_reg==1'b1)||(enr_reg==1'b1)) begin
            pll_lock_reg = pll_lock;
        end
    case(apb_current_state)
        APB_IDLE: begin
            PSLVERR_reg         = 1'b0;
            PLL_read_write_done = 1'b0;
            PLL_test_wr_en      = 1'b0;
            PLL_test_rd_en      = 1'b0;

            if(PSELx) begin
                if(PWRITE) begin
                    if(PADDR[9])
                        apb_next_state = APB_WRITE_PLL;
                    else
                        apb_next_state = APB_WRITE;
                end else begin
                    if(PADDR[9])
                        apb_next_state = APB_READ_PLL;
                    else
                        apb_next_state = APB_READ;
                end
            end
            else begin
                apb_next_state = APB_IDLE;
            end
        end
        APB_WRITE: begin
            case(PADDR)
                10'h000: begin
                    if(PSTRB[0]==1'b1) begin
                        bypass_reg = PWDATA[0];
                        enp_reg = PWDATA[4];
                        enr_reg = PWDATA[5];
                        gear_shift_reg = PWDATA[7];
                    end else begin
                        PSLVERR_reg = 1'b1;
                    end
                end
                10'h001: begin
                    PSLVERR_reg = 1'b1; 
                end
                10'h002: begin
                    PSLVERR_reg = 1'b1; 
                end
                10'h003: begin
                    if(PSTRB[0]==1'b1)
                        r_reg = PWDATA[5:0];
                    if(PSTRB[1]==1'b1)
                        divvcor_reg = PWDATA[11:8];
                    if(PSTRB[2]==1'b1)
                        p_reg = PWDATA[21:16];
                    if(PSTRB[3]==1'b1)
                        divvcop_reg = PWDATA[27:24];
                end
                10'h004: begin
                    if(PSTRB[0]==1'b1)
                        fbdiv_reg = PWDATA[6:0];
                    if(PSTRB[1]==1'b1)
                        prediv_reg = PWDATA[12:8];
                end

            endcase
            apb_next_state = APB_IDLE;
        end
        APB_READ: begin
            case(PADDR)
                10'h000: PRDATA_reg = {{24{1'b0}}, gear_shift_reg, 1'b0, enr_reg, enp_reg, {3{1'b0}}, bypass_reg};
                10'h001: PRDATA_reg = {{20{1'b0}}, gear_shift_counter};
                10'h002: PRDATA_reg = {{20{1'b0}}, enable_counter};
                10'h003: PRDATA_reg = {{4{1'b0}}, divvcop_reg, {2{1'b0}}, p_reg, {4{1'b0}}, divvcor_reg, {2{1'b0}}, r_reg};
                10'h004: PRDATA_reg = {{19{1'b0}}, prediv_reg, {1{1'b0}}, fbdiv_reg};
                10'h005: PRDATA_reg = 32'h534E504C;
                10'h006: PRDATA_reg = {{31{1'b0}},pll_lock_reg};
            endcase
            apb_next_state = APB_IDLE;
        end
        APB_WRITE_PLL: begin
            case(PADDR)
                10'h200: PLL_test_addr = 5'h00;
                10'h201: PLL_test_addr = 5'h01;
                10'h202: PLL_test_addr = 5'h02;
                10'h203: PLL_test_addr = 5'h03;
                10'h204: PLL_test_addr = 5'h04;
                10'h205: PLL_test_addr = 5'h10;
                10'h206: PLL_test_addr = 5'h11;
                10'h207: PLL_test_addr = 5'h12;
                10'h208: PLL_test_addr = 5'h13;
                10'h209: PLL_test_addr = 5'h14;
                10'h20A: PLL_test_addr = 5'h15;
                10'h20B: PLL_test_addr = 5'h16;
                10'h20C: PLL_test_addr = 5'h17;
            endcase
            PLL_test_wr_en = 1'b1;
            PLL_data_i <= PWDATA[7:0];
            if(APB_PLL_counter > 3'h2) begin
                PLL_read_write_done = 1'b1;
            end
            if(PLL_read_write_done) begin
                apb_next_state = APB_IDLE;   
            end else begin
                apb_next_state = APB_WRITE_PLL; 
            end
        end
        APB_READ_PLL: begin
            case(PADDR)
                10'h200: PLL_test_addr = 5'h00;
                10'h201: PLL_test_addr = 5'h01;
                10'h202: PLL_test_addr = 5'h02;
                10'h203: PLL_test_addr = 5'h03;
                10'h204: PLL_test_addr = 5'h04;
                10'h205: PLL_test_addr = 5'h10;
                10'h206: PLL_test_addr = 5'h11;
                10'h207: PLL_test_addr = 5'h12;
                10'h208: PLL_test_addr = 5'h13;
                10'h209: PLL_test_addr = 5'h14;
                10'h20A: PLL_test_addr = 5'h15;
                10'h20B: PLL_test_addr = 5'h16;
                10'h20C: PLL_test_addr = 5'h17;
            endcase
            PLL_test_rd_en = 1'b1;
            if(APB_PLL_counter > 3'h2) begin
                PLL_read_write_done = 1'b1;
                PRDATA_reg = {{24{1'b0}}, PLL_data_o};
            end
            if(PLL_read_write_done) begin
                apb_next_state = APB_IDLE;
            end else begin
                apb_next_state = APB_READ_PLL;
            end
        end
        default: apb_next_state = APB_IDLE;
    endcase
    end
end


assign PREADY = ((apb_current_state==APB_READ|apb_current_state==APB_WRITE|PLL_read_write_done==1'b1))? 1'b1:1'b0;


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

    .bypass(bypass_reg),      //PLL Bypass mode (0: clk_out = PLL output 1:clk_out = ref_clk/(p/r))
    .divvcop(divvcop_reg),     //Output divider for clock P (3:0)
    .divvcor(divvcor_reg),     //Output divider for clock R (3:0)
    .enp(enp_reg),         // Enable output clock P (1: clk_out = PLL output 0: clk_out = 0 or ref_clock/p)
    .enr(enr_reg),         // Enable output clock R (1: clk_out = PLL output 0: clk_out = 0 or ref_clock/r)
    .fbdiv(fbdiv_reg),       // Feedback multiplication facor (7 bits 8-131)
    .lock(pll_lock),        // PLL Lock State 
    .gear_shift(gear_shift_reg),  // Locking control, set high for faster PLL locking at cost of phase margin and jitter
    .p(p_reg),           // Post divider division factor P (1-64)
    .prediv(prediv_reg),      // input frequency division factor (1-32)
    .pwron(1'b1),       // Power on control
    .r(r_reg),           // Post divider division factor R (1-64)
    .rst(~resetn),         // Reset signal (set high for 4us whenever PWRON goes high)

    .vregp(),       // Output voltage regulator for P clock
    .vregr(),       // Output voltage regulator for R clock


    // Test Signals
    .test_data_i(PLL_data_i), //Data bus input control registers (7:0)
    .test_rd_en(PLL_test_rd_en),  // Control register read enable
    .test_rst(~resetn),    // Control register reset signal
    .test_sel(PLL_test_addr),    // Select lines for control register (4:0)
    .test_wr_en(PLL_test_wr_en),  // Control register write enable
    .test_data_o(PLL_data_o), //Data bus output control registers (7:0)

    .atb_f_m(),     //Signal for sinking or sourcing currents to/from PLL (for internal debug)
    .atb_s_m(),     // Signal for sensing voltages internal to PLL (for internal debug)
    .atb_s_p()      // Signal for sensing voltages internal to PLL (for internal debug)
);

endmodule