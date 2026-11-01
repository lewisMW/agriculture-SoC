#!/usr/bin/env python3
"""Copy a Verilog file, dropping net declarations that repeat an earlier one.

HARNESS ONLY. nanosoc/system/src/accelerator_subsystem.v (commit 325a0b7)
declares PWDATA, PWRITE, PRDATA, PADDR, PREADY, PSEL, PENABLE, PSLVERR, PSTRB,
PPROT and APBACTIVE twice. Verilator and iverilog both reject that
("Duplicate declaration"), so the harness compiles a de-duplicated copy written
to the build directory. The RTL in the repo is NOT modified. Once the RTL is
fixed this script becomes a no-op. See coverage_plan.md finding F1.

Usage: dedupe_decls.py <in.v> <out.v>
"""
import re
import sys

DECL = re.compile(r"^\s*(wire|reg|logic)\b[^;=]*?\b([A-Za-z_]\w*)\s*;\s*(//.*)?$")


def main():
    src, dst = sys.argv[1], sys.argv[2]
    seen, out, dropped = set(), [], []
    for line in open(src, encoding="latin-1"):
        if re.match(r"^\s*module\b", line):
            seen = set()
        m = DECL.match(line)
        if m:
            name = m.group(2)
            if name in seen:
                dropped.append(name)
                out.append("// [dedupe_decls.py] dropped duplicate: " + line.lstrip())
                continue
            seen.add(name)
        out.append(line)
    with open(dst, "w") as fh:
        fh.writelines(out)
    print(f"dedupe_decls: {src} -> {dst}: dropped {len(dropped)} duplicate declaration(s)"
          + (f" ({', '.join(dropped)})" if dropped else ""))


if __name__ == "__main__":
    main()
