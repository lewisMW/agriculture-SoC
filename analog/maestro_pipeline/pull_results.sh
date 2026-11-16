#!/bin/bash
# pull_results.sh -- steps 2 and 3 in one, run on your computer: export the latest Maestro
# run on the Cadence machine (export_results.sh there, over ssh), then copy it here
# (fetch_exports.sh). Run it after the Maestro run has finished.
#   ./pull_results.sh                                   # all tests of ExplorerRun.0
#   ./pull_results.sh ExplorerRun.0 sar_adc_sine_two_tone   # same arguments as export_results.sh
# The last line printed is the local export folder:  export folder: <path>
# maestro_sweep.py --pull runs this and then plots that folder.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/vm_settings.sh"

echo "== exporting on $VM_HOST"
# bash -i loads the Cadence setup in .bashrc (ocean on PATH); drop its harmless job-control warnings
# quote each argument for the remote shell, so a name can't run extra commands there
ARGS=""
[ $# -gt 0 ] && ARGS=$(printf ' %q' "$@")
LOG=$(ssh "${SSH_ARGS[@]}" "$VM_HOST" "bash -ic $(printf %q "~/$VM_DIR/export_results.sh$ARGS")" 2>&1 \
      | grep -vE "^bash: (cannot set terminal process group|no job control)" || true)
echo "$LOG"
REMOTE=$(echo "$LOG" | sed -n 's/^done: //p' | tail -1)
[ -n "$REMOTE" ] || { echo "export failed (no 'done:' line)"; exit 1; }

echo "== copying to this computer"
"$HERE/fetch_exports.sh" | tail -2
echo "export folder: $HERE/data/exports/$(basename "$REMOTE")"
