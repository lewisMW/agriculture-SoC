#!/usr/bin/env bash
# =====================================================================
# extract_cap.sh -- reusable parasitic-capacitance extraction for the
# sky130_cw_ip custom MOM caps, via Pegasus EXT -> Quantus QRC (C-only).
#
# One command re-extracts any cap cell (unit cell OR array) straight from
# the source GDS. No schematic / source netlist required.
#
# Usage:
#   ./extract_cap.sh <CELL> [--gnd NET] [--gds FILE] [--dp N]
#
# Examples:
#   ./extract_cap.sh sarcta__C0            # single trim unit cap  (~1.61 fF isolated)
#   ./extract_cap.sh sarct__trim_array     # full 18-cap trim array (~1.10 fF/cap in-context)
#   ./extract_cap.sh dacca__unitcap        # DAC unit cap
#
# What it does:
#   1. KLayout labels the two met2 plates of every leaf cap cell (PLUS/MINUS,
#      layer 69:5) and reports whether CELL is a leaf or an array.
#   2. pegasus -ext (flat, text_depth all, -rc_data) builds the Quantus input.
#   3. quantus runs a C-only coupled extraction, grounding a reference plate.
#   4. Prints a capacitance summary and writes <CELL>.qrc.sp.
#
# Ground/reference net (auto, override with --gnd):
#   leaf cell  -> MINUS  (prints the single PLUS-MINUS device cap)
#   array cell -> PLUS   (common top plate; prints each bottom->top cap)
#
# Env overrides: PORT_PDK (Cadence sky130 port dir), GDS, RUNROOT.
# Requires klayout, pegasus, quantus on PATH (the Cadence sky130 port).
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cadence sky130 *port* dir. Note: do NOT read $PDK -- the xschem flow exports
# PDK=sky130A, which is a different thing. Override with $PORT_PDK if needed.
PDK="${PORT_PDK:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
# Source layout GDS -- bundled next to this script (override with $GDS).
GDS="${GDS:-$SCRIPT_DIR/mom_caps.gds}"
# Run outputs go here (gitignored). Override with $RUNROOT.
RUNROOT="${RUNROOT:-$SCRIPT_DIR/runs}"
LVS_DECK="$PDK/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl"
QRC_TECH="$PDK/quantus/extraction/typical"

CELL=""; GND=""; DP=2

die(){ echo "ERROR: $*" >&2; exit 1; }
usage(){ sed -n '2,33p' "$0"; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --gnd) GND="${2:?}"; shift 2;;
    --gds) GDS="${2:?}"; shift 2;;
    --dp)  DP="${2:?}";  shift 2;;
    -*) die "unknown option: $1";;
    *) if [ -z "$CELL" ]; then CELL="$1"; shift; else die "unexpected arg: $1"; fi;;
  esac
done

[ -n "$CELL" ] || usage 1
[ -f "$GDS" ] || die "GDS not found: $GDS (set with --gds or \$GDS)"
[ -f "$LVS_DECK" ] || die "LVS deck not found: $LVS_DECK (set \$PDK)"
[ -d "$QRC_TECH" ] || die "QRC tech dir not found: $QRC_TECH"
for t in klayout pegasus quantus; do command -v "$t" >/dev/null || die "$t not on PATH"; done

RUNDIR="$RUNROOT/$CELL"
rm -rf "$RUNDIR"; mkdir -p "$RUNDIR"; cd "$RUNDIR"
echo "=== extract_cap: $CELL ==="
echo "    GDS : $GDS"
echo "    run : $RUNDIR"

echo ">>> [1/4] Label plates + detect cell type ..."
LBL=$(klayout -b -r "$SCRIPT_DIR/label_plates.py" \
        -rd gds="$GDS" -rd cell="$CELL" -rd out="$RUNDIR/labeled.gds" 2>&1) \
  || { echo "$LBL"; die "labeling failed"; }
echo "$LBL" | grep -E "CELLTYPE|LABELED_CELLS" | sed 's/^/    /'
CELLTYPE=$(echo "$LBL" | sed -n 's/^CELLTYPE=//p')
[ -n "$CELLTYPE" ] || die "could not determine cell type"
if [ -z "$GND" ]; then
  [ "$CELLTYPE" = "leaf" ] && GND="MINUS" || GND="PLUS"
fi
echo "    type=$CELLTYPE  reference/ground net=$GND"

echo ">>> [2/4] Pegasus extraction ..."
sed 's/^text_depth -primary/text_depth -all/' "$LVS_DECK" > deck.pvl
pegasus -ext -f -dp "$DP" \
  -gds "$RUNDIR/labeled.gds" -top_cell "$CELL" \
  -rc_data -spice "$CELL.ext.sp" deck.pvl > pegasus_ext.log 2>&1 \
  || { tail -25 pegasus_ext.log; die "pegasus failed (see $RUNDIR/pegasus_ext.log)"; }
grep -m1 -E "N=.*EP=" "$CELL.ext.sp" | sed 's/^\*\* /    nets: /' || true

echo ">>> [3/4] Quantus QRC (capacitance only) ..."
cat > qrc.cmd <<EOF
input_db -type pegasus -directory_name "." -run_name "$CELL" -hierarchy_delimiter "/"
process_technology -technology_directory "$QRC_TECH"
extract -selection "all" -type "c_only_coupled"
capacitance -coupling "default" -ground_net "$GND"
filter_cap -exclude_self_cap "false" -exclude_floating_nets "false"
extraction_setup -net_name_space "LAYOUT"
output_db -type spice -include_parasitic_cap_model "comment"
output_setup -directory_name "." -file_name "$CELL.qrc.sp" -net_name_space "LAYOUT"
log_file -file_name qrc.log
EOF
quantus -cmd qrc.cmd > quantus.log 2>&1 \
  || { tail -25 quantus.log; die "quantus failed (see $RUNDIR/quantus.log)"; }

echo ">>> [4/4] Capacitance summary ..."
[ -f "$CELL.qrc.sp" ] || die "no QRC netlist produced (see $RUNDIR/quantus.log)"
awk -v gnd="$GND" '
  /^C[0-9]/ {
    v = $4 + 0.0
    if ($2 == gnd || $3 == gnd) { tot += v; main[nm++] = v }
    else { ctot += v; nc++ }
  }
  END {
    ff = 1e15
    printf "    device caps to reference net %s:\n", gnd
    printf "      count = %d\n", nm
    printf "      total = %.4f fF\n", tot * ff
    if (nm > 0) {
      mn = 1e30; mx = -1e30
      for (i = 0; i < nm; i++) { x = main[i]; if (x < mn) mn = x; if (x > mx) mx = x }
      printf "      mean  = %.4f fF   (min %.4f / max %.4f)\n", (tot/nm)*ff, mn*ff, mx*ff
    }
    if (nc > 0) printf "    net-to-net coupling caps: count = %d   total = %.4f fF\n", nc, ctot*ff
  }
' "$CELL.qrc.sp"

echo
echo "Done. Netlist: $RUNDIR/$CELL.qrc.sp   (logs: pegasus_ext.log, quantus.log)"
