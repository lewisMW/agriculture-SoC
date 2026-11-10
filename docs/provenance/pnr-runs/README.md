# sky130 P&R run provenance (Aug–Sep 2026)

Summary reports from the sequence of runs that took the sky130 NanoSoC flow from
failing badly to closing timing. Kept because every before/after figure quoted in
`docs/tapeout-plan-status.md`, `docs/synthesis-reproducibility-fixes.md`, the
tapeout report and the commit messages on `sky130-flow-fixes` comes from one of
these runs — and only run G is reproducible from the repo.

Only the summary files are kept (`qor_*`, `timing_summary_*`, `syn_*`, `power_*`).
The per-path timing dumps and DRC listings were several MB each and are not kept.

**Every run used identical synthesis** — 21,192 instances, 4,262,163.844 µm² —
except run D, which was retargeted to 25 MHz. So the comparisons are clean: one
variable at a time.

| Run | Change from previous | Post-route setup WNS | DRC |
|---|---|---|---|
| `A-baseline` | stock flow as inherited | −24.127 ns | — |
| `B-nouniform` | `place_global_uniform_density false` | −10.063 ns | — |
| `C-30ns` | + post-route setup pass in `4_pnr_route.tcl` | −3.913 ns | 252,529 |
| `D-25mhz` | retargeted to 25 MHz (40 ns) — **made it worse** | −14.259 ns | 434,496 |
| `E-mcpfix` | + `set_multicycle_path` `-setup`/`-hold` qualifiers | −0.146 ns | 952 |
| `F-layerfix` | + routing restricted to met1–met5 (li1 excluded) | −0.021 ns | 120 |
| `G-gnc` | + `connect_global_net` real pin names | **+0.169 ns** | 122 |
| `H-blockages` | + route blockages over macros — **made it worse** | +0.110 ns | 128 |

**Run G is the reference result**: setup WNS +0.169 ns, TNS 0.000, zero failing
endpoints, hold MET (+0.109 ns), 23,098 instances, 3,467,594 µm², 122 DRC.
Reproduce it with `ASIC_ours/Cadence/scripts/run_flow.sh` from branch
`sky130-flow-fixes`. The database is preserved read-only on the build machine at
`~lewis/pr112-repro/ASIC_ours/Cadence/scripts/nanosoc_chip_pads_runG_final`.

## What the individual runs are evidence for

- **A → B** — forced uniform placement density was scattering ~21k cells across a
  10.3 mm² pad-limited core at 3.3% density. Turning it off cut wirelength 29%,
  clock-net wirelength 25%, and *improved* routing congestion.
- **B → C** — the flow ran `opt_design -post_route -hold` with no setup repair
  anywhere, so hold optimisation loaded setup-critical paths with delay buffers
  unopposed (−10.1 → −52.9 ns and 237k DRCs before the setup pass was added).
- **C → D** — relaxing the clock to 25 MHz produced a *slower* chip: 18.4 MHz
  achieved versus 29.5 MHz at the 33.3 MHz target. The extra slack was spent on
  21,000 more hold buffers, which congested routing. Constrain tight, ship slow.
- **C → E** — eight `set_multicycle_path` statements lacked `-setup`/`-hold`, so
  the multiplier also moved the hold capture edge a full cycle later, producing
  fictional −35 ns hold violations. Fixing them took hold-buffer insertion from
  **29,889 cells to zero** and is the single largest improvement in the sequence.
- **E → F** — li1 is `TYPE ROUTING` in the sky130 tech LEF but is intra-cell local
  interconnect; all 437 hd macros obstruct it. Excluding it took DRC 952 → 120.
- **F → G** — `connect_global_net` matched on pin names `VDD`/`VSS`, which no cell
  in the design has (they use `VPWR`/`VGND`/`VPB`/`VNB`, and the SRAM `vccd1`/
  `vssd1`). Fixing it closed timing. It did **not** reduce DRC.
- **G → H** — route blockages over the SRAM macros were tried against the
  remaining 122 violations and made both DRC and timing marginally worse. Kept as
  a record of a fix that does *not* work.

## The remaining 122 DRC violations

Unexplained. All 122 are at the four SRAM macros (65 `imem_0`, 49 `dmem_0`,
8 `expram_h`, 0 `expram_l`), on met1–met4 — the layers those macros obstruct —
and 112 involve `Regular Wire` of nets VSS/VDD, i.e. power nets carried as
ordinary routing. Ruled out by direct checking: floorplan spread, LEF pin/
obstruction inconsistency, global-net pin names, missing route blockages, and the
macro's obstruction overlapping its own pins. The live lead is that the power
stripes drop stacked vias (M5→M1) through the macros' obstructed layers — 42 of
the met4 violations are identical 1.18 × 1.18 µm squares, which looks like a via
landing pad. **This needs looking at in the Innovus GUI, not further inference
from report text.**
