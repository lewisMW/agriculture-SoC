#!/usr/bin/env bash
# =====================================================================
# run_precheck_native.sh -- the checks of ChipFoundry's precheck that need
# only KLayout and Magic, run without Docker, with cf-precheck's own decks
# and the same command lines (cf-precheck src/cf_precheck/checks/*.py).
#
# Usage: ./run_precheck_native.sh <openframe_project_wrapper.gds> <out_dir> [check ...]
#   checks (default: all): topcell_check illegal_cellname_check xor
#     klayout_feol klayout_beol klayout_offgrid klayout_met_min_ca_density
#     klayout_pin_label_purposes_overlapping_drawing klayout_zeroarea spike_check
# Env:
#   CF_PRECHECK  a checkout of github.com/chipfoundry/cf-precheck   (required)
#   GOLDEN       openframe_project_wrapper_empty.gds, unzipped from the gds/
#                directory of chipfoundry/caravel-lite              (required for xor)
#   PDK_ROOT     default /opt/pdk      PDK  default sky130A
#   THREADS      default 8             JOBS checks run at once, default 1
#
# Memory and time on the 230 MB wrapper GDS (KLayout 0.30.9, 8 threads): klayout_beol
# 9 GB and 51 min, klayout_offgrid 7 GB and 9 min, klayout_feol 24 min, xor 12 min
# (Magic), the rest under 4 min each. On a shared machine keep JOBS=1.
#
# Not covered (they need netgen and CVC, which the precheck image has): lvs, oeb.
# This is a rehearsal; the result that counts is `cf precheck` itself.
# Output: <out_dir>/logs/<check>.log, <out_dir>/outputs/reports/<check>_check.xml,
#         <out_dir>/summary.txt (one line per check). Exit 0 only if all pass.
# =====================================================================
set -uo pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 2 ] || { sed -n '2,20p' "$0"; exit 2; }
GDS="$(readlink -f "$1")"; OUT="$2"; shift 2
[ -f "$GDS" ] || { echo "no such GDS: $GDS"; exit 2; }
: "${CF_PRECHECK:?set CF_PRECHECK to a cf-precheck checkout}"
DRC="$CF_PRECHECK/src/cf_precheck/drc_scripts"
[ -d "$DRC" ] || { echo "no drc_scripts under $CF_PRECHECK"; exit 2; }
export PDK_ROOT="${PDK_ROOT:-/opt/pdk}" PDK="${PDK:-sky130A}" MAGTYPE=mag
THREADS="${THREADS:-8}"; JOBS="${JOBS:-1}"
TOP="$(basename "$GDS" .gds)"
ALL="topcell_check illegal_cellname_check xor klayout_feol klayout_beol klayout_offgrid
     klayout_met_min_ca_density klayout_pin_label_purposes_overlapping_drawing klayout_zeroarea spike_check"
CHECKS="${*:-$ALL}"
mkdir -p "$OUT/logs" "$OUT/outputs/reports"; OUT="$(cd "$OUT" && pwd)"
L="$OUT/logs"; R="$OUT/outputs/reports"

# klayout DRC deck: pass when the report has no <item>
kl_drc () {  # <check> <deck> [extra klayout args]
    local c="$1" deck="$2"; shift 2
    klayout -b -r "$deck" -rd input="$GDS" -rd topcell="$TOP" -rd report="$R/${c}_check.xml" \
            -rd thr="$THREADS" "$@" > "$L/$c.log" 2>&1 || { echo "FAIL klayout exit $?"; return; }
    [ -s "$R/${c}_check.xml" ] || { echo "FAIL no report"; return; }
    local n; n=$(grep -c "<item>" "$R/${c}_check.xml")
    if [ "$n" = 0 ]; then echo "PASS 0 violations"; else echo "FAIL $n violations ($R/${c}_check.xml)"; fi
}

run_check () {
    local c="$1"
    case "$c" in
    topcell_check|illegal_cellname_check)
        klayout -b -r "$SD/precheck_names.py" -rd gds="$GDS" -rd check="$c" > "$L/$c.log" 2>&1
        if [ $? = 0 ]; then echo "PASS $(tail -1 "$L/$c.log")"; else echo "FAIL $(tail -1 "$L/$c.log")"; fi ;;
    xor)
        : "${GOLDEN:?set GOLDEN to openframe_project_wrapper_empty.gds}"
        local rc="$PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc" e="$DRC/erase_box_openframe.tcl"
        { magic -dnull -noconsole -rcfile "$rc" "$e" "$GDS"    "$OUT/outputs/${TOP}_erased.gds"       "$TOP" < /dev/null
          magic -dnull -noconsole -rcfile "$rc" "$e" "$GOLDEN" "$OUT/outputs/${TOP}_empty_erased.gds" "$TOP" < /dev/null
          klayout -b -r "$DRC/xor.rb.drc" -rd ext=gds -rd top_cell=xor_target -rd thr="$THREADS" \
              -rd a="$OUT/outputs/${TOP}_erased.gds" -rd b="$OUT/outputs/${TOP}_empty_erased.gds" \
              -rd o="$OUT/outputs/$TOP.xor.gds" -rd ol="$OUT/outputs/$TOP.xor.gds" \
              -rd xor_total_file_path="$L/xor_check.total"
        } > "$L/$c.log" 2>&1
        local n; n=$(cat "$L/xor_check.total" 2>/dev/null || echo "no-total")
        if [ "$n" = 0 ]; then echo "PASS 0 differences"; else echo "FAIL $n differences"; fi ;;
    klayout_feol)    kl_drc "$c" "$DRC/${PDK}_mr.drc" -rd feol=true ;;
    klayout_beol)    kl_drc "$c" "$DRC/${PDK}_mr.drc" -rd beol=true ;;
    klayout_offgrid) kl_drc "$c" "$DRC/${PDK}_mr.drc" -rd offgrid=true ;;
    klayout_met_min_ca_density) kl_drc "$c" "$DRC/met_min_ca_density.lydrc"
        grep -h "ca_density is" "$L/$c.log" | sed 's/^/        /' ;;
    klayout_pin_label_purposes_overlapping_drawing)
        kl_drc "$c" "$DRC/pin_label_purposes_overlapping_drawing.rb.drc" -rd top_cell_name="$TOP" ;;
    klayout_zeroarea)
        kl_drc "$c" "$DRC/zeroarea.rb.drc" -rd cleaned_output="$OUT/outputs/${TOP}_no_zero_areas.gds" ;;
    spike_check)
        bash "$DRC/gdsArea0" -V -m "$R/spike_check.xml" "$GDS" > "$L/$c.log" 2>&1
        local rc=$?; if [ $rc = 0 ]; then echo "PASS no spikes"; else echo "FAIL gdsArea0 exit $rc"; fi ;;
    *) echo "FAIL unknown check" ;;
    esac
}

echo "=== native precheck of $GDS -> $OUT ($(date '+%F %T')), cf-precheck $(git -C "$CF_PRECHECK" log -1 --format=%h 2>/dev/null)"
: > "$OUT/summary.txt"
for c in $CHECKS; do
    # (bash 4.2 has no "wait -n": poll)
    while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do sleep 2; done
    ( t0=$(date +%s); res="$(run_check "$c")"
      printf '%-50s %s  [%d s]\n' "$c" "$res" $(( $(date +%s) - t0 )) | tee -a "$OUT/summary.txt" ) &
done
wait
echo "=== done $(date '+%T')"
! grep -q " FAIL " "$OUT/summary.txt"
