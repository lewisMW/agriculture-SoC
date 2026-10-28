# =====================================================================
# merge_fill.py -- FILLGEN GDS_flow steps 3a + 3b in KLayout (batch)
#
#   klayout -b -r merge_fill.py -rd chip=<chip.gds> -rd top=<cell>
#       -rd fill=<top>.fill.gds.gz -rd cells=poly_diff_3_10_25.gds.gz
#       -rd out=<top>.filled.gds
#
# 3a: every reference to a placeholder poly_diff_<n>_FILL (written by the
#     fill deck as arrays of a bare diff rectangle) is pointed at the real
#     poly_diff_<n>_FILLCELL from the PDK's poly_diff_3_10_25 GDS, as the
#     pdr_CTL_aref REPLACE lines do. The placeholders are then dropped.
# 3b: the fill top cell <top>_FILL is placed at (0,0) R0 in <top>, as
#     pdr_CTL does.
# fix=1 (default; fix=0 to skip) repairs two defects of the fill deck's
# output, see "repairs" below. drop=<L>[,<L>...] removes the fill on those
# GDS layers (<L>/99), e.g. drop=67 for li1.
# The chip's own cells are not touched. Fails if a fill/fill-cell name
# collides with a chip cell name.
# =====================================================================
import sys, time
import pya

G = globals()
def opt(n):
    v = G.get(n)
    if v in (None, ""):
        print("missing -rd %s" % n); sys.exit(2)
    return v
CHIP, TOP, FILL, CELLS, OUT = opt("chip"), opt("top"), opt("fill"), opt("cells"), opt("out")
T0 = time.time()

def names(path):
    l = pya.Layout(); l.read(path)
    return set(c.name for c in l.each_cell())

ly = pya.Layout()
ly.read(CHIP)
topc = ly.cell(TOP)
if topc is None:
    print("top cell %s not in %s" % (TOP, CHIP)); sys.exit(1)
chip_names = set(c.name for c in ly.each_cell())
fill_names, cell_names = names(FILL), names(CELLS)
clash = (fill_names | cell_names) & chip_names
if clash:
    print("name clash between fill and chip cells: %s" % " ".join(sorted(clash)[:20])); sys.exit(1)
print("merge_fill: chip %d cells; fill GDS %d cells (top %s_FILL; the fill deck mirrors the chip"
      " hierarchy as <cell>_FILL cells); fill-cell GDS %d cells"
      % (len(chip_names), len(fill_names), TOP, len(cell_names)))

ly.read(FILL)
ly.read(CELLS)
fill_top = ly.cell(TOP + "_FILL")
if fill_top is None:
    print("fill top cell %s_FILL not found" % TOP); sys.exit(1)

# ---- 3a -------------------------------------------------------------------
for n in (3, 10, 25):
    ph = ly.cell("poly_diff_%d_FILL" % n)
    fc = ly.cell("poly_diff_%d_FILLCELL" % n)
    if ph is None:
        print("  poly_diff_%d_FILL: not used" % n); continue
    if fc is None:
        print("poly_diff_%d_FILLCELL missing from %s" % (n, CELLS)); sys.exit(1)
    print("  poly_diff_%d_FILL bbox %s -> poly_diff_%d_FILLCELL bbox %s"
          % (n, ph.dbbox(), n, fc.dbbox()))
    nref = 0; nplaced = 0
    for pci in list(ph.each_parent_cell()):
        parent = ly.cell(pci)
        for inst in list(parent.each_inst()):
            if inst.cell_index == ph.cell_index():
                nplaced += inst.size() if inst.is_regular_array() else 1
                inst.cell_index = fc.cell_index()
                nref += 1
    ly.delete_cell(ph.cell_index())
    print("  poly_diff_%d: %d references (%d placements) now point at the FILLCELL" % (n, nref, nplaced))

# drop top cells that came with the fill-cell library and are not used
for c in list(ly.top_cells()):
    if c.cell_index() not in (topc.cell_index(), fill_top.cell_index()):
        print("  dropping unused library top cell %s" % c.name)
        ly.prune_cell(c.cell_index(), -1)

# ---- repairs (fix=1, the default) -------------------------------------------
# fillgen.v08 breaks two of the deck's own fill rules on this chip:
#  * poly fill (66/99) off the 5 nm grid (x.1b): such shapes are removed
#    (removing fill can only lower poly density, never add a spacing error)
#  * diff fill (65/99) longer than 25 um (diff.fill.3): the deck's filler-row
#    pass emits strips up to a row long. Each merged strip longer than 25 um is
#    cut into equal pieces of at most 24.5 um with 0.5 um gaps (diff fill to
#    diff fill spacing is 0.4 um), snapped to the 5 nm grid.
FIX = str(G.get("fix", "1")) == "1"
if FIX:
    GRID = 5
    fill_cells = [fill_top.cell_index()] + [ci for ci in fill_top.called_cells()
                                            if not ly.cell(ci).name.endswith("_FILLCELL")]
    li66 = ly.find_layer(66, 99)
    nrm = 0
    if li66 is not None:
        for ci in fill_cells:
            sh = ly.cell(ci).shapes(li66)
            bad = [x for x in sh.each() if any(v % GRID for v in (x.bbox().left, x.bbox().bottom, x.bbox().right, x.bbox().top))]
            for x in bad:
                sh.erase(x)
            nrm += len(bad)
    print("  fix: removed %d poly fill shapes off the 5 nm grid" % nrm)
    li65 = ly.find_layer(65, 99)
    MAXL, GAP = int(24.5 / ly.dbu), int(0.5 / ly.dbu)
    ncut = npieces = nleft = 0
    if li65 is not None:
        for ci in fill_cells:
            c = ly.cell(ci)
            sh = c.shapes(li65)
            if sh.is_empty(): continue
            reg = pya.Region(sh); reg.merge()
            out = pya.Region()
            changed = False
            for poly in reg.each():
                b = poly.bbox()
                L = max(b.width(), b.height())
                if L * ly.dbu <= 25.0:
                    out.insert(poly); continue
                if not poly.is_box():
                    out.insert(poly); nleft += 1; continue
                changed = True; ncut += 1
                n = -(-(L + GAP) // (MAXL + GAP))
                seg = ((L - (n - 1) * GAP) // n) // GRID * GRID
                horiz = b.width() >= b.height()
                start = b.left if horiz else b.bottom
                for k in range(n):
                    a = start + k * (seg + GAP)
                    e = (b.right if horiz else b.top) if k == n - 1 else a + seg
                    out.insert(pya.Box(a, b.bottom, e, b.top) if horiz else pya.Box(b.left, a, b.right, e))
                    npieces += 1
            if changed:
                sh.clear()
                sh.insert(out)
    print("  fix: cut %d diff fill strips longer than 25 um into %d pieces%s"
          % (ncut, npieces, "" if not nleft else "; %d non-rectangular strips left as they are" % nleft))

# ---- dropped fill layers (drop=67,... : GDS layer numbers, datatype 99) ------
# For a layer that already meets its density without fill and that the fill
# would push over its maximum (li1 on a decap-filled core: CDRW.li.global.max).
DROP = [int(x) for x in str(G.get("drop") or "").replace("/99", "").split(",") if x.strip()]
for L in DROP:
    li = ly.find_layer(L, 99)
    if li is None: continue
    n = 0
    for ci in [fill_top.cell_index()] + list(fill_top.called_cells()):
        if ly.cell(ci).name.endswith("_FILLCELL"): continue
        sh = ly.cell(ci).shapes(li); n += sh.size(); sh.clear()
    print("  drop: removed all %d fill shapes on %d/99" % (n, L))

# ---- 3b -------------------------------------------------------------------
topc.insert(pya.CellInstArray(fill_top.cell_index(), pya.Trans()))

# ---- stats ------------------------------------------------------------------
fill_cells = [fill_top.cell_index()] + list(fill_top.called_cells())
for li in sorted(ly.layer_indexes(), key=lambda i: (ly.get_info(i).layer, ly.get_info(i).datatype)):
    info = ly.get_info(li)
    if info.datatype != 99: continue
    nshape = sum(ly.cell(ci).shapes(li).size() for ci in fill_cells)
    if nshape:
        print("  fill %d/%d: %d shapes in the fill hierarchy (arrays count once)" % (info.layer, info.datatype, nshape))
tops = [c.name for c in ly.top_cells()]
if tops != [TOP]:
    print("unexpected top cells after merge: %s" % tops); sys.exit(1)
ly.write(OUT)
print("merge_fill: wrote %s in %.0f s" % (OUT, time.time() - T0))
