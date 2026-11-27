# klayout -b -r gds_pin_texts_only.py -rd gds=<in.gds> -rd out=<out.gds> -rd lefs=<a.lef,b.lef,...>
#
# Copy of a GDS in which each macro named by a LEF keeps only the text labels that
# are pin names of that LEF. The DFFRAM compiler's blocks come with a label on
# every internal net (31,000 in a 2 kbyte block, 81 of them pins). A black box in
# LVS takes its ports from the labels in the cell, so with those labels the block
# cannot be compared by its pins. Shapes, instances and other cells are untouched.
import pya, re

ly = pya.Layout()
ly.read(gds)
total = 0
for lef in lefs.split(","):
    t = open(lef).read()
    for m in re.finditer(r"MACRO (\S+)\n(.*?)END \1\n", t, re.S):
        name, body = m.group(1), m.group(2)
        pins = set(re.findall(r"\n\s*PIN (\S+)", body))
        c = ly.cell(name)
        if c is None:
            print("%s: not in %s" % (name, gds)); continue
        kept = dropped = 0
        for li in ly.layer_indices():
            for s in list(c.shapes(li).each(pya.Shapes.STexts)):
                if s.text.string.replace("\\", "") in pins: kept += 1
                else:
                    c.shapes(li).erase(s); dropped += 1
        total += dropped
        print("%s: %d pins in the LEF, %d pin texts kept, %d other texts removed" % (name, len(pins), kept, dropped))
opt = pya.SaveLayoutOptions()
opt.format = "GDS2"
opt.gds2_write_timestamps = False
ly.write(out, opt)
print("%s written, %d texts removed" % (out, total))
