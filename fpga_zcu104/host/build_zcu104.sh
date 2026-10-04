#!/usr/bin/env bash
# Build the NanoSoC + sensing-peripheral bitstream for the ZCU104.
#
# Thin wrapper around the soclabs flow (`make build_fpga FPGA=zcu104`) that
# checks the environment first, because every one of these missing pieces
# otherwise fails many minutes into the build with an unhelpful error.
#
# Usage:  ./build_zcu104.sh            (from anywhere; finds the repo itself)
#         VIVIADO_VERSION=2021_1 ./build_zcu104.sh    (older Vivado)
#
# See fpga_zcu104/BUILD_GUIDE.md for the full story.

set -u

# Repo root = two levels up from this script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NANOSOC="$REPO_ROOT/nanosoc"

fail=0
note() { echo "  [x] $1"; fail=1; }
ok()   { echo "  [+] $1"; }

echo "== Preflight checks =="

# 1. Vivado on PATH
if command -v vivado >/dev/null 2>&1; then
    ok "vivado: $(command -v vivado)"
else
    note "vivado not on PATH. Run: source /tools/Xilinx/Vivado/<ver>/settings64.sh"
fi

# 2. arm-none-eabi-gcc (bootrom is compiled and baked into the bitstream)
if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    ok "arm-none-eabi-gcc: $(command -v arm-none-eabi-gcc)"
else
    note "arm-none-eabi-gcc not on PATH (needed for the bootrom). apt: gcc-arm-none-eabi"
fi

# 3. dependency_env.sh exists and ARM_IP_LIBRARY_PATH is real
DEP_ENV="$NANOSOC/env/dependency_env.sh"
if [ -f "$DEP_ENV" ]; then
    # shellcheck disable=SC1090
    source "$DEP_ENV" 2>/dev/null
    if [ -n "${ARM_IP_LIBRARY_PATH:-}" ] && [ -d "$ARM_IP_LIBRARY_PATH" ]; then
        ok "ARM_IP_LIBRARY_PATH: $ARM_IP_LIBRARY_PATH"
    else
        note "ARM_IP_LIBRARY_PATH ('${ARM_IP_LIBRARY_PATH:-unset}') is not a directory."
        note "Edit $DEP_ENV — it is gitignored and per-machine (it may still hold another machine's path)."
    fi
else
    note "$DEP_ENV missing — create it (gitignored), it must export ARM_IP_LIBRARY_PATH."
fi

if [ "$fail" -ne 0 ]; then
    echo "Preflight failed — fix the [x] items above and re-run."
    exit 1
fi

echo "== Sourcing soclabs environment (twice — first pass may only bootstrap) =="
cd "$NANOSOC" || exit 1
source set_env.sh
source set_env.sh

if [ -z "${SOCLABS_NANOSOC_TECH_DIR:-}" ]; then
    echo "ERROR: SOCLABS_NANOSOC_TECH_DIR still unset after set_env.sh — see DEBUGGING.md §1."
    exit 1
fi

echo "== Building bitstream (this runs Vivado synth+impl; expect 30-90 min) =="
# ACCELERATOR=yes    -> include the sensing peripheral (ACCELERATOR_SUBSYSTEM define)
# TOOL_CHAIN=gcc     -> bootrom with arm-none-eabi-gcc (flow default is Arm DS-5)
# VIVIADO_VERSION    -> picks fpga/targets/pynq_zcu104/vivado_script/<ver>/ (the
#                       misspelling is the flow's real variable name).
#                       2021_1 and 2024_1 scripts are byte-identical; default to 2024_1.
make -C "$SOCLABS_NANOSOC_TECH_DIR" build_fpga \
    FPGA=zcu104 ACCELERATOR=yes TOOL_CHAIN=gcc \
    VIVIADO_VERSION="${VIVIADO_VERSION:-2024_1}"
rc=$?

OUT="$REPO_ROOT/nanosoc/imp/fpga/output/pynq_zcu104/overlays"
if [ $rc -eq 0 ] && [ -f "$OUT/nanosoc_design.bit" ]; then
    echo "== SUCCESS =="
    ls -l "$OUT/nanosoc_design.bit" "$OUT/nanosoc_design.hwh"
    echo "Next: copy both files to the board (BOARD_BRINGUP.md §3)."
else
    echo "== BUILD FAILED (rc=$rc) — check the last vivado.log:"
    echo "   $REPO_ROOT/nanosoc/imp/fpga/run/vivado.log"
    echo "   and DEBUGGING.md §1/§2."
    exit 1
fi
