#!/bin/bash
# fetch_exports.sh -- step 3, run on your computer: MOVE new exports from the Cadence
# machine (<VM_DIR>/exports/) into data/exports/ next to this script. Each file is
# deleted on the Cadence machine once it has been copied, so the data lives in one place.
# Machine settings: vm_settings.sh.
#   ./fetch_exports.sh            # move everything
#   ./fetch_exports.sh -n         # dry run: list what would be moved, change nothing
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/vm_settings.sh"
DEST="$HERE/data/exports/"
mkdir -p "$DEST"
rsync -av --remove-source-files "$@" -e "ssh ${SSH_ARGS[*]}" "$VM_HOST:$VM_DIR/exports/" "$DEST"

# rsync leaves the emptied folders behind on the Cadence machine: remove them
case " $* " in
  *" -n "*|*" --dry-run "*) ;;
  *) ssh "${SSH_ARGS[@]}" "$VM_HOST" "find ~/$VM_DIR/exports -mindepth 1 -type d -empty -delete" ;;
esac
