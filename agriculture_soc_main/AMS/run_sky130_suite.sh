#!/bin/bash
# 1) negative test: prove SENSING_CHECK catches the known-broken comparator
#    polarity (un-cross outp/outn -> codes rail at 0x00)
# 2) run all 6 firmware tests in the full sky130 analog config with checks on
set -u
cd ~/agriculture-SoC/nanosoc
export SOCLABS_PROJECT_DIR=$PWD ARM_IP_LIBRARY_PATH=/opt/arm
source env/dependency_env.sh
A=$ACCELERATOR_DIR

# ---- build a deliberately-broken variant (polarity un-crossed) ----
sed 's/Xcmp (outn outp/Xcmp (outp outn/' "$A/AMS/spice/sky130_cells.scs" > /tmp/badpol_cells.scs
sed "s#include \"\$ACCELERATOR_DIR/AMS/spice/sky130_cells.scs\"#include \"/tmp/badpol_cells.scs\"#" \
    "$A/AMS/amsd_sky130_all.scs" > /tmp/amsd_badpol.scs
echo "### negative control: comparator polarity un-crossed (expect FAILs) ###"
timeout 2400 make -C nanosoc_tech run_xr TESTNAME=adc_trigger_test ACCELERATOR=yes \
    TOOL_CHAIN=gcc SAR_AMS_INCLUDE=yes XRUN_EXTRA_SRC=/tmp/amsd_badpol.scs \
    AMS_ACF="$A/AMS/acf_sky130.scs" EXTRA_DEFINES=+define+SENSING_CHECK \
    > /tmp/neg.log 2>&1
L=~/agriculture-SoC/nanosoc/simulate/sim/adc_trigger_test/logs/run_adc_trigger_test.log
printf "  SENSING_CHECK FAIL lines : %s\n" "$(grep -c 'SENSING_CHECK FAIL' $L)"
grep 'SENSING_CHECK FAIL' $L | head -3 | sed 's/^/    /'
printf "  firmware verdict         : %s\n" "$(grep -oE 'Test Passed!|did not acquire' $L | head -1)"

# ---- the real suite ----
for T in adc_trigger_test adc_autonomous_test fifo_drain_test rtc_time_test pslverr_test sensing_driver_test; do
  echo "##################### $T #####################"
  timeout 2400 make -C nanosoc_tech run_xr TESTNAME=$T ACCELERATOR=yes TOOL_CHAIN=gcc \
      SAR_AMS_INCLUDE=yes XRUN_EXTRA_SRC="$A/AMS/amsd_sky130_all.scs" \
      AMS_ACF="$A/AMS/acf_sky130.scs" EXTRA_DEFINES=+define+SENSING_CHECK \
      > /tmp/sky_$T.log 2>&1
  L=~/agriculture-SoC/nanosoc/simulate/sim/$T/logs/run_$T.log
  printf "  spectre      : %s\n" "$(grep -oE 'spectre completes with [0-9]+ errors, [0-9]+ warnings' $L | head -1)"
  printf "  xrun errors  : %s\n" "$(grep -cE '\*E,' $L)"
  printf "  CHECK fails  : %s\n" "$(grep -c 'SENSING_CHECK FAIL' $L)"
  grep 'SENSING_CHECK FAIL' $L | head -2 | sed 's/^/    /'
  printf "  samples seen : %s\n" "$(grep 'SENSING_CHECK:' $L | tail -1)"
  printf "  firmware     : %s\n" "$(grep -oE 'Test Passed!|PSLVERR_TEST: PASS \(no hang\)|FAIL[^\"]*|did not acquire' $L | head -1)"
  printf "  time         : %s\n" "$(grep -oE 'Time used: CPU = [0-9.]+ s, elapsed = [0-9.]+ s' $L | head -1)"
done
echo "SUITE_DONE"
