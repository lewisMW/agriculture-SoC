module rtc_control(
    input wire PCLK,
    input wire PRESETn,


    input wire [DATA_WIDTH-1 : 0]  PWDATA,
    input wire CLK1HZ,
    input wire nRTCRST,
    input wire nPOR,

    output wire [DATA_WIDTH-1 : 0 ] PRDATA,
    output reg PREADY,
    output wire RTCINTR,
    output wire rtc_trig
);

wire [ADDR_WIDTH -1 : 0] PADDR;
wire PWRITE;
wire PSEL;
wire PENABLE;

assign nRTCRST = PRESETn;
assign nPOR = PRESETn;

Rtc rtc(
    // Inputs
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .CLK1HZ(CLK1HZ),
    .nRTCRST(nRTCRST),
    .nPOR(nPOR),
    
    // Outputs
    .PRDATA(PRDATA),
    .RTCINTR(RTCINTR),
    
    // Testing
    .SCANENABLE(),
    .SCANINPCLK(),
    .SCANINCLK1HZ(),
    .SCANOUTPCLK(),
    .SCANOUTCLK1HZ()
);

assign rtc_trig = RTCINTR;

// TODO: create FSM using array indexing to reflect the FSM diagram on draw.io

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        PREADY <= 0;
    else if (PSEL && PENABLE)
        PREADY <= 1;
    else
        PREADY <= 0;
end

endmodule