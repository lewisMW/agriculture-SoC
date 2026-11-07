#!/usr/bin/env bash
# =====================================================================
# run_fill.sh -- sky130 metal/diff/poly fill for a merged chip GDS, then
# DRC of the filled GDS.
#
# Usage: ./run_fill.sh <gds> <top_cell> <out_dir> [--dp N] [--before <drc_dir>]
#                      [--no-drc]
#
# Follows $SKY130/Sky130_FILLGEN/GDS_flow (fill deck fillgen.v08.pvl):
#   step 2   Pegasus runs fillgen.v08.pvl with fill_CTL.pvl -> <top>.fill.gds.gz
#            (top cell <top>_FILL; poly/diff fill as placeholder arrays
#            poly_diff_{3,10,25}_FILL)
#   step 3a  placeholders -> poly_diff_{3,10,25}_FILLCELL from
#            poly_diff_3_10_25.gds.gz
#   step 3b  <top>_FILL placed at (0,0) in <top>          -> <top>.filled.gds
#   step 5   run_chip_drc.sh on <top>.filled.gds           -> <out_dir>/drc_filled
# Steps 3a/3b are done in KLayout (merge_fill.py) instead of Pegasus Design
# Review; this is the manual route the FILLGEN user guide describes.
# Steps 1 and 4 (strmout/strmin via Virtuoso) do not apply: the GDS comes
# from Innovus.
#
# --before <drc_dir>  an unfilled DRC run of the same GDS, for the
#                     density before/after table (density_report.py)
# --drop-fill L[,L]   leave out the fill on GDS layers L/99 (e.g. 67 = li1, when
#                     the layer meets its minimum density without fill and
#                     the fill would push it over its maximum)
# --no-fix            keep the fill deck's output as it is (merge_fill.py
#                     otherwise drops off-grid poly fill and cuts diff fill
#                     strips longer than 25 um; see merge_fill.py)
# Output: <out_dir>/<top>.filled.gds, fill.log, merge_fill.log, check_gds.txt,
#         drc_filled/ (see run_chip_drc.sh), density_before_after.txt
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die(){ echo "ERROR: $*" >&2; exit 2; }
GDS=""; TOP=""; OUT=""; DP=8; BEFORE=""; DODRC=1; FIX=1; DROP=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) sed -n '2,32p' "$0"; exit 0;;
    --dp) DP="${2:?}"; shift 2;;
    --before) BEFORE="${2:?}"; shift 2;;
    --no-drc) DODRC=0; shift;;
    --no-fix) FIX=0; shift;;
    --drop-fill) DROP="${2:?}"; shift 2;;
    -*) die "unknown option $1";;
    *) if [ -z "$GDS" ]; then GDS="$1"; elif [ -z "$TOP" ]; then TOP="$1"; elif [ -z "$OUT" ]; then OUT="$1"; else die "extra arg $1"; fi; shift;;
  esac
done
[ -n "$OUT" ] || { sed -n '2,32p' "$0"; exit 2; }
[ -f "$GDS" ] || die "no GDS $GDS"
GDS="$(cd "$(dirname "$GDS")" && pwd)/$(basename "$GDS")"
[ -z "$BEFORE" ] || BEFORE="$(cd "$BEFORE" && pwd)" || die "no dir $BEFORE"
SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"; SKY130="${SKY130%/}"
FG="$SKY130/Sky130_FILLGEN"
export PEGASUS_DRC="$SKY130/Sky130_DRC" PDK_HOME="$SKY130" SKY130
PEGASUS_BIN="${PEGASUS_BIN:-/opt/cadence/installs/PEGASUS232/tools/bin/pegasus}"
KLAYOUT="${KLAYOUT:-klayout}"
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}"
[ -f "$FG/fillgen.v08.pvl" ] || die "fill deck not found in $FG"

mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd)"
[ -e "$OUT/$TOP.fill.gds.gz" ] && die "$OUT already holds a fill run; use a new directory"
cd "$OUT" || die "cd $OUT"
# the user guide wants the deck and the fill cells in the run directory
cp "$FG/fillgen.v08.pvl" "$FG/GDS_flow/poly_diff_3_10_25.gds.gz" .

avail(){ free -g | awk '/^Mem:/{print $7}'; }
while [ "$(avail)" -lt 16 ]; do echo "$(date '+%F %T') waiting: $(avail) GB available"; sleep 120; done

# ---- step 2: fill generation (GDS_flow/fill_CTL.pvl with CELLNAME=$TOP) --
cat > fill_CTL.pvl <<EOF
text_depth -primary;
virtual_connect -colon no;
virtual_connect -semicolon_as_colon yes;
virtual_connect -noname;
virtual_connect -report no;
virtual_connect -depth -primary;
report_summary -drc "fill.sum" -replace;
max_results -drc -all;
keep_layers -none;
abort_on_layout_error yes;
layout_format gdsii;
layout_path "$GDS";
layout_primary $TOP;

// _FILL is appended to every cell created (including the poly-fill cell)
 results_db -drc "$TOP.fill.gds.gz" -gdsii _FILL ;

 output -drc "diff_fillgen" -gdsii 65 99 $TOP.fill.gds.gz  ;
 output -drc "poly_fillgen" -gdsii 66 99 $TOP.fill.gds.gz  ;
 output -drc "LI_fillgen"   -gdsii 67 99 $TOP.fill.gds.gz  ;
 output -drc "m1_fillgen"   -gdsii 68 99 $TOP.fill.gds.gz  ;
 output -drc "m2_fillgen"   -gdsii 69 99 $TOP.fill.gds.gz  ;
 output -drc "m3_fillgen"   -gdsii 70 99 $TOP.fill.gds.gz  ;
 output -drc "m4_fillgen"   -gdsii 71 99 $TOP.fill.gds.gz  ;
 output -drc "m5_fillgen"   -gdsii 72 99 $TOP.fill.gds.gz  ;

// placeholder cells for the poly-diff fill cells (sizes match the FILLCELLs)
 output -drc "diff_poly_fillgen_3"  -gdsii 65 99 -aref poly_diff_3   3.0 2.5 $TOP.fill.gds.gz  ;
 output -drc "diff_poly_fillgen_10" -gdsii 65 99 -aref poly_diff_10 10.0 2.5 $TOP.fill.gds.gz  ;
 output -drc "diff_poly_fillgen_25" -gdsii 65 99 -aref poly_diff_25 25.0 2.5 $TOP.fill.gds.gz  ;
EOF
echo "=== fill $TOP  ($(date '+%F %T'), $(avail) GB available)"
T0=$(date +%s)
"$PEGASUS_BIN" -drc -dp "$DP" -top_cell "$TOP" -control fill_CTL.pvl -log_dir LOGS \
    fillgen.v08.pvl > fill.log 2>&1
RC=$?
echo "    fill generation: pegasus exit $RC, $(( $(date +%s) - T0 )) s (fill.log)"
grep -q "finished normally" fill.log && [ -s "$TOP.fill.gds.gz" ] || { tail -20 fill.log; die "fill generation failed"; }

# ---- steps 3a + 3b: fill cells in, fill placed in the chip --------------
T1=$(date +%s)
"$KLAYOUT" -b -r "$SD/merge_fill.py" -rd chip="$GDS" -rd top="$TOP" \
    -rd fill="$OUT/$TOP.fill.gds.gz" -rd cells="$OUT/poly_diff_3_10_25.gds.gz" \
    -rd out="$OUT/$TOP.filled.gds" -rd fix="$FIX" -rd drop="$DROP" > merge_fill.log 2>&1 || { cat merge_fill.log; die "merge_fill.py failed"; }
cat merge_fill.log
echo "    merge: $(( $(date +%s) - T1 )) s"

"$KLAYOUT" -b -r "$SD/check_gds.py" -rd gds="$OUT/$TOP.filled.gds" -rd top="$TOP" > check_gds.txt 2>&1
CK=$?
grep -E "^(TOP|EMPTY|LAYERS|RESULT|FAIL)" check_gds.txt
[ $CK -eq 0 ] || die "filled GDS fails check_gds.py (check_gds.txt)"

# ---- step 5: DRC of the filled GDS --------------------------------------
RCD=0
if [ "$DODRC" = 1 ]; then
  "$SD/run_chip_drc.sh" "$OUT/$TOP.filled.gds" "$TOP" "$OUT/drc_filled" --dp "$DP"
  RCD=$?
  if [ -n "$BEFORE" ]; then
    python3 "$SD/density_report.py" "$BEFORE" "$OUT/drc_filled" | tee density_before_after.txt
  else
    python3 "$SD/density_report.py" "$OUT/drc_filled" | tee density_after.txt
  fi
fi
exit $RCD
