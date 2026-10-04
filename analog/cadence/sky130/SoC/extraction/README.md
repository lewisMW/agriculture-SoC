# MOM-cap parasitic extraction (`extract_cap.sh`)

One-command capacitance extraction for the sky130_cw_ip custom MOM caps,
using the Cadence sky130 port's **Pegasus** (`-ext`) + **Quantus QRC** decks.
No schematic or source netlist is needed — it extracts straight from GDS.

## Usage

```bash
./extract_cap.sh <CELL> [--gnd NET] [--gds FILE] [--dp N]
```

| Example | What you get |
|---|---|
| `./extract_cap.sh sarcta__C0`        | single trim unit cap |
| `./extract_cap.sh sarct__trim_array` | full 18-cap trim array (per-cap + total) |
| `./extract_cap.sh dacca__unitcap`    | DAC unit cap |

Results print to the terminal and land in `runs/<CELL>/` next to the script
(gitignored; `<CELL>.qrc.sp` is the extracted netlist; `pegasus_ext.log`,
`quantus.log` are the tool logs). The source layout `mom_caps.gds` is bundled
here, so the flow is self-contained. Override the output root with `RUNROOT=...`,
the input GDS with `GDS=...`, or the Cadence port dir with `PORT_PDK=...` (the
script deliberately does **not** read `$PDK`, since the xschem flow exports
`PDK=sky130A`, a different thing).

## How it works

1. **`label_plates.py`** (KLayout) tags the two largest disjoint met2 plates
   of every *leaf* cap cell with `PLUS`/`MINUS` text on layer **69:5** (the
   met2 label layer the LVS deck reads as a port), and reports whether the
   requested cell is a `leaf` (single cap) or `hier` (array of instances).
2. **`pegasus -ext -f`** extracts connectivity flat, with `text_depth -all`
   (so the in-cell plate labels are read through the hierarchy) and
   `-rc_data` to emit the Quantus input.
3. **`quantus`** runs a `c_only_coupled` extraction, grounding a reference
   plate, and writes the SPICE netlist.
4. The script parses it into a **count / total / mean / min / max** summary.

## Reference (ground) net

Chosen automatically, override with `--gnd`:

- **leaf** cell &rarr; `MINUS` &mdash; prints the single `PLUS`&ndash;`MINUS` device cap.
- **array** cell &rarr; `PLUS` &mdash; the tiled top plates merge into one common
  net; each bottom plate stays separate, so you get **one cap per unit cell**
  (bottom&rarr;top) plus the adjacent bottom-to-bottom coupling caps.

## Reference results (2026-07-18, `typical` corner)

| Cell | Result |
|---|---|
| `sarcta__C0` (isolated) | **1.61 fF** |
| `sarct__trim_array` (in-context) | **~1.10 fF/cap** (16 interior 1.099, 2 edge 1.125); total ~19.84 fF; bottom-bottom coupling ~0.037 fF |

**Use the in-context array value (~1.10 fF), not the isolated one (1.61 fF)** —
in the array each cap's fringe terminates on neighbouring bottom plates, which
lowers the plate-to-plate cap ~32%. Design intent in `trimcap.sch` is 1.25 fF.

## Caveats

- This is a **standalone** extraction (no surrounding block, no substrate
  plane/shield beyond the cell). Good for characterising the cells; the value
  inside the full chip may shift further.
- Extraction is the rule-based `typical` corner, not a full 3-D field solve.
- For arrays whose topology is **not** "one common top + independent bottoms"
  (e.g. the DAC `sard__carray`, which also has via stacks), the auto-picked
  `PLUS` ground may not be meaningful — inspect `<CELL>.qrc.sp` directly and/or
  pass an explicit `--gnd`.
- Needs a `capacitance -ground_net` that exists; an isolated all-metal cell has
  no substrate ground, which is why one plate is used as the reference.
