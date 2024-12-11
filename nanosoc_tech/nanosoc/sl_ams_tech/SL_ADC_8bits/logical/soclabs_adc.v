`include "constants.vams"
`include "disciplines.vams"

`default_discipline logic
module soclabs_adc (
    input  wire             PCLK,     
    input  wire             PCLKG,    
    input  wire             PRESETn,  
    input  wire             PSEL,     
    input  wire [9:0]       PADDR,    
    input  wire             PENABLE,  
    input  wire             PWRITE,   
    input  wire [31:0]      PWDATA,   
    output wire [31:0]      PRDATA,   
    output wire             PREADY,   
    output wire             PSLVERR, 

    input         EXTIN,    
    output wire             ADCINT
);

reg [31:0]  DATA_reg;
reg [31:0]  STATUS_reg;
reg [7:0]   ENABLE_reg;
reg [31:0]  CLK_DIV;
reg [63:0]  ID_reg = 64'h534C_0061_6463_0008;

reg [31:0] PRDATA_reg;
reg [31:0] counter;
reg PSLVERR_reg;
reg  adc_clk_reg;
wire adc_clk;
wire [7:0] data;
wire READY;
reg CLR_READY_reg;

assign PRDATA = PRDATA_reg;
assign PSLVERR = PSLVERR_reg;


// Clock divider
always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        CLK_DIV <= 32'd10;
        ENABLE_reg <= 8'd0;
        counter <= 32'd0;
        adc_clk_reg <= 1'b0;
        STATUS_reg<= 32'd0;
    end else begin
        STATUS_reg<={31'd0, READY};
        DATA_reg <= {24'd0, data};
        counter <= counter + 1;
        if(counter == CLK_DIV) begin
            adc_clk_reg <= ~adc_clk_reg;
            counter <= 32'd0;
        end
    end
end

assign adc_clk = adc_clk_reg & ENABLE_reg[0];

// APB interface
localparam  APB_IDLE = 2'd0,
            APB_WRITE = 2'd1,
            APB_READ = 2'd2;

reg [1:0] apb_current_state;
reg [1:0] apb_next_state;

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        apb_current_state <= APB_IDLE;
        PSLVERR_reg <= 1'b0;
    end else begin
        apb_current_state <= apb_next_state;
    end
end

always @(*) begin
    case(apb_current_state)
        APB_IDLE: begin
            CLR_READY_reg = 1'b0;
            PSLVERR_reg = 1'b0;
            if(PSEL) begin
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
                10'h000: PSLVERR_reg = 1'b1;
                10'h001: PSLVERR_reg = 1'b1;
                10'h002: CLK_DIV = PWDATA;
                10'h003: ENABLE_reg = PWDATA[7:0];
                10'h3F0: PSLVERR_reg = 1'b1;
                10'h3F1: PSLVERR_reg = 1'b1;
                10'h3F2: PSLVERR_reg = 1'b1;
                10'h3F3: PSLVERR_reg = 1'b1;
                10'h3F4: PSLVERR_reg = 1'b1;
                10'h3F5: PSLVERR_reg = 1'b1;
                10'h3F6: PSLVERR_reg = 1'b1;
                10'h3F7: PSLVERR_reg = 1'b1;
            endcase
            apb_next_state = APB_IDLE;
        end
        APB_READ: begin
            case(PADDR)
                10'h000: begin
                    PRDATA_reg = DATA_reg;
                    CLR_READY_reg = 1'b1;
                end
                10'h001: PRDATA_reg = STATUS_reg;
                10'h002: PRDATA_reg = CLK_DIV;
                10'h003: PRDATA_reg = {24'd0, ENABLE_reg};
                10'h3F0: PRDATA_reg = {24'd0, ID_reg[63:56]};
                10'h3F1: PRDATA_reg = {24'd0, ID_reg[55:48]};
                10'h3F2: PRDATA_reg = {24'd0, ID_reg[47:40]};
                10'h3F3: PRDATA_reg = {24'd0, ID_reg[39:32]};
                10'h3F4: PRDATA_reg = {24'd0, ID_reg[31:24]};
                10'h3F5: PRDATA_reg = {24'd0, ID_reg[23:16]};
                10'h3F6: PRDATA_reg = {24'd0, ID_reg[15:8]};
                10'h3F7: PRDATA_reg = {24'd0, ID_reg[7:0]};
                default: PRDATA_reg = 32'hDEADDEAD;
            endcase 
            apb_next_state = APB_IDLE;
        end
    endcase
end

assign PREADY = (apb_current_state==APB_READ|apb_current_state==APB_WRITE)? 1'b1:1'b0;

soclabs_adc_8bits u_adc_8bits(
    .adc_clk(adc_clk),
    .resetn(PRESETn),
    .READY(READY),
    .CLR_READY(CLR_READY_reg),
    .DATA(data)
);

endmodule