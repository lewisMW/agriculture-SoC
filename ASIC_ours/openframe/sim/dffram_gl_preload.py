#!/usr/bin/env python3
"""dffram_gl_preload.py -- backdoor access to the storage latches of ChipFoundry's
pre-hardened DFFRAM blocks when their gate netlists are simulated.

In the gate netlist (OL-DFFRAM hdl/gl) every bit is one sky130_fd_sc_hd__dlxtp_1:
    \\RAM.SLICE_16[s].RAM16.SLICE[t].RAM8.WORD[w].W.BYTE[b].B.BIT[i].genblk1.STORAGE
with word address 16*s + 8*t + w and bit 8*b + i (hdl/rtl/DFFRAM.v). The cell
model keeps its state on the UDP output buf_Q, so a $deposit there sets the bit.

Usage: dffram_gl_preload.py <out.vh> <name>=<instance path>:<words> ...
For each argument the file gets two tasks, to be included in the scope the paths
are written from:
    of_dep_<name>(a, d)    deposit the 32-bit word d at word address a
    of_peek_<name>(a, d)   read word a back from the latches
"""
import sys


def latch(path, a, j):
    s, t, w, b, i = a >> 4, (a >> 3) & 1, a & 7, j >> 3, j & 7
    return ("%s.\\RAM.SLICE_16[%d].RAM16.SLICE[%d].RAM8.WORD[%d].W.BYTE[%d].B.BIT[%d].genblk1.STORAGE .buf_Q"
            % (path, s, t, w, b, i))


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    out = [
        "// written by dffram_gl_preload.py: backdoor to the DFFRAM gate netlists' latches",
    ]
    for arg in sys.argv[2:]:
        name, rest = arg.split("=", 1)
        path, words = rest.rsplit(":", 1)
        words = int(words)
        if words not in (128, 256, 512):
            sys.exit("%s: %d words is not a pre-hardened DFFRAM size" % (name, words))
        out.append("task of_dep_%s(input integer a, input [31:0] d);" % name)
        out.append("  case (a)")
        for a in range(words):
            out.append("    %d: begin" % a)
            for j in range(32):
                out.append("      $deposit(%s, d[%d]);" % (latch(path, a, j), j))
            out.append("    end")
        out.append("    default: $display(\"[OPENFRAME] ERROR: of_dep_%s: no word %%0d\", a);" % name)
        out.append("  endcase")
        out.append("endtask")
        out.append("task of_peek_%s(input integer a, output [31:0] d);" % name)
        out.append("  case (a)")
        for a in range(words):
            bits = ", ".join(latch(path, a, j) for j in range(31, -1, -1))
            out.append("    %d: d = {%s};" % (a, bits))
        out.append("    default: d = 32'hx;")
        out.append("  endcase")
        out.append("endtask")
    with open(sys.argv[1], "w") as f:
        f.write("\n".join(out) + "\n")


if __name__ == "__main__":
    main()
