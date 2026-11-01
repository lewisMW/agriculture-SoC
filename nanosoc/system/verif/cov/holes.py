#!/usr/bin/env python3
"""holes.py - per-coverpoint functional-coverage table + list of unhit bins.

Usage:  python3 holes.py merged.dat [--all] [--prefix nsc_]

Derived from agriculture_soc_main/verif/cov/holes.py. Reads a Verilator
coverage.dat (any number of merged runs) and, for every covergroup coverpoint /
cross:
  * prints covered/total over the NORMAL bins only - ignore_bins, illegal_bins
    and "violation" bins are excluded from the denominator;
  * lists every normal bin with a zero count (the "holes");
  * flags as ERROR any illegal bin, or any bin whose name starts with "viol_",
    that has a non-zero count. The nanosoc models use viol_* bins instead of
    illegal_bins because a hit illegal bin $stops a Verilator run before the
    coverage file is written.
  * lists `cover property` points (Verilator type "user") that were never hit.
--prefix keeps only covergroups whose hierarchical name contains the string.
Exit status is 1 if a violation/illegal bin was hit, else 0.
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
            yield fields, int(m.group(2))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    show_all = "--all" in sys.argv
    prefix = None
    if "--prefix" in sys.argv:
        prefix = sys.argv[sys.argv.index("--prefix") + 1]
    groups = OrderedDict()
    props = OrderedDict()
    for fields, count in parse(sys.argv[1]):
        kind_t = fields.get("t")
        hier = fields.get("h", "")
        if prefix and prefix not in hier and prefix not in fields.get("page", ""):
            continue
        if kind_t == "user":
            key = f"{hier}:{fields.get('o', '')}@{fields.get('f', '')}:{fields.get('l', '')}"
            props[key] = props.get(key, 0) + count
            continue
        if kind_t != "covergroup":
            continue
        point, _, binname = hier.rpartition(".")
        g = groups.setdefault(point, {"bins": OrderedDict(), "illegal": {}, "ignore": 0})
        kind = fields.get("bin_type", "normal")
        if kind == "ignore":
            g["ignore"] += 1
        elif kind == "illegal" or binname.startswith("viol_") or "_x_viol_" in binname \
                or binname.startswith("viol"):
            g["illegal"][binname] = g["illegal"].get(binname, 0) + count
        else:
            g["bins"][binname] = g["bins"].get(binname, 0) + count

    errors = 0
    tot_cov = tot_all = 0
    print(f"{'coverpoint / cross':62s} {'covered':>9s}  {'pct':>6s}")
    print("-" * 81)
    for point, g in groups.items():
        bins = g["bins"]
        covered = sum(1 for c in bins.values() if c > 0)
        total = len(bins)
        tot_cov += covered
        tot_all += total
        pct = 100.0 * covered / total if total else 100.0
        print(f"{point:62s} {covered:4d}/{total:<4d}  {pct:5.1f}%")
        holes = [b for b, c in bins.items() if c == 0]
        shown = holes if show_all else holes[:12]
        for b in shown:
            print(f"      HOLE  {b}")
        if len(holes) > len(shown):
            print(f"      ... {len(holes) - len(shown)} more (use --all)")
        for b, c in g["illegal"].items():
            if c > 0:
                errors += 1
                print(f"      ERROR violation bin '{b}' hit {c} times")
    print("-" * 81)
    pct = 100.0 * tot_cov / tot_all if tot_all else 100.0
    print(f"{'TOTAL (normal bins)':62s} {tot_cov:4d}/{tot_all:<4d}  {pct:5.1f}%")
    if props:
        hit = sum(1 for c in props.values() if c > 0)
        print(f"{'cover property points':62s} {hit:4d}/{len(props):<4d}")
        for k, c in props.items():
            if c == 0 or show_all:
                print(f"      {'HOLE ' if c == 0 else 'hit  '} {k}  ({c})")
    if errors:
        print(f"*** {errors} violation bin(s) hit - see ERROR lines above ***")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
