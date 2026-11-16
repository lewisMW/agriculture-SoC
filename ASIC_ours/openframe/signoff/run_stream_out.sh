#!/usr/bin/env bash
# =====================================================================
# run_stream_out.sh -- stream the routed OpenFrame wrapper to a merged GDS.
#
# Usage: ./run_stream_out.sh <out_dir> [<routed_db_dir>] [VAR=value ...]
#   <routed_db_dir> defaults to ../Cadence/scripts/openframe_project_wrapper_signoff
#
# The chip flow's stream-out (../../Cadence/signoff/run_stream_out.sh) with the
# two things the OpenFrame wrapper needs:
#   - the frame's power-connection blocks merged from ../Cadence/inputs
#   - the die box written on 235/4 (prBoundary): ChipFoundry's density check
#     takes the chip area from that layer, and their template has it.
#   - a flat netlist as well (.pg.flat.v): ChipFoundry's LVS compares the
#     netlist's module hierarchy with the layout's, and the layout is flat.
# Output as for the chip script: <out_dir>/openframe_project_wrapper.gds,
# .pg.v, .pg_nophys.v, .pg.flat.v, .def.gz, check_gds.txt. Exit status is check_gds.py's.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 1 ] || { sed -n '2,15p' "$0"; exit 2; }
OUT="$1"; shift
DB="$SD/../Cadence/scripts/openframe_project_wrapper_signoff"
if [ $# -ge 1 ] && [[ "$1" != *=* ]]; then DB="$1"; shift; fi
mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
CHIP="$SD/../../Cadence/signoff"
IN="$(cd "$SD/../Cadence/inputs" && pwd)"

# the database's constraints use $ACCELERATOR_DIR, so it needs the flow environment
source "$SD/../Cadence/scripts/setup_env.sh" > /dev/null || { echo "environment setup failed"; exit 2; }

{ cat "$CHIP/sky130_stream.map"
  printf '\n# ---- OpenFrame: die box on prBoundary.boundary\nDIEAREA ALL 235 4\n'
} > "$OUT/openframe_stream.map"

# The memory blocks' layouts, by OF_MEM as in ../Cadence/scripts/config.tcl:
# ChipFoundry's pre-hardened blocks (../fetch_dffram.sh; DFFRAM_ROOT overrides) or
# the DFFRAM compiler's products (DFFRAM_COMPILER_ROOT overrides).
case "${OF_MEM:-prebuilt}" in
  prebuilt)   MEMGDS="${DFFRAM_ROOT:-$SD/../ip/OL-DFFRAM}/layout/gds" ;;
  compiler_*) MEMROOT="${DFFRAM_COMPILER_ROOT:-$SD/../ip/DFFRAM_${OF_MEM#compiler_}}"
              MEMGDS="$MEMROOT/RAM1024/gds $MEMROOT/RAM512/gds" ;;
  *) echo "OF_MEM is '${OF_MEM}'"; exit 2 ;;
esac

exec "$CHIP/run_stream_out.sh" "$DB" "$OUT" \
     "EXTRA_GDS=$IN/vccd1_connection.gds $IN/vssd1_connection.gds" \
     "MACRO_GDS_DIRS=$MEMGDS" \
     "MAP=$OUT/openframe_stream.map" FLAT_NETLIST=1 "$@"
