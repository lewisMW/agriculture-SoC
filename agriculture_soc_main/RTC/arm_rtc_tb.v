`timescale 1ns/1ps

module arm_rtc_tb;

// ─── Parameters ──────────────────────────────────────────────────────────────
parameter PCLK_PERIOD   = 10;   // 100 MHz APB clock
parameter CLK1HZ_PERIOD = 1000;   // Sim-accelerated: 20ns instead of 1s
                                 // Change to 1_000_000_000 for real 1Hz

// ─── DUT Signals ─────────────────────────────────────────────────────────────
reg         PCLK;
reg         PRESETn;
reg         PSEL;
reg         PENABLE;
reg         PWRITE;
reg  [11:2] PADDR;
reg  [31:0] PWDATA;
reg         CLK1HZ;
reg         nRTCRST;
reg         nPOR;

// Scan — tied off (not used outside scan insertion flow)
reg         SCANENABLE;
reg         SCANINPCLK;
reg         SCANINCLK1HZ;

wire [31:0] PRDATA;
wire        RTCINTR;
wire        SCANOUTPCLK;
wire        SCANOUTCLK1HZ;

// ─── Test Tracking ────────────────────────────────────────────────────────────
integer pass_count;
integer fail_count;

// ─── DUT Instantiation ───────────────────────────────────────────────────────
Rtc u_rtc (
    .PCLK          (PCLK),
    .PRESETn       (PRESETn),
    .PSEL          (PSEL),
    .PENABLE       (PENABLE),
    .PWRITE        (PWRITE),
    .PADDR         (PADDR),
    .PWDATA        (PWDATA),
    .CLK1HZ        (CLK1HZ),
    .nRTCRST       (nRTCRST),
    .nPOR          (nPOR),
    .SCANENABLE    (SCANENABLE),
    .SCANINPCLK    (SCANINPCLK),
    .SCANINCLK1HZ  (SCANINCLK1HZ),
    .PRDATA        (PRDATA),
    .RTCINTR       (RTCINTR),
    .SCANOUTPCLK   (SCANOUTPCLK),
    .SCANOUTCLK1HZ (SCANOUTCLK1HZ)
);

// ─── Clock Generation ─────────────────────────────────────────────────────────
initial PCLK = 0;
always #(PCLK_PERIOD/2) PCLK = ~PCLK;

initial CLK1HZ = 0;
always #(CLK1HZ_PERIOD/2) CLK1HZ = ~CLK1HZ;

// ─── APB Master Tasks ─────────────────────────────────────────────────────────

task apb_write;
    input [11:2] addr;
    input [31:0] data;
    begin
        // SETUP phase — drive address/data, assert PSEL, deassert PENABLE
        @(posedge PCLK);
        #1;
        PADDR   = addr;
        PWDATA  = data;
        PWRITE  = 1'b1;
        PSEL    = 1'b1;
        PENABLE = 1'b0;

        // ACCESS phase — assert PENABLE
        @(posedge PCLK);
        #1;
        PENABLE = 1'b1;

        // Wait for PREADY (slave may insert wait states)
        // RTC may or may not drive PREADY; if it's always-ready,
        // PRDATA is valid on the same cycle as PENABLE=1
        @(posedge PCLK);
        #1;

        // IDLE — deassert bus
        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
    end
endtask

task apb_read;
    input  [11:2] addr;
    output [31:0] rdata;
    begin
        // SETUP phase
        @(posedge PCLK);
        #1;
        PADDR   = addr;
        PWDATA  = 32'h0;
        PWRITE  = 1'b0;
        PSEL    = 1'b1;
        PENABLE = 1'b0;

        // ACCESS phase
        @(posedge PCLK);
        #1;
        PENABLE = 1'b1;

        // Capture on rising edge while PENABLE is asserted
        @(posedge PCLK);
        rdata   = PRDATA;
        #1;

        // IDLE
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    end
endtask

task check;
    input [31:0]  actual;
    input [31:0]  expected;
    input [127:0] test_name;   // up to 16 chars as ASCII packed
    begin
        if (actual === expected) begin
            $display("PASS [%0t] %s : got 0x%08X", $time, test_name, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL [%0t] %s : expected 0x%08X, got 0x%08X",
                     $time, test_name, expected, actual);
            fail_count = fail_count + 1;
        end
    end
endtask

// RTC Register Map - using ARM PrimeCell PL031 
// PADDR is [11:2], so byte offset >> 2 gives the word address
localparam RTCDR   = 10'h000;  // 0x000 - Data Register        (read-only)
localparam RTCMR   = 10'h001;  // 0x004 - Match Register       (read/write)
localparam RTCLR   = 10'h002;  // 0x008 - Load Register        (read/write)
localparam RTCCR   = 10'h003;  // 0x00C - Control Register     (read/write, 1-bit)
localparam RTCIMSC = 10'h004;  // 0x010 - Interrupt Mask       (read/write, 1-bit)
localparam RTCRIS  = 10'h005;  // 0x014 - Raw IRQ Status       (read-only,  1-bit)
localparam RTCMIS  = 10'h006;  // 0x018 - Masked IRQ Status    (read-only,  1-bit)
localparam RTCICR  = 10'h007;  // 0x01C - Interrupt Clear      (write-only, 1-bit)

// Integration test registers (leave alone in functional sim)
localparam RTCITCR    = 10'h020;  // 0x080
localparam RTCITIP    = 10'h021;  // 0x084
localparam RTCITOP    = 10'h022;  // 0x088
localparam RTCTOFFSET = 10'h023;  // 0x08C
localparam RTCTCOUNT  = 10'h024;  // 0x090

// Identification registers (should read back fixed ARM/PrimeCell IDs)
localparam PERIPHID0    = 10'h3F8;  // 0xFF0 - expect 0x31 (PL031)
localparam PERIPHID1    = 10'h3F9;  // 0xFF4 - expect 0x10
localparam PERIPHID2    = 10'h3FA;  // 0xFF8 - expect 0x04
localparam PERIPHID3    = 10'h3FB;  // 0xFFC - expect 0x00
localparam PRIMECELLID0 = 10'h3FC;  // 0xFF0 - expect 0x0D
localparam PRIMECELLID1 = 10'h3FD;  // 0xFF4 - expect 0xF0
localparam PRIMECELLID2 = 10'h3FE;  // 0xFF8 - expect 0x05
localparam PRIMECELLID3 = 10'h3FF;  // 0xFFC - expect 0xB1

reg [31:0] rd_data;

// ─── Stimulus ─────────────────────────────────────────────────────────────────
initial begin
    $dumpfile("tb_rtc.vcd");
    $dumpvars(0, tb_rtc);

    pass_count = 0;
    fail_count = 0;

    // ── 1. Initialise all bus signals to idle ──────────────────────────────
    PSEL      = 0;
    PENABLE   = 0;
    PWRITE    = 0;
    PADDR     = 0;
    PWDATA    = 0;

    // Tie off scan pins — never driven in functional sim
    SCANENABLE   = 0;
    SCANINPCLK   = 0;
    SCANINCLK1HZ = 0;

    // ── 2. Assert resets ──────────────────────────────────────────────────
    PRESETn  = 0;
    nRTCRST  = 0;
    nPOR     = 0;

    repeat(5) @(posedge PCLK);

    // ── 3. Release power-on reset first, then RTC reset, then APB reset ──
    nPOR    = 1;
    repeat(2) @(posedge PCLK);
    nRTCRST = 1;
    repeat(2) @(posedge PCLK);
    PRESETn = 1;
    repeat(5) @(posedge PCLK);

    $display("--- Reset complete ---");

    // ── 4. Verify reset state of control register ─────────────────────────
    apb_read(RTCCR, rd_data);
    check(rd_data, 32'h0, "RTCCR reset val");

    // ── 6. Enable RTC counter ──────────────────────────────────────────────
    apb_write(RTCCR, 32'h1);
    apb_read(RTCCR, rd_data);
    check(rd_data, 32'h1, "RTCCR enable");
    $display("RTCDR after enable, before RTCLR: 0x%08X", rd_data);
    // ── 5. Load a known time value ─────────────────────────────────────────
    apb_write(RTCLR, 32'hDEAD_BEEF);

    // repeat(1) @(posedge CLK1HZ);
    repeat(4) @(posedge PCLK); 
    apb_read(RTCDR, rd_data);
    // Note: on some RTCs, RTCDR increments on each CLK1HZ rising edge,
    // so immediately after writing LR it may equal LR value.
    // Adjust the check if your RTC has a cycle delay.
    check(rd_data, 32'hDEAD_BEEF, "RTCLR load+read");


    // ── 7. Wait a few CLK1HZ ticks and check counter increments ───────────
    repeat(3) @(posedge CLK1HZ);
    repeat(2) @(posedge PCLK);

    apb_read(RTCDR, rd_data);
    // After 3 ticks, value should be DEAD_BEEF + 3
    // check(rd_data, 32'hDEAD_BEF2, "RTCDR after 3 ticks");
    check(rd_data, 32'hDEAD_BEF1, "RTCDR2ticks+syc");

    // ── 8. Set alarm (match register) and enable interrupt ─────────────────
    apb_write(RTCMR,   32'hDEAD_BEF5);  // Alarm fires 2 ticks later
    apb_write(RTCIMSC, 32'h1);           // Unmask interrupt

    // ── 9. Wait for interrupt to fire ──────────────────────────────────────
    // Use a timeout so sim doesn't hang if RTCINTR never asserts
    begin : wait_intr
        integer timeout;
        timeout = 0;
        while (RTCINTR !== 1'b1 && timeout < 200) begin
            @(posedge PCLK);
            timeout = timeout + 1;
        end
        if (RTCINTR === 1'b1)
            $display("PASS [%0t] RTCINTR asserted", $time);
        else
            $display("FAIL [%0t] RTCINTR never asserted (timeout)", $time);
    end

    // ── 10. Check raw and masked interrupt status ───────────────────────────
    apb_read(RTCRIS, rd_data);
    check(rd_data & 32'h1, 32'h1, "RTCRIS set");

    apb_read(RTCMIS, rd_data);
    check(rd_data  & 32'h1, 32'h1, "RTCMIS set");

    // ── 11. Clear interrupt ─────────────────────────────────────────────────
    apb_write(RTCICR, 32'h1);
    repeat(2) @(posedge PCLK);

    apb_read(RTCMIS, rd_data);
    check(rd_data & 32'h1, 32'h0, "RTCMIS cleared");

    if (RTCINTR === 1'b0)
        $display("PASS [%0t] RTCINTR deasserted after clear", $time);
    else
        $display("FAIL [%0t] RTCINTR still asserted after clear", $time);

    // -- 12. Read RTC Identification registers
    // Change 8'hFF to 32'hFF
    apb_read(PERIPHID0,    rd_data); $display("PERIPHID0    = 0x%02X (expect 0x31)", rd_data & 32'hFF);
    apb_read(PERIPHID1,    rd_data); $display("PERIPHID1    = 0x%02X (expect 0x10)", rd_data & 32'hFF);
    apb_read(PERIPHID2,    rd_data); $display("PERIPHID2    = 0x%02X (expect 0x04)", rd_data & 32'hFF);
    apb_read(PERIPHID3,    rd_data); $display("PERIPHID3    = 0x%02X (expect 0x00)", rd_data & 32'hFF);
    apb_read(PRIMECELLID0, rd_data); $display("PRIMECELLID0 = 0x%02X (expect 0x0D)", rd_data & 32'hFF);
    apb_read(PRIMECELLID1, rd_data); $display("PRIMECELLID1 = 0x%02X (expect 0xF0)", rd_data & 32'hFF);
    apb_read(PRIMECELLID2, rd_data); $display("PRIMECELLID2 = 0x%02X (expect 0x05)", rd_data & 32'hFF);
    apb_read(PRIMECELLID3, rd_data); $display("PRIMECELLID3 = 0x%02X (expect 0xB1)", rd_data & 32'hFF);


    // ── 13. Summary ────────────────────────────────────────────────────────
    $display("─────────────────────────────────────");
    $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
    $display("─────────────────────────────────────");

    #100;
    $finish;
end

// ─── Watchdog — kill sim if it hangs ──────────────────────────────────────────
initial begin
    #1_000_000;
    $display("WATCHDOG TIMEOUT — simulation hung");
    $finish;
end

endmodule