#!/usr/bin/env bash
# =====================================================================
# run_io_timing.sh -- timing of the routed wrapper at its pins (io_timing.tcl,
# io_timing_summary.py): clock-to-output, setup and hold of every pin against
# the clock pin, and the flash pass-through's delay.
#
# Usage: ./run_io_timing.sh <out_dir> [<routed_db_dir>]
#   <routed_db_dir> defaults to ../Cadence/scripts/openframe_project_wrapper_signoff
# Prints the table (also <out_dir>/io_timing.txt). About two minutes.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 1 ] || { sed -n '2,10p' "$0"; exit 2; }
OUT="$1"; DB="${2:-$SD/../Cadence/scripts/openframe_project_wrapper_signoff}"
[ -d "$DB" ] || { echo "no routed database $DB"; exit 2; }
DB="$(cd "$DB" && pwd)"; mkdir -p "$OUT/work"; OUT="$(cd "$OUT" && pwd)"
if ! command -v innovus > /dev/null 2>&1; then
    source "$SD/../Cadence/scripts/setup_env.sh" > /dev/null || { echo "environment setup failed"; exit 2; }
fi
cd "$OUT/work" || exit 2
innovus -stylus -no_gui -batch -execute "set DB {$DB}; set OUT {$OUT}" -files "$SD/io_timing.tcl" < /dev/null > "$OUT/io_timing.log" 2>&1
grep -a -q "^IO_TIMING_DONE" "$OUT/io_timing.log" || { echo "the analysis did not finish: see $OUT/io_timing.log"; grep -a "^IO_TIMING" "$OUT/io_timing.log"; exit 2; }
python3 "$SD/io_timing_summary.py" "$OUT" | tee "$OUT/io_timing.txt"
