#!/usr/bin/env bash
# =====================================================================
# run_chip_drc.sh -- Pegasus DRC of a merged chip GDS with the sky130 deck
#
# Usage: ./run_chip_drc.sh <gds> <top_cell> <out_dir> [--dp N]
#            [--max-results N] [--min-free-gb G] [--no-classify]
#
#   <out_dir> must not already hold a DRC run (nothing is overwritten).
#   --dp N           Pegasus threads (default 8)
#   --max-results N  results kept per rule in the ASCII database (default
#                    5000); the summary still counts every result
#   --min-free-gb G  wait until `free -g` shows G GB available before
#                    launching (default 20: the run needs ~10 GB and 8 GB
#                    must stay free for everyone else)
#
# Output in <out_dir>:
#   <top>.drc.sum          Pegasus summary (rule by rule)
#   <top>.drc_errors.ascii results database (ASCII)
#   counts.txt             every rule with results: "<rule> <hier> <flat>"
#   violations.txt         REAL rules vs DENSITY/FILL rules, each REAL rule
#                          split by location (classify_drc.py)
#   breakdown.txt          per rule x location class, with example points
#   density.txt            the density/fill rules with results
#   density_values.txt     each density check: failing windows, worst value
#   pegasus.log, mem.log   tool log; available memory/Pegasus RSS each minute
# Exit 0 = no REAL violations outside library/IP cells; 1 = REAL violations
# in the top-level routing / std-cell area; 2 = usage/tool error.
#
# Env: SKY130 (Cadence sky130 port), PEGASUS_BIN (default Pegasus 23.2;
#      24.1 has deck problems, see analog/cadence/pv/README.md), KLAYOUT.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die(){ echo "ERROR: $*" >&2; exit 2; }
usage(){ sed -n '2,32p' "$0"; exit "${1:-0}"; }

GDS=""; TOP=""; OUT=""; DP=8; MAXRES=5000; MINFREE=20; CLASSIFY=1
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --dp) DP="${2:?}"; shift 2;;
    --max-results) MAXRES="${2:?}"; shift 2;;
    --min-free-gb) MINFREE="${2:?}"; shift 2;;
    --no-classify) CLASSIFY=0; shift;;
    -*) die "unknown option $1";;
    *) if [ -z "$GDS" ]; then GDS="$1"; elif [ -z "$TOP" ]; then TOP="$1"; elif [ -z "$OUT" ]; then OUT="$1"; else die "extra arg $1"; fi; shift;;
  esac
done
[ -n "$OUT" ] || usage 2
[ -f "$GDS" ] || die "no GDS $GDS"
GDS="$(cd "$(dirname "$GDS")" && pwd)/$(basename "$GDS")"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"; SKY130="${SKY130%/}"
export PEGASUS_DRC="$SKY130/Sky130_DRC" SKY130
DECK="$PEGASUS_DRC/sky130_rev_0.0_2.12.drc.pvl"
PEGASUS_BIN="${PEGASUS_BIN:-/opt/cadence/installs/PEGASUS232/tools/bin/pegasus}"
KLAYOUT="${KLAYOUT:-klayout}"
[ -f "$DECK" ] || die "deck not found: $DECK"
[ -x "$PEGASUS_BIN" ] || die "pegasus not found: $PEGASUS_BIN"
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}"

mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
[ -e "$OUT/$TOP.drc.sum" ] && die "$OUT already holds a DRC run; use a new directory"
cd "$OUT" || die "cd $OUT"

# ---- memory gate -------------------------------------------------------
avail(){ free -g | awk '/^Mem:/{print $7}'; }
while [ "$(avail)" -lt "$MINFREE" ]; do
  echo "$(date '+%F %T') waiting: $(avail) GB available < $MINFREE GB"; sleep 120
done
echo "=== DRC $TOP  gds=$GDS  dp=$DP  ($(avail) GB available, $(date '+%F %T'))"

# Control file (overrides the deck's mycell placeholders), as in the PDK's
# Sky130_FILLGEN/GDS_flow/drc_CTL.pvl.
cat > drc_CTL.pvl <<EOF
layout_format gdsii;
layout_path "$GDS";
layout_primary $TOP;
report_summary -drc "$TOP.drc.sum" -replace;
results_db -drc "$TOP.drc_errors.ascii" -ascii;
max_results -drc $MAXRES;
EOF

# ---- memory log (our Pegasus processes only) ----------------------------
( while :; do
    rss=$(ps -u "$(id -u)" -o rss=,args= | awk 'tolower($0) ~ /peg[a]sus/{s+=$1} END{printf "%.1f", s/1048576}')
    echo "$(date '+%T') avail_GB=$(avail) pegasus_RSS_GB=$rss"; sleep 60
  done ) > mem.log 2>&1 &
MON=$!
trap 'kill $MON 2>/dev/null' EXIT

T0=$(date +%s)
"$PEGASUS_BIN" -drc -dp "$DP" -gds "$GDS" -top_cell "$TOP" \
    -control drc_CTL.pvl -log_dir LOGS "$DECK" > pegasus.log 2>&1
RC=$?
T1=$(date +%s)
{ kill $MON && wait $MON; } 2>/dev/null
PEAK=$(awk '{for(i=1;i<=NF;i++){split($i,a,"="); if(a[1]=="pegasus_RSS_GB" && a[2]+0>m) m=a[2]+0}} END{print m+0}' mem.log)
MINAV=$(awk '{for(i=1;i<=NF;i++){split($i,a,"="); if(a[1]=="avail_GB" && (m=="" || a[2]+0<m)) m=a[2]+0}} END{print m}' mem.log)
WMEM=$(grep -o "Max peak memory\[MB\]: *[0-9]*" pegasus.log | tail -1 | grep -o "[0-9]*$")
echo "    pegasus exit $RC, $(( (T1-T0)/60 )) min $(( (T1-T0)%60 )) s; Pegasus RSS ${PEAK} GB (sampled each minute), worker peak ${WMEM:-?} MB, min available ${MINAV} GB (mem.log)"
if grep -q -E "LMF-[0-9]+|License call failed|Failed to check ?out" pegasus.log; then
  echo "ERROR: licence problem, see $OUT/pegasus.log"; exit 2; fi
[ -f "$TOP.drc.sum" ] || { tail -30 pegasus.log; die "no summary (pegasus exit $RC; see $OUT/pegasus.log)"; }

# ---- counts, REAL vs DENSITY/FILL ---------------------------------------
# "RULECHECK <name> ..... Total Result  N (  M)": N = hierarchical results
# (one per cell definition; the ASCII database holds at most --max-results
# of them), M = flat count over every placement.
awk '/^RULECHECK/ { n=$0; sub(/.*Total Result */,"",n); gsub(/[()]/," ",n); split(n,a," "); if (a[1]+0>0) print $2, a[1], a[2] }' \
    "$TOP.drc.sum" | sort > counts.txt
# density/fill = windowed CDR/CDRW checks (*.local.*, *.global.*) and the
# *.fill.* rules on fill shapes. Other CDR.* rules are geometry rules: REAL.
DENS='\.(local|global)\.|dens|\.fill\.'
grep -E "$DENS" counts.txt > density.txt || true
grep -v -E "$DENS" counts.txt > real.txt || true
echo "    rules with results: $(wc -l < counts.txt)  (REAL $(wc -l < real.txt), DENSITY/FILL $(wc -l < density.txt))"
# density values (failing windows, worst value) from the deck's density RDBs
python3 "$SD/density_report.py" "$OUT" > density_values.txt 2>&1 || true

RCC=0
if [ "$CLASSIFY" = 1 ]; then
  "$KLAYOUT" -b -r "$SD/classify_drc.py" -rd gds="$GDS" -rd top="$TOP" \
      -rd rdb="$OUT/$TOP.drc_errors.ascii" -rd counts="$OUT/counts.txt" \
      -rd out="$OUT" > classify.log 2>&1
  RCC=$?
  [ -f breakdown.txt ] || { tail -20 classify.log; echo "WARN: classification failed (classify.log)"; }
fi
if [ ! -f violations.txt ]; then
  { echo "REAL violations:"; sed 's/^/  /' real.txt
    echo "DENSITY/FILL (chip fill resolves):"; sed 's/^/  /' density.txt; } > violations.txt
fi
cat violations.txt
exit $RCC
