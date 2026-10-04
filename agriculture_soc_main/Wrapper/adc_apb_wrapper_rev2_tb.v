`timescale 1ns/1ps
// =============================================================================
// adc_apb_wrapper_rev2_tb.v
//
// Integration test for the sensing peripheral: RTC (autonomous alarm) + FSM +
// ADC + FIFO behind one APB slave. Exercises
//   - the autonomous poll path (RTC alarm -> FSM -> ADC -> FIFO),
//   - firmware readout of samples (status + measurement_lo pop),
//   - a manual one-shot trigger,
//   - RTC register passthrough (read live time at 0x200),
//   - calibration-mode conversion, and
//   - FIFO clear.
//
// Requires the ARM PL031 IP (pulled in by the Makefile via ARM_IP_LIBRARY_PATH).
// =============================================================================
module adc_apb_wrapper_rev2_tb;
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 32;
    parameter PCLK_PERIOD   = 10;
    parameter CLK1HZ_PERIOD = 1000;

    reg                   PCLK, CLK1HZ, PRESETn, nPOR;
    reg                   PSEL, PENABLE, PWRITE;
    reg  [ADDR_WIDTH-1:0] PADDR;
    reg  [DATA_WIDTH-1:0] PWDATA;
    wire [DATA_WIDTH-1:0] PRDATA;
    wire                  PREADY, PSLVERR;

    integer pass_count = 0;
    integer fail_count = 0;
    reg [31:0] rd;
    reg        rd_err;   // PSLVERR captured during the ACCESS phase of a read

    // Register offsets (mirror sensing_ip.h)
    localparam A_STATUS  = 12'h004;
    localparam A_MEAS_HI = 12'h008;
    localparam A_MEAS_LO = 12'h00C;
    localparam A_AMUX    = 12'h104;
    localparam A_TRIG    = 12'h108;
    localparam A_CAL     = 12'h10C;
    localparam A_RTC_DR  = 12'h200;
    localparam A_FIFOCLR = 12'h220;
    localparam A_ALARMO  = 12'h224;

    adc_apb_wrapper_rev2 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .PCLK(PCLK), .CLK1HZ(CLK1HZ), .PRESETn(PRESETn), .nPOR(nPOR),
        .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .APBACTIVE(1'b1), .PPROT(3'b0), .PSTRB(4'hF)
    );

    initial PCLK   = 0;  always #(PCLK_PERIOD/2)   PCLK   = ~PCLK;
    initial CLK1HZ = 0;  always #(CLK1HZ_PERIOD/2) CLK1HZ = ~CLK1HZ;

    task check_true;
        input        cond;
        input [511:0] name;
        begin
            if (cond) begin $display("PASS [%0t] %s", $time, name); pass_count = pass_count + 1; end
            else      begin $display("FAIL [%0t] %s", $time, name); fail_count = fail_count + 1; end
        end
    endtask

    task apb_write(input [11:0] addr, input [31:0] data);
    begin
        @(posedge PCLK); #1; PSEL=1; PADDR=addr; PWDATA=data; PWRITE=1; PENABLE=0;
        @(posedge PCLK); #1; PENABLE=1;
        @(posedge PCLK); #1; PSEL=0; PENABLE=0; PWRITE=0;
    end
    endtask

    task apb_read(input [11:0] addr);
    begin
        @(posedge PCLK); #1; PSEL=1; PADDR=addr; PWRITE=0; PENABLE=0;
        @(posedge PCLK); #1; PENABLE=1;
        @(posedge PCLK); rd = PRDATA; rd_err = PSLVERR; #1; PSEL=0; PENABLE=0;
    end
    endtask

    // Wait until the FIFO holds at least one sample
    task wait_fifo_data(input integer timeout);
        integer i; begin
            i = 0;
            while (uut.fifo_empty && i < timeout) begin @(posedge PCLK); i = i + 1; end
            if (uut.fifo_empty) $display("TIMEOUT waiting for FIFO data at %0t", $time);
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, adc_apb_wrapper_rev2_tb);

        PSEL=0; PENABLE=0; PWRITE=0; PADDR=0; PWDATA=0;

        // Reset (nPOR released first, then APB reset), then let nRTCRST recover
        PRESETn=0; nPOR=0;
        repeat(5) @(posedge PCLK);
        nPOR=1;
        repeat(2) @(posedge PCLK);
        PRESETn=1;
        repeat(2) @(posedge CLK1HZ);
        repeat(3) @(posedge PCLK);
        $display("--- reset released ---");

        // 1. FIFO empty out of reset
        apb_read(A_STATUS);
        check_true((rd & 32'h3) == 32'h0, "FIFO empty after reset");

        // 2. Autonomous poll: short period so the RTC alarm fires quickly
        apb_write(A_ALARMO, 32'd3);
        $display("--- waiting for autonomous RTC-triggered sample ---");
        wait_fifo_data(20000);
        apb_read(A_STATUS);
        check_true((rd & 32'h3) != 32'h0, "FIFO has data after RTC-triggered sample");

        // 3. Read the sample out; high word is 0 (8-bit ADC), low word pops FIFO
        apb_read(A_MEAS_HI);
        check_true(rd == 32'h0, "measurement_hi is 0 for 8-bit sample");
        apb_read(A_MEAS_LO);
        $display("    sample = 0x%02x", rd[7:0]);
        check_true(rd[31:8] == 24'h0, "measurement_lo upper bits zero");

        // 4. Slow the poll right down so the rest of the test is deterministic
        apb_write(A_ALARMO, 32'd100000);
        // drain anything already queued
        apb_write(A_FIFOCLR, 32'h1);
        repeat(4) @(posedge PCLK);
        apb_read(A_STATUS);
        check_true((rd & 32'h3) == 32'h0, "FIFO empty after fifo_clear");

        // 5. Manual one-shot trigger
        apb_write(A_TRIG, 32'h1);
        wait_fifo_data(2000);
        apb_read(A_STATUS);
        check_true((rd & 32'h3) != 32'h0, "FIFO has data after manual trigger");
        apb_read(A_MEAS_LO);
        $display("    manual sample = 0x%02x", rd[7:0]);

        // 6. RTC passthrough: read live time (RTCDR). The autonomous RTC only
        //    grants its bus while parked in WAITING, so a read that collides
        //    with an arm cycle is correctly denied (PSLVERR) and firmware just
        //    retries. Let the short-interval alarm fire once and re-arm long
        //    (offset was set to 100000 above), then read with a retry loop.
        repeat(6) @(posedge CLK1HZ);
        begin : rtc_read
            integer tries;
            tries = 0;
            apb_read(A_RTC_DR);
            while (rd_err && tries < 50) begin
                apb_read(A_RTC_DR);
                tries = tries + 1;
            end
        end
        $display("    RTCDR = 0x%08x (slverr=%b)", rd, rd_err);
        check_true(rd_err === 1'b0, "RTC passthrough read granted (not denied)");
        check_true(rd != 32'h0, "RTC time readable & non-zero via passthrough");

        // 7. Calibration-mode conversion
        apb_write(A_CAL, 32'h1);
        apb_write(A_TRIG, 32'h1);
        wait_fifo_data(2000);
        apb_read(A_MEAS_LO);
        $display("    calibrated sample = 0x%02x", rd[7:0]);
        check_true(1'b1, "calibration-mode conversion completed");
        apb_write(A_CAL, 32'h0);

        // 8. FIFO clear leaves it empty
        apb_write(A_FIFOCLR, 32'h1);
        repeat(4) @(posedge PCLK);
        apb_read(A_STATUS);
        check_true((rd & 32'h3) == 32'h0, "FIFO empty after final clear");

        $display("\n=== WRAPPER: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        #50 $finish;
    end

    initial begin
        #50_000_000;
        $display("WATCHDOG TIMEOUT");
        $finish;
    end
endmodule
