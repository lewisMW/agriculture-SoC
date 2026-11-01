#!/usr/bin/env bash
# =====================================================================
# export_macro.sh -- hand-off views of the ADC analog macro for the digital
# (Innovus) flow. One set per placement variant (see afe_lay.il):
#   sar_afe    analog inputs on the left edge   (macro at the chip's bottom-left)
#   sar_afe_r  analog inputs on the right edge  (bottom-right)
#   sar_afe_b  analog inputs on the bottom edge (bottom, mid-chip)
#
#   CELL.gds   stream of the layout; every subcell renamed CELL__<name> so
#              nothing collides with the standard-cell/SRAM/IO GDS (or with
#              another variant)
#   CELL.lef   CLASS BLOCK abstract: pins, OBS on li1..met5, antenna areas
#   CELL__<corner>.lib  timing/capacitance model per corner of the digital
#              flow's MMMC (ss_100C_1v60 tt_025C_1v80 tt_100C_1v80 ff_100C_1v95)
#   CELL.v     port declaration (black box)
#   CELL.cdl   LVS source netlist, subcells renamed as in the GDS
#
# Usage:  ./export_macro.sh [--cell CELL]... [OUTDIR]
#         (default: all three cells, into <repo>/ASIC_ours/macros/sar_afe)
#
# Run each cell's sign-off first; this script uses their outputs:
#   ../run_lvs.sh sar_adc CELL --blackbox sarcta__C0  (CDL)
#   ../run_pex.sh sar_adc sar_afe --blackbox sarcta__C0
#       (wire C, optional; the variants are sar_afe mirrored/rotated, so its
#       extraction gives their pin capacitances too)
# Env overrides: SKY130, CDSLIB (default ../../cds.lib), LVSROOT (default
# ../runs/lvs), PEXROOT (../runs/pex), EXPORTROOT (../runs/export).
# Needs virtuoso, strmout, klayout and python3 on PATH (the Cadence box).
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PV="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO="$(cd "$PV/../../.." && pwd)"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
SKY130="${SKY130%/}"
CDSLIB="${CDSLIB:-$PV/../cds.lib}"
LVSROOT="${LVSROOT:-$PV/runs/lvs}"
PEXROOT="${PEXROOT:-$PV/runs/pex}"
EXPORTROOT="${EXPORTROOT:-$PV/runs/export}"
LAYERMAP="$SKY130/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap"
SCH="$REPO/agriculture_soc_main/AMS/spice/sar_afe.sch.scs"   # all variants: one circuit
PEX="$PEXROOT/sar_afe/sar_afe.pex.scs"

die(){ echo "ERROR: $*" >&2; exit 2; }
CELLS=(); OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --cell) CELLS+=("${2:?}"); shift 2;;
    -*) die "unknown option: $1";;
    *) OUT="$1"; shift;;
  esac
done
[ ${#CELLS[@]} -gt 0 ] || CELLS=(sar_afe sar_afe_r sar_afe_b)
OUT="${OUT:-$REPO/ASIC_ours/macros/sar_afe}"

for t in virtuoso strmout klayout python3; do command -v "$t" >/dev/null || die "$t not on PATH"; done
[ -f "$SCH" ] || die "no schematic netlist $SCH (netlist_spectre.sh sar_adc sar_afe $SCH)"
PEXOPT=(); if [ -f "$PEX" ]; then PEXOPT=(--pex "$PEX" --pex-top sar_afe); else echo "WARN: no $PEX; pin capacitances are gate-only"; fi
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}" SKY130
mkdir -p "$OUT"

for CELL in "${CELLS[@]}"; do
  PREFIX="${CELL}__"
  CDL="$LVSROOT/$CELL/$CELL.cdl"
  [ -f "$CDL" ] || die "no LVS run at $(dirname "$CDL") (run_lvs.sh sar_adc $CELL --blackbox sarcta__C0)"
  grep -q "Run Result *: *MATCH" "$(dirname "$CDL")/$CELL.lvsrpt.cls" 2>/dev/null \
    || die "the last LVS run of $CELL did not MATCH"
  RUN="$EXPORTROOT/$CELL"
  rm -rf "$RUN"; mkdir -p "$RUN"; cd "$RUN"
  echo "INCLUDE $(cd "$(dirname "$CDSLIB")" && pwd)/$(basename "$CDSLIB")" > cds.lib
  echo "=== $CELL"

  echo ">>> [1/3] pins and outline (afe_pins.il) ..."
  PINS_CELL="$CELL" PINS_OUT="$RUN/$CELL.pins" virtuoso -nograph -replay "$SCRIPT_DIR/afe_pins.il" -log afe_pins.log > /dev/null 2>&1 || true
  [ -s "$CELL.pins" ] || { grep -h "Error" afe_pins.log | head; die "pin dump failed (see $RUN/afe_pins.log)"; }

  echo ">>> [2/3] GDS (strmout, subcells prefixed $PREFIX) ..."
  strmout -library sar_adc -topCell "$CELL" -view layout -strmFile "$CELL.raw.gds" \
    -layerMap "$LAYERMAP" -case preserve -convertPin geometryAndText \
    -logFile strmout.log -summaryFile strmout.sum > /dev/null 2>&1 \
    || { tail -20 strmout.log; die "strmout failed (see $RUN/strmout.log)"; }
  klayout -b -r "$SCRIPT_DIR/gds_prefix.py" -rd src="$CELL.raw.gds" -rd dst="$OUT/$CELL.gds" \
    -rd top="$CELL" -rd prefix="$PREFIX" | tee gds_prefix.log

  echo ">>> [3/3] LEF, Liberty, Verilog, CDL ..."
  python3 "$SCRIPT_DIR/export_macro.py" --cell "$CELL" --pins "$CELL.pins" \
    --sch "$SCH" --sch-top sar_afe ${PEXOPT[@]+"${PEXOPT[@]}"} \
    --cdl "$CDL" --prefix "$PREFIX" --out "$OUT" | tee export.log
  ( cd "$OUT" && md5sum "$CELL".{gds,lef,v,cdl} "$CELL"__*.lib > "$RUN/md5.txt" )
  echo "    wrote $OUT: $(cd "$OUT" && ls "$CELL".* "$CELL"__*.lib | tr "\n" " ")"
done
