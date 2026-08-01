#!/bin/bash
# -----------------------------------------------------------------------------
# run_wrapper_ams.sh
#
# Wrapper-level mixed-signal simulation: the real APB sensing wrapper
# (adc_apb_wrapper_rev2) driven by its APB testbench, with the behavioural
# Verilog-AMS SAR ADC swapped in for dummy_adc (via -define SAR_AMS).
#
# Digital: wrapper + sampling FSM + FIFO + RTC (Arm PL031)  -> Xcelium
# Analog : SAR (CDAC / comparator / caps / switches)        -> Spectre
#
# Requires: Xcelium + Spectre (see analog/cadence/bashrc), ARM_IP_LIBRARY_PATH.
# Usage:    ./run_wrapper_ams.sh [extra xrun args]
# -----------------------------------------------------------------------------
set -e

REPO="${REPO:-$HOME/agriculture-SoC}"
ARM_IP="${ARM_IP_LIBRARY_PATH:-/opt/arm}"
CL="$AMSHOME/tools.lnx86/affirma_ams/etc/connect_lib"

ANA="$REPO/analog/cadence/notech/SoC"
SOC="$REPO/agriculture_soc_main"
RTC_IP="$ARM_IP/PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source"

BUILD="${BUILD:-$HOME/wrapper_ams_build}"
mkdir -p "$BUILD"
cd "$BUILD"

# xrun keys file type off the extension and does not recognise .va, so expose
# the Verilog-A cells as .vams.
ln -sf "$ANA/adc_primitives_lib/capacitor_adc/veriloga/veriloga.va" capacitor_adc.vams
ln -sf "$ANA/adc_primitives_lib/inverter/veriloga/veriloga.va"      inverter.vams
ln -sf "$ANA/adc_analog_lib/cap_array_8b/veriloga/veriloga.va"      cap_array_8b.vams

# Analog control file: transient analysis for the Spectre side.
cat > acf.scs <<'EOF'
simulator lang=spectre
tran1 tran start=0 stop=300u method=trap
EOF

xrun -64bit -ams -clean -timescale 1ns/1ps \
  -discipline logic \
  -amsconnrules ConnRules_18V_full_fast \
  -analogcontrol acf.scs \
  -define SAR_AMS \
  "$CL/ConnRules18.vams" \
  `# ---- analog: SAR hierarchy (bottom-up) ----` \
  "$ANA/adc_digital_lib/sarlogic/functional/verilog.v" \
  "$ANA/adc_digital_lib/sr_latch/functional/verilog.v" \
  capacitor_adc.vams inverter.vams cap_array_8b.vams \
  "$ANA/adc_analog_lib/switch_adc/verilogams/verilog.vams" \
  "$ANA/adc_analog_lib/comparator/verilogams/verilog.vams" \
  "$ANA/adc_top_lib/cdac_8b/verilogams/verilog.vams" \
  "$ANA/adc_top_lib/sar/verilogams/verilog.vams" \
  "$SOC/AMS/sar_ams_shim.vams" \
  `# ---- digital: wrapper, FSM, FIFO, RTC, testbench ----` \
  "$SOC/Wrapper/adc_apb_wrapper_rev2.v" \
  "$SOC/Wrapper/adc_apb_wrapper_rev2_tb.v" \
  "$SOC/FSM/wrapper_control_2.v" \
  "$SOC/FIFO/fifo_apb_adc.v" \
  "$SOC/Dummy/dummy_amux.v" \
  "$SOC/Dummy/dummy_pll.v" \
  "$SOC/RTC/rtc_control_2.v" \
  `# RtcParams.v is include-only (no module) - reached via -incdir, not compiled` \
  $(find "$RTC_IP" -name '*.v' ! -name 'RtcParams.v') \
  -incdir "$RTC_IP" \
  -top adc_apb_wrapper_rev2_tb \
  -access +rwc "$@"