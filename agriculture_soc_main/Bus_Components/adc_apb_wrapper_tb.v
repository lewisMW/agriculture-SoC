// ===================================================================
// Testbench: adc_apb_wrapper_tb
// ===================================================================

module adc_apb_wrapper_tb;
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 32;

    reg PCLK;
    reg PRESETn;

    reg PSEL;
    reg [ADDR_WIDTH-1:0] PADDR;
    reg PENABLE;
    reg PWRITE;
    reg [DATA_WIDTH-1:0] PWDATA;
    wire [DATA_WIDTH-1:0] PRDATA;
    wire PREADY;
    wire PSLVERR;

    reg [55:0] adc_data;
    reg adc_data_valid;

    // Instantiate DUT
    adc_apb_wrapper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PADDR(PADDR),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid)
    );

    // Clock generation (10ns period)
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // APB Read Task
    task apb_read(input [ADDR_WIDTH-1:0] addr);
    begin
        @(posedge PCLK);
        PSEL   = 1;
        PADDR  = addr;
        PWRITE = 1'b0;
        PENABLE= 1;
        @(posedge PCLK);
        PSEL   = 0;
        PENABLE= 0;
        $display("At time %0t: [APB READ] Addr = 0x%h, Data = 0x%h", $time, addr, PRDATA);
    end
    endtask

    // APB Write Task (if needed for test)
    task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
    begin
        @(posedge PCLK);
        PSEL   = 1;
        PADDR  = addr;
        PWRITE = 1'b1;
        PWDATA = data;
        PENABLE= 1;
        @(posedge PCLK);
        PSEL   = 0;
        PENABLE= 0;
        $display("At time %0t: [APB WRITE] Addr = 0x%h, Data = 0x%h", $time, addr, data);
    end
    endtask

    initial begin
        // Waveform Output
        $dumpfile("waveform.vcd");
        $dumpvars(0, adc_apb_wrapper_tb);

        // Initialize all signals
        PRESETn = 0;
        PSEL = 0;
        PADDR = 0;
        PENABLE = 0;
        PWRITE = 0;
        PWDATA = 0;
        adc_data = 56'b0;
        adc_data_valid = 0;

        // Reset Sequence
        #20;
        PRESETn = 1;
        $display("System Reset Completed at time %0t", $time);

        // 1. Read initial status (FIFO should be empty, the lower two bits of the status register should be 00)
        apb_read(12'h001);

        // 2. Send ADC data into FIFO
        @(posedge PCLK);
        adc_data = 56'h0123456789ABCDE;
        adc_data_valid = 1;
        @(posedge PCLK);
        adc_data_valid = 0;
        @(posedge PCLK);

        // 3. Read status (now FIFO is not empty, the lower two bits of the status register are not 00)
        apb_read(12'h001);

        // 4. Read FIFO high 32 bits
        apb_read(12'h002);

        // 5. Read FIFO low 24 bits (this operation should trigger FIFO dequeue)
        apb_read(12'h003);

        // Wait for one clock cycle to let fifo_rd_en_d propagate to status update
        @(posedge PCLK);

        // 6. Read status again (FIFO should be empty, the lower two bits of the status register should be 00)
        apb_read(12'h001);

        // End Simulation
        #50;
        $display("Simulation Completed at time %0t", $time);
        $finish;
    end
endmodule
