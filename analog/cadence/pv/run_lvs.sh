#!/usr/bin/env bash
# =====================================================================
# run_lvs.sh -- batch LVS for one cell of the analog libraries:
#   OA layout -> GDS (strmout), OA schematic -> CDL (si/auCdl),
#   then Pegasus LVS with the patched sky130 deck (see lvs_deck.sh).
#
# Usage:
#   ./run_lvs.sh <LIB> <CELL> [--rc] [--dp N] [--sch-view V] [--lay-view V]
#                             [--blackbox SUBCELL]... [--exclude-hcell SUBCELL]...
#
# Examples:
#   ./run_lvs.sh sar_adc inverter
#   ./run_lvs.sh sar_adc comparator
#   ./run_lvs.sh sar_adc sar_adc_afe --rc     # also write the Quantus input
#
# --blackbox SUBCELL (repeatable, or LVS_BLACKBOX="a b") compares SUBCELL
# as a black box on both sides: only its pins and their connections are
# checked. Used for the trim's MOM unit cap sarcta__C0, which is plain metal
# that no device rule extracts (Erick's LVS setup, 9 Oct 2026).
#
# --exclude-hcell SUBCELL (repeatable, or LVS_EXCLUDE_HCELL="a b") keeps
# SUBCELL from being a correspondence point: it is compared flattened into
# its parent. Used for Hee's cdac_8b, whose schematic contains the bootstrap
# switch while its layout doesn't (the macro places the switch beside it).
#
# Output: runs/lvs/<CELL>/ next to this script (gitignored).
#   <CELL>.lvsrpt.cls  comparison report ("Run Result : MATCH")
#   <CELL>.lvsrpt      extraction report (label/short/open warnings)
#   <CELL>.gds, <CELL>.cdl, <CELL>.spi (extracted layout netlist)
# Exit status 0 only on MATCH.
#
# Env overrides: SKY130 (Cadence sky130 port dir), RUNROOT,
#                CDSLIB (default: ../cds.lib, i.e. analog/cadence/cds.lib).
# Needs strmout and si on PATH (source ~/.bashrc on the box); Pegasus 23.2
# is picked up from its install dir (see PEGASUS_BIN below).
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
SKY130="${SKY130%/}"
CDSLIB="${CDSLIB:-$SCRIPT_DIR/../cds.lib}"
RUNROOT="${RUNROOT:-$SCRIPT_DIR/runs/lvs}"
LAYERMAP="$SKY130/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap"

# Pegasus 23.2, not 24.1: on this deck 24.1 attaches each pin label to two
# co-located nets and reports false opens (Hee's carray_8b: MATCH on 23.2,
# MISMATCH on 24.1, same GDS/CDL/deck). main's analog/cadence/bashrc pins
# 23.2 for the same reason. Override with PEGASUS_BIN.
if [ -z "${PEGASUS_BIN:-}" ]; then
  PEGASUS_BIN=/opt/cadence/installs/PEGASUS232/tools/bin/pegasus
  [ -x "$PEGASUS_BIN" ] || PEGASUS_BIN=$(command -v pegasus || true)
fi

LIB=""; CELL=""; DP=4; RC=0; CDLONLY=0; SCHVIEW=schematic; LAYVIEW=layout
BLACKBOX="${LVS_BLACKBOX:-}"
EXCLUDE="${LVS_EXCLUDE_HCELL:-}"

die(){ echo "ERROR: $*" >&2; exit 2; }
usage(){ sed -n '2,30p' "$0"; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --rc) RC=1; shift;;
    --cdl-only) CDLONLY=1; shift;;
    --dp) DP="${2:?}"; shift 2;;
    --sch-view) SCHVIEW="${2:?}"; shift 2;;
    --lay-view) LAYVIEW="${2:?}"; shift 2;;
    --blackbox) BLACKBOX="$BLACKBOX ${2:?}"; shift 2;;
    --exclude-hcell) EXCLUDE="$EXCLUDE ${2:?}"; shift 2;;
    -*) die "unknown option: $1";;
    *) if [ -z "$LIB" ]; then LIB="$1"; elif [ -z "$CELL" ]; then CELL="$1"; else die "unexpected arg: $1"; fi; shift;;
  esac
done
[ -n "$LIB" ] && [ -n "$CELL" ] || usage 2
[ -f "$CDSLIB" ] || die "cds.lib not found: $CDSLIB"
[ -f "$LAYERMAP" ] || die "layer map not found: $LAYERMAP (set \$SKY130)"
for t in strmout si; do command -v "$t" >/dev/null || die "$t not on PATH"; done
[ -x "$PEGASUS_BIN" ] || die "pegasus not found (set PEGASUS_BIN)"
# filelist/python tools elsewhere in the flow die on an ASCII locale
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}"
export SKY130 CDS_Netlisting_Mode=Analog

RUN="$RUNROOT/$CELL"
rm -rf "$RUN"; mkdir -p "$RUN"; cd "$RUN"
# INCLUDE resolves the repo cds.lib's relative DEFINEs against its own dir
echo "INCLUDE $(cd "$(dirname "$CDSLIB")" && pwd)/$(basename "$CDSLIB")" > cds.lib
"$SCRIPT_DIR/lvs_deck.sh" > deck.pvl
for b in $BLACKBOX; do printf 'lvs_black_box %s -source_layout\n' "$b" >> deck.pvl; done
for c in $EXCLUDE; do printf 'lvs_exclude_hcell %s\n' "$c" >> deck.pvl; done

echo "=== LVS $LIB/$CELL  ($LAYVIEW vs $SCHVIEW) ==="
echo "    run: $RUN"
[ -n "${BLACKBOX// /}" ] && echo "    black boxes:$BLACKBOX"
[ -n "${EXCLUDE// /}" ] && echo "    compared flattened:$EXCLUDE"

if [ "$CDLONLY" = 1 ]; then echo ">>> [1/3] strmout skipped (--cdl-only)"; else
echo ">>> [1/3] strmout ..."
strmout -library "$LIB" -topCell "$CELL" -view "$LAYVIEW" \
  -strmFile "$CELL.gds" -layerMap "$LAYERMAP" \
  -case preserve -convertPin geometryAndText \
  -logFile strmout.log -summaryFile strmout.sum > /dev/null 2>&1 \
  || { tail -20 strmout.log; die "strmout failed (see $RUN/strmout.log)"; }
fi

echo ">>> [2/3] CDL netlist (si auCdl) ..."
# The full variable set the CDL Out form writes: the auCdl formatters read
# shrinkFACTOR, checkScale, pinMAP etc. and fail (OSSHNL-411) if unbound.
cat > si.env <<EOF
simLibName = "$LIB"
simCellName = "$CELL"
simViewName = "$SCHVIEW"
simSimulator = "auCdl"
simNotIncremental = 't
simReNetlistAll = nil
simViewList = '("auCdl" "schematic")
simStopList = '("auCdl")
simNetlistHier = 't
hnlNetlistFileName = "$CELL.cdl"
resistorModel = ""
shortRES = 2000.0
preserveRES = 't
checkRESVAL = 't
checkRESSIZE = 'nil
preserveCAP = 't
checkCAPVAL = 't
checkCAPAREA = 'nil
checkCAPPERI = 'nil
preserveDIO = 't
checkDIOAREA = 't
checkDIOPERI = 't
preserveBangInNetlist = 'nil
preserveALL = 't
setEQUIV = ""
simPrintInhConnAttributes = 'nil
checkScale = "meter"
checkLDD = 'nil
pinMAP = 'nil
shrinkFACTOR = 0.0
globalPowerSig = ""
globalGndSig = ""
displayPININFO = 't
incFILE = ""
cdlSimViewList = '("auCdl" "schematic")
cdlSimStopList = '("auCdl")
EOF
si . -batch -command netlist -cdslib ./cds.lib > si.out 2>&1 \
  || { tail -20 si.out; die "si netlisting failed (see $RUN/si.out, si.log)"; }
[ -s "$CELL.cdl" ] || die "no CDL written (see $RUN/si.out)"
[ "$CDLONLY" = 1 ] && { echo "    CDL: $RUN/$CELL.cdl"; exit 0; }

echo ">>> [3/3] pegasus -lvs ($("$PEGASUS_BIN" -version 2>/dev/null | grep -o -m1 "[0-9][0-9]\.[0-9]*-[a-z0-9]*")) ..."
RCOPT="-no_rc_data"; [ "$RC" = 1 ] && RCOPT="-rc_data"
set +e
"$PEGASUS_BIN" -lvs -dp "$DP" -automatch -check_schematic $RCOPT -ui_data \
  -gds "$CELL.gds" -top_cell "$CELL" \
  -source_cdl "$CELL.cdl" -source_top_cell "$CELL" \
  -spice "$CELL.spi" deck.pvl > pegasus.log 2>&1
RC_PEG=$?
set -e
CLS=$(ls -t ./*.cls 2>/dev/null | head -1 || true)
if [ -z "$CLS" ]; then
  tail -30 pegasus.log
  die "pegasus produced no comparison report (exit $RC_PEG; see $RUN/pegasus.log)"
fi
RESULT=$(sed -n 's/^#*[[:space:]]*Run Result[[:space:]]*:[[:space:]]*//p' "$CLS" | head -1 | tr -d ' ')
echo "    result: ${RESULT:-UNKNOWN}   ($CLS)"
grep -E '^#+[[:space:]]+:?[[:space:]]*\[(INFO|WARN|ERROR)\]' "$CLS" | sed 's/^#*[[:space:]]*/    /' || true
[ "$RESULT" = "MATCH" ]
