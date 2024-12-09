// To DO
//      - Calibration mode signals
//      - Signature mode 
//      - Test control


module synopsys_TS_sensor_integration(
    input  wire             PCLK,
    input  wire             aRESETn,

    input  wire             PSELx,     
    input  wire [1:0]       PADDR,    
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

// APB Logic
// APB interface
localparam  APB_IDLE = 3'd0,
            APB_WRITE = 3'd1,
            APB_READ = 3'd2;

reg [1:0] apb_current_state;
reg [1:0] apb_next_state;

reg PSLVERR_reg;
reg [31:0] PRDATA_reg;

assign PRDATA = PRDATA_reg;
assign PSLVERR = PSLVERR_reg;

// TS signals
wire ts_clk;
reg ts_clk_slow;
wire [11:0]  ts_data;
// TS Irq registers
wire ts_ready;
reg ts_ready_reg;
reg ts_ready_reg_clr;
reg ts_irq_enabled;
reg ts_irq_clear_reg;
reg ts_irq_rdy_reg;

// TS Enable
reg ts_enable_reg;
reg ts_clk_gate_reg;
reg [7:0] ts_clk_div;
reg ts_local_reset;

// TS conversion
reg ts_run_reg;
reg ts_run_clear;
reg ts_run_continuous_reg;

// TS test modes
reg ts_sig_en;
reg [3:0] ts_tm_an;
reg ts_cal;


// TS Combination logic
assign irq_ts_rdy = ts_irq_rdy_reg;

// Main sequential logic
always @(posedge PCLK or negedge aRESETn)begin
    if(~aRESETn) begin
        
        // Automatically controlled registers
        ts_irq_rdy_reg <= 1'b0;
        ts_ready_reg <= 1'b0;

        // APB Control
        apb_current_state <= APB_IDLE;

    end
    else begin
        // Synopsys TS register control logic
        if(ts_irq_enabled && ts_ready)
            ts_irq_rdy_reg <= 1'b1;  

        if (ts_irq_clear_reg)
            ts_irq_rdy_reg <= 1'b0;
        if(ts_ready) 
            ts_ready_reg <= 1'b1;

        if(ts_ready_reg_clr) begin
            ts_ready_reg <= 1'b0;
        end


        // APB control
        apb_current_state <= apb_next_state;
    end
end

// Clock gating
always @(negedge PCLK) begin
    ts_clk_gate_reg <= ts_enable_reg;
end

assign ts_clk = PCLK & ts_clk_gate_reg;

reg [7:0] ts_clk_div_counter;

always @(posedge ts_clk or negedge aRESETn) begin
    if(~aRESETn) begin
        ts_clk_div_counter <= 8'd0;
        ts_clk_slow <=1'b0;
    end else begin
        ts_clk_div_counter <= ts_clk_div_counter + 8'd1;
        if(ts_clk_div_counter >= ts_clk_div) begin
            ts_clk_slow <= ~ts_clk_slow;
            ts_clk_div_counter <= 8'd0;
        end
    end
end

reg [2:0] ts_reset_delay;
reg ts_run_delay;
reg ts_ready_reg_clr_del;

always @(posedge ts_clk_slow or negedge aRESETn) begin
    if(~aRESETn) begin
        // ts_local_reset <= 1'b0;
        // ts_run_clear <= 1'b0;
        // ts_reset_delay <= 3'h0;
        // ts_run_delay <= 1'b0;
        ts_ready_reg_clr_del <= 1'b0;
    end else begin 
        // if(~ts_run_continuous_reg & ts_run_reg)
        //     ts_run_delay <= 1'b1;
        // if(ts_run_delay) begin
        //     ts_run_delay <= 1'b0; 
        //     ts_run_clear <= 1'b1;
        // end
        // if(~ts_local_reset)
        //     ts_reset_delay <= ts_reset_delay + 1'b1;
        // if(ts_reset_delay>=3'h6)
        //     ts_local_reset <= 1'b1;
        ts_ready_reg_clr_del <= ts_ready_reg_clr;

    end
end

always @(*) begin
    if(~aRESETn) begin
            // Synopsys TS register control logic
        // Software definable
        ts_irq_clear_reg = 1'b0;   //Clear interrupt
        ts_irq_enabled = 1'b0;     //Enable interrupt
        ts_run_reg = 1'b0;
        ts_enable_reg = 1'b0;      //Enable Temperature sensor
        ts_run_continuous_reg = 1'b0;
        ts_clk_div = 8'd24;
        ts_ready_reg_clr = 1'b0;

        ts_sig_en = 1'b0;
        ts_tm_an = 4'h0;
        ts_cal = 1'b0;
        PSLVERR_reg = 1'b0;

        ts_local_reset = 1'b0;
        ts_run_clear = 1'b0;
        ts_reset_delay = 3'h0;
        ts_run_delay = 1'b0;

    end else begin
        if(ts_run_continuous_reg)
            ts_run_reg = 1'b1;
        if(ts_run_clear) begin
            ts_run_clear = 1'b0;
            ts_run_reg = 1'b0;
        end 
        if(ts_ready_reg_clr_del) begin
            ts_ready_reg_clr = 1'b0;
        end

        if(~ts_run_continuous_reg & ts_run_reg)
            ts_run_delay = 1'b1;
        if(ts_run_delay) begin
            ts_run_delay = 1'b0; 
            ts_run_clear = 1'b1;
        end
        if(~ts_local_reset)
            ts_reset_delay = ts_reset_delay + 1'b1;
        if(ts_reset_delay>=3'h6)
            ts_local_reset = 1'b1;


    case(apb_current_state)
        APB_IDLE: begin
            PSLVERR_reg = 1'b0;

            if(PSELx) begin
                if(PWRITE) begin
                        apb_next_state = APB_WRITE;
                end else begin
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
                        ts_enable_reg = PWDATA[0];
                        ts_run_reg = PWDATA[1];
                        ts_run_continuous_reg = PWDATA[2];
                        ts_ready_reg_clr =  PWDATA[3];
                    end
                    if(PSTRB[1]==1'b1) begin
                        ts_clk_div = PWDATA[15:8];
                    end 
                    if(PSTRB[2]==1'b1) begin
                        ts_irq_enabled = PWDATA[16];
                        ts_irq_clear_reg = PWDATA[17];
                    end
                end
                2'h1: PSLVERR_reg = 1'b1; // Data Reg - read only
                2'h2: begin // Test Control
                    if(PSTRB[0]==1'b1) begin
                        ts_cal=PWDATA[0];
                    end
                    if(PSTRB[1]==1'b1) begin
                        ts_sig_en = PWDATA[8];
                    end
                    if(PSTRB[2]==1'b1) begin
                        ts_tm_an = PWDATA[16];
                    end
                end
                2'h3: PSLVERR_reg = 1'b1; // ID Reg - read only
            endcase
            apb_next_state = APB_IDLE;
        end
        APB_READ: begin
            case(PADDR)
                2'h0: PRDATA_reg = {7'h00, ts_ready_reg, 6'h0, ts_irq_clear_reg, ts_irq_enabled, ts_clk_div, 3'h0, ts_local_reset, ts_ready_reg_clr, ts_run_continuous_reg, ts_run_reg, ts_enable_reg};
                2'h1: PRDATA_reg = {{20{1'b0}}, ts_data}; // Data Reg
                2'h2: PRDATA_reg = {8'h00, 7'h00, ts_tm_an, 7'h00, ts_sig_en, 7'h00, ts_cal}; // Test Control
                2'h3: PRDATA_reg = 32'h736E7473; // ID Reg
            endcase
            apb_next_state = APB_IDLE;
        end
        default: apb_next_state = APB_IDLE;
    endcase
    end
end

assign PREADY = (apb_current_state==APB_READ|apb_current_state==APB_WRITE)? 1'b1:1'b0;


mr74127 u_synopsys_ts(
`ifdef MR74127_GATE_PW_SIM
    .VDD(),                // Digital supply
    .VDDA(),               // Analog supply
    .VSS(),                // Combined ground
`endif
    .clk(ts_clk_slow),          // TS Clock
    .pd(~ts_enable_reg),       // TS Power Down Control (active high)
    .run(ts_run_reg),          // TS Run (active high)
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