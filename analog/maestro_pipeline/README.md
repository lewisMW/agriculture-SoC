# Maestro → CSV → Python: SAR ADC sine-test pipeline

Gets the results of Maestro (ADE Explorer) sine-wave tests out of Cadence as CSV files,
copies them to your own computer, and plots the figures of merit (SINAD, ENOB, SFDR,
THD, ...) against the swept variable.

The scripts only **read** the results Maestro has saved. Nothing in Maestro, the
testbench or the library is changed.

```
 Cadence machine (VM)                         Your computer (Mac / Linux)
 ───────────────────                          ───────────────────────────
 1. run the test in Maestro
 2. export_results.sh  ──► exports/<folder>/ ──► 3. fetch_exports.sh ──► data/exports/<folder>/
                                                  4. maestro_sweep.py  ──► sweep_<test>.png/.csv

 Steps 2+3 from your computer:   pull_results.sh
 Steps 2+3+4 from your computer: maestro_sweep.py --pull
```

---

## Contents of this folder

| Path | Runs on | What it does |
|---|---|---|
| `vm/export_results.sh` | Cadence machine | **Step 2.** Exports the latest run. Calls the two files below |
| `vm/export_sine.ocn` | Cadence machine | OCEAN script: waveforms, samples, FFT and design variables → CSV |
| `vm/foms.py` | Cadence machine | Every scalar Maestro output per design point → `foms.csv` |
| `fetch_exports.sh` | Your computer | **Step 3.** Moves the exports from the Cadence machine (deletes them there once copied) |
| `pull_results.sh` | Your computer | **Steps 2 + 3.** Runs the export on the Cadence machine over ssh, then `fetch_exports.sh` |
| `maestro_sweep.py` | Your computer | **Step 4.** Plots the outputs against the swept variable. `--pull` does steps 2–4 |
| `extra_foms.py` | Your computer | Figures of merit Maestro doesn't give, from the exported codes: single-tone (ENOB at full scale, largest-spur frequency, noise floor, HD2–HD6, sine-fit offset and gain, Walden/Schreier with `--power`) and two-tone (tone levels, noise floor). Called by `maestro_sweep.py` |
| `histogram.py` | Your computer | Histogram tests: loads `hist.csv`/`hist_info.csv`, plots them, and is where the INL/DNL code goes (`analyse()`, empty for now). Called by `maestro_sweep.py` |
| `vm_pull.py` | Your computer | The `--pull` part of `maestro_sweep.py` (runs `pull_results.sh`); `maestro_sweep.py` itself only plots |
| `vm_settings.sh` | Your computer | How to reach the Cadence machine (used by the two scripts above); your values go in `vm_settings.local.sh` |
| `data/exports/` | Your computer | Where the exports land, one folder per export |

---

## One-time setup

### On the Cadence machine
1. Copy the three files in `vm/` into a folder in your home directory, e.g. `~/maestro_pipeline/`:
   ```
   scp vm/* <user>@<cadence-host>:maestro_pipeline/
   ```
2. Make them runnable (on the Cadence machine):
   ```
   chmod +x ~/maestro_pipeline/export_results.sh ~/maestro_pipeline/foms.py
   ```
3. Check that `ocean` (Cadence, comes with Virtuoso) and `python3` are on your PATH:
   `command -v ocean python3` should print two paths.
4. **Tell the script where your results are.** Open `export_results.sh` and set the two
   paths near the top (or set them as environment variables before running):

   | Setting | What it is | Default (Jaime's setup) |
   |---|---|---|
   | `SIMROOT` | Where Maestro writes the simulation data: `<simulation dir>/<lib>/<cell>/maestro/results/maestro`. It contains `ExplorerRun.0/1/<test>/psf/` | `~/simulation/sar_adc/tb_sar_adc/maestro/results/maestro` |
   | `RDBROOT` | The maestro view's own results folder in the library: `<lib path>/<cell>/maestro/results/maestro`. It contains `ExplorerRun.0.rdb` | `~/agriculture-SoC-hee-v2/analog/cadence/sar_adc/tb_sar_adc/maestro/results/maestro` |

   To find yours: after a run, `ls <...>/results/maestro/` should show `ExplorerRun.0`
   (SIMROOT) and `ExplorerRun.0.rdb` (RDBROOT). The simulation directory is set in
   Maestro under *Setup → Simulation Files / Run directory*.

### On your computer
1. Python 3 with `numpy`, `pandas` and `matplotlib` (for `maestro_sweep.py`), plus `rsync` and `ssh`.
2. Create `vm_settings.local.sh` next to `vm_settings.sh` (it is not committed) with your
   machine's details, e.g.
   ```
   VM_HOST="me@my-cadence-host"
   VM_KEY="$HOME/.ssh/my_key"
   ```
   The settings (also accepted as environment variables):

   | Setting | What it is | Default |
   |---|---|---|
   | `VM_HOST` | `user@host` of the Cadence machine | none: must be set |
   | `VM_KEY` | ssh key file (empty = your normal ssh key) | empty |
   | `VM_DIR` | Folder of `export_results.sh` on the Cadence machine, relative to home | `maestro_pipeline` |

3. Make the scripts runnable: `chmod +x fetch_exports.sh pull_results.sh`.
4. ssh to the Cadence machine must work without a password prompt (key in `VM_KEY`),
   and `ocean` must be set up by its `~/.bashrc` (the export runs in an interactive shell).

---

## Every time

**Shortest way**, after the Maestro run has finished, on your computer:
```
python maestro_sweep.py --pull                                   # export, copy and plot the latest run
python maestro_sweep.py --pull ExplorerRun.0 sar_adc_sine_two_tone   # one test only
./pull_results.sh                                                # export and copy, no plot
```
The steps it runs are below; each can also be run on its own.

### 1. Run the test in Maestro
Run the sine FFT, two-tone or histogram test as usual. A sweep (e.g. of `M_cycles` or
`v_ref`) is fine: every design point is exported.

Several tests can run in one go: enable them all in Maestro and run once. Each test can
have its own sweep (set it in that test's variables), e.g. the sine test sweeping
`M_cycles` and the two-tone test sweeping `v_ref`. One export then covers every test.

### 2. Export (on the Cadence machine)
```
~/maestro_pipeline/export_results.sh
```
Do this **before the next Maestro run**: ADE Explorer overwrites `ExplorerRun.0` every time.

| Command | What it exports |
|---|---|
| `~/maestro_pipeline/export_results.sh` | Latest run, every test that has results |
| `~/maestro_pipeline/export_results.sh ExplorerRun.0 sar_adc_sine_two_tone` | Latest run, one test only (test name as in Maestro) |
| `WAVEFORMS=1 ~/maestro_pipeline/export_results.sh` | Also the full `vout` transient (`vout.csv`, ~10 MB per point; off by default) |

Type the full path (or `./export_results.sh` from inside the folder). Plain
`export_results.sh` gives `command not found`, because bash doesn't look in the current folder.

When it finishes it prints `done: .../exports/<folder>`.

### 3. Move to your computer
```
./fetch_exports.sh          # from this folder; moves new exports here
./fetch_exports.sh -n       # dry run: show what would be moved, change nothing
```
The exports are **moved**: each file is deleted on the Cadence machine once it is copied,
so the data only lives in `data/exports/` on your computer. Only the three scripts stay
on the Cadence machine. Nothing is plotted there.

### 4. Plot
```
python maestro_sweep.py                                   # newest export
python maestro_sweep.py data/exports/2026-11-16_1323_fft  # a particular export
python maestro_sweep.py --x M_cycles --y sinad sfdr       # choose x axis and outputs
python maestro_sweep.py --no-plot                         # save the plot without opening a window
```
(Run these from this folder, `analog/maestro_pipeline/`, with a Python that has numpy, pandas and matplotlib.)

**What to give it:** an **export folder**, i.e. one of the folders inside `data/exports/`
such as `data/exports/2026-11-16_1323_fft`. **Not** a test folder inside it
(`.../sar_adc_sine_fft`) and not a `pt<N>` folder. It reads the `ExplorerRun.0.rdb` in
that folder. You can also give the `.rdb` file itself. With nothing, it takes the newest
export folder.

It writes one plot and one table **per test** into the same export folder:
`sweep_fft.png` / `sweep_fft.csv`, `sweep_two_tone.png` / `sweep_two_tone.csv`, ...
(a test with a single design point, like the histogram, gets the table but no plot).
`M_cycles` is plotted as input frequency in kHz, `v_ref` as input level in dBFS (with the ideal
8-bit SINAD line). With two swept variables you get one line per value of the second.
The y axes zoom to the data: a steep-looking line can be a few hundredths of a dB.

---

## Export folder format

One folder per export, named `<date>_<time>_<tests that had results>`
(`fft` = `sar_adc_sine_fft`, `two_tone`, `hist`), e.g. `2026-11-16_1323_fft` or
`2026-11-16_1430_fft+two_tone`:

```
data/exports/2026-11-16_1323_fft/           ← export folder (give this to maestro_sweep.py)
├── ExplorerRun.0.rdb                        Maestro's results database (SQLite): all outputs, all points
├── ocean.log                                full log of the OCEAN export (look here if something is missing; not in git)
├── export.txt                               short record of what was exported
├── sweep_<test>.png/.csv                   made by maestro_sweep.py, one pair per test
└── sar_adc_sine_fft/                        one folder per test
    ├── foms.csv                             one row per design point (see below)
    ├── pt1/                                 design point 1
    │   ├── vars.csv                         name,value  design variables of this point
    │   ├── samples.csv                      time,vout   one sample per conversion, t0 … t1 − tstep (1024 rows)
    │   ├── fft.csv                          freq,mag,dB,re,im  dft(vout t0 t1 Nfft "Rectangular"), mag in peak volts
    │   └── hist.csv, hist_info.csv          histogram tests only (see "Histogram test")
    ├── pt2/
    └── pt3/
```

**`foms.csv`** has one row per design point: the point number (same `N` as the `pt<N>`
folders), every design variable, then every scalar output of that test, in Maestro's order.
Example (frequency sweep of `M_cycles`, trimmed):

| point | M_cycles | fin_1 | v_ref | sinad | enob | sfdr | thd | H1 |
|---|---|---|---|---|---|---|---|---|
| 1 | 31 | 3027.34 | 1.8 | 49.81 | 7.98 | 66.31 | 0.039 | 1.7997 |
| 2 | 59 | 5761.72 | 1.8 | 49.78 | 7.98 | 66.70 | 0.039 | 1.7994 |

All CSVs have a header row, comma-separated, SI units (s, Hz, V, dB).
`samples.csv` and `fft.csv` use the variables `t0`, `t1`, `tstep` and `Nfft`, so they
are only written for tests that define them.

---

## Sweeping the input frequency up to Nyquist

Coherent sampling: `fin = M · fs / Nfft`, with `M` an **odd prime** so every sample hits
a different phase. Nyquist is `M < Nfft/2`. For `Nfft = 1024`, `fs = 100 kHz`
(bin spacing 97.66 Hz, Nyquist 50 kHz):

**Quick sweep, 16 points evenly spaced up to Nyquist** (≈ 3 kHz steps):
```
31 61 97 127 157 191 223 257 283 317 353 383 419 449 479 509
```

**Log-spaced, 15 points** (good for seeing the low-frequency end):
```
3 5 7 11 17 23 31 47 67 89 131 181 257 359 509
```
(0.29, 0.49, 0.68, 1.07, 1.66, 2.25, 3.03, 4.59, 6.54, 8.69, 12.8, 17.7, 25.1, 35.1, 49.7 kHz)

**All 96 odd primes below 512** (3 → 509, i.e. 0.29 kHz → 49.7 kHz):
```
3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109
113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229
233 239 241 251 257 263 269 271 277 281 283 293 307 311 313 317 331 337 347 349 353
359 367 373 379 383 389 397 401 409 419 421 431 433 439 443 449 457 461 463 467 479
487 491 499 503 509
```

Paste a list into the `M_cycles` value in Maestro's Design Variables (values separated
by spaces). Every point is a full transient, so start with the 16-point list.
If `Nfft` or `fs` changes, regenerate the list:
```
python -c "N=1024; print(*[m for m in range(3, N//2) if all(m % d for d in range(2, int(m**.5) + 1))])"
```

---

## Sweeping the input amplitude

Run it as a **separate sweep** from the frequency sweep: fix `M_cycles` (e.g. 31,
3.03 kHz) and sweep `v_ref`. `v_ref` is the peak differential input; full scale is
1.8 V. The values below step down by a fixed number of dB each time
(dBFS = 20·log10(v_ref / 1.8), i.e. dB below full scale; 0 dBFS = 1.8 V, −6 dBFS = half).

**Sine test (`v_ref`):**
```
1.6993 1.6043 1.4298 1.2743 0.9021 0.5692 0.18 0.0569 0.018 0.0057 0.0018
```
= −0.5, −1, −2, −3, −6, −10, −20, −30, −40, −50, −60 dBFS.
Stop at about −0.5 dBFS: at 0 dBFS (1.8) the peaks start to clip.

**Two-tone test (`v_ref` is each tone):** the two tones add, so each must stay ≤ 0.9:
```
0.9 0.8021 0.6372 0.4511 0.2846 0.09 0.0285 0.009
```

The histogram (INL/DNL) test is run at a fixed, slightly over-full-scale amplitude, so
it is not swept.

Plot with `python maestro_sweep.py <export>`: a `v_ref` sweep is plotted against dBFS,
with the ideal 8-bit SINAD line (SINAD falls 1 dB per dB of input).

**Both at once** (e.g. 3 frequencies × 11 amplitudes = 33 simulations) also works:
Maestro runs every combination, and
`python maestro_sweep.py <export> --x v_ref` draws one SINAD-vs-amplitude line per
frequency (`--x M_cycles` gives one SINAD-vs-frequency line per amplitude).

---

## Histogram test

For a test whose name contains `hist`, the export also writes per point `hist.csv` (one row
per code 0–255: count and cumulative count) and `hist_info.csv` (number of samples, codes
hit, lowest/highest code, record time, `t_sim`, `fs`, `fin_1`, `M_cycles`, `Nfft`, `v_ref`,
...). The codes are recovered from `vout` with the ideal DAC's scale
(`code = vout·128/1.8 + 127.5`; `mxNbits`/`mxDacVref` at the top of `export_sine.ocn`).
This replaces Maestro's `histogram2D(samples 50 ...)` outputs, which bin `vout` into 50
bins rather than one per code.

**Getting a histogram run into Python** (after the run has finished in Maestro):
```
cd analog/maestro_pipeline                # in your clone of the repo
python maestro_sweep.py --pull            # export, copy and plot
```
For a histogram test `maestro_sweep.py` prints the run settings and saves `pt<N>/hist.png`
(hits per code and the cumulative histogram), using `histogram.py`. That file is where the
histogram code lives (`analyse()` runs for every point); it can also be run on its own:
`python histogram.py [data/exports/<folder>]`. In your own code or notebook (run from this folder):
```
import sys; sys.path.append(".")      # or the path to analog/maestro_pipeline
from histogram import find_points, load_point
pt = find_points()[0]                  # newest histogram export, design point 1
hist, info = load_point(pt)            # hist: code, count, cumulative; info: dict of settings
H = hist["count"].to_numpy()           # H[k] for k = 0..255, as np.bincount in sine_hist_test.ipynb
```
The INL/DNL calculation is left for you to fill in (`analyse()` in `histogram.py`).

## Two-tone test: outputs and sweeps

**Maestro outputs** (test `sar_adc_sine_two_tone`). `spectrumMeas()` can't do two-tone
SFDR: it takes the largest bin as the signal and the next largest, the other tone, as the
worst spur. These outputs exclude both tones instead (each expression is one line):

| Output | Expression |
|---|---|
| `bin` | `VAR("fs")/VAR("Nfft")` |
| `spec` | `mag(fft_vout)` |
| `tone` | `max(value(spec VAR("fin_1")) value(spec VAR("fin_2")))` |
| `spur` | `max(ymax(clip(spec bin VAR("fin_1")-bin)) ymax(clip(spec VAR("fin_1")+bin VAR("fin_2")-bin)) ymax(clip(spec VAR("fin_2")+bin VAR("fs")/2)))` |
| `SFDR_2TONE` | `dB20(tone/spur)` |
| `IMD3` | `10*log10((V3low**2 + V3high**2)/(V1**2 + V2**2))` |
| `IMD2` | `10*log10(max(Vplus**2 + Vmin**2 1e-12)/(V1**2 + V2**2))` |

`spur` is the largest bin below tone 1 (DC skipped), between the tones, and above tone 2
up to fs/2; `clip(spec a b)` keeps the spectrum between frequencies a and b, `ymax` takes
its largest value. The ends sit on bins so `clip` doesn't interpolate into a tone. `V1`,
`V2`, `Vplus`, `Vmin`, `V3low`, `V3high` are `abs(value(fft_vout f))` at f1, f2, f1+f2,
f2−f1, 2f1−f2, 2f2−f1. IMD2 has a floor because an ideal (odd-symmetric) ADC has exactly
zero IM2 and log10(0) doesn't evaluate.

`maestro_sweep.py` plots `SFDR_2TONE`, `IMD3` and `IMD2` by default. (`SFDR_2TONE` was
checked against the same calculation done in Python on the exported FFTs: identical.)

**Amplitude sweep** (`v_ref` is each tone; the tones add, so keep `v_ref` ≤ 0.9):
```
0.9 0.8021 0.6372 0.4511 0.2846 0.09 0.0285 0.009
```
(−6, −7, −9, −12, −16, −26, −36, −46 dBFS per tone.) Plotted against dBFS per tone.

**Frequency sweep:** keep the tone spacing fixed (8 bins = 781 Hz) and sweep tone 1:
set `M_cycles_2` to `M_cycles_1+8` and sweep `M_cycles_1` with
```
17 31 47 61 79 97 113 127 139 157 173 191 211 223 239 251
```
(tone 1 from 1.7 to 24.5 kHz). Plotted against fin_1. The list stops at 251 so that every
product the outputs read, including the sum f1+f2 (510 bins at 251 → 49.8 kHz), stays
below fs/2; above that `value()` would ask for a frequency the FFT doesn't have. Going
higher needs `fplus` and `f3high` folded back below fs/2, e.g.
`min(VAR("fin_1")+VAR("fin_2") VAR("fs")-VAR("fin_1")-VAR("fin_2"))`.

---

## Adapting to another testbench

- **Different paths:** `SIMROOT` / `RDBROOT` in `export_results.sh` (see setup).
- **Different signal:** `SIGNALS='"/out"'` (the signal that is sampled and FFT'd).
- **Different design-variable names:** the list `mxVarNames` at the top of `export_sine.ocn`
  says which variables go into `vars.csv`; `t0`, `t1`, `tstep` and `Nfft` are needed for
  the samples and FFT. `foms.csv` takes all variables automatically.
- **Folder names:** test names are shortened by removing `sar_adc_sine_` (last step of
  `export_results.sh`).
- **Full scale / resolution for the plots:** `FULL_SCALE` (1.8 V) and `NBITS` (8) at the
  top of `maestro_sweep.py`.
- **Exporting from the CIW instead of a terminal:**
  `load("~/maestro_pipeline/export_sine.ocn")` then
  `mxExport("<SIMROOT>/ExplorerRun.0" "~/somewhere")`. This does the CSVs but not
  `foms.csv` or the `.rdb` copy.

---

## What goes into git

`.gitignore` keeps the scripts and README, and from each export only the summary:
`export.txt`, `<test>/foms.csv`, `sweep_<test>.csv` and `sweep_<test>.png`, and for histogram
tests `pt<N>/hist.png`, `hist.csv` and `hist_info.csv`. The per-point raw data
(`samples.csv`, `fft.csv`, `vars.csv`), the `.rdb` databases, `ocean.log` (it starts with Cadence's licence
banner) and `vm_settings.local.sh` stay on your computer.

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | Use the full path, `~/maestro_pipeline/export_results.sh` |
| `no results at .../ExplorerRun.0` | `SIMROOT` is wrong, or nothing has been run yet |
| `warning: no ...rdb, skipping foms.csv` | `RDBROOT` is wrong |
| `ocean not on PATH` | Open a new terminal so the Cadence setup in `.bashrc` is loaded |
| A test is missing from the export | It has no results in the latest run (only a netlist). Run it in Maestro first |
| Something else | Look at `ocean.log` in the export folder |
| `maestro_sweep.py`: `no exports in data/exports` | Run `fetch_exports.sh` first |
| `maestro_sweep.py`: `nothing swept` | That run has a single design point; there is nothing to plot against |
