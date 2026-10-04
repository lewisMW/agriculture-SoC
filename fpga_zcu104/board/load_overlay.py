#!/usr/bin/env python3
"""
Load the NanoSoC bitstream into the ZCU104 PL.

Run on the board, as root, inside the pynq venv:
    sudo su
    source /etc/profile.d/pynq_venv.sh
    python3 load_overlay.py [path/to/nanosoc_design.bit]

The matching .hwh file must sit next to the .bit with the same basename —
pynq parses it to learn the design's address map; without it Overlay() fails.
"""
import argparse
import os
import sys

from pynq import Overlay

DEFAULT_BIT = "/home/xilinx/pynq/overlays/soclabs/nanosoc_design.bit"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("bitfile", nargs="?", default=DEFAULT_BIT)
    args = ap.parse_args()

    if not os.path.exists(args.bitfile):
        sys.exit("ERROR: bitfile not found: %s" % args.bitfile)
    hwh = os.path.splitext(args.bitfile)[0] + ".hwh"
    if not os.path.exists(hwh):
        sys.exit("ERROR: missing %s — copy the .hwh from the build output "
                 "next to the .bit (same basename)." % hwh)

    ol = Overlay(args.bitfile)
    ol.download()
    if ol.is_loaded():
        print("Overlay Loaded")   # ci_tools greps for this exact string
        return 0
    print("Overlay failed to load")
    return 1


if __name__ == "__main__":
    sys.exit(main())
