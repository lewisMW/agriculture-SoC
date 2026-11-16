#!/bin/bash
# =====================================================================
# run_dffram_gl_unit.sh -- one pre-hardened DFFRAM block on its own, as its gate
# netlist with ChipFoundry's SDF for it, against a reference array
# (tb_dffram_gl.v): the backdoor preload, 6000 random cycles, every word read
# back.
#
# Usage: ./run_dffram_gl_unit.sh <run_dir> <128|256|512> [slow|typical|fast] [TIN] [HALF]
#   TIN   ns after the rising clock edge at which the block's inputs change
#         (default 3: a flop-driven bus; the blocks sample control and data on
#         the falling edge too, so a large TIN is expected to fail)
#   HALF  half the clock period in ns (default 15)
# Needs the netlists and SDF files: ../fetch_dffram.sh --sim
# Prints one line and exits 0 only if every check passed.
# =====================================================================
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 2 ] || { sed -n '2,15p' "$0"; exit 2; }
mkdir -p "$1"; RUN="$(cd "$1" && pwd)"; N="$2"; CORNER="${3:-slow}"; TIN="${4:-3}"; HALF="${5:-15}"
case "$N" in 128) AW=7;; 256) AW=8;; 512) AW=9;; *) echo "size: 128, 256 or 512"; exit 2;; esac
case "$CORNER" in
    slow)    C512=max_ss_100C_1v60; CDIR=max; CNAME=Slowest;;
    typical) C512=nom_tt_025C_1v80; CDIR=nom; CNAME=Typical;;
    fast)    C512=min_ff_n40C_1v95; CDIR=min; CNAME=Fastest;;
    *) echo "corner: slow, typical or fast"; exit 2;;
esac
source "$SD/../Cadence/scripts/setup_env.sh" > /dev/null || { echo "environment setup failed"; exit 2; }
DFFRAM_DIR="${DFFRAM_ROOT:-$SD/../ip/OL-DFFRAM}"
PDKV="${OPENFRAME_PDK:-/opt/pdk/sky130A}/libs.ref/sky130_fd_sc_hd/verilog"
if [ "$N" = 512 ]; then SDF="$DFFRAM_DIR/timing/sdf/$C512/DFFRAM512x32__$C512.sdf"
else SDF="$DFFRAM_DIR/timing/sdf/$CDIR/DFFRAM${N}x32.$CNAME.sdf"; fi
GL="$DFFRAM_DIR/hdl/gl/DFFRAM${N}x32.v"
for f in "$GL" "$SDF"; do [ -f "$f" ] || { echo "no $f (run ../fetch_dffram.sh --sim)"; exit 2; }; done
TAG="${N}_${CORNER}_tin${TIN}_half${HALF}"
W="$RUN/$TAG"; mkdir -p "$W"; cd "$W" || exit 2
python3 "$SD/dffram_gl_preload.py" preload.vh "u=dut:$N" || exit 2
xrun -64bit -timescale 1ns/1ps -access +rwc +define+USE_POWER_PINS "+define+DUTMOD=DFFRAM${N}x32" "+define+AW=$AW" \
     "+define+HALF=$HALF" "+define+TIN=$TIN" "+define+SDFFILE=\"$SDF\"" "+incdir+$W" \
     "$PDKV/primitives.v" "$PDKV/sky130_fd_sc_hd.v" "$GL" "$SD/tb_dffram_gl.v" -top tb_dffram_gl -exit -l xrun.log > xrun.out 2>&1
RES="$(grep -a 'PASSED' xrun.log | tail -1)"
ANN="$(grep -a -A3 'Total(T)' xrun.log | grep -a 'Path Delays' | awk '{print $NF}')"
printf 'DFFRAM%sx32 %-7s inputs +%s ns, clock %s ns: %s | path delays annotated %s %% | timing violations %s\n' \
    "$N" "$CORNER" "$TIN" "$((2 * HALF))" "${RES:-no result (see $W/xrun.log)}" "${ANN:-?}" "$(grep -a -c 'Warning!  Timing violation' xrun.log)"
echo "$RES" | grep -q ' 0 FAILED'
