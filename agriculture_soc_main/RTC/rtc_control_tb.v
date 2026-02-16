`timescale 1ns/1ps

module rtc_control_tb;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 12;

    // APB Interface Signals (PCLK domain)
    reg                         PCLK;
    reg                         PRESETn;
    reg                         PSEL;
    reg                         PENABLE;
    reg                         PWRITE;
    reg   [ADDR_WIDTH-1:0]      PADDR;
    reg   [DATA_WIDTH-1:0]      PWDATA;
    wire  [DATA_WIDTH-1:0]      PRDATA;
    wire                        PREADY;
    wire                        PSLVERR;

    // RTC Domain Signals
    reg                         CLK1HZ;   
    reg                         nRTCRST;
    reg                         nPOR;
    wire                        RTCINTR;
    wire                        rtc_trig;

    // Control Unit Interface Signals
    reg                         ctrl_read_time_en;
    wire [DATA_WIDTH-1:0]       ctrl_time_value;
    reg                         ctrl_set_match_en;
    reg  [DATA_WIDTH-1:0]       ctrl_match_value;
    reg                         ctrl_clear_intr;
    wire                        ctrl_intr_flag;

    // Test Mask: force the counter to increment (for test)
    reg                         test_mask_enable;

    // Timeout counter
    integer timeout_counter;

    // Instantiate DUT
    rtc_control #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .CLK1HZ(CLK1HZ),
        .nRTCRST(nRTCRST),
        .nPOR(nPOR),

        .RTCINTR(RTCINTR),
        .rtc_trig(rtc_trig),

        .ctrl_read_time_en(ctrl_read_time_en),
        .ctrl_time_value(ctrl_time_value),
        .ctrl_set_match_en(ctrl_set_match_en),
        .ctrl_match_value(ctrl_match_value),
        .ctrl_clear_intr(ctrl_clear_intr),
        .ctrl_intr_flag(ctrl_intr_flag),

        .test_mask_enable(test_mask_enable)
    );

    //-----------------------------------------------------
    // Clock Generation
    //-----------------------------------------------------
    // PCLK: 10ns period
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end
    
    // CLK1HZ: shortened to 100ns period for faster simulation
    initial begin
        CLK1HZ = 0;
        forever #50 CLK1HZ = ~CLK1HZ;
    end

    //-----------------------------------------------------
    // Reset Generation
    //-----------------------------------------------------
    initial begin
        PRESETn = 0;
        nRTCRST = 0;
        nPOR = 0;
        #20;
        PRESETn = 1;
        nRTCRST = 1;
        nPOR = 1;
    end

    //-----------------------------------------------------
    // Initialize Signals
    //-----------------------------------------------------
    initial begin
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 0;
        PWDATA = 0;
        ctrl_read_time_en = 0;
        ctrl_set_match_en = 0;
        ctrl_match_value = 0;
        ctrl_clear_intr = 0;
        test_mask_enable = 1;  // forcibly increment the counter
    end

    //-----------------------------------------------------
    // APB Write Task
    //-----------------------------------------------------
    task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
    begin
        @(posedge PCLK);
        $display("TB: APB WRITE start: addr=0x%03h, data=0x%08h, time=%t", addr, data, $time);
        PSEL = 1;
        PENABLE = 0;
        PWRITE = 1;
        PADDR = addr;
        PWDATA = data;
        @(posedge PCLK);
        PSEL = 1;
        PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        $display("TB: APB WRITE done: addr=0x%03h, data=0x%08h, time=%t", addr, data, $time);
    end
    endtask

    //-----------------------------------------------------
    // APB Extended Write Task
    //-----------------------------------------------------
    task apb_write_extended(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        integer i;
    begin
        @(posedge PCLK);
        $display("TB: APB EXTENDED WRITE start: addr=0x%03h, data=0x%08h, time=%t", addr, data, $time);
        PSEL = 1;
        PENABLE = 0;
        PWRITE = 1;
        PADDR = addr;
        PWDATA = data;
        @(posedge PCLK);
        PSEL = 1;
        PENABLE = 1;
        // hold for extra cycles to ensure the load request is captured
        for (i = 0; i < 20; i = i + 1) begin
            @(posedge PCLK);
        end
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        $display("TB: APB EXTENDED WRITE done: addr=0x%03h, data=0x%08h, time=%t", addr, data, $time);
    end
    endtask

    //-----------------------------------------------------
    // APB Read Task
    //-----------------------------------------------------
    task apb_read(input [ADDR_WIDTH-1:0] addr);
    begin
        @(posedge PCLK);
        $display("TB: APB READ start: addr=0x%03h, time=%t", addr, $time);
        PSEL = 1;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = addr;
        PWDATA = 0;
        @(posedge PCLK);
        PSEL = 1;
        PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
        $display("TB: APB READ done: addr=0x%03h, PRDATA=0x%08h, time=%t", addr, PRDATA, $time);
    end
    endtask

    //-----------------------------------------------------
    // Test Sequence
    //-----------------------------------------------------
    initial begin
        @(posedge PRESETn);
        #30;
        
        // Test 1: Extended write RTCLR (0x208) = 100
        apb_write_extended(12'h208, 32'd100);
        #1000;
        
        // Test 2: Extended write RTCCR (0x20C) = 1
        apb_write_extended(12'h20C, 32'd1);
        #1000;

        // Test 3: Extended write RTCIMSC (0x210) = 1
        apb_write_extended(12'h210, 32'd1);
        #1000;
        
        // Wait for the counter to increment
        #3000;
        
        // Test 4: Control Unit reads current RTC time
        $display("CU: Request read current RTC time at time %t", $time);
        ctrl_read_time_en = 1;
        @(posedge PCLK);
        ctrl_read_time_en = 0;
        $display("CU: RTC time = %d at time %t", ctrl_time_value, $time);
        
        // Test 5: Set next match value = current + 10
        ctrl_set_match_en = 1;
        ctrl_match_value = ctrl_time_value + 10;
        @(posedge PCLK);
        ctrl_set_match_en = 0;
        $display("CU: Set match value = %d at time %t", ctrl_match_value, $time);
        
        // Test 6: Wait for interrupt
        timeout_counter = 0;
        while ((ctrl_intr_flag == 0) && (timeout_counter < 1000)) begin
            @(posedge PCLK);
            timeout_counter = timeout_counter + 1;
        end
        if (timeout_counter >= 1000)
            $display("Timeout waiting for RTC interrupt at time %t", $time);
        else
            $display("RTC Interrupt triggered at time %t, CU RTC time = %d", $time, ctrl_time_value);
        
        // Test 7: Clear interrupt via APB write (0x21C) = 1
        apb_write_extended(12'h21C, 32'd1);
        $display("Interrupt cleared at time %t", $time);
        
        // Test 8: APB read RTCDR (0x200)
        apb_read(12'h200);
        #500;
        
        $display("TB: Final read RTCDR => 0x%08h at time %t", PRDATA, $time);
        
        #2000;
        $finish;
    end

    //-----------------------------------------------------
    // Periodic Display
    //-----------------------------------------------------
    always @(posedge PCLK) begin
        if ($time % 500 == 0)
            $display("Time: %t, CU RTC = %d, Intr = %b", 
                     $time, ctrl_time_value, ctrl_intr_flag);
    end

    //-----------------------------------------------------
    // Dump Waveform
    //-----------------------------------------------------
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, rtc_control_tb);
        $dumpvars(0, rtc_control_tb.dut);
    end

endmodule
