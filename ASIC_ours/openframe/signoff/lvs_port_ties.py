#!/usr/bin/env python3
"""Compare the wrapper's port-to-port ties in the netlist with those in the layout.

The OpenFrame wrapper ties each pad's static configuration ports straight to the
frame's gpio_loopback_one/zero ports: wires with no device on them. Pegasus
compares devices and their nets, so it cannot check such wires; it reports them
as "label shorts" (several port texts on one layout net) and still says MATCH.
This script checks them: the groups of ports joined by `assign` in the netlist's
top module must be exactly the groups of port texts that lvs_find_shorts found
on one net.

Usage: lvs_port_ties.py <top>.pg.v <top>.lvsrpt.shorts [--top NAME]
Exit 0 when the two sets of groups are identical.
"""
import argparse
import re
import sys


def groups(pairs):
    """Connected components of the pairs, as a set of frozensets."""
    parent = {}

    def find(x):
        parent.setdefault(x, x)
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for a, b in pairs:
        parent[find(a)] = find(b)
    comp = {}
    for x in list(parent):
        comp.setdefault(find(x), set()).add(x)
    return {frozenset(c) for c in comp.values()}


def netlist_pairs(path, top):
    pairs, inside = [], False
    mod = re.compile(r"^\s*module\s+(\S+)")
    asg = re.compile(r"^\s*assign\s+(\S+)\s*=\s*(\S+?)\s*;")
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = mod.match(line)
            if m:
                inside = m.group(1).rstrip("(") == top
                continue
            if inside:
                if line.startswith("endmodule"):
                    inside = False
                    continue
                m = asg.match(line)
                if m:
                    pairs.append((m.group(1).lstrip("\\"), m.group(2).lstrip("\\")))
    return pairs


def layout_pairs(path, top):
    pat = re.compile(r"^SHORT \d+\. (\S+) - (\S+) in (\S+)")
    pairs = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = pat.match(line)
            if m and m.group(3) == top:
                pairs.append((m.group(1), m.group(2)))
    return pairs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("verilog")
    ap.add_argument("shorts")
    ap.add_argument("--top", default="openframe_project_wrapper")
    a = ap.parse_args()
    np_, lp = netlist_pairs(a.verilog, a.top), layout_pairs(a.shorts, a.top)
    ng, lg = groups(np_), groups(lp)
    print("netlist: %d assign statements, %d groups, %d ports" % (len(np_), len(ng), sum(map(len, ng))))
    print("layout : %d label shorts,     %d groups, %d ports" % (len(lp), len(lg), sum(map(len, lg))))
    only_n, only_l = ng - lg, lg - ng
    for name, only in (("netlist", only_n), ("layout", only_l)):
        for g in sorted(only, key=lambda s: sorted(s))[:20]:
            print("  only in %s: %s" % (name, " ".join(sorted(g))))
    # a tie to a supply or between a constant and a functional port would be a real short
    const = re.compile(r"^gpio_loopback_(one|zero)\[\d+\]$")
    odd = [g for g in lg if sum(1 for p in g if const.match(p)) != 1]
    for g in odd[:20]:
        print("  group without exactly one loopback constant: %s" % " ".join(sorted(g)))
    ok = not only_n and not only_l and not odd
    print("RESULT %s: %d groups identical, %d only in the netlist, %d only in the layout, "
          "%d without exactly one loopback constant" % ("PASS" if ok else "FAIL", len(ng & lg),
                                                          len(only_n), len(only_l), len(odd)))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
