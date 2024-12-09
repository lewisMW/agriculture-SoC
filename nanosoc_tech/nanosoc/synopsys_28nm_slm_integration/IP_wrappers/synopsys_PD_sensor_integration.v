
module synopsys_PD_sensor_integration(
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
    output wire             irq_pd_rdy
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

// PD Signals
wire pd_clk;
reg pd_clk_slow;
wire [11:0] pd_data;
wire pd_faultn;

// PD Irq registers
wire pd_ready;
reg pd_ready_reg;
reg pd_ready_reg_clr;
reg pd_irq_enabled;
reg pd_irq_clear_reg;
reg pd_irq_rdy_reg;

// PD Enable
reg pd_enable_reg;
reg pd_clk_gate_reg;
reg [7:0] pd_clk_div;
reg pd_local_reset;

// PD Configuration
reg [7:0] pd_config_reg1;
reg [7:0] pd_config_reg2;
reg [7:0] pd_config_reg3;
reg pd_cload;

// PD Conversion
reg pd_run_reg;
reg pd_run_clear;
reg pd_run_continuous_reg;

// PD Combinational Logic
assign irq_pd_rdy = pd_irq_rdy_reg;

// Main sequential logic
always @(posedge PCLK or negedge aRESETn)begin
    if(~aRESETn) begin
        // Automatically controlled registers
        pd_irq_rdy_reg <= 1'b0;
        pd_ready_reg <= 1'b0;
        // APB Control
        apb_current_state <= APB_IDLE;
    end
    else begin 
        if(pd_irq_enabled && pd_ready)
            pd_irq_rdy_reg <= 1'b1;
        if(pd_irq_clear_reg)
            pd_irq_rdy_reg <= 1'b0;


        if(pd_ready)
            pd_ready_reg <= 1'b1;

        if(pd_ready_reg_clr) begin
            pd_ready_reg <= 1'b0;
        end
        // APB control
        apb_current_state <= apb_next_state;
    end
end

// Clock Gating
always @(negedge PCLK) begin
    pd_clk_gate_reg <= pd_enable_reg;
end

assign pd_clk = PCLK & pd_clk_gate_reg;

reg [7:0] pd_clk_div_counter;

always @(posedge pd_clk or negedge aRESETn) begin
    if(~aRESETn) begin
        pd_clk_div_counter <= 8'd0;
        pd_clk_slow <= 1'b0;
    end else begin
        pd_clk_div_counter <= pd_clk_div_counter + 8'd1;
        if(pd_clk_div_counter >= pd_clk_div) begin
            pd_clk_slow <= ~pd_clk_slow;
            pd_clk_div_counter <= 8'd0;
        end
    end
end

reg [2:0] pd_reset_delay;
reg pd_run_delay;
reg pd_run_delay_reg;

always @(posedge pd_clk_slow or negedge aRESETn) begin
     if(~aRESETn) begin
        pd_run_delay_reg <= 1'b0;
//         pd_local_reset <= 1'b0;
//         pd_reset_delay <= 3'h0;
//         pd_run_clear <= 1'b0;
//         pd_run_delay <= 1'b0;
     end else begin
        pd_run_delay_reg <= pd_run_delay;
     end
end

always @(*) begin
    if(~aRESETn) begin
        pd_enable_reg   = 1'b0;
        pd_clk_div      = 8'h14;

        pd_config_reg1  = 8'h00;
        pd_config_reg2  = 8'hC0;
        pd_config_reg3  = 8'h21;
        pd_cload        = 1'b0;

        pd_irq_clear_reg = 1'b0;
        pd_irq_enabled  = 1'b0;
        pd_run_reg      = 1'b0;
        pd_run_continuous_reg = 1'b0;
        pd_ready_reg_clr    = 1'b0;
        pd_local_reset = 1'b0;
        pd_reset_delay = 3'h0;
        pd_run_clear = 1'b0;
        pd_run_delay = 1'b0;

        PSLVERR_reg = 1'b0;
    end else begin
        if(pd_ready_reg_clr) begin
            pd_ready_reg_clr = 1'b0;
        end

        if(pd_run_continuous_reg)
            pd_run_reg = 1'b1;
        if(pd_run_clear) begin
            pd_run_clear = 1'b0;
            pd_run_reg = 1'b0;
        end

        if(~pd_run_continuous_reg & pd_run_reg)
            pd_run_delay = 1'b1;
        if(pd_run_delay_reg) begin
            pd_run_delay = 1'b0;
            pd_run_clear = 1'b1;
        end
        if(~pd_local_reset)
            pd_reset_delay = pd_reset_delay + 1'b1;
        if(pd_reset_delay>=3'h6)
            pd_local_reset = 1'b1;

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
                2'h0: begin
                    if(PSTRB[0]==1'b1) begin
                        pd_enable_reg = PWDATA[0];
                        pd_run_reg = PWDATA[1];
                        pd_run_continuous_reg = PWDATA[2];
                        pd_ready_reg_clr = PWDATA[3];
                    end
                    if(PSTRB[1]==1'b1) begin
                        pd_clk_div = PWDATA[15:8];
                    end 
                    if(PSTRB[2]==1'b1) begin
                        pd_irq_enabled = PWDATA[16];
                        pd_irq_clear_reg = PWDATA[17];
                    end
                end
                2'h1: PSLVERR_reg = 1'b1; // Data Reg - read only
                2'h2: begin // Test Control
                    if(PSTRB[0]==1'b1) begin
                        pd_config_reg1 = PWDATA[7:0];
                    end
                    if(PSTRB[1]==1'b1) begin
                        pd_config_reg2 = PWDATA[15:8];
                    end
                    if(PSTRB[2]==1'b1) begin
                        pd_config_reg3 = PWDATA[23:16];
                    end
                    if(PSTRB[3]==1'b1) begin
                        pd_cload = PWDATA[24];
                    end
                end
                2'h3: PSLVERR_reg = 1'b1; // ID Reg - read only
            endcase
            apb_next_state = APB_IDLE;
        end
        APB_READ: begin
            case(PADDR)
                2'h0: PRDATA_reg = {7'h00, pd_ready_reg, 6'h0, pd_irq_clear_reg, pd_irq_enabled, pd_clk_div, 3'h0, pd_local_reset, pd_ready_reg_clr, pd_run_continuous_reg, pd_run_reg, pd_enable_reg};
                2'h1: PRDATA_reg = {20'h0, pd_data};
                2'h2: PRDATA_reg = {7'h0, pd_cload, pd_config_reg3, pd_config_reg2, pd_config_reg1}; // Configuration
                2'h3: PRDATA_reg = 32'h736E7064; // ID Reg
            endcase
            apb_next_state = APB_IDLE;
        end
        default: apb_next_state = APB_IDLE;
    endcase
    end
end

assign PREADY = (apb_current_state==APB_READ|apb_current_state==APB_WRITE)? 1'b1:1'b0;

mr74125 u_synopsys_pd(
`ifdef MR74125_GATE_PW_SIM
    .VDD(),
    .VDDA(),
    .VSS(),
`endif 
    .clk(pd_clk_slow),      
    .run(pd_run_reg),      
    .rstn(pd_local_reset),     
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