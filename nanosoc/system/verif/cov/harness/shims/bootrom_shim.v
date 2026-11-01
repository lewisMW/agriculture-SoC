// -----------------------------------------------------------------------------
// bootrom_shim.v  —  HARNESS ONLY (compile-check of the coverage models).
//
// The checked-in nanosoc/system/src/bootrom/verilog/bootrom.v (listed in
// flist/project/system.flist) is a STALE generator output: its ports are
// CLK/EN/W_ADDR[7:0]/RDATA, but its only instantiation (nanosoc_bootrom_cpu_0)
// connects clk/en/word_addr/out_data. The flow's `make bootrom` step writes the
// current template output to bootrom.sv instead (lower-case ports). This shim
// has the template's port list so the system elaborates here; it returns a
// fixed "b ." (0xE7FE) pattern - there is no bootloader image in it.
// See coverage_plan.md finding F2.
// -----------------------------------------------------------------------------
module bootrom #(
    parameter ADDR_W = 9
)(
    input  wire              clk,
    input  wire              en,
    input  wire [ADDR_W-1:0] word_addr,
    output reg  [31:0]       out_data
);
    always @(posedge clk)
        if (en) out_data <= 32'hE7FE_E7FE;
    wire _unused = &{1'b0, word_addr};
endmodule
