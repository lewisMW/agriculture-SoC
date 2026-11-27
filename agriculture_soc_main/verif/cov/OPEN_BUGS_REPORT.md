# Open suspected RTL bugs - sensing SoC verification

Generated 2026-11-22 18:01 by `verif/signoff.py` (mode full). Each bug below fails the checks listed and is waiting on the owner named under it to confirm and fix it. Source of this list: `agriculture_soc_main/verif/cov/open_bugs.txt`.

## ADC-CAL - Offset calibration has the wrong polarity and always ends on a trim rail

- **Owner:** analog team (sarlogic)
- **Where:** `analog/cadence/sar_adc/sarlogic/functional/verilog.v:120-145`
- **Found:** 2026-11-15, sar_adc_cal_tb ADC-2
- **Status in this run:** 80 failing checks
- **Reproduce:** `make -C agriculture_soc_main/ADC cal`

In sCal each trial trim bit is kept when the comparator read 0 in the majority of its 7 samples (verilog.v:126-127). With the sar_afe model a kept bit moves the comparator offset further in the direction that made it read 0, so the loop runs away: every calibration finishes at trim 0 or 31 and leaves the offset worse than before (0 mV -> -155 mV, +10 mV -> +165 mV, -40 mV -> -195 mV). The vote/mask logic itself is correct (the scripted-vote cases ADC-2b pass and reach every final-trim bin); the sense of the keep decision (or of trima/trimb) is inverted relative to the AFE. Either the keep condition should be cal_count <= 7, or trima/trimb swap. Please confirm against the real AFE netlist before changing it.

**Expected:** for an offset inside the trim range the final trim is the one predicted from VTRIM_LSB and a 0 V input then reads mid-scale +-1 LSB

Failing checks:

```
adc_cal: FAIL [209281000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: final trim 31 = trim predicted from VTRIM_LSB 15 (offset left -155 mV)
adc_cal: FAIL [212401000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_cal: FAIL [268051000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: final trim 0 = trim predicted from VTRIM_LSB 16 (offset left 165 mV)
adc_cal: FAIL [271171000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8b)
adc_cal: FAIL [326821000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: final trim 31 = trim predicted from VTRIM_LSB 14 (offset left -165 mV)
adc_cal: FAIL [329941000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_cal: FAIL [385591000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: final trim 0 = trim predicted from VTRIM_LSB 19 (offset left 195 mV)
adc_cal: FAIL [388711000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8d)
adc_cal: FAIL [444361000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: final trim 31 = trim predicted from VTRIM_LSB 11 (offset left -195 mV)
adc_cal: FAIL [447481000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x72)
adc_cal: FAIL [503131000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: final trim 0 = trim predicted from VTRIM_LSB 22 (offset left 230 mV)
adc_cal: FAIL [506251000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x90)
adc_cal: FAIL [561901000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: final trim 31 = trim predicted from VTRIM_LSB 7 (offset left -230 mV)
adc_cal: FAIL [565021000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6f)
adc_cal: FAIL [620671000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: final trim 0 = trim predicted from VTRIM_LSB 27 (offset left 275 mV)
adc_cal: FAIL [623791000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x93)
adc_cal: FAIL [679441000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: final trim 31 = trim predicted from VTRIM_LSB 3 (offset left -275 mV)
adc_cal: FAIL [682561000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6c)
adc_cal: FAIL [738211000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 200 mV: final trim 0 = trim predicted from VTRIM_LSB 31 (offset left 355 mV)
adc_cal: FAIL [796981000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -200 mV: final trim 31 = trim predicted from VTRIM_LSB 0 (offset left -355 mV)
adc_div: FAIL [52501000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: final trim 31 = trim predicted from VTRIM_LSB 15 (offset left -155 mV)
adc_div: FAIL [53281000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_div: FAIL [67261000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: final trim 0 = trim predicted from VTRIM_LSB 16 (offset left 165 mV)
adc_div: FAIL [68041000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8b)
adc_div: FAIL [82021000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: final trim 31 = trim predicted from VTRIM_LSB 14 (offset left -165 mV)
adc_div: FAIL [82801000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_div: FAIL [96781000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: final trim 0 = trim predicted from VTRIM_LSB 19 (offset left 195 mV)
adc_div: FAIL [97561000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8d)
adc_div: FAIL [111541000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: final trim 31 = trim predicted from VTRIM_LSB 11 (offset left -195 mV)
adc_div: FAIL [112321000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x72)
adc_div: FAIL [126301000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: final trim 0 = trim predicted from VTRIM_LSB 22 (offset left 230 mV)
adc_div: FAIL [127081000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x90)
adc_div: FAIL [141061000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: final trim 31 = trim predicted from VTRIM_LSB 7 (offset left -230 mV)
adc_div: FAIL [141841000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6f)
adc_div: FAIL [155821000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: final trim 0 = trim predicted from VTRIM_LSB 27 (offset left 275 mV)
adc_div: FAIL [156601000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x93)
adc_div: FAIL [170581000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: final trim 31 = trim predicted from VTRIM_LSB 3 (offset left -275 mV)
adc_div: FAIL [171361000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6c)
adc_div: FAIL [185341000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 200 mV: final trim 0 = trim predicted from VTRIM_LSB 31 (offset left 355 mV)
adc_div: FAIL [200101000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -200 mV: final trim 31 = trim predicted from VTRIM_LSB 0 (offset left -355 mV)
adc_div: FAIL [104761000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: final trim 31 = trim predicted from VTRIM_LSB 15 (offset left -155 mV)
adc_div: FAIL [106321000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 0 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_div: FAIL [134191000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: final trim 0 = trim predicted from VTRIM_LSB 16 (offset left 165 mV)
adc_div: FAIL [135751000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8b)
adc_div: FAIL [163621000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: final trim 31 = trim predicted from VTRIM_LSB 14 (offset left -165 mV)
adc_div: FAIL [165181000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -10 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x74)
adc_div: FAIL [193051000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: final trim 0 = trim predicted from VTRIM_LSB 19 (offset left 195 mV)
adc_div: FAIL [194611000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x8d)
adc_div: FAIL [222481000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: final trim 31 = trim predicted from VTRIM_LSB 11 (offset left -195 mV)
adc_div: FAIL [224041000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -40 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x72)
adc_div: FAIL [251911000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: final trim 0 = trim predicted from VTRIM_LSB 22 (offset left 230 mV)
adc_div: FAIL [253471000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x90)
adc_div: FAIL [281341000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: final trim 31 = trim predicted from VTRIM_LSB 7 (offset left -230 mV)
adc_div: FAIL [282901000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -75 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6f)
adc_div: FAIL [310771000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: final trim 0 = trim predicted from VTRIM_LSB 27 (offset left 275 mV)
adc_div: FAIL [312331000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x93)
adc_div: FAIL [340201000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: final trim 31 = trim predicted from VTRIM_LSB 3 (offset left -275 mV)
adc_div: FAIL [341761000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -120 mV: after calibration a 0 V input reads within 1 LSB of mid-scale (0x6c)
adc_div: FAIL [369631000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos 200 mV: final trim 0 = trim predicted from VTRIM_LSB 31 (offset left 355 mV)
adc_div: FAIL [399061000] [SUSPECTED RTL BUG ADC-CAL] ADC-2 vos -200 mV: final trim 31 = trim predicted from VTRIM_LSB 0 (offset left -355 mV)
... 20 more
```

## ADC-CLKC - clkc stays high through a reset asserted in the low half of sar_clk (sim/synthesis mismatch)

- **Owner:** analog team (sarlogic)
- **Where:** `analog/cadence/sar_adc/sarlogic/functional/verilog.v:63-65`
- **Found:** 2026-11-15, sar_adc_cal_tb ADC-4
- **Status in this run:** 12 failing checks
- **Reproduce:** `make -C agriculture_soc_main/ADC cal`

`always @(clk) clkc <= ~clk & en_co_clk;` is only sensitive to clk. When rstn falls while sar_clk is low, en_co_clk goes to 0 but the block does not re-evaluate, so in RTL simulation clkc stays 1 until sar_clk next toggles (after the reset is released). Synthesis builds the AND gate, so the netlist drops clkc at once: RTL and gates disagree. Fix: make it combinational on both inputs, e.g. `assign clkc = ~clk & en_co_clk;` or `always @*`.

**Expected:** clkc is 0 whenever en_co_clk is 0 (including in reset)

Failing checks:

```
adc_cal: FAIL [2222413000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sSample, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_cal: FAIL [2227273000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sConv, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_cal: FAIL [2238193000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sCal, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [565513000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sSample, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [566773000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sConv, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [569593000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sCal, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [1117813000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sSample, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [1120273000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sConv, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [1125793000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sCal, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [4431613000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sSample, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [4441273000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sConv, sar_clk low: clkc low in reset (en_co_clk is 0)
adc_div: FAIL [4462993000] [SUSPECTED RTL BUG ADC-CLKC] ADC-4 reset in sCal, sar_clk low: clkc low in reset (en_co_clk is 0)
```

