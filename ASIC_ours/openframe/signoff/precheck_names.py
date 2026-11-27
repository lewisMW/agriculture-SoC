# klayout -b -r precheck_names.py -rd gds=<file> -rd check=topcell_check|illegal_cellname_check
# The two cf-precheck checks that only look at cell names (checks/topcell.py,
# checks/illegal_cellname.py): exactly one top cell, and no '#' or '/' in the
# name of any cell below it. The last line printed is the result; exit 1 = fail.
import sys
import pya

ly = pya.Layout()
ly.read(gds)
tops = [c.name for c in ly.top_cells()]
if check == "topcell_check":
    print("%d top cell(s): %s" % (len(tops), ", ".join(tops[:10])))
    sys.exit(0 if len(tops) == 1 else 1)

top = ly.top_cell()
bad = sorted(ly.cell(i).name for i in top.called_cells()
             if "#" in ly.cell(i).name or "/" in ly.cell(i).name)
for n in bad[:50]:
    print("illegal:", n)
print("%d of %d cell names contain '#' or '/'" % (len(bad), len(top.called_cells())))
sys.exit(1 if bad else 0)
