`timescale 1ns/1ps
// =============================================================================
// sens_rob_tb.sv - ROB-1 illegal-state recovery
//
// Forces rtc_control_2.state to the unused encodings 15 and 31 and
// wrapper_control_2.state to 7 for one cycle (as an SEU would), at several
// points of the sampling cycle, then checks that each FSM returns to IDLE,
// that no FIFO write and no rtc_trig is produced on the way, and that
// autonomous and manual sampling resume.
//
// Built WITHOUT the coverage models and WITHOUT the bound SVA: their viol_
// state bins / legal-state assertions exist to flag exactly what this bench
// does on purpose. Closes rtc_control_2.v and wrapper_control_2.v `default`
// arms in the code-coverage gate (waiver C-1 not needed).
// Ends with "=== SENS-ROB: N PASSED, M FAILED ===".
// =============================================================================
module sens_rob_tb;
    localparam logic [15:0] A_STATUS = 16'h004, A_MEAS_LO = 16'h00C, A_TRIG = 16'h108,
                            A_FCLR = 16'h220, A_ALARM = 16'h224;
    localparam logic [4:0] R_IDLE = 5'd0, R_WAITING = 5'd10;
    localparam logic [2:0] F_IDLE = 3'd0, F_WDONE = 3'd4;

    logic        PCLK = 1'b0, CLK1HZ = 1'b0, PRESETn = 1'b0, nPOR = 1'b0;
    logic        PSEL = 1'b0, PENABLE = 1'b0, PWRITE = 1'b0;
    logic [15:0] PADDR = '0;
    logic [31:0] PWDATA = '0;
    wire  [31:0] PRDATA;
    wire         PREADY, PSLVERR;

    adc_apb_wrapper_rev2 #(.ADDR_WIDTH(16), .DEFAULT_ALARM_OFFSET(32'd1)) uut (
        .PCLK(PCLK), .CLK1HZ(CLK1HZ), .PRESETn(PRESETn), .nPOR(nPOR),
        .PSEL(PSEL), .PADDR(PADDR), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
        .APBACTIVE(1'b1), .PPROT(3'b001), .PSTRB(4'hF),
        .ADC_VINP(1'b0), .ADC_VINN(1'b0));

    always #5 PCLK = ~PCLK;
    always #1000 CLK1HZ = ~CLK1HZ;            // one tick = 200 PCLK

    int pass_count = 0, fail_count = 0;
    function automatic void check(input bit c, input string name);
        if (c) pass_count++;
        else begin fail_count++; $display("FAIL [%0t] %s", $time, name); end
    endfunction

    int unsigned n_trig = 0, n_wr = 0;
    always @(posedge PCLK) if (PRESETn) begin
        if (uut.rtc_trig) n_trig++;
        if (uut.fifo_write_en) n_wr++;
    end

    task automatic cyc(input int n); repeat (n) @(posedge PCLK); #1; endtask
    task automatic wr(input logic [15:0] a, input logic [31:0] d);
        PSEL = 1; PENABLE = 0; PWRITE = 1; PADDR = a; PWDATA = d;
        @(posedge PCLK); #1; PENABLE = 1;
        do @(posedge PCLK); while (!PREADY);
        #1; PSEL = 0; PENABLE = 0; PWRITE = 0;
    endtask

    task automatic wait_rtc(input logic [4:0] s, input int tmo, output bit ok);
        int i = 0; ok = 0;
        while (i < tmo) begin if (uut.u_rtc.state == s) begin ok = 1; return; end cyc(1); i++; end
    endtask
    task automatic wait_fsm(input logic [2:0] s, input int tmo, output bit ok);
        int i = 0; ok = 0;
        while (i < tmo) begin if (uut.u_ctrl.state == s) begin ok = 1; return; end cyc(1); i++; end
    endtask

    // Force the RTC FSM to an unused encoding for one cycle.
    task automatic upset_rtc(input logic [4:0] bad, input logic [4:0] when, input string nm);
        bit ok;
        int unsigned t0, w0, t1;
        wait_rtc(when, 2000, ok);
        check(ok, {"ROB-1 precondition: RTC FSM in ", nm});
        t0 = n_trig; w0 = n_wr;
        force uut.u_rtc.state = bad;
        cyc(1);
        release uut.u_rtc.state;
        cyc(2);
        check(uut.u_rtc.state == R_IDLE || uut.u_rtc.state == 5'd3,
              $sformatf("ROB-1 rtc_control_2 state %0d (from %s) returns to IDLE (now %0d)", bad, nm, uut.u_rtc.state));
        check(n_trig == t0, $sformatf("ROB-1 rtc_control_2 state %0d: no rtc_trig on the way", bad));
        check(n_wr == w0, $sformatf("ROB-1 rtc_control_2 state %0d: no FIFO write on the way", bad));
        check(!uut.u_rtc.fsm_psel || uut.u_rtc.state != R_IDLE, "ROB-1 rtc_control_2: PL031 bus released");
        // sampling resumes: the re-arm reads the time again and the next alarm fires
        t1 = n_trig;
        begin int g = 0; while (n_trig == t1 && g < 2000) begin cyc(1); g++; end end
        check(n_trig > t1, $sformatf("ROB-1 rtc_control_2 state %0d: autonomous sampling resumes", bad));
    endtask

    // Force the sampling FSM to the unused encoding 7 for one cycle.
    task automatic upset_fsm(input logic [2:0] when, input string nm);
        bit ok;
        int unsigned w0, w1;
        if (when == F_IDLE) wait_fsm(F_IDLE, 2000, ok);
        else begin wr(A_TRIG, 32'h1); wait_fsm(when, 2000, ok); end
        check(ok, {"ROB-1 precondition: sampling FSM in ", nm});
        w0 = n_wr;
        force uut.u_ctrl.state = 3'd7;
        #0.1;
        check(!uut.adc_en && !uut.fifo_write_en, {"ROB-1 wrapper_control_2 state 7 (from ", nm, "): adc_en and fifo_write_en low"});
        cyc(1);
        release uut.u_ctrl.state;
        cyc(2);
        check(uut.u_ctrl.state == F_IDLE || uut.u_ctrl.state == 3'd1,
              $sformatf("ROB-1 wrapper_control_2 state 7 (from %s) returns to IDLE (now %0d)", nm, uut.u_ctrl.state));
        check(n_wr == w0, {"ROB-1 wrapper_control_2 state 7 (from ", nm, "): no FIFO write"});
        // sampling resumes: a manual trigger gives one sample
        wait_fsm(F_IDLE, 3000, ok);
        cyc(300);                                   // any back-to-back conversion finishes
        w1 = n_wr;
        wr(A_TRIG, 32'h1);
        begin int g = 0; while (n_wr == w1 && g < 3000) begin cyc(1); g++; end end
        check(n_wr == w1 + 1, {"ROB-1 wrapper_control_2 state 7 (from ", nm, "): sampling resumes"});
        wr(A_FCLR, 32'h1);
    endtask

    initial begin
        cyc(5); nPOR = 1; cyc(2); PRESETn = 1; cyc(5);
        begin bit ok; wait_rtc(R_WAITING, 5000, ok); check(ok, "first arm completes"); end
        upset_rtc(5'd15, R_WAITING, "S_WAITING");
        upset_rtc(5'd31, R_WAITING, "S_WAITING");
        upset_rtc(5'd15, 5'd6,      "S_MATCH_SETUP");
        upset_rtc(5'd31, 5'd12,     "S_ICR_ACCESS");
        wr(A_ALARM, 32'd100);                       // keep the RTC out of the FSM cases below
        begin int g = 0; while (g < 2000 && uut.u_rtc.armed_offset != 100) begin cyc(1); g++; end end
        upset_fsm(F_IDLE,  "S_IDLE");
        upset_fsm(3'd3,    "S_WAIT_START");
        upset_fsm(F_WDONE, "S_WAIT_DONE");
        $display("\n=== SENS-ROB: %0d PASSED, %0d FAILED ===", pass_count, fail_count);
        $finish;
    end
    initial begin
        #200_000_000;
        $display("WATCHDOG TIMEOUT");
        $display("\n=== SENS-ROB: %0d PASSED, %0d FAILED (TIMEOUT) ===", pass_count, fail_count + 1);
        $finish;
    end
endmodule
