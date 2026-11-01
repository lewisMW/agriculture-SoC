#!/usr/bin/env python3
"""export_macro.py -- abstract views of a sar_afe macro variant for the digital flow.

  export_macro.py --cell sar_afe --pins sar_afe.pins --sch sar_afe.sch.scs
                  [--sch-top sar_afe] [--pex sar_afe.pex.scs] [--pex-top sar_afe]
                  [--cdl sar_afe.cdl --prefix sar_afe__] --out DIR

Writes, into DIR (CELL = --cell: sar_afe, sar_afe_r or sar_afe_b):
  CELL.lef     CLASS BLOCK; pins as drawn in the layout (afe_pins.il dump);
               OBS on li1..met5 over the whole outline except the pin shapes
               (met5 only over the region the macro uses it);
               antenna gate/diffusion areas per pin from the schematic netlist
  CELL__<corner>.lib  one per corner in CORNERS: pin capacitances and
               the comparator's clk -> outp/outn arcs (estimates, see below)
  CELL.v       port declaration only (black box)
  CELL.cdl     (with --cdl) the LVS source netlist, subcells renamed with
               --prefix to match the GDS written by gds_prefix.py
The variants share one circuit, so --sch-top/--pex-top can name sar_afe's
netlists for all three (the variants are sar_afe mirrored or rotated).

Pin capacitance = gate capacitance (W*L*COX + 2*W*COV over the gates the
pin reaches, schematic netlist) + wire capacitance (every extracted
capacitor with one end on the pin's net, --pex). Python 3.6.
"""
import argparse
import datetime
import os
import re
import sys

CELL = "sar_afe"  # set from --cell
LAYERS = ["li1", "met1", "met2", "met3", "met4", "met5"]
COX = 8.3e-3     # pF/um2, sky130 1.8 V gate oxide (tox ~4.1 nm)
COV = 0.25e-3    # pF/um per side, gate-source/drain overlap (estimate)
CMIM = 2.0e-3    # pF/um2, cap_mim_m3_1 area capacitance
OBS_MARGIN = 2.0  # um around a partially used layer's shapes (met5 space 1.6)
# comparator timing (estimates until Erick's characterisation, M3):
# clk rises -> one output falls (decision); clk falls -> both rise (reset)
T_DECIDE, T_RESET, T_SLEW, C_MAX = 1.0, 0.3, 0.3, 0.03   # ns, ns, ns, pF
# one Liberty file per corner of the digital flow's MMMC (ASIC_ours/Cadence/
# scripts/nanosoc_chip_pads.mmmc); delays scaled from typical (estimate)
CORNERS = [("ss_100C_1v60", 1, 100.0, 1.60, 1.6),
           ("tt_025C_1v80", 1, 25.0, 1.80, 1.0),
           ("tt_100C_1v80", 1, 100.0, 1.80, 1.15),
           ("ff_100C_1v95", 1, 100.0, 1.95, 0.75)]

SI = {"a": 1e-18, "f": 1e-15, "p": 1e-12, "n": 1e-9, "u": 1e-6, "m": 1e-3,
      "k": 1e3, "M": 1e6, "G": 1e9}


def num(s):
    s = s.strip().strip("()")
    m = re.match(r"^([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)([afpnumkMG]?)", s)
    if not m:
        raise ValueError("not a number: %r" % s)
    return float(m.group(1)) * SI.get(m.group(2), 1.0)


# ------------------------------------------------------------ Spectre parse --
def read_spectre(path):
    """{subckt: {"ports": [...], "insts": [(name, nodes, model, params)]}}"""
    text, cur = [], ""
    for line in open(path):
        line = line.rstrip("\n")
        if line.lstrip().startswith("//"):
            continue
        if re.search(r"\s\\$", line):
            cur += line[:-1] + " "
            continue
        text.append(cur + line)
        cur = ""
    subs, sub = {}, None
    for line in text:
        t = line.strip()
        if not t:
            continue
        if t.startswith("subckt "):
            w = t.split()
            sub = {"ports": [unesc(p) for p in w[2:]], "insts": []}
            subs[unesc(w[1])] = sub
            continue
        if t.startswith("ends"):
            sub = None
            continue
        if sub is None:
            continue
        m = re.match(r"^(\S+)\s*\(([^)]*)\)\s*(\S+)\s*(.*)$", t)
        if not m:
            continue
        params = {k: v for k, v in re.findall(r"(\w+)=(\([^)]*\)|\S+)", m.group(4))}
        sub["insts"].append((unesc(m.group(1)), [unesc(n) for n in m.group(2).split()],
                             unesc(m.group(3)), params))
    return subs


def unesc(s):
    return s.replace("\\", "")


def flatten(subs, top):
    """primitive instances of `top`, nodes mapped to top-level net names"""
    out = []

    def walk(name, netmap, path):
        for iname, nodes, model, params in subs[name]["insts"]:
            g = [netmap.get(n, path + n) for n in nodes]
            if model in subs:
                walk(model, dict(zip(subs[model]["ports"], g)), path + iname + "/")
            else:
                out.append((path + iname, g, model, params))

    walk(top, {p: p for p in subs[top]["ports"]}, "")
    return out


def areas(sch, top):
    """per top-level net: gate area (um2), gate width (um), diffusion area (um2)"""
    ga, gw, da, cmim = {}, {}, {}, {}
    for _, nodes, model, p in flatten(read_spectre(sch), top):
        if re.match(r"^[np]fet_", model):
            d, g, s = nodes[0], nodes[1], nodes[2]
            mult = num(p.get("m", "1"))
            w, l = num(p["w"]) * 1e6 * mult, num(p["l"]) * 1e6
            ga[g] = ga.get(g, 0.0) + w * l
            gw[g] = gw.get(g, 0.0) + w
            if "ad" in p:
                da[d] = da.get(d, 0.0) + num(p["ad"]) * 1e12 * mult
            if "as" in p:
                da[s] = da.get(s, 0.0) + num(p["as"]) * 1e12 * mult
        elif model.startswith("cap_mim"):
            c = num(p["l"]) * num(p["w"]) * 1e12 * CMIM * num(p.get("m", "1"))
            for n in nodes[:2]:
                cmim[n] = cmim.get(n, 0.0) + c
    return ga, gw, da, cmim


def wire_caps(pex, top):
    """per net: sum of extracted capacitors with exactly one end on it (pF)"""
    subs = read_spectre(pex)
    cw = {}
    net = lambda n: re.sub(r"^\d+:", "", n)
    for _, nodes, model, p in subs[top]["insts"]:
        if model != "capacitor":
            continue
        a, b = net(nodes[0]), net(nodes[1])
        if a != b:
            c = num(p["c"]) * 1e12
            cw[a] = cw.get(a, 0.0) + c
            cw[b] = cw.get(b, 0.0) + c
    return cw


# ------------------------------------------------------------------ pins --
def read_pins(path):
    size, pins, extent = None, {}, {}
    for line in open(path):
        w = line.split()
        if not w:
            continue
        if w[0] == "SIZE":
            size = [float(x) for x in w[1:5]]
        elif w[0] == "PIN":
            name, direction, layer = w[1], w[2], w[3]
            r = [float(x) for x in w[4:8]]
            pins.setdefault(name, {"dir": direction, "shapes": []})["shapes"].append((layer, r))
        elif w[0] == "EXTENT":
            extent[w[1]] = [float(x) for x in w[2:6]]
    if size is None or size[0] != 0 or size[1] != 0:
        sys.exit("pin dump: missing SIZE or PR boundary not at the origin")
    return size[2], size[3], pins, extent


def lefname(n):        # ctlp<3> -> ctlp[3]
    return re.sub(r"<(\d+)>$", r"[\1]", n)


def busof(n):
    m = re.match(r"^(\w+)<(\d+)>$", n)
    return (m.group(1), int(m.group(2))) if m else (n, None)


def subtract(full, holes):
    """full rect minus holes, as non-overlapping rects (horizontal bands,
    then vertically adjacent equal spans merged)"""
    x0, y0, x1, y1 = full
    hs = [(max(h[0], x0), max(h[1], y0), min(h[2], x1), min(h[3], y1)) for h in holes]
    hs = [h for h in hs if h[0] < h[2] and h[1] < h[3]]
    ys = sorted(set([y0, y1] + [h[1] for h in hs] + [h[3] for h in hs]))
    bands = []
    for ya, yb in zip(ys, ys[1:]):
        iv = sorted((h[0], h[2]) for h in hs if h[1] < yb and h[3] > ya)
        cur, spans = x0, []
        for a, b in iv:
            if a > cur:
                spans.append((cur, a))
            cur = max(cur, b)
        if cur < x1:
            spans.append((cur, x1))
        bands.append((ya, yb, spans))
    rects, open_ = [], {}
    for ya, yb, spans in bands:
        nxt = {}
        for s in spans:
            if s in open_ and open_[s][1] == ya:
                nxt[s] = (open_[s][0], yb)
            else:
                nxt[s] = (ya, yb)
        for s, (a, b) in open_.items():
            if s not in nxt or nxt[s][0] != a:
                rects.append((s[0], a, s[1], b))
        open_ = nxt
    rects += [(s[0], a, s[1], b) for s, (a, b) in open_.items()]
    return sorted(rects, key=lambda r: (r[1], r[0]))


# ---------------------------------------------------------------- writers --
def f3(v):
    return "%.3f" % v


def obs_region(layer, W, H, extent):
    """area to obstruct on a layer: the whole outline, or for a layer with an
    EXTENT in the pin dump, that extent grown by OBS_MARGIN (snapped to the
    outline edge when within the margin)"""
    if layer not in extent:
        return (0.0, 0.0, W, H)
    x0, y0, x1, y1 = extent[layer]
    m = OBS_MARGIN
    r = [max(0.0, x0 - m), max(0.0, y0 - m), min(W, x1 + m), min(H, y1 + m)]
    r = [0.0 if r[0] < m else r[0], 0.0 if r[1] < m else r[1],
         W if W - r[2] < m else r[2], H if H - r[3] < m else r[3]]
    return tuple(round(v, 3) for v in r)


def write_lef(path, W, H, pins, ga, da, stamp, extent):
    o = open(path, "w")
    o.write("# %s.lef -- ADC analog front end hard macro (%s)\n" % (CELL, stamp))
    o.write("# Generated by analog/cadence/pv/macro/export_macro.sh; do not edit.\n")
    o.write("VERSION 5.8 ;\nBUSBITCHARS \"[]\" ;\nDIVIDERCHAR \"/\" ;\n\n")
    o.write("MACRO %s\n  CLASS BLOCK ;\n  FOREIGN %s 0 0 ;\n  ORIGIN 0 0 ;\n" % (CELL, CELL))
    o.write("  SIZE %s BY %s ;\n  SYMMETRY X Y ;\n" % (f3(W), f3(H)))
    for name in sorted(pins, key=sortkey):
        p = pins[name]
        use = {"vdd": "POWER", "vdda": "POWER", "vref": "POWER", "vss": "GROUND"}.get(name, "SIGNAL")
        d = {"input": "INPUT", "output": "OUTPUT"}.get(p["dir"], "INOUT")
        o.write("  PIN %s\n    DIRECTION %s ;\n    USE %s ;\n" % (lefname(name), d, use))
        if use == "SIGNAL":
            if ga.get(name, 0) > 0:
                o.write("    ANTENNAGATEAREA %.4f ;\n" % ga[name])
            if da.get(name, 0) > 0:
                o.write("    ANTENNADIFFAREA %.4f ;\n" % da[name])
        for layer, r in p["shapes"]:       # each shape its own PORT (strongly connected)
            o.write("    PORT\n      LAYER %s ;\n        RECT %s ;\n    END\n"
                    % (layer, " ".join(f3(v) for v in r)))
        o.write("  END %s\n" % lefname(name))
    o.write("  OBS\n")
    nobs = 0
    for layer in LAYERS:
        holes = [r for p in pins.values() for (l, r) in p["shapes"] if l == layer]
        o.write("    LAYER %s ;\n" % layer)
        for r in subtract(obs_region(layer, W, H, extent), holes):
            o.write("      RECT %s ;\n" % " ".join(f3(v) for v in r))
            nobs += 1
    o.write("  END\nEND %s\n\nEND LIBRARY\n" % CELL)
    o.close()
    return nobs


def sortkey(n):
    b, i = busof(n)
    return (b, -1 if i is None else i)


def write_lib(path, W, H, pins, cpin, stamp, corner):
    cname, proc, temp, volt, k = corner
    o = open(path, "w")
    w = o.write
    w("/* %s__%s.lib -- ADC analog front end hard macro (%s).\n" % (CELL, cname, stamp))
    w("   Generated by analog/cadence/pv/macro/export_macro.sh; do not edit.\n")
    w("   Pin capacitance = gate (schematic) + wire (Quantus RC extraction).\n")
    w("   clk -> outp/outn: the comparator latch. clk rising starts the decision\n")
    w("   and pulls ONE output low; clk falling resets both high. The delays are\n")
    w("   conservative estimates (typical: decision %.1f ns, reset %.1f ns; this\n" % (T_DECIDE, T_RESET))
    w("   corner x%.2f) pending the comparator characterisation; the SAR samples\n" % k)
    w("   the decision half a clock period later. vinp/vinn are analog: their\n")
    w("   capacitance is the switch and wiring only; the CDAC sampling\n")
    w("   capacitance is in the README. */\n")
    w("library (%s__%s) {\n" % (CELL, cname))
    for a in ['technology (cmos) ;', 'delay_model : table_lookup ;', 'time_unit : "1ns" ;',
              'voltage_unit : "1V" ;', 'current_unit : "1mA" ;',
              'pulling_resistance_unit : "1kohm" ;', 'leakage_power_unit : "1nW" ;',
              'capacitive_load_unit (1, pf) ;', 'nom_process : %.1f ;' % proc,
              'nom_temperature : %.1f ;' % temp, 'nom_voltage : %.2f ;' % volt,
              'operating_conditions (%s) { process : %.1f ; temperature : %.1f ; voltage : %.2f ; }'
              % (cname, proc, temp, volt),
              'default_operating_conditions : %s ;' % cname,
              'voltage_map (vdd, %.2f) ;' % volt, 'voltage_map (vdda, %.2f) ;' % volt,
              'voltage_map (vref, %.2f) ;' % volt,
              'voltage_map (vss, 0.0) ;',
              'input_threshold_pct_rise : 50 ;', 'input_threshold_pct_fall : 50 ;',
              'output_threshold_pct_rise : 50 ;', 'output_threshold_pct_fall : 50 ;',
              'slew_lower_threshold_pct_rise : 20 ;', 'slew_upper_threshold_pct_rise : 80 ;',
              'slew_lower_threshold_pct_fall : 20 ;', 'slew_upper_threshold_pct_fall : 80 ;',
              'slew_derate_from_library : 1.0 ;', 'default_max_transition : 1.5 ;']:
        w("  %s\n" % a)
    buses = {}
    for n in pins:
        b, i = busof(n)
        if i is not None:
            buses.setdefault(b, []).append(i)
    for b, idx in sorted(buses.items()):
        w("  type (%s_t) { base_type : array ; data_type : bit ; bit_width : %d ; "
          "bit_from : %d ; bit_to : 0 ; downto : true ; }\n" % (b, len(idx), max(idx)))
    w("  cell (%s) {\n    area : %.3f ;\n    is_macro_cell : true ;\n" % (CELL, W * H))
    w("    dont_touch : true ;\n    dont_use : true ;\n")
    w("    pg_pin (vdd) { pg_type : primary_power ; voltage_name : vdd ; }\n")
    w("    pg_pin (vdda) { pg_type : primary_power ; voltage_name : vdda ; }\n")
    w("    pg_pin (vref) { pg_type : primary_power ; voltage_name : vref ; }\n")
    w("    pg_pin (vss) { pg_type : primary_ground ; voltage_name : vss ; }\n")

    def pinbody(n, ind):
        p = pins[n]
        s = ""
        # ctlp/ctln drive the CDAC bit-driver inverters, on vref; sample
        # drives the switches, on vdda; the comparator's pins are on vdd
        rel = "related_power_pin : %s ; related_ground_pin : vss ;" % (
            {"ctlp": "vref", "ctln": "vref", "sample": "vdda"}.get(busof(n)[0], "vdd"))
        if p["dir"] == "output":
            s += "%sdirection : output ; max_capacitance : %.4f ; %s\n" % (ind, C_MAX, rel)
            s += ("%stiming () {\n%s  related_pin : \"clk\" ; timing_sense : negative_unate ; "
                  "timing_type : combinational ;\n" % (ind, ind))
            s += "%s  cell_fall (scalar) { values (\"%.3f\") ; }\n" % (ind, T_DECIDE * k)
            s += "%s  fall_transition (scalar) { values (\"%.3f\") ; }\n" % (ind, T_SLEW * k)
            s += "%s  cell_rise (scalar) { values (\"%.3f\") ; }\n" % (ind, T_RESET * k)
            s += "%s  rise_transition (scalar) { values (\"%.3f\") ; }\n%s}\n" % (ind, T_SLEW * k, ind)
        else:
            s += "%sdirection : input ; capacitance : %.5f ; %s\n" % (ind, cpin.get(n, 0.0), rel)
            if n == "clk":
                s += "%sclock : true ;\n" % ind
        return s

    for n in sorted(pins, key=sortkey):
        b, i = busof(n)
        if n in ("vdd", "vdda", "vref", "vss") or i is not None:
            continue
        w("    pin (%s) {\n%s    }\n" % (n, pinbody(n, "      ")))
    for b, idx in sorted(buses.items()):
        w("    bus (%s) {\n      bus_type : %s_t ;\n" % (b, b))
        for i in sorted(idx):
            n = "%s<%d>" % (b, i)
            w("      pin (%s[%d]) {\n%s      }\n" % (b, i, pinbody(n, "        ")))
        w("    }\n")
    w("  }\n}\n")
    o.close()


def write_v(path, pins, stamp):
    buses, scalars = {}, []
    for n in pins:
        b, i = busof(n)
        if i is None:
            scalars.append(n)
        else:
            buses.setdefault(b, []).append(i)
    order = ["vinp", "vinn", "sample", "clk", "ctlp", "ctln", "trima", "trimb", "outp", "outn"]
    names = [n for n in order if n in scalars or n in buses]
    names += sorted(n for n in list(scalars) + list(buses)
                    if n not in names and n not in ("vdd", "vdda", "vref", "vss"))
    o = open(path, "w")
    o.write("// %s.v -- port declaration of the %s hard macro (%s).\n" % (CELL, CELL, stamp))
    o.write("// Generated by analog/cadence/pv/macro/export_macro.sh; do not edit.\n")
    o.write("// Black box: no behaviour. Synthesis takes the cell from %s__<corner>.lib\n" % CELL)
    o.write("// (do not read this file into Genus: it would become an empty module). Behavioural\n")
    o.write("// model for AMS simulation: analog/cadence/sar_adc/sar_afe/verilogams.\n")
    o.write("(* blackbox *)\nmodule %s (\n" % CELL)
    o.write("`ifdef USE_POWER_PINS\n  inout  vdd,   // comparator\n"
            "  inout  vdda,  // sampling switches\n"
            "  inout  vref,  // CDAC reference (bit-driver inverters)\n"
            "  inout  vss,\n`endif\n")
    lines = []
    for n in names:
        d = pins[n]["dir"] if n in pins else pins["%s<%d>" % (n, buses[n][0])]["dir"]
        kw = {"input": "input ", "output": "output"}.get(d, "inout ")
        rng = "[%d:0] " % max(buses[n]) if n in buses else ""
        lines.append("  %s %s%s" % (kw, rng, n))
    o.write(",\n".join(lines) + "\n);\nendmodule\n")
    o.close()


def write_cdl(src, dst, prefix):
    text = open(src).read()
    names = set(re.findall(r"^\.subckt\s+(\S+)", text, re.M | re.I)) - {CELL}
    for n in sorted(names, key=len, reverse=True):
        q = re.escape(n)
        text = re.sub(r"^(\.subckt\s+)%s(?=\s)" % q, r"\g<1>%s%s" % (prefix, n), text, flags=re.M | re.I)
        text = re.sub(r"^(\.ends\s+)%s(?=\s|$)" % q, r"\g<1>%s%s" % (prefix, n), text, flags=re.M | re.I)
        text = re.sub(r"(/\s*)%s(?=\s*$)" % q, r"\g<1>%s%s" % (prefix, n), text, flags=re.M)
    open(dst, "w").write(text)
    return len(names)


def main():
    global CELL
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--cell", default="sar_afe")
    ap.add_argument("--pins", required=True)
    ap.add_argument("--sch", required=True)
    ap.add_argument("--sch-top")
    ap.add_argument("--pex")
    ap.add_argument("--pex-top")
    ap.add_argument("--cdl")
    ap.add_argument("--prefix")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    CELL = a.cell
    stamp = "generated %s" % datetime.date.today().isoformat()
    W, H, pins, extent = read_pins(a.pins)
    ga, gw, da, cmim = areas(a.sch, a.sch_top or CELL)
    cw = wire_caps(a.pex, a.pex_top or CELL) if a.pex else {}
    cpin = {n: ga.get(n, 0.0) * COX + 2 * gw.get(n, 0.0) * COV + cw.get(n, 0.0) for n in pins}
    os.makedirs(a.out, exist_ok=True)
    nobs = write_lef(os.path.join(a.out, CELL + ".lef"), W, H, pins, ga, da, stamp, extent)
    for layer in sorted(extent):
        print("OBS %s limited to %s (shapes %s)" % (layer, obs_region(layer, W, H, extent), extent[layer]))
    for corner in CORNERS:
        write_lib(os.path.join(a.out, "%s__%s.lib" % (CELL, corner[0])), W, H, pins, cpin, stamp, corner)
    write_v(os.path.join(a.out, CELL + ".v"), pins, stamp)
    if a.cdl:
        prefix = a.prefix or CELL + "__"
        n = write_cdl(a.cdl, os.path.join(a.out, CELL + ".cdl"), prefix)
        print("cdl: %d subckts prefixed %s" % (n, prefix))
    print("macro %s: %.3f x %.3f um, %d pins (%d shapes), %d OBS rects"
          % (CELL, W, H, len(pins), sum(len(p["shapes"]) for p in pins.values()), nobs))
    print("%-12s %-6s %-5s %10s %10s %10s %10s" % ("pin", "dir", "layer", "gate_um2", "diff_um2",
                                                   "wire_fF", "pin_fF"))
    for n in sorted(pins, key=sortkey):
        p = pins[n]
        print("%-12s %-6s %-5s %10.4f %10.4f %10.2f %10.2f" % (
            n, p["dir"][:6], p["shapes"][0][0], ga.get(n, 0.0), da.get(n, 0.0),
            cw.get(n, 0.0) * 1e3, cpin.get(n, 0.0) * 1e3))
    for n in sorted(k for k in cmim if k.startswith("vtop")):
        print("CDAC top plate %s: %.3f pF of MIM capacitance (sampled through vin%s)"
              % (n, cmim[n], n[-1]))


if __name__ == "__main__":
    main()
