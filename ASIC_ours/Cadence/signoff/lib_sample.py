# =====================================================================
# lib_sample.py -- one placement of each given master, copied out of a chip
# GDS, 50 um apart in a new top cell. DRC of this file shows which chip DRC
# results a library/IP cell has on its own (KLayout batch).
#
#   klayout -b -r lib_sample.py -rd gds=<chip.gds> -rd out=<sample.gds>
#       -rd cells=<master1>,<master2>,...  [-rd top=lib_sample]
#   then: run_chip_drc.sh <sample.gds> lib_sample <dir>
# =====================================================================
import sys
import pya
G = globals()
for n in ("gds", "out", "cells"):
    if not G.get(n):
        print("missing -rd %s" % n); sys.exit(2)
src = pya.Layout(); src.read(gds)
ly = pya.Layout(); ly.dbu = src.dbu
topc = ly.create_cell(G.get("top") or "lib_sample")
x = 0
for name in cells.split(","):
    sc = src.cell(name)
    if sc is None:
        print("not in %s: %s" % (gds, name)); sys.exit(1)
    tc = ly.create_cell(name)
    tc.copy_tree(sc)
    b = tc.bbox()
    topc.insert(pya.CellInstArray(tc.cell_index(), pya.Trans(pya.Point(x - b.left, -b.bottom))))
    print("%-40s at x=%.1f um, %.1f x %.1f um" % (name, x * ly.dbu, b.width() * ly.dbu, b.height() * ly.dbu))
    x += b.width() + int(50 / ly.dbu)
ly.write(out)
print("wrote", out)
