# =====================================================================
# check_gds.py -- sanity checks on a merged chip GDS (KLayout batch mode)
#
#   klayout -b -r check_gds.py -rd gds=<file.gds> [-rd top=<cell>]
#       [-rd masters=<masters.txt from stream_out.tcl>] [-rd pincheck=1]
#       [-rd layermap=<sky130 layermap>] [-rd allow=236/0,...] [-rd json=<out>]
#
# Checks (FAIL -> exit status 1):
#   * exactly one top cell (or the given one exists); bbox; cell count
#   * no ghost cells (referenced, never defined) and no empty cells
#     (no shapes, no instances): an unmerged library master shows up as one
#   * every layer/datatype is in the PDK layermap
#     ($SKY130/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap). Library
#     cells may carry the allow-listed library-native layers (default 236/0,
#     the open-PDK std-cell boundary marker); the top cell and the Innovus via
#     cells may not carry anything outside the layermap.
#   * with masters=: every master is present, non-empty, and placed as many
#     times as Innovus placed it
#   * top-level labels sit on a drawing shape of their layer
# Reports: per-layer shape counts in the top cell, via cells, label list.
# pincheck=1 adds connectivity spot checks (WARN only, not FAIL):
#   * std-cell li1 signal pins (67/16) with a routing mcon (67/44, from an
#     Innovus via cell) inside them
#   * std-cell met1 VPWR/VGND pins (68/16) touched by top-level met1 rails
#   * hard-macro pins (class BLOCK in masters.txt): each pin's own metal
#     touched by top-level routing or by a top-level via cut on that metal
# =====================================================================
import os, sys, time, json as _json
import pya

T0 = time.time()
G = globals()
def opt(name, default=None):
    v = G.get(name)
    return default if v in (None, "") else v

GDS = opt("gds")
if not GDS:
    print("usage: klayout -b -r check_gds.py -rd gds=<file> [-rd top=..] [-rd masters=..] [-rd pincheck=1]")
    sys.exit(2)
SKY130 = os.environ.get("SKY130", "/opt/pdk/cadence_SKY130/sky130_release_0.1.0").rstrip("/")
LAYERMAP = opt("layermap", SKY130 + "/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap")
ALLOW = set()
for a in opt("allow", "236/0").split(","):
    if a.strip():
        l, d = a.strip().split("/"); ALLOW.add((int(l), int(d)))
PINCHECK = str(opt("pincheck", "0")) == "1"
MASTERS_FILE = opt("masters")      # read before the name "masters" is reused below
WANT_TOP = opt("top")
JSON_OUT = opt("json")

fails, warns = [], []
def FAIL(msg): fails.append(msg); print("FAIL: " + msg)
def WARN(msg): warns.append(msg); print("WARN: " + msg)

# ---- layermap --------------------------------------------------------
known = {}
for line in open(LAYERMAP):
    f = line.split()
    if len(f) >= 4 and not line.startswith("#") and f[2].isdigit() and f[3].isdigit():
        known[(int(f[2]), int(f[3]))] = f[0] + "." + f[1]

# ---- read ------------------------------------------------------------
ly = pya.Layout()
ly.read(GDS)
dbu = ly.dbu
print("GDS     %s (%.1f MB), read in %.0f s, dbu %g um" % (GDS, os.path.getsize(GDS) / 1e6, time.time() - T0, dbu))
if abs(dbu - 0.001) > 1e-12:
    FAIL("dbu is %g um, expected 0.001 (1000 units per um)" % dbu)

tops = [c for c in ly.top_cells()]
want = WANT_TOP
if want:
    top = ly.cell(want)
    if top is None:
        FAIL("top cell %s not in GDS" % want); top = tops[0]
else:
    top = tops[0]
if len(tops) != 1:
    FAIL("%d top cells: %s" % (len(tops), ", ".join(sorted(c.name for c in tops))[:400]))
bb = top.dbbox()
print("TOP     %s  bbox (%.3f, %.3f) - (%.3f, %.3f) um  = %.3f x %.3f um"
      % (top.name, bb.left, bb.bottom, bb.right, bb.top, bb.width(), bb.height()))
print("CELLS   %d" % ly.cells())

ghosts = [c.name for c in ly.each_cell() if c.is_ghost_cell()]
if ghosts: FAIL("%d ghost cells (referenced, not defined): %s" % (len(ghosts), " ".join(ghosts[:20])))

# ---- which cells are library cells, which are Innovus-generated -------
masters = {}
if MASTERS_FILE:
    for line in open(MASTERS_FILE):
        f = line.rstrip("\n").split("\t")
        if len(f) >= 2: masters[f[0]] = (int(f[1]), f[2] if len(f) > 2 else "", f[3] if len(f) > 3 else "")
ROUTE_LAYERS = set([(l, 20) for l in range(67, 73)] + [(l, 44) for l in range(67, 72)] +
                   [(l, 99) for l in range(67, 73)] + [(l, 16) for l in range(67, 73)] +
                   [(l, 5) for l in range(67, 73)])
def cell_layers(c):
    return set((ly.get_info(li).layer, ly.get_info(li).datatype) for li in ly.layer_indexes() if not c.shapes(li).is_empty())
child_idx = set(i.cell_index for i in top.each_inst())
lib_roots = set()
gen = set()
for ci in child_idx:
    c = ly.cell(ci)
    if masters:
        (lib_roots if c.name in masters else gen).add(ci)
    else:
        if c.child_cells() == 0 and cell_layers(c) <= ROUTE_LAYERS:
            gen.add(ci)
        else:
            lib_roots.add(ci)
lib = set(lib_roots)
for ci in lib_roots:
    lib |= set(ly.cell(ci).called_cells())
gen -= lib
# An unmerged master is an empty cell placed directly in the top cell (the
# 22 Sep stream had 173). An empty cell deeper down came empty from the
# library GDS itself, so it is reported but does not fail the check.
empty = [c for c in ly.each_cell() if not c.is_ghost_cell() and c.is_empty()]
empty_masters = sorted(c.name for c in empty if c.cell_index() in child_idx)
empty_sub = sorted(c.name for c in empty if c.cell_index() not in child_idx)
print("EMPTY   %d empty masters/via cells placed in the top cell, %d empty library subcells, %d ghost cells"
      % (len(empty_masters), len(empty_sub), len(ghosts)))
if empty_sub:
    print("        empty subcells below the placed masters (not a merge failure: a cell empty in its source GDS,"
          " or an empty mirror cell of a fill hierarchy): " + " ".join(empty_sub[:10]))
if empty_masters: FAIL("%d empty masters (not merged?): %s" % (len(empty_masters), " ".join(empty_masters[:20])))
print("HIER    %d library masters placed (%d library cells incl. subcells), %d Innovus via/generated cells"
      % (len(lib_roots), len(lib), len(gen)))

# ---- layers ----------------------------------------------------------
per_layer = {}   # (l,d) -> [shapes, cells, {top,gen,lib} cell names]
for li in ly.layer_indexes():
    info = ly.get_info(li); key = (info.layer, info.datatype)
    for c in ly.each_cell():
        n = c.shapes(li).size()
        if not n: continue
        e = per_layer.setdefault(key, [0, 0, {"top": [], "gen": [], "lib": []}])
        e[0] += n; e[1] += 1
        kind = "top" if c.cell_index() == top.cell_index() else ("gen" if c.cell_index() in gen else "lib")
        if len(e[2][kind]) < 6: e[2][kind].append(c.name)
print("LAYERS  %d layer/datatypes in the file" % len(per_layer))
bad = []
for key in sorted(per_layer):
    if key in known: continue
    e = per_layer[key]
    where = "; ".join("%s: %s" % (k, ",".join(v)) for k, v in e[2].items() if v)
    if key in ALLOW and not e[2]["top"] and not e[2]["gen"]:
        print("        %d/%d not in the layermap, allow-listed (library-native, %d shapes in %d library cells, e.g. %s)"
              % (key[0], key[1], e[0], e[1], ",".join(e[2]["lib"][:3])))
        continue
    bad.append(key)
    FAIL("layer %d/%d is not in the sky130 layermap (%d shapes in %d cells; %s)" % (key[0], key[1], e[0], e[1], where))
for junk in [(127, 0), (128, 0), (129, 0)]:
    if junk in per_layer: FAIL("junk layer %d/%d from a map-less stream-out is present" % junk)

# ---- top-level shapes per layer ---------------------------------------
print("TOP-LEVEL SHAPES (top cell itself; vias are instances of via cells)")
print("  %-9s %-18s %9s %9s %9s %9s" % ("layer", "name", "boxes", "polygons", "paths", "texts"))
for li in sorted(ly.layer_indexes(), key=lambda i: (ly.get_info(i).layer, ly.get_info(i).datatype)):
    sh = top.shapes(li)
    if sh.is_empty(): continue
    info = ly.get_info(li)
    nb = np_ = npa = nt = 0
    for s in sh.each():
        if s.is_box(): nb += 1
        elif s.is_path(): npa += 1
        elif s.is_text(): nt += 1
        else: np_ += 1
    print("  %-9s %-18s %9d %9d %9d %9d" % ("%d/%d" % (info.layer, info.datatype),
          known.get((info.layer, info.datatype), "?"), nb, np_, npa, nt))

# ---- instances --------------------------------------------------------
placed = {}
for inst in top.each_inst():
    n = inst.size() if inst.is_regular_array() else 1
    placed[inst.cell_index] = placed.get(inst.cell_index, 0) + n
n_gen_inst = sum(v for k, v in placed.items() if k in gen)
n_lib_inst = sum(v for k, v in placed.items() if k in lib_roots)
print("INSTS   %d master instances, %d via-cell instances (%d via cells)" % (n_lib_inst, n_gen_inst, len(gen)))
if masters:
    miss, cntbad = [], []
    for m, (n, cls, src) in sorted(masters.items()):
        c = ly.cell(m)
        if c is None: miss.append(m); continue
        got = placed.get(c.cell_index(), 0)
        if got != n: cntbad.append("%s %d/%d" % (m, got, n))
    print("MASTERS %d in masters.txt, %d missing, %d with a different instance count" % (len(masters), len(miss), len(cntbad)))
    if miss: FAIL("masters missing from GDS: " + " ".join(miss[:20]))
    if cntbad: FAIL("instance count GDS/Innovus differs: " + ", ".join(cntbad[:20]))
    extra = [ly.cell(ci).name for ci in lib_roots if ly.cell(ci).name not in masters]
    if extra: FAIL("placed cells not in masters.txt: " + " ".join(extra[:20]))

# ---- labels ----------------------------------------------------------
def drawing_li(l):
    return ly.find_layer(l, 20)
labs = []
for li in ly.layer_indexes():
    info = ly.get_info(li)
    for s in top.shapes(li).each(pya.Shapes.STexts):
        labs.append((info.layer, info.datatype, s.text_string, s.text_pos))
print("LABELS  %d top-level labels on %s" % (len(labs), ", ".join(sorted(set("%d/%d" % (a, b) for a, b, _, _ in labs)))))
off = []
for l, d, s, p in labs:
    dli = drawing_li(l)
    hit = False
    if dli is not None:
        box = pya.Box(p.x - 1, p.y - 1, p.x + 1, p.y + 1)
        it = top.begin_shapes_rec_touching(dli, box)
        hit = not it.at_end()
    if not hit: off.append("%s@%d/%d(%.3f,%.3f)" % (s, l, d, p.x * dbu, p.y * dbu))
if labs:
    print("        %d of %d labels sit on drawing metal of their layer" % (len(labs) - len(off), len(labs)))
    print("        e.g. " + ", ".join("%s@%d/%d(%.1f,%.1f)" % (s, l, d, p.x * dbu, p.y * dbu) for l, d, s, p in labs[:6]))
if off: FAIL("%d labels not on metal: %s" % (len(off), " ".join(off[:10])))

# ---- connectivity spot checks ------------------------------------------
pinres = {}
if PINCHECK:
    T1 = time.time()
    lib_list = sorted(lib)
    def rec_iter(l, d, box=None, touching=True):
        li = ly.find_layer(l, d)
        if li is None: return None
        it = top.begin_shapes_rec_touching(li, box) if box is not None else top.begin_shapes_rec(li)
        it.unselect_cells(lib_list)    # top cell + Innovus via cells only
        return it
    # routing mcon centres on a 2 um grid
    GRID = 2000
    grid = {}
    it = rec_iter(67, 44); n_mcon = 0
    while it is not None and not it.at_end():
        c = it.shape().bbox().transformed(it.trans()).center()
        grid.setdefault((c.x // GRID, c.y // GRID), []).append(c); n_mcon += 1
        it.next()
    def pin_name_shapes(c, pl, pd, ll, ld):
        """pin polygons on pl/pd grouped by the label (ll/ld or pl/pd texts) inside them"""
        out = {}
        pli = ly.find_layer(pl, pd)
        if pli is None: return out
        texts = []
        for tl, td in ((ll, ld), (pl, pd)):
            tli = ly.find_layer(tl, td)
            if tli is None: continue
            for s in c.shapes(tli).each(pya.Shapes.STexts):
                texts.append((s.text_string, s.text_pos))
        for s in c.shapes(pli).each():
            if s.is_text(): continue
            poly = s.polygon
            if poly is None: continue
            name = None
            for t, p in texts:
                if poly.inside(p) or poly.bbox().contains(p):
                    name = t; break
            out.setdefault(name or "?", []).append(poly)
        return out
    PWR = set(["VPWR", "VGND", "VPB", "VNB"])
    sc_pins = {}
    for ci in lib_roots:
        c = ly.cell(ci)
        if not (c.name.startswith("sky130_fd_sc_hd__") or c.name.startswith("sky130_ef_sc_hd__")): continue
        p = pin_name_shapes(c, 67, 16, 67, 5)
        # the router may land anywhere on the pin's li1 (the LEF pin is the
        # whole li1 shape), so test against the li1 drawing under the pin
        li1 = pya.Region(c.shapes(ly.find_layer(67, 20))) if ly.find_layer(67, 20) is not None else pya.Region()
        li1.merge()
        # some pins also have a met1 strap inside the cell (e.g. dfrtp RESET_B,
        # dfstp SET_B); the router may land on that with a via1 instead
        m1 = pya.Region(c.shapes(ly.find_layer(68, 20))) if ly.find_layer(68, 20) is not None else pya.Region()
        m1.merge()
        mc = pya.Region(c.shapes(ly.find_layer(67, 44))) if ly.find_layer(67, 44) is not None else pya.Region()
        terms = {}
        for k, polys in p.items():
            if k in PWR: continue
            t = li1.interacting(pya.Region(polys))
            lit = t if not t.is_empty() else pya.Region(polys)
            m1t = m1.interacting(mc.interacting(lit))
            terms[k] = (list(lit.each()), list(m1t.each()))
        sc_pins[ci] = terms
    tot = hit = 0; miss_ex = []; m1hit = [0]
    rail_tot = rail_hit = 0; rail_n = 0
    m1li = ly.find_layer(68, 16)
    for inst in top.each_inst():
        pins = sc_pins.get(inst.cell_index)
        if not pins: continue
        tr = inst.cplx_trans
        for name, (polys, m1polys) in pins.items():
            tot += 1; ok = False
            for poly in polys:
                tp = poly.transformed(tr)
                b = tp.bbox()
                for gx in range(b.left // GRID, b.right // GRID + 1):
                    for gy in range(b.bottom // GRID, b.top // GRID + 1):
                        for c in grid.get((gx, gy), ()):
                            if tp.inside(c): ok = True; break
                        if ok: break
                    if ok: break
                if ok: break
            if not ok:
                for poly in m1polys:      # top-level met1 or via1 on the pin's met1 strap
                    tp = poly.transformed(tr)
                    for (l, d) in ((68, 20), (68, 44)):
                        it4 = rec_iter(l, d, tp.bbox())
                        while it4 is not None and not it4.at_end():
                            sp = it4.shape().polygon
                            if sp is not None and pya.Region(sp.transformed(it4.trans())).interacting(pya.Region(tp)).count():
                                ok = True; m1hit[0] += 1; break
                            it4.next()
                        if ok: break
                    if ok: break
            if ok: hit += 1
            elif len(miss_ex) < 8:
                miss_ex.append("%s/%s@(%.2f,%.2f)" % (ly.cell(inst.cell_index).name.replace("sky130_fd_sc_hd__", ""),
                                                      name, inst.dcplx_trans.disp.x, inst.dcplx_trans.disp.y))
        # met1 rails on every 25th logic cell
        rail_n += 1
        if rail_n % 25 == 0 and m1li is not None:
            for s in ly.cell(inst.cell_index).shapes(m1li).each():
                if s.is_text(): continue
                b = s.bbox().transformed(tr)
                rail_tot += 1
                it2 = rec_iter(68, 20, b)
                if it2 is not None and not it2.at_end(): rail_hit += 1
    print("PINS    routing mcons: %d; std-cell signal pins reached by routing: %d of %d (%.1f%%; %d of them on the"
          " cell's met1 strap rather than through an mcon on li1)"
          % (n_mcon, hit, tot, 100.0 * hit / max(tot, 1), m1hit[0]))
    if miss_ex: print("        not reached (unused outputs are expected here), e.g. " + ", ".join(miss_ex))
    print("        std-cell met1 power pins touched by top-level met1 (every 25th cell): %d of %d" % (rail_hit, rail_tot))
    pinres["stdcell_signal_pins"] = [hit, tot]; pinres["stdcell_rails_sampled"] = [rail_hit, rail_tot]
    if tot and hit < 0.9 * tot: WARN("only %.1f%% of std-cell signal pins have a routing mcon" % (100.0 * hit / tot))
    if rail_tot and rail_hit < rail_tot: WARN("%d sampled std-cell power pins not on a top-level met1 rail" % (rail_tot - rail_hit))

    # hard macros
    blocks = [ci for ci in lib_roots if masters.get(ly.cell(ci).name, (0, ""))[1].startswith("block")] if masters else []
    for ci in blocks:
        c = ly.cell(ci)
        terms = {}   # pin name -> (metal gds layer, [polygons in macro coords])
        for L in range(67, 73):
            dli = ly.find_layer(L, 20)
            if dli is None: continue
            reg = pya.Region(c.begin_shapes_rec(dli))
            named = pin_name_shapes(c, L, 16, L, 5)
            pts = []
            for name, polys in named.items():
                for poly in polys:
                    pts.append((name, poly.bbox().center()))
            tli = ly.find_layer(L, 5)
            if tli is not None:
                for s in c.shapes(tli).each(pya.Shapes.STexts):
                    pts.append((s.text_string, s.text_pos))
            for name, p in pts:
                if name == "?": continue
                sel = reg.interacting(pya.Region(pya.Box(p.x - 1, p.y - 1, p.x + 1, p.y + 1)))
                if sel.is_empty(): continue
                e = terms.setdefault((name, L), pya.Region())
                e.insert(sel)
        for inst in top.each_inst():
            if inst.cell_index != ci: continue
            tr = inst.cplx_trans
            hitpins = {}
            for (name, L), reg in sorted(terms.items()):
                treg = reg.merged().transformed(tr)
                ok = False
                for (l, d) in ((L, 20), (L - 1, 44), (L, 44)):
                    li = ly.find_layer(l, d)
                    if li is None: continue
                    for poly in treg.each():
                        it3 = rec_iter(l, d, poly.bbox())
                        while it3 is not None and not it3.at_end():
                            sp = it3.shape().polygon
                            if sp is not None and pya.Region(sp.transformed(it3.trans())).interacting(pya.Region(poly)).count():
                                ok = True; break
                            it3.next()
                        if ok: break
                    if ok: break
                hitpins.setdefault(name, []).append((L, ok))
            # a pin counts as reached if any of its layers is reached
            okn = sorted(n for n, v in hitpins.items() if any(o for _, o in v))
            bad_ = sorted("%s(%s)" % (n, ",".join(str(L) for L, _ in v)) for n, v in hitpins.items() if not any(o for _, o in v))
            d = inst.dcplx_trans.disp
            print("MACRO   %s at (%.2f, %.2f) %s: %d of %d pins touched by top-level routing/vias"
                  % (c.name, d.x, d.y, inst.dcplx_trans.to_s(), len(okn), len(okn) + len(bad_)))
            if bad_:
                print("        untouched: " + " ".join(bad_))
                WARN("%s at (%.1f, %.1f): %d pins not touched by top-level routing/vias" % (c.name, d.x, d.y, len(bad_)))
            pinres.setdefault("macros", []).append({"cell": c.name, "at": [d.x, d.y], "ok": okn, "untouched": bad_})
    print("PINCHECK done in %.0f s" % (time.time() - T1))

print("RESULT  %s  (%d FAIL, %d WARN, %.0f s)" % ("PASS" if not fails else "FAIL", len(fails), len(warns), time.time() - T0))
if JSON_OUT:
    with open(JSON_OUT, "w") as fh:
        _json.dump({"gds": GDS, "top": top.name, "bbox_um": [bb.left, bb.bottom, bb.right, bb.top],
                    "cells": ly.cells(), "empty_masters": empty_masters, "empty_lib_subcells": empty_sub, "ghosts": ghosts, "bad_layers": ["%d/%d" % k for k in bad],
                    "layers": dict(("%d/%d" % k, v[0]) for k, v in per_layer.items()),
                    "labels": len(labs), "pins": pinres, "fails": fails, "warns": warns}, fh, indent=1)
sys.exit(1 if fails else 0)
