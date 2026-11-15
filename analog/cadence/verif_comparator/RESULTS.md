# Comparator verification results

Testbench: `sar_adc/tb_comparator_parasitic/maestro`, built by `tbcmp_setup.il` (see `README.md`).

## Latest Maestro run (2026-11-16, ExplorerRun.0)

Test `Basic_op`, schematic view, tt, 27 °C. Alternating ±vd input, `pol = +1` (SAR convention), 8 cycles.

| vd | dec_pos (spec > 0.5) | dec_neg (spec < −0.5) | n_correct | n_wrong | n_unres |
|---|---|---|---|---|---|
| 5 mV   | −1 ✗ | +1 ✗ | 0 | 7 | 0 |
| 20 mV  | −1 ✗ | +1 ✗ | 0 | 7 | 0 |
| 100 mV | −1 ✗ | +1 ✗ | 0 | 7 | 0 |

Every decision resolves (n_unres = 0), but every decision has the wrong sign.

### What this means: output polarity is inverted on the schematic

`ADC/sar_comp_latch.v` and `ADC/sim/sar_afe_model.v` expect **outn to fall when vinp > vinn**
(`q = NAND(outn, qn)` gives comp = 1, and `sarlogic` keeps the bit). The comparator schematic
makes **outp** fall instead, so the SAR would read every bit inverted. With an inverted
comparator the SAR search runs to one end of the range, so the code sticks at 0 or 255.

Earlier runs recorded in `README.md` show `Basic_op` **passing on the extracted view**
(`config_pex` → `av_extracted`). The schematic and the layout disagree on polarity, which LVS
should catch. To do:

1. Swap the outp/outn pin labels (or the input pair) in the schematic to match the layout and the SAR convention.
2. Rerun LVS.
3. Rerun `Basic_op` on `schematic` and `config_pex`. Both should pass.
4. Change the default `pol` in `tbcmp_setup.il` from −1 to +1 and rebuild with `tbcmpSetup()`.

## Earlier results (from batch runs recorded in README.md)

Schematic, tt, 27 °C, with `pol = −1` unless noted.

| Test | Result | Spec |
|---|---|---|
| Reset_op | outp, outn, net2, net3 all reach 1.0·vcc | > 0.95 / 0.9 |
| Off_set | Vos = −125 µV | ±5 mV |
| Decision_delay | t_cq = 0.75–2.7 ns over vd = 300 mV … 1 mV | t_cq_frac < 1 |
| Common_mode | No decisions at vcm ≤ 0.5 V | — |
| Kickback | 20 µV differential at ccdac = 9.3 pF | < 3.5 mV |
| Power_energy | 160–180 fJ/cycle (PEX: 210–230 fJ) | — |
| History_dep | dVth = 0 at 0.25 mV resolution | ±1 mV |
| MC_mismatch | σ(Vos) = 8.9 mV (40 samples, standalone Spectre) | — |

Not run yet: Input_ref_noise, Metastability, Clk_* sweeps, Output_compat, PVT, Trim_a/Trim_b, 200-point MC.

## Open issues

1. Output polarity inverted on the schematic (above).
2. No decisions at vcm ≤ 0.5 V.
3. σ(Vos) ≈ 8.9 mV is larger than 1 LSB (≈ 7 mV), so the trim range needs to cover about ±27 mV.
