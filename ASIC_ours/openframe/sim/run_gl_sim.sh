#!/bin/bash
# =====================================================================
# run_gl_sim.sh -- gate-level simulation of the OpenFrame wrapper with the
# SoC Labs testbench and Xcelium.
#
# Usage: ./run_gl_sim.sh <netlist_dir> <run_dir> [TESTNAME] [sdf]
#   <netlist_dir>  output of write_sim_netlist.tcl (openframe_project_wrapper.sim.v, .sim.sdf)
#   <run_dir>      simulation output, <run_dir>/<TESTNAME>/ (outside the repo)
#   TESTNAME       a test in nanosoc_tech/testcodes (default hello)
#   sdf            annotate the netlist's delays (default: unit-delay cells, no timing),
#                  at the corner SDF_CORNER names: slow (default), typical or fast.
#                  The testbench's clock is then 30 ns, the period the design is
#                  constrained to (CLK_HALF_NS=15; the variable also works without
#                  sdf). The testbench's own generator is fixed at 20 ns, so a copy
#                  of the testbench with that one delay changed is made in the run
#                  directory. Timing violations are reported but do not corrupt state
#                  (xrun -nonotifier): inputs from the testbench are asynchronous to
#                  the clock, and static timing analysis is the sign-off for setup and
#                  hold. XRUN_OPTS adds to or replaces that option.
# Env: TIMEOUT_NS (default 3000000) ends a run that never reaches the end of the test;
#      HEARTBEAT_NS=<n> prints the simulation time every n ns;
#      PADLOG=1 logs every change on the host-link pads to padlog.txt;
#      MAKE_ARGS adds make variables: the project's own tests (nanosoc/system/testcodes)
#      need MAKE_ARGS=TOOL_CHAIN=gcc;
#      MEM_GATES=1 simulates ChipFoundry's pre-hardened DFFRAM blocks as their gate
#      netlists (OL-DFFRAM hdl/gl) and not as models, and with sdf gives each block
#      ChipFoundry's SDF for the same corner: every latch, clock gate and tri-state
#      line of the memories is then in the simulation with its delays. Needs the
#      netlists and SDF files (../fetch_dffram.sh --sim). The program is put into
#      the instruction memory's latches by deposit (dffram_gl_preload.py);
#      SMALL_SW=1 builds the test program with gcc for size (newlib-nano, unused
#      sections dropped, ../sw/small_puts.c) and for the real memory sizes
#      (../sw/openframe.ld: 4 kbyte and 1 kbyte, the stack at the top of the data
#      memory), and implies TOOL_CHAIN=gcc: a program built the default way is
#      12 kbyte and does not fit the instruction memory;
#      RTL=1 simulates the wrapper's RTL in the same frame model and testbench, in
#      place of a netlist (<netlist_dir> is then not used: give -). The sources are
#      the ones synthesis reads (make flist_genus_nanosoc, genus_flist_to_xrun.py),
#      with the OpenFrame boot ROM built from ../sw/bootrom and ChipFoundry's
#      pre-hardened DFFRAM blocks as models;
#      FLASH= where the program is and what the boot ROM is to do with the board's
#      flash (spiflash_model.v). The run fails unless the ROM prints the line given:
#        (unset)  flash erased, program preloaded          "flash: no image"
#        boot     program in the flash only                "flash: loaded"
#        prog     as boot, but the flash starts erased and is first written
#                 through the chip with FLASH_PROG high    "flash: loaded"
#        skip     program in the flash and preloaded, and the host's skip word
#                 in the data memory                       "flash: skipped, host"
#        badsum   as boot with one byte of the image wrong: the ROM must stop
#                 ("flash: BAD SUM"), so the test's pass line must NOT appear;
#      NOHOST=1 disconnects the host-link pads from the testbench (a board with
#      nothing on those header pins) and stalls the chip's stream port. Nothing
#      the chip prints is then seen; the run passes when the frame model sees
#      the processor fetch the program's first word. Use it with FLASH=boot.
#
# The testbench is SoC Labs' nanosoc_tb_GATE.v, unchanged. The design under
# test is the module in nanosoc_chip_pads_openframe.v: the gate netlist inside a
# model of ChipFoundry's frame. Software build, ADP upload and the pass/fail
# message are those of the RTL simulation (make run_xr), so the two logs compare
# line for line.
# Prints the test's result lines and exits 0 only when the test passed and the
# frame model reported no error.
# =====================================================================
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ $# -ge 2 ] || { sed -n '2,27p' "$0"; exit 2; }
TOP=openframe_project_wrapper
if [ -n "${RTL:-}" ]; then
    NET=
    [ "${4:-}" = sdf ] && { echo "RTL=1 has no SDF"; exit 2; }
    [ -n "${MEM_GATES:-}" ] && { echo "RTL=1 uses memory models (no MEM_GATES)"; exit 2; }
else
    NET="$(cd "$1" && pwd)" || exit 2
    [ -f "$NET/$TOP.sim.v" ] || { echo "no $TOP.sim.v in $NET (run write_sim_netlist.tcl)"; exit 2; }
fi
mkdir -p "$2"; RUN="$(cd "$2" && pwd)"
TEST="${3:-hello}"; MODE="${4:-}"

source "$SD/../Cadence/scripts/setup_env.sh" > /dev/null || { echo "environment setup failed"; exit 2; }
command -v xrun > /dev/null || { echo "xrun not on PATH"; exit 2; }

export OPENFRAME_DIR="$(cd "$SD/.." && pwd)"
export OPENFRAME_GL_NETLIST="$NET/$TOP.sim.v"
export OPENFRAME_PDK="${OPENFRAME_PDK:-/opt/pdk/sky130A}"
SRAM=sky130_sram_8kbyte_1rw_32x2048_8
export OPENFRAME_GL_NETLIST_DIR="$NET"
export OPENFRAME_SRAM_DIR="${OPENFRAME_SRAM_DIR:-${SRAM_ROOT:-/opt/pdk/sram_macros}/$SRAM}"
export OPENFRAME_GL_RUN="$RUN/$TEST"
mkdir -p "$OPENFRAME_GL_RUN"

# Which memories the netlist has, and their instance names (escaped identifiers:
# each ends at a space). openframe_gl_paths.vh gives the frame model the names;
# openframe_mem_model.v pulls in the matching simulation model.
inst () { grep -o -E "^ *$1 +\\\\[^ ]*$2[^ ]* " "$OPENFRAME_GL_NETLIST" | head -1 | awk '{print $2}'; }
if [ -n "${RTL:-}" ]; then
    MEMDEF=OF_MEM_DFFRAM; MEMMODEL="$SD/dffram_pg_models.v"; PAIRS=()
elif grep -q -E "^ *RAM1024 " "$OPENFRAME_GL_NETLIST"; then
    MEMDEF=OF_MEM_COMPILER; MEMMODEL="$SD/dffram_pg_models.v"
    PAIRS=("OF_IMEM:RAM1024:region_imem_0" "OF_DMEM:RAM512:region_dmem_0" "OF_EXPRAM_L:RAM512:region_expram_l" "OF_EXPRAM_H:RAM512:region_expram_h")
elif grep -q -E "^ *DFFRAM512x32 " "$OPENFRAME_GL_NETLIST"; then
    MEMDEF=OF_MEM_DFFRAM; MEMMODEL="$SD/dffram_pg_models.v"
    PAIRS=("OF_IMEM_LO:DFFRAM512x32:region_imem_0[^ ]*ram_lo" "OF_IMEM_HI:DFFRAM512x32:region_imem_0[^ ]*ram_hi"
           "OF_DMEM:DFFRAM256x32:region_dmem_0" "OF_EXPRAM_L:DFFRAM128x32:region_expram_l" "OF_EXPRAM_H:DFFRAM128x32:region_expram_h")
else
    MEMDEF=OF_MEM_OPENRAM; MEMMODEL="$OPENFRAME_SRAM_DIR/$SRAM.v"
    PAIRS=("OF_IMEM:$SRAM:region_imem_0" "OF_DMEM:$SRAM:region_dmem_0" "OF_EXPRAM_L:$SRAM:region_expram_l" "OF_EXPRAM_H:$SRAM:region_expram_h")
fi
[ -f "$MEMMODEL" ] || { echo "no memory model $MEMMODEL"; exit 2; }

# the corner of a timing-annotated run: which of the SDF's three values, and
# which of ChipFoundry's SDF files for the memory blocks
case "${SDF_CORNER:-slow}" in
    slow)    MTM=MAXIMUM; C512=max_ss_100C_1v60; CDIR=max; CNAME=Slowest;;
    typical) MTM=TYPICAL; C512=nom_tt_025C_1v80; CDIR=nom; CNAME=Typical;;
    fast)    MTM=MINIMUM; C512=min_ff_n40C_1v95; CDIR=min; CNAME=Fastest;;
    *) echo "SDF_CORNER: slow, typical or fast"; exit 2;;
esac
DFFRAM_DIR="${DFFRAM_ROOT:-$SD/../ip/OL-DFFRAM}"
if [ -n "${MEM_GATES:-}" ]; then
    [ "$MEMDEF" = OF_MEM_DFFRAM ] || { echo "MEM_GATES=1 needs a netlist with the pre-hardened DFFRAM blocks"; exit 2; }
    SDF512="$DFFRAM_DIR/timing/sdf/$C512/DFFRAM512x32__$C512.sdf"
    SDF256="$DFFRAM_DIR/timing/sdf/$CDIR/DFFRAM256x32.$CNAME.sdf"
    SDF128="$DFFRAM_DIR/timing/sdf/$CDIR/DFFRAM128x32.$CNAME.sdf"
    for f in "$DFFRAM_DIR"/hdl/gl/DFFRAM{512,256,128}x32.v "$SDF512" "$SDF256" "$SDF128"; do
        [ -f "$f" ] || { echo "MEM_GATES=1: no $f (run ../fetch_dffram.sh --sim)"; exit 2; }
    done
fi
{
  echo "// written by run_gl_sim.sh from $OPENFRAME_GL_NETLIST"
  echo "\`define $MEMDEF"
  echo "\`define OF_SDF_MTM \"$MTM\""
  if [ -n "${MEM_GATES:-}" ]; then
      echo "\`define OF_MEM_GATES"
      echo "\`define OF_SDF_512 \"$SDF512\""
      echo "\`define OF_SDF_256 \"$SDF256\""
      echo "\`define OF_SDF_128 \"$SDF128\""
  fi
  for t in ${PAIRS[@]+"${PAIRS[@]}"}; do
      IFS=: read -r def cell pat <<< "$t"
      name="$(inst "$cell" "$pat")"
      [ -n "$name" ] || { echo "no $cell instance matching $pat in the netlist" >&2; exit 2; }
      printf '`define %s u_openframe.%s \n' "$def" "$name"
  done
  if [ -n "${RTL:-}" ]; then
      # the same blocks by their RTL names (../rtl/sl_sram_dffram.v)
      S=u_openframe.u_nanosoc_chip.u_system
      echo "\`define OF_IMEM_LO $S.u_ss_cpu.u_region_imem_0.u_imem_0.u_sram.g_4k.u_ram_lo "
      echo "\`define OF_IMEM_HI $S.u_ss_cpu.u_region_imem_0.u_imem_0.u_sram.g_4k.u_ram_hi "
      echo "\`define OF_DMEM $S.u_ss_cpu.u_region_dmem_0.u_dmem_0.u_sram.g_1k.u_ram "
      echo "\`define OF_EXPRAM_L $S.u_ss_expansion.u_region_expram_l.u_expram_l.u_sram.g_512.u_ram "
      echo "\`define OF_EXPRAM_H $S.u_ss_expansion.u_region_expram_h.u_expram_h.u_sram.g_512.u_ram "
  fi
} > "$OPENFRAME_GL_RUN/openframe_gl_paths.vh" || exit 2
if [ -n "${MEM_GATES:-}" ]; then
    # the blocks' gate netlists in place of the models, and the backdoor to their latches
    { echo "// written by run_gl_sim.sh: the DFFRAM blocks' gate netlists"
      for n in 512 256 128; do printf '`include "%s"\n' "$DFFRAM_DIR/hdl/gl/DFFRAM${n}x32.v"; done
    } > "$OPENFRAME_GL_RUN/openframe_mem_model.v"
    python3 "$SD/dffram_gl_preload.py" "$OPENFRAME_GL_RUN/openframe_mem_preload.vh" \
        'OF_IMEM_LO=`OF_IMEM_LO :512' 'OF_IMEM_HI=`OF_IMEM_HI :512' 'OF_DMEM=`OF_DMEM :256' \
        'OF_EXPRAM_L=`OF_EXPRAM_L :128' 'OF_EXPRAM_H=`OF_EXPRAM_H :128' || exit 2
else
    printf '// written by run_gl_sim.sh: the memory model for this netlist\n`include "%s"\n' "$MEMMODEL" > "$OPENFRAME_GL_RUN/openframe_mem_model.v"
fi

# power-aware models: the netlist connects every cell's supply pins
DEFS="+define+OF_GATE_SIM +define+USE_POWER_PINS +define+OF_TIMEOUT_NS=${TIMEOUT_NS:-3000000}"
FLIST="$SD/openframe_gl.flist"; MKARGS=()
if [ -n "${RTL:-}" ]; then
    # RTL: no supply pins. The boot ROM, the memory sizes of the pre-hardened
    # blocks, and the sources synthesis reads (without its boot ROM and its
    # sl_sram, which openframe_rtl.flist replaces).
    # The design's defines (gen_defines.v) are made here as synthesis has them:
    # the simulation's own make target adds IMEM_0_RAM_PRELOAD, which swaps the
    # instruction memory for a ROM model, and leaves out ASIC_TEST_PORTS. The
    # file is put first on the include path. (ASIC=yes is not passed to the
    # simulation's make: it would add the pad-ring chip's boot ROM and memory
    # wrapper to the file list.) The comparator latch is standard cells in RTL
    # too, hence the cell models.
    DEFS="+define+OF_RTL_SIM +define+FUNCTIONAL +define+UNIT_DELAY=#1 +define+OF_TIMEOUT_NS=${TIMEOUT_NS:-3000000}"
    FLIST="$SD/openframe_rtl.flist"
    B="$OPENFRAME_GL_RUN/rtl_build"; mkdir -p "$B"
    printf '`define OF_IMEM_AW 12\n`define OF_DMEM_AW 10\n`define OF_EXPRAM_L_AW 9\n`define OF_EXPRAM_H_AW 9\n' > "$OPENFRAME_GL_RUN/of_mem_config.vh"
    { make -C "$SD/../sw/bootrom" OUT="$B" &&
      make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 BOOTROM_ADDRW=9 \
           BOOTROM_HEX="$B/of_bootrom.hex" BOOTROM_BUILD_DIR="$B/bootrom" bootrom &&
      make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 flist_genus_nanosoc &&
      make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" ASIC=yes NODE=SKY130 DEFINES_DIR="$B/defines" \
           DEFINES_FILE="$B/defines/gen_defines.v" gen_defs &&
      python3 "$SD/genus_flist_to_xrun.py" "$SOCLABS_PROJECT_DIR/imp/ASIC/nanosoc/flist/genus_flist.tcl" \
           "$OPENFRAME_GL_RUN/openframe_rtl_design.flist" --drop '/bootrom\.s?v$' --drop '/sl_sram\.v$' \
           --drop '/gen_defines\.v$' --drop '/system/src/defines$'
    } > "$RUN/rtl_build_$TEST.log" 2>&1 || { echo "RTL build failed:"; tail -5 "$RUN/rtl_build_$TEST.log"; exit 2; }
    export OPENFRAME_BOOTROM_SV="$B/bootrom/verilog" OPENFRAME_RTL_DEFINES="$B/defines"
fi
# FLASH: what the flash holds, whether the program is preloaded, and the line the boot ROM must print
case "${FLASH:-}" in
    "")     EXPECT="flash: no image";;
    boot)   EXPECT="flash: loaded";        DEFS="$DEFS +define+OF_FLASH +define+OF_NO_IMEM_PRELOAD";;
    prog)   EXPECT="flash: loaded";        DEFS="$DEFS +define+OF_FLASH +define+OF_NO_IMEM_PRELOAD +define+OF_FLASH_PROG";;
    skip)   EXPECT="flash: skipped, host"; DEFS="$DEFS +define+OF_FLASH +define+OF_BOOT_SKIP";;
    badsum) EXPECT="flash: BAD SUM";       DEFS="$DEFS +define+OF_FLASH +define+OF_NO_IMEM_PRELOAD";;
    *) echo "FLASH: boot, prog, skip or badsum"; exit 2;;
esac
[ -n "${NOHOST:-}" ] && { DEFS="$DEFS +define+OF_NO_HOST"; EXPECT="\\[OPENFRAME\\] no host: the program started"; }
[ -n "${HEARTBEAT_NS:-}" ] && DEFS="$DEFS +define+OF_HEARTBEAT_NS=$HEARTBEAT_NS"
[ -n "${PADLOG:-}" ] && DEFS="$DEFS +define+OF_PADLOG"
# SMALL_SW=1: the software build's compiler flags, replaced as one make variable
SWARGS=()
[ -n "${SMALL_SW:-}" ] && SWARGS=(TOOL_CHAIN=gcc "GNU_CC_FLAGS=-g -mthumb -mcpu=cortex-m0 -Os --specs=nano.specs -ffunction-sections -fdata-sections -Wl,--gc-sections $SD/../sw/small_puts.c" "LINKER_SCRIPT=$SD/../sw/openframe.ld")
if [ "$MODE" = sdf ]; then
    [ -f "$NET/$TOP.sim.sdf" ] || { echo "no $TOP.sim.sdf in $NET"; exit 2; }
    DEFS="$DEFS +define+OF_SDF"
    # the SDF names instances by hierarchy; the netlist is flat (see sdf_flat_names.py)
    # (with MEM_GATES the blocks' own entries are left out: their delays come from their SDF)
    python3 "$SD/sdf_flat_names.py" "$NET/$TOP.sim.sdf" "$OPENFRAME_GL_RUN/$TOP.sim.flat.sdf" ${MEM_GATES:+'^DFFRAM[0-9]+x32$'} || exit 2
    CLK_HALF_NS="${CLK_HALF_NS:-15}"
    XOPTS="${XRUN_OPTS--nonotifier}"
else
    DEFS="$DEFS +define+FUNCTIONAL +define+UNIT_DELAY=#1"
fi
if [ -n "${CLK_HALF_NS:-}" ]; then
    # a copy of the testbench with its clock at 2 x CLK_HALF_NS
    sed -E '/always @\(osc_q\)/{n;s/#10/#'"$CLK_HALF_NS"'/}' \
        "$SOCLABS_NANOSOC_TECH_DIR/verif/tb/verilog/nanosoc_tb_GATE.v" > "$OPENFRAME_GL_RUN/nanosoc_tb_GATE.v"
    grep -q "#$CLK_HALF_NS\$" "$OPENFRAME_GL_RUN/nanosoc_tb_GATE.v" || { echo "could not set the testbench clock"; exit 2; }
    export OPENFRAME_TB_DIR="$OPENFRAME_GL_RUN"
fi

export OPENFRAME_TB_DIR="${OPENFRAME_TB_DIR:-$SOCLABS_NANOSOC_TECH_DIR/verif/tb/verilog}"
LOG="$RUN/make_$TEST.log"
if [ -n "${FLASH:-}" ]; then
    # the program first (image.hex in the simulation directory), then the flash's contents from it
    make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" testcode TESTNAME="$TEST" SIM_TOP_DIR="$RUN" \
         ${MAKE_ARGS:-} ${SWARGS[@]+"${SWARGS[@]}"} < /dev/null > "$RUN/make_sw_$TEST.log" 2>&1
    python3 "$SD/../sw/mkflashimg.py" "$OPENFRAME_GL_RUN/image.hex" --hex "$OPENFRAME_GL_RUN/flash.hex" \
        || { echo "no flash image (see $RUN/make_sw_$TEST.log)"; exit 2; }
    if [ "$FLASH" = badsum ]; then
        # one byte of the program wrong (line 21 is the image's fifth byte)
        sed -i '21s/.*/5a/' "$OPENFRAME_GL_RUN/flash.hex"
    fi
fi
KIND=gate-level; [ -n "${RTL:-}" ] && KIND=RTL
echo "=== $KIND $TEST ${MODE:+($MODE, ${SDF_CORNER:-slow} corner) }${MEM_GATES:+memories as gate netlists }${FLASH:+flash: $FLASH }-> $OPENFRAME_GL_RUN  ($(date '+%F %T'))"
make -C "$SOCLABS_PROJECT_DIR/nanosoc_tech" run_xr TESTNAME="$TEST" SIM_TOP_DIR="$RUN" \
     TBENCH_VC="$FLIST" DESIGN_VC="$FLIST" TB_TOP=nanosoc_tb ${MKARGS[@]+"${MKARGS[@]}"} \
     EXTRA_DEFINES="$DEFS" XRUN_EXTRA_SRC="-exit ${XOPTS:-${XRUN_OPTS:-}}" ${MAKE_ARGS:-} ${SWARGS[@]+"${SWARGS[@]}"} < /dev/null > "$LOG" 2>&1
echo "    make exit $? (log: $LOG)"
RL="$OPENFRAME_GL_RUN/logs/run_$TEST.log"
[ -f "$RL" ] || { tail -20 "$LOG"; exit 1; }
grep -a -E "^\[OPENFRAME\]|^flash: |TEST (PASSED|FAILED)|Test (Passed|Failed|FAILED)|_TEST: (PASS|FAIL)|Hello world|Simulation (stopped|complete)|\*[EF]," "$RL" | head -30
if [ "$MODE" = sdf ]; then
    echo "    SDF path delays $(grep -m1 -o 'Annotated = [0-9.]*%' "$RL"); instances not found: $(grep -c 'SDFINF' "$RL")"
    echo "    timing violations reported: $(grep -c 'Warning!  Timing violation' "$RL"), by instance (bit numbers dropped):"
    grep -A3 'Warning!  Timing violation' "$RL" | grep -o 'Scope: [^ ]*' | sed -E 's/.*u_openframe\.//; s/\[[0-9]+\]/[n]/g' | sort | uniq -c | sort -rn | head -5 | sed 's/^/      /'
    grep -q 'SDFINF' "$RL" && { echo "    ERROR: part of the SDF was not applied"; exit 1; }
fi
# pass lines: "TEST PASSED" (hello), "Test Passed!" (the project tests), "<NAME>_TEST: PASS" (fault_recovery_test, pslverr_test)
grep -a -q "^$EXPECT" "$RL" || { echo "    ERROR: the log has no line \"$EXPECT\""; exit 1; }
[ -n "${NOHOST:-}" ] && { grep -q "^\[OPENFRAME\] ERROR\|pad configuration check FAILED" "$RL" && exit 1; exit 0; }
if [ "${FLASH:-}" = badsum ]; then
    # the ROM must have stopped: no pass line, and the run ends on the timeout
    grep -q -E "TEST PASSED|Test Passed|_TEST: PASS" "$RL" && { echo "    ERROR: the program ran from a flash image with a wrong sum"; exit 1; }
    grep -v "no end of test" "$RL" | grep -q "^\[OPENFRAME\] ERROR\|pad configuration check FAILED" && exit 1
    exit 0
fi
grep -q "^\[OPENFRAME\] ERROR\|pad configuration check FAILED" "$RL" && exit 1
grep -q -E "TEST PASSED|Test Passed|_TEST: PASS" "$RL"
