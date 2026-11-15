#!/usr/bin/env python3
"""run_mutations.py - prove every bound SVA assertion can fail.

For each assertion in verif/sensing_assertions.sv there is one deliberate
mutation below: a single text replacement in ONE source file (RTL, or the
bench for the master-side checks). The script copies that file to
$BUILD_ROOT/sva_mut/<id>/, applies the replacement there (the checkout is
never modified), builds the named bench with the mutated copy and --assert,
runs it with +verilator+error+limit+1000 so every failing assertion is
reported rather than only the first, and checks that the TARGET assertion
fired ("Assertion failed in ...<name>").

    python3 verif/sva_mut/run_mutations.py            all mutations
    python3 verif/sva_mut/run_mutations.py fifo_ptr   only some (by id)
    STUB_RTC=1 / BUILD_ROOT=dir as for the other targets (BUILD_ROOT defaults
    to /tmp/sens_build).

Writes verif/sva_mut/MUTATION_REPORT.txt. Exit 1 unless every mutation is
PROVEN. One core, nice'd, memory-capped (see verif/verilator_1core.mk).
"""
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
AGRI = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(AGRI)
BUILD = os.path.join(os.environ.get("BUILD_ROOT") or "/tmp/sens_build", "sva_mut")
STUB = os.environ.get("STUB_RTC") == "1"

def P(*a):
    return os.path.join(AGRI, *a)

SARLOGIC = os.path.join(REPO, "analog/cadence/sar_adc/sarlogic/functional/verilog.v")
ADC = [P("ADC/sar_adc.v"), P("ADC/sar_comp_latch.v"), SARLOGIC,
       P("ADC/sim/sky130_fd_sc_hd__nand2_1.v"), P("ADC/sim/sar_afe_model.v")]
if STUB:
    RTC_IP, RTC_DEF = [P("verif/stubs/pl031_stub.v")], ["-DPL031_STUB"]
else:
    arm = os.environ.get("ARM_IP_LIBRARY_PATH", "")
    ipdir = os.path.join(arm, "PL031/PL031-r1p3-00rel0/PL031-BU-00000-r1p3-00rel0/PL031_VC/rtc_pl031/verilog/rtl_source")
    RTC_IP = sorted(os.path.join(ipdir, f) for f in os.listdir(ipdir) if f.endswith(".v")) if os.path.isdir(ipdir) else []
    RTC_DEF = ["-I" + ipdir]
RTC = [P("RTC/rtc_control_2.v")] + RTC_IP
SENS = [P("Wrapper/adc_apb_wrapper_rev2.v"), P("FSM/wrapper_control_2.v"), P("FIFO/fifo_apb_adc.v")] + ADC + \
       [P("Dummy/dummy_amux.v"), P("Dummy/dummy_pll.v")] + RTC
SVA = P("verif/sensing_assertions.sv")

BENCHES = {
    "fifo":   ("fifo_apb_adc_rand_tb", [P("FIFO/fifo_apb_adc_rand_tb.v"), P("FIFO/fifo_apb_adc.v")], [], []),
    "fsm":    ("wrapper_control_seq_tb", [P("FSM/wrapper_control_seq_tb.v"), P("FSM/wrapper_control_2.v"), P("Dummy/dummy_adc.v")],
               ["-DSVA_FSM_UNIT"], []),
    "clo":    ("sens_closure_tb", [P("Wrapper/sens_closure_tb.sv")] + SENS, RTC_DEF, []),
    "gap":    ("sens_gap_tb", [P("Wrapper/sens_gap_tb.sv")] + SENS, RTC_DEF, []),
    "soak":   ("sens_soak_tb", [P("Wrapper/sens_soak_tb.sv")] + SENS, RTC_DEF, ["+seed=1", "+periods=300"]),
    "rtc":    ("tb_rtc_closure", [P("RTC/tb_rtc_closure.sv")] + RTC, RTC_DEF, []),
    "adccal": ("sar_adc_cal_tb", [P("ADC/tb/sar_adc_cal_tb.sv")] + ADC, [], []),
}

F, W, R, CT = P("FIFO/fifo_apb_adc.v"), P("Wrapper/adc_apb_wrapper_rev2.v"), P("RTC/rtc_control_2.v"), P("FSM/wrapper_control_2.v")
SA = P("ADC/sar_adc.v")

# id, assertion, bench, file, old, new
MUTS = [
    # ---- FIFO
    ("fifo_le_depth", "a_count_le_depth", "fifo", F, "assign fifo_full  = (count == DEPTH);", "assign fifo_full  = (count == DEPTH + 1);"),
    ("fifo_full",     "a_full_iff",       "fifo", F, "assign fifo_full  = (count == DEPTH);", "assign fifo_full  = (count >= DEPTH - 1);"),
    ("fifo_empty",    "a_empty_iff",      "fifo", F, "assign fifo_empty = (count == 0);", "assign fifo_empty = (count <= 1);"),
    ("fifo_ptr",      "a_ptr_count",      "fifo", F, "rd_ptr <= rd_ptr + 1;", "rd_ptr <= rd_ptr + 2;"),
    ("fifo_step",     "a_count_step",     "fifo", F, "count <= count + 1'b1;", "count <= count + 2'd2;"),
    ("fifo_clear",    "a_clear",          "fifo", F, "end else if (fifo_clear) begin\n            rd_ptr <= 0;",
                                                     "end else if (fifo_clear) begin\n            rd_ptr <= rd_ptr;"),
    ("fifo_data",     "a_empty_data",     "fifo", F, "assign apb_rd_data = fifo_empty ? {DATA_WIDTH{1'b0}} : fifo_mem[rd_ptr];",
                                                     "assign apb_rd_data = fifo_mem[rd_ptr];"),
    # ---- sampling FSM
    ("fsm_en_bound",  "a_adc_en_bounded", "fsm", CT, "wire          tmo_hit = (tmo_cnt == CONV_TIMEOUT - 1);",
                                                     "wire          tmo_hit = 1'b0;"),
    ("fsm_arc_tmo",   "a_arc_timeout",    "fsm", CT, "S_ERR_TIMEOUT: next_state = S_IDLE;", "S_ERR_TIMEOUT: next_state = S_ERR_FULL;"),
    ("fsm_full_wr",   "a_no_write_when_full", "clo", CT, "S_CHECK_FIFO: next_state = fifo_full ? S_ERR_FULL : S_ENABLE;",
                                                         "S_CHECK_FIFO: next_state = S_ENABLE;"),
    ("fsm_wr_1cyc",   "a_write_one_cycle", "fsm", CT, "S_WRITE:                             fifo_write_en = 1'b1;",
                                                      "S_WRITE, S_IDLE:                     fifo_write_en = 1'b1;"),
    ("fsm_en_states", "a_adc_en_states",  "fsm", CT, "S_ENABLE, S_WAIT_START, S_WAIT_DONE: adc_en        = 1'b1;",
                                                     "S_CHECK_FIFO, S_ENABLE, S_WAIT_START, S_WAIT_DONE: adc_en = 1'b1;"),
    ("fsm_arc_idle",  "a_arc_idle",       "fsm", CT, "S_IDLE:       if (sample_trig) next_state = S_CHECK_FIFO;",
                                                     "S_IDLE:       if (sample_trig) next_state = S_ENABLE;"),
    ("fsm_arc_check", "a_arc_check",      "fsm", CT, "S_CHECK_FIFO: next_state = fifo_full ? S_ERR_FULL : S_ENABLE;",
                                                     "S_CHECK_FIFO: next_state = fifo_full ? S_ERR_FULL : S_WAIT_START;"),
    ("fsm_arc_enable", "a_arc_enable",    "fsm", CT, "S_ENABLE:     next_state = S_WAIT_START;", "S_ENABLE:     next_state = S_WAIT_DONE;"),
    ("fsm_arc_wstart", "a_arc_wstart",    "fsm", CT, "if (!adc_valid && adc_quiet) next_state = S_WAIT_DONE;",
                                                     "if (!adc_valid && adc_quiet) next_state = S_WRITE;"),
    ("fsm_arc_wdone", "a_arc_wdone",      "fsm", CT, "S_WAIT_DONE:  if (adc_valid)                next_state = S_WRITE;",
                                                     "S_WAIT_DONE:  if (adc_valid)                next_state = S_IDLE;"),
    ("fsm_arc_write", "a_arc_write",      "fsm", CT, "S_WRITE:      next_state = S_IDLE;", "S_WRITE:      next_state = S_CHECK_FIFO;"),
    ("fsm_arc_err",   "a_arc_err",        "fsm", CT, "S_ERR_FULL:   next_state = S_IDLE;", "S_ERR_FULL:   next_state = S_CHECK_FIFO;"),
    ("fsm_err_rise",  "a_err_rise",       "fsm", CT, "if (state == S_ERR_FULL)\n                err_fifo_full <= 1'b1;",
                                                     "if (state == S_CHECK_FIFO && fifo_full)\n                err_fifo_full <= 1'b1;"),
    # ---- APB slave
    ("apb_stall",     "a_stall_bounded",  "clo", R, "|| (state == S_WAITING)) && !fsm_psel;",
                                                    "|| (state == S_WAITING && wd_ticks != 0)) && !fsm_psel;"),
    ("apb_en_sel",    "a_enable_needs_sel", "clo", P("Wrapper/sens_closure_tb.sv"),
                      "        @(posedge PCLK); #1;\n        PSEL = 1'b0; PENABLE = 1'b0; PWRITE = 1'b0; PSTRB = 4'h0;\n        last_stall = st;",
                      "        @(posedge PCLK); #1;\n        PSEL = 1'b0; PWRITE = 1'b0; PSTRB = 4'h0;\n        last_stall = st;"),
    ("apb_pslverr",   "a_no_pslverr",     "clo", R, "assign PSLVERR = 1'b0;", "assign PSLVERR = PSEL;"),
    ("apb_pready",    "a_pready_non_rtc", "clo", W, "assign PREADY  = (rtc_region & ~rtc_partial_wr) ? rtc_pready  : 1'b1;",
                                                    "assign PREADY  = (rtc_region & ~rtc_partial_wr) ? rtc_pready  : ~(PSEL & ~PENABLE);"),
    ("apb_prdata",    "a_prdata_idle_zero", "clo", W, "PRDATA = {DATA_WIDTH{1'b0}};\n        if (read_enable) begin",
                                                      "PRDATA = {DATA_WIDTH{1'b0}};\n        if (PSEL & ~PWRITE) begin"),
    ("apb_reserved",  "a_reserved_reads_zero", "gap", W, "default:           PRDATA = {DATA_WIDTH{1'b0}};",
                                                         "default:           PRDATA = 32'h0000_DEAD;"),
    # ---- wrapper internals
    ("wrap_trig",     "a_manual_trig_pulse", "clo", W, "manual_trig <= (write_enable && strb0",
                                                       "manual_trig <= (PSEL && PWRITE && strb0"),
    ("wrap_clear",    "a_fifo_clear_pulse",  "clo", W, "fifo_clear <= (write_enable && (|PSTRB)",
                                                       "fifo_clear <= (PSEL && PWRITE && (|PSTRB)"),
    ("wrap_rd_en",    "a_fifo_rd_en_pulse",  "clo", W, "fifo_rd_en <= (read_enable && (PADDR == MEASUREMENT_LO) && !fifo_empty);",
                                                       "fifo_rd_en <= (PSEL && !PWRITE && (PADDR == MEASUREMENT_LO) && !fifo_empty);"),
    ("wrap_pop_empty", "a_no_pop_when_empty", "soak", W, "fifo_rd_en <= (read_enable && (PADDR == MEASUREMENT_LO) && !fifo_empty);",
                                                         "fifo_rd_en <= (read_enable && (PADDR == MEASUREMENT_LO));"),
    ("wrap_capture",  "a_sample_capture",  "clo", W, "else if (adc_valid_rise) adc_sample <= adc_result;", "else adc_sample <= adc_result;"),
    ("wrap_status",   "a_status_reserved", "clo", W, "status_reg[DATA_WIDTH-1:7] <= {(DATA_WIDTH-7){1'b0}};",
                                                     "status_reg[DATA_WIDTH-1:7] <= {(DATA_WIDTH-7){adc_en}};"),
    # ---- RTC controller / PL031 port
    ("rtc_legal",     "a_legal_state",     "rtc", R, "rtc_trig <= 1'b1;\n                state    <= S_IDLE;",
                                                     "rtc_trig <= 1'b1;\n                state    <= 5'd15;"),
    ("rtc_trig_1cyc", "a_trig_one_cycle",  "rtc", R, "        rtc_trig    <= 1'b0;\n", "        rtc_trig    <= rtc_trig && (state == S_IDLE);\n"),
    ("rtc_trig_src",  "a_trig_source",     "rtc", R, "S_IDLE: begin\n                if (nrtcrst_pclk) begin",
                                                     "S_IDLE: begin\n                rtc_trig <= rtc_enabled;\n                if (nrtcrst_pclk) begin"),
    ("rtc_bus_excl",  "a_bus_exclusive",   "rtc", R, "wire grant = PSEL & (bus_free | (pt_setup_done & ~fsm_psel));",
                                                     "wire grant = PSEL & (bus_free | pt_setup_done | (state == S_MATCH_ACCESS));"),
    ("rtc_acc_setup", "a_pl031_access_after_setup", "rtc", R, "wire ext_penable = PENABLE & pt_setup_done;", "wire ext_penable = PENABLE;"),
    ("rtc_setup_acc", "a_pl031_setup_then_access",  "rtc", R, "wire grant = PSEL & (bus_free | (pt_setup_done & ~fsm_psel));",
                                                              "wire grant = PSEL & bus_free;"),
    ("rtc_wd_frozen", "a_wd_frozen_paused", "rtc", R, "if (poll_enable && clk1hz_tick && (wd_ticks != 32'hFFFF_FFFF))",
                                                      "if (clk1hz_tick && (wd_ticks != 32'hFFFF_FFFF))"),
    ("rtc_rearm_trig", "a_rearm_no_trig",  "rtc", R, "                    state <= S_READ_SETUP;\n            end",
                                                      "                    begin state <= S_READ_SETUP; rtc_trig <= 1'b1; end\n            end"),
    ("rtc_offset_armed", "a_offset_armed", "rtc", R, "else if ((eff_offset != armed_offset) && !PSEL)",
                                                     "else if (1'b0)"),
    ("rtc_setup_psel", "a_setup_done_needs_psel", "rtc", R, "else if (ext_done) pt_setup_done <= 1'b0;", "else if (1'b0)     pt_setup_done <= 1'b0;"),
    # ---- SAR ADC
    ("sar_legal",     "a_legal_state",     "adccal", SARLOGIC, "if (en) start_conv;\n\t\t\t\t\telse state <= sWait;",
                                                               "if (en) start_conv;\n\t\t\t\t\telse state <= 6;"),
    ("sar_result",    "a_result_only_in_done", "adccal", SARLOGIC, "res_valid <= 0; // valid is a 1-cycle pulse in back-to-back mode",
                                                                   "res_valid <= 0; result_q <= ~result_q; // MUTATION"),
    ("sar_valid",     "a_valid_falls",     "adccal", SARLOGIC, "res_valid <= 0; // valid is a 1-cycle pulse in back-to-back mode",
                                                               "res_valid <= res_valid; // MUTATION"),
    ("sar_clkc",      "a_clkc_gated",      "adccal", SARLOGIC, "clkc <= (~clk & en_co_clk);", "clkc <= ~clk;"),
]

VL = ["verilator", "--binary", "--timing", "-j", "1", "--output-groups", "20", "-CFLAGS", "-O0",
      "-Wno-fatal", "-Wno-lint", "-Wno-style", "--assert", "-DSIMULATION"]


def run(mid, aname, bench, src, old, new):
    d = os.path.join(BUILD, mid)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    text = open(src).read()
    if text.count(old) != 1:
        return "NOT APPLIED", "anchor text found %d times in %s" % (text.count(old), os.path.relpath(src, REPO))
    mfile = os.path.join(d, os.path.basename(src))
    with open(mfile, "w") as f:
        f.write(text.replace(old, new))
    top, files, defs, plus = BENCHES[bench]
    files = [mfile if os.path.abspath(x) == os.path.abspath(src) else x for x in files] + [SVA]
    cmd = ["nice", "-n", "19"] + VL + defs + ["--Mdir", os.path.join(d, "obj"), "--top", top, "-o", "Vmut"] + files
    b = subprocess.run("ulimit -v 3000000; " + " ".join("'%s'" % c for c in cmd), shell=True, cwd=d,
                       capture_output=True, text=True)
    if b.returncode != 0:
        open(os.path.join(d, "build.log"), "w").write(b.stdout + b.stderr)
        return "BUILD FAILED", "see " + os.path.join(d, "build.log")
    try:
        r = subprocess.run([os.path.join(d, "obj", "Vmut"), "+verilator+error+limit+1000"] + plus, cwd=d,
                           capture_output=True, text=True, timeout=1200)
        out = r.stdout + r.stderr
    except subprocess.TimeoutExpired as e:
        out = (e.stdout or b"").decode(errors="replace") if isinstance(e.stdout, bytes) else (e.stdout or "")
    open(os.path.join(d, "run.log"), "w").write(out)
    shutil.rmtree(os.path.join(d, "obj"), ignore_errors=True)   # ~90 MB per mutant; keep only the logs
    fired = sorted(set(re.findall(r"Assertion failed in \S*?\.(a_\w+)", out)))
    if aname in fired:
        return "PROVEN", "fired: " + ", ".join(fired)
    return "NOT FIRED", "fired: " + (", ".join(fired) or "none") + "; log " + os.path.join(d, "run.log")


def main():
    want = sys.argv[1:]
    rows = []
    for m in MUTS:
        if want and m[0] not in want:
            continue
        st, info = run(*m)
        rows.append((m[0], m[1], m[2], st, info))
        print("%-15s %-28s %-7s %-12s %s" % (m[0], m[1], m[2], st, info), flush=True)
    ok = all(r[3] == "PROVEN" for r in rows)
    lines = ["SVA MUTATION REPORT (%s)" % ("PL031 stand-in" if STUB else "real PL031"),
             "Each assertion with one deliberate mutation; PROVEN = the target assertion fired.", ""]
    lines += ["%-15s %-28s %-7s %-12s %s" % r for r in rows]
    lines += ["", "RESULT: %d/%d PROVEN" % (sum(r[3] == "PROVEN" for r in rows), len(rows))]
    if not want:
        open(os.path.join(HERE, "MUTATION_REPORT.txt"), "w").write("\n".join(lines) + "\n")
    print(lines[-1])
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
