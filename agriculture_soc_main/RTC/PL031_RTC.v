// Verilog Implementation of ARM PrimeCell Real Time Clock (PL031)

module pl031_rtc (
    input wire PCLK,          // APB clock
    input wire PRESETn,       // APB reset (active low)
    input wire PSEL,          // APB select
    input wire PENABLE,       // APB enable
    input wire PWRITE,        // APB write enable
    input wire [11:2] PADDR,  // APB address
    input wire [31:0] PWDATA, // APB write data
    output reg [31:0] PRDATA, // APB read data
    output reg RTCINTR,       // RTC interrupt output
    input wire CLK1HZ,        // 1Hz clock
    input wire nRTCRST,       // RTC reset (active low)
    input wire nPOR           // Power-on reset (active low)
);

    // RTC registers
    reg [31:0] RTCDR;   // Data Register (read-only)
    reg [31:0] RTCMR;   // Match Register
    reg [31:0] RTCLR;   // Load Register
    reg RTCCR;          // Control Register (1-bit: enable/disable RTC)
    reg RTCIMSC;        // Interrupt Mask Set or Clear Register (1-bit)
    reg RTCRIS;         // Raw Interrupt Status Register (1-bit, read-only)
    reg RTCMIS;         // Masked Interrupt Status Register (1-bit, read-only)

    // Internal free-running counter
    reg [31:0] counter;

    // Synchronization logic for CLK1HZ and PCLK domains
    reg [31:0] counter_sync;
    reg sync_RTCINTR;

    // Reset logic
    always @(negedge PRESETn or negedge nRTCRST or negedge nPOR) begin
        if (!PRESETn || !nRTCRST || !nPOR) begin
            RTCDR <= 32'b0;
            RTCMR <= 32'b0;
            RTCLR <= 32'b0;
            RTCCR <= 1'b0;
            RTCIMSC <= 1'b0;
            RTCRIS <= 1'b0;
            RTCMIS <= 1'b0;
            RTCINTR <= 1'b0;
            counter <= 32'b0;
        end
    end

    // Counter increment logic (CLK1HZ domain)
    always @(posedge CLK1HZ or negedge nRTCRST or negedge nPOR) begin
        if (!nRTCRST || !nPOR) begin
            counter <= 32'b0;
        end else if (RTCCR) begin
            if (counter == 32'hFFFFFFFF)
                counter <= 32'b0; // Wrap around
            else
                counter <= counter + 1;
        end
    end

    // Synchronize counter to PCLK domain
    always @(posedge PCLK) begin
        counter_sync <= counter;
    end

    // Update RTCDR with synchronized counter value
    always @(posedge PCLK) begin
        if (PSEL && PENABLE && !PWRITE && (PADDR[11:2] == 4'h0)) begin
            PRDATA <= counter_sync; // Read RTCDR
        end
    end

    // Handle writes to registers
    always @(posedge PCLK) begin
        if (PSEL && PENABLE && PWRITE) begin
            case (PADDR[11:2])
                4'h1: RTCMR <= PWDATA; // Match Register
                4'h2: RTCLR <= PWDATA; // Load Register
                4'h3: RTCCR <= PWDATA[0]; // Control Register
                4'h4: RTCIMSC <= PWDATA[0]; // Interrupt Mask Set or Clear
                4'h7: if (PWDATA[0]) RTCRIS <= 1'b0; // Clear interrupt
            endcase
        end
    end

    // Comparator logic
    always @(posedge CLK1HZ or negedge nRTCRST or negedge nPOR) begin
        if (!nRTCRST || !nPOR) begin
            RTCRIS <= 1'b0;
        end else if (RTCCR && (counter == RTCMR)) begin
            RTCRIS <= 1'b1;
        end
    end

    // Masked interrupt logic
    always @(posedge PCLK) begin
        RTCMIS <= RTCRIS & RTCIMSC;
        RTCINTR <= RTCMIS;
    end

endmodule
