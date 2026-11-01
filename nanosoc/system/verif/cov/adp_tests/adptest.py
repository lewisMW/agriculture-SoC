#!/usr/bin/env python3
"""adptest.py - self-checking system-level tests for the nanosoc coverage harness.

Each test is an ADP (ASCII debug protocol) command script streamed into the
nanosoc debug controller by the Verilator harness (../harness). The debugger is
a real AHB master even though the Cortex-M0 is an idle stand-in on a machine
without ARM IP, so the script drives real bus traffic through the bus matrix,
the SYSIO region, sysctrl and the sensing peripheral. The response stream
(logs/extadp_out.log) is parsed and every response is checked against what the
design must return - values, bus-error flags ('!'), poll results.

Writing a test (see tests.py):
    t = AdpTest("sens_ahb", "sensing peripheral over AHB")
    t.wr(0x60000100, 0x11223344)                 # A + W (word)
    t.rd(0x60000100, expect=0x11223344, desc="PLL read-back")
    t.rd(0x60000101, size=1, expect=0x33, desc="byte lane 1")
    t.rd(0xE0000000, err=True, desc="unmapped -> bus error")
    t.wait_until(0x60000004, mask=0x3, value=0x1, desc="FIFO not empty")
    t.run()

Stream framing (nanosoc_axi_stream_io_8_txd_from_file, FAST_LOAD=1): the file
is appended after the fixed prologue (ESC, "A 20000000", "C 201" = debugger
reset), bytes 18-25 are never written (0x00 = ADP exit) and the last 9 bytes of
the file are never sent (coverage_plan.md F11). So every script starts with ESC
(re-enter ADP), a marker address, and ends with padding.

Checks marked with bug=<id> are suspected-RTL-bug checks: they are reported as
"FAIL [SUSPECTED RTL BUG <id>]" and are not weakened to pass.
"""
import os
import re
import shutil
import subprocess
import sys

COV_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BIN = os.path.join(COV_DIR, "build", "obj_dir", "Vnsc")
RUNS = os.path.join(COV_DIR, "runs")
MARK = 0x0BADC0DE
END_MARK = 0x0E0DE0D0
TOK = re.compile(r"([ACRSWXFMPUV])(!?)\s?0x([0-9a-fA-F]+)")
DIG = {1: 2, 2: 4, 4: 8}


class Exp:
    """One expected response token."""

    def __init__(self, letter, desc=None, check=None, err=False, bug=None, capture=None,
                 optional=False, resync=None):
        self.letter = letter
        self.optional = optional  # may be missing (e.g. cut short by a pin reset)
        self.resync = resync      # skip ahead to the 'A <resync>' echo
        self.desc = desc          # None = alignment only, not counted as a check
        self.check = check        # callable(value, captures) -> bool, or None
        self.err = err            # expected '!' flag; None = don't care
        self.bug = bug
        self.capture = capture    # name to store the value under


class AdpTest:
    def __init__(self, name, title, max_cycles=1500000, plusargs=""):
        self.name = name
        self.title = title
        self.max_cycles = max_cycles
        self.plusargs = plusargs
        self.lines = []
        self.exps = []
        self.posts = []

    # ------------------------------------------------------------ commands
    def line(self, text, exps):
        self.lines.append(text)
        self.exps.extend(exps)

    def comment(self, _text):
        pass

    def A(self, addr):
        self.line("A 0x%08x" % addr, [Exp("A", check=lambda v, c, a=addr: v == a)])

    def W(self, data, size=4, err=False, desc=None, bug=None):
        self.line("W 0x%0*x" % (DIG[size], data), [Exp("W", desc, err=err, bug=bug)])

    def R(self, n=1, size=4, expect=None, mask=0xFFFFFFFF, err=False, desc=None, bug=None,
          check=None, capture=None):
        """Read n items of `size` from the current address (auto-increments)."""
        assert 1 <= n < (1 << (4 * DIG[size]))
        exps = []
        for i in range(n):
            ex = expect[i] if isinstance(expect, (list, tuple)) else expect
            fn = None
            if check is not None:
                fn = (lambda v, c, f=check, m=mask: f(v & m, c))
            elif ex is not None:
                fn = (lambda v, c, ex=ex, m=mask: (v & m) == (ex & m))
            d = desc if (n == 1 or desc is None) else "%s [%d]" % (desc, i)
            cap = capture if (n == 1 or capture is None) else "%s%d" % (capture, i)
            exps.append(Exp("R", d, check=fn, err=err, bug=bug, capture=cap))
        self.line("R %0*x" % (DIG[size], n), exps)

    def wr(self, addr, data, size=4, **kw):
        self.A(addr)
        self.W(data, size, **kw)

    def rd(self, addr, size=4, **kw):
        self.A(addr)
        self.R(1, size, **kw)

    def raw(self, text, letters, desc=None, err=None, check=None, bug=None):
        exps = [Exp(l) for l in letters]
        if exps:
            exps[-1] = Exp(letters[-1], desc, check=check, err=err, bug=bug)
        self.line(text, exps)

    def delay(self, n_lines):
        """Blank lines: the ADP just prompts, the system keeps running."""
        for _ in range(n_lines):
            self.lines.append("")

    def poll(self, addr, mask, value, count=0xFFF, expect_match=True, desc=None, bug=None):
        """ADP poll: read `addr` until (data & mask) == value, at most `count` reads.
        Echo is 'P' on a match and 'P!' when the count runs out."""
        self.A(addr)
        self.line("M 0x%08x" % mask, [Exp("M")])
        self.line("V 0x%08x" % value, [Exp("V")])
        self.line("P 0x%04x" % count, [Exp("P", desc, err=(not expect_match), bug=bug)])

    def wait_until(self, addr, mask, value, count=0xFFF, desc=None, bug=None):
        self.poll(addr, mask, value, count, True, desc, bug)

    def spin(self, count=0x200):
        """Busy-wait: poll a register for a value it never has (sensing STATUS
        bit 31 is reserved-0). Each poll is one bus read."""
        self.A(0x60000004)
        self.line("M 0x80000000", [Exp("M")])
        self.line("V 0x80000000", [Exp("V")])
        self.line("P 0x%04x" % count, [Exp("P", err=True)])

    def resync(self, tag):
        """After an asynchronous event (NRST pin pulse) re-enter ADP and skip the
        response stream ahead to this point."""
        # an ESC that arrives while the chip is still in reset is dropped, and
        # the ADP then forwards everything to STDIN until the next ESC: send
        # several (extra ESCs in command mode are just unknown characters)
        for _ in range(4):
            self.lines.append("")
            self.lines.append("\x1b")
        self.lines.append("")
        v = 0x0E5E0000 | tag
        self.line("A 0x%08x" % v, [Exp("A", resync=v)])

    def long_spin(self, count=0xFFFF):
        """A long busy-wait that an NRST pulse is expected to cut short."""
        self.A(0x60000004)
        self.line("M 0x80000000", [Exp("M")])
        self.line("V 0x80000000", [Exp("V")])
        self.line("P 0x%04x" % count, [Exp("P", err=None, optional=True)])

    def debug_reset(self):
        """ADP GPO bit0 -> DEBUG_RESETREQ -> system reset (resets the ADP too, so
        re-enter the monitor with ESC)."""
        self.line("C 201", [])
        self.lines.append("\x1b")
        self.lines.append("")

    def post(self, fn, desc, bug=None):
        self.posts.append((fn, desc, bug))

    # ---------------------------------------------------------------- run
    def script(self):
        body = "\n".join(self.lines)
        return "\x1b\nA 0x%08x\n%s\nA 0x%08x\n%s" % (MARK, body, END_MARK, "\n" * 24)

    def run(self):
        d = os.path.join(RUNS, "adp_" + self.name)
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(os.path.join(d, "logs"))
        with open(os.path.join(d, "adp.cmd"), "w", newline="\n") as f:
            f.write(self.script())
        cmd = ("ulimit -v 4000000; nice -n 19 %s +max_cycles=%d %s "
               "+verilator+coverage+file+coverage.dat > sim.log 2>&1"
               % (BIN, self.max_cycles, self.plusargs))
        subprocess.run(cmd, shell=True, cwd=d, check=False)
        if os.path.exists(os.path.join(d, "coverage.dat")):
            shutil.copy(os.path.join(d, "coverage.dat"),
                        os.path.join(COV_DIR, "coverage_adp_%s.dat" % self.name))
        out = open(os.path.join(d, "logs", "extadp_out.log"), encoding="latin-1").read()
        return self.check(out, d)

    def check(self, out, d):
        log = []
        npass = nfail = nbug = 0

        def report(ok, desc, bug=None):
            nonlocal npass, nfail, nbug
            if ok:
                npass += 1
                log.append("PASS %s" % desc)
            else:
                nfail += 1
                if bug:
                    nbug += 1
                    log.append("FAIL [SUSPECTED RTL BUG %s] %s" % (bug, desc))
                else:
                    log.append("FAIL %s" % desc)

        start = out.find("A 0x%08x" % MARK)
        toks = TOK.findall(out[start:]) if start >= 0 else []
        toks = toks[1:]  # drop the marker echo
        caps = {}
        aligned = True
        j = 0                                   # token index
        for i, ex in enumerate(self.exps):
            if ex.resync is not None:
                k = j
                while k < len(toks) and not (toks[k][0] == "A" and int(toks[k][2], 16) == ex.resync):
                    k += 1
                if k >= len(toks):
                    report(False, "resync point 0x%08x never echoed (ADP did not recover after the reset?)"
                           % ex.resync)
                    aligned = False
                    break
                j = k + 1
                continue
            if j >= len(toks):
                if ex.optional:
                    continue
                report(False, "ADP stream ended after %d responses, %d of %d expectations met (raise max_cycles?)"
                       % (len(toks), i, len(self.exps)))
                aligned = False
                break
            letter, bang, val = toks[j]
            v = int(val, 16)
            if letter != ex.letter:
                if ex.optional:
                    continue
                report(False, "response %d: expected '%s', got '%s%s0x%s' - stream misaligned"
                       % (j, ex.letter, letter, bang, val))
                aligned = False
                break
            j += 1
            if ex.capture:
                caps[ex.capture] = v
            ok = True
            why = []
            if ex.err is not None and (bang == "!") != ex.err:
                ok = False
                why.append("bus %s" % ("ERROR" if bang else "OKAY"))
            if ex.check is not None and not ex.check(v, caps):
                ok = False
                why.append("value 0x%s" % val)
            if ex.desc is not None:
                report(ok, ex.desc + ("" if ok else "  <- " + ", ".join(why)), ex.bug)
            elif not ok:
                report(False, "response %d '%s%s0x%s' unexpected (%s)"
                       % (i, letter, bang, val, ", ".join(why)))
        if aligned:
            done = j < len(toks) and toks[j][0] == "A" and int(toks[j][2], 16) == END_MARK
            report(done, "script ran to its end marker")
            for fn, desc, bug in self.posts:
                try:
                    ok = bool(fn(caps))
                except KeyError as e:
                    ok = False
                    desc += "  <- missing capture %s" % e
                report(ok, desc, bug)
        with open(os.path.join(d, "check.log"), "w") as f:
            f.write("\n".join(log) + "\n")
        for l in log:
            if l.startswith("FAIL"):
                print("  " + l)
        line = "=== ADP-%s: %d PASSED, %d FAILED (%d of them suspected RTL bugs) ===" % (
            self.name.upper(), npass, nfail, nbug)
        print(line)
        return npass, nfail, nbug


def main(tests):
    names = sys.argv[1:] or list(tests)
    tot = [0, 0, 0]
    for n in names:
        t = tests[n]()
        print("--- %s: %s" % (n, t.title))
        r = t.run()
        tot = [a + b for a, b in zip(tot, r)]
    print("=== ADP-ALL: %d PASSED, %d FAILED (%d of them suspected RTL bugs) ===" % tuple(tot))
    return 0
