#!/usr/bin/env python3
"""Rewrite an Innovus SDF so that it annotates a flat netlist.

Innovus writes the SDF of a design with its hierarchy: an instance is
`u_a/u_b/g123`, with `/` as the hierarchy divider. `write_netlist -flat` writes
the same instance as one escaped identifier, `\\u_a/u_b/g123 `, in which `/` is
part of the name. A simulator then looks for a child instance `u_a`, does not
find it, and silently leaves every such cell and wire without its delay (one
SDFINF warning per block, not per instance).

This escapes the `/` inside instance names (`u_a\\/u_b\\/g123`), which is how
SDF spells a name that contains the divider. Pin separators are left alone.

With a third argument, a regular expression, the CELL entries whose CELLTYPE
matches it are left out: used when a macro is simulated as its own gate netlist,
which has no delays of its own at the macro's boundary to annotate (its SDF is
applied separately). The wire delays to and from the macro's pins are kept.

Usage: sdf_flat_names.py <in.sdf> <out.sdf> [<celltype regex to drop>]
"""
import re
import sys

UNESC_SLASH = re.compile(r"(?<!\\)/")
INSTANCE = re.compile(r"^(\s*\(INSTANCE\s+)([^\s)]+)(\s*\).*)$")
INTERCONNECT = re.compile(r"^(\s*\(INTERCONNECT\s+)(\S+)(\s+)(\S+)(.*)$")


def esc_instance(path):
    return UNESC_SLASH.sub(r"\\/", path)


def esc_pin(path):
    """`inst/path/pin`: escape every divider except the last, which separates the pin."""
    parts = UNESC_SLASH.split(path)
    if len(parts) <= 2:
        return path                      # a top-level port, or instance/pin
    return r"\/".join(parts[:-1]) + "/" + parts[-1]


CELL_START = re.compile(r"^\s*\(CELL\s*$")
CELLTYPE = re.compile(r'\(CELLTYPE\s+"([^"]+)"')


def rewrite(line, count):
    m = INSTANCE.match(line)
    if m:
        new = esc_instance(m.group(2))
        count[0] += new != m.group(2)
        return m.group(1) + new + m.group(3) + "\n"
    m = INTERCONNECT.match(line)
    if m:
        a, b = esc_pin(m.group(2)), esc_pin(m.group(4))
        count[1] += (a != m.group(2)) or (b != m.group(4))
        return m.group(1) + a + m.group(3) + b + m.group(5) + "\n"
    return line


def main():
    if len(sys.argv) not in (3, 4):
        sys.exit(__doc__)
    drop = re.compile(sys.argv[3]) if len(sys.argv) == 4 else None
    count = [0, 0]
    n_drop = 0
    with open(sys.argv[1], encoding="utf-8", errors="replace") as fin, \
         open(sys.argv[2], "w", encoding="utf-8") as fout:
        if drop is None:
            for line in fin:
                fout.write(rewrite(line, count))
        else:
            # A CELL entry is read whole before it is written or dropped. The
            # design's own entry (the wire delays) comes first and is large;
            # every other entry is a few lines.
            cell, depth = None, 0
            for line in fin:
                if cell is None:
                    if CELL_START.match(line):
                        cell, depth = [line], line.count("(") - line.count(")")
                    else:
                        fout.write(rewrite(line, count))
                    continue
                cell.append(line)
                depth += line.count("(") - line.count(")")
                if depth <= 0:
                    m = next((CELLTYPE.search(l) for l in cell[:4] if CELLTYPE.search(l)), None)
                    if m and drop.search(m.group(1)):
                        n_drop += 1
                    else:
                        for l in cell:
                            fout.write(rewrite(l, count))
                    cell = None
            if cell is not None:
                for l in cell:
                    fout.write(rewrite(l, count))
    print("sdf_flat_names: %d instance names and %d interconnects rewritten%s"
          % (count[0], count[1], (", %d cell entries dropped" % n_drop) if drop else ""))


if __name__ == "__main__":
    main()
