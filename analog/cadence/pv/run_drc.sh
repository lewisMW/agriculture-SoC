#!/usr/bin/env bash
# =====================================================================
# run_drc.sh -- batch Pegasus DRC for one cell of the analog libraries
# (OA layout -> GDS via strmout, then the PDK sky130 DRC deck).
#
# Usage:
#   ./run_drc.sh <LIB> <CELL> [--dp N] [--lay-view V]
#
# Output: runs/drc/<CELL>/ next to this script (gitignored):
#   <CELL>.drc.sum   Pegasus summary, rule-by-rule
#   violations.txt   non-zero rules, split into REAL and DENSITY/FILL
# Exit status 0 when the only violations are density/fill rules, which a
# standalone block cannot meet and chip-level fill resolves.
#
# Env overrides: SKY130, RUNROOT, CDSLIB (default ../cds.lib), PEGASUS_BIN.
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
SKY130="${SKY130%/}"
CDSLIB="${CDSLIB:-$SCRIPT_DIR/../cds.lib}"
RUNROOT="${RUNROOT:-$SCRIPT_DIR/runs/drc}"
LAYERMAP="$SKY130/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap"
export PEGASUS_DRC="$SKY130/Sky130_DRC"
DECK="$PEGASUS_DRC/sky130_rev_0.0_2.12.drc.pvl"
# same Pegasus as run_lvs.sh (23.2; see the note there)
if [ -z "${PEGASUS_BIN:-}" ]; then
  PEGASUS_BIN=/opt/cadence/installs/PEGASUS232/tools/bin/pegasus
  [ -x "$PEGASUS_BIN" ] || PEGASUS_BIN=$(command -v pegasus || true)
fi

LIB=""; CELL=""; DP=4; LAYVIEW=layout
die(){ echo "ERROR: $*" >&2; exit 2; }
usage(){ sed -n '2,16p' "$0"; exit "${1:-0}"; }
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --dp) DP="${2:?}"; shift 2;;
    --lay-view) LAYVIEW="${2:?}"; shift 2;;
    -*) die "unknown option: $1";;
    *) if [ -z "$LIB" ]; then LIB="$1"; elif [ -z "$CELL" ]; then CELL="$1"; else die "unexpected arg: $1"; fi; shift;;
  esac
done
[ -n "$LIB" ] && [ -n "$CELL" ] || usage 2
[ -f "$DECK" ] || die "DRC deck not found: $DECK"
[ -x "$PEGASUS_BIN" ] || die "pegasus not found (set PEGASUS_BIN)"
command -v strmout >/dev/null || die "strmout not on PATH"
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}" SKY130

RUN="$RUNROOT/$CELL"
rm -rf "$RUN"; mkdir -p "$RUN"; cd "$RUN"
echo "INCLUDE $(cd "$(dirname "$CDSLIB")" && pwd)/$(basename "$CDSLIB")" > cds.lib
echo "=== DRC $LIB/$CELL ($LAYVIEW)   run: $RUN"

strmout -library "$LIB" -topCell "$CELL" -view "$LAYVIEW" \
  -strmFile "$CELL.gds" -layerMap "$LAYERMAP" \
  -case preserve -convertPin geometryAndText \
  -logFile strmout.log -summaryFile strmout.sum > /dev/null 2>&1 \
  || { tail -20 strmout.log; die "strmout failed (see $RUN/strmout.log)"; }

set +e
"$PEGASUS_BIN" -drc -dp "$DP" -gds "$CELL.gds" -top_cell "$CELL" \
  -ascrdb "$CELL.drc_errors.ascii" "$DECK" > pegasus.log 2>&1
RC_PEG=$?
set -e
SUM=$(ls -t ./*.sum 2>/dev/null | grep -v strmout | head -1 || true)
[ -n "$SUM" ] || { tail -30 pegasus.log; die "no DRC summary (exit $RC_PEG; see $RUN/pegasus.log)"; }
cp "$SUM" "$CELL.drc.sum" 2>/dev/null || true

# "RULECHECK <name> ....... Total Result   N (   M)" lines in the summary
awk '/^RULECHECK/ { n=$0; sub(/.*Total Result */,"",n); split(n,a," "); if (a[1]+0>0) print $2, a[1] }' "$SUM" \
  | sort > counts.txt
# density/fill = the windowed CDR/CDRW checks (*.local.* / *.global.*) and
# anything named dens/fill. Other CDR.* rules (e.g. CDR.nwell.2a.lv spacing,
# CDR.m1.6 min area) are real geometry rules and stay in REAL.
DENS='\.(local|global)\.|dens|fill'
grep -i -E "$DENS" counts.txt > density.txt || true
grep -v -i -E "$DENS" counts.txt > real.txt || true
{ echo "REAL violations:"; sed 's/^/  /' real.txt
  echo "DENSITY/FILL (chip fill resolves):"; sed 's/^/  /' density.txt; } > violations.txt
echo "    real rules failing: $(wc -l < real.txt)   density/fill rules: $(wc -l < density.txt)"
sed 's/^/    /' real.txt | head -40
[ ! -s real.txt ]
