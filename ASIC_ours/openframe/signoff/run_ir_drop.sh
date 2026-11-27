#!/usr/bin/env bash
# =====================================================================
# run_ir_drop.sh -- static IR drop on the core supply of the routed OpenFrame
# wrapper (../Cadence/scripts/ir_drop.tcl, Innovus early rail analysis).
#
# Usage: ./run_ir_drop.sh <out_dir> [<routed_db_dir>] [VAR=value ...]
#   <routed_db_dir> defaults to ../Cadence/scripts/openframe_project_wrapper_signoff
#   VAR=value       any of ir_drop.tcl's optional variables, for example
#                     SCALE=2                      every current doubled
#                     ACTIVITY=0.3
#                     "MACRO_POWER=DFFRAM512x32 7.4 DFFRAM256x32 3.9 DFFRAM128x32 2.5"
#                                                  mW per instance of each memory
#                                                  block (their libraries have no
#                                                  power data; these figures are
#                                                  Genus' for each block's gate
#                                                  netlist at 33.33 MHz, typical
#                                                  corner, 0.2 toggles a cycle on
#                                                  the inputs, no wire capacitance)
#                     QRC=<extraction technology file>, if $SKY130 is not set
#
# Prints the summary (also <out_dir>/ir_drop_summary.txt; the tool's reports and
# plots are under <out_dir>/rail). Exit status 0 if the analysis finished, no
# node is beyond the limit (5 % of the supply unless LIMIT_MV is given) and no
# current is over the LEF's DC limit; 1 if there are violations; 2 if it did not
# finish.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 1 ] || { sed -n '2,25p' "$0"; exit 2; }
OUT="$1"; shift
DB="$SD/../Cadence/scripts/openframe_project_wrapper_signoff"
if [ $# -ge 1 ] && [[ "$1" != *=* ]]; then DB="$1"; shift; fi
[ -d "$DB" ] || { echo "no routed database $DB"; exit 2; }
DB="$(cd "$DB" && pwd)"
mkdir -p "$OUT/work"; OUT="$(cd "$OUT" && pwd)"
TCL="$(cd "$SD/../Cadence/scripts" && pwd)/ir_drop.tcl"

# Innovus and the licence: from the caller's environment, else the flow's
if ! command -v innovus > /dev/null 2>&1; then
    source "$SD/../Cadence/scripts/setup_env.sh" > /dev/null || { echo "environment setup failed"; exit 2; }
fi

EXEC="set DB {$DB}; set OUT {$OUT}"
for a in "$@"; do
    [[ "$a" == *=* ]] || { echo "not VAR=value: $a"; exit 2; }
    EXEC="$EXEC; set ${a%%=*} {${a#*=}}"
done

cd "$OUT/work" || exit 2
innovus -stylus -no_gui -batch -execute "$EXEC" -files "$TCL" < /dev/null > "$OUT/ir_drop.log" 2>&1
grep -a "^IR_DROP_ERROR" "$OUT/ir_drop.log"
if ! grep -a -q "^IR_DROP_DONE" "$OUT/ir_drop.log"; then
    echo "the analysis did not finish: see $OUT/ir_drop.log"; exit 2
fi
grep -a "^IR_DROP_SUMMARY: " "$OUT/ir_drop.log" | sed 's/^IR_DROP_SUMMARY: //'
if grep -a "^IR_DROP_SUMMARY: .*Number of Violations" "$OUT/ir_drop.log" | grep -a -q -v "Number of Violations: 0 "; then
    echo "IR drop: violations"; exit 1
fi
if grep -a "^IR_DROP_SUMMARY: Current Limit Violations" "$OUT/ir_drop.log" | grep -a -q -v "Violations: 0 "; then
    echo "IR drop within the limit; current-limit violations"; exit 1
fi
echo "IR drop: no violations"
