#!/usr/bin/env python3
"""def_pg_labels.py -- Pegasus add_text rules naming the top-level PG nets.

  def_pg_labels.py <design.def[.gz]> [NET ...]  > pg_labels.pvl

A pad-ring chip's supply ports (VDD, VSS, VDDIO, ...) have no pin shape, so
write_stream writes no text for them and the layout's supply nets would be
anonymous: the top cell's PG ports could not be compared. This reads the DEF
SPECIALNETS and, for each PG net (default: every DEF pin with USE POWER or
GROUND), puts one label at the midpoint of one of its special wires, on that
wire's metal label layer (deck names met1_label .. met5_label), preferring
RING, then STRIPE, PADRING and COREWIRE shapes, widest first.

One label per net is enough for LVS to name the net. A second piece of the
same supply that is not connected to the labelled one stays anonymous and
shows up as an extra layout net, which is the point.
"""
import gzip
import re
import sys

PREF = ["RING", "STRIPE", "PADRING", "COREWIRE", "BLOCKWIRE", "FOLLOWPIN"]
METAL = {"met1": "met1_label", "met2": "met2_label", "met3": "met3_label",
         "met4": "met4_label", "met5": "met5_label"}


def main():
    path = sys.argv[1]
    want = set(sys.argv[2:])
    op = gzip.open if path.endswith(".gz") else open
    units = 1000.0
    pg_pins = set()
    best = {}
    section = None
    net = None
    stmt = []
    with op(path, "rt", errors="replace") as f:
        for line in f:
            t = line.split()
            if not t:
                continue
            if t[0] == "UNITS" and len(t) >= 4:
                units = float(t[3])
            if t[0] in ("PINS", "SPECIALNETS") and section is None:
                section = t[0]
                continue
            if t[0] == "END" and len(t) > 1 and t[1] == section:
                section = None
                continue
            if section == "PINS":
                stmt.append(line)
                if ";" in line:
                    s = " ".join(stmt)
                    stmt = []
                    m = re.search(r"^\s*-\s+(\S+).*\+\s*USE\s+(POWER|GROUND)", s)
                    if m:
                        n = re.search(r"\+\s*NET\s+(\S+)", s)
                        pg_pins.add(n.group(1) if n else m.group(1))
            elif section == "SPECIALNETS":
                if t[0] == "-":
                    net = t[1]
                # wire segments: [ROUTED|NEW] layer width [+ SHAPE s] ( x y ) ( x y )
                m = re.search(r"(?:ROUTED|NEW)\s+(met[1-5])\s+(\d+)\s*(?:\+\s*SHAPE\s+(\w+))?\s*"
                              r"\(\s*(-?\d+)\s+(-?\d+)\s*(?:-?\d+\s*)?\)\s*\(\s*(\*|-?\d+)\s+(\*|-?\d+)",
                              line)
                if net and m:
                    lay, w, shape = m.group(1), int(m.group(2)), m.group(3) or ""
                    x1, y1 = int(m.group(4)), int(m.group(5))
                    x2 = x1 if m.group(6) == "*" else int(m.group(6))
                    y2 = y1 if m.group(7) == "*" else int(m.group(7))
                    rank = (PREF.index(shape) if shape in PREF else len(PREF), -w)
                    if net not in best or rank < best[net][0]:
                        best[net] = (rank, lay, (x1 + x2) / 2.0 / units, (y1 + y2) / 2.0 / units, shape)
    nets = sorted(want or pg_pins)
    print("// top-level PG net labels from %s (def_pg_labels.py)" % path)
    for n in nets:
        if n not in best:
            print("// %s: no special wire found in the DEF" % n)
            continue
        _, lay, x, y, shape = best[n]
        print("add_text %s %.4f %.4f %s   // %s %s" % (n, x, y, METAL[lay], lay, shape))
    return 0


if __name__ == "__main__":
    sys.exit(main())
