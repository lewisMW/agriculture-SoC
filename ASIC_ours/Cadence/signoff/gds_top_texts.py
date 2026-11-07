#!/usr/bin/env python3
"""gds_top_texts.py -- list the text labels of one cell of a GDS (stdlib only).

  gds_top_texts.py <file.gds> <cell>        prints: name layer texttype x_um y_um
  gds_top_texts.py --one-per-net <file.gds> <cell> NET...
                                            prints Pegasus rules that delete
                                            all but the first top-level text of
                                            each NET, and lists NETs without text
  gds_top_texts.py --none-per-net ...      same, deleting every text of each NET

Used by run_chip_lvs.sh. A supply port labelled on every one of its supply
pads' bond pads gives several top-level texts of one name; with the pads as
hard black boxes those bond pads are separate nets at extraction time, and
Pegasus rejects the duplicates ("Top level port name ... already used on net
..."). One text per supply is enough to name it: the other bond pads join it
through the pad ring (lvs_join_nets X X_PAD in the supply-pad black boxes),
so a broken ring still shows up as an unmatched net.
"""
import struct
import sys

BGNSTR, STRNAME, ENDSTR, TEXT, LAYER, XY, ENDEL, STRING, TEXTTYPE, UNITS = (
    0x05, 0x06, 0x07, 0x0C, 0x0D, 0x10, 0x11, 0x19, 0x16, 0x03)


def texts(path, cell):
    with open(path, "rb") as f:
        data = f.read()
    n = len(data)
    i = 0
    uu = 1e-3  # user units per db unit, from UNITS
    in_cell = False
    cur = None
    out = []
    while i + 4 <= n:
        ln, rt = struct.unpack_from(">HB", data, i)
        if ln < 4:
            break
        body = i + 4
        if rt == UNITS:
            uu_db = struct.unpack_from(">8s8s", data, body)
            # GDS 8-byte reals: convert excess-64 base-16
            def real8(b):
                s = -1 if b[0] & 0x80 else 1
                e = (b[0] & 0x7F) - 64
                m = int.from_bytes(b[1:], "big") / float(1 << 56)
                return s * m * 16 ** e
            uu = real8(uu_db[0])
        elif rt == STRNAME:
            name = data[body:i + ln].rstrip(b"\0").decode("ascii", "replace")
            in_cell = name == cell
        elif rt == ENDSTR:
            if in_cell:
                break
            in_cell = False
        elif in_cell:
            if rt == TEXT:
                cur = {}
            elif cur is not None:
                if rt == LAYER:
                    cur["layer"] = struct.unpack_from(">h", data, body)[0]
                elif rt == TEXTTYPE:
                    cur["tt"] = struct.unpack_from(">h", data, body)[0]
                elif rt == XY:
                    cur["xy"] = struct.unpack_from(">ii", data, body)
                elif rt == STRING:
                    cur["s"] = data[body:i + ln].rstrip(b"\0").decode("ascii", "replace")
                elif rt == ENDEL:
                    out.append(cur)
                    cur = None
        i += ln
    return [(t.get("s", ""), t.get("layer"), t.get("tt"), t["xy"][0] * uu, t["xy"][1] * uu)
            for t in out if "xy" in t]


if __name__ == "__main__":
    if sys.argv[1] in ("--one-per-net", "--none-per-net"):
        keep = sys.argv[1] == "--one-per-net"
        gds, cell, nets = sys.argv[2], sys.argv[3], sys.argv[4:]
        seen = {}
        print("// %s top-level text per supply net (gds_top_texts.py %s)" % (
            "one" if keep else "no", sys.argv[1]))
        for s, l, tt, x, y in texts(gds, cell):
            if s in nets:
                if not keep:
                    print("add_text %.4f %.4f   // drop %s on %d/%d (named from the DEF instead)"
                          % (x, y, s, l, tt))
                elif s in seen:
                    print("add_text %.4f %.4f   // drop duplicate %s on %d/%d (kept %.3f,%.3f)"
                          % (x, y, s, l, tt, seen[s][0], seen[s][1]))
                else:
                    seen[s] = (x, y)
                    print("// keep %s at (%.4f, %.4f) on %d/%d" % (s, x, y, l, tt))
        print("// NO_TEXT %s" % " ".join(n for n in nets if n not in seen or not keep))
    else:
        for s, l, tt, x, y in texts(sys.argv[1], sys.argv[2]):
            print("%s %s %s %.4f %.4f" % (s, l, tt, x, y))
