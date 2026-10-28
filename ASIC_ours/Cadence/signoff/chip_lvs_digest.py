#!/usr/bin/env python3
"""chip_lvs_digest.py -- digest of a Pegasus LVS comparison report (.cls),
plus the extraction report's warnings (<report>.lvsrpt, same name without .cls).

  chip_lvs_digest.py <top>.lvsrpt.cls [--examples N]

Prints: the run result and times/memory from the report header; the cells
that did not match (CELL MATCH SUMMARY); for each mismatching cell the
statistics rows that differ (devices/instances by type, pins, nets), the
mismatched nets and instances grouped by kind with a few examples, property
errors; and the extraction warnings grouped by message.
"""
import collections
import os
import re
import sys


def sections(lines):
    """Split the per-cell part of the report into (cell, title, lines)."""
    cell, title, buf = None, None, []
    hdr = re.compile(r"^\+===\[(.+?)\]=+")
    for i, l in enumerate(lines):
        m = hdr.match(l)
        if m and i + 1 < len(lines) and lines[i + 1].startswith("|"):
            if title:
                yield cell, title, buf
            cell, title, buf = m.group(1), lines[i + 1].strip("| \n"), []
            continue
        if l.startswith("+====") or l.startswith("|  ") and title is None:
            continue
        if title:
            buf.append(l.rstrip("\n"))
    if title:
        yield cell, title, buf


def main():
    args = sys.argv[1:]
    nex = 5
    if "--examples" in args:
        i = args.index("--examples")
        nex = int(args[i + 1])
        del args[i:i + 2]
    cls = args[0]
    lines = open(cls, errors="replace").read().split("\n")
    out = []
    hdr = {}
    for l in lines[:60]:
        m = re.match(r"^#+\s+(.+?)\s+:\s+(.*?)\s*$", l)
        if m:
            hdr.setdefault(m.group(1), m.group(2))
    out.append("Run Result : %s" % hdr.get("Run Result", "UNKNOWN"))
    out.append("report: %s" % os.path.abspath(cls))
    for k in ("Top Cell", "Run Summary", "Extraction Exec Time", "Extraction Peak Memory Usage",
              "NVN Exec Time", "LVS Total Exec Time", "LVS Total Peak Memory Usage"):
        if k in hdr:
            out.append("  %-30s %s" % (k, hdr[k]))
    # summary lines continuing "Run Summary"
    for l in lines[:60]:
        m = re.match(r"^#+\s+:\s+(\[.*)$", l)
        if m:
            out.append("  %-30s %s" % ("", m.group(1)))

    # CELL MATCH SUMMARY
    try:
        s = next(i for i, l in enumerate(lines) if "CELL MATCH SUMMARY" in l)
    except StopIteration:
        s = None
    if s is not None:
        rows, bad = 0, []
        for l in lines[s + 3:]:
            if l.startswith("####"):
                break
            if "|" not in l or l.startswith(("Cell ", "-", " ")) or "Initial Pins" in l:
                continue
            rows += 1
            # Pegasus pads every other row with dot leaders (" .  .  .")
            f = [re.sub(r"(?:\s+\.)+(?=\s|$)", "", x).strip(" .") for x in l.split("|")]
            if len(f) >= 4 and f[3].split()[:1] != ["match"]:
                bad.append("    %-40s pins %s / %s  %s %s" % (f[0], f[1], f[2], f[3], f[4] if len(f) > 4 else ""))
        out.append("")
        out.append("Cells compared: %d, not matching: %d" % (rows, len(bad)))
        out += bad[:60]
        if len(bad) > 60:
            out.append("    ... %d more" % (len(bad) - 60))
    # cell statistics (matched / expanded / blackboxed)
    for l in lines:
        m = re.match(r"^(Cells (matched|expanded|not run|which mismatch)|Cells with .*|Cells that have been blackboxed)\s+\|\s+(\d+)", l)
        if m:
            out.append("  %-45s %s" % (m.group(1), m.group(3)))

    # per-cell sections (only for cells that did not match)
    badcells = set(b.split()[0] for b in bad) if s is not None else None
    for cell, title, buf in sections(lines):
        if badcells is not None and cell not in badcells:
            continue
        if title == "STATISTICS":
            # a '*' only in the Original/Filtered columns is parallel-device
            # reduction at work (fingers), not a difference: look at the last two
            def late_diff(b):
                f = b.split("|")
                return len(f) >= 4 and "*" in "|".join(f[-2:])
            diff = [b for b in buf if late_diff(b)]
            if diff:
                out.append("")
                out.append("[%s] statistics that differ (lay : sch; * = differs):" % cell)
                head = [b for b in buf if b.startswith("Cell ") or "Original" in b]
                out += ["    " + h for h in head[:2]]
                out += ["    " + d for d in diff[:40]]
        elif title == "SHORTS AND OPENS":
            # entry: one layout net joining several schematic nets (SHORT) or
            # one schematic net split over several layout nets (OPEN)
            ents, cur, pend_s, pend_l, kind = [], None, False, False, None
            for b in buf:
                if b.startswith("=") or "|" not in b:
                    continue
                left, right = b.split("|", 1)
                left, right = left.strip(), right.strip()
                if left.startswith(("Layout Net:", "Layout Pin:")) and cur is not None and cur.get("closed") \
                        and not (right in ("SHORT", "OPEN")):
                    if cur:
                        ents.append(cur)
                    cur = {"lay": [], "sch": [], "kind": None}
                if cur is None:
                    cur = {"lay": [], "sch": [], "kind": None}
                if left in ("SHORT", "OPEN") or right in ("SHORT", "OPEN"):
                    cur["kind"] = left if left in ("SHORT", "OPEN") else right
                    cur["closed"] = True
                m = re.match(r"Layout (?:Net|Pin):\s*(\S*)", left)
                if m:
                    if m.group(1):
                        cur["lay"].append(m.group(1))
                    else:
                        pend_l = True
                elif pend_l and left:
                    cur["lay"].append(left); pend_l = False
                m = re.match(r"Schematic (?:Net|Pin):\s*(\S*)", right)
                if m:
                    if m.group(1):
                        cur["sch"].append(m.group(1))
                    else:
                        pend_s = True
                elif pend_s and right:
                    cur["sch"].append(right.split()[0]); pend_s = False
            if cur:
                ents.append(cur)
            kinds = collections.Counter(e["kind"] or "?" for e in ents)
            out.append("")
            out.append("[%s] shorts and opens: %d entries %s" % (cell, len(ents), dict(kinds)))
            for e in ents[:3 * nex]:
                out.append("    %s layout %s <-> schematic %s" % (
                    e["kind"], " ".join(e["lay"]), " + ".join(e["sch"]))[:300])
            if len(ents) > 3 * nex:
                out.append("    ... %d more" % (len(ents) - 3 * nex))
        elif title == "MISMATCHED NETS":
            ents = [b for b in buf if re.search(r"\(mn \d+\)", b)]
            pairs = []
            cur = []
            for b in buf:
                if b.strip().startswith(("Layout Net", "Layout Pin", "Schematic")) or "|" in b:
                    cur.append(b.strip())
                if re.search(r"\(mn \d+\)", b):
                    pairs.append(" ".join(x for x in cur if not x.startswith("=")))
                    cur = []
            kinds = collections.Counter()
            for p in pairs:
                k = "missing net in layout" if "Layout Net: ** missing" in p else \
                    "missing net in source" if "Schematic Net: ** missing" in p or "Schematic Pin: ** missing" in p else \
                    "net connectivity differs"
                kinds[k] += 1
            out.append("")
            out.append("[%s] mismatched nets: %d  %s" % (cell, len(ents), dict(kinds)))
            for p in pairs[:nex]:
                out.append("    " + re.sub(r"\s+", " ", p)[:300])
        elif title == "MISMATCHED INSTANCES":
            ents = []
            cur = []
            for b in buf:
                if "|" in b:
                    cur.append(b)
                if re.search(r"\(mi \d+\)", b):
                    ents.append(cur)
                    cur = []
            kinds = collections.Counter()
            ex = collections.OrderedDict()
            for e in ents:
                txt = " ".join(e)
                lm = re.search(r"Layout Model:\s*(\S*)", txt)
                sm = re.search(r"Schematic Model:\s*(\S*)", txt)
                lay = lm.group(1) if lm else ""
                sch = sm.group(1) if sm else ""
                if "Layout Inst : ** missing" in txt:
                    k = "only in source: %s" % sch
                elif "Schematic Inst : ** missing" in txt:
                    k = "only in layout: %s" % lay
                else:
                    k = "connections differ: %s/%s" % (lay, sch)
                kinds[k] += 1
                ex.setdefault(k, [])
                if len(ex[k]) < 2:
                    ex[k].append(re.sub(r"\s+", " ", " / ".join(x.strip() for x in e if x.strip() and not x.startswith("="))))
            out.append("")
            out.append("[%s] mismatched instances: %d" % (cell, len(ents)))
            for k, v in kinds.most_common(30):
                out.append("    %6d  %s" % (v, k))
                for x in ex[k]:
                    out.append("            e.g. %s" % x[:260])
        elif "PROPERT" in title or "PARAMETER" in title:
            ents = [b for b in buf if re.search(r"\((mp|mip|pe)\s*\d+\)", b)]
            out.append("")
            out.append("[%s] %s: %d entries" % (cell, title.lower(), len(ents)))
            txt = [b for b in buf if b.strip() and not b.startswith("=")]
            out += ["    " + t[:200] for t in txt[:4 * nex]]
        elif "PORT" in title or "PIN" in title:
            txt = [b for b in buf if b.strip()]
            out.append("")
            out.append("[%s] %s:" % (cell, title.lower()))
            out += ["    " + t[:200] for t in txt[:3 * nex]]

    # label-to-label shorts found by lvs_find_shorts
    sh = cls[:-4] + ".shorts" if cls.endswith(".cls") else None
    if sh and os.path.exists(sh):
        txt = open(sh, errors="replace").read()
        heads = re.findall(r"^SHORT \d+\. (.*)$", txt, re.M)
        out.append("")
        out.append("Label shorts (lvs_find_shorts, %s): %d" % (os.path.basename(sh), len(heads)))
        starts = [m.start() for m in re.finditer(r"^SHORT \d+\.", txt, re.M)] + [len(txt)]
        for blk in (txt[a:b] for a, b in zip(starts, starts[1:])):
            h = blk.split("\n", 1)[0]
            labs = re.findall(r'^"(\S+)" at \(([^)]*)\)', blk, re.M)
            lays = collections.Counter(re.findall(r"^SN \d+ (\S+)$", blk, re.M))
            out.append("    %s; labels %s; path polygons by layer %s" % (
                h, ", ".join("%s@(%s)" % l for l in labs), dict(lays)))
    # extraction report
    rpt = cls[:-4] if cls.endswith(".cls") else None
    if rpt and os.path.exists(rpt):
        warn = collections.Counter()
        ex = {}
        for l in open(rpt, errors="replace"):
            m = re.match(r"^\s*\[(WARN|ERROR)\]\s*(.*)$", l)
            if m:
                key = re.sub(r"\d+(\.\d+)?", "#", m.group(2))[:110]
                warn[(m.group(1), key)] += 1
                ex.setdefault((m.group(1), key), m.group(2)[:200])
        if warn:
            out.append("")
            out.append("Extraction report %s: warnings/errors by message" % os.path.basename(rpt))
            for (lvl, k), v in warn.most_common(25):
                out.append("    %6d  [%s] %s" % (v, lvl, ex[(lvl, k)]))
    print("\n".join(out))


if __name__ == "__main__":
    main()
