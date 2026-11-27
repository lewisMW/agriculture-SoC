#!/usr/bin/env python3
"""
Load a firmware test onto the NanoSoC in the ZCU104 PL and run it.

Equivalent to one iteration of ci_tools/run_full_verification.py, but for a
single named .hex, self-contained, and with readable output.

Run on the board, as root, inside the pynq venv:
    sudo su
    source /etc/profile.d/pynq_venv.sh
    python3 run_sensing_test.py binaries/adc_trigger_test.hex

Sequence: (re)load the overlay -> enter ADP monitor -> upload the hex to
iRAM at 0x2000_0000 -> pulse the go signal (C 0x200 / C 0x201) -> relay the
SoC's stdout until it prints PASSED/FAILED or goes quiet.

Exit code: 0 if "PASSED" was seen, 2 if "FAILED", 3 on timeout/no verdict.
"""
import argparse
import sys

from pynq import Overlay

from nanosoc_adp import ADP

DEFAULT_BIT = "/home/xilinx/pynq/overlays/soclabs/nanosoc_design.bit"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("hexfile", help="byte-per-line .hex built by the testcode makefile")
    ap.add_argument("--bit", default=DEFAULT_BIT, help="bitstream (default: %(default)s)")
    ap.add_argument("--no-overlay", action="store_true",
                    help="skip reloading the bitstream (reuse the loaded one; note the "
                         "SoC keeps whatever state the last run left behind)")
    ap.add_argument("--base", type=lambda x: int(x, 0), default=0x20000000,
                    help="upload address (default: 0x20000000, NanoSoC iRAM)")
    ap.add_argument("--timeout", type=float, default=120,
                    help="max seconds to wait for the test (default: %(default)s)")
    ap.add_argument("--idle", type=float, default=10,
                    help="stop after this many silent seconds (default: %(default)s). "
                         "Raise for tests that wait on real-time RTC alarms.")
    args = ap.parse_args()

    if not args.no_overlay:
        print("Loading overlay %s ..." % args.bit)
        ol = Overlay(args.bit)
        ol.download()
        if not ol.is_loaded():
            sys.exit("ERROR: overlay failed to load")
        print("Overlay loaded.")

    adp = ADP()
    banner = adp.read(512, timeout=1.0)      # bootloader banner, if any queued
    if banner:
        print("[boot] %r" % banner)
    print("[adp ] entering monitor: %r" % adp.monitor_enter())

    adp.upload_hex(args.hexfile, base=args.base)
    print("[adp ] releasing core ...")
    adp.start_core()

    print("---- SoC output " + "-" * 44)
    out = adp.stream(seconds=args.timeout, idle=args.idle)
    print("\n" + "-" * 60)

    if "PASSED" in out:
        print("RESULT: PASSED")
        return 0
    if "FAILED" in out:
        print("RESULT: FAILED")
        return 2
    print("RESULT: no verdict (timeout or silent test) — see DEBUGGING.md §5")
    return 3


if __name__ == "__main__":
    sys.exit(main())
