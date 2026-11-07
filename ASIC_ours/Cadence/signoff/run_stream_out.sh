#!/usr/bin/env bash
# =====================================================================
# run_stream_out.sh -- stream a routed Innovus DB to a merged chip GDS,
# write the LVS netlists, then check the GDS (check_gds.py).
#
# Usage: ./run_stream_out.sh <routed_db_dir> <out_dir> [VAR=value ...]
#   VAR=value pairs are passed to stream_out.tcl, e.g. EXTRA_GDS=/x/y.gds,
#   LABEL_PORTS=0, TOP=name, CPUS=8.
# Output: <out_dir>/<TOP>.gds, .pg.v, .pg_nophys.v, .def.gz, innovus.log,
#         check_gds.txt (exit status of check_gds.py is this script's).
# Env: INNOVUS (default: innovus from DDI221), KLAYOUT (default klayout),
#      SKY130 (Cadence sky130 port, for the layermap).
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 2 ] || { sed -n '2,14p' "$0"; exit 2; }
DB="$(cd "$1" && pwd)" || exit 2
OUT="$2"; shift 2
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
export PATH=/opt/cadence/installs/DDI221/bin:$PATH
INNOVUS="${INNOVUS:-innovus}"
KLAYOUT="${KLAYOUT:-klayout}"
export LC_ALL="${LC_ALL:-en_US.utf8}" SIGNOFF_DIR="$SD"
EXEC="set DB {$DB}; set OUT {$OUT}"
for kv in "$@"; do EXEC="$EXEC; set ${kv%%=*} {${kv#*=}}"; done

echo "=== stream-out $DB -> $OUT  ($(date '+%F %T'))"
cd "$OUT" || exit 2
T0=$(date +%s)
"$INNOVUS" -stylus -no_gui -batch -execute "$EXEC" -files "$SD/stream_out.tcl" \
    -log innovus < /dev/null > innovus.stdout 2>&1
RC=$?
echo "    innovus exit $RC after $(( $(date +%s) - T0 )) s (log: $OUT/innovus.log)"
if grep -q "Fail to find any .* license\|LMF-10096" innovus.stdout; then
    echo "ERROR: licence failure; retry later"; exit 3; fi
[ -f STREAM_OUT_OK ] || { grep -E "STREAM_OUT_ERROR|^\*\*ERROR" innovus.stdout | tail -10; exit 1; }
TOP=$(basename "$(ls -t ./*.gds | head -1)" .gds)
echo "=== check_gds $OUT/$TOP.gds"
"$KLAYOUT" -b -r "$SD/check_gds.py" -rd gds="$OUT/$TOP.gds" -rd top="$TOP" \
    -rd masters="$OUT/masters.txt" -rd pincheck=1 > check_gds.txt 2>&1
RC=$?
cat check_gds.txt
exit $RC
