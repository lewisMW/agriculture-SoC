#!/bin/bash
# run_afe_suite.sh -- the 6 self-checking firmware tests with the ADC analog
# front end (sar_afe) bound to a device-level netlist.
#
#   ./run_afe_suite.sh pex        # extracted layout (M1 sign-off)
#   ./run_afe_suite.sh sch        # schematic, no parasitics
#   ./run_afe_suite.sh beh        # all behavioural (no spice binding)
#   NEG=1 ./run_afe_suite.sh pex  # first a negative control: outp/outn
#                                 # swapped at the macro ports, so every
#                                 # decision inverts -> SENSING_CHECK must FAIL
#   TESTS="adc_trigger_test" ./run_afe_suite.sh sch   # subset
#
# A test is clean iff spectre completes with 0 errors, the firmware passes,
# and the log has no "SENSING_CHECK FAIL" line. Logs: afe_<cfg>_<test>.log in
# the repo root; per-test sim logs under nanosoc/simulate/sim/<test>/logs.
set -u
CFG=${1:?usage: run_afe_suite.sh pex|sch|beh}
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$REPO_ROOT/nanosoc"
export SOCLABS_PROJECT_DIR=$PWD ARM_IP_LIBRARY_PATH=/opt/arm
export LC_ALL=en_US.utf8 LANG=en_US.utf8
source env/dependency_env.sh
A=$ACCELERATOR_DIR
TESTS=${TESTS:-"adc_trigger_test adc_autonomous_test fifo_drain_test rtc_time_test pslverr_test sensing_driver_test"}

case "$CFG" in
  beh) XSRC="" ;;
  sch|pex) XSRC="$A/AMS/amsd_sky130_afe_$CFG.scs"
           NETF="$A/AMS/spice/sar_afe.$CFG.scs"
           [ -f "$NETF" ] || { echo "missing $NETF - generate it: analog/cadence/pv/$( [ $CFG = pex ] && echo 'run_pex.sh sar_adc sar_afe' || echo 'netlist_spectre.sh sar_adc sar_afe <out>')"; exit 2; } ;;
  *) echo "unknown config $CFG"; exit 2 ;;
esac

run_one() {  # $1 test, $2 amsd file ("" = behavioural), $3 log tag
  local T=$1 X=$2 TAG=$3 L
  timeout 7200 make -C nanosoc_tech run_xr TESTNAME=$T ACCELERATOR=yes TOOL_CHAIN=gcc \
      SAR_AMS_INCLUDE=yes ${X:+XRUN_EXTRA_SRC="$X"} \
      ${X:+AMS_ACF="$A/AMS/acf_sky130.scs"} EXTRA_DEFINES=+define+SENSING_CHECK \
      > "$REPO_ROOT/afe_${TAG}_$T.log" 2>&1
  L=$REPO_ROOT/nanosoc/simulate/sim/$T/logs/run_$T.log
  printf "  spectre      : %s\n" "$(grep -oE 'spectre completes with [0-9]+ errors?, [0-9]+ warnings?' $L | head -1)"
  printf "  inventory    : %s\n" "$(grep -m1 -A3 'Circuit inventory' $L | grep -oE '(bsim4|capacitor|resistor) +[0-9]+' | tr -s ' ' | paste -sd, -)"
  printf "  behavioural  : %s\n" "$(grep -oE 'worklib__(cdac_8b|switch_adc|carray_8b|inverter|comparator|sar_afe)__vams[A-Za-z_]*' $L | sort -u | paste -sd' ' -)"
  printf "  xrun errors  : %s\n" "$(grep -cE '\*E,' $L)"
  printf "  CHECK fails  : %s\n" "$(grep -c 'SENSING_CHECK FAIL' $L)"
  grep 'SENSING_CHECK FAIL' $L | head -2 | sed 's/^/    /'
  printf "  samples seen : %s\n" "$(grep 'SENSING_CHECK:' $L | tail -1)"
  # the firmware's own verdict (SENSING_CHECK lines excluded: that checker is reported above)
  printf "  firmware     : %s\n" "$(grep -v SENSING_CHECK $L | grep -oE 'Test Passed!|PSLVERR_TEST: PASS \(no hang\)|[Tt]est [Ff]ail[^\"]*|FAIL[^\"]*|did not acquire' | head -1)"
  printf "  time         : %s\n" "$(grep -oE 'Time used: CPU = [0-9.]+ s, elapsed = [0-9.]+ s' $L | head -1)"
}

if [ "${NEG:-0}" = 1 ] && [ -n "$XSRC" ]; then
  # same netlist, renamed sar_afe_core, under a wrapper that swaps outp/outn
  NET=$(sed -n 's/^include "\$ACCELERATOR_DIR\/AMS\/spice\/\(.*\)"$/\1/p' "$XSRC")
  SRC="$A/AMS/spice/$NET"
  PORTS=$(awk '/^subckt sar_afe /{h=1} h{s=$0; c=(s ~ /\\$/); sub(/\\$/,"",s); l=l" "s; if(!c){print l; exit}}' "$SRC" \
          | sed 's/^ *subckt sar_afe //')
  SWAP=$(for p in $PORTS; do case "$p" in (outp) echo outn;; (outn) echo outp;; (*) echo "$p";; esac; done | paste -sd' ' -)
  { sed -e 's/^subckt sar_afe /subckt sar_afe_core /' -e 's/^ends sar_afe$/ends sar_afe_core/' "$SRC"
    echo "subckt sar_afe $PORTS"
    echo "    Xneg ($SWAP) sar_afe_core"
    echo "ends sar_afe"; } > "$REPO_ROOT/neg_$NET"
  sed "s#\$ACCELERATOR_DIR/AMS/spice/$NET#$REPO_ROOT/neg_$NET#" "$XSRC" > "$REPO_ROOT/neg_amsd.scs"
  echo "##################### NEGATIVE CONTROL ($CFG, outp/outn swapped; expect FAILs) #####################"
  run_one adc_trigger_test "$REPO_ROOT/neg_amsd.scs" "neg_$CFG"
fi

for T in $TESTS; do
  echo "##################### $CFG: $T #####################"
  run_one "$T" "$XSRC" "$CFG"
done
echo "SUITE_DONE"
