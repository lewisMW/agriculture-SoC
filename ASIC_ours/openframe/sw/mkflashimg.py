#!/usr/bin/env python3
"""mkflashimg.py -- wrap a program for the OpenFrame boot ROM's flash loader.

The boot ROM (bootrom/of_boot.c) copies a program from the development board's
SPI flash into the instruction memory when the flash starts with this header
(32-bit words, little-endian):
    +0   0x434F534E ("NSOC")
    +4   n      length of the program in bytes (padded here to a multiple of 4)
    +8   sum    32-bit sum of the program's words
    +12  ~n
    +16  the program, as it is to stand at 0x20000000

Usage: mkflashimg.py PROGRAM [--bin OUT.bin] [--hex OUT.hex] [--max BYTES]
  PROGRAM   the program: a raw binary (objcopy -O binary), or a hex file with
            one or more bytes per line and optional @address lines (objcopy -O
            verilog, or the testbench's image.hex), chosen by the name ending
            in .hex
  --bin     the flash contents as a binary file, to write to the flash from
            address 0 (for example with flashrom, FLASH_PROG high)
  --hex     the same, one byte per line, for the simulation's flash model
  --max     refuse a program longer than this (default 4096, the instruction
            memory of the OpenFrame build)
"""
import argparse
import struct
import sys


def read_program(path):
    if not path.endswith(".hex"):
        with open(path, "rb") as f:
            return bytearray(f.read())
    data = bytearray()
    addr = 0
    with open(path) as f:
        for line in f:
            for tok in line.split():
                if tok.startswith("@"):
                    addr = int(tok[1:], 16)
                    continue
                if addr >= len(data):
                    data.extend(b"\x00" * (addr + 1 - len(data)))
                data[addr] = int(tok, 16)
                addr += 1
    return data


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("program")
    ap.add_argument("--bin")
    ap.add_argument("--hex")
    ap.add_argument("--max", type=int, default=4096)
    a = ap.parse_args()

    prog = read_program(a.program)
    while len(prog) % 4:
        prog.append(0)
    n = len(prog)
    if n < 8:
        sys.exit("mkflashimg: the program is shorter than a vector table's first two words")
    if n > a.max:
        sys.exit(f"mkflashimg: the program is {n} bytes; the limit is {a.max}")
    words = struct.unpack(f"<{n // 4}I", bytes(prog))
    total = sum(words) & 0xFFFFFFFF
    img = struct.pack("<4I", 0x434F534E, n, total, ~n & 0xFFFFFFFF) + bytes(prog)
    if a.bin:
        with open(a.bin, "wb") as f:
            f.write(img)
    if a.hex:
        with open(a.hex, "w") as f:
            f.write("".join(f"{b:02x}\n" for b in img))
    print(f"mkflashimg: program {n} bytes, sum 0x{total:08x}, flash image {len(img)} bytes")


if __name__ == "__main__":
    main()
