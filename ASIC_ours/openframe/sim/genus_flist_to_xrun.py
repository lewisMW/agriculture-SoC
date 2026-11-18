#!/usr/bin/env python3
"""genus_flist_to_xrun.py -- the RTL that synthesis reads, as a file list for xrun.

The chip flow's file list for Genus (nanosoc/imp/ASIC/nanosoc/flist/genus_flist.tcl,
written by `make flist_genus_nanosoc`) is a Tcl script of read_hdl and
init_hdl_search_path commands. This turns it into source and +incdir+ lines, in
the same order, so that the RTL simulation of the OpenFrame wrapper compiles
exactly the files the netlist was synthesised from.

Usage: genus_flist_to_xrun.py GENUS_FLIST.tcl OUT.flist [--drop REGEX]...
  --drop   leave out files and include directories whose path matches (the
           simulation supplies its own version)
$env(NAME) is replaced from the environment; a name that is not set is an error.
Only the paths are read, never the files.
"""
import os
import re
import sys


def expand(s):
    def sub(m):
        v = os.environ.get(m.group(1))
        if v is None:
            sys.exit(f"genus_flist_to_xrun: environment variable {m.group(1)} is not set")
        return v
    return re.sub(r"\$(?:::)?env\((\w+)\)", sub, s)


def main():
    args = sys.argv[1:]
    drops = []
    while "--drop" in args:
        i = args.index("--drop")
        drops.append(re.compile(args[i + 1]))
        del args[i:i + 2]
    if len(args) != 2:
        sys.exit(__doc__)
    src, out = args
    lines, seen = [], set()
    with open(src) as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            m = re.match(r"read_hdl\s+(?:-language\s+\w+\s+|-sv\s+)*(\S+)\s*$", line)
            if m:
                path = expand(m.group(1))
                if any(d.search(path) for d in drops):
                    continue
                if path in seen:                      # the same file listed twice
                    continue
                seen.add(path)
                lines.append(path)
                continue
            m = re.match(r"set_db\s+init_hdl_search_path\s+(.*)$", line)
            if m:
                rest = re.sub(r"\[get_db\s+\w+\]", " ", m.group(1)).replace('"', " ")
                for d in rest.split():
                    d = expand(d)
                    if not any(x.search(d) for x in drops):
                        lines.append("+incdir+" + d)
                continue
            sys.exit(f"genus_flist_to_xrun: line not understood: {line}")
    with open(out, "w") as f:
        f.write("// written by genus_flist_to_xrun.py from " + os.path.basename(src) + "\n")
        f.write("\n".join(lines) + "\n")
    print(f"genus_flist_to_xrun: {sum(1 for x in lines if not x.startswith('+'))} source files")


if __name__ == "__main__":
    main()
