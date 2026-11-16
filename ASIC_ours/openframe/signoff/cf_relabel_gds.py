# klayout -b -r cf_relabel_gds.py -rd gds=<in.gds> -rd out=<out.gds> [-rd cell=sar_afe]
#
# Copy of a GDS for ChipFoundry's Magic/netgen LVS with the bus texts of one macro
# changed from <n> to [n]. The ADC macro's pin texts are written "ctln<7>" (Virtuoso
# style); the Verilog netlist and Magic's abstract of the macro need "ctln[7]", or
# the macro's bus pins do not match by name. Only text strings in that one cell
# change: no shape, instance or other cell is touched.
import pya

target = cell if "cell" in dir() else "sar_afe"
ly = pya.Layout()
ly.read(gds)
c = ly.cell(target)
if c is None:
    raise SystemExit("cell %s not found in %s" % (target, gds))
n = 0
for li in ly.layer_indices():
    for s in c.shapes(li).each(pya.Shapes.STexts):
        t = s.text
        new = t.string.replace("<", "[").replace(">", "]")
        if new != t.string:
            t.string = new
            s.text = t
            n += 1
opt = pya.SaveLayoutOptions()
opt.format = "GDS2"
opt.gds2_write_timestamps = False
ly.write(out, opt)
print("%s: %d texts relabelled in cell %s; %d cells, top cells: %s" % (
    out, n, target, ly.cells(), ", ".join(x.name for x in ly.top_cells())))
