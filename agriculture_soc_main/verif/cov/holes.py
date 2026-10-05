#!/usr/bin/env python3
"""holes.py - per-coverpoint functional-coverage table + list of unhit bins.

Usage:  python3 holes.py merged.dat [--all]

Reads a Verilator coverage.dat (any number of merged runs) and, for every
covergroup coverpoint / cross:
  * prints covered/total over the NORMAL bins only - ignore_bins and
    illegal_bins are excluded from the denominator (verilator_coverage's own
    summary counts them, which under-reports coverage);
  * lists every normal bin with a zero count (the "holes" - what the next
    test should target);
  * flags any illegal bin with a non-zero count as an ERROR.
Exit status is 1 if an illegal bin was hit, else 0.
"""
import re
import sys
from collections import OrderedDict

LINE = re.compile(r"^C '(.*)' (\d+)\s*$")


def parse(path):
    with open(path, encoding="latin-1") as f:
        for raw in f:
            m = LINE.match(raw)
            if not m:
                continue
            fields = {}
            for kv in m.group(1).split("\x01"):
                if "\x02" in kv:
                    k, v = kv.split("\x02", 1)
                    fields[k] = v
            if fields.get("t") != "covergroup":
                continue
            yield fields, int(m.group(2))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    show_all = "--all" in sys.argv
    groups = OrderedDict()   # "cg.cp" -> {"bins": {name: count}, "illegal": {...}}
    for fields, count in parse(sys.argv[1]):
        hier = fields.get("h", "")
        point, _, binname = hier.rpartition(".")
        g = groups.setdefault(point, {"bins": OrderedDict(), "illegal": {}, "ignore": 0})
        kind = fields.get("bin_type", "normal")
        if kind == "ignore":
            g["ignore"] += 1
        elif kind == "illegal":
            g["illegal"][binname] = g["illegal"].get(binname, 0) + count
        else:
            g["bins"][binname] = g["bins"].get(binname, 0) + count

    errors = 0
    tot_cov = tot_all = 0
    print(f"{'coverpoint / cross':55s} {'covered':>9s}  {'pct':>6s}")
    print("-" * 74)
    for point, g in groups.items():
        bins = g["bins"]
        covered = sum(1 for c in bins.values() if c > 0)
        total = len(bins)
        tot_cov += covered
        tot_all += total
        pct = 100.0 * covered / total if total else 100.0
        print(f"{point:55s} {covered:4d}/{total:<4d}  {pct:5.1f}%")
        holes = [b for b, c in bins.items() if c == 0]
        shown = holes if show_all else holes[:12]
        for b in shown:
            print(f"      HOLE  {b}")
        if len(holes) > len(shown):
            print(f"      ... {len(holes) - len(shown)} more (use --all)")
        for b, c in g["illegal"].items():
            if c > 0:
                errors += 1
                print(f"      ERROR illegal bin '{b}' hit {c} times")
    print("-" * 74)
    pct = 100.0 * tot_cov / tot_all if tot_all else 100.0
    print(f"{'TOTAL (normal bins)':55s} {tot_cov:4d}/{tot_all:<4d}  {pct:5.1f}%")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
