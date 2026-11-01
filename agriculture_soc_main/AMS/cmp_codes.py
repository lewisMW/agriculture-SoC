#!/usr/bin/env python3
"""cmp_codes.py -- compare an AMS run's ADC codes with the ideal model's, sample
by sample.

Run the same test twice with EXTRA_DEFINES=+define+SENSING_DEBUG, which logs
every FIFO push with its time stamp: once plain digital, where
ADC/sim/sar_afe_model.v gives the ideal code, and once in AMS. The digital
timing is identical, so the samples pair up by time stamp.

  cmp_codes.py [-v] [--fin HZ] IDEAL_LOG AMS_LOG [IDEAL_LOG AMS_LOG ...]

For each pair it prints the range of the error (AMS - ideal, in LSB); -v also
lists every sample. Over all pairs it then fits the error as
  offset + gain * (v - 128) + lag * dv/dt
where v is a sine fitted to the ideal codes at the test tone (FIN_HZ, 5 kHz by
default). The rms left after the fit is the noise and quantisation.
"""
import argparse
import math
import re

PAT = re.compile(r"\[SENS (\d+)(?: ns)?\] fifo_push +data=0x([0-9a-fA-F]+)")


def samples(path):
    with open(path, errors="replace") as f:
        return [(int(m.group(1)), int(m.group(2), 16)) for m in map(PAT.search, f) if m]


def lstsq(rows, ys):
    """Least squares by the normal equations; the systems here are 2x2 or 3x3."""
    n = len(rows[0])
    m = [[sum(r[i] * r[j] for r in rows) for j in range(n)] + [sum(r[i] * y for r, y in zip(rows, ys))]
         for i in range(n)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(m[r][c]))
        m[c], m[p] = m[p], m[c]
        for r in range(n):
            if r != c:
                f = m[r][c] / m[c][c]
                m[r] = [x - f * y for x, y in zip(m[r], m[c])]
    return [m[i][n] / m[i][i] for i in range(n)]


def rms(xs):
    return math.sqrt(sum(x * x for x in xs) / len(xs))


ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
ap.add_argument("-v", action="store_true", help="list every sample")
ap.add_argument("--fin", type=float, default=5000.0, help="test tone in Hz (default 5000)")
ap.add_argument("logs", nargs="+", help="IDEAL_LOG AMS_LOG pairs")
a = ap.parse_args()
if len(a.logs) % 2:
    ap.error("logs come in IDEAL_LOG AMS_LOG pairs")

w = 2 * math.pi * a.fin * 1e-9  # rad/ns
rows, errs = [], []
for ideal_log, ams_log in zip(a.logs[0::2], a.logs[1::2]):
    ideal, ams = samples(ideal_log), dict(samples(ams_log))
    pairs = [(t, i, ams[t]) for t, i in ideal if t in ams]
    print(f"{ams_log}: ideal {len(ideal)}, ams {len(ams)}, paired {len(pairs)}")
    if not pairs:
        continue
    e = [c - i for _, i, c in pairs]
    print(f"  ams - ideal: {min(e):+d} to {max(e):+d} LSB, mean {sum(e) / len(e):+.2f}")
    if a.v:
        for t, i, c in pairs:
            print(f"    t={t:>9d} ns  ideal 0x{i:02x} ({i:3d})  ams 0x{c:02x} ({c:3d})  "
                  f"{c - i:+3d}{'  <--' if abs(c - i) > 1 else ''}")
    # the unquantised input: a sine fitted to the ideal codes
    k0, ks, kc = lstsq([[1, math.sin(w * t), math.cos(w * t)] for t, _ in ideal], [i for _, i in ideal])
    for t, _, c in pairs:
        v = k0 + ks * math.sin(w * t) + kc * math.cos(w * t)
        dv = (ks * math.cos(w * t) - kc * math.sin(w * t)) * w * 1e3  # LSB/us
        rows.append([1.0, v - 128.0, dv])
        errs.append(c - v)

if len(errs) > 3:
    o, g, lag = lstsq(rows, errs)
    left = [e - (o + g * r[1] + lag * r[2]) for e, r in zip(errs, rows)]
    print(f"fit over {len(errs)} samples: offset {o:+.2f} LSB, gain {100 * g:+.2f} %, lag {lag:+.3f} us; "
          f"rms {rms(errs):.2f} LSB before, {rms(left):.2f} after")
