"""
vm_pull.py -- the VM part of `maestro_sweep.py --pull`: runs pull_results.sh (export the
latest Maestro run on the Cadence machine, copy it here) and returns the new export folder.

Kept apart from maestro_sweep.py so that the plotting script has nothing to do with the
Cadence machine. Which machine to reach is set in vm_settings.local.sh (not in git);
see vm_settings.sh.
"""
import subprocess
from pathlib import Path


def pull(export_args):
    """Run pull_results.sh with export_args (as for export_results.sh); return the local folder."""
    script = Path(__file__).resolve().parent / "pull_results.sh"
    proc = subprocess.run([str(script), *export_args], capture_output=True, text=True)
    print(proc.stdout, end="")
    print(proc.stderr, end="")
    folder = [l.split(": ", 1)[1] for l in proc.stdout.splitlines() if l.startswith("export folder: ")]
    if proc.returncode or not folder:
        raise SystemExit("pull_results.sh failed, nothing plotted")
    return folder[-1]
