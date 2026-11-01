#!/usr/bin/env bash
# =====================================================================
# lvs_deck.sh -- print the sky130 Pegasus LVS deck with our fixes applied.
#
# The deck itself is not committed: it is generated from the PDK copy at
# $SKY130/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl, and every edit below is checked
# so a PDK update that moves the text fails loudly instead of silently.
#
#   ./lvs_deck.sh > deck.pvl         # patched deck
#   LVS_DECK_RAW=1 ./lvs_deck.sh     # unpatched PDK deck (for comparison)
# =====================================================================
set -euo pipefail

SKY130="${SKY130:-/opt/pdk/cadence_SKY130/sky130_release_0.1.0}"
DECK="${SKY130%/}/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl"
[ -f "$DECK" ] || { echo "ERROR: deck not found: $DECK" >&2; exit 2; }

if [ "${LVS_DECK_RAW:-0}" = 1 ]; then cat "$DECK"; exit 0; fi

# fix <description> <sed expression> <grep pattern that must match after>
TMP=$(mktemp); trap 'rm -f "$TMP" "$TMP.n"' EXIT
cp "$DECK" "$TMP"
fix() {
  sed -e "$2" "$TMP" > "$TMP.n"
  if cmp -s "$TMP" "$TMP.n" || ! grep -q -E "$3" "$TMP.n"; then
    echo "ERROR: lvs_deck.sh: fix did not apply: $1" >&2; exit 3
  fi
  mv "$TMP.n" "$TMP"
}

# 1. met2 pins/labels were attached to the wrong layer: the deck has
#    "attach met3_pin met2" (twice-attached met3_pin, met2_pin never
#    attached). Pegasus 24.1 aborts on it; 23.2 ran but met2 pin text
#    could not name a net.
fix "met2_pin attach" \
    's/^attach met3_pin met2[[:space:]]*$/attach met2_pin met2/' \
    '^attach met2_pin met2$'

# 2. MIM cap (cap_mim_m3__base) l/w came from edge layers ("angle capacitor
#    -eq 0/90") passed to the device as auxiliary layers. Pegasus 24.1 dies
#    on any cell containing capm with "Internal error during runset
#    evaluation" -- this is the LVS crash Hee and Jaime hit; 23.2 is fine.
#    Bisected 6 Oct 2026: the edge auxiliary layers alone trigger it.
#    Derive l and w from the polygon instead: l = perimeter/4, w = area/l.
#    Exact for square caps (every MIM cap in the SAR is square). A
#    non-square cap gets l = (w+l)/2 and fails the L/W property check,
#    so it can't pass silently. (SQRT for the general rectangle also
#    crashes 24.1.)
fix "mim cap device aux layers" \
    's/ < cap_width > < cap_length > -element "C" cmacro CAP_PROPERTIES capacitor cap_width cap_length/ -element "C" cmacro CAP_PROPERTIES capacitor/' \
    'cmacro CAP_PROPERTIES capacitor$'
fix "mim cap dmacro signature" \
    's/^dmacro CAP_PROPERTIES dev_shape c_width c_length {/dmacro CAP_PROPERTIES dev_shape {/' \
    '^dmacro CAP_PROPERTIES dev_shape \{'
fix "mim cap l" \
    's/^\([[:space:]]*l[[:space:]]*=[[:space:]]*\)PERIMETER_COINCIDE( dev_shape , c_length )[[:space:]]*$/\1PERIMETER( dev_shape ) \/ 4/' \
    'l[[:space:]]*= PERIMETER\( dev_shape \) / 4'
fix "mim cap w" \
    's/^\([[:space:]]*w[[:space:]]*=[[:space:]]*\)PERIMETER_COINCIDE( dev_shape , c_width ) \/ 2[[:space:]]*$/\1AREA( dev_shape ) \/ l/' \
    'w[[:space:]]*= AREA\( dev_shape \) / l'

# 3. Parallel MIM caps were merged (the Pegasus default) with no rule for
#    their l/w, so after reduction both sides read "<missing>" and every
#    cell with parallel caps (e.g. the bootstrap switch's 4 boost caps)
#    failed with a parameter mismatch. Compare MIM caps one-to-one instead:
#    stricter, since a missing parallel cap is still a count mismatch.
printf '\n// lvs_deck.sh fix 3: compare MIM caps unmerged (keeps their l/w)\nlvs_reduce no -parallel_caps\n' >> "$TMP"

cat "$TMP"
