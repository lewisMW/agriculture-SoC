"""
histogram.py -- sine-histogram test: offset (Vos), DNL and INL from the ADC codes.

The figure-of-merit calculation in fom() is copied unchanged from sine_hist_test.ipynb:
the histogram cell (np.histogram(codes, bins=256)) and the "### THIS CODE HERE ###" cell.
Only the source of the codes changes:
  - default : codes of a Maestro histogram run, from an export (pt<N>/samples.csv)
  - --ideal : the notebook's ideal ADC, synthetic_codes(N_CODES + NDROP)

Run from this folder:
    python histogram.py                          # newest export with a histogram test
    python histogram.py data/exports/<folder>    # a particular export
    python histogram.py --ideal                  # the notebook's ideal-ADC codes instead
    python histogram.py --no-plot                # save the figure, don't open a window
maestro_sweep.py calls run_point() for every point of a histogram test.

TODO (Jaime):
  - Check the gain-error calculation in gain_error() (added quickly, not from the notebook).
  - Decide on the Vj / LSB scale: the notebook cell uses VREF (full scale), while the
    "corrected" cell below it in the notebook uses the sine amplitude A = 2*VAMP.
  - The notebook's np.histogram(codes, bins=256) spreads 256 bins over min..max of the
    codes, so a bin is one code only when all 256 codes are hit (input at full scale).
  - Long run for real numbers: ~67k codes for +/-0.2 LSB (sine_test.tex), not 1024.
"""
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# ---- Settings, as in the notebook's settings cell (used by --ideal and the scales) ----
NBITS = 8
FS = 1e6 / 10                # sample rate: 1 MHz SAR clock / 10 clocks per conversion
N_FFT, M_CYCLES = 1024, 31
FIN = M_CYCLES / N_FFT * FS  # 3027.34375 Hz
NDROP = 2                    # start-up codes (Maestro's samples already start after them)
N_CODES = 10000              # codes in the notebook's synthetic histogram
VSSA, VDDA = 0, 1.8
VREF = VDDA                  # full scale = +/- VREF differential
VAMP = VREF / 2              # amplitude per side (v1 in Maestro)
DAC_VREF = 1.8               # vref of ideal_dac_8b in the testbench (vout -> code)

EXPORTS = Path(__file__).resolve().parent / "data" / "exports"


# ---- Where the codes come from ----
def synthetic_codes(n, nbits=NBITS):
    """Ideal ADC codes for the test sine, same transfer function as Lewis's model
    (unchanged from the notebook)."""
    t = np.arange(n) / FS
    vdiff = 2 * VAMP * np.sin(2 * np.pi * FIN * t + 0.1)
    half = 2 ** (nbits - 1)
    return np.clip(np.floor(half + half * vdiff / VREF), 0, 2**nbits - 1).astype(int)


def maestro_codes(pt):
    """Codes of one exported design point: the testbench's ideal DAC holds
    vout = (code + 0.5 - 128) * DAC_VREF / 128, so code = vout * 128 / DAC_VREF + 127.5.
    Returns (codes, info) with info = the run settings from hist_info.csv."""
    vout = pd.read_csv(pt / "samples.csv")["vout"].to_numpy()
    half = 2 ** (NBITS - 1)
    codes = np.clip(np.round(vout * half / DAC_VREF + half - 0.5), 0, 2**NBITS - 1).astype(int)
    info = pd.read_csv(pt / "hist_info.csv")
    return codes, dict(zip(info["name"], info["value"]))


# ---- Figures of merit: exactly the notebook's calculation ----
def fom(codes):
    # histogram cell: 256 bins over the code range, bin centres
    Hk, x = np.histogram(codes, bins=256)
    bins = x[:-1] + np.diff(x) / 2

    # "### THIS CODE HERE ###" cell
    mid = 2**(8 - 1)
    idxn = np.where(bins <= mid)             # bins in the negative half
    idxp = np.where(bins > mid)              # bins in the positive half
    Mn = np.sum(Hk[idxn])
    Mp = np.sum(Hk[idxp])
    Vos = VREF * np.pi / 2 * (Mp - Mn) / (Mp + Mn)   # offset voltage
    M = sum(Hk)                              # number of samples
    Hkcum = np.cumsum(Hk)                    # cumulative histogram
    Vj = -VREF * np.cos(np.pi / M * Hkcum)   # transition voltages
    LSB = 2 * VDDA / 2**8                    # also VQ
    DNL = (Vj[1:] - Vj[:-1]) / LSB - 1
    INL = DNL.cumsum()                       # (the notebook's earlier (Vj-Vj[0])/LSB is overwritten)
    return dict(Hk=Hk, bins=bins, Hkcum=Hkcum, Vj=Vj, M=M, Vos=Vos, LSB=LSB, DNL=DNL, INL=INL)


# ---- Extras (not from the notebook) ----
def gain_error(r):
    """Quick end-point gain error: the measured span between the first and last
    transitions against the ideal span for that many steps (r from fom()).
    Vj[-1] is left out: it is always +VREF (cumulative count = M), not a transition."""
    vj = r["Vj"][:-1]
    measured = vj[-1] - vj[0]
    ideal = (len(vj) - 1) * r["LSB"]
    return (measured / ideal - 1) * 100      # percent


def missing_codes(codes):
    """Codes inside the hit range that never occur."""
    hit = np.bincount(codes, minlength=2**NBITS) > 0
    return [k for k in range(codes.min(), codes.max() + 1) if not hit[k]]


# ---- Report: print and plot ----
def report(codes, label, info=None, out=None, show=True):
    r = fom(codes)
    gain = gain_error(r)
    miss = missing_codes(codes)

    # Code-count checks: what the record should hold vs what was used
    n_ideal = N_CODES + NDROP
    notes = [f"codes used: {len(codes)} (M = {r['M']})"]
    if info:
        notes.append(f"export says n_samples = {int(info['n_samples'])}, Nfft = {int(info['Nfft'])}")
        if int(info["n_samples"]) != len(codes):
            notes.append("MISMATCH: codes used != exported n_samples")
        notes.append(f"notebook's ideal run uses {n_ideal} codes (N_CODES + NDROP): "
                     + ("same" if n_ideal == len(codes) else f"differs by {n_ideal - len(codes)}"))
        notes.append(f"input: v_ref = {info['v_ref']:g} V here vs {2 * VAMP:g} V in the ideal run")
    else:
        notes.append(f"ideal run: N_CODES + NDROP = {n_ideal} (start-up codes not dropped)")
    lines = [f"{label}",
             f"Offset error Vos = {r['Vos'] * 1e3:.3f} mV ({r['Vos'] / r['LSB']:.3f} LSB)",
             f"Gain error (end-point, quick) = {gain:+.3f} %",
             f"DNL: min {r['DNL'].min():.3f}  max {r['DNL'].max():.3f} LSB",
             f"INL: min {r['INL'].min():.3f}  max {r['INL'].max():.3f} LSB",
             f"Missing codes: {len(miss)}" + (f" {miss[:10]}" if miss else ""),
             *notes]
    print("\n".join(lines))

    fig, ax = plt.subplots(2, 2, figsize=(12, 7))
    ax[0, 0].bar(r["bins"], r["Hk"], width=np.diff(r["bins"]).mean())
    ax[0, 0].set(title="Histogram Hk", xlabel="code (bin centre)", ylabel="hits")
    ax[0, 1].step(r["bins"], r["Hkcum"], where="mid")
    ax[0, 1].set(title="Cumulative histogram", xlabel="code (bin centre)", ylabel="hits")
    ax[1, 0].plot(r["DNL"], ".")
    ax[1, 0].set(title="DNL", xlabel="Code", ylabel="DNL (LSB)")
    ax[1, 1].plot(r["INL"], ".")
    ax[1, 1].set(title="INL (Cumulative Sum)", xlabel="Code", ylabel="INL (LSB)")
    for a in ax.flat:
        a.grid(alpha=0.3)
    fig.text(0.01, 0.99, "\n".join(lines), va="top", family="monospace", fontsize=8)
    fig.tight_layout(rect=(0, 0, 1, 0.80))
    if out:
        fig.savefig(out, dpi=150)
        print(f"saved {out}")
    if show:
        plt.show()
    plt.close(fig)
    return r


def run_point(pt, show=True):
    """One exported design point (called by maestro_sweep.py)."""
    codes, info = maestro_codes(pt)
    return report(codes, f"Maestro: {pt.parent.parent.name}/{pt.parent.name}/{pt.name}",
                  info, out=pt / "hist.png", show=show)


def find_points(export=None):
    """pt<N> folders of histogram tests: in the given export, else the newest that has one."""
    folders = [Path(export)] if export else sorted(EXPORTS.glob("*/"), reverse=True)
    for folder in folders:
        pts = sorted(folder.glob("*hist*/pt*/hist_info.csv"), key=lambda p: int(p.parent.name[2:]))
        if pts:
            return [p.parent for p in pts]
    raise SystemExit("no histogram export found (hist_info.csv)")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    show = "--no-plot" not in sys.argv
    if "--ideal" in sys.argv:
        report(synthetic_codes(N_CODES + NDROP), "Ideal ADC (notebook synthetic_codes)",
               out=EXPORTS.parent / "ideal_hist.png", show=show)
    else:
        for pt in find_points(args[0] if args else None):
            run_point(pt, show)
