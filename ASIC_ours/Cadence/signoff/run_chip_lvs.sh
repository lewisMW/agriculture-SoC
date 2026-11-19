#!/usr/bin/env bash
# =====================================================================
# run_chip_lvs.sh -- chip-level LVS (Pegasus 23.2, sky130): the merged chip
# GDS against the Innovus Verilog netlist, with the libraries' transistor
# netlists as leaf cells.
#
# Usage:
#   run_chip_lvs.sh <gds> <verilog> <top> <outdir> [options]
#
#   <gds>      merged chip GDS (write_stream -merge ...)
#   <verilog>  Innovus write_netlist output WITH PG connections; best the
#              variant with physical instances (-include_pg -include_phys_insts),
#              so decaps/fills/taps are in the source too
#   <top>      top module / cell (nanosoc_chip_pads)
#   <outdir>   new or empty run directory (never reused: results are kept)
#
# Options:
#   --blackbox CELL     compare CELL by its pins only (repeatable)
#   --bb-default        black-box the first-pass set: sar_afe*, the OpenRAM
#                       SRAM and every IO pad cell in the netlist, minus the
#                       kinds given to --full. This is the default when no
#                       --blackbox/--no-bb/--full is given.
#   --no-bb             no default black boxes (use with --full)
#   --full KIND         compare KIND at transistor level instead of stubbing
#                       it: sram (OpenRAM .lvs.sp), io (sky130_fd_io/ef_io
#                       netlists), sar_afe (the macro's CDL). Repeatable.
#   --soft-bb           black boxes as plain "lvs_black_box": contents are
#                       extracted (devices, wells, taps) and only ignored in
#                       the comparison. Default is "lvs_black_box -black":
#                       contents not extracted, a port is a pin shape under
#                       pin text (at any depth in the cell). See README.
#   --no-pad-ring       use the Verilog as is. By default IO-cell ring pins
#                       (VCCD VSSD VDDIO ... ) that the netlist leaves open are
#                       connected to the net the netlist uses for that ring
#                       elsewhere (src/netlist.v; see chip_lvs_src.py), since
#                       the abutted IO cells make each ring one net
#   --no-tie-bulk       use the Verilog's VPB/VNB as they are. By default a
#                       std-cell VPB/VNB the netlist leaves open (cells Innovus
#                       added after connect_global_net) goes on that cell's own
#                       VPWR/VGND net, as power_plan.tcl intends
#   --pg-labels-def DEF name the top-level supply nets with one add_text each on
#                       a DEF core-ring wire (def_pg_labels.py), replacing the
#                       GDS's own supply texts, so lvs_find_shorts can trace a
#                       supply short on the core grid. A supply without a DEF
#                       special wire (and every supply, without this option)
#                       keeps only its first GDS text (gds_top_texts.py)
#   --no-bulk-pins      diagnostic: leave std-cell VPB/VNB out of the comparison
#                       (shows the wiring apart from well/substrate ties)
#   --ignore-top-ports  lvs_ignore_ports yes: don't compare the top cell's
#                       ports (use when the GDS has no top-level port text)
#   --layout-top CELL   layout top cell, if not <top>
#   --dp N              Pegasus threads (default 8)
#   --mem-gb N          expected peak memory of the run (default 10); the run
#                       waits (up to 30 min) until N + 8 GB are available
#   --deck-extra FILE   append FILE to the deck (site-specific rules)
#
# Output in <outdir>: deck.pvl, src/ (source CDL set, verilog_scan.txt),
# <top>.lvsrpt.cls (comparison report), <top>.lvsrpt (extraction report),
# <layout-top>.spi (extracted layout netlist), pegasus.log, digest.txt.
# Prints "Run Result : MATCH|MISMATCH" and a digest; exit 0 only on MATCH.
#
# Env: SKY130 (Cadence sky130 port, for lvs_deck.sh), PEGASUS_BIN,
#      PDK_ROOT_SKY130A, SRAM_DIR, SAR_AFE_DIR (library locations, see
#      chip_lvs_src.py). The licence comes from the caller's environment.
# =====================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DECK_SH="$REPO_ROOT/analog/cadence/pv/lvs_deck.sh"

# Pegasus 23.2: 24.1 attaches pin labels to two co-located nets on this deck
# and reports false opens (analog/cadence/pv/README.md).
if [ -z "${PEGASUS_BIN:-}" ]; then
  PEGASUS_BIN=/opt/cadence/installs/PEGASUS232/tools/bin/pegasus
  [ -x "$PEGASUS_BIN" ] || PEGASUS_BIN=$(command -v pegasus || true)
fi

die(){ echo "ERROR: $*" >&2; exit 2; }
usage(){ awk 'NR>2 && /^# =====/{exit} NR>2' "$0"; exit "${1:-0}"; }

POS=(); BB=(); FULL=(); DP=8; MEMGB=10; HARD=1; IGNPORTS=0; LTOP=""
BBDEF=auto; EXTRA=""; PADRING=1; TIEBULK=1; PGDEF=""
NOBULK=0
PGNETS="VDD VSS VDDIO VSSIO VDDIO_Q VSSIO_Q VDDA VSSA VCCD VSSD VSWITCH VCCHIB"
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    --blackbox) BB+=("${2:?}"); shift 2;;
    --bb-default) BBDEF=yes; shift;;
    --no-bb) BBDEF=no; shift;;
    --full) FULL+=("${2:?}"); shift 2;;
    --hard-bb) HARD=1; shift;;
    --soft-bb) HARD=0; shift;;
    --no-pad-ring) PADRING=0; shift;;
    --no-tie-bulk) TIEBULK=0; shift;;
    --no-bulk-pins) NOBULK=1; shift;;
    --pg-labels-def) PGDEF="${2:?}"; shift 2;;
    --ignore-top-ports) IGNPORTS=1; shift;;
    --layout-top) LTOP="${2:?}"; shift 2;;
    --dp) DP="${2:?}"; shift 2;;
    --mem-gb) MEMGB="${2:?}"; shift 2;;
    --deck-extra) EXTRA="${2:?}"; shift 2;;
    -*) die "unknown option: $1";;
    *) POS+=("$1"); shift;;
  esac
done
[ ${#POS[@]} -eq 4 ] || usage 2
GDS=$(readlink -f "${POS[0]}"); VLOG=$(readlink -f "${POS[1]}"); TOP="${POS[2]}"; OUT="${POS[3]}"
LTOP="${LTOP:-$TOP}"
[ -f "$GDS" ] || die "GDS not found: ${POS[0]}"
[ -f "$VLOG" ] || die "Verilog not found: ${POS[1]}"
[ -x "$PEGASUS_BIN" ] || die "pegasus not found (set PEGASUS_BIN)"
[ -x "$DECK_SH" ] || die "deck generator not found: $DECK_SH"
[ -z "$EXTRA" ] || [ -f "$EXTRA" ] || die "--deck-extra file not found: $EXTRA"
[ -z "$PGDEF" ] || [ -f "$PGDEF" ] || die "--pg-labels-def file not found: $PGDEF"
[ -z "$PGDEF" ] || PGDEF=$(readlink -f "$PGDEF")
if [ -e "$OUT" ] && [ -n "$(ls -A "$OUT" 2>/dev/null)" ]; then
  die "output dir exists and is not empty: $OUT (pick a new name; runs are never overwritten)"
fi
mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)
export LC_ALL="${LC_ALL:-en_US.utf8}" LANG="${LANG:-en_US.utf8}"

# ---- 1. source side: library CDL set + Verilog scan
echo "=== chip LVS: $(basename "$GDS") vs $(basename "$VLOG")  (top $TOP)"
echo "    run: $OUT"
SRCARGS=(--out "$OUT/src" --verilog "$VLOG" --top "$TOP")
for f in "${FULL[@]+"${FULL[@]}"}"; do SRCARGS+=(--full "$f"); done
[ "$PADRING" = 1 ] && SRCARGS+=(--pad-ring)
[ "$TIEBULK" = 1 ] && SRCARGS+=(--tie-bulk)
# default first-pass black boxes: decided from the netlist's own masters
if [ "$BBDEF" = yes ] || { [ "$BBDEF" = auto ] && [ ${#BB[@]} -eq 0 ] && [ ${#FULL[@]} -eq 0 ]; }; then
  python3 "$SCRIPT_DIR/chip_lvs_src.py" --out "$OUT/src" --verilog "$VLOG" --top "$TOP" --scan-only > /dev/null
  while read -r c; do
    # a kind compared at transistor level (--full) is not black-boxed
    case "$c" in
      sar_afe*) [[ " ${FULL[*]-} " == *" sar_afe "* ]] && continue;;
      sky130_sram_*) [[ " ${FULL[*]-} " == *" sram "* ]] && continue;;
      sky130_ef_io__*|sky130_fd_io__*) [[ " ${FULL[*]-} " == *" io "* ]] && continue;;
    esac
    BB+=("$c")
  done < <(
    sed -n 's/^ *[0-9]\+  \(sky130_ef_io__[A-Za-z0-9_]*\|sky130_fd_io__[A-Za-z0-9_]*\|sky130_sram_[A-Za-z0-9_]*\|sar_afe[A-Za-z0-9_]*\)$/\1/p' \
      "$OUT/src/verilog_scan.txt" | sort -u)
fi
for b in "${BB[@]+"${BB[@]}"}"; do SRCARGS+=(--blackbox "$b"); done
echo ">>> [1/3] source netlist set (chip_lvs_src.py)"
python3 "$SCRIPT_DIR/chip_lvs_src.py" "${SRCARGS[@]}" | sed 's/^/    /'
[ -s "$OUT/src/source.cdl" ] || die "no source.cdl written"

# ---- 2. deck: PDK deck + our fixes (lvs_deck.sh) + chip options
echo ">>> [2/3] deck"
"$DECK_SH" > "$OUT/deck.pvl"
BBOPT="-source_layout"; [ "$HARD" = 1 ] && BBOPT="-black -source_layout"
{
  echo ""
  echo "// ===== chip LVS options (ASIC_ours/Cadence/signoff/run_chip_lvs.sh) ====="
  echo "// Source: the Innovus Verilog read natively, leaf cells from CDL."
  echo "// Verilog constants 1'b0/1'b1 become the core supplies."
  echo "schematic_path \"$OUT/src/netlist.v\" verilog -supply0 VSS -supply1 VDD"
  echo "schematic_path \"$OUT/src/source.cdl\" cdl"
  echo "schematic_primary $TOP"
  echo "lvs_power_name VDD VDDIO VDDIO_Q VDDA VSWITCH VCCHIB VCCD vccd1 tie1"
  echo "lvs_ground_name VSS VSSIO VSSIO_Q VSSA VSSD vssd1 tie0"
  echo "// sky130_fd_sc_hd__conb_1 ties HI/LO through poly 'resistors' that the deck"
  echo "// does not extract (no res_generic_po device), so in the layout HI is VPWR"
  echo "// and LO is VGND. Short the two resistors in the source to match."
  echo "lvs_filter_device R(res_generic_po) -short -source"
  echo "// Physical-only cells without devices (fill_*, tapvpwrvgnd_1, IO filler"
  echo "// slices) extract to nothing in the layout: drop their empty source"
  echo "// subcircuits too (black-box stubs are kept)."
  echo "lvs_spice yes -cull_primitive_subcircuits"
  echo "// shorts between differently labelled nets: path written to <top>.lvsrpt.shorts"
  echo "lvs_find_shorts yes -cell all"
  echo "lvs_report_max 1000 -mismatched_net_limit 1000"
  echo "lvs_warn_max 200"
  [ "$IGNPORTS" = 1 ] && echo "lvs_ignore_ports yes"
  for b in "${BB[@]+"${BB[@]}"}"; do echo "lvs_black_box $b $BBOPT"; done
  if [ "$HARD" = 1 ] && [ ${#BB[@]} -gt 0 ]; then
    echo "// hard black boxes: ports from pin shapes at any depth under the cell's"
    echo "// own pin text (sky130_fd_io__top_xres4v2 has its met4 pins in subcells)"
    echo "lvs_black_box_port_depth -all"
  fi
  # pins of black-boxed IO cells that are not compared (see README):
  cat "$OUT/src/deck_pins.pvl"
  [ "$NOBULK" = 1 ] && cat "$OUT/src/deck_nobulk.pvl"
  # supply-net texts: at most one per net in the layout (gds_top_texts.py),
  # and from the DEF special wires for supplies the GDS does not name
  PGPORTS=$(for n in $PGNETS; do grep -qx "$n" "$OUT/src/top_ports.txt" && echo "$n"; done | tr '\n' ' ' || true)
  # With --pg-labels-def: supplies with a DEF special wire are named there (one
  # text on the core grid) and lose their GDS texts; the rest keep one GDS text.
  DEFNETS=""
  if [ -n "$PGDEF" ] && [ -n "$PGPORTS" ]; then
    python3 "$SCRIPT_DIR/def_pg_labels.py" "$PGDEF" $PGPORTS > "$OUT/pg_labels.pvl"
    DEFNETS=$(awk '/^add_text/{print $2}' "$OUT/pg_labels.pvl" | tr '\n' ' ')
  fi
  KEEPNETS=$(for n in $PGPORTS; do case " $DEFNETS " in *" $n "*) ;; *) echo "$n";; esac; done | tr '\n' ' ' || true)
  : > "$OUT/pg_texts.pvl"
  [ -n "${DEFNETS// /}" ] && python3 "$SCRIPT_DIR/gds_top_texts.py" --none-per-net "$GDS" "$LTOP" $DEFNETS >> "$OUT/pg_texts.pvl"
  [ -n "${KEEPNETS// /}" ] && python3 "$SCRIPT_DIR/gds_top_texts.py" --one-per-net "$GDS" "$LTOP" $KEEPNETS >> "$OUT/pg_texts.pvl"
  cat "$OUT/pg_texts.pvl"
  [ -n "${DEFNETS// /}" ] && cat "$OUT/pg_labels.pvl"
  # A supply port with no text anywhere (an IO-ring-only rail such as VSWITCH or
  # VCCHIB: no bond pad, no special wire) cannot be a layout port: compare it
  # as a net only
  for n in $(sed -n 's,^// NO_TEXT ,,p' "$OUT/pg_texts.pvl" || true); do
    case " $DEFNETS " in *" $n "*) continue;; esac
    echo "lvs_delete_cell_pin $TOP $n -source   // supply port without layout text"
  done
  [ -n "$EXTRA" ] && { echo "// --- $EXTRA"; cat "$EXTRA"; }
} >> "$OUT/deck.pvl"
[ ${#BB[@]} -gt 0 ] && echo "    black boxes: ${BB[*]}"
[ ${#FULL[@]} -gt 0 ] && echo "    transistor level: ${FULL[*]}"
[ "$IGNPORTS" = 1 ] && echo "    top-level ports NOT compared (--ignore-top-ports)"

# ---- 3. memory gate, then Pegasus
need=$((MEMGB + 8)); waited=0
while :; do
  avail=$(free -g | awk '/^Mem:/{print $7}')
  [ "$avail" -ge "$need" ] && break
  [ $waited -ge 30 ] && die "only ${avail} GB available after 30 min (need $need: ${MEMGB} run + 8 kept free)"
  echo "    waiting for memory: ${avail} GB available, need $need"; sleep 60; waited=$((waited+1))
done
echo ">>> [3/3] pegasus -lvs -dp $DP ($("$PEGASUS_BIN" -version 2>/dev/null | grep -o -m1 "[0-9][0-9]\.[0-9]*-[a-z0-9]*"); ${avail} GB available)"
cd "$OUT"
T0=$(date +%s)
set +e
"$PEGASUS_BIN" -lvs -dp "$DP" -automatch -check_schematic -ui_data \
  -gds "$GDS" -top_cell "$LTOP" -source_top_cell "$TOP" \
  -spice "$LTOP.spi" deck.pvl > pegasus.log 2>&1
RC_PEG=$?
set -e
echo "    pegasus exit $RC_PEG after $(( $(date +%s) - T0 )) s (log: $OUT/pegasus.log)"
CLS=$(ls -t ./*.cls 2>/dev/null | head -1 || true)
if [ -z "$CLS" ]; then
  grep -E "ERROR|Error" pegasus.log | head -20
  tail -20 pegasus.log
  die "pegasus produced no comparison report (exit $RC_PEG)"
fi
python3 "$SCRIPT_DIR/chip_lvs_digest.py" "$OUT/${CLS#./}" | tee digest.txt
RESULT=$(sed -n 's/^#*[[:space:]]*Run Result[[:space:]]*:[[:space:]]*//p' "$CLS" | head -1 | tr -d ' ')
[ "$RESULT" = "MATCH" ]
