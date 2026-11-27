"""
extra_foms.py -- figures of merit Maestro doesn't give, from each exported design point.

Same calculations as fft_metrics(), sine_fit() and two_tone_metrics() in the old
sine_test_claude.py, but every setting (fs, Nfft, M_cycles, v_ref) is read from the
point's vars.csv instead of being hard-coded, and the codes come from samples.csv.

Sine test, per point:
    signal_dbfs   signal level, dBFS (0 dBFS = full-scale sine)
    sinad_py      SINAD from these codes (should match Maestro's sinad: a check)
    enob_fs       ENOB normalised to full scale = (SINAD - signal_dbfs - 1.76) / 6.02
    spur_hz       frequency of the largest spur (Maestro's sfdr gives only its size)
    noise_floor   noise floor, dBFS per bin
    hd2..hd6      harmonics 2-6 in dBc (Maestro has only H1, H3, H5, H7)
    fit_offset    sine-fit offset error, LSB  (3-parameter least-squares fit at fin, IEEE 1241)
    fit_gain      sine-fit gain error, %
    walden, schreier   only with a power given (maestro_sweep.py --power W)
Two-tone test, per point (own names, so nothing is shared with the single-tone results):
    tone1_dbfs, tone2_dbfs, noise_floor_2tone (dBFS/bin, without the tones and IM products)

Which calculation runs is decided by the test name: "two_tone" -> two-tone, "hist" ->
skipped (histogram.py), anything else -> single-tone sine.

Used by maestro_sweep.py; can also be run on its own:
    python extra_foms.py data/exports/<folder> [--power 50e-6]
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

NBITS = 8
DAC_VREF = 1.8          # vref of ideal_dac_8b in the testbench (vout -> code)
FULL_SCALE = 1.8        # V peak differential that spans all codes
N_HARMONICS = 6         # harmonics 2..6, as in the old script


def load(pt):
    """Codes and design variables of one exported point (pt<N> folder)."""
    vout = pd.read_csv(pt / "samples.csv")["vout"].to_numpy()
    half = 2 ** (NBITS - 1)
    codes = np.clip(np.round(vout * half / DAC_VREF + half - 0.5), 0, 2**NBITS - 1).astype(int)
    v = pd.read_csv(pt / "vars.csv")
    return codes, dict(zip(v["name"], v["value"]))


def spectrum_of(codes):
    """Power spectrum (rfft, mean removed, DC zeroed) and the full-scale reference power."""
    n = len(codes)
    s = np.abs(np.fft.rfft(codes - codes.mean())) ** 2
    s[0] = 0
    full_scale = (n / 2 * 2 ** (NBITS - 1)) ** 2       # full-scale sine -> 0 dBFS
    return s, full_scale


def fold(k, n):
    """Bin k folded back into 0..n/2 (aliasing)."""
    k = k % n
    return min(k, n - k)


def sine_foms(codes, var, power=None):
    n = len(codes)
    fs = var["fs"]
    s, fsc = spectrum_of(codes)
    k_sig = int(np.argmax(s))                           # fundamental bin
    harm = [fold(h * k_sig, n) for h in range(2, N_HARMONICS + 1)]
    p_sig = s[k_sig]
    p_harm = sum(s[b] for b in harm)
    p_noise = s.sum() - p_sig - p_harm
    others = s.copy()
    others[k_sig] = 0
    k_spur = int(np.argmax(others))                     # largest bin that isn't DC or the signal
    n_noise_bins = len(s) - 2 - len(set(harm))          # minus DC, signal, harmonics

    sinad = 10 * np.log10(p_sig / (p_noise + p_harm))
    sig_dbfs = 10 * np.log10(p_sig / fsc)
    r = {
        "signal_dbfs": sig_dbfs,
        "sinad_py": sinad,
        "enob_fs": (sinad - sig_dbfs - 1.76) / 6.02,
        "spur_hz": k_spur * fs / n,
        "noise_floor": 10 * np.log10(p_noise / n_noise_bins / fsc),
    }
    for h, b in zip(range(2, N_HARMONICS + 1), harm):
        r[f"hd{h}"] = 10 * np.log10(s[b] / p_sig + 1e-20)

    # 3-parameter sine fit at the known input frequency: codes ~ a cos + b sin + offset
    fin = fs * var["M_cycles"] / var["Nfft"]
    wt = 2 * np.pi * fin * np.arange(n) / fs
    basis = np.column_stack([np.cos(wt), np.sin(wt), np.ones(n)])
    (a, b, offset), *_ = np.linalg.lstsq(basis, codes.astype(float), rcond=None)
    ideal_amp = 2 ** (NBITS - 1) * var["v_ref"] / FULL_SCALE   # v_ref = peak differential input
    ideal_mid = (2**NBITS - 1) / 2                              # mean code at 0 V differential
    r["fit_offset"] = offset - ideal_mid                        # LSB
    r["fit_gain"] = (np.hypot(a, b) / ideal_amp - 1) * 100      # %

    if power:                                                   # needs the ADC's power (W)
        enob = (sinad - 1.76) / 6.02
        r["walden"] = power / (2**enob * fs)                    # J per conversion step
        r["schreier"] = sinad + 10 * np.log10(fs / 2 / power)   # dB
    return r


def two_tone_foms(codes, var):
    n = len(codes)
    s, fsc = spectrum_of(codes)
    m1 = int(round(var["M_cycles_1"] * n / var["Nfft"]))
    m2 = int(round(var["M_cycles_2"] * n / var["Nfft"]))
    products = [fold(k, n) for k in (m2 - m1, m1 + m2, 2 * m1 - m2, 2 * m2 - m1, 2 * m1 + m2, 2 * m2 + m1)]
    used = {m1, m2, *products}
    noise_bins = [b for b in range(1, len(s)) if b not in used]
    return {
        "tone1_dbfs": 10 * np.log10(s[m1] / fsc),
        "tone2_dbfs": 10 * np.log10(s[m2] / fsc),
        "noise_floor_2tone": 10 * np.log10(s[noise_bins].mean() / fsc),
    }


def for_test(test_dir, power=None):
    """One row per design point of a sine or two-tone test folder; empty if not applicable."""
    rows = []
    for pt in sorted(Path(test_dir).glob("pt*"), key=lambda p: int(p.name[2:])):
        if not (pt / "samples.csv").exists():
            continue
        codes, var = load(pt)
        if "two_tone" in test_dir.name:
            r = two_tone_foms(codes, var)
        elif "hist" in test_dir.name:
            continue                                            # histogram.py handles these
        else:
            r = sine_foms(codes, var, power)
        rows.append({"point": int(pt.name[2:]), **r})
    return pd.DataFrame(rows)


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    power = float(sys.argv[sys.argv.index("--power") + 1]) if "--power" in sys.argv else None
    folder = Path(args[0]) if args else sorted((Path(__file__).resolve().parent / "data" / "exports").glob("*/"))[-1]
    for test_dir in sorted(p for p in folder.glob("sar_adc_*") if p.is_dir()):
        t = for_test(test_dir, power)
        if len(t):
            print(f"===== {test_dir.name}\n{t.to_string(index=False)}")
