#!/usr/bin/env python3
"""chip_lvs_nets.py -- which top-level layout nets the pins of chosen cells sit
on, read from the extracted layout netlist Pegasus writes (-spice <top>.spi).

  chip_lvs_nets.py <top>.spi <top> CELL [CELL ...]

For every placement of each CELL (typically a black box: sar_afe, an IO pad)
it prints the instance path, its placement ($X/$Y from the netlist) and, per
pin, the top-level net: a label name where the layout has one (VDD, P0[3],
...) or Pegasus's net number. Nets that also reach a pin of another listed
cell are cross-referenced, e.g. "vinp -> 1234 (= sky130_ef_io__analog_pad
X56/X0 P_CORE)". This is what the layout says, independent of the netlist.
"""
import collections
import re
import sys


def read_spi(path):
    subs = {}
    cur = None
    line_buf = ""

    def handle(line):
        nonlocal cur
        t = line.split()
        if not t:
            return
        low = t[0].lower()
        if low == ".subckt":
            cur = {"pins": t[2:], "inst": []}
            subs[t[1]] = cur
        elif low == ".ends":
            cur = None
        elif cur is not None and t[0][0] in "Xx":
            # Xname n1 n2 ... MASTER [$T=...] [$X=..] [$Y=..]
            toks = []
            for x in t[1:]:
                if x.startswith("$"):
                    break           # $T=x y r m, $X=, $Y= follow the master
                toks.append(x)
            attrs = dict(re.findall(r"\$(\w+)=(\S+)", line))
            pos = re.search(r"\$X=(\S+)\s+\$Y=(\S+)", line)
            cur["inst"].append((t[0], toks[:-1], toks[-1],
                                (pos.group(1), pos.group(2)) if pos else None))

    with open(path, errors="replace") as f:
        for raw in f:
            raw = raw.rstrip("\n")
            if raw.startswith("+"):
                line_buf += " " + raw[1:]
                continue
            if line_buf:
                handle(line_buf)
            line_buf = "" if raw.startswith("*") else raw
    if line_buf:
        handle(line_buf)
    return subs


def main():
    spi, top, cells = sys.argv[1], sys.argv[2], set(sys.argv[3:])
    subs = read_spi(spi)
    if top not in subs:
        sys.exit("no subckt %s in %s" % (top, spi))
    found = []   # (cell, path, xy, {pin: topnet})

    def walk(name, netmap, path, depth=0):
        for iname, nets, master, xy in subs[name]["inst"]:
            if master not in subs:
                continue
            pins = subs[master]["pins"]
            m = {p: netmap.get(n, "%s/%s" % ("/".join(path), n) if path else n)
                 for p, n in zip(pins, nets)}
            if master in cells:
                found.append((master, "/".join(path + [iname]), xy, m))
            elif depth < 50:
                # nets local to master: pins map to parent nets
                walk(master, m, path + [iname], depth + 1)

    walk(top, {p: p for p in subs[top]["pins"]}, [])
    # nets of the top cell that are not pins keep their local name
    users = collections.defaultdict(list)
    for c, p, xy, m in found:
        for pin, n in m.items():
            users[n].append("%s %s %s" % (c, p, pin))
    for c, p, xy, m in sorted(found, key=lambda x: (x[0], x[1])):
        print("%s  %s  at %s" % (c, p, "(%s, %s)" % xy if xy else "?"))
        for pin in sorted(m):
            n = m[pin]
            others = [u for u in users[n] if not u.startswith("%s %s " % (c, p))]
            print("    %-10s -> %-12s %s" % (pin, n, ("(= " + "; ".join(others[:4]) +
                                                       (" ..." if len(others) > 4 else "") + ")")
                                             if others else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
