# Comparator verification suite (`sar_adc/tb_comparator_parasitic/maestro`)

## Files

| File | Purpose |
|---|---|
| `tbcmp_stim.va` | Clock (fclk, duty, tr, tf), differential input generator (static / staircase / alternating / history) and Trima/Trimb codes. Replaces schematic instance `I11`. |
| `tbcmp_stim.scs` | Definition file added to every test. Instantiates the stimulus, the source resistance `rs`, the CDAC load `ccdac` on inp/inn, the output load `cload`, and saves `V0:p`. |
| `tbcmp_lib.il` | Per-cycle measurements used in output expressions: `tbcmpDec`, `tbcmp_vos`, `tbcmp_sigma`, `tbcmp_hist`, `tbcmp_count`. |
| `tbcmp_mc.scs` | `statistics { mismatch {...} }` block for sky130 nfet/pfet_01v8. It's added only to `MC_mismatch`. |
| `tbcmp_corners.sdb` | 45 PVT corners: {tt,ff,ss,sf,fs} × vcc {1.62,1.8,1.98} × T {-40,27,125}. |
| `tbcmp_setup.il` | Builds everything: `load(".../tbcmp_setup.il") tbcmpSetup()`. |
| `../.vdsinit` | Loads `tbcmp_lib.il` into Maestro's expression evaluator (`vds` reads `.vdsinit`, not `.cdsinit`). |
| `backup_maestro_sar_adc/` | Copy of `maestro.sdb`, `active.state` and `namedStimuli` from before the change. |

## Timing convention

A high clock means evaluate and a low clock means reset (precharge). The comparator has no separate reset pin, so reset duration is the low time, `(1-duty)/fclk`.

Cycle k rises at `(k+0.5)/fclk` and falls at `(k+0.5+duty)/fclk`. Inputs change only during reset, at 25 % of the low phase. A decision is read `tsu` before the falling edge. In the SAR, `clkc = ~clk`, so the comparator clock falls on the `sarlogic` posedge that samples `comp`.

`pol` is the polarity used for counting: +1 means `inp > inn` gives `outp` high. The current schematic resolves the other way, so the default is `pol = -1`. `Basic_op` keeps `pol = +1` so that it checks the polarity the SAR needs.

## Design variables

| Variable | Default | Meaning |
|---|---|---|
| vcc, vcm | 1.8, 0.9 | Supply and input common mode |
| vd | 10m | Static / alternating differential input |
| fclk, duty, tr, tf | 1M, 0.5, 100p, 100p | Comparator clock |
| t_eval, t_rst | — | Used only by `Clk_reset`, where `fclk = 1/(t_eval+t_rst)` |
| trim_a, trim_b | 8, 8 | Codes on the comparator TRIMA/TRIMB pins (0..31) |
| rs, ccdac, cload | 1, 9.3p, 10f | Source R, CDAC top-plate C (256 × 4 µm × 4 µm MiM), output load |
| mode | 0 | 0 static, 1 staircase, 2 ±vd alternating, 3 history groups |
| vstart, vstep, nsteps, nrep | -30m, 1m, 61, 1 | Staircase |
| vagg | 300m | History aggressor |
| tsu | 0.5n | SAR setup time before the sampling edge |
| vos, ncyc, tstop | 0, 20, (ncyc+1)/fclk | Expected threshold for error counting, cycles, stop time |

## Switching schematic / extracted

* `PEX_*` tests use view `config_pex`, which binds `sar_adc.comparator` to `av_extracted`.
* To repoint any test: `tbcmpSetView("config_pex" '("Off_set"))`, or `tbcmpSetView("schematic")` for all tests. You can also change the view field in the Maestro Data View.
* Outputs that probe `/I0/XCORE/net2|net3` are dropped from PEX tests, because extracted net names differ.

## Tests

Values marked (verified) come from batch runs of this exact setup on a scratch copy (schematic, tt, 27 °C).

| # | Test | Stimulus / sweep | Outputs (spec) |
|---|---|---|---|
| 1 | Basic_op | ±vd alternating, vd ∈ {5m,20m,100m}, pol=+1 | dec_pos (>0.5), dec_neg (<-0.5), n_wrong, n_unres. **Fails on schematic** (polarity), passes on PEX (verified) |
| 2 | Reset_op | vd=100m | outp/outn, I0/XCORE/net2,net3 at end of reset (/vcc > 0.95 / 0.9), t_reset. All reach 1.0 (verified) |
| 3 | Off_set | staircase ±30 mV, 0.25 mV steps | Vos (±5 mV). −125 µV (verified) |
| 4 | Input_ref_noise | staircase ±3 mV × 20 repeats, fclk=5M, transient noise 50k–5G | Vos_noisy, sigma_n (< 1.75 mV). Not run here because it is slow; center vstart on Vos |
| 5 | Decision_delay | vd ∈ ±{1m…300m} | t_cq, t_cq_frac (< 1). 0.75–2.7 ns (verified) |
| 6 | Metastability | 101 steps of 1 µV around vos, fclk ∈ {1M,5M,20M} | n_wrong, n_unres (< 1), n_correct, t_cq_worst |
| 7 | Common_mode | staircase, vcm 0.3…1.5 | Vos, t_cq, n_wrong, n_unres. **No decisions at vcm ≤ 0.5 V** (verified) |
| 8 | Kickback | rs=1G (floating inputs), ccdac ∈ {9.3p,1p,100f}, vd ∈ {1m,100m} | kick_inp/inn, kick_diff (< 3.5 mV ≈ ½ LSB), resid_diff. 20 µV diff at 9.3 pF (verified) |
| 9 | Power_energy | ±vd, vd ∈ {1m,10m,100m} | E_cycle, P_avg, E_eval, E_reset. ≈160–180 fJ/cycle (verified) |
| 10 | History_dep | [+300m, test, −300m, test] groups | Vth_after_pos/neg, dVth_hist (±1 mV). 0 at 0.25 mV resolution (verified) |
| 11 | Clk_freq / Clk_edge / Clk_duty / Clk_reset | fclk 1M–100M / tr=tf 50p–5n / duty 0.2–0.8 / t_rst 1n–500n with t_eval=500n | t_cq, t_cq_frac, n_correct, n_unres, n_wrong (< 1) |
| 12 | Output_compat | cload ∈ {5f,10f,50f} | V_high (>0.9), V_low (<0.1), V_peak (<1.1), V_undershoot (>−0.1), setup_margin (>0), hold_t_after_clk |
| 13 | PVT | staircase, 45 corners (only this test) | Vos, t_cq, n_wrong, n_unres, E_cycle |
| 14 | MC_mismatch | staircase ±60 mV, `tbcmp_mc.scs`; 200 points, mismatch | Vos, t_cq, E_cycle. Standalone Spectre: σ(Vos)=8.9 mV over 40 samples |
| 15 | Trim_a / Trim_b | code 0:1:31 on one side | Vos, t_cq, E_cycle. Range = max−min Vos, step = ΔVos/code |
| 16 | PEX_* | Basic_op, Off_set, Decision_delay, Kickback, Power_energy on `config_pex` | same outputs (internal nets dropped). PEX E_cycle ≈ 210–230 fJ (verified) |

## Assumptions to confirm

* fclk = 1 MHz (from `tb_sar_stimuli`, TCLK = 1000 ns); the old tests used 100 kHz.
* tsu = 0.5 ns, and the decision is valid when the winner is < 0.3·vcc and the loser is > 0.7·vcc.
* LSB ≈ 1.8 V/256 ≈ 7 mV. Specs used: |Vos| < 5 mV, σn < LSB/4, kick < LSB/2.
* ccdac = 9.3 pF per side (256 × 4×4 µm MiM, `sar_afe` netlist). The CDAC is modeled as a grounded C, ignoring the bootstrap switch.
* cload = 10 fF (sr_latch input, not extracted).
