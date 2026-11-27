#!/bin/bash
# nanosoc in the ChipFoundry OpenFrame wrapper: inputs -> synthesis -> place ->
# CTS -> route -> DRC check. The chip flow's script (../../../Cadence/scripts),
# with two arguments added:  run_flow.sh [synth|pnr]
#   synth  stop after synthesis        pnr  skip inputs and synthesis
#
# Reference result (10 Nov 2026): setup WNS +0.239 ns, hold WNS +0.112 ns,
# 26,088 logic instances, check_drc clean apart from the 6 frame-pin markers
# (see ../../README.md). About 10 min of synthesis and 20 min of place and route.
#
# Every stage runs an EDA tool that needs a licence; a VPN drop shows up as an
# immediate licence failure, and the script stops rather than running the next
# stage on a stale database.

set -o pipefail
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SD/setup_env.sh" || { echo "environment setup failed"; exit 1; }

LOGS="${LOG_DIR:-$SD/../logs}"
# The stages also write ../reports and ../outputs (config.tcl), which are not in git.
mkdir -p "$LOGS" "$SD/../reports" "$SD/../outputs"
F="$SOCLABS_ASIC_FLOW_DIR/Cadence"
cd "$SD" || exit 1

fail () { echo "=== $1 FAILED - see $2 ==="; grep -E "^\*\*ERROR|^#ERROR|^Error" "$2" \
          | grep -vE "IMPLF-24|IMPMSMV-3501|IMPDB-1221" | tail -5; exit 1; }

# ---- inputs -------------------------------------------------------------
# NODE=SKY130 selects asic_lib_ip_SKY130.flist (SKY130 sl_sram + SV bootrom).
# Without it the generic list is used; without ASIC=yes you silently get an
# FPGA/testbench filelist and synthesise the wrong design with no error.
if [ "${1:-}" = pnr ]; then echo "=== skipping inputs and synthesis (arg: pnr) ==="; else
echo "=== inputs starting $(date +%H:%M:%S) ==="
make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 TOOL_CHAIN=GCC \
     BOOTROM_ADDRW=9 bootrom          > "$LOGS/00_bootrom.log" 2>&1 || fail inputs "$LOGS/00_bootrom.log"
# The OpenFrame boot ROM (../../sw/bootrom: it can load the program from the
# board's flash), built beside the flow's outputs and read by
# custom_hdl_file_list.tcl in place of the SoC Labs boot loader made above. The
# project's own system/src/bootrom is left as the other flows expect it.
{ make -C "$SD/../../sw/bootrom" OUT="$SD/../outputs/bootrom" &&
  make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 BOOTROM_ADDRW=9 \
       BOOTROM_HEX="$SD/../outputs/bootrom/of_bootrom.hex" BOOTROM_BUILD_DIR="$SD/../outputs/bootrom" bootrom
}                                     > "$LOGS/00_bootrom_openframe.log" 2>&1 || fail inputs "$LOGS/00_bootrom_openframe.log"
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
[ "${1:-}" = synth ] && { echo "=== stopping after synthesis (arg: synth) ==="; exit 0; }
fi

# ---- place and route ----------------------------------------------------
# -stylus is required: the P&R scripts use common-UI commands and native mode
# fails immediately with `invalid command name "set_multi_cpu_usage"`.
# 5_drc (route_drc.tcl): check_drc on the routed and filled design, ECO reroute of
# any violations, and the final database, openframe_project_wrapper_signoff.
for stage in "2_place:$F/2_pnr_setup.tcl" "3_cts:$F/3_pnr_clock.tcl" \
             "4_route:$F/4_pnr_route.tcl" "5_drc:$SD/route_drc.tcl"; do
    name="${stage%%:*}"; tcl="${stage#*:}"
    echo "=== $name starting $(date +%H:%M:%S) ==="
    innovus -stylus -no_gui -files "$tcl" > "$LOGS/$name.log" 2>&1 \
        || fail "$name" "$LOGS/$name.log"
    grep -q "Fail to find any .* license" "$LOGS/$name.log" && fail "$name" "$LOGS/$name.log"
    # A Tcl error stops the script (IMPSYT-6692) but Innovus still exits 0, and the next
    # stage would then read a database this one never wrote.
    grep -q "IMPSYT-6692" "$LOGS/$name.log" && fail "$name" "$LOGS/$name.log"
    echo "=== $name done $(date +%H:%M:%S) ==="
    # Each stage writes its own database in this directory: openframe_project_wrapper_place,
    # _cts, _route (routed and filled) and _signoff. Route can be re-run from _cts.
done

echo "=== FLOW COMPLETE $(date +%H:%M:%S) ==="
echo "Reports in $SD/../reports ; compare timing_summary_06_signoff.rep against"
echo "the reference above. Post-route DRC: drc_06_signoff.rpt (5_drc.log has the count)."
