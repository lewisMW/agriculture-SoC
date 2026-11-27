#!/usr/bin/env python3
"""signoff.py - one-command verdict for the sensing peripheral.

    python3 verif/signoff.py               full sign-off: every bench, the
                                           functional coverage gate and the
                                           code coverage gate
    python3 verif/signoff.py --benches     benches only (`make verify`)
    python3 verif/signoff.py --free        benches that need no ARM IP
    python3 verif/signoff.py --only gap,clo   a subset of steps by name
    python3 verif/signoff.py --list        list the steps

Run from agriculture_soc_main/ (the makefile targets do). Environment:
    STUB_RTC=1      PL031 stand-in (no ARM IP needed). The verdict is then
                    marked STUB: every number must be re-run with the real PL031.
    BUILD_ROOT=dir  build directories (and the step logs) on a local disk.
    CLEAN_BUILDS=1  with BUILD_ROOT: delete each step's build directories as
                    soon as the step has finished (the step logs are kept), so
                    the disk only ever holds one step's build (~1.2 GB at most
                    instead of ~5 GB). Later steps rebuild what they need.
    OPEN_BUGS_OK=1  exit 0 when the only failures are checks tagged
                    [SUSPECTED RTL BUG <ID>] with <ID> in verif/cov/open_bugs.txt.
                    The verdict still says OPEN BUGS and lists them.

What fails the run:
  - a step that exits non-zero,
  - a bench that does not print every summary line it is expected to print
    (an SVA failure aborts the simulation before its summary),
  - any "N FAILED" with N > 0. Failures tagged [SUSPECTED RTL BUG <ID>] are
    counted per ID; the rest are untagged and can never be excused,
  - an assertion failure or %Error in a run log,
  - the coverage gates (unwaived hole, viol_ hit, waiver that is wrong).

Writes verif/cov/SIGNOFF_REPORT.txt and verif/cov/OPEN_BUGS_REPORT.md (the
hand-off for the owners of the open bugs: what fails, where, how to reproduce).
"""
import argparse
import configparser
import datetime
import os
import re
import subprocess
import sys
import time
import functools
import shutil
print = functools.partial(print, flush=True)  # noqa: A001 - progress through a pipe

HERE = os.path.dirname(os.path.abspath(__file__))
AGRI = os.path.dirname(HERE)
REPO = os.path.dirname(AGRI)
COV = os.path.join(HERE, "cov")

# ---------------------------------------------------------------------------
# Step table: name, group, command (run in AGRI), expected summary names.
#   group  free  - no ARM IP needed
#          ip    - needs the PL031 (real, or the stand-in with STUB_RTC=1)
#          cm0   - needs the Cortex-M0 + CMSDK kit (never stubbed)
#          cov   - gates judged on exit status: lint, SVA mutation proof,
#                  functional coverage, code coverage
# Expected names are matched against "=== <NAME>: N PASSED, M FAILED ... ===".
# ---------------------------------------------------------------------------
SOAK_SEEDS = int(os.environ.get("SEEDS", "10"))

STEPS = [
    ("fifo_rand",   "free", "make -C FIFO rand",       ["FIFO"]),
    ("fsm",         "free", "make -C FSM all",         ["FSM"]),
    ("fsm_seq",     "free", "make -C FSM seq",         ["FSM-SEQ"]),
    ("adc",         "free", "make -C ADC all",         ["SAR_ADC_TB"]),
    ("adc_cal",     "free", "make -C ADC cal",         ["SAR_ADC_CAL[div4]"]),
    ("adc_div",     "free", "make -C ADC div",         ["SAR_ADC_CAL[div1]", "SAR_ADC_CAL[div2]", "SAR_ADC_CAL[div8]"]),
    ("uvm_fifo",    "free", "make -C verif/uvm/fifo build run", ["FIFO-UVM"]),
    ("rtc",         "ip",   "make -C RTC all",         ["RTC"]),
    ("rtc_rand",    "ip",   "make -C RTC rand",        ["RTC-RAND"]),
    ("rtc_clo",     "ip",   "make -C RTC clo",         ["RTC-CLO"]),
    ("wrap",        "ip",   "make -C Wrapper all",     ["WRAPPER"]),
    ("wrap_rand",   "ip",   "make -C Wrapper rand",    ["WRAPPER-RAND"]),
    ("wrap_sva",    "ip",   "make -C Wrapper sva",     ["WRAPPER-RAND"]),
    ("gap",         "ip",   "make -C Wrapper gap",     ["SENS-GAP"]),
    ("clo",         "ip",   "make -C Wrapper clo",     ["SENS-CLO"]),
    ("adcdiv",      "ip",   "make -C Wrapper adcdiv",  ["SENS-CLO[div1]", "SENS-CLO[div2]", "SENS-CLO[div8]"]),
    ("params",      "ip",   "make -C Wrapper params",  ["WRAPPER", "SENS-GAP"]),
    ("soak",        "ip",   "make -C Wrapper soak SEEDS=%d" % SOAK_SEEDS,
                                                       ["SENS-SOAK[seed%d]" % s for s in range(1, SOAK_SEEDS + 1)]),
    ("rob",         "ip",   "make -C Wrapper rob",     ["SENS-ROB"]),
    ("xsafe",       "ip",   "make -C Wrapper xsafe",   ["WRAPPER-XSAFE[seed%d]" % s for s in range(1, 6)]),
    ("uvm_sensing", "ip",   "make -C verif/uvm/wrapper build run", ["SENSING-UVM"]),
    ("soc_check",   "cm0",  "make check",              []),
    ("soc_reset",   "cm0",  "make reset_rand",         []),
    ("lint",        "cov",  "python3 verif/lint_check.py", []),
    ("sva_mut",     "cov",  "python3 verif/sva_mut/run_mutations.py", []),
    ("cov_func",    "cov",  "make -C verif/cov all && make -C verif/cov gate", []),
    ("cov_code",    "cov",  "make -C verif/cov code",  []),
]

SUMMARY_RE = re.compile(r"===\s*(.+?):\s*(\d+)\s+PASSED,\s*(\d+)\s+FAILED(.*?)===")
BUG_RE = re.compile(r"^FAIL\b.*\[SUSPECTED RTL BUG ([A-Za-z0-9_-]+)\]")
FAIL_RE = re.compile(r"^FAIL\b")
ABORT_RE = re.compile(r"Assertion failed|%Error|WATCHDOG TIMEOUT|\bTIMEOUT\b|Segmentation fault|Killed")


def cm0_available():
    arm = os.environ.get("ARM_IP_LIBRARY_PATH", "")
    return bool(arm) and os.path.isdir(os.path.join(arm, "Cortex-M0"))


def pl031_available():
    if os.environ.get("STUB_RTC") == "1":
        return True
    arm = os.environ.get("ARM_IP_LIBRARY_PATH", "")
    return bool(arm) and os.path.isdir(os.path.join(arm, "PL031"))


def load_open_bugs():
    cp = configparser.ConfigParser(interpolation=None)
    path = os.path.join(COV, "open_bugs.txt")
    if os.path.exists(path):
        cp.read(path)
    return {s: dict(cp[s]) for s in cp.sections()}


def run_step(name, cmd, logdir, timeout):
    log = os.path.join(logdir, "%s.log" % name)
    t0 = time.time()
    with open(log, "w") as f:
        f.write("$ %s\n" % cmd)
        f.flush()
        try:
            rc = subprocess.run(cmd, shell=True, cwd=AGRI, stdout=f, stderr=subprocess.STDOUT,
                                timeout=timeout).returncode
        except subprocess.TimeoutExpired:
            rc = "timeout"
    with open(log, errors="replace") as f:
        text = f.read()
    return rc, text, log, time.time() - t0


def analyse(name, group, rc, text, expected):
    """-> dict with summaries, per-bug fails, untagged count, problems."""
    res = {"summaries": [], "bugs": {}, "bug_lines": {}, "untagged": 0, "problems": []}
    if group == "cov":
        if rc != 0:
            res["problems"].append("gate failed (exit %s): %s" % (rc, "; ".join(
                l.strip() for l in text.splitlines() if l.startswith(("RESULT", "ERROR", "HOLE")))[:300]))
        return res
    tagged_total = 0
    for line in text.splitlines():
        m = BUG_RE.match(line)
        if m:
            bid = m.group(1)
            res["bugs"][bid] = res["bugs"].get(bid, 0) + 1
            res["bug_lines"].setdefault(bid, []).append(line.strip())
            tagged_total += 1
        elif ABORT_RE.search(line) and not line.startswith(("PASS", "  ")) and "FAILED" not in line:
            # a FAIL line naming a timeout is counted by the summary already
            if not FAIL_RE.match(line):
                res["problems"].append("log: " + line.strip()[:160])
    failed_total = 0
    seen = []
    for m in SUMMARY_RE.finditer(text):
        nm, p, fl = m.group(1).strip(), int(m.group(2)), int(m.group(3))
        res["summaries"].append((nm, p, fl, m.group(4).strip()))
        seen.append(nm)
        failed_total += fl
    for e in expected:
        if e not in seen:
            res["problems"].append("expected summary line '=== %s: ... ===' not printed "
                                   "(build failed, bench missing, or the run aborted)" % e)
    if expected and not res["summaries"]:
        pass  # already reported per expected name
    res["untagged"] = max(0, failed_total - tagged_total)
    if rc not in (0,):
        res["problems"].append("step exited %s" % rc)
    return res


def clean_build_root(build_root, keep):
    """Delete everything directly inside build_root except the log directory."""
    root = os.path.realpath(build_root)
    if root in ("/", os.path.realpath(os.path.expanduser("~"))) or not os.path.isdir(root):
        return
    for e in os.listdir(root):
        p = os.path.join(root, e)
        if os.path.realpath(p) == os.path.realpath(keep):
            continue
        if os.path.isdir(p) and not os.path.islink(p):
            shutil.rmtree(p, ignore_errors=True)
        else:
            try:
                os.remove(p)
            except OSError:
                pass


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--benches", action="store_true", help="benches only (no coverage gates)")
    ap.add_argument("--free", action="store_true", help="only steps that need no ARM IP")
    ap.add_argument("--only", default="", help="comma-separated step names")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--timeout", type=int, default=7200, help="per-step timeout, seconds")
    a = ap.parse_args()

    if a.list:
        for n, g, c, e in STEPS:
            print("%-12s %-5s %s" % (n, g, c))
        return 0

    only = [s for s in a.only.split(",") if s]
    unknown = [s for s in only if s not in [x[0] for x in STEPS]]
    if unknown:
        print("unknown step(s): %s (see --list)" % ", ".join(unknown))
        return 2

    stub = os.environ.get("STUB_RTC") == "1"
    open_ok = os.environ.get("OPEN_BUGS_OK") == "1"
    build_root = os.environ.get("BUILD_ROOT", "")
    logdir = os.path.join(build_root, "signoff_logs") if build_root else os.path.join(COV, "signoff_logs")
    clean_builds = os.environ.get("CLEAN_BUILDS") == "1"
    if clean_builds and not build_root:
        print("CLEAN_BUILDS=1 needs BUILD_ROOT=<dir> (it only ever deletes inside BUILD_ROOT)")
        return 2
    os.makedirs(logdir, exist_ok=True)
    known = load_open_bugs()

    mode = "only " + ",".join(only) if only else ("free" if a.free else ("benches" if a.benches else "full"))
    print("===== SIGN-OFF (%s)%s =====" % (mode, "  [STUB_RTC=1: PL031 stand-in, re-run with the real PL031]" if stub else ""))

    rows = []
    for name, group, cmd, expected in STEPS:
        if only and name not in only:
            continue
        if not only:
            if a.free and group != "free":
                continue
            if a.benches and group == "cov":
                continue
        if group == "cm0" and not cm0_available():
            rows.append((name, group, "SKIPPED", "needs the Cortex-M0/CMSDK kit (ARM_IP_LIBRARY_PATH)", None, 0))
            print("  %-12s SKIPPED  (needs the Cortex-M0 kit)" % name)
            continue
        if group == "ip" and not pl031_available():
            rows.append((name, group, "MISSING", "needs the PL031 (ARM_IP_LIBRARY_PATH) or STUB_RTC=1", None, 0))
            print("  %-12s NOT RUN  (no PL031 and STUB_RTC is not 1)" % name)
            continue
        print("  %-12s ..." % name, end="", flush=True)
        rc, text, log, dt = run_step(name, cmd, logdir, a.timeout)
        if clean_builds:
            clean_build_root(build_root, logdir)
        res = analyse(name, group, rc, text, expected)
        if res["problems"] or res["untagged"]:
            st = "FAIL"
        elif res["bugs"]:
            st = "OPENBUG"
        else:
            st = "PASS"
        rows.append((name, group, st, log, res, dt))
        summ = "; ".join("%s %d/%d" % (n, p, f) for n, p, f, _ in res["summaries"])
        extra = ""
        if res["bugs"]:
            extra += "  bugs: " + ", ".join("%s x%d" % kv for kv in sorted(res["bugs"].items()))
        if res["untagged"]:
            extra += "  UNTAGGED FAILURES: %d" % res["untagged"]
        print("\r  %-12s %-8s %5.0fs  %s%s" % (name, st, dt, summ, extra))
        for p in res["problems"][:6]:
            print("               ! %s" % p)

    # ---- verdict -------------------------------------------------------------
    bugs_seen = {}
    bug_lines = {}
    for name, group, st, log, res, dt in rows:
        if res:
            for b, n in res["bugs"].items():
                bugs_seen[b] = bugs_seen.get(b, 0) + n
                bug_lines.setdefault(b, []).extend("%s: %s" % (name, l) for l in res["bug_lines"][b])
    unknown_bugs = sorted(b for b in bugs_seen if b not in known)
    hard_fail = [r for r in rows if r[2] in ("FAIL", "MISSING")]
    stale = sorted(b for b in known if b not in bugs_seen) if mode == "full" else []

    if hard_fail or unknown_bugs:
        verdict, rc = "FAIL", 1
    elif bugs_seen:
        verdict = "OPEN BUGS ONLY"
        rc = 0 if open_ok else 1
    else:
        verdict, rc = "PASS", 0

    lines = []
    lines.append("SENSING PERIPHERAL SIGN-OFF REPORT")
    lines.append("generated %s, mode %s" % (datetime.datetime.now().strftime("%Y-%m-%d %H:%M"), mode))
    lines.append("PL031: %s" % ("STAND-IN (STUB_RTC=1) - every number below must be re-run with the real PL031" if stub else "real ARM PL031"))
    try:
        head = subprocess.run("git rev-parse --short HEAD", shell=True, cwd=AGRI, capture_output=True, text=True).stdout.strip()
        dirty = subprocess.run("git status --porcelain -- . ../nanosoc/system", shell=True, cwd=AGRI,
                               capture_output=True, text=True).stdout.strip()
        lines.append("tree: %s%s" % (head, " + uncommitted changes" if dirty else ""))
    except Exception:
        pass
    lines.append("")
    lines.append("%-12s %-8s %6s  %s" % ("step", "status", "time", "summary lines (passed/failed)"))
    for name, group, st, log, res, dt in rows:
        if res is None:
            lines.append("%-12s %-8s %6s  %s" % (name, st, "-", log))
            continue
        summ = "; ".join("%s %d/%d" % (n, p, f) for n, p, f, _ in res["summaries"]) or "-"
        lines.append("%-12s %-8s %5.0fs  %s" % (name, st, dt, summ))
        if res["bugs"]:
            lines.append("%-12s %-8s %6s  open-bug failures: %s" % ("", "", "",
                         ", ".join("%s x%d" % kv for kv in sorted(res["bugs"].items()))))
        if res["untagged"]:
            lines.append("%-12s %-8s %6s  UNTAGGED failures: %d" % ("", "", "", res["untagged"]))
        for p in res["problems"]:
            lines.append("%-12s %-8s %6s  ! %s" % ("", "", "", p))
        lines.append("%-12s %-8s %6s  log: %s" % ("", "", "", log))
    lines.append("")
    if bugs_seen:
        lines.append("OPEN SUSPECTED RTL BUGS (failing checks, counted as failures):")
        for b in sorted(bugs_seen):
            k = known.get(b)
            lines.append("  %-10s %3d failing checks  %s" % (b, bugs_seen[b],
                         ("%s [%s]" % (k.get("title", ""), k.get("owner", ""))) if k else "NOT IN open_bugs.txt"))
        lines.append("  details for the owners: verif/cov/OPEN_BUGS_REPORT.md")
        lines.append("")
    if stale:
        lines.append("STALE open_bugs.txt entries (no bench reports them any more - fixed? remove): " + ", ".join(stale))
        lines.append("")
    if unknown_bugs:
        lines.append("UNKNOWN bug IDs (tagged in a bench but not listed in open_bugs.txt): " + ", ".join(unknown_bugs))
    skipped = [r[0] for r in rows if r[2] == "SKIPPED"]
    if skipped:
        lines.append("SKIPPED (needs the ARM IP): " + ", ".join(skipped))
    lines.append("")
    banner = "VERDICT: %s" % verdict
    if verdict == "OPEN BUGS ONLY":
        banner += " (%s) - exit %d%s" % (", ".join(sorted(bugs_seen)), rc,
                                          " because OPEN_BUGS_OK=1" if open_ok else "; set OPEN_BUGS_OK=1 to accept")
    if stub:
        banner += "  [STUB - re-run with the real PL031]"
    lines.append(banner)

    report = "\n".join(lines) + "\n"
    if mode == "full" or not only:
        with open(os.path.join(COV, "SIGNOFF_REPORT.txt"), "w") as f:
            f.write(report)
    write_bug_report(known, bugs_seen, bug_lines, stub, mode)

    print("")
    print(report)
    return rc


def write_bug_report(known, seen, lines_by_bug, stub, mode):
    out = ["# Open suspected RTL bugs - sensing SoC verification", "",
           "Generated %s by `verif/signoff.py` (mode %s%s). Each bug below fails "
           "the checks listed and is waiting on the owner named under it to confirm "
           "and fix it. Source of this list: `agriculture_soc_main/verif/cov/open_bugs.txt`." % (
               datetime.datetime.now().strftime("%Y-%m-%d %H:%M"), mode,
               ", PL031 stand-in" if stub else ""), ""]
    ids = sorted(set(known) | set(seen))
    if not ids:
        out.append("No open bugs.")
    for b in ids:
        k = known.get(b, {})
        out.append("## %s - %s" % (b, k.get("title", "(not described in open_bugs.txt)")))
        out.append("")
        for key, label in (("owner", "Owner"), ("file", "Where"), ("found", "Found")):
            if k.get(key):
                out.append("- **%s:** `%s`" % (label, k[key]) if key == "file" else "- **%s:** %s" % (label, k[key]))
        out.append("- **Status in this run:** %s" % (
            "%d failing checks" % seen[b] if b in seen else "not reported by any bench run (fixed, or not run in this mode)"))
        if k.get("repro"):
            out.append("- **Reproduce:** `%s`" % k["repro"].split("  ")[0].strip())
        out.append("")
        if k.get("detail"):
            out.append(" ".join(k["detail"].split()))
            out.append("")
        if k.get("expected"):
            out.append("**Expected:** " + " ".join(k["expected"].split()))
            out.append("")
        if b in lines_by_bug:
            out.append("Failing checks:")
            out.append("")
            out.append("```")
            out.extend(lines_by_bug[b][:60])
            if len(lines_by_bug[b]) > 60:
                out.append("... %d more" % (len(lines_by_bug[b]) - 60))
            out.append("```")
            out.append("")
    with open(os.path.join(COV, "OPEN_BUGS_REPORT.md"), "w") as f:
        f.write("\n".join(out) + "\n")


if __name__ == "__main__":
    sys.exit(main())
