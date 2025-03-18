`timescale 1ns / 1ps

module rtc_control_tb;

    // Instantiate the Unit Under Test (UUT)
    rtc_control uut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .CLK1HZ(CLK1HZ),
    .nRTCRST(nRTCRST),
    .nPOR(nPOR),

    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .RTCINTR(RTCINTR),
    .rtc_trig(rtc_trig)
    );

    // Clock generation
    always #5 PCLK = ~PCLK;

    initial begin

        $finish;
    end

    always @(posedge clk) begin
        $monitor();
    end

endmodule