"""
histogram.py -- load the histogram-test exports (per-code histogram and run settings)
for your own INL/DNL calculations. No figures of merit are computed here yet.

The export writes, for every design point of a test whose name contains "hist":
    <export>/<test>/pt<N>/hist.csv       code, count, cumulative   (one row per code 0..255)
    <export>/<test>/pt<N>/hist_info.csv  name, value   n_samples, codes_hit, code_min, code_max,
                                         record_time, t_sim, fs, fin_1, M_cycles, Nfft, v_ref, ...
    <export>/<test>/pt<N>/samples.csv    time, vout    the samples the histogram was made from

It plots, per design point, the histogram (hits per code) and the cumulative histogram,
saved next to the data as pt<N>/hist.png. Opens the plot window unless --no-plot.

Usage (from ~/Documents/SoCs):
    venv_SoC/bin/python maestro_pipeline/histogram.py                     # newest export with a histogram
    venv_SoC/bin/python maestro_pipeline/histogram.py data/exports/<folder>
    venv_SoC/bin/python maestro_pipeline/histogram.py --no-plot           # save the plots, no window
"""
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

EXPORTS = Path(__file__).resolve().parent / "data" / "exports"


def find_points(export=None):
    """pt<N> folders holding hist.csv: in the given export folder, else the newest that has one."""
    folders = [Path(export)] if export else sorted(EXPORTS.glob("*/"), reverse=True)
    for folder in folders:
        pts = sorted(folder.glob("*hist*/pt*/hist.csv"), key=lambda p: int(p.parent.name[2:]))
        if pts:
            return [p.parent for p in pts]
    raise SystemExit("no histogram export found (hist.csv)")


def load_point(pt):
    """Return (hist, info) for one design point: hist is a DataFrame (code, count,
    cumulative), info a dict of the run settings from hist_info.csv."""
    hist = pd.read_csv(pt / "hist.csv")
    info = pd.read_csv(pt / "hist_info.csv")
    return hist, dict(zip(info["name"], info["value"]))


def plot_point(pt, hist, info, show=True):
    """Histogram and cumulative histogram of one design point -> pt<N>/hist.png."""
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(9, 6), sharex=True)
    a1.bar(hist["code"], hist["count"], width=1.0, color="#2a78d6")
    a1.set_ylabel("Hits per code")
    a1.set_title(f"{pt.parent.name} {pt.name}: {int(info['n_samples'])} samples, "
                 f"{int(info['codes_hit'])} codes hit, record {info['record_time'] * 1e3:.2f} ms",
                 loc="left", fontsize=10)
    a2.step(hist["code"], hist["cumulative"], where="post", color="#2a78d6")
    a2.set_ylabel("Cumulative hits")
    a2.set_xlabel("Code")
    a2.set_xlim(-1, len(hist))
    for a in (a1, a2):
        a.grid(alpha=0.3)
    fig.tight_layout()
    out = pt / "hist.png"
    fig.savefig(out, dpi=150)
    print(f"  saved {out}")
    if show:
        plt.show()
    plt.close(fig)


def analyse(hist, info):
    """Your INL / DNL calculations go here (see sine_hist_test.ipynb).
    hist["count"] is H[k], hist["cumulative"] the cumulative histogram."""
    pass


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--no-plot"]
    show = "--no-plot" not in sys.argv
    for pt in find_points(args[0] if args else None):
        hist, info = load_point(pt)
        print(f"{pt}: {int(info['n_samples'])} samples over {info['record_time'] * 1e3:.2f} ms, "
              f"codes {int(info['code_min'])}..{int(info['code_max'])} ({int(info['codes_hit'])} hit), "
              f"fin {info['fin_1']:.2f} Hz, v_ref {info['v_ref']:g} V")
        plot_point(pt, hist, info, show)
        analyse(hist, info)
