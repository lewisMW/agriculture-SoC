#!/usr/bin/env bash
# =====================================================================
# run_lvs.sh -- Pegasus LVS of the OpenFrame wrapper: the merged GDS against
# the Innovus netlist, with the chip flow's script
# (../../Cadence/signoff/run_chip_lvs.sh) and the wrapper's supplies.
#
# Usage: ./run_lvs.sh <stream_dir> <out_dir> [run_chip_lvs.sh options]
#   <stream_dir>  output of run_stream_out.sh (openframe_project_wrapper.gds, .pg.v)
#   <out_dir>     new directory; <out_dir>.in holds the two generated inputs
#
# What differs from the chip:
#   - Supplies are the frame's (vccd1/vssd1 core, vdda1/vssa1 for the ADC).
#   - Each frame supply has several pins on the wrapper's edge, joined outside
#     it by the frame, so texts of one supply name are one net here
#     (virtual_connect -name). The core grid itself carries no text: it gets
#     its name only through the metal from a frame pin, so a pin that does not
#     reach the grid still shows up as a mismatch.
#   - vccd1_connection / vssd1_connection are layout-only blocks (metal from the
#     frame pins to the core ring): empty subcircuits in the source, and their
#     layout is extracted like any other metal.
# This is our own sign-off LVS. ChipFoundry's precheck runs its own
# (Magic + netgen) from lvs/openframe_project_wrapper/lvs_config.json.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 2 ] || { sed -n '2,22p' "$0"; exit 2; }
ST="$(cd "$1" && pwd)" || exit 2
OUT="$2"; shift 2
TOP=openframe_project_wrapper
IN="$OUT.in"; mkdir -p "$IN"; IN="$(cd "$IN" && pwd)"

POWER="vccd1 vdda1 vccd vccd2 vdda vdda2 vddio"
GROUND="vssd1 vssa1 vssd vssd2 vssa vssa2 vssio"

cat > "$IN/openframe_extra.cdl" <<'EOF'
* layout-only blocks of the OpenFrame template: no pins, no devices
.SUBCKT vccd1_connection
.ENDS
.SUBCKT vssd1_connection
.ENDS
EOF
cat > "$IN/openframe_extra.pvl" <<EOF
schematic_path "$IN/openframe_extra.cdl" cdl
// the frame joins the pins of one supply outside the wrapper
virtual_connect -name $POWER $GROUND
EOF

# the memory blocks are black boxes (as the OpenRAM macro was): pins from their
# LEFs, by OF_MEM as in ../Cadence/scripts/config.tcl
case "${OF_MEM:-prebuilt}" in
  prebuilt)   MEMLEF="$(ls "${DFFRAM_ROOT:-$SD/../ip/OL-DFFRAM}"/layout/lef/*.lef 2>/dev/null | paste -s -d:)" ;;
  compiler_*) MEMROOT="${DFFRAM_COMPILER_ROOT:-$SD/../ip/DFFRAM_${OF_MEM#compiler_}}"
              MEMLEF="$MEMROOT/RAM1024/lef/RAM1024.lef:$MEMROOT/RAM512/lef/RAM512.lef" ;;
  *) echo "OF_MEM is '${OF_MEM}'"; exit 2 ;;
esac
export LVS_EXTRA_LEF="$MEMLEF"

# PGNETS=- : keep every supply text (no thinning to one per net)
PGNETS=- LVS_SUPPLY0=vssd1 LVS_SUPPLY1=vccd1 \
LVS_POWER_NAMES="$POWER" LVS_GROUND_NAMES="$GROUND" \
exec "$SD/../../Cadence/signoff/run_chip_lvs.sh" "$ST/$TOP.gds" "$ST/$TOP.pg.v" "$TOP" "$OUT" \
     --deck-extra "$IN/openframe_extra.pvl" "$@"
