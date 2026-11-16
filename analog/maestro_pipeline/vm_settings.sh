# vm_settings.sh -- where the Cadence machine is. Read by fetch_exports.sh and pull_results.sh.
# Put your own values in vm_settings.local.sh next to this file (not committed to git),
# or set the variables before running:
#   VM_HOST   user@host of the Cadence machine
#   VM_KEY    ssh private key for it (empty = your normal ssh key)
#   VM_DIR    folder of export_results.sh on that machine, relative to its home
HERE_SETTINGS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$HERE_SETTINGS/vm_settings.local.sh" ] && source "$HERE_SETTINGS/vm_settings.local.sh"
VM_HOST="${VM_HOST:-user@cadence-host}"
VM_KEY="${VM_KEY-}"
VM_DIR="${VM_DIR:-maestro_pipeline}"
[ "$VM_HOST" = "user@cadence-host" ] && { echo "set VM_HOST in vm_settings.local.sh (see vm_settings.sh)" >&2; exit 2; }
# fetch_exports.sh deletes files under ~/$VM_DIR/exports on the Cadence machine:
# VM_DIR must be a plain folder below home
[[ -n "$VM_DIR" && "$VM_DIR" != /* && "$VM_DIR" != *..* && "$VM_DIR" =~ ^[A-Za-z0-9_./-]+$ ]] \
  || { echo "VM_DIR must be a folder below your home on the Cadence machine, got '$VM_DIR'" >&2; exit 2; }
SSH_ARGS=()
[ -n "$VM_KEY" ] && SSH_ARGS=(-i "$VM_KEY")
