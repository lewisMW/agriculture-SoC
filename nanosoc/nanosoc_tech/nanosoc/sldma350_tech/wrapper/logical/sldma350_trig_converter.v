//-----------------------------------------------------------------------------
// trig converter - Converts trigger protocol to simple flags
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access l
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sldma350_trig_converter (
    input  wire         clk,
    input  wire         resetn,
    output wire         trig_in_req,
    output wire [1:0]   trig_in_req_type,
    input  wire         trig_in_ack,
    input  wire [1:0]   trig_in_ack_type,
    input  wire         DMAC_DMA_REQ,
    output wire         DMAC_DMA_REQ_ERR
);

 parameter IDLE  = 2'b00,START_REQ = 2'b01,ERROR = 2'b10,END_REQ = 2'b11;

reg [1:0]  state;
reg        dma_err;
reg        req_err;
reg [1:0]  next_state;
reg        trig_req;

assign trig_in_req = trig_req;
assign DMAC_DMA_REQ_ERR = dma_err;
assign trig_in_req_type = 2'b10;

always @(posedge clk or negedge resetn) begin
    if(~resetn) begin
        state <= IDLE;
        dma_err<= 1'b0;
    end else begin
        state <= next_state;
        if (req_err) begin
        dma_err <= 1'b1;
        end
    end
    
end

always @* begin
case(state)
    IDLE: begin
        trig_req = 1'b0;
        if (DMAC_DMA_REQ & ~trig_in_ack) begin
            req_err = 1'b0;
            next_state = START_REQ;
        end
    end
    START_REQ: begin
        trig_req = 1'b1;
        req_err = 1'b0;
        if (trig_in_ack) begin
            case (trig_in_ack_type)
                2'b00: next_state = IDLE;
                2'b10: next_state = IDLE;
                2'b01: next_state = ERROR;
            endcase
        end
    end
    ERROR: begin
        req_err = 1'b1;
        next_state = IDLE;
    end
    END_REQ: begin
        trig_req = 1'b0;
        req_err = 1'b0;
        if (~DMAC_DMA_REQ) begin
            next_state = IDLE;
        end
    end
    default : next_state = IDLE;
endcase
end


endmodule