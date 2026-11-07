#!/usr/bin/env python3
"""density_report.py <drc_run_dir> [<other_drc_run_dir> ...]

Summarises the density RDB files the sky130 deck writes next to a DRC run
(m1_global_low.rdb, m1_local_low.rdb, ...): for each density check, the
number of failing windows and the worst density value (DV) among them.
An empty RDB means the check passed; "-" means no RDB (not run). Given several run
directories (e.g. before and after fill), prints them side by side.
"""
import os, re, sys

CHECKS = [  # rdb file, rule, limit
    ("diff_low_density.rdb", "CDR.diff.local.low", ">= 28% (700um win)"),
    ("diff_high_density.rdb", "CDRW.diff.local.high", "<= 62% (700um win)"),
    ("poly_low_density.rdb", "CDRW.poly.local.low", ">= 8% (700um win)"),
    ("poly_high_density.rdb", "CDRW.poly.local.high", "<= 38% (700um win)"),
    ("li_global_low.rdb", "CDRW.li.global.min", ">= 33% global"),
    ("li_global_high.rdb", "CDRW.li.global.max", "<= 62% global"),
] + [(f, r, lim) for n in range(1, 6) for f, r, lim in (
    ("m%d_global_low.rdb" % n, "CDRW.m%d.global.min" % n, ">= %s global" % ("43%" if n == 5 else "33%")),
    ("m%d_global_high.rdb" % n, "CDRW.m%d.global.max" % n, "<= %s global" % ("78%" if n == 5 else "62%")),
    ("m%d_local_low.rdb" % n, "CDR.m%d.local.min" % n, ">= 80% oxide (700um win)"),
)]

def read(path):
    if not os.path.exists(path):
        return "missing"
    if os.path.getsize(path) == 0:
        return None
    dv = [float(m.group(1)) for m in re.finditer(r"^DV\s+([-0-9.eE]+)", open(path).read(), re.M)]
    return dv

def cell(dv, low):
    if dv == "missing":
        return "-"
    if dv is None:
        return "pass"
    if not dv:
        return "FAIL"
    worst = min(dv) if low else max(dv)
    return "FAIL %d win, %s %.1f%%" % (len(dv), "min" if low else "max", 100 * worst)

def main(dirs):
    if not dirs:
        print(__doc__); return 2
    hdr = "%-22s %-26s" % ("rule", "limit") + "".join(" %-30s" % os.path.basename(os.path.normpath(d))[:30] for d in dirs)
    print(hdr); print("-" * len(hdr))
    for f, rule, lim in CHECKS:
        if all(not os.path.exists(os.path.join(d, f)) for d in dirs):
            continue
        low = ">=" in lim
        print("%-22s %-26s" % (rule, lim) + "".join(" %-30s" % cell(read(os.path.join(d, f)), low) for d in dirs))
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
