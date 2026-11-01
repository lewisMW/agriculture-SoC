#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# run_all_tests.sh — run every test / coverage / UVM bench in the repo, one
# after another, and print a PASS/FAIL table at the end.
#
# Run from the repo root (or anywhere — it cd's to its own directory):
#     ./run_all_tests.sh                 # everything
#     ./run_all_tests.sh --quick         # lint + unit tests only (fast)
#     ./run_all_tests.sh --free          # only what needs NO ARM IP
#     ./run_all_tests.sh --no-uvm --no-socsim
#     ./run_all_tests.sh --only unit     # one group: lint|unit|cov|uvm|nsccov|socsim
#     ./run_all_tests.sh --list          # show the steps, run nothing
#
# Groups (in run order):
#   lint    verilator --lint-only (informational; -Wall warnings don't fail the run)
#   unit    block TBs: FIFO, FSM, RTC, Wrapper (+rand, +sva), full-SoC check/reset_rand
#   cov     functional coverage runs (verif/cov) + merged report
#   uvm     UVM benches (FIFO, full sensing peripheral) — slow first build
#   nsccov  nanosoc system coverage harness + ADP self-checking tests
#   socsim  nanosoc firmware tests under socsim/iverilog (reads uart2.log)
#
# Parallelism: each build uses JOBS cores (default: half of nproc, max 4).
# Steps still run one after another. The limit is RAM, not CPU — an unbounded
# -j 0 UVM build once ran the WSL box out of memory and crashed it. Never -j 0.
#     JOBS=8 ./run_all_tests.sh      # more cores (if you have the RAM)
#     JOBS=1 ./run_all_tests.sh      # back to single-core
#
# Logs: test_results/<timestamp>/<step>.log  — summary in summary.txt there.
# Exit code: 0 if every gating step passed, 1 otherwise.
# -----------------------------------------------------------------------------
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOC="$REPO/agriculture_soc_main"
NSC="$REPO/nanosoc"
MIN_VERILATOR="5.052"
_half=$(( $(nproc 2>/dev/null || echo 2) / 2 )); [ "$_half" -lt 1 ] && _half=1; [ "$_half" -gt 4 ] && _half=4
export JOBS="${JOBS:-$_half}"
export MAKEFLAGS="-j${JOBS}"
STEP_TIMEOUT="${STEP_TIMEOUT:-5400}"      # seconds per step (UVM first build is slow)
SOCSIM_TIMEOUT="${SOCSIM_TIMEOUT:-3600}"  # seconds per firmware test

SOCSIM_TESTS=(adc_trigger_test fifo_drain_test sensing_driver_test rtc_time_test
              adc_autonomous_test pslverr_test fault_recovery_test)

# ---------------------------------------------------------------- arguments --
DO_LINT=1 DO_UNIT=1 DO_COV=1 DO_UVM=1 DO_NSCCOV=1 DO_SOCSIM=1
FREE_ONLY=0 LIST_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --quick)      DO_COV=0 DO_UVM=0 DO_NSCCOV=0 DO_SOCSIM=0 ;;
    --free)       FREE_ONLY=1 ;;
    --no-lint)    DO_LINT=0 ;;
    --no-unit)    DO_UNIT=0 ;;
    --no-cov)     DO_COV=0 ;;
    --no-uvm)     DO_UVM=0 ;;
    --no-nsccov)  DO_NSCCOV=0 ;;
    --no-socsim)  DO_SOCSIM=0 ;;
    --only)       shift
                  DO_LINT=0 DO_UNIT=0 DO_COV=0 DO_UVM=0 DO_NSCCOV=0 DO_SOCSIM=0
                  case "${1:-}" in
                    lint) DO_LINT=1 ;; unit) DO_UNIT=1 ;; cov) DO_COV=1 ;;
                    uvm) DO_UVM=1 ;; nsccov) DO_NSCCOV=1 ;; socsim) DO_SOCSIM=1 ;;
                    *) echo "--only needs one of: lint unit cov uvm nsccov socsim"; exit 2 ;;
                  esac ;;
    --list)       LIST_ONLY=1 ;;
    -h|--help)    sed -n 2,28p "$0"; exit 0 ;;
    *)            echo "unknown option: $1 (try --help)"; exit 2 ;;
  esac
  shift
done

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$REPO/test_results/$STAMP"
[ "$LIST_ONLY" = 1 ] || mkdir -p "$OUT"

if [ -t 1 ]; then G=$'\e[32m' R=$'\e[31m' Y=$'\e[33m' B=$'\e[1m' N=$'\e[0m'; else G= R= Y= B= N=; fi

RESULTS=()   # "STATUS|name|detail"
GATING_FAIL=0

record() {   # record STATUS name detail
  RESULTS+=("$1|$2|$3")
  case "$1" in
    PASS) printf '  %s%-6s%s %-28s %s\n' "$G" "$1" "$N" "$2" "$3" ;;
    FAIL) printf '  %s%-6s%s %-28s %s\n' "$R" "$1" "$N" "$2" "$3"; GATING_FAIL=1 ;;
    *)    printf '  %s%-6s%s %-28s %s\n' "$Y" "$1" "$N" "$2" "$3" ;;
  esac
}

# Verdict from a log: any "=== X: N PASSED, M FAILED ===" with M>0 -> fail;
# any UVM_ERROR/UVM_FATAL count > 0 -> fail. Echoes a short detail string.
log_verdict() {
  local log="$1" detail="" bad=0
  local sums; sums="$(grep -E '===.*PASSED,.*FAILED.*===' "$log" 2>/dev/null | sed 's/^ *//')"
  if [ -n "$sums" ]; then
    detail="$(echo "$sums" | sed -E 's/=== *//; s/ *===.*//' | paste -sd ';' -)"
    echo "$sums" | grep -qE '[1-9][0-9]* FAILED' && bad=1
  fi
  local ue uf
  ue="$(grep -E '^UVM_ERROR *: *[0-9]+' "$log" 2>/dev/null | tail -1 | grep -oE '[0-9]+$')"
  uf="$(grep -E '^UVM_FATAL *: *[0-9]+' "$log" 2>/dev/null | tail -1 | grep -oE '[0-9]+$')"
  if [ -n "$ue$uf" ]; then
    detail="${detail:+$detail; }UVM_ERROR=${ue:-?} UVM_FATAL=${uf:-?}"
    { [ "${ue:-0}" != 0 ] || [ "${uf:-0}" != 0 ]; } && bad=1
  fi
  grep -qE '^%Error' "$log" 2>/dev/null && { bad=1; detail="${detail:+$detail; }verilator %Error"; }
  echo "$bad|$detail"
}

# run_step NAME KIND DIR CMD...   KIND = gate (fails the run) | info (never fails)
run_step() {
  local name="$1" kind="$2" dir="$3"; shift 3
  if [ "$LIST_ONLY" = 1 ]; then printf '  %-28s (%s) cd %s && %s\n' "$name" "$kind" "${dir#$REPO/}" "$*"; return; fi
  local log="$OUT/$name.log" t0=$SECONDS rc
  printf '%s>> %s%s  (%s)\n' "$B" "$name" "$N" "${dir#$REPO/}"
  ( cd "$dir" && timeout "$STEP_TIMEOUT" bash -c "$*" ) > "$log" 2>&1
  rc=$?
  local dt=$((SECONDS - t0)) v bad detail
  v="$(log_verdict "$log")"; bad="${v%%|*}"; detail="${v#*|}"
  [ "$rc" = 124 ] && detail="TIMEOUT after ${STEP_TIMEOUT}s; $detail"
  detail="${detail:-exit $rc} [${dt}s]"
  if [ "$rc" = 0 ] && [ "$bad" = 0 ]; then
    record PASS "$name" "$detail"
  elif [ "$kind" = info ]; then
    record WARN "$name" "$detail (non-gating, see log)"
  else
    record FAIL "$name" "exit $rc; $detail -> $log"
  fi
}

skip() { [ "$LIST_ONLY" = 1 ] && printf '  %-28s SKIP: %s\n' "$1" "$2" || record SKIP "$1" "$2"; }

# ---------------------------------------------------------------- preflight --
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

echo "${B}== Preflight ==${N}"
PRE_OK=1
if [ -n "${VERILATOR_ROOT:-}" ]; then
  echo "  ${Y}WARN${N}  VERILATOR_ROOT is set ($VERILATOR_ROOT) — it can shadow the install. Recommend: unset VERILATOR_ROOT"
fi
if command -v verilator >/dev/null; then
  VV="$(verilator --version | awk '{print $2}')"
  if ver_ge "$VV" "$MIN_VERILATOR"; then echo "  ok    verilator $VV ($(command -v verilator))"
  else echo "  ${R}FAIL${N}  verilator $VV < $MIN_VERILATOR — covergroups are silently dropped. See WSL_TEST_SETUP.txt"; PRE_OK=0; fi
else echo "  ${R}FAIL${N}  verilator not found"; PRE_OK=0; fi
command -v verilator_coverage >/dev/null && echo "  ok    verilator_coverage" || echo "  ${Y}WARN${N}  verilator_coverage missing (cov reports will fail)"
command -v z3 >/dev/null || command -v cvc5 >/dev/null \
  && echo "  ok    SMT solver ($(command -v z3 || command -v cvc5))" \
  || { echo "  ${R}FAIL${N}  no z3/cvc5 — randomize() fails at runtime (rand/UVM benches)"; PRE_OK=0; }
export UVM_HOME="${UVM_HOME:-/opt/uvm}"
if [ -f "$UVM_HOME/src/uvm_pkg.sv" ]; then echo "  ok    UVM_HOME=$UVM_HOME"
else echo "  ${Y}WARN${N}  UVM not found at UVM_HOME=$UVM_HOME — UVM group will be skipped"; DO_UVM=0; fi
command -v python3 >/dev/null && echo "  ok    python3" || echo "  ${Y}WARN${N}  python3 missing (coverage holes / ADP tests need it)"

HAVE_ARM=0
if [ "$FREE_ONLY" = 0 ]; then
  if [ -z "${ARM_IP_LIBRARY_PATH:-}" ] && [ -f "$NSC/env/dependency_env.sh" ]; then
    # Pick up the path the nanosoc flow already uses on this box.
    ARM_IP_LIBRARY_PATH="$(grep -oE 'ARM_IP_LIBRARY_PATH:-[^}]*' "$NSC/env/dependency_env.sh" | head -1 | sed 's/.*:-//')"
    export ARM_IP_LIBRARY_PATH
  fi
  if [ -n "${ARM_IP_LIBRARY_PATH:-}" ] && [ -d "$ARM_IP_LIBRARY_PATH/Cortex-M0" ] && [ -d "$ARM_IP_LIBRARY_PATH/PL031" ]; then
    HAVE_ARM=1; echo "  ok    ARM_IP_LIBRARY_PATH=$ARM_IP_LIBRARY_PATH"
  else
    echo "  ${Y}WARN${N}  ARM IP not found (ARM_IP_LIBRARY_PATH='${ARM_IP_LIBRARY_PATH:-}') — running ARM-IP-free steps only"
  fi
fi
if [ "$DO_SOCSIM" = 1 ] && [ "$HAVE_ARM" = 1 ]; then
  for t in iverilog arm-none-eabi-gcc; do
    command -v $t >/dev/null && echo "  ok    $t" || { echo "  ${Y}WARN${N}  $t missing — socsim group will be skipped"; DO_SOCSIM=0; }
  done
  # bootrom_gen.py (run by every socsim build) imports jinja2.
  python3 -c 'import jinja2' 2>/dev/null && echo "  ok    python3 jinja2" \
    || { echo "  ${Y}WARN${N}  python3 jinja2 missing (sudo apt install python3-jinja2) — socsim group will be skipped"; DO_SOCSIM=0; }
fi
if [ "$PRE_OK" = 0 ] && [ "$LIST_ONLY" = 0 ]; then
  echo "${R}Preflight failed — fix the above first (see WSL_TEST_SETUP.txt).${N}"; exit 1
fi
[ "$LIST_ONLY" = 1 ] || echo "  logs -> $OUT"

need_arm() { [ "$HAVE_ARM" = 1 ]; }

# --------------------------------------------------------------------- lint --
if [ "$DO_LINT" = 1 ]; then
  echo; echo "${B}== Lint (informational) ==${N}"
  run_step lint-free info "$SOC" "make lint-free"
  if need_arm; then run_step lint info "$SOC" "make lint"; else skip lint "needs ARM IP"; fi
fi

# --------------------------------------------------------------- unit tests --
if [ "$DO_UNIT" = 1 ]; then
  echo; echo "${B}== Unit / block tests ==${N}"
  run_step fifo-directed gate "$SOC/FIFO"  "make all"
  run_step fifo-rand     gate "$SOC/FIFO"  "make rand"
  run_step fsm-directed  gate "$SOC/FSM"   "make all"
  run_step fsm-seq       gate "$SOC/FSM"   "make seq"
  if need_arm; then
    run_step rtc-directed     gate "$SOC/RTC"     "make all"
    run_step rtc-rand         gate "$SOC/RTC"     "make rand"
    run_step wrapper-directed gate "$SOC/Wrapper" "make all"
    run_step wrapper-rand     gate "$SOC/Wrapper" "make rand"
    run_step wrapper-sva      gate "$SOC/Wrapper" "make sva"
    run_step soc-check        gate "$SOC"         "make check"
    run_step soc-reset-rand   gate "$SOC"         "make reset_rand"
  else
    for s in rtc-directed rtc-rand wrapper-directed wrapper-rand wrapper-sva soc-check soc-reset-rand; do skip $s "needs ARM IP"; done
  fi
fi

# ----------------------------------------------------------------- coverage --
if [ "$DO_COV" = 1 ]; then
  echo; echo "${B}== Functional coverage (verif/cov) ==${N}"
  run_step cov-fifo gate "$SOC/verif/cov" "make fifo"
  run_step cov-fsm  gate "$SOC/verif/cov" "make fsm"
  if need_arm; then
    run_step cov-rtc     gate "$SOC/verif/cov" "make rtc"
    run_step cov-rtcdir  gate "$SOC/verif/cov" "make rtcdir"
    run_step cov-wrapper gate "$SOC/verif/cov" "make wrapper"
    run_step cov-wrapdir gate "$SOC/verif/cov" "make wrapdir"
    # sens_gap_tb deliberately probes suspected RTL bugs (19 known FAILs at
    # time of writing) — reported, but doesn't fail the run.
    run_step cov-gap     info "$SOC/verif/cov" "make gap"
  else
    for s in cov-rtc cov-rtcdir cov-wrapper cov-wrapdir cov-gap; do skip $s "needs ARM IP"; done
  fi
  run_step cov-report info "$SOC/verif/cov" "make report && make holes"
fi

# ---------------------------------------------------------------------- UVM --
if [ "$DO_UVM" = 1 ]; then
  echo; echo "${B}== UVM benches (first build is slow on 1 core) ==${N}"
  run_step uvm-fifo gate "$SOC" "make uvm-fifo"
  if need_arm; then run_step uvm-sensing gate "$SOC" "make uvm-sensing"
  else run_step uvm-sensing-stub info "$SOC" "make uvm-sensing STUB_RTC=1"; fi
fi

# ---------------------------------------------------- nanosoc cov harness ----
if [ "$DO_NSCCOV" = 1 ]; then
  echo; echo "${B}== NanoSoC system coverage harness (Verilator, ARM stand-ins) ==${N}"
  run_step nsc-build    gate "$NSC/system/verif/cov" "make build"
  run_step nsc-adptests gate "$NSC/system/verif/cov" "make adptests"
  run_step nsc-report   info "$NSC/system/verif/cov" "make report"
fi

# ------------------------------------------------------ nanosoc firmware -----
if [ "$DO_SOCSIM" = 1 ]; then
  echo; echo "${B}== NanoSoC firmware tests (socsim / iverilog) ==${N}"
  if ! need_arm; then
    for t in "${SOCSIM_TESTS[@]}"; do skip "fw-$t" "needs ARM IP"; done
  elif [ "$LIST_ONLY" = 1 ]; then
    for t in "${SOCSIM_TESTS[@]}"; do printf '  %-28s socsim test_accelerator TESTNAME=%s TOOL_CHAIN=gcc\n' "fw-$t" "$t"; done
  else
    for t in "${SOCSIM_TESTS[@]}"; do
      log="$OUT/fw-$t.log"; t0=$SECONDS
      printf '%s>> fw-%s%s\n' "$B" "$t" "$N"
      # set_env.sh sometimes needs sourcing twice before it settles (see CLAUDE.md).
      # set +u: the soctools setup scripts read unset vars (SOCLABS_DESIGN_ROOT, ...);
      # under this script's `set -u` that silently killed the subshell -> empty log.
      ( set +u; cd "$NSC" && source ./set_env.sh >/dev/null 2>&1; source ./set_env.sh >/dev/null 2>&1
        # socsim names the sim dir after its script (test_accelerator.sh), not
        # TESTNAME, so every test shares sim/test_accelerator and overwrites
        # logs/uart2.log. Clean it once per runner invocation (fresh RTL build),
        # and drop the previous test's uart2.log before each test.
        if [ ! -e "$OUT/.socsim_cleaned" ]; then
          rm -rf "$SOCLABS_PROJECT_DIR/simulate/sim/test_accelerator"; touch "$OUT/.socsim_cleaned"
        fi
        rm -f "$SOCLABS_PROJECT_DIR/simulate/sim/test_accelerator/logs/uart2.log"
        # socsim's "#!/usr/bin/env bash" is on line 12, not line 1, so `timeout`
        # (execvp) falls back to /bin/sh = dash -> "Bad substitution". Force bash.
        timeout "$SOCSIM_TIMEOUT" bash "$(command -v socsim)" test_accelerator TESTNAME="$t" TOOL_CHAIN=gcc
        echo "SOCSIM_EXIT=$?"
        echo "SIMDIR=$SOCLABS_PROJECT_DIR/simulate/sim/test_accelerator" ) < /dev/null > "$log" 2>&1
      simdir="$(grep '^SIMDIR=' "$log" | tail -1 | cut -d= -f2-)"
      sexit="$(grep '^SOCSIM_EXIT=' "$log" | tail -1 | cut -d= -f2)"
      uart="$simdir/logs/uart2.log"; dt=$((SECONDS - t0))
      [ -f "$uart" ] && cp "$uart" "$OUT/fw-$t.uart2.log"
      # uart_capture echoes every UART2 line to the console as well. On the WSL
      # box uart2.log has come back holding only its header line while the
      # console log had the full firmware output, so judge from the console log
      # when uart2.log has nothing past that header.
      if [ -f "$uart" ] && [ "$(grep -vc '^uartcapture:' "$uart")" = 0 ] && grep -q 'Test Ended' "$log"; then
        uart="$log"
      fi
      if [ ! -f "$uart" ]; then
        record FAIL "fw-$t" "no uart2.log (build failed? exit ${sexit:-?}) -> $log [${dt}s]"
      elif grep -qE 'FAIL' "$uart"; then
        record FAIL "fw-$t" "$(grep -m1 -E 'FAIL' "$uart" | tr -d '\r') -> $OUT/fw-$t.uart2.log [${dt}s]"
      elif grep -qE 'Test Passed!|: PASS' "$uart"; then
        record PASS "fw-$t" "$(grep -m1 -E 'Test Passed!|: PASS' "$uart" | tr -d '\r') [${dt}s]"
      elif grep -q 'SKIPPED' "$uart"; then
        record WARN "fw-$t" "$(grep -m1 SKIPPED "$uart" | tr -d '\r') [${dt}s]"
      else
        record FAIL "fw-$t" "no pass line in uart2.log (hang/timeout? exit ${sexit:-?}; check logs/tarmac0.log) [${dt}s]"
      fi
    done
  fi
fi

[ "$LIST_ONLY" = 1 ] && exit 0

# ------------------------------------------------------------------ summary --
{
  echo
  echo "===================== TEST SUMMARY ($STAMP) ====================="
  echo "verilator $(verilator --version 2>/dev/null | awk '{print $2}')   ARM IP: $([ $HAVE_ARM = 1 ] && echo yes || echo no)   JOBS=$JOBS"
  np=0 nf=0 nw=0 ns=0
  for r in "${RESULTS[@]}"; do
    IFS='|' read -r st nm dt <<< "$r"
    printf '%-5s %-26s %s\n' "$st" "$nm" "$dt"
    case $st in PASS) np=$((np+1));; FAIL) nf=$((nf+1));; WARN) nw=$((nw+1));; SKIP) ns=$((ns+1));; esac
  done
  echo "------------------------------------------------------------------"
  echo "PASS=$np  FAIL=$nf  WARN=$nw  SKIP=$ns"
  [ "$GATING_FAIL" = 0 ] && echo "RESULT: ALL GATING STEPS PASS" || echo "RESULT: FAILURES PRESENT"
  echo "Logs: $OUT"
} | tee "$OUT/summary.txt"

exit "$GATING_FAIL"
