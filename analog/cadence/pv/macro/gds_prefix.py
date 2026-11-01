# gds_prefix.py -- copy a GDS, prefixing every cell name except the top cell,
# so a hard macro's subcells (inverter, carray_8b, the PDK pcell variants...)
# cannot collide with same-named cells of other GDS merged at chip level.
#
#   klayout -b -r gds_prefix.py -rd src=in.gds -rd dst=out.gds \
#           -rd top=sar_afe -rd prefix=sar_afe__
import pya

ly = pya.Layout()
ly.read(src)
tops = ly.top_cells()
if len(tops) != 1 or tops[0].name != top:
    raise RuntimeError("expected one top cell %s, got %s" % (top, [c.name for c in tops]))
n = 0
for c in ly.each_cell():
    if c.cell_index() != tops[0].cell_index() and not c.name.startswith(prefix):
        ly.rename_cell(c.cell_index(), prefix + c.name)
        n += 1
ly.write(dst)
layers = sorted("%d/%d" % (ly.get_info(i).layer, ly.get_info(i).datatype) for i in ly.layer_indexes())
print("GDS %s: top %s, %d subcells renamed, dbu %g, bbox %s, layers %s"
      % (dst, top, n, ly.dbu, tops[0].dbbox(), " ".join(layers)))
