#!/usr/bin/env python3
"""
foms.py RUN.rdb OUTDIR  -- write every scalar Maestro output (SINAD, ENOB, SFDR,
THD, IMD, H1, ...) of every design point to one CSV per test:

    OUTDIR/<test>/foms.csv    point, <design variables...>, <scalar outputs...>

`point` is the design point number, the same N as the pt<N> folders that
export_sine.ocn writes, so each row lines up with its waveforms. Waveform outputs
(fft_vout, vout, ...) are left out (exported separately as CSV).

Reads the results database (SQLite) read-only. Standard library only, so it runs
with the VM's python3.
"""
import csv
import os
import sqlite3
import sys


def number(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def main(rdb, outdir):
    con = sqlite3.connect("file:%s?mode=ro" % os.path.abspath(rdb), uri=True)
    q = con.execute
    point_no = dict(q("select pointID, designPointNumber from point"))
    params = {}
    for pid, name, val in q("select pv.pointID, pa.name, pv.value from parameterValue pv "
                            "join parameter pa using(parameterID)"):
        params.setdefault(pid, {})[name] = val
    pnames = sorted({n for d in params.values() for n in d})

    for test_id, test in q("select testID, name from test order by sequence").fetchall():
        rows, rnames = {}, []
        for pid, name, val in q("select rv.pointID, r.name, rv.value from resultValue rv "
                                "join result r using(resultID) where r.testID = ? "
                                "order by r.resultOrder", (test_id,)):
            x = number(val)
            if x is None:                      # waveform or error
                continue
            if name not in rnames:
                rnames.append(name)
            rows.setdefault(pid, {})[name] = x
        if not rows:
            continue
        os.makedirs(os.path.join(outdir, test), exist_ok=True)
        path = os.path.join(outdir, test, "foms.csv")
        with open(path, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["point"] + pnames + rnames)
            for pid in sorted(rows, key=lambda p: point_no.get(p, p)):
                w.writerow([point_no.get(pid, pid)]
                           + [params.get(pid, {}).get(n, "") for n in pnames]
                           + [rows[pid].get(n, "") for n in rnames])
        print("wrote %s (%d points, %d outputs)" % (path, len(rows), len(rnames)))
    con.close()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
