# sky130_analog_lib — custom capacitor cells (status / WIP)

Hand-drawn capacitor cells for the SAR ADC (comparator **trim** DAC + main
**DAC** array), imported from the `sky130_cw_ip` (cheetah) design.

> **Terminology:** these are **single-layer (met2) lateral-flux / fringe
> capacitors** — *not* foundry MiM caps (no `capm`/`cap2m`), and *not* the
> multi-layer interdigitated VPP structures. "MOM" is loose shorthand; the
> capacitance is lateral edge coupling between two coplanar met2 electrodes.
> Because it is fringe-dominated, the value is **strongly context-dependent**
> (see below) — extract in-context, not in isolation.

## Cells

| Cell | Role | Views | Capacitance |
|---|---|---|---|
| `sarcta__C0` | comparator trim **unit** cap | layout, symbol, schematic | **~1.10 fF in-array** (1.61 fF isolated; design 1.25 fF) |
| `sarct__trim_array` | trim cap array (18 units) | layout, symbol, schematic | total **~19.84 fF**; per-cap ~1.10 fF |
| `dacca__unitcap` | DAC **unit** cap | layout only | design 2.6 fF (not yet QRC-extracted) |
| `sard__carray` | DAC binary array (1032 caps + 1024 vias) | layout only | — |
| `dac_via` | via-stack routing helper for the DAC array | layout only | (not a cap) |

## Extracted values (Quantus QRC, `typical` corner)

- `sarcta__C0`: **1.61 fF isolated** → **~1.10 fF in the array** (fringe
  redistributes onto neighbouring plates → ~32 % drop). **Use the in-context
  value.**
- `sarct__trim_array`: 16 interior caps uniform at **1.099 fF**, 2 edge/dummy
  caps 1.125 fF; adjacent bottom-plate coupling ~0.037 fF (matches the FEM
  `Cpar` caps in the source schematic). Well-matched across the active caps.
- Values are from a **standalone** extraction (no surrounding block/shield);
  full-chip numbers may shift.

## Status

- **Layouts** — all present (GDS stream-in), DRC-clean apart from expected
  standalone-cell metal-density flags.
- **Symbol + schematic** — ✅ done for the trim cells (`sarcta__C0`,
  `sarct__trim_array`); ⛔ **TODO** for the DAC cells (`dacca__unitcap`,
  `sard__carray`) — currently layout-only, so they place in layout but are not
  yet schematic-driven.
- **Schematic model** — each cap = ideal `analogLib` cap (`PLUS`/`MINUS`).
  `sarct__trim_array` schematic = 18× `sarcta__C0` grouped as
  `drain` (common top) + `n4..n0` (binary bottoms) + `vss` (2 dummies).
- **LVS** — bare-met2 caps are non-extractable → must be **black-boxed**
  (the Pegasus LVS deck supports `lvs_black_box` for caps) with met2 plate
  labels on layer **69:5**. Labeling recipe validated; end-to-end LVS not yet run.
- **Open item** — whether the parent top-plate strap is continuous over all 18
  trim caps (dummy tops on `drain`) or stops at 16 (dummies inert) — confirm
  from the `sarc__trim` routing.

## Notes for use

- Instantiate `sarcta__C0` / `sarct__trim_array` **symbol** in a schematic and
  place the matching **layout**. DAC caps are layout-placement only for now.
- Library is registered in `analog/cadence/cds.lib` as `sky130_analog_lib`,
  bound to tech `sky130_fd_pr_main`.
- The trim **switch** cell (`sarc__trim` = these caps + 16 `nfet_01v8_lvt`
  switches) is being assembled separately (native FET rebuild) and is not part
  of this cap library.
