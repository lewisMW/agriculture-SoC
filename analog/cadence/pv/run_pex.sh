#!/usr/bin/env bash
# =====================================================================
# run_pex.sh -- parasitic extraction of one LVS-clean cell, and a Spectre
# netlist of the result for the AMS flow.
#
#   1. run_lvs.sh <LIB> <CELL> --rc      (must MATCH; writes the Quantus input)
#   2. Quantus -> OA extracted view <LIB>/<CELL>/av_extracted
#      (same output settings as Jaime's bootstrap_sw extraction)
#   3. netlist_spectre.sh with av_extracted first in the view list
#      -> runs/pex/<CELL>/<CELL>.pex.scs, a `subckt <CELL> ... ends` that an
#      AMS `config cell=<CELL> use=spice` can bind.
#
# Usage:
#   ./run_pex.sh <LIB> <CELL> [--type rc_coupled|rc_decoupled|c_only_coupled]
#                             [--gnd NET] [--view NAME] [--skip-lvs]
#                             [--blackbox SUBCELL]... [--exclude-hcell SUBCELL]...
# Defaults: --type rc_coupled  --gnd vss  --view av_extracted
# --blackbox and --exclude-hcell are passed to run_lvs.sh (e.g. sarcta__C0,
# the trim's MOM unit cap, for any cell containing Erick's trim; cdac_8b for
# the macro).
#
# Env overrides: SKY130, CDSLIB (default ../cds.lib), RUNROOT.
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
SKY130="${SKY130%/}"
CDSLIB="${CDSLIB:-$SCRIPT_DIR/../cds.lib}"
RUNROOT="${RUNROOT:-$SCRIPT_DIR/runs}"
QRCTECH="$SKY130/quantus/extraction/typical/qrcTechFile"

LIB=""; CELL=""; TYPE=rc_coupled; GND=vss; SKIPLVS=0; VIEW=av_extracted
die(){ echo "ERROR: $*" >&2; exit 2; }
usage(){ sed -n '2,20p' "$0"; exit "${1:-0}"; }
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --type) TYPE="${2:?}"; shift 2;;
    --gnd) GND="${2:?}"; shift 2;;
    --view) VIEW="${2:?}"; shift 2;;
    --skip-lvs) SKIPLVS=1; shift;;
    --blackbox) export LVS_BLACKBOX="${LVS_BLACKBOX:-} ${2:?}"; shift 2;;
    --exclude-hcell) export LVS_EXCLUDE_HCELL="${LVS_EXCLUDE_HCELL:-} ${2:?}"; shift 2;;
    -*) die "unknown option: $1";;
    *) if [ -z "$LIB" ]; then LIB="$1"; elif [ -z "$CELL" ]; then CELL="$1"; else die "unexpected arg: $1"; fi; shift;;
  esac
done
[ -n "$LIB" ] && [ -n "$CELL" ] || usage 2
[ -f "$QRCTECH" ] || die "QRC tech file not found: $QRCTECH"
for t in quantus virtuoso; do command -v "$t" >/dev/null || die "$t not on PATH"; done
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}" SKY130 CDS_Netlisting_Mode=Analog
CDSLIB_ABS="$(cd "$(dirname "$CDSLIB")" && pwd)/$(basename "$CDSLIB")"

LVSRUN="$RUNROOT/lvs-pex/$CELL"
if [ "$SKIPLVS" = 0 ]; then
  echo ">>> [1/3] LVS with Quantus data ..."
  RUNROOT="$RUNROOT/lvs-pex" "$SCRIPT_DIR/run_lvs.sh" "$LIB" "$CELL" --rc \
    || die "LVS did not MATCH; fix it before extracting (see $LVSRUN)"
fi
[ -d "$LVSRUN/svdb" ] || [ -d "$LVSRUN" ] || die "no LVS run at $LVSRUN"

RUN="$RUNROOT/pex/$CELL"
rm -rf "$RUN"; mkdir -p "$RUN"; cd "$RUN"
echo "INCLUDE $CDSLIB_ABS" > cds.lib

echo ">>> [2/3] Quantus ($TYPE, ground $GND) -> $LIB/$CELL/$VIEW ..."
# Quantus wants a technology library (name -> technology dir), a corner.defs
# in that dir (corner -> subdir), and for extracted-view output the device
# mapping extview.trp. The port ships the corner dir and extview.trp but no
# corner.defs or library file, so assemble a local technology dir.
mkdir -p qrctech
ln -s "$SKY130/quantus/extraction/typical" qrctech/typical
ln -s "$SKY130/quantus/extraction/extview.trp" qrctech/extview.trp
echo "DEFINE typical typical" > qrctech/corner.defs
echo "DEFINE sky130 $RUN/qrctech" > qrctech.lib
cat > qrc.cmd <<EOF
input_db -type pegasus \\
    -design_cell_name "$CELL layout $LIB" \\
    -directory_name "$LVSRUN" \\
    -format "DFII" \\
    -library_definitions_file "$RUN/cds.lib" \\
    -run_name "$CELL"
process_technology \\
    -technology_library_file "$RUN/qrctech.lib" \\
    -technology_name "sky130" -technology_corner "typical" -temperature 25.0
extract -selection "all" -type "$TYPE"
capacitance -decoupling_factor 1.0 -ground_net "$GND"
extraction_setup -net_name_space "SCHEMATIC" -max_fracture_length infinite
filter_res -merge_parallel_res false -min_res 0.001
output_db -type extracted_view \\
    -cdl_out_map_directory "$LVSRUN" \\
    -cap_component "pcapacitor" -cap_property_name "c" \\
    -res_component "presistor" -res_property_name "r" \\
    -include_cap_model "false" -include_parasitic_cap_model "false" \\
    -include_parasitic_res_model "comment" -include_res_model "false" \\
    -device_finger_delimiter "@" -enable_cellview_check true \\
    -transfer_net_expression true \\
    -view_name "$VIEW"
output_setup -directory_name "$RUN" -temporary_directory_name "qrc_tmp"
log_file -file_name "$RUN/quantus.log"
EOF
quantus -cmd qrc.cmd > quantus.out 2>&1 || { tail -30 quantus.out; die "quantus failed (see $RUN/quantus.log)"; }
grep -E -i "^(ERROR|\*\*ERROR)" quantus.out quantus.log 2>/dev/null | head -5 || true

echo ">>> [3/3] Spectre netlist of the extracted view ..."
RUNDIR="$RUN/netlist" "$SCRIPT_DIR/netlist_spectre.sh" "$LIB" "$CELL" "$RUN/$CELL.pex.scs" \
    "$VIEW" spectre cmos_sch cmos.sch schematic veriloga
P="$RUN/$CELL.pex.scs"
# Quantus names bus bits net(7); the schematic netlist (and AMSD's by-name
# port binding) use net<7>. Normalise, then insist the ports match the
# schematic's exactly, so `config cell=$CELL use=spice` binds either netlist.
sed -i -e 's/\\(\([0-9][0-9]*\)\\)/\\<\1\\>/g' "$P"
ports(){ awk -v c="$CELL" '$1=="subckt" && $2==c {h=1} h{s=$0; k=(s ~ /\\$/); sub(/\\$/,"",s); l=l" "s; if(!k){print l; exit}}' "$1" \
         | tr ' ' '\n' | sed '1,/^subckt$/d' | sed '/^$/d' | sed 1d | sort; }
RUNDIR="$RUN/netlist_sch" "$SCRIPT_DIR/netlist_spectre.sh" "$LIB" "$CELL" "$RUN/$CELL.sch.scs" > /dev/null
if ! diff <(ports "$RUN/$CELL.sch.scs") <(ports "$P") > ports.diff; then
  cat ports.diff; die "extracted ports differ from the schematic's (see $RUN/ports.diff)"
fi
echo "    ports: $(ports "$P" | wc -l), identical to the schematic netlist"
# count on joined lines: long hierarchical device names (a flattened
# sub-cell's X|I|C...) wrap before the model name
awk '{ if (sub(/\\$/, "")) printf "%s ", $0; else print }' "$P" > joined.scs
echo "    devices: $(grep -c -E '\) +[np]fet_' joined.scs) FETs, $(grep -c -E '\) +cap_mim' joined.scs) MIM caps;" \
     "parasitics: $(grep -c -E '\) +capacitor ' joined.scs) C, $(grep -c -E '\) +resistor ' joined.scs) R"
