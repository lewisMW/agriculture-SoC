#!/usr/bin/env python3
"""io_timing_summary.py -- tabulate the paths io_timing.tcl wrote.

Usage: io_timing_summary.py <out_dir>      (reads <out_dir>/paths, prints the table)

For each pin, relative to the clock edge AT THE WRAPPER'S CLOCK PIN (GPIO 38; GPIO
20 for the debug port), in ns:
  outputs  valid by   = clock network delay to the launching flop + data path, latest
           holds till = the same, earliest (the output cannot change before this)
  inputs   setup      = data path + the flop's setup time - clock network delay
                        (negative: the pin may change that long after the edge)
           hold       = clock network delay + the flop's hold time - data path
                        (positive: the pin must be held that long after the edge)
each the worse of the slow and the fast corner.
The frame's pads come on top of this: the clock's input buffer delays the edge, an
input pin's buffer delays the data by about as much, an output pin's driver adds
its delay into the load on the board.
"""
import collections
import os
import re
import sys


def source_latency(path):
    """the launching clock's source latency in a full report (second column)"""
    try:
        text = open(path, errors="replace").read()
    except OSError:
        return 0.0
    m = re.search(r"^\s*Src Latency:\+\s*(-?[\d.]+)\s+(-?[\d.]+)", text, re.M)
    return float(m.group(2)) if m else 0.0


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    d = os.path.join(sys.argv[1], "paths")
    if not os.path.isfile(f"{d}/paths.txt"):
        sys.exit(f"no {d}/paths.txt")
    src = {}                                # (clock, view) -> source latency
    out = collections.defaultdict(dict)     # (port, clock) -> {late: t, early: t}
    inp = collections.defaultdict(dict)     # (port, clock) -> {late: setup, early: hold}
    pt = collections.defaultdict(dict)      # (from, to) -> {late: d, early: d}
    for line in open(f"{d}/paths.txt"):
        f = line.split()
        if len(f) < 8:
            continue
        kind, view, start, end = f[0], f[1], f[2], f[3]
        delay, chk, cap, launch = (float(x) if x not in ("", "NA") else 0.0 for x in f[4:8])
        lclk = f[8] if len(f) > 8 else ""
        cclk = f[9] if len(f) > 9 else ""
        for c in (lclk, cclk):
            if c and (c, view) not in src:
                src[(c, view)] = source_latency(f"{d}/sample_{c}_{view}.txt")
        side = "late" if kind.endswith("late") else "early"
        pick = max if side == "late" else min
        if start.startswith("gpio_in[") and end.startswith("gpio_o"):
            k = (start, end)
            pt[k][side] = pick(pt[k].get(side, delay), delay)
        elif kind.startswith("out_") and lclk:
            t = (launch - src.get((lclk, view), 0.0)) + delay
            k = (end, lclk)
            out[k][side] = pick(out[k].get(side, t), t)
        elif kind.startswith("in_") and start.startswith("gpio_in[") and cclk:
            net = cap - src.get((cclk, view), 0.0)
            t = delay + chk - net if side == "late" else net + chk - delay
            k = (start, cclk)
            inp[k][side] = max(inp[k].get(side, t), t)

    def fmt(x):                             # a side the constraints do not time is left blank
        return f"{x:7.2f}" if x is not None else "      -"

    def num(port):
        return int(re.search(r"\[(\d+)\]", port).group(1))

    for clock, pin in (("clk", "GPIO 38"), ("swdclk", "GPIO 20")):
        rows = sorted(((p, v) for (p, c), v in out.items() if c == clock), key=lambda r: (num(r[0]), r[0]))
        if rows:
            print(f"Outputs, after the clock edge at {pin} (ns)            valid by          may change from")
            for p, v in rows:
                print(f"  {p:<52}{fmt(v.get('late'))}           {fmt(v.get('early'))}")
            print(f"  all {len(rows)}: valid by {max(v.get('late', 0) for _, v in rows):.2f} at the latest, "
                  f"change from {min(v.get('early', 99) for _, v in rows):.2f} at the earliest\n")
        rows = sorted(((p, v) for (p, c), v in inp.items() if c == clock), key=lambda r: num(r[0]))
        if rows:
            print(f"Inputs, against the clock edge at {pin} (ns)              setup             hold")
            for p, v in rows:
                print(f"  {p:<52}{fmt(v.get('late'))}           {fmt(v.get('early'))}")
            su = [v['late'] for _, v in rows if 'late' in v]
            ho = [v['early'] for _, v in rows if 'early' in v]
            print(f"  all {len(rows)}: setup at most {fmt(max(su) if su else None).strip()}, "
                  f"hold at most {fmt(max(ho) if ho else None).strip()}\n")
    if pt:
        print("Pin to pin (ns)                                           longest           shortest")
        for (a, b), v in sorted(pt.items(), key=lambda r: num(r[0][1])):
            if len(v) == 2:
                print(f"  {a + ' -> ' + b:<52}{v['late']:7.2f}           {v['early']:7.2f}")


if __name__ == "__main__":
    main()
