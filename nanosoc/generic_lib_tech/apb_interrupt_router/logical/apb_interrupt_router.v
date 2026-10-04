//-----------------------------------------------------------------------------
//
// APB Interrupt Router
//
// Simple router for interrupts, particularly for use in systems with
// minimal interrupts on the CPU (such as the Cortex M0 in nanoSoC)
//
// 64 Interrupts are combined into a 2 interrupts to CPU, the IRQ handler
// can then read over APB to discover which interrupt is responsible
//
// YOU MUST USE LEVEL SENSITIVE INTERRUPTS ON YOUR CPU
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright � 2021-5, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------


module apb_interrupt_router
    (
        input  wire         PCLK,
        input  wire         PRESETn,
        input  wire         PSEL,
        input  wire [4:0]   PADDR,
        input  wire         PENABLE,
        input  wire [3:0]   PSTRB,
        input  wire         PWRITE,
        input  wire [31:0]  PWDATA,
        output reg  [31:0]  PRDATA,
        output wire         PREADY,
        output wire         PSLVERR,

        input  wire [63:0]  IRQs_i,
        output reg  [1:0]   IRQs_o
);


// APB memory map
// 0x00 - 31-0 IRQ mask 0 (default to 0's)
// 0x04 - 31-0 IRQ mask 1 (default to 0's)
// 0x08 - 31-0 IRQs masked 0
// 0x0C - 31-0 IRQs masked 1
// 0x10 - 31-0 IRQs in 0
// 0x14 - 31-0 IRQs in 1
// 0x18 -   Masked IRQs byte location
// 0x1C - 31-0 ID


wire apb_read_en;
wire apb_write_en;
wire [1:0] apb_wr_sel;
reg [31:0] irq_mask_0;
reg [31:0] irq_mask_1;

wire [31:0] irqs_masked_0;
wire [31:0] irqs_masked_1;

wire IRQ_0_B3;
wire IRQ_0_B1;
wire IRQ_0_B2;
wire IRQ_0_B0;

wire IRQ_1_B3;
wire IRQ_1_B1;
wire IRQ_1_B2;
wire IRQ_1_B0;


// IRQ contol
assign irqs_masked_0 = IRQs_i[31:0] & irq_mask_0;
assign irqs_masked_1 = IRQs_i[63:32] & irq_mask_1;

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn) begin
        IRQs_o = 2'b00;
    end else begin
        IRQs_o[0] <= | irqs_masked_0;
        IRQs_o[1] <= | irqs_masked_1;

    end
end

assign IRQ_0_B0 = | irqs_masked_0[7:0];
assign IRQ_0_B1 = | irqs_masked_0[15:8];
assign IRQ_0_B2 = | irqs_masked_0[23:16];
assign IRQ_0_B3 = | irqs_masked_0[31:24];

assign IRQ_1_B0 = | irqs_masked_1[7:0];
assign IRQ_1_B1 = | irqs_masked_1[15:8];
assign IRQ_1_B2 = | irqs_masked_1[23:16];
assign IRQ_1_B3 = | irqs_masked_1[31:24];

// APB Control
assign apb_read_en = PSEL & (~PWRITE);
assign apb_write_en = PSEL & (~PENABLE) & PWRITE;

assign PREADY = 1'b1; // Always ready
assign PSLVERR = 1'b0; // Always OK

assign apb_wr_sel[0] = ((PADDR[4:2]==3'h0)&apb_write_en) ? 1'b1: 1'b0;
assign apb_wr_sel[1] = ((PADDR[4:2]==3'h1)&apb_write_en) ? 1'b1: 1'b0;

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn)
        irq_mask_0 <= 32'd0;
    else begin
        if(apb_wr_sel[0]) begin
            if(PSTRB[0])
                irq_mask_0[7:0] <= PWDATA[7:0];
            if(PSTRB[1])
                irq_mask_0[15:8] <= PWDATA[15:8];
            if(PSTRB[2])
                irq_mask_0[23:16] <= PWDATA[23:16];
            if(PSTRB[3])
                irq_mask_0[31:24] <= PWDATA[31:24];
        end
    end
end

always @(posedge PCLK or negedge PRESETn) begin
    if(~PRESETn)
        irq_mask_1 <= 32'd0;
    else begin
        if(apb_wr_sel[1]) begin
            if(PSTRB[0])
                irq_mask_1[7:0] <= PWDATA[7:0];
            if(PSTRB[1])
                irq_mask_1[15:8] <= PWDATA[15:8];
            if(PSTRB[2])
                irq_mask_1[23:16] <= PWDATA[23:16];
            if(PSTRB[3])
                irq_mask_1[31:24] <= PWDATA[31:24];
        end
    end
end


always @(apb_read_en or PADDR or irq_mask_0 or irq_mask_1 or PRDATA or irqs_masked_0 or irqs_masked_1 or IRQs_i) begin
    case(apb_read_en)
        1'b1: begin
            case(PADDR[4:2])
                3'h0: PRDATA = irq_mask_0;
                3'h1: PRDATA = irq_mask_1;
                3'h2: PRDATA = irqs_masked_0;
                3'h3: PRDATA = irqs_masked_1;
                3'h4: PRDATA = IRQs_i[31:0];
                3'h5: PRDATA = IRQs_i[63:32];
                3'h6: PRDATA = {3'h0,IRQ_1_B3,
                                3'h0,IRQ_1_B2,
                                3'h0,IRQ_1_B1,
                                3'h0,IRQ_1_B0,
                                3'h0,IRQ_0_B3,
                                3'h0,IRQ_0_B2,
                                3'h0,IRQ_0_B1,
                                3'h0,IRQ_0_B0};
                3'h7: PRDATA = 32'h534C4951;
                default: PRDATA = 32'hDEADBEEF;
            endcase
        end
        1'b0:
            PRDATA = 32'd0;
    endcase
end

endmodule
