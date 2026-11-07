#!/usr/bin/env python3
"""chip_lvs_src.py -- assemble the source (schematic) side of chip LVS.

Called by run_chip_lvs.sh; usable on its own:

  chip_lvs_src.py --out SRCDIR --verilog NETLIST.v [--blackbox CELL]...
                  [--full sram|io|sar_afe]... [--scan-only]

Pegasus reads the Innovus Verilog netlist itself (schematic_path ... verilog)
and takes every leaf cell from the CDL written here. This script writes into
SRCDIR:

  stdcells.cdl      sky130_fd_sc_hd (PDK CDL) + sky130_ef_sc_hd decap/fill cells,
                    normalised for the Cadence sky130 LVS deck (see below)
  blackbox.cdl      a pin-only .SUBCKT for every black-boxed cell (pins from LEF)
  <lib>.cdl         transistor-level copies of the SRAM / IO / sar_afe netlists
                    for the cells that are not black-boxed (--full)
  source.cdl        .INCLUDEs of the above (the CDL that goes next to the Verilog)
  verilog_scan.txt  what the Verilog netlist contains: cell masters and counts,
                    masters with no source definition, PG pin connections per
                    master, constants, assigns, escaped names

Normalisation of the library netlists (they were written for netgen/ngspice):
  * MOS models lose the sky130_fd_pr__ prefix, and the "special_" flavours map
    to the device the deck extracts: special_nfet_01v8 -> nfet_01v8,
    special_pfet_01v8_hvt -> pfet_01v8_hvt (flip-flops, latches), and in the
    OpenRAM bit cells special_nfet_latch/special_nfet_pass -> nfet_01v8,
    special_pfet_pass -> pfet_01v8.
  * Unit-less W/L (the PDK CDL writes w=0.65 meaning um) get an explicit "u";
    only W, L and M are kept (the deck checks W and L).
  * X-calls of sky130_fd_pr__ primitives (magic/OpenRAM style) become M/D/R/C
    elements.
  * Diodes carry a= (um^2) and p= (um), the property names and units the deck
    computes on the layout side (DIO_PARAMS: a = area*1e12, p = perimeter*1e6).
"""
import argparse
import collections
import os
import re
import sys

PDK = os.environ.get("PDK_ROOT_SKY130A", "/opt/pdk/sky130A")
SRAM_DIR = os.environ.get(
    "SRAM_DIR", "/opt/pdk/sram_macros/sky130_sram_8kbyte_1rw_32x2048_8")
HERE = os.path.dirname(os.path.abspath(__file__))
MACRO_DIR = os.environ.get(
    "SAR_AFE_DIR", os.path.normpath(os.path.join(HERE, "..", "..", "macros", "sar_afe")))

LIB = {
    "sc_cdl": PDK + "/libs.ref/sky130_fd_sc_hd/cdl/sky130_fd_sc_hd.cdl",
    "sc_spice": PDK + "/libs.ref/sky130_fd_sc_hd/spice",
    "sc_lef": PDK + "/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef",
    "io_cdl": PDK + "/libs.ref/sky130_fd_io/cdl/sky130_ef_io.cdl",
    "io_spice": PDK + "/libs.ref/sky130_fd_io/spice/sky130_fd_io.spice",
    "io_analog": PDK + "/libs.ref/sky130_fd_io/spice/sky130_ef_io__analog.spice",
    "io_lef_ef": PDK + "/libs.ref/sky130_fd_io/lef/sky130_ef_io.lef",
    "io_lef_fd": PDK + "/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef",
    "sram_sp": SRAM_DIR + "/sky130_sram_8kbyte_1rw_32x2048_8.lvs.sp",
    "sram_lef": SRAM_DIR + "/sky130_sram_8kbyte_1rw_32x2048_8.lef",
    "afe_cdl": MACRO_DIR + "/sar_afe.cdl",
}
SRAM_CELL = "sky130_sram_8kbyte_1rw_32x2048_8"

MODEL_MAP = {
    "special_nfet_01v8": "nfet_01v8",
    "special_pfet_01v8_hvt": "pfet_01v8_hvt",
    "special_nfet_latch": "nfet_01v8",
    "special_nfet_pass": "nfet_01v8",
    "special_pfet_pass": "pfet_01v8",
}
PG_PINS = {"VPWR", "VGND", "VPB", "VNB", "vccd1", "vssd1", "VDDIO", "VSSIO",
           "VDDIO_Q", "VSSIO_Q", "VDDA", "VSSA", "VCCD", "VSSD", "VSWITCH",
           "VCCHIB", "VDDIO_PAD", "VSSIO_PAD", "VDDA_PAD", "VSSA_PAD",
           "VCCD_PAD", "VSSD_PAD", "vdd", "vdda", "vref", "vss",
           "AMUXBUS_A", "AMUXBUS_B"}

NUM = re.compile(r"^[-+]?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?$")


def model_name(m):
    if m.startswith("sky130_fd_pr__"):
        m = m[len("sky130_fd_pr__"):]
    return MODEL_MAP.get(m, m)


def logical_lines(path):
    """Yield netlist lines with '+' continuations joined."""
    cur = None
    with open(path, errors="replace") as f:
        for raw in f:
            line = raw.rstrip("\n")
            s = line.lstrip()
            if s.startswith("+"):
                if cur is not None:
                    cur += " " + s[1:]
                continue
            if cur is not None:
                yield cur
            cur = line
    if cur is not None:
        yield cur


def split_params(tokens):
    pos, par = [], collections.OrderedDict()
    for t in tokens:
        if "=" in t:
            k, v = t.split("=", 1)
            par[k.lower()] = v
        else:
            pos.append(t)
    return pos, par


def um(v, unitless_um):
    """Length with an explicit unit."""
    if NUM.match(v):
        return v + ("u" if unitless_um else "")
    return v


def conv_device(name, nodes, model, par, unitless_um, area_scale=1.0, perim_scale=1.0):
    """One primitive as a CDL element line, or None if not a primitive."""
    m = model_name(model)
    if "fet" in m:
        if len(nodes) != 4:
            raise ValueError("MOS %s with %d nodes" % (name, len(nodes)))
        out = ["M" + name] + nodes + [m]
        if "w" in par:
            out.append("W=" + um(par["w"], unitless_um))
        if "l" in par:
            out.append("L=" + um(par["l"], unitless_um))
        mult = par.get("m", par.get("mult"))
        if mult and mult not in ("1", "1.0"):
            out.append("M=" + mult)
        return " ".join(out)
    if m.startswith("diode_"):
        out = ["D" + name] + nodes[:2] + [m]
        a = par.get("area", par.get("a"))
        p = par.get("perim", par.get("pj", par.get("p")))
        if a is not None:
            out.append("a=%.6g" % (float(a) * area_scale))
        if p is not None:
            out.append("p=%.6g" % (float(p) * perim_scale))
        return " ".join(out)
    if m.startswith("res_"):
        out = ["R" + name] + nodes[:2] + [m]
        if "w" in par:
            out.append("$W=" + um(par["w"], unitless_um))
        if "l" in par:
            out.append("$L=" + um(par["l"], unitless_um))
        return " ".join(out)
    if m.startswith("cap_mim"):
        out = ["C" + name] + nodes[:2] + [m]
        if "w" in par:
            out.append("$W=" + um(par["w"], unitless_um))
        if "l" in par:
            out.append("$L=" + um(par["l"], unitless_um))
        return " ".join(out)
    return None


def convert(path, unitless_um, only=None, skip=(), area_scale=1.0,
            perim_scale=1.0, stats=None):
    """Normalised CDL text of a library netlist.

    only: set of subckt names to keep (with everything they instantiate is the
    caller's business); skip: subckts to drop."""
    out = []
    keep = True
    for line in logical_lines(path):
        s = line.strip()
        if not s:
            continue
        low = s.lower()
        if s[0] in "*$#":
            if keep and not low.startswith("*.scale"):
                out.append(line)
            continue
        if low.startswith(".subckt"):
            name = s.split()[1]
            keep = (only is None or name in only) and name not in skip
            if keep:
                out.append(".SUBCKT " + " ".join(s.split()[1:]))
            continue
        if low.startswith(".ends"):
            if keep:
                out.append(".ENDS")
            keep = True
            continue
        if low.startswith((".option", ".end", ".include", ".lib", ".param", ".global")):
            if low.startswith(".global") and keep:
                out.append(s)
            continue
        if not keep:
            continue
        tok = s.split()
        el = tok[0][0].upper()
        if el == "X":
            pos, par = split_params(tok[1:])
            model = pos[-1]
            if model.startswith("sky130_fd_pr__"):
                d = conv_device(tok[0][1:] or "0", pos[:-1], model, par,
                                unitless_um, area_scale, perim_scale)
                if d is None:
                    raise ValueError("%s: unknown primitive %s" % (path, model))
                out.append(d)
                if stats is not None:
                    stats[model_name(model)] += 1
            else:
                out.append(s)
            continue
        if el == "M":
            pos, par = split_params(tok[1:])
            nodes, model = pos[:4], pos[4]
            out.append(conv_device(tok[0][1:], nodes, model, par, unitless_um))
            if stats is not None:
                stats[model_name(model)] += 1
            continue
        if el in "RDC":
            pos, par = split_params(tok[1:])
            if len(pos) >= 3 and not NUM.match(pos[2]):
                d = conv_device(tok[0][1:], pos[:2], pos[2], par, unitless_um,
                                area_scale, perim_scale)
                if d is not None:
                    out.append(d)
                    if stats is not None:
                        stats[model_name(pos[2])] += 1
                    continue
            out.append(s)
            continue
        out.append(s)
    return out


def lef_macros(paths, names):
    """{macro: [pins]} from LEF files, for the requested macro names."""
    res = {}
    for p in paths:
        if not os.path.exists(p):
            continue
        cur = None
        with open(p, errors="replace") as f:
            for line in f:
                t = line.split()
                if not t:
                    continue
                if t[0] == "MACRO" and len(t) > 1:
                    cur = t[1] if t[1] in names and t[1] not in res else None
                    if cur:
                        res[cur] = []
                elif cur and t[0] == "PIN" and len(t) > 1:
                    res[cur].append(t[1])
                elif cur and t[0] == "END" and len(t) > 1 and t[1] == cur:
                    cur = None
    return res


# ---------------------------------------------------------------- Verilog scan
TOK = re.compile(r"\\\S+|[A-Za-z_][A-Za-z0-9_$]*|\d+'[bBhHdDoO][0-9a-fA-FxXzZ_]+|\d+|\S")


def verilog_tokens(path):
    in_block = False
    with open(path, errors="replace") as f:
        for line in f:
            if in_block:
                e = line.find("*/")
                if e < 0:
                    continue
                line = line[e + 2:]
                in_block = False
            while True:
                b = line.find("/*")
                c = line.find("//")
                if c >= 0 and (b < 0 or c < b):
                    line = line[:c]
                    break
                if b >= 0:
                    e = line.find("*/", b + 2)
                    if e < 0:
                        line = line[:b]
                        in_block = True
                        break
                    line = line[:b] + " " + line[e + 2:]
                    continue
                break
            for m in TOK.finditer(line):
                yield m.group(0)


DECL = {"input", "output", "inout", "wire", "supply0", "supply1", "tri",
        "wand", "wor", "reg", "parameter", "localparam", "specify", "tri0", "tri1"}


def scan_verilog(path):
    """Structural scan: modules, instances per master, PG pin connections,
    constants, assigns. Light on memory: aggregates only."""
    mods = collections.OrderedDict()   # module -> {"ports":n, "insts":Counter(master)}
    pg = collections.defaultdict(collections.Counter)   # (master,pin) -> Counter(net)
    pins_seen = collections.defaultdict(set)            # master -> pins used
    consts = collections.Counter()      # (master,pin) -> count of constant conns
    assigns = collections.Counter()
    escaped = 0
    supplies = collections.defaultdict(set)
    declared = collections.defaultdict(set)
    it = verilog_tokens(path)
    cur = None
    for t in it:
        if t == "module":
            name = next(it)
            cur = name
            mods[cur] = {"ports": [], "insts": collections.Counter()}
            # port list until ';'
            for u in it:
                if u == ";":
                    break
                if u not in "(),":
                    mods[cur]["ports"].append(u)
            continue
        if t == "endmodule":
            cur = None
            continue
        if cur is None:
            continue
        if t in DECL:
            kind = t
            names = []
            for u in it:
                if u == ";":
                    break
                names.append(u)
            if kind in ("supply0", "supply1"):
                supplies[cur].update(n for n in names if n not in "[]:,")
            declared[cur].update(n for n in names if n not in "[]:,=" and not n.isdigit())
            continue
        if t == "assign":
            for u in it:
                if u == ";":
                    break
            assigns[cur] += 1
            continue
        # instance: MASTER [#(...)] NAME ( .PIN(expr), ... ) ;
        master = t
        u = next(it)
        if u == "#":
            depth = 0
            for u in it:
                if u == "(":
                    depth += 1
                elif u == ")":
                    depth -= 1
                    if depth == 0:
                        break
            u = next(it)
        inst = u
        if inst.startswith("\\"):
            escaped += 1
        u = next(it)
        if u != "(":
            # unknown statement; skip to ';'
            while u != ";":
                u = next(it)
            continue
        mods[cur]["insts"][master] += 1
        depth = 1
        pin = None
        expr = []
        for u in it:
            if u == "(":
                depth += 1
                if depth == 2 and pin is not None:
                    expr = []
                    continue
            elif u == ")":
                depth -= 1
                if depth == 1 and pin is not None:
                    e = "".join(expr)
                    pins_seen[master].add(pin)
                    if pin in PG_PINS:
                        pg[(master, pin)][e or "<unconnected>"] += 1
                    if "'" in e:
                        consts[(master, pin)] += 1
                    pin = None
                    continue
                if depth == 0:
                    break
            elif u == "." and depth == 1:
                pin = next(it)
                continue
            if depth >= 2:
                expr.append(u)
        u = next(it)  # ';'
    return mods, pg, pins_seen, consts, assigns, escaped, supplies, declared


def io_internal_ties(cdl):
    """{cell: [(ring_pin, other_pin)]} from the ef_io CDL's comments
    "(connects P_PAD and VDDIO_Q to VDDIO)"; P_PAD/G_PAD is the cell's *_PAD pin."""
    ties = {}
    cell, pins = None, []
    comment = ""
    for line in logical_lines(cdl):
        t = line.split()
        if not t:
            continue
        if t[0].startswith("*") and cell is None:
            comment += " " + line.lstrip("* ")
        if t[0].lower() == ".subckt":
            cell, pins = t[1], t[2:]
            # padframe connect slices: "A 20um-wide padframe filler that
            # connects VCCHIB and VCCD as well as VSWITCH and VDDIO"
            m = re.search(r"connects (\w+) and (\w+) as well as (\w+) and (\w+)", comment)
            if m:
                ties.setdefault(cell, []).extend([(m.group(2), m.group(1)), (m.group(4), m.group(3))])
            comment = ""
            continue
        if t[0].lower().startswith(".ends"):
            cell, pins, comment = None, [], ""
            continue
        m = re.search(r"\(connects (.+?) to (\w+)\)", line)
        if cell and m:
            to = m.group(2)
            for x in re.split(r"\s+and\s+|,\s*", m.group(1)):
                x = x.strip()
                if x in ("P_PAD", "G_PAD"):
                    x = next((p for p in pins if p.endswith("_PAD")), x)
                if x and x != to:
                    ties.setdefault(cell, []).append((to, x))
    return ties


RING_PINS = ["VCCD", "VCCHIB", "VDDA", "VSSA", "VSSD", "VSWITCH", "VDDIO",
             "VDDIO_Q", "VSSIO", "VSSIO_Q"]


def write_netlist(src, dst, top, drop, io_pins, ringnet, declared, bulk_cells=()):
    """Copy the Verilog, connecting every IO-cell ring pin the netlist leaves
    open to the chip's net for that ring (ringnet: pin -> net).

    In the layout the IO cells abut, so their ring buses (VCCD, VSSD, VDDIO,
    ...) are one net per ring; Innovus writes only the pins it was told to
    connect (connect_global_net, UPF supply pins). Returns {master: added}."""
    added = collections.Counter()
    pin_re = re.compile(r"\.\s*(\\\S+|[A-Za-z_][A-Za-z0-9_$]*)\s*\(\s*([^()]*?)\s*\)")
    with open(src, errors="replace") as f, open(dst, "w") as o:
        buf = None
        in_top = False
        hdr_done = False
        skipping = False
        for line in f:
            if skipping:
                if line.lstrip().startswith("endmodule"):
                    skipping = False
                continue
            if buf is None:
                st = line.lstrip()
                if st.startswith("module "):
                    name = st.split()[1].split("(")[0]
                    if name in drop:
                        skipping = True
                        continue
                    in_top = name == top
                    hdr_done = False
                if in_top and not hdr_done:
                    o.write(line)
                    if ";" in line:
                        hdr_done = True
                        new = sorted(set(ringnet.values()) - declared.get(top, set()))
                        new = [n for n in new if not n.startswith("UNCONNECTED")]
                        if new:
                            o.write("  // chip_lvs_src.py --pad-ring: IO ring nets\n")
                            o.write("".join("  wire %s;\n" % n for n in new))
                    continue
                tok = st.split(None, 1)[0] if st.strip() else ""
                if (in_top and ringnet and tok in io_pins) or tok in bulk_cells:
                    buf = line
                    if ";" not in line:
                        continue
                else:
                    o.write(line)
                    continue
            else:
                buf += line
                if ";" not in line:
                    continue
            # complete IO instance statement in buf
            master = buf.lstrip().split(None, 1)[0]
            have = {}
            for m in pin_re.finditer(buf):
                have[m.group(1)] = m.group(2)
            adds = []
            if master in bulk_cells:
                # std cell whose VPB/VNB the netlist leaves open: put them on
                # the cell's own VPWR/VGND, as power_plan.tcl's
                # connect_global_net VPB->VDD, VNB->VSS intends
                for pin, rail in (("VPB", "VPWR"), ("VNB", "VGND")):
                    cur = have.get(pin)
                    if (cur and not cur.startswith("UNCONNECTED")) or not have.get(rail):
                        continue
                    if pin in have:
                        buf = re.sub(r"\.\s*%s\s*\(\s*[^()]*?\s*\)" % pin,
                                     ".%s(%s)" % (pin, have[rail]), buf, 1)
                    else:
                        adds.append(".%s(%s)" % (pin, have[rail]))
                    added["%s.%s" % (master, pin)] += 1
            for pin in (RING_PINS if master in io_pins and ringnet else []):
                if pin not in io_pins[master] or pin not in ringnet:
                    continue
                cur = have.get(pin)
                if cur and not cur.startswith("UNCONNECTED"):
                    continue
                if pin in have:      # .PIN() or .PIN(UNCONNECTEDnn): open
                    buf = re.sub(r"\.\s*%s\s*\(\s*[^()]*?\s*\)" % pin,
                                 ".%s(%s)" % (pin, ringnet[pin]), buf, 1)
                else:
                    adds.append(".%s(%s)" % (pin, ringnet[pin]))
                added[master] += 1
            if adds:
                i = buf.rstrip().rfind(")")
                body = buf[:i].rstrip()
                sep = "" if body.endswith("(") else ","
                buf = body + sep + "\n    " + ",\n    ".join(adds) + " );\n"
            o.write(buf)
            buf = None
    return added


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out", required=True)
    ap.add_argument("--verilog", required=True)
    ap.add_argument("--top", default=None)
    ap.add_argument("--blackbox", action="append", default=[])
    ap.add_argument("--full", action="append", default=[],
                    choices=["sram", "io", "sar_afe"])
    ap.add_argument("--scan-only", action="store_true")
    ap.add_argument("--tie-bulk", action="store_true",
                    help="connect std-cell VPB/VNB the netlist leaves open to the cell's VPWR/VGND")
    ap.add_argument("--pad-ring", action="store_true",
                    help="connect IO-cell ring pins the netlist leaves open (see pad_ring_rewrite)")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rep = []

    # ---- scan the Verilog
    mods, pg, pins_seen, consts, assigns, escaped, supplies, declared = scan_verilog(a.verilog)
    # Innovus writes an empty module (ports only) for every library cell it
    # instantiates (-include_pg). Those are leaves: their netlist comes from
    # the CDL, and the empty modules are dropped from the copy Pegasus reads.
    empty = set(k for k, m in mods.items() if not m["insts"])
    defined = set(mods) - empty
    masters = collections.Counter()
    for m in mods.values():
        masters.update(m["insts"])
    leaf = {k: v for k, v in masters.items() if k not in defined}
    top = a.top or (list(mods)[-1] if mods else None)
    rep.append("Verilog: %s" % a.verilog)
    rep.append("modules defined: %d (+%d empty library-cell modules, dropped)   top: %s (%d ports)" % (
        len(defined), len(empty), top, len(mods.get(top, {}).get("ports", []))))
    rep.append("leaf masters: %d   leaf instances: %d" % (len(leaf), sum(leaf.values())))
    rep.append("assign statements: %d %s" % (sum(assigns.values()), dict(assigns) if assigns else ""))
    rep.append("escaped instance names: %d" % escaped)
    if supplies:
        rep.append("supply0/supply1 nets: %s" % {k: sorted(v) for k, v in supplies.items()})
    rep.append("")
    rep.append("Leaf masters (instances):")
    for k, v in sorted(leaf.items(), key=lambda x: (-x[1], x[0])):
        rep.append("  %8d  %s" % (v, k))

    # ---- library cells available
    sc_cells = set()
    for line in logical_lines(LIB["sc_cdl"]):
        if line.lower().startswith(".subckt"):
            sc_cells.add(line.split()[1])
    ef_files = sorted(f for f in os.listdir(LIB["sc_spice"]) if f.startswith("sky130_ef_sc_hd__"))
    ef_cells = set(f[:-len(".spice")] for f in ef_files)

    bb = set(a.blackbox)
    used_io = sorted(k for k in leaf if k.startswith(("sky130_ef_io__", "sky130_fd_io__")))
    used_other = sorted(k for k in leaf if k not in sc_cells and k not in ef_cells
                        and k not in used_io)
    rep.append("")
    rep.append("IO cells used: %s" % " ".join(used_io))
    rep.append("other non-std-cell masters: %s" % " ".join(used_other))

    # ---- PG connections per master
    rep.append("")
    rep.append("PG/supply pin connections (master.pin: net=count ...):")
    for (mst, pin), cnt in sorted(pg.items()):
        rep.append("  %s.%s: %s" % (mst, pin, " ".join(
            "%s=%d" % kv for kv in cnt.most_common(6))))
    missing_pg = []
    for mst in sorted(leaf):
        if mst in sc_cells or mst in ef_cells:
            need = {"VPWR", "VGND"} if "tapvpwrvgnd" in mst else {"VPWR", "VGND", "VPB", "VNB"}
            miss = need - pins_seen.get(mst, set())
            if miss:
                missing_pg.append("%s(%s)" % (mst, ",".join(sorted(miss))))
    rep.append("std-cell masters with PG pins absent from every instance: %s" % (
        " ".join(missing_pg) or "none"))
    if consts:
        rep.append("constant (1'bx) connections: " + " ".join(
            "%s.%s=%d" % (k[0], k[1], v) for k, v in consts.most_common(40)))

    open(os.path.join(a.out, "top_ports.txt"), "w").write(
        "\n".join(mods.get(top, {}).get("ports", [])) + "\n")
    if a.scan_only:
        open(os.path.join(a.out, "verilog_scan.txt"), "w").write("\n".join(rep) + "\n")
        print("\n".join(rep[:12]))
        return 0

    # ---- std cells
    stats = collections.Counter()
    txt = ["* sky130_fd_sc_hd + sky130_ef_sc_hd for chip LVS (chip_lvs_src.py)",
           "* from %s and %s/sky130_ef_sc_hd__*.spice" % (LIB["sc_cdl"], LIB["sc_spice"]),
           "*.SCALE METER"]
    # diode_2: the PDK CDL has no device ("Tap diode is not represented"), but
    # the layout has an areaid.de diode the deck extracts. Take it from the
    # magic-extracted SPICE (area in pm^2, perimeter in pm there).
    txt += convert(LIB["sc_cdl"], unitless_um=True, skip={"sky130_fd_sc_hd__diode_2"},
                   stats=stats)
    txt += convert(LIB["sc_spice"] + "/sky130_fd_sc_hd.spice", unitless_um=True,
                   only={"sky130_fd_sc_hd__diode_2"}, area_scale=1e-12,
                   perim_scale=1e-6, stats=stats)
    for f in ef_files:
        txt += convert(os.path.join(LIB["sc_spice"], f), unitless_um=True, stats=stats)
    open(os.path.join(a.out, "stdcells.cdl"), "w").write("\n".join(txt) + "\n")
    rep.append("")
    rep.append("stdcells.cdl devices by model: %s" % dict(stats))

    includes = ["stdcells.cdl"]

    # ---- black boxes: pin-only subckts from LEF
    want_stub = set(bb)
    lef_paths = [LIB["io_lef_ef"], LIB["io_lef_fd"], LIB["sram_lef"],
                 MACRO_DIR + "/sar_afe.lef", MACRO_DIR + "/sar_afe_r.lef",
                 MACRO_DIR + "/sar_afe_b.lef"]
    # IO / SRAM / macro cells in the netlist that are not black-boxed and not
    # compared in full still need a definition: stub them too, but say so.
    full_io = "io" in a.full
    full_sram = "sram" in a.full
    full_afe = "sar_afe" in a.full
    for c in used_io:
        if not full_io:
            want_stub.add(c)
    for c in used_other:
        if c == SRAM_CELL and full_sram:
            continue
        if c.startswith("sar_afe") and full_afe:
            continue
        want_stub.add(c)
    pins = lef_macros(lef_paths, want_stub)
    stub = ["* pin-only subcircuits for black-boxed cells (pins from LEF)", "*.SCALE METER"]
    nobb_stub = []
    for c in sorted(want_stub):
        cdl = os.path.join(MACRO_DIR, c + ".cdl")
        if c.startswith("sar_afe") and os.path.exists(cdl):
            # The macro's pin text in its GDS is ctln<0> (Virtuoso buses), so
            # the stub keeps the CDL's <> names; *.BUSDELIMITER < lets the
            # Verilog bus .ctln(x[7:0]) bind to them bit by bit.
            hdr = next((l.split()[2:] for l in logical_lines(cdl)
                        if l.lower().startswith(".subckt " + c.lower() + " ")), None)
            if hdr:
                stub += ["*.BUSDELIMITER <", ".SUBCKT %s %s" % (c, " ".join(hdr)),
                         ".ENDS", "*.BUSDELIMITER ["]
                if c not in bb:
                    nobb_stub.append(c)
                continue
        if c not in pins:
            if c in sc_cells or c in ef_cells:
                continue        # std cell asked to be black-boxed: its CDL is there
            rep.append("WARNING: no LEF pins for %s; not stubbed" % c)
            continue
        stub.append(".SUBCKT %s %s" % (c, " ".join(pins[c])))
        stub.append(".ENDS")
        if c not in bb:
            nobb_stub.append(c)
    open(os.path.join(a.out, "blackbox.cdl"), "w").write("\n".join(stub) + "\n")
    includes.append("blackbox.cdl")

    # ---- pins of black-boxed IO cells not compared (deck rules)
    io_pins = lef_macros([LIB["io_lef_ef"], LIB["io_lef_fd"]], set(used_io))
    dp = ["// IO-cell pins not compared, and black boxes inside compared macros (chip_lvs_src.py)"]
    for c in used_io:
        if c not in bb:
            continue
        for pin in io_pins.get(c, []):
            if pin in ("AMUXBUS_A", "AMUXBUS_B"):
                # analog mux buses: unused by this chip, and in the power
                # pads the PDK's met4 AMUXBUS text sits 0.055 um off the
                # metal, so a -black box cannot form the port
                dp.append("lvs_delete_cell_pin %s %s" % (c, pin))

    # supply pads: inside the cell the bond pad (and for VDDIO/VSSIO pads the
    # quiet rail) is metal-connected to a ring bus; the ef_io CDL says so in
    # a comment, e.g. "(connects P_PAD and VDDIO_Q to VDDIO)". A -black box
    # does not extract it, so join those pins, in the layout and in the
    # pin-only source stub alike.
    ties = io_internal_ties(LIB["io_cdl"])
    for c in used_io:
        if c not in bb:
            continue
        for a_, b_ in ties.get(c, []):
            if a_ in io_pins.get(c, []) and b_ in io_pins.get(c, []):
                dp.append("lvs_join_nets %s %s %s -source_layout" % (c, a_, b_))
    if full_afe:
        # the macro's own LVS black-boxes the trim's MOM unit cap (plain metal
        # fingers, no device rule extracts them): same here, by its renamed name
        for c in sorted(leaf):
            if c.startswith("sar_afe") and c not in bb:
                dp.append("lvs_black_box %s__sarcta__C0 -source_layout" % c.split("__")[0])
        dp = list(dict.fromkeys(dp))
    open(os.path.join(a.out, "deck_pins.pvl"), "w").write("\n".join(dp) + "\n")
    # diagnostic (run_chip_lvs.sh --no-bulk-pins): std-cell well/substrate pins
    # out of the comparison, to see the signal/supply wiring apart from the
    # well ties
    nb = ["// std-cell VPB/VNB not compared (diagnostic, chip_lvs_src.py)"]
    for mst in sorted(leaf):
        if (mst in sc_cells or mst in ef_cells) and not re.search(r"__(fill|tap)", mst):
            nb += ["lvs_delete_cell_pin %s VPB" % mst, "lvs_delete_cell_pin %s VNB" % mst]
    open(os.path.join(a.out, "deck_nobulk.pvl"), "w").write("\n".join(nb) + "\n")

    # ---- Verilog copy for Pegasus: without the empty library-cell modules
    # (they would shadow the CDL subcircuits), optionally with the IO ring
    # pins connected
    vout = os.path.join(a.out, "netlist.v")
    if os.path.lexists(vout):
        os.rename(vout, vout + ".old")
    ringnet = {}
    if a.pad_ring and used_io:
        ringnet = {}
        for pin in RING_PINS:
            nets = collections.Counter()
            for (mst, p), cnt in pg.items():
                if p == pin and mst in io_pins:
                    for n, k in cnt.items():
                        if n != "<unconnected>" and not n.startswith("UNCONNECTED"):
                            nets[n] += k
            if not nets:
                ringnet[pin] = pin
            else:
                ringnet[pin] = nets.most_common(1)[0][0]
                if len(nets) > 1:
                    rep.append("WARNING: ring pin %s is on several nets %s; open pins go to %s"
                               % (pin, dict(nets), ringnet[pin]))
    bulk = set()
    if a.tie_bulk:
        for mst in leaf:
            if (mst in sc_cells or mst in ef_cells) and not re.search(r"__(fill|tap)", mst):
                bulk.add(mst)
    added = write_netlist(a.verilog, vout, top, empty, io_pins, ringnet, declared, bulk)
    if a.tie_bulk:
        nb = {k: v for k, v in added.items() if k.endswith((".VPB", ".VNB"))}
        rep.append("--tie-bulk: open VPB/VNB put on the cell's VPWR/VGND: %d pins %s" % (
            sum(nb.values()), dict(sorted(nb.items())[:12])))
        for k in nb:
            del added[k]
    rep.append("")
    rep.append("netlist.v: %s without %d empty library-cell modules" % (a.verilog, len(empty)))
    if ringnet:
        rep.append("--pad-ring: ring pin -> net: %s" % " ".join("%s=%s" % kv for kv in ringnet.items()))
        rep.append("--pad-ring: open ring pins connected, per IO master: %s" % (dict(added) or "none"))
    if nobb_stub:
        rep.append("WARNING: stubbed (no transistor netlist used) but not black-boxed: %s"
                   % " ".join(nobb_stub))

    # ---- transistor-level macros
    if full_sram and SRAM_CELL in leaf:
        s2 = collections.Counter()
        t = ["* %s (OpenRAM LVS netlist) normalised by chip_lvs_src.py" % SRAM_CELL, "*.SCALE METER"]
        t += convert(LIB["sram_sp"], unitless_um=False, stats=s2)
        open(os.path.join(a.out, "sram.cdl"), "w").write("\n".join(t) + "\n")
        includes.append("sram.cdl")
        rep.append("sram.cdl devices by model: %s" % dict(s2))
    if full_io and used_io:
        s3 = collections.Counter()
        t = ["* sky130_fd_io / sky130_ef_io normalised by chip_lvs_src.py", "*.SCALE METER"]
        t += convert(LIB["io_spice"], unitless_um=True, stats=s3)
        t += convert(LIB["io_cdl"], unitless_um=True, stats=s3)
        t += convert(LIB["io_analog"], unitless_um=True, stats=s3)
        open(os.path.join(a.out, "io.cdl"), "w").write("\n".join(t) + "\n")
        includes.append("io.cdl")
        rep.append("io.cdl devices by model: %s" % dict(s3))
    if full_afe and any(c.startswith("sar_afe") for c in leaf):
        # The macro's CDL is the auCdl netlist its own LVS matched; buses are <>.
        includes.append(("*.BUSDELIMITER <", LIB["afe_cdl"], "*.BUSDELIMITER ["))

    w = ["* chip LVS source libraries (chip_lvs_src.py); the Verilog netlist is",
         "* read separately (schematic_path ... verilog)"]
    for inc in includes:
        if isinstance(inc, tuple):
            w += [inc[0], '.INCLUDE "%s"' % inc[1], inc[2]]
        else:
            w.append('.INCLUDE "%s"' % os.path.join(os.path.abspath(a.out), inc))
    open(os.path.join(a.out, "source.cdl"), "w").write("\n".join(w) + "\n")
    open(os.path.join(a.out, "verilog_scan.txt"), "w").write("\n".join(rep) + "\n")
    print("\n".join(l for l in rep if l.startswith(("modules", "leaf", "assign", "IO cells",
                                                     "other", "WARNING", "std-cell"))))
    return 0


if __name__ == "__main__":
    sys.exit(main())
