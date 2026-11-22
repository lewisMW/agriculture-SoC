# Sensing peripheral verification

This directory holds the sign-off flow for the sensing peripheral: the RTC
controller (`RTC/rtc_control_2.v`), the sampling FSM (`FSM/wrapper_control_2.v`),
the sample FIFO (`FIFO/fifo_apb_adc.v`) and the APB wrapper that ties them to
the SAR ADC (`Wrapper/adc_apb_wrapper_rev2.v`). The same RTL is used by the
standalone SoC in `agriculture_soc_main/` and by the NanoSoC integration in
`nanosoc/system/src/accelerator_subsystem.v`.

## Design decisions the checks rely on

1. **The RTC polls autonomously.** `rtc_control_2` arms a PL031 alarm every
   `rtc_alarm_offset` seconds and triggers one ADC conversion per alarm.
   Firmware can also force a one-shot trigger.
2. **A firmware RTC access that collides with an autonomous arm cycle is
   stalled, never errored.** The wrapper holds `PREADY` low (13 PCLK at most)
   instead of signalling `PSLVERR`. On the Cortex-M0, `PSLVERR` becomes a
   HardFault that firmware cannot retry from.
3. **The RTC counter resets from `nPOR`, not `PRESETn`**, so RTC time survives
   a warm reset in the standalone SoC.
4. **Samples are 8 bits**, as produced by the SAR ADC, zero-extended on read.
5. **Firmware cannot stop the RTC counter.** The wrapper forces bit 0 of every
   firmware RTCCR write to 1 (FIX-3 below); polling is paused with `RTC_CTRL`
   instead.

The register map is defined in `Wrapper/adc_apb_wrapper_rev2.v` and
`nanosoc/system/testcodes/sensing_ip.h`.

## Running it

From `agriculture_soc_main/`:

```bash
make verify-free             # benches that need no ARM IP (FIFO, FSM, ADC, FIFO UVM)
make verify                  # every bench
make signoff                 # every bench + lint + SVA mutation + coverage gates
OPEN_BUGS_OK=1 make signoff  # exit 0 if the only failures are known open bugs
python3 verif/signoff.py --list           # the steps
python3 verif/signoff.py --only gap,clo   # a subset
```

Most steps need the licensed ARM IP (Cortex-M0, CMSDK, PL031), found through
`ARM_IP_LIBRARY_PATH`. With `STUB_RTC=1` the RTC steps run against a
behavioural PL031 stand-in instead; that verdict is marked STUB and does not
count for sign-off. `BUILD_ROOT=<dir>` puts build directories on a local disk.
Builds are single-core by design (`verif/verilator_1core.mk`).

Each run writes `verif/cov/SIGNOFF_REPORT.txt` and
[`verif/cov/OPEN_BUGS_REPORT.md`](cov/OPEN_BUGS_REPORT.md).

## What fails a run

- any bench that exits non-zero or prints `N FAILED` with N > 0
- a bench that does not print all of its expected summary lines (an SVA
  failure stops the simulation before the summary)
- an assertion failure or `%Error` in a log
- a functional coverage bin that is neither hit nor waived, any `viol_*`
  (must-never-happen) bin that is hit, or a code coverage hole
- lint warnings that are not waived in [`cov/waivers.txt`](cov/waivers.txt)
- an SVA assertion that a deliberate mutation of the RTL does not trip

Checks that fail because of a suspected bug in RTL owned by another team are
tagged `[SUSPECTED RTL BUG <ID>]`. They still count as failures. With
`OPEN_BUGS_OK=1` the run exits 0 only if every failure carries an ID listed in
[`cov/open_bugs.txt`](cov/open_bugs.txt).

## Benches

| Step | Bench | Covers |
|---|---|---|
| `fifo_rand` | `FIFO/fifo_apb_adc_rand_tb.v` | FIFO against a reference model, invariants, random traffic |
| `fsm`, `fsm_seq` | `FSM/wrapper_control_2_tb.v`, `FSM/wrapper_control_seq_tb.v` | FSM states and sequencing, FSM-1..5 (trigger in every busy state, stuck ADC, FIFO full, no stale sample after a timeout) |
| `adc`, `adc_cal`, `adc_div` | `ADC/tb/` | SAR ADC digital with a behavioural analog model, ADC-1..5, clock dividers 1/2/4/8 |
| `uvm_fifo`, `uvm_sensing` | `verif/uvm/` | UVM benches for the FIFO and the whole peripheral |
| `rtc`, `rtc_rand`, `rtc_clo` | `RTC/` | RTC controller: directed, random, and closure tests RTC-1..14 |
| `wrap`, `wrap_rand`, `wrap_sva` | `Wrapper/` | wrapper directed and constrained-random traffic, with bound SVA |
| `gap`, `params` | `Wrapper/sens_gap_tb.sv` | APB4 protocol, byte strobes, register map, reset behaviour; `params` reruns it at other parameter values |
| `clo`, `adcdiv` | `Wrapper/sens_closure_tb.sv` | WRP-1..5 and ADC-6 at wrapper level; `adcdiv` repeats ADC-6 at ADC clock dividers 1, 2, 8 and 255 (the slowest clock the conversion timeout is sized for) |
| `soak` | `Wrapper/sens_soak_tb.sv` | WRP-6: 2000+ sample periods per seed under random firmware traffic |
| `rob` | `Wrapper/sens_rob_tb.sv` | ROB-1: recovery from illegal FSM states |
| `xsafe` | `Wrapper/` (directed bench, random initial values) | ROB-2: no X propagation from uninitialised registers, 5 seeds |
| `soc_check`, `soc_reset` | `agriculture_soc_checked_tb.v`, `agriculture_soc_reset_rand_tb.v` | full standalone SoC, including random reset timing |

At chip level, the NanoSoC firmware tests in `nanosoc/system/testcodes/`
(`sensing_*_test`, FW-1..6, and the earlier `adc_*`, `fifo_drain`, `rtc_time`,
`pslverr`, `fault_recovery` tests) and the debug-port (ADP) bus tests in
`nanosoc/system/verif/cov/adp_tests/` exercise the peripheral through the
Cortex-M0 and the AHB bus.

## Current results

Full sign-off with the real ARM PL031, 2026-11-16, on the tree that includes
FIX-1 to FIX-4. RTC-NPOR-2, FSM-STALE-2 and TMO-DIV came later and are signed
off on the PL031 stand-in only, so these numbers need a re-run with the real
PL031:

| Gate | Result |
|---|---|
| All benches | pass, apart from the two open ADC bugs below |
| Functional coverage | 656 / 656 goal bins, no `viol_*` bin hit |
| Code coverage | 100 % line and branch on the peripheral RTL (waivers in `cov/waivers.txt`) |
| SVA mutation | 48 / 48 assertions shown to fail on a deliberate RTL mutation |
| Lint | clean apart from waived warnings |
| NanoSoC ADP bus tests | 762 passed, 0 failed |
| NanoSoC firmware tests | 13 / 13 pass |

## RTL fixes made during verification

Each fix has a regression test that failed before the fix.

| ID | File | Problem fixed |
|---|---|---|
| RTC-NPOR | `rtc_control_2.v` | after a power-on reset without a bus reset the RTC counter stayed stopped |
| FSM-STALE | `wrapper_control_2.v` | a trigger soon after a sample could store the result of a conversion that started before the trigger |
| RTC-RSTREL | `rtc_control_2.v` | a firmware RTC access could lose its bus grant when the RTC reset was released mid-transfer |
| FIX-1 | `rtc_control_2.v` | a new `rtc_alarm_offset` only applied after the current, possibly very long, period ended; it now re-arms immediately |
| FIX-2 | `wrapper_control_2.v` | the FSM waited forever for a dead ADC; it now times out and sets `status[6]` |
| FIX-3 | `adc_apb_wrapper_rev2.v` | firmware could stop the RTC counter by writing 0 to RTCCR, silently stopping sampling |
| FIX-4 | `rtc_control_2.v` | a warm reset just after an alarm could produce a duplicate sample |
| RTC-NPOR-2 | `rtc_control_2.v` | after a power-on reset of the RTC alone (`nPOR` without `PRESETn`), any alarm-register write before the next idle (a FIX-1 offset re-arm, an arm already in progress, a watchdog service) left the counter stopped for good; with a long offset it stayed stopped for the whole period. The enable flag is now reset by `nPOR` only, and the controller re-enables as soon as the counter reset releases (RTC-14) |
| FSM-STALE-2 | `wrapper_control_2.v` | after a FIX-2 timeout of a slow (not dead) ADC, the next trigger could store the result of the conversion that was still running (FSM-5) |
| TMO-DIV | `adc_apb_wrapper_rev2.v` | the FIX-2 timeout was sized for the default ADC clock, so a slower ADC clock (a programmable divider) would time out every conversion; it is now sized for the slowest divider, `ADC_CLK_DIV_MAX` = 255 (85680 PCLK) |

FIX-1 to FIX-4 are pending confirmation by the rest of the team. RTC-NPOR-2
and FSM-STALE-2 correct FIX-4 and FIX-2.

## Open issues

- **Two suspected bugs in the SAR ADC controller** (`sarlogic`, owned by the
  analog team): ADC-CAL (offset calibration ends on a trim limit) and
  ADC-CLKC (`clkc` can stay high through a reset in RTL simulation, unlike
  the synthesised gates). Details and reproduction steps are in
  [`cov/OPEN_BUGS_REPORT.md`](cov/OPEN_BUGS_REPORT.md).
- **Not covered here:** clock-domain-crossing analysis, gate-level simulation
  of this flow's netlist, the analog behaviour of the real ADC (needs
  mixed-signal simulation), and hardware runs. The CPU interrupt from the
  peripheral is being added on a separate branch and is not yet part of these
  checks.
