#!/bin/bash
# =====================================================================
# fetch_dffram.sh -- get the DFFRAM macros the OpenFrame wrapper uses.
#
# ChipFoundry's pre-hardened DFFRAM blocks (github.com/efabless/OL-DFFRAM,
# Apache-2.0): DFFRAM512x32 (2 kbyte), DFFRAM256x32 (1 kbyte), DFFRAM128x32
# (512 byte), each with LEF, GDS, timing libraries and Verilog. They are not
# kept in this repository (about 110 MB); this fetches the views the flow
# needs, at the commit the flow was run with.
#
# Usage: ./fetch_dffram.sh [--sim] [dir]   default dir: ip/OL-DFFRAM beside this script
# The flow looks there, or in $DFFRAM_ROOT if that is set.
#   --sim  also fetch each block's gate netlist (hdl/gl) and its SDF for the
#          slow, typical and fast corners (about 330 MB more), for the gate-level
#          simulation with the memories as gates (sim/run_gl_sim.sh, MEM_GATES=1).
#          Can be run after a plain fetch.
# =====================================================================
set -euo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM=""; if [ "${1:-}" = "--sim" ]; then SIM=1; shift; fi
DIR="${1:-$SD/ip/OL-DFFRAM}"
COMMIT=8aaa518          # 29 Sep 2025
if [ ! -f "$DIR/layout/lef/DFFRAM512x32.lef" ]; then
    mkdir -p "$(dirname "$DIR")"
    git clone --filter=blob:none --sparse https://github.com/efabless/OL-DFFRAM.git "$DIR"
    git -C "$DIR" checkout -q "$COMMIT"
    git -C "$DIR" sparse-checkout set --no-cone '/*.md' '/*.txt' '/*.yaml' \
        '/hdl/rtl/' '/hdl/sim/' '/layout/lef/' '/layout/gds/' '/timing/lib/' '/PnR/'
    for g in "$DIR"/layout/gds/*.gds.gz; do gunzip -c "$g" > "${g%.gz}"; done    # (gzip 1.5 has no -k)
else
    echo "already there: $DIR"
fi
if [ -n "$SIM" ] && [ ! -f "$DIR/timing/sdf/max/DFFRAM128x32.Slowest.sdf" ]; then
    # the 512-word block's SDF files are one directory per corner; the other two
    # blocks' are max/nom/min directories holding Slowest, Typical and Fastest
    git -C "$DIR" sparse-checkout add '/hdl/gl/' \
        '/timing/sdf/max_ss_100C_1v60/' '/timing/sdf/nom_tt_025C_1v80/' '/timing/sdf/min_ff_n40C_1v95/' \
        '/timing/sdf/max/' '/timing/sdf/nom/' '/timing/sdf/min/'
fi
echo "DFFRAM macros in $DIR:"; grep -H -m1 SIZE "$DIR"/layout/lef/*.lef
[ -z "$SIM" ] || ls "$DIR"/hdl/gl/*.v
