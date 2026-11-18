// =====================================================================
// spiflash_model.v -- a small model of the development board's SPI flash, for
// the simulations of the boot ROM's loader and of the programming pass-through.
//
// Plain SPI, mode 0 (data taken on the rising clock edge, put out on the
// falling one, most significant bit first). 64 kbyte of contents, erased
// (0xFF) unless FILE names a hex file of bytes, one a line, from address 0.
// Commands:
//   0x03 read              0x0B fast read (one dummy byte)
//   0x9F JEDEC ID (EF 40 16)
//   0x05 read status       bit 0 busy (never), bit 1 write-enable latch
//   0x06 write enable      0x04 write disable
//   0x02 page program      bits can only go from 1 to 0; wraps within the 256-byte page
//   0x20 sector erase (4 kbyte)      0xC7, 0x60 chip erase
//   0xB9 power down        0xAB release from power down
// In power-down every command but 0xAB is ignored. IO3 is the hold input of a
// part in plain SPI mode: while it is low the part ignores the clock and
// releases its output. IO2 (write protect) is not modelled. Program and erase
// take effect when CSB rises, at once.
// Timing: the output changes TV ns after the falling edge and is released TDIS
// ns after CSB rises.
// =====================================================================
`timescale 1ns/1ps
module spiflash_model #(
  parameter FILE = "",
  parameter real TV = 7.0,
  parameter real TDIS = 9.0
) (
  input  wire csb,
  input  wire clk,
  input  wire io0,     // to the flash
  output wire io1,     // from the flash
  input  wire io2,
  input  wire io3
);
  localparam integer BYTES = 1 << 16;
  reg [7:0] mem [0:BYTES-1];
  integer k;
  initial begin
    for (k = 0; k < BYTES; k = k + 1) mem[k] = 8'hFF;
    if (FILE != "") $readmemh(FILE, mem);
  end

  reg        powered  = 1'b1;
  reg        wel      = 1'b0;
  reg [7:0]  cmd;
  reg [23:0] addr;
  reg [7:0]  shift_in;
  reg [7:0]  shift_out;
  integer    nbits;       // bits taken since CSB fell
  integer    nbytes;      // whole bytes taken since CSB fell
  reg        out_en;
  reg        out_bit;
  reg [7:0]  page [0:255];
  integer    page_n;
  reg [23:0] page_addr;
  integer    reads = 0, programs = 0, erases = 0;   // for the testbench

  wire hold = (io3 === 1'b0);
  wire [23:0] a16 = addr & (BYTES - 1);

  assign #(TV) io1 = (out_en && !hold) ? out_bit : 1'bz;
  wire out_off;
  assign #(TDIS) out_off = csb;

  // what the part answers with, one byte at a time
  function [7:0] next_out_byte (input integer n);
    begin
      case (cmd)
        8'h03, 8'h0B: next_out_byte = mem[a16];
        8'h9F:        next_out_byte = (n % 3 == 0) ? 8'hEF : (n % 3 == 1) ? 8'h40 : 8'h16;
        8'h05:        next_out_byte = {6'b0, wel, 1'b0};
        default:      next_out_byte = 8'hFF;
      endcase
    end
  endfunction

  integer out_n;          // bytes put out in this command
  reg     reading;

  always @(negedge csb) begin
    nbits = 0; nbytes = 0; out_en = 1'b0; reading = 1'b0; out_n = 0; page_n = 0; cmd = 8'h00;
  end

  always @(posedge clk) if (!csb && !hold) begin
    shift_in = {shift_in[6:0], io0};
    nbits = nbits + 1;
    if (nbits % 8 == 0) begin
      nbytes = nbytes + 1;
      if (nbytes == 1) begin
        cmd = shift_in;
        if (!powered && cmd != 8'hAB) cmd = 8'h00;
        if (cmd == 8'h9F || cmd == 8'h05) reading = 1'b1;
      end else if (nbytes <= 4 && (cmd == 8'h03 || cmd == 8'h0B || cmd == 8'h02 || cmd == 8'h20)) begin
        addr = {addr[15:0], shift_in};
        if (nbytes == 4 && cmd == 8'h03) begin reading = 1'b1; reads = reads + 1; end
        if (nbytes == 4 && cmd == 8'h02) page_addr = addr;
      end else if (nbytes == 5 && cmd == 8'h0B) begin
        reading = 1'b1; reads = reads + 1;
      end else if (cmd == 8'h02) begin
        page[page_n % 256] = shift_in;
        page_n = page_n + 1;
      end
    end
  end

  always @(negedge clk) if (!csb && !hold && reading) begin
    if ((nbits % 8) == 0) begin
      shift_out = next_out_byte(out_n);
      out_n = out_n + 1;
      if (cmd == 8'h03 || cmd == 8'h0B) addr = addr + 1;
    end
    out_bit   = shift_out[7];
    shift_out = {shift_out[6:0], 1'b1};
    out_en    = 1'b1;
  end

  always @(posedge out_off) out_en = 1'b0;

  // commands that act when CSB rises on a byte boundary
  integer j;
  reg [23:0] pa;
  always @(posedge csb) if ((nbits % 8) == 0) begin
    case (cmd)
      8'hAB: powered = 1'b1;
      8'hB9: if (nbytes == 1) powered = 1'b0;
      8'h06: if (nbytes == 1) wel = 1'b1;
      8'h04: if (nbytes == 1) wel = 1'b0;
      8'h02: if (wel && nbytes > 4) begin
               // byte j of the data goes to offset j within the page, wrapping; of
               // more than 256 bytes only the last 256 are kept
               for (j = (page_n > 256) ? page_n - 256 : 0; j < page_n; j = j + 1) begin
                 pa = {page_addr[23:8], page_addr[7:0] + j[7:0]} & (BYTES - 1);
                 mem[pa] = mem[pa] & page[j % 256];
               end
               wel = 1'b0; programs = programs + 1;
             end
      8'h20: if (wel && nbytes == 4) begin
               for (j = 0; j < 4096; j = j + 1) mem[({addr[23:12], 12'h000} & (BYTES - 1)) + j] = 8'hFF;
               wel = 1'b0; erases = erases + 1;
             end
      8'hC7, 8'h60: if (wel && nbytes == 1) begin
               for (j = 0; j < BYTES; j = j + 1) mem[j] = 8'hFF;
               wel = 1'b0; erases = erases + 1;
             end
      default: ;
    endcase
  end
endmodule
