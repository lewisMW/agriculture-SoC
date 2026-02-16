`timescale 1ns / 1ps

module wrapper_control_tb;

    // Inputs
    reg clk;
    reg rst;
    reg rtc_trig;
    reg fifo_full;
    reg adc_ready;
    reg adc_done;

    // Outputs
    wire fifo_write_en;
    wire adc_enable;
    wire adc_start;
    wire apb_fifo_ready;

    // Instantiate the Unit Under Test (UUT)
    wrapper_control uut (
        .clk(clk),
        .rst(rst),
        .rtc_trig(rtc_trig),
        .fifo_full(fifo_full),
        .fifo_write_en(fifo_write_en),
        .adc_enable(adc_enable),
        .adc_ready(adc_ready),
        .adc_start(adc_start),
        .adc_done(adc_done),
        .apb_fifo_ready(apb_fifo_ready)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        rtc_trig = 0;
        fifo_full = 0;
        adc_ready = 0;
        adc_done = 0;

        // Wait for global reset
        #10;
        rst = 0;

        // Test Case 1: Normal operation
        #10;
        rtc_trig = 1;   // mock RTC trigger
        #10;
        rtc_trig = 0; 
        #10;
        if (adc_enable !== 1) begin // ADC enable signal should be high
            $display("Test Case 1 Failed");
        end
        adc_ready = 1;  // mock ADC ready signal
        #20;
        adc_ready = 0;
        #10;
        if (adc_start !== 1 || fifo_write_en != 1) begin    // ADC start and FIFO write enable signals should be high
            $display("Test Case 1 Failed");
        end
        adc_done = 1;   // mock ADC done signal
        #10;
        adc_done = 0;

        // Test Case 2: FIFO full error
        rst = 1;
        #50;
        rst = 0;
        rtc_trig = 1;
        fifo_full = 1;
        #10;
        rtc_trig = 0;
        #10;
        if (apb_fifo_ready !== 1) begin
            $display("Test Case 2 Failed");
        end
        #10;
        fifo_full = 0;

        // // Test Case 3: Reset during operation
        // #50;
        // rtc_trig = 1;
        // #10;
        // rst = 1;
        // #10;
        // rst = 0;
        // rtc_trig = 0;

        // // Validate outputs for Test Case 3
        // #10;
        // if (fifo_write_en !== 0 || adc_enable !== 0 || adc_start !== 0 || apb_fifo_ready !== 0) begin
        //     $display("Test Case 3 Failed");
        // end else begin
        //     $display("Test Case 3 Passed");
        // end

        // // Test Case 4: ADC not ready
        // #50;
        // rtc_trig = 1;
        // #10;
        // rtc_trig = 0;
        // #20;
        // adc_ready = 0;
        // #10;
        // adc_done = 1;
        // #10;
        // adc_done = 0;

        // // Validate outputs for Test Case 4
        // #10;
        // if (adc_enable !== 1 || adc_start !== 0) begin
        //     $display("Test Case 4 Failed");
        // end else begin
        //     $display("Test Case 4 Passed");
        // end

        // // Finish simulation
        // #100;
        $finish;
    end

    always @(posedge clk) begin
        $monitor("Time=%0d, rst=%b, rtc_trig=%b, fifo_full=%b, adc_ready=%b, adc_done=%b, fifo_write_en=%b, adc_enable=%b, adc_start=%b, apb_fifo_ready=%b",
                 $time, rst, rtc_trig, fifo_full, adc_ready, adc_done, fifo_write_en, adc_enable, adc_start, apb_fifo_ready);
    end

endmodule