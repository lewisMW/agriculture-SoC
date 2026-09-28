# label_plates.py -- label MOM-cap plates for QRC extraction (sky130_cw_ip)
#
# Adds PLUS/MINUS met2 label text (layer 69:5) to the two largest disjoint
# met2 plates of every *leaf* cell in the GDS, so Pegasus/Quantus resolve
# named cap terminals. Also reports whether the requested top cell is a
# leaf (single cell) or hier (array of instances).
#
# Run:  klayout -b -r label_plates.py -rd gds=IN.gds -rd cell=CELL -rd out=OUT.gds
import pya


def find_layer(ly, lnum, dt):
    for li in ly.layer_indexes():
        info = ly.get_info(li)
        if info.layer == lnum and info.datatype == dt:
            return li
    return -1


def point_on(c, met2, plate):
    """A point guaranteed to sit on the plate metal (for label placement)."""
    pr = pya.Region(plate)
    for s in c.shapes(met2).each():
        ctr = s.bbox().center()
        tb = pya.Region(pya.Box(ctr.x - 1, ctr.y - 1, ctr.x + 1, ctr.y + 1))
        if not (pr & tb).is_empty():
            return ctr
    return plate.bbox().center()


ly = pya.Layout()
ly.read(gds)                       # gds, cell, out come from -rd
target = ly.cell(cell)
if target is None:
    raise Exception("cell not found in GDS: %s" % cell)

celltype = "hier" if target.child_cells() > 0 else "leaf"

met2 = find_layer(ly, 69, 20)      # met2 drawing
lbl = ly.layer(69, 5)              # met2 label purpose (read as port by LVS deck)

nlabeled = 0
if met2 >= 0:
    for c in ly.each_cell():
        if c.child_cells() > 0:            # only leaf cells hold plate metal
            continue
        if c.shapes(met2).size() == 0:
            continue
        reg = pya.Region(c.shapes(met2))
        reg.merge()
        plates = sorted([p for p in reg.each()], key=lambda p: -p.area())
        if len(plates) < 2:                # need two plates to label a cap
            continue
        for name, plate in zip(["PLUS", "MINUS"], plates[:2]):
            pt = point_on(c, met2, plate)
            c.shapes(lbl).insert(pya.Text(name, pya.Trans(pt.x, pt.y)))
        nlabeled += 1

ly.write(out)
print("CELLTYPE=%s" % celltype)
print("LABELED_CELLS=%d" % nlabeled)
