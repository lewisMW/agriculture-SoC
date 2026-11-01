#!/bin/bash
# Full sky130 NanoSoC flow: inputs -> synthesis -> place -> CTS -> route.
# Run from anywhere:  ./ASIC_ours/Cadence/scripts/run_flow.sh
#
# Reference result on the Cadence machine (3 Sep 2026, "run G"):
#   setup WNS +0.169 ns, TNS 0.000, 0 failing endpoints, hold MET (+0.109 ns)
#   23,098 instances, 3,467,594 um2, 122 DRC violations
# Roughly 65 minutes end to end.
#
# Every stage runs an EDA tool that needs a licence; a VPN drop shows up as an
# immediate licence failure, and the script stops rather than running the next
# stage on a stale database.

set -o pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SD/setup_env.sh" || { echo "environment setup failed"; exit 1; }

LOGS="${LOG_DIR:-$SD/../logs}"
mkdir -p "$LOGS"
F="$SOCLABS_ASIC_FLOW_DIR/Cadence"
cd "$SD" || exit 1

fail () { echo "=== $1 FAILED - see $2 ==="; grep -E "^\*\*ERROR|^#ERROR|^Error" "$2" \
          | grep -vE "IMPLF-24|IMPMSMV-3501|IMPDB-1221" | tail -5; exit 1; }

# ---- inputs -------------------------------------------------------------
# NODE=SKY130 selects asic_lib_ip_SKY130.flist (SKY130 sl_sram + SV bootrom).
# Without it the generic list is used; without ASIC=yes you silently get an
# FPGA/testbench filelist and synthesise the wrong design with no error.
echo "=== inputs starting $(date +%H:%M:%S) ==="
make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 TOOL_CHAIN=GCC \
     BOOTROM_ADDRW=9 bootrom          > "$LOGS/00_bootrom.log" 2>&1 || fail inputs "$LOGS/00_bootrom.log"
make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 \
     flist_genus_nanosoc              > "$LOGS/00_flist.log"   2>&1 || fail inputs "$LOGS/00_flist.log"
echo "=== inputs done $(date +%H:%M:%S) ==="

# ---- synthesis ----------------------------------------------------------
# 1_synthesis.tcl aborts if any reference is unresolved: Genus black-boxes
# undefined modules at zero area, so a bad read_hdl path otherwise yields a
# netlist missing whole blocks while still reporting success.
echo "=== 1_synth starting $(date +%H:%M:%S) ==="
genus -f "$F/1_synthesis.tcl" > "$LOGS/01_synth.log" 2>&1
grep -q "Normal exit" "$LOGS/01_synth.log" || fail 1_synth "$LOGS/01_synth.log"
echo "=== 1_synth done $(date +%H:%M:%S) ==="

# ---- place and route ----------------------------------------------------
# -stylus is required: the P&R scripts use common-UI commands and native mode
# fails immediately with `invalid command name "set_multi_cpu_usage"`.
for stage in "2_place:2_pnr_setup" "3_cts:3_pnr_clock" "4_route:4_pnr_route"; do
    name="${stage%%:*}"; tcl="${stage##*:}"
    echo "=== $name starting $(date +%H:%M:%S) ==="
    innovus -stylus -no_gui -files "$F/$tcl.tcl" > "$LOGS/$name.log" 2>&1 \
        || fail "$name" "$LOGS/$name.log"
    grep -q "Fail to find any .* license" "$LOGS/$name.log" && fail "$name" "$LOGS/$name.log"
    echo "=== $name done $(date +%H:%M:%S) ==="
    # Each stage ends `write_db $block_name`, overwriting the previous one.
    # Snapshot CTS so route can be re-run without redoing placement.
    [ "$name" = "3_cts" ] && { rm -rf nanosoc_chip_pads_ctsdb; \
        cp -a nanosoc_chip_pads nanosoc_chip_pads_ctsdb && echo "CTS database snapshotted"; }
done

echo "=== FLOW COMPLETE $(date +%H:%M:%S) ==="
echo "Reports in $SD/../reports ; compare timing_summary_05_route_opt.rep against"
echo "the reference above. check_drc must be run separately for the DRC count."
