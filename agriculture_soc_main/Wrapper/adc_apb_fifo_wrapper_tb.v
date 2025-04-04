// ===================================================================
// Testbench: adc_apb_wrapper_tb
// ===================================================================
`timescale 1ns/1ps
module adc_apb_fifo_wrapper_tb;
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

    // Instantiate DUT
    adc_apb_fifo_wrapper #(
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
        .PSLVERR(PSLVERR)
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
        $dumpfile("waveform.vcd");
        $dumpvars(0, adc_apb_fifo_wrapper_tb);

        // Initialize all signals
        PRESETn = 0;
        PSEL    = 0;
        PADDR   = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PWDATA  = 0;

        // Reset Sequence
        #20;
        PRESETn = 1;
        $display("System Reset Completed at time %0t", $time);

        // 1. Read initial status (FIFO should be empty)
        apb_read(uut.STATUS_REG_ADDR);

        // 2. Trigger ADC conversion by writing to ADC trigger register.
        //    This should cause dummy_adc to generate one new ADC data.
        apb_write(uut.ADC_TRIGGER_ADDR, 32'h00000001);
        
        @(posedge PCLK);

        // 3. Read status (now FIFO should contain one entry)
        apb_read(uut.STATUS_REG_ADDR);

        // 4. Read FIFO high 32 bits
        apb_read(uut.MEASUREMENT_HI_ADDR);

        // 5. Read FIFO low 24 bits (this operation should trigger FIFO dequeue)
        apb_read(uut.MEASUREMENT_LO_ADDR);

        @(posedge PCLK);

        // 6. Read status again (FIFO should be empty now)
        apb_read(uut.STATUS_REG_ADDR);

        // Add assertion check: if FIFO status (lower 2 bits) is not 00, error out.
        if (uut.status_reg[1:0] !== 2'b00) begin
            $error("Assertion failed! FIFO is not empty.");
        end

        #50;
        $display("Simulation Completed at time %0t", $time);
        $finish;
    end
endmodule
