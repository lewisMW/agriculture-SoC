#!/usr/bin/env python3
"""cov_table.py - covered/total per coverpoint from one or more coverage.dat
files, as "group.point covered/total [holes...]" lines (used to fill the
coverpoint catalogue in coverage_plan.md). viol_* bins are excluded.
Usage: cov_table.py file.dat [file2.dat ...] [--grep cg_sens]"""
import re, sys
from collections import OrderedDict
LINE = re.compile(r"^C '(.*)' (\d+)\s*$")
files = [a for a in sys.argv[1:] if a.endswith('.dat')]
pat = sys.argv[sys.argv.index('--grep') + 1] if '--grep' in sys.argv else ''
pts = OrderedDict()
for fn in files:
    for raw in open(fn, encoding='latin-1'):
        m = LINE.match(raw)
        if not m: continue
        f = dict(kv.split('\x02', 1) for kv in m.group(1).split('\x01') if '\x02' in kv)
        if f.get('t') != 'covergroup': continue
        h = f.get('h', ''); point, _, b = h.rpartition('.')
        if pat and pat not in point: continue
        if f.get('bin_type', 'normal') != 'normal' or b.startswith('viol'): continue
        pts.setdefault(point, OrderedDict())
        pts[point][b] = pts[point].get(b, 0) + int(m.group(2))
for p, bins in pts.items():
    hit = sum(1 for c in bins.values() if c)
    holes = [b for b, c in bins.items() if not c]
    print(f"{p} {hit}/{len(bins)}" + (f"  holes: {', '.join(holes[:8])}{' …' if len(holes) > 8 else ''}" if holes else ""))
