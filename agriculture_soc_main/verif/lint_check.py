#!/usr/bin/env python3
"""lint_check.py - lint gate for the sensing peripheral.

Runs verilator --lint-only -Wall on adc_apb_wrapper_rev2 and everything under
it (the PL031 stand-in with STUB_RTC=1, else the ARM PL031 from
ARM_IP_LIBRARY_PATH) and checks every warning in the peripheral RTL against
the `lint` waivers in verif/cov/waivers.txt (pattern file:CODE:signal).
Warnings in simulation models and vendor IP are reported as information.

    python3 verif/lint_check.py          (from agriculture_soc_main/)
Exit 1 on any unwaived warning in the gated files, or a lint waiver that
matches nothing.
"""
import fnmatch, glob, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
AGRI = os.path.dirname(HERE)
SARLOGIC = os.path.join(AGRI, "../analog/cadence/sar_adc/sarlogic/functional/verilog.v")
GATED = {"adc_apb_wrapper_rev2.v", "rtc_control_2.v", "wrapper_control_2.v", "fifo_apb_adc.v",
         "sar_adc.v", "sar_comp_latch.v", "sarlogic.v"}

def short(path):
    return "sarlogic.v" if os.path.abspath(path) == os.path.abspath(SARLOGIC) else os.path.basename(path)

files = ["Wrapper/adc_apb_wrapper_rev2.v", "RTC/rtc_control_2.v", "FIFO/fifo_apb_adc.v", "FSM/wrapper_control_2.v",
         "ADC/sar_adc.v", "ADC/sar_comp_latch.v", SARLOGIC, "ADC/sim/sky130_fd_sc_hd__nand2_1.v",
         "ADC/sim/sar_afe_model.v", "Dummy/dummy_amux.v", "Dummy/dummy_pll.v"]
extra = []
if os.environ.get("STUB_RTC") == "1":
    files.append("verif/stubs/pl031_stub.v")
else:
    arm = os.environ.get("ARM_IP_LIBRARY_PATH", "")
    ip = os.path.join(arm, "PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source")
    if not os.path.isdir(ip):
        print("lint_check: no PL031 at %s (set ARM_IP_LIBRARY_PATH or STUB_RTC=1)" % ip); sys.exit(2)
    files += sorted(glob.glob(os.path.join(ip, "*.v")))
    extra = ["-I" + ip]

cmd = ["verilator", "--lint-only", "-Wall", "-Wno-fatal", "--top-module", "adc_apb_wrapper_rev2"] + extra + files
out = subprocess.run(cmd, cwd=AGRI, capture_output=True, text=True)
text = out.stdout + out.stderr
warns = []
for m in re.finditer(r"^%Warning-(\w+): ([^:\s]+):(\d+):\d+: (.*)$", text, re.M):
    code, f, line, msg = m.groups()
    sig = re.findall(r"'([^']+)'", msg)
    warns.append((short(f), int(line), code, sig[0] if sig else msg, msg))
errors = [l for l in text.splitlines() if l.startswith("%Error")]

waivers = []
for l in open(os.path.join(HERE, "cov/waivers.txt")):
    if l.startswith("#") or "|" not in l:
        continue
    parts = [x.strip() for x in l.split("|")]
    if len(parts) >= 4 and parts[1] == "lint":
        fp, cp, sp = (parts[2].split(":") + ["*", "*"])[:3]
        waivers.append({"id": parts[0], "f": fp, "c": cp, "s": sp, "reason": parts[3], "used": 0})

hole, waived, info = [], [], []
for w in warns:
    f, line, code, sig, msg = w
    hit = None
    for wv in waivers:
        if fnmatch.fnmatch(f, wv["f"]) and fnmatch.fnmatch(code, wv["c"]) and \
           (fnmatch.fnmatch(sig, wv["s"]) or fnmatch.fnmatch(msg, wv["s"])):
            hit = wv; break
    if hit:
        hit["used"] += 1; waived.append((hit["id"], w))
    elif f in GATED:
        hole.append(w)
    else:
        info.append(w)

print("===== LINT (verilator -Wall, top adc_apb_wrapper_rev2, %s) =====" % ("PL031 stand-in" if os.environ.get("STUB_RTC") == "1" else "real PL031"))
for e in errors: print("ERROR  " + e)
for w in hole:   print("HOLE   %s:%d %s %s" % (w[0], w[1], w[2], w[4]))
for i, w in waived: print("WAIVED %-5s %s:%d %s %s" % (i, w[0], w[1], w[2], w[3]))
for w in info:   print("INFO   %s:%d %s %s (outside the gated RTL)" % (w[0], w[1], w[2], w[4]))
stale = [wv for wv in waivers if wv["used"] == 0 and not wv["f"].startswith(("pl031_stub", "dummy_", "sar_afe", "sky130"))]
for wv in stale: print("ERROR  lint waiver %s (%s:%s:%s) matches no warning (stale?)" % (wv["id"], wv["f"], wv["c"], wv["s"]))
bad = len(hole) + len(errors) + len(stale)
print("LINT: %d warnings, %d waived, %d unwaived in the peripheral RTL, %d info" % (len(warns), len(waived), len(hole), len(info)))
print("RESULT: %s" % ("PASS" if bad == 0 else "%d ERROR(s)" % bad))
sys.exit(1 if bad else 0)
