#!/bin/bash
# export_results.sh -- export the results of the latest Maestro run of tb_sar_adc to CSV.
# Run on the VM, in a terminal, AFTER the Maestro run has finished:
#
#   ~/maestro_pipeline/export_results.sh                    # ExplorerRun.0, all sine tests
#   ~/maestro_pipeline/export_results.sh ExplorerRun.0 sar_adc_sine_two_tone
#   WAVEFORMS=1 ~/maestro_pipeline/export_results.sh                     # also the full vout transient (large)
#
# Writes exports/<date_time>_<tests>/ next to this script (see README.md):
#   <test>/foms.csv            every scalar output (SINAD, SFDR, ...) per design point
#   <test>/pt<N>/              samples.csv, fft.csv, vars.csv (+ vout.csv with WAVEFORMS=1)
#   <run>.rdb                  copy of the results database (maestro_sweep.py reads it)
# The folder is named <date_time>_<tests>, e.g. 2026-11-16_1239_fft+two_tone.
#
# Only reads the results: nothing in Maestro is changed. ADE Explorer overwrites
# ExplorerRun.0 on every run, so export after each run you want to keep.
#
# ---- Settings: another user / testbench, set these or edit the defaults ----
#   SIMROOT  where Maestro writes the simulation results of the testbench:
#            <simulation dir>/<lib>/<cell>/maestro/results/maestro
#            (holds ExplorerRun.0/1/<test>/psf/)
#   RDBROOT  the maestro view's own results folder:
#            <library path>/<cell>/maestro/results/maestro  (holds ExplorerRun.0.rdb)
# =====================================================================
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="${1:-ExplorerRun.0}"; shift || true
TESTS=("$@")
# Names go into file paths and into OCEAN code: allow only plain names
for n in "$RUN" ${TESTS[@]+"${TESTS[@]}"}; do      # (old bash: empty array + set -u)
  [[ "$n" =~ ^[A-Za-z0-9_.]+$ && "$n" != *..* ]] || { echo "bad run/test name: '$n'"; exit 2; }
done
SIGNALS="${SIGNALS:-\"/vout\"}"
[ "${WAVEFORMS:-0}" = 1 ] && WAVES=t || WAVES=nil

SIMROOT="${SIMROOT:-$HOME/simulation/sar_adc/tb_sar_adc/maestro/results/maestro}"
RDBROOT="${RDBROOT:-$HOME/agriculture-SoC-hee-v2/analog/cadence/sar_adc/tb_sar_adc/maestro/results/maestro}"
OUT="$HERE/exports/$(date +%Y-%m-%d_%H%M)"

[ -d "$SIMROOT/$RUN" ] || { echo "no results at $SIMROOT/$RUN"; exit 2; }
command -v ocean >/dev/null || { echo "ocean not on PATH (source your .bashrc)"; exit 2; }
command -v python3 >/dev/null || { echo "python3 not on PATH"; exit 2; }
mkdir -p "$OUT"

if [ ${#TESTS[@]} -gt 0 ]; then
  TLIST="'($(printf '"%s" ' "${TESTS[@]}"))"
else
  TLIST=nil
fi

# 1. scalar figures of merit from the results database
if [ -f "$RDBROOT/$RUN.rdb" ]; then
  cp "$RDBROOT/$RUN.rdb" "$OUT/$RUN.rdb"
  python3 "$HERE/foms.py" "$OUT/$RUN.rdb" "$OUT"
else
  echo "warning: no $RDBROOT/$RUN.rdb, skipping foms.csv"
fi

# 2. waveforms, samples, FFT and variables from the PSF results
ocean -nograph > "$OUT/ocean.log" 2>&1 <<EOF
load("$HERE/export_sine.ocn")
mxExport("$SIMROOT/$RUN" "$OUT" ?signals '($SIGNALS) ?tests $TLIST ?waveforms $WAVES)
exit()
EOF
# short record of the export without Cadence's banner (ocean.log itself stays out of git)
grep -E "^(exported|mxExport|  samples)|\*Error\*" "$OUT/ocean.log" | sed "s#$HOME#~#g" \
  | tee "$OUT/export.txt" || true

# 3. name the folder after the tests that had results: ..._sine_fft+two_tone
NAMES=$(for d in "$OUT"/*/; do [ -n "$(ls -d "$d"pt* 2>/dev/null)" ] && basename "$d"; done \
        | sed 's/^sar_adc_sine_//' | paste -sd+ -)
if [ -n "$NAMES" ]; then
  NEW="${OUT}_$NAMES"
  [ -e "$NEW" ] && NEW="${OUT}$(date +%S)_$NAMES"      # two exports in the same minute
  mv "$OUT" "$NEW"
  OUT="$NEW"
fi
echo "done: $OUT"
