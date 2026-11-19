#!/usr/bin/env python3
"""code_holes.py - line + branch coverage gate for the six sensing RTL files.

Usage:  python3 code_holes.py merged_code.dat [--gate] [--waivers FILE] [--all]

Verilator reports coverage points per INSTANCE, so the same source line shows
as covered in one bench and uncovered in another. This script takes the UNION:
a point is covered when any instance in any merged run executed it.

  line    a source line is counted when at least one coverage point's range
          includes it; it is covered when one of those points was executed
          (so a statement inside a never-taken branch is uncovered).
  branch  every if / else / ?: arm reported by Verilator ("t=branch"), keyed by
          file:line:column:kind.
  toggle  printed for information only (not gated).

Only these files are gated (anything else in the build is ignored):
  adc_apb_wrapper_rev2.v  rtc_control_2.v  wrapper_control_2.v
  fifo_apb_adc.v  sar_adc.v  sarlogic/functional/verilog.v
`ifdef SENSING_DEBUG / SENSING_CHECK blocks are never compiled in these builds,
so they produce no points.

Waivers (waivers.txt):  ID | line   | <file>:<line>        | reason | approved
                        ID | branch | <file>:<line>[:kind] | reason | approved
A waived line/branch that IS covered is an ERROR (stale waiver).
Exit status: 1 on ERROR; with --gate also on any unwaived uncovered item.
"""
import os
import sys
from collections import OrderedDict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from holes import parse, load_waivers  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))

# gated file -> short name used in reports and waivers
FILES = OrderedDict([
    ("Wrapper/adc_apb_wrapper_rev2.v", "adc_apb_wrapper_rev2.v"),
    ("RTC/rtc_control_2.v", "rtc_control_2.v"),
    ("FSM/wrapper_control_2.v", "wrapper_control_2.v"),
    ("FIFO/fifo_apb_adc.v", "fifo_apb_adc.v"),
    ("ADC/sar_adc.v", "sar_adc.v"),
    ("sarlogic/functional/verilog.v", "sarlogic.v"),
])


def short(path):
    p = os.path.normpath(path).replace("\\", "/")
    for tail, name in FILES.items():
        if p.endswith("/" + tail) or p == tail:
            return name
    return None


def expand(spec):
    """'46-48,50' -> [46,47,48,50]"""
    out = []
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            out.extend(range(int(a), int(b) + 1))
        else:
            out.append(int(part))
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print(__doc__)
        return 2
    gate = "--gate" in sys.argv
    wfile = os.path.join(HERE, "waivers.txt")
    for i, a in enumerate(sys.argv):
        if a == "--waivers":
            wfile = sys.argv[i + 1]
            args = [x for x in args if x != wfile]
    waivers = load_waivers(wfile, ("line", "branch"))

    lines = {n: {} for n in FILES.values()}      # file -> {line: max count}
    branches = {n: OrderedDict() for n in FILES.values()}  # file -> {(l, col, kind): count}
    toggles = {n: {} for n in FILES.values()}    # file -> {(l, col, o): count}

    for path in args:
        for f, count in parse(path, want=None):
            name = short(f.get("f", ""))
            if name is None:
                continue
            t = f.get("t")
            try:
                ln = int(f.get("l", "0"))
            except ValueError:
                continue
            if t == "toggle":
                k = (ln, f.get("n", ""), f.get("o", ""))
                toggles[name][k] = toggles[name].get(k, 0) + count
                continue
            if t not in ("line", "branch"):
                continue
            rng = expand(f["S"]) if f.get("S") else [ln]
            for s in rng:
                lines[name][s] = max(lines[name].get(s, 0), count)
            if t == "branch":
                k = (ln, int(f.get("n", "0")), f.get("o", ""))
                branches[name][k] = branches[name].get(k, 0) + count

    # Verilator merges identical keys across runs by summing, but per-instance
    # records stay separate; the dicts above already took the union.
    errors = 0
    open_items = []
    waived_items = []
    tot = {"line": [0, 0], "branch": [0, 0], "toggle": [0, 0]}
    print(f"{'file':26s} {'line':>14s} {'branch':>14s} {'toggle (info)':>16s}")
    print("-" * 74)

    def waiver_for(kind, name, ln, o=None):
        for w in waivers:
            if w["kind"] != kind:
                continue
            p = w["pattern"].split(":")
            if p[0] != name or int(p[1]) != ln:
                continue
            if kind == "branch" and len(p) > 2 and p[2] != o:
                continue
            return w
        return None

    for name in FILES.values():
        l_cov = l_tot = b_cov = b_tot = 0
        for ln in sorted(lines[name]):
            c = lines[name][ln]
            w = waiver_for("line", name, ln)
            if w:
                w["used"] += 1
                if c > 0:
                    errors += 1
                    print(f"      ERROR waived line {name}:{ln} is covered (waiver {w['id']} is stale)")
                waived_items.append((f"line   {name}:{ln}", w))
                continue
            l_tot += 1
            if c > 0:
                l_cov += 1
            else:
                open_items.append(f"line   {name}:{ln}")
        for (ln, col, o), c in sorted(branches[name].items()):
            w = waiver_for("branch", name, ln, o)
            if w:
                w["used"] += 1
                if c > 0:
                    errors += 1
                    print(f"      ERROR waived branch {name}:{ln}:{o} is covered (waiver {w['id']} is stale)")
                waived_items.append((f"branch {name}:{ln}:{o} (col {col})", w))
                continue
            b_tot += 1
            if c > 0:
                b_cov += 1
            else:
                open_items.append(f"branch {name}:{ln}:{o} (col {col})")
        t_tot = len(toggles[name])
        t_cov = sum(1 for c in toggles[name].values() if c > 0)
        tot["line"][0] += l_cov; tot["line"][1] += l_tot
        tot["branch"][0] += b_cov; tot["branch"][1] += b_tot
        tot["toggle"][0] += t_cov; tot["toggle"][1] += t_tot

        def pct(a, b):
            return f"{a:4d}/{b:<4d} {100.0 * a / b if b else 100.0:5.1f}%"
        print(f"{name:26s} {pct(l_cov, l_tot)} {pct(b_cov, b_tot)} {pct(t_cov, t_tot)}")
        if not lines[name]:
            errors += 1
            print(f"      ERROR no coverage points at all for {name} (file missing from the code builds?)")
    print("-" * 74)

    def pct(a, b):
        return f"{a:4d}/{b:<4d} {100.0 * a / b if b else 100.0:5.1f}%"
    print(f"{'TOTAL (non-waived)':26s} {pct(*tot['line'])} {pct(*tot['branch'])} {pct(*tot['toggle'])}")
    if open_items:
        print("\nUNCOVERED (not waived):")
        for it in open_items:
            print(f"      HOLE   {it}")
    if waived_items:
        print("\nWAIVED:")
        for it, w in waived_items:
            print(f"      {w['id']:5s} {it}")
        seen = OrderedDict((w["id"], w) for _, w in waived_items)
        for w in seen.values():
            print(f"   [{w['id']}] {w['reason']}  (approved: {w['approved']})")
    for w in waivers:
        if w["used"] == 0:
            errors += 1
            print(f"ERROR waiver {w['id']} '{w['pattern']}' matches no coverage point (stale line number?)")
    print(f"\nCODE: line HIT {tot['line'][0]} / HOLE {tot['line'][1] - tot['line'][0]}, "
          f"branch HIT {tot['branch'][0]} / HOLE {tot['branch'][1] - tot['branch'][0]}, "
          f"WAIVED {len(waived_items)}")
    if errors:
        print(f"RESULT: {errors} ERROR(s)")
        return 1
    if gate and open_items:
        print(f"RESULT: {len(open_items)} unwaived uncovered line/branch item(s)")
        return 1
    print("RESULT: code coverage clean" if not open_items else f"RESULT: {len(open_items)} item(s) uncovered (not gated)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
