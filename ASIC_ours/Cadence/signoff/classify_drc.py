# =====================================================================
# classify_drc.py -- split a Pegasus chip DRC result by location (KLayout)
#
#   klayout -b -r classify_drc.py -rd gds=<chip.gds> -rd top=<cell>
#       -rd rdb=<top>.drc_errors.ascii -rd counts=counts.txt -rd out=<dir>
#
# Every result marker of a REAL rule is put in one class:
#   ip-internal   centred in a library/IP instance (IO pad, SRAM, hard macro) and
#                 touching no top-level shape on the rule's layers: the
#                 violation is in the IP's own layout
#   ip+top        centred in an IP instance and touching top-level routing/vias on
#                 the rule's layers: an interaction between our routing and IP
#   top-level     centred outside IP instances, touching top-level routing/vias
#   std-cell      outside IP instances, touching no top-level shape on the
#                 rule's layers (std-cell internals or cell abutment)
# "Top-level" = shapes in the top cell, in Innovus via cells, or in the fill
# cell <top>_FILL added by run_fill.sh. Rules on front-end layers (well,
# diff, poly, licon, implants...) involve the top level only through diff/poly
# fill; Innovus draws only li1..met5 and cuts.
# Density/fill rules (*.local.*, *.global.*, *.fill.*) are windows, not
# geometry; they are listed with their window counts.
# Writes <out>/breakdown.txt and <out>/violations.txt. Exit status 1 when a
# REAL rule has results in the top-level, std-cell or ip+top classes.
# =====================================================================
import os, sys, re, time
import pya

G = globals()
def opt(n, d=None):
    v = G.get(n)
    return d if v in (None, "") else v
GDS, TOP, RDB, OUTD = opt("gds"), opt("top"), opt("rdb"), opt("out", ".")
COUNTS = opt("counts")
if not (GDS and RDB):
    print("usage: klayout -b -r classify_drc.py -rd gds=.. -rd top=.. -rd rdb=.. [-rd counts=..] [-rd out=..]")
    sys.exit(2)
T0 = time.time()
DENS = re.compile(r"\.(local|global)\.|dens|\.fill\.")

# ---- results database (Calibre-style ASCII written by Pegasus) ---------
lines = open(RDB, errors="replace").read().splitlines()
hdr = lines[0].split()
prec = int(hdr[1]) if len(hdr) > 1 else 1000
rules = {}
i = 1
while i < len(lines):
    name = lines[i].strip(); i += 1
    if not name: continue
    f = lines[i].split(); i += 1
    cur, orig, nl = int(f[0]), int(f[1]), int(f[2])
    i += nl
    res = []; tr = None
    k = 0
    while k < cur and i < len(lines):
        h = lines[i].split()
        if h and h[0] == "CN":            # cell-based results: c m11 m12 m21 m22 dx dy
            m = [float(x) for x in h[3:9]] if len(h) >= 9 else None
            tr = m; i += 1; continue
        i += 1
        typ, n = h[0], int(h[2])
        pts = []
        for j in range(n):
            v = [int(float(x)) for x in lines[i + j].split()]
            pts.extend([(v[0], v[1])] if typ == "p" else [(v[0], v[1]), (v[2], v[3])])
        i += n
        if tr:
            pts = [(int(tr[0] * x + tr[1] * y + tr[4]), int(tr[2] * x + tr[3] * y + tr[5])) for x, y in pts]
        res.append(pts); k += 1
    rules[name] = (cur, orig, res)

totals = {}
if COUNTS and os.path.exists(COUNTS):
    for line in open(COUNTS):
        f = line.split()
        if len(f) >= 2: totals[f[0]] = (int(f[1]), int(f[2]) if len(f) > 2 else int(f[1]))
for r, (cur, orig, res) in rules.items():
    if cur and r not in totals: totals[r] = (orig or cur, orig or cur)

# ---- layout -------------------------------------------------------------
ly = pya.Layout(); ly.read(GDS)
top = ly.cell(TOP) if TOP else ly.top_cells()[0]
scale = 1.0 / (prec * ly.dbu)           # rdb units -> dbu
ROUTE = set([(l, 20) for l in range(67, 73)] + [(l, 44) for l in range(67, 72)] + [(l, 5) for l in range(67, 73)] + [(l, 16) for l in range(67, 73)])
def is_std(n): return n.startswith("sky130_fd_sc_hd__") or n.startswith("sky130_ef_sc_hd__")
def kind(n):
    if "_io__" in n: return "IO"
    if "sram" in n: return "SRAM"
    return "MACRO"
lib = set(); ips = []
via_cache = {}
for inst in top.each_inst():
    c = ly.cell(inst.cell_index)
    ci = inst.cell_index
    if c.name == top.name + "_FILL":
        continue      # metal/diff/poly fill (run_fill.sh): ours, i.e. top-level
    if ci not in via_cache:
        lays = set((ly.get_info(li).layer, ly.get_info(li).datatype) for li in ly.layer_indexes() if not c.shapes(li).is_empty())
        via_cache[ci] = (c.child_cells() == 0 and lays <= ROUTE and not is_std(c.name))
    if via_cache[ci]: continue
    if ci not in lib:
        lib.add(ci); lib |= set(c.called_cells())
    if not is_std(c.name):
        ips.append((inst.bbox(), c.name, kind(c.name)))
lib_list = sorted(lib)
print("classify: %d IP instances (%s), %d library cells" % (len(ips), ", ".join(sorted(set(k for _, _, k in ips))), len(lib)))

top_regions = {}
def top_region(l, d):
    if (l, d) in top_regions: return top_regions[(l, d)]
    li = ly.find_layer(l, d)
    reg = pya.Region()
    if li is not None:
        it = top.begin_shapes_rec(li); it.unselect_cells(lib_list)
        reg = pya.Region(it)
    top_regions[(l, d)] = reg
    return reg

# rule-name prefix -> GDS layers the top level (routing, vias, fill on xx/99)
# can contribute to that rule
LAYERS = {
    "li": [(67, 20), (67, 44), (67, 99)], "mcon": [(67, 44), (67, 20), (68, 20)],
    "m1": [(68, 20), (68, 44), (67, 44), (68, 99)], "via": [(68, 44), (68, 20), (69, 20)],
    "via1": [(68, 44), (68, 20), (69, 20)], "m2": [(69, 20), (69, 44), (68, 44), (69, 99)],
    "via2": [(69, 44), (69, 20), (70, 20)], "m3": [(70, 20), (70, 44), (69, 44), (70, 99)],
    "via3": [(70, 44), (70, 20), (71, 20)], "m4": [(71, 20), (71, 44), (70, 44), (71, 99)],
    "via4": [(71, 44), (71, 20), (72, 20)], "m5": [(72, 20), (71, 44), (72, 99)],
    "capm": [(70, 20), (70, 44), (70, 99)], "cap2m": [(71, 20), (71, 44), (71, 99)], "pad": [(72, 20)],
    # front-end layers: only fill (diff/poly fill cells) comes from the top level
    "diff": [(65, 99)], "difftap": [(65, 99)], "tap": [(65, 99)], "poly": [(66, 99)],
    "licon": [(65, 99), (66, 99)], "npc": [(66, 99)], "psd": [(65, 99)], "nsd": [(65, 99)],
}
for a, b in (("li1", "li"), ("met1", "m1"), ("met2", "m2"), ("met3", "m3"), ("met4", "m4"), ("met5", "m5")):
    LAYERS[a] = LAYERS[b]
def rule_layers(r):
    for p in ("CDR.", "CDRW."):
        if r.startswith(p): r = r[len(p):]
    t = r.split(".")
    key = t[-1] if t[0] == "x" else t[0]
    if t[0] == "x" and key in ("1a", "1b"):  # off-grid checks cover every layer
        return sorted(set(l for v in LAYERS.values() for l in v))
    # other x.* checks (x.prBndry, x.8 areaid.ce, ...) are about layers the
    # top level never draws
    return LAYERS.get(key, [])

def um(p): return "(%.2f,%.2f)" % (p.x * ly.dbu, p.y * ly.dbu)

out = []; summary = []
real_bad = 0
CLASSES = ["top-level", "std-cell", "ip+top", "ip-internal"]
for r in sorted(totals, key=lambda x: (bool(DENS.search(x)), -totals[x][1], x)):
    cur, orig, res = rules.get(r, (0, 0, []))
    tot, flat = totals[r]
    if DENS.search(r):
        boxes = []
        for pts in res:
            b = pya.Box()
            for x, y in pts: b += pya.Point(int(x * scale), int(y * scale))
            boxes.append(b)
        on_ip = sum(1 for b in boxes if any(ib.overlaps(b) for ib, _, _ in ips))
        out.append("%-26s %8d  density/fill windows%s; %d of %d listed overlap IP instances"
                   % (r, flat, "" if cur >= tot else " (%d listed)" % cur, on_ip, len(boxes)))
        summary.append(("D", r, flat, None))
        continue
    layers = rule_layers(r)
    toplev = pya.Region()
    for l, d in layers: toplev += top_region(l, d)
    markers = []
    for pts in res:
        if len(pts) >= 3:
            poly = pya.Polygon([pya.Point(int(x * scale), int(y * scale)) for x, y in pts])
        else:
            b = pya.Box()
            for x, y in pts: b += pya.Point(int(x * scale), int(y * scale))
            poly = pya.Polygon(b)
        markers.append(poly)
    hit = set()
    if layers and markers and not toplev.is_empty():
        mreg = pya.Region(); mreg.merged_semantics = False
        for m in markers: mreg.insert(m.sized(5))
        hr = mreg.interacting(toplev)
        for p in hr.each(): hit.add(p.bbox().to_s())
    cls = dict((c, []) for c in CLASSES); ipnames = {}
    for m in markers:
        b = m.bbox(); touched = m.sized(5).bbox().to_s() in hit
        ip = None
        for ib, n, k in ips:          # the IP instance holding the marker's centre
            if ib.contains(b.center()):
                ip = n; break
        if ip is None and not touched and max(b.width(), b.height()) * ly.dbu > 50:
            # an extent-type marker (e.g. CDRW.x.8: extent of areaid.ce) spanning IP cells
            over = sorted(set(n for ib, n, k in ips if ib.overlaps(b)))
            if over: ip = "extent over " + "+".join(over)
        if ip:
            c = "ip+top" if touched else "ip-internal"
            ipnames.setdefault(c, {}); ipnames[c][ip] = ipnames[c].get(ip, 0) + 1
        else:
            c = "top-level" if touched else "std-cell"
        cls[c].append(b.center())
    n_bad = len(cls["top-level"]) + len(cls["std-cell"]) + len(cls["ip+top"])
    if n_bad: real_bad += 1
    capnote = "" if cur >= tot else "  (classified %d of %d; raise --max-results for all)" % (cur, tot)
    out.append("%-26s hier %6d flat %9d  layers %s%s" % (r, tot, flat, ",".join("%d/%d" % x for x in layers) or "front-end", capnote))
    for c in CLASSES:
        if not cls[c]: continue
        extra = ""
        if c in ipnames:
            extra = " [" + ", ".join("%s %d" % (n, v) for n, v in sorted(ipnames[c].items(), key=lambda kv: -kv[1])) + "]"
        out.append("    %-12s %7d%s  e.g. %s" % (c, len(cls[c]), extra, " ".join(um(p) for p in cls[c][:3])))
    summary.append(("R", r, (tot, flat), dict((c, len(cls[c])) for c in CLASSES), ipnames, cur))

with open(os.path.join(OUTD, "breakdown.txt"), "w") as fh:
    fh.write("DRC results by rule and location class (classify_drc.py)\n")
    fh.write("gds %s  top %s\n" % (GDS, top.name))
    fh.write("IP instances: %s\n\n" % ", ".join("%s x%d" % (n, sum(1 for _, m, _ in ips if m == n)) for n in sorted(set(m for _, m, _ in ips))))
    fh.write("\n".join(out) + "\n")

with open(os.path.join(OUTD, "violations.txt"), "w") as fh:
    real = [s for s in summary if s[0] == "R"]
    dens = [s for s in summary if s[0] == "D"]
    fh.write("REAL violations: rule, hierarchical results (one per cell definition), flat count;\n"
             "then the hierarchical results by location class\n")
    fh.write("  (top-level = our routing/vias, std-cell = std-cell internals/abutment,\n"
             "   ip+top = our routing on an IP cell, ip-internal = inside IO/SRAM/macro layout)\n")
    for _, r, tot, c, ipn, cur in real:
        ipi = ""
        if "ip-internal" in ipn:
            ipi = " [" + ", ".join("%s %d" % (n, v) for n, v in sorted(ipn["ip-internal"].items(), key=lambda kv: -kv[1])) + "]"
        note = "" if cur >= tot[0] else " (%d of %d classified)" % (cur, tot[0])
        fh.write("  %-22s %6d %9d | top-level %d, std-cell %d, ip+top %d, ip-internal %d%s%s\n"
                 % (r, tot[0], tot[1], c["top-level"], c["std-cell"], c["ip+top"], c["ip-internal"], ipi, note))
    nb = sum(1 for s in real if s[3]["top-level"] + s[3]["std-cell"] + s[3]["ip+top"])
    ni = sum(1 for s in real if not (s[3]["top-level"] + s[3]["std-cell"] + s[3]["ip+top"]))
    fh.write("  => %d REAL rules with results outside IP layout (top-level/std-cell/ip+top), %d REAL rules only inside IP layout\n" % (nb, ni))
    fh.write("DENSITY/FILL (chip fill resolves):\n")
    for _, r, tot, _ in dens:
        fh.write("  %-26s %8d\n" % (r, tot))
print("classify: %d rules, done in %.0f s" % (len(totals), time.time() - T0))
sys.exit(1 if real_bad else 0)
