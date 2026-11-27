#!/usr/bin/env python3
"""holes.py - functional-coverage report: HIT / WAIVED / HOLE per covergroup bin.

Usage:  python3 holes.py merged.dat [--all] [--gate] [--waivers FILE] [--kind func|sys]

Reads a Verilator coverage.dat (any number of merged runs) and, for every
covergroup coverpoint / cross:
  * counts the NORMAL bins only - ignore_bins, illegal_bins and viol_* bins are
    not goals (verilator_coverage's own summary counts them);
  * a bin with a zero count is a HOLE unless a waiver in waivers.txt matches
    its "cg.cp.bin" name, in which case it is WAIVED (listed separately);
  * a bin whose name starts with viol_ (or an illegal bin) must never be hit:
    any hit is an ERROR;
  * a waived bin that IS hit is an ERROR too (the waiver's reason is wrong).

Exit status: 1 on any ERROR; with --gate also 1 on any unwaived HOLE.

Waiver file (one per line, '|' separated, '#' comments):
    ID | kind | pattern | reason (with RTL file:line) | approved by
kind 'func' = block-level bins (default here), 'sys' = chip-level bins
(nanosoc/system/verif/cov), 'line'/'branch'/'lint' = read by code_holes.py /
the sign-off script. pattern is an fnmatch glob on "covergroup.coverpoint.bin".
"""
import fnmatch
import os
import re
import sys
from collections import OrderedDict

LINE = re.compile(r"^C '(.*)' (\d+)\s*$")
HERE = os.path.dirname(os.path.abspath(__file__))


def parse(path, want="covergroup"):
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
            if want and fields.get("t") != want:
                continue
            yield fields, int(m.group(2))


def load_waivers(path, kinds):
    """-> list of dicts {id, kind, pattern, reason, approved, used}"""
    out = []
    if not path or not os.path.exists(path):
        return out
    with open(path, encoding="utf-8") as f:
        for n, raw in enumerate(f, 1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            parts = [p.strip() for p in line.split("|")]
            if len(parts) < 5 or not all(parts[:5]):
                print(f"ERROR {path}:{n}: waiver needs 'id | kind | pattern | reason | approved'")
                sys.exit(2)
            if parts[1] in kinds:
                out.append({"id": parts[0], "kind": parts[1], "pattern": parts[2],
                            "reason": parts[3], "approved": parts[4], "used": 0})
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print(__doc__)
        return 2
    show_all = "--all" in sys.argv
    gate = "--gate" in sys.argv
    wfile = os.path.join(HERE, "waivers.txt")
    kind = "func"
    for i, a in enumerate(sys.argv):
        if a == "--waivers":
            wfile = sys.argv[i + 1]
            args = [x for x in args if x != wfile]
        if a == "--kind":
            kind = sys.argv[i + 1]
            args = [x for x in args if x != kind]
    waivers = load_waivers(wfile, (kind,))

    groups = OrderedDict()   # "cg.cp" -> {"bins": {name: count}, "never": {...}}
    for path in args:
        for fields, count in parse(path):
            hier = fields.get("h", "")
            point, _, binname = hier.rpartition(".")
            g = groups.setdefault(point, {"bins": OrderedDict(), "never": OrderedDict()})
            btype = fields.get("bin_type", "normal")
            if btype == "ignore":
                continue
            if btype == "illegal" or binname.startswith("viol_"):
                g["never"][binname] = g["never"].get(binname, 0) + count
            else:
                g["bins"][binname] = g["bins"].get(binname, 0) + count

    errors = holes_n = 0
    tot_hit = tot_waived = tot_all = 0
    waived_rows = []
    print(f"{'coverpoint / cross':52s} {'hit':>5s} {'waived':>6s} {'hole':>5s}  {'pct':>6s}")
    print("-" * 82)
    for point, g in groups.items():
        hit, waived, holes = [], [], []
        for b, c in g["bins"].items():
            name = f"{point}.{b}"
            w = next((w for w in waivers if fnmatch.fnmatchcase(name, w["pattern"])), None)
            if w:
                w["used"] += 1
                if c > 0:
                    errors += 1
                    print(f"      ERROR waived bin '{name}' was hit {c} times (waiver {w['id']} is wrong)")
                waived.append((b, w))
            elif c > 0:
                hit.append(b)
            else:
                holes.append(b)
        goal = len(hit) + len(holes)
        tot_hit += len(hit)
        tot_waived += len(waived)
        tot_all += goal
        holes_n += len(holes)
        pct = 100.0 * len(hit) / goal if goal else 100.0
        if g["bins"]:
            print(f"{point:52s} {len(hit):5d} {len(waived):6d} {len(holes):5d}  {pct:5.1f}%")
        shown = holes if show_all else holes[:12]
        for b in shown:
            print(f"      HOLE  {b}")
        if len(holes) > len(shown):
            print(f"      ... {len(holes) - len(shown)} more (use --all)")
        for b, w in waived:
            waived_rows.append((f"{point}.{b}", w))
        for b, c in g["never"].items():
            if c > 0:
                errors += 1
                print(f"      ERROR must-never-happen bin '{point}.{b}' hit {c} times")
    print("-" * 82)
    pct = 100.0 * tot_hit / tot_all if tot_all else 100.0
    print(f"{'TOTAL (goal bins)':52s} {tot_hit:5d} {tot_waived:6d} {holes_n:5d}  {pct:5.1f}%")
    never = sum(len(g["never"]) for g in groups.values())
    print(f"HIT {tot_hit} / WAIVED {tot_waived} / HOLE {holes_n}   "
          f"(must-never-happen bins watched: {never}, hit: "
          f"{sum(1 for g in groups.values() for c in g['never'].values() if c > 0)})")
    if waived_rows:
        print("\nWAIVED bins:")
        for name, w in waived_rows:
            print(f"      {w['id']:5s} {name}")
        seen = OrderedDict()
        for _, w in waived_rows:
            seen[w["id"]] = w
        for w in seen.values():
            print(f"   [{w['id']}] {w['reason']}  (approved: {w['approved']})")
    for w in waivers:
        if w["used"] == 0:
            print(f"NOTE  waiver {w['id']} pattern '{w['pattern']}' matched no bin in this merge")
    if errors:
        print(f"RESULT: {errors} ERROR(s) - a must-never-happen or wrongly waived bin was hit")
        return 1
    if gate and holes_n:
        print(f"RESULT: {holes_n} unwaived HOLE(s)")
        return 1
    print("RESULT: functional coverage clean" if not holes_n else f"RESULT: {holes_n} hole(s) (not gated)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
