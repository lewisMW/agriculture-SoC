`timescale 1ns/1ps
// tb_sl_ahb_sram_hold.v -- self-checking test of ../rtl/sl_ahb_sram_hold.v with the
// behavioural compiler-block model (dffram_pg_models.v, without USE_POWER_PINS).
// A small AHB-Lite master does 4000 random byte, halfword and word reads and
// writes, back to back and with idle gaps, against a reference array.
//   xrun -timescale 1ns/1ps ../rtl/sl_ahb_sram_hold.v dffram_pg_models.v tb_sl_ahb_sram_hold.v
// Ends with "=== TB_SL_AHB_SRAM_HOLD: N PASSED, M FAILED ===".
module tb_sl_ahb_sram_hold;
    parameter AW = 12;
    reg         HCLK = 0, HRESETn = 0;
    reg         HSEL = 0, HWRITE = 0;
    reg  [1:0]  HTRANS = 0;
    reg  [2:0]  HSIZE = 0;
    reg  [AW-1:0] HADDR = 0;
    reg  [31:0] HWDATA = 0;
    wire        HREADYOUT, HRESP;
    wire [31:0] HRDATA;
    wire        HREADY = HREADYOUT;          // the only slave
    always #15 HCLK = ~HCLK;

    sl_ahb_sram #(.RAM_ADDR_W(AW)) dut (.HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HREADY(HREADY), .HTRANS(HTRANS),
        .HSIZE(HSIZE), .HWRITE(HWRITE), .HADDR(HADDR), .HWDATA(HWDATA), .HREADYOUT(HREADYOUT), .HRESP(HRESP), .HRDATA(HRDATA));

    reg [7:0] ref_mem [0:(1<<AW)-1];
    reg       ref_def [0:(1<<AW)-1];         // byte has been written
    integer pass = 0, fail = 0, i, seed = 32'h5eed, n_rd = 0, n_wr = 0, n_b2b = 0, n_cross = 0;

    // the data phase of the transfer accepted on the previous edge
    reg          d_valid = 0, d_write;
    reg [AW-1:0] d_addr;
    reg [2:0]    d_size;
    reg [31:0]   d_wdata;
    reg [AW-1:0] last_rd_addr = 0;
    integer      k, nb;
    reg [31:0]   exp, mask;

    task drive_next;                        // put a new address phase (or idle) on the bus
        integer r;
        begin
            r = {$random(seed)} % 100;
            if (r < 20) begin HTRANS <= 2'b00; HSEL <= 1'b1; end          // idle
            else begin
                HTRANS <= 2'b10; HSEL <= 1'b1;
                HWRITE <= ({$random(seed)} % 100) < 45;
                case ({$random(seed)} % 3)
                    0: begin HSIZE <= 3'b000; HADDR <= {$random(seed)}; end
                    1: begin HSIZE <= 3'b001; HADDR <= {$random(seed)} & ~1; end
                    default: begin HSIZE <= 3'b010; HADDR <= {$random(seed)} & ~3; end
                endcase
            end
        end
    endtask

    always @(posedge HCLK) if (HRESETn && HREADY) begin
        // the transfer whose data phase just ended
        if (d_valid) begin
            nb = 1 << d_size;
            if (d_write) begin
                n_wr = n_wr + 1;
                for (k = 0; k < nb; k = k + 1) begin
                    ref_mem[d_addr + k] = d_wdata[8*((d_addr[1:0] + k) % 4) +: 8];
                    ref_def[d_addr + k] = 1'b1;
                end
            end else begin
                n_rd = n_rd + 1;
                exp = 0; mask = 0;
                for (k = 0; k < nb; k = k + 1) if (ref_def[d_addr + k]) begin
                    exp [8*((d_addr[1:0] + k) % 4) +: 8] = ref_mem[d_addr + k];
                    mask[8*((d_addr[1:0] + k) % 4) +: 8] = 8'hff;
                end
                if ((HRDATA & mask) === exp) pass = pass + 1;
                else begin
                    fail = fail + 1;
                    if (fail <= 10) $display("FAIL [%0t] read %0d bytes at 0x%03h: got 0x%08h, expected 0x%08h (mask 0x%08h)", $time, nb, d_addr, HRDATA, exp, mask);
                end
                if (d_addr[AW-1:6] != last_rd_addr[AW-1:6]) n_cross = n_cross + 1;
                last_rd_addr = d_addr;
            end
        end
        // the address phase that is accepted now becomes the next data phase
        if (HSEL && HTRANS[1]) begin
            if (d_valid) n_b2b = n_b2b + 1;
            d_valid <= 1'b1; d_write <= HWRITE; d_addr <= HADDR; d_size <= HSIZE;
            d_wdata = {$random(seed)};
            HWDATA <= HWRITE ? d_wdata : 32'hdeadbeef;
        end else d_valid <= 1'b0;
        drive_next;
    end

    initial begin
        for (i = 0; i < (1<<AW); i = i + 1) ref_def[i] = 1'b0;
        repeat (4) @(posedge HCLK);
        #1 HRESETn = 1;
        wait (n_rd + n_wr >= 4000);
        @(posedge HCLK);
        $display("    %0d writes, %0d reads (%0d into another 16-word block than the read before), %0d transfers back to back", n_wr, n_rd, n_cross, n_b2b);
        if (HRESP !== 1'b0) fail = fail + 1;
        $display("\n=== TB_SL_AHB_SRAM_HOLD: %0d PASSED, %0d FAILED ===", pass, fail);
        $finish;
    end
    initial begin #50_000_000; $display("WATCHDOG TIMEOUT\n=== TB_SL_AHB_SRAM_HOLD: %0d PASSED, %0d FAILED ===", pass, fail + 1); $finish; end
endmodule
