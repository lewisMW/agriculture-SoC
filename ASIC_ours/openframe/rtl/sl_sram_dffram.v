//-----------------------------------------------------------------------------
// sl_sram for the OpenFrame wrapper: DFFRAM macros in place of the OpenRAM SRAM.
//
// Same module name and ports as nanosoc/asic_lib_tech/sram/SKY130/verilog/sl_sram.v.
// It is read after that file (Cadence/inputs/custom_hdl_file_list.tcl), so it is
// the definition synthesis keeps. ChipFoundry does not accept OpenRAM macros;
// these are the pre-hardened DFFRAM blocks it distributes (OL-DFFRAM, Apache-2.0,
// fetched by ../fetch_dffram.sh): standard cells only, latch storage, one
// read/write port, synchronous read like an SRAM.
//
// AW is the region's address width in bytes and selects the memory:
//   AW 12   4 kbyte    2 x DFFRAM512x32, ADDR[11] picks one
//   AW 11   2 kbyte    DFFRAM512x32
//   AW 10   1 kbyte    DFFRAM256x32
//   AW  9   512 byte   DFFRAM128x32
// Any other AW instantiates a module that does not exist, which stops
// elaboration: a region must not silently get a memory of another size (the
// OpenRAM wrapper put one 8 kbyte macro behind a 16 kbyte region and dropped
// the top address bit).
//
// The macros hold Do0 while EN0 is low (their output register is clock-gated);
// the bus bridge only looks at RDATA in the cycle after an access.
//-----------------------------------------------------------------------------

module sl_sram #(
  parameter AW = 13
 )
 (
  `ifdef POWER_PINS
  inout  wire          VDD,
  inout  wire          VSS,
  `endif
  input  wire          CLK,
  input  wire [AW-1:2] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,     // byte write enables, active high
  input  wire          CS,
  output wire [31:0]   RDATA
  );

generate
    if (AW == 12) begin : g_4k
        // two 2 kbyte macros; the read data comes from the one the access went to
        wire        hi = ADDR[11];
        reg         hi_q;
        wire [31:0] do_lo, do_hi;
        always @(posedge CLK) if (CS) hi_q <= hi;
        DFFRAM512x32 u_ram_lo (.CLK(CLK), .WE0(WREN), .EN0(CS & ~hi), .A0(ADDR[10:2]), .Di0(WDATA), .Do0(do_lo));
        DFFRAM512x32 u_ram_hi (.CLK(CLK), .WE0(WREN), .EN0(CS &  hi), .A0(ADDR[10:2]), .Di0(WDATA), .Do0(do_hi));
        assign RDATA = hi_q ? do_hi : do_lo;
    end else if (AW == 11) begin : g_2k
        DFFRAM512x32 u_ram (.CLK(CLK), .WE0(WREN), .EN0(CS), .A0(ADDR[10:2]), .Di0(WDATA), .Do0(RDATA));
    end else if (AW == 10) begin : g_1k
        DFFRAM256x32 u_ram (.CLK(CLK), .WE0(WREN), .EN0(CS), .A0(ADDR[9:2]),  .Di0(WDATA), .Do0(RDATA));
    end else if (AW == 9) begin : g_512
        DFFRAM128x32 u_ram (.CLK(CLK), .WE0(WREN), .EN0(CS), .A0(ADDR[8:2]),  .Di0(WDATA), .Do0(RDATA));
    end else begin : g_unsupported
        sl_sram_dffram_has_no_macro_for_this_AW u_stop ();
    end
endgenerate

endmodule
