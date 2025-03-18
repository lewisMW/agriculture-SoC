module rtc_control(
    input  wire PCLK,
    input  wire PRESETn,
    input wire PSEL,
    input wire [ADDR_WIDTH -1 : 0] PADDR,
    input wire PENABLE,
    input wire PWRITE,
    input wire [DATA_WIDTH-1 : 0]  PWDATA,
    input wire CLK1HZ,
    input wire nRTCRST,
    input wire nPOR,

    output wire [DATA_WIDTH-1 : 0 ] PRDATA,
    output reg PREADY,
    output wire RTCINTR,
    output wire rtc_trig
);

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

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        PREADY <= 0;
    else if (PSEL && PENABLE)
        PREADY <= 1;
    else
        PREADY <= 0;
end

endmodule