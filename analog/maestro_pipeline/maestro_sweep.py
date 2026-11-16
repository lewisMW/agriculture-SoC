"""
Plot the scalar results (SINAD, ENOB, SFDR, ...) of a Maestro / ADE Explorer sweep
against the swept variable, and write them to a CSV.

Run it after export_results.sh (VM) and fetch_exports.sh (Mac), or with --pull, which
runs both first (vm_pull.py -> pull_results.sh; this file only plots). It reads the copy of the results database
(ExplorerRun.0.rdb, an SQLite file) inside an export folder. For a histogram test it
also works out each point's Vos, DNL and INL with histogram.py and plots them.

Usage (from ~/Documents/SoCs):
  venv_SoC/bin/python maestro_pipeline/maestro_sweep.py --pull            # export + copy the latest run, then plot it
  venv_SoC/bin/python maestro_pipeline/maestro_sweep.py                   # newest export in data/exports/
  venv_SoC/bin/python maestro_pipeline/maestro_sweep.py data/exports/2026-11-16_1323_fft
  ... maestro_sweep.py <export> --x M_cycles     # choose the x variable (default: first swept one)
  ... maestro_sweep.py <export> --y sinad sfdr   # choose the outputs (default: all known FOMs in the run)

x axis: M_cycles is shown as input frequency (f = M * fs / Nfft); v_ref as the input level
in dBFS, dB below full scale: 20*log10(v_ref / 1.8), so 0 dBFS = 1.8 V, -6 dBFS = 0.9 V. Two swept variables give one line per value
of the second one. Each test of the run gets its own plot and table, saved in the export
folder as sweep_<test>.png and sweep_<test>.csv (e.g. sweep_fft.png, sweep_two_tone.png).
"""

import argparse
import sqlite3
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

EXPORTS = Path(__file__).resolve().parent / "data" / "exports"
# Plotted by default when the run has them: sine test, then two-tone test
DEFAULT_YS = ["sinad", "enob", "sfdr", "thd",                      # single-tone (Maestro)
              "enob_fs", "noise_floor", "fit_offset", "fit_gain",   # single-tone (extra_foms.py)
              "SFDR_2TONE", "IMD3", "IMD2",                          # two-tone (Maestro)
              "noise_floor_2tone"]                                   # two-tone (extra_foms.py)
FULL_SCALE = 1.8   # V peak differential (vref of the sar instance)
NBITS = 8


def find_rdb(arg):
    """An .rdb file, an export folder holding one, or (None) the newest export."""
    if arg is None:
        folders = sorted(d for d in EXPORTS.glob("*/") if list(d.glob("*.rdb")))
        if not folders:
            raise SystemExit(f"no exports in {EXPORTS}: run fetch_exports.sh first")
        arg = folders[-1]
    path = Path(arg)
    if not path.exists():
        raise SystemExit(f"no such export folder or file: {path}")
    if path.is_dir():
        rdbs = sorted(path.glob("*.rdb"))
        if not rdbs:
            raise SystemExit(f"no .rdb in {path}")
        path = rdbs[0]
    return path


def load(rdb):
    """Return {test name: (table, swept)}: for every test with scalar results, one row per
    design point (its parameters and that test's scalar outputs) and the swept variables."""
    con = sqlite3.connect(f"file:{Path(rdb).resolve()}?mode=ro", uri=True)
    params = pd.read_sql(
        "select pv.pointID, pa.name, pv.value from parameterValue pv join parameter pa using(parameterID)", con)
    results = pd.read_sql(
        "select rv.pointID, t.name as test, r.name, rv.value from resultValue rv "
        "join result r using(resultID) join test t on t.testID = r.testID", con)
    point_no = pd.read_sql("select pointID, designPointNumber as point from point", con)
    # Variables defined from other variables (v1 = v_ref/2, fin_1 = fs*M/Nfft, ...) aren't sweeps
    derived = set(pd.read_sql(
        "select distinct a.name from VariableDependency d join parameter a on a.parameterID = d.varID",
        con)["name"])
    con.close()

    results["value"] = pd.to_numeric(results["value"], errors="coerce")   # waveforms -> NaN
    results = results.dropna()
    params["value"] = pd.to_numeric(params["value"], errors="coerce")
    p = params.pivot_table(index="pointID", columns="name", values="value", aggfunc="first")

    out = {}
    for test, res in results.groupby("test"):
        r = res.pivot_table(index="pointID", columns="name", values="value", aggfunc="first")
        pt = p.loc[p.index.intersection(r.index)]
        table = pt.join(r, how="inner").reset_index().merge(point_no, on="pointID", how="left")
        swept = [c for c in pt.columns if pt[c].nunique() > 1 and c not in derived]
        print(f"{test}: {len(table)} points, swept: {swept or 'nothing'}")
        out[test] = (table, swept)
    return out


def x_axis(table, name):
    """Turn a swept variable into a readable axis."""
    if name in ("M_cycles", "M_cycles_1", "M_cycles_2"):
        fin = "fin_1" if name != "M_cycles_2" else "fin_2"
        if fin in table:
            return table[fin] / 1e3, "Input frequency (kHz)"
    if name == "v_ref":
        per_tone = "fin_2" in table and table["fin_2"].max() > 0      # two-tone test: v_ref is each tone
        return (20 * np.log10(table["v_ref"] / FULL_SCALE),
                f"Input level{' per tone' if per_tone else ''} (dBFS, 0 = 1.8 V peak differential)")
    return table[name], name


def plot(table, swept, x=None, ys=("sinad", "enob", "sfdr", "thd"), out=None, show=True):
    if not swept and x is None:
        print("nothing swept, nothing to plot")
        return
    x = x or swept[0]
    group = next((s for s in swept if s != x), None)
    ys = [y for y in ys if y in table]
    fig, axes = plt.subplots(len(ys), 1, figsize=(8, 2.6 * len(ys)), sharex=True, squeeze=False)
    for ax, y in zip(axes[:, 0], ys):
        groups = table.groupby(group) if group else [(None, table)]
        for g, sub in groups:
            sub = sub.sort_values(x)
            xv, xlabel = x_axis(sub, x)
            ax.plot(xv, sub[y], "o-", label=f"{group} = {g:g}" if group else None)
        if y == "sinad" and x == "v_ref":
            # ideal N-bit converter: 6.02N + 1.76 dB at 0 dBFS, falling 1 dB per dB of input
            lv = np.linspace(xv.min(), min(xv.max(), 0), 50)
            ax.plot(lv, 6.02 * NBITS + 1.76 + lv, "k--", lw=0.8, label="ideal 8-bit")
        ax.set_ylabel(y)
        ax.ticklabel_format(axis="y", useOffset=False)       # no "1e2 + ..." offset labels
        ax.grid(alpha=0.3)
        if group or (y == "sinad" and x == "v_ref"):
            ax.legend(fontsize=8)
    axes[-1, 0].set_xlabel(xlabel)
    fig.tight_layout()
    if out:
        fig.savefig(out, dpi=150)
        print(f"saved {out}")
    if show:
        plt.show()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("export", nargs="?", help="export folder or .rdb file (default: newest export)")
    ap.add_argument("--x", help="swept variable for the x axis")
    ap.add_argument("--y", nargs="+", help="outputs to plot (default: every one of "
                    + " ".join(DEFAULT_YS) + " that the run has)")
    ap.add_argument("--no-plot", action="store_true", help="save the plot without opening a window")
    ap.add_argument("--power", type=float, metavar="W",
                    help="ADC power in watts: adds the Walden and Schreier FoM to sine tests")
    ap.add_argument("--pull", nargs="*", metavar="ARG",
                    help="first export the latest run on the Cadence machine and copy it here "
                         "(pull_results.sh; ARGs as for export_results.sh, e.g. ExplorerRun.0 "
                         "sar_adc_sine_two_tone), then plot it")
    args = ap.parse_args()

    if args.pull is not None:
        if args.export:
            ap.error("give either an export folder or --pull, not both")
        from vm_pull import pull           # the only part that talks to the Cadence machine
        args.export = pull(args.pull)
    rdb = find_rdb(args.export)
    print(rdb)
    tests = load(rdb)
    # histogram tests may have no scalar outputs at all: still handle their exported histograms
    for d in sorted(rdb.parent.glob("*hist*/")):
        if d.name not in tests and list(d.glob("pt*/hist.csv")):
            tests[d.name] = (pd.DataFrame(), [])

    for test, (table, swept) in tests.items():
        short = test.replace("sar_adc_sine_", "")
        print(f"\n===== {test} =====")

        # figures of merit Maestro doesn't give, from the exported codes (extra_foms.py):
        # single-tone and two-tone each get their own set
        from extra_foms import for_test
        extra = for_test(rdb.parent / test, args.power)
        if len(extra) and len(table):
            table = table.merge(extra, on="point", how="left")
            if "sinad_py" in table and "sinad" in table:
                d = (table["sinad_py"] - table["sinad"]).abs().max()
                print(f"check: SINAD from the exported codes vs Maestro's, max difference {d:.3f} dB")

        # outputs to plot: those asked for, else every known figure of merit the test has.
        # Names are matched without regard to case (SFDR_2TONE = sfdr_2tone).
        lower = {c.lower(): c for c in table.columns}
        ys = [lower[y.lower()] for y in (args.y or DEFAULT_YS) if y.lower() in lower]
        if args.y and len(ys) < len(args.y):
            print("not in this test:", [y for y in args.y if y.lower() not in lower])

        if len(table):
            cols = swept + [c for c in ["fin_1", "fin_2", "v_ref"] + ys
                            if c in table and c not in swept]
            print(table[["point"] + cols].to_string(index=False))
            csv = rdb.parent / f"sweep_{short}.csv"
            table.to_csv(csv, index=False)
            print(f"wrote {csv}")

        # histogram test: Vos, DNL, INL (the notebook's calculation) per point, from histogram.py
        if "hist" in test:
            from histogram import run_point
            pts = sorted((rdb.parent / test).glob("pt*/hist_info.csv"), key=lambda p: int(p.parent.name[2:]))
            for pt in (p.parent for p in pts):
                run_point(pt, show=not args.no_plot)
            if not pts:
                print("no hist.csv in this export (exported before the histogram step existed?)")

        if not swept and args.x is None:
            print("nothing swept, no figure-of-merit plot")
            continue
        if not ys:
            print("no figures of merit to plot (choose some with --y)")
            continue
        plot(table, swept, args.x, ys, out=rdb.parent / f"sweep_{short}.png", show=not args.no_plot)


if __name__ == "__main__":
    main()
