#!/usr/bin/env python3
"""Resolve a nanosoc .flist tree into a flat Verilator command file.

Usage: flist_resolve.py <top.flist> <out.vc> [--missing missing.txt]

Understands the subset of flist syntax the nanosoc flists use: `//` comments,
`-f <file>`, `-y <dir>`, `+incdir+<dir>`, `+libext+...`, `+define+...` and
explicit source files.  `$(VAR)` / `${VAR}` / `$VAR` are expanded from the
environment.  Unlike soctools_flow's filelist_compile.py it never drops a line
silently: a bare directory or an unresolvable path is reported.

Files that do not exist (typically everything under $ARM_IP_LIBRARY_PATH on a
machine without the licensed ARM kit) are written to --missing instead of the
output, so the caller can substitute verif/cov/arm_stubs/ for them.
"""
import os
import re
import sys

VAR = re.compile(r"\$\(([A-Za-z_][A-Za-z0-9_]*)\)|\$\{([A-Za-z_][A-Za-z0-9_]*)\}|\$([A-Za-z_][A-Za-z0-9_]*)")


def expand(s):
    return VAR.sub(lambda m: os.environ.get(m.group(1) or m.group(2) or m.group(3), ""), s)


def resolve(path, out, missing, seen):
    path = os.path.normpath(expand(path))
    if path in seen:
        return
    seen.add(path)
    if not os.path.isfile(path):
        missing.append(f"-f {path}")
        return
    base = os.path.dirname(path)
    with open(path, encoding="latin-1") as fh:
        for raw in fh:
            line = raw.split("//", 1)[0].strip()
            if not line:
                continue
            if line.startswith("-f "):
                resolve(line[3:].strip(), out, missing, seen)
            elif line.startswith("-y "):
                d = os.path.normpath(expand(line[3:].strip()))
                if os.path.isdir(d):
                    out.append(f"-y {d}")
                else:
                    missing.append(f"-y {d}")
            elif line.startswith("+incdir+"):
                d = os.path.normpath(expand(line[len("+incdir+"):]))
                if os.path.isdir(d):
                    out.append(f"+incdir+{d}")
                else:
                    missing.append(f"+incdir+{d}")
            elif line.startswith("+libext+") or line.startswith("+define+"):
                out.append(expand(line))
            else:
                f = os.path.normpath(expand(line))
                if not os.path.isabs(f):
                    f = os.path.normpath(os.path.join(base, f))
                if os.path.isfile(f):
                    if f not in out:
                        out.append(f)
                elif os.path.isdir(f):
                    # Bare directory: filelist_compile.py drops these silently.
                    # Report rather than guess (see CLAUDE.md "flist gotcha").
                    missing.append(f"bare-dir {f}")
                else:
                    missing.append(f)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    top, out_path = sys.argv[1], sys.argv[2]
    miss_path = None
    if "--missing" in sys.argv:
        miss_path = sys.argv[sys.argv.index("--missing") + 1]
    out, missing = [], []
    resolve(top, out, missing, set())
    with open(out_path, "w") as fh:
        fh.write("\n".join(out) + "\n")
    if miss_path:
        with open(miss_path, "w") as fh:
            fh.write("\n".join(missing) + "\n")
    print(f"flist_resolve: {len(out)} entries, {len(missing)} missing/unresolved")


if __name__ == "__main__":
    main()
