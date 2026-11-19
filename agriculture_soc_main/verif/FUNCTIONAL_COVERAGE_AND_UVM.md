# Functional Coverage & UVM for the Sensing Peripheral — Detailed Guide

Written 2026-10-04 against **Verilator 5.052** (2026-09-05) and **Accellera UVM
1800.2-2020.3.1** (installed at `/opt/uvm`).

Everything below the "verified" markers was actually compiled and run on a
machine without the ARM IP. Anything marked **ARM IP** was written and
compile-checked against a PL031 stand-in, but must be run on a machine with
`ARM_IP_LIBRARY_PATH` set before its results count.

---

## 0. Quick start

```bash
cd agriculture_soc_main

# ---- no ARM IP needed ----
make cov-free                       # FIFO + FSM functional coverage, merged report
make uvm-fifo                       # FIFO UVM bench (first build is slow, see §2)
make uvm-sensing STUB_RTC=1         # whole peripheral, PL031 stand-in (smoke only)

# ---- needs ARM IP ----
export ARM_IP_LIBRARY_PATH=/path/to/nanosoc_arm_ip
make cov                            # FIFO + FSM + RTC + Wrapper coverage, merged
make uvm-sensing                    # whole peripheral UVM bench on the real PL031
make -C verif/cov holes             # list every bin never hit
```

Every target prints the usual `=== NAME: N PASSED, M FAILED ===` line (so
`make verify`'s aggregator understands it) and a per-coverpoint coverage table.

---

## 1. File map

```
agriculture_soc_main/verif/
├── verilator_1core.mk          shared single-core / memory-capped Verilator flags
├── cov/                        FUNCTIONAL COVERAGE MODELS (bound into the RTL)
│   ├── fifo_cov.sv             fifo_apb_adc
│   ├── fsm_cov.sv              wrapper_control_2 (sampling FSM)
│   ├── rtc_cov.sv              rtc_control_2      (ARM IP)
│   ├── wrapper_cov.sv          adc_apb_wrapper_rev2 (ARM IP)
│   ├── holes.py                per-coverpoint table + list of unhit bins
│   └── Makefile                make fifo|fsm|rtc|wrapper|free|all|report|holes
├── uvm/
│   ├── apb/                    reusable APB3 master agent (driver/monitor/seqs)
│   ├── fifo/                   FIFO UVM bench          (runs without ARM IP)
│   └── wrapper/                whole-peripheral UVM bench over APB (ARM IP)
├── stubs/pl031_stub.v          NOT ARM IP: behavioural PL031 for compile/smoke
└── sensing_assertions.sv       (pre-existing) bound SVA assertions
```

Also changed outside `verif/`:

* `makefile` — new `cov-free`, `cov`, `uvm-fifo`, `uvm-sensing` targets; the
  `check` / `reset_rand` full-SoC targets (lost in the origin/main merge) are
  restored and back in `make verify`.
* `RTC/Makefile` — `rand` target restored (lost in the merge).
* `RTC/tb_rtc_control_rand.v` — now instantiates `rtc_control_2` (main renamed
  the module this TB was written against).

---

## 2. Single-core policy (why the builds look the way they do)

A parallel (`-j 0`) UVM build exhausted the RAM of an 8-core / 7.8 GB machine
and crashed it. All new targets therefore include `verif/verilator_1core.mk`:

| Setting | Why |
|---|---|
| `-j 1` | one Verilate thread, one C++ compile at a time |
| `--output-groups 20` | **important.** With `-j 1`, Verilator defaults to ONE output group, i.e. it concatenates all ~2000 generated UVM `.cpp` files (~300 MB) into a single translation unit → one `g++` at 3.5 GB+. With ~300 groups it compiles ~2000 tiny files that each re-parse a big header (~2.5 h). 20 groups ≈ 600 MB per compile. |
| `-CFLAGS -O0` | testbench C++ doesn't need optimising; much faster, much less RAM |
| `nice -n 19` | the build never starves the desktop |
| `ulimit -v $(MEMCAP_KB)` | hard per-build memory cap (default 3 GB) |

On a bigger machine: `make JOBS=4 MEMCAP_KB=8000000`.

---

## 3. Functional coverage in Verilator 5.052 — what actually works

Older Verilators (and the 5.039 tree in `./verilator/`) **parse covergroups and
silently throw them away** (`COVERIGN` warning, zero coverage, clean compile).
5.052 implements them for real: there is a runtime
(`include/verilated_covergroup.{h,cpp}`), bins are counted, and results are
written to `coverage.dat` as a new `covergroup` category next to line / toggle /
branch / expr / fsm.

I probed every common construct with small test programs. Results:

### 3.1 Works (verified)

| Construct | Example | Notes |
|---|---|---|
| covergroup in a module | `covergroup cg @(posedge clk); ... endgroup` | |
| covergroup in a class | `class T; covergroup cg; ... endgroup; function new(); cg = new; endfunction` | used by the UVM coverage collectors |
| explicit sampling | `cg.sample();` | **preferred** — see §3.3 |
| `sample()` with arguments | `covergroup cg with function sample(logic [7:0] v);` | |
| value / range bins | `bins low = {[1:15]};` | parameter expressions OK (`{DEPTH-1}`) |
| one-bin-per-value | `bins vals[] = {[0:5]};` | |
| `default` bin | `bins other = default;` | |
| `ignore_bins` | `ignore_bins ig = {6};` | excluded from `get_inst_coverage()` |
| `illegal_bins` | `illegal_bins bad = {7};` | **fatal** when hit — see §3.3 |
| `iff` guard | `coverpoint st iff (en)` | |
| `wildcard` bins | `wildcard bins top = {8'b1???????};` | |
| transitions | `bins a = (0 => 1);  bins s = (0 => 1 => 2);  bins m = (4,5 => 6);` | **literal numbers only** — see §3.2 |
| auto bins for enums / small vectors | `coverpoint state_e_var;` | |
| `cross` | `x : cross cp_a, cp_b;` | auto cross bins |
| `option.per_instance`, `option.at_least` (constant) | | |
| `get_inst_coverage()` | | the call to use (see below) |
| reporting | `verilator_coverage --report summary,hier`, `--filter-type covergroup`, `--write` (merge), `--annotate` | |

### 3.2 Does NOT work (verified) — and the workaround used here

| Construct | What happens | Workaround |
|---|---|---|
| fixed-size bin array `bins b[4] = {[16:127]};` | warning, silently becomes `b[]` (112 bins!) | write explicit range bins |
| `with` filter `bins e = {[0:255]} with (item % 2 == 0);` | warning, filter ignored | wildcard bins or explicit values |
| consecutive repetition `(3 [*2])` | error | write the explicit transition `(3 => 3)` |
| range inside a transition `([7:8] => 9)` | **Verilator internal error (crash)** | list values: `(7,8 => 9)` |
| covergroup ctor args in bin bounds `bins b = {[lo:hi]};` | error "non-constant" | module parameters instead |
| non-constant `option.at_least` | ignored, default used | constant only |
| `cg.cp.get_coverage()` (per coverpoint) | compile error | use `holes.py` on `coverage.dat` |
| `cg.get_coverage()` / `cg_type::get_coverage()` (type-level) | **always 0.00** | use `cg.get_inst_coverage()` |
| `cg.stop()` / `cg.start()` | compile but **do nothing** — sampling continues | gate the `sample()` call yourself |
| a parameter / expression in a transition `(DEPTH-1 => DEPTH)` or even `(S_IDLE => S_CHECK)` | **internal error (crash)** | history register + `{prev, cur}` value bins (§3.3 item 5) |
| `binsof(...)` / explicit cross bins (`ignore_bins x = binsof(a.b) ...` on a cross) | warning, ignored | an `iff`-guarded coverpoint instead of a filtered cross |
| `dist` with variable weights (`1 := pct`) | `randomize()` fails (UNSATCONSTR) | pick the value with `$urandom_range` and pass it in `with { x == v; }` |
| `dist` + inline `with { x == v; }` on the same field (even with constant weights) | `randomize()` fails | a plain range constraint (`x <= 10`) |

Also found while building the benches (not covergroup syntax, but they bit):

| Issue | Effect | Workaround |
|---|---|---|
| **`--coverage-line` in the same build as covergroups** | some covergroup bins silently read **0** (rtc_cov `cp_arm`: 29 hits without the flag, 0 with it; other bins unaffected) | never mix: functional coverage by default, code coverage as a separate `CODE_COV=1` run |
| a **comment starting with the word "Verilator"** (`// Verilator 5.052 notes`) | hard error `BADVLTPRAGMA` — parsed as a `/*verilator ...*/` pragma | don't start a comment with that word |
| variable declared inside a `forever` body (`forever begin item s; ...`) | not re-initialised to `null` each iteration | assign it explicitly at the top of the loop |
| `--coverage-fsm` on this project's two-process FSMs | detects nothing (`fsm_state 0/0`) | hand-written state/arc bins (`fsm_cov`) |
| class-embedded covergroups | appear in reports as `__vlAnonCG_<name>` | cosmetic |

### 3.3 Gotchas that shaped the coverage models

1. **Illegal bins abort the simulation without writing `coverage.dat`.** A hit
   prints `Assertion failed ... Illegal bin 'x' hit` and `$stop`s. You lose the
   coverage of the whole run. So in these models `illegal_bins` is only used for
   truly impossible encodings (e.g. FSM state 7); "must never happen" protocol
   events (PSLVERR on the RTC passthrough) are a *normal* bin that the report
   flags, and the testbench/scoreboard is what fails the test.
2. **`verilator_coverage`'s summary counts ignore/illegal bins in the
   denominator**, so it under-reports. `holes.py` reports over normal bins
   only, matching `get_inst_coverage()`.
3. **Sample explicitly from an `always @(posedge clk)` block** rather than
   `covergroup cg @(posedge clk)`. It makes reset-gating explicit
   (`if (rst_n) cg.sample();`) and guarantees the sampled values are the
   *pre-edge* values the DUT itself acts on (no scheduling ambiguity).
4. Coverage is only written to `coverage.dat` when built with `--coverage` /
   `--coverage-user`. Without it the covergroups still count (so
   `get_inst_coverage()` works), they just aren't saved.
5. **Transitions as `{previous, current}` value bins.** Because transition bins
   only take literal numbers, every model keeps a one-cycle history register and
   covers the pair. Value bins accept parameters, so this works for any FIFO
   depth and reads naturally with named states:
   ```systemverilog
   always @(posedge clk or negedge rstn)
       if (!rstn) st_q <= S_IDLE; else st_q <= state;
   cp_arc : coverpoint {st_q, state} iff (hist_valid) {
       bins idle_to_check = {{S_IDLE, S_CHECK_FIFO}};
       ...
   ```
   Two history registers give three-step sequences (`cp_cycle` in `fsm_cov`).

---

## 4. The coverage models (verif/cov)

### 4.1 Approach: bind, don't edit

Each model is a small module containing a covergroup, attached to the RTL with
`bind`:

```systemverilog
bind fifo_apb_adc fifo_cov #(.DEPTH(DEPTH), ...) u_fifo_cov (.clk(clk), .count(count), ...);
```

That means **every** testbench that instantiates the block — the block TBs, the
wrapper TBs, the UVM benches, the full SoC — collects the same coverage without
any change to the testbench or the RTL. Port connections are evaluated inside
the bound instance, so internal signals (`count`, `wr_ptr`, `state`, `ext_sel`,
`RTCINTR`…) are visible.

### 4.2 What each model covers

**fifo_cov (fifo_apb_adc)**

| Coverpoint | Bins | Why it matters |
|---|---|---|
| `cp_occupancy` | empty, one, mid, almost_full, full | every fill level |
| `cp_op` | idle, rd_only, wr_only, rd_wr | every operation |
| `x_occ_op` | 5×4 cross | includes **overflow attempt** (wr while full), **underflow attempt** (rd while empty), **R+W at full** and **R+W at empty** |
| `cp_fill_edges` | 0→1, 1→0, D-1→D, D→D-1 | crossing the flag boundaries |
| `cp_wr_wrap`, `cp_rd_wrap` | ptr D-1→0 | ring-buffer wrap |
| `cp_clear_occ` | clear while empty/partial/full | flush in every state |
| `cp_data` | 0x00, all-ones, other | data-path corners |

**fsm_cov (wrapper_control_2)**

| Coverpoint | Why |
|---|---|
| `cp_state` | every state (state 7 = illegal) |
| `cp_arc` | all 11 legal arcs incl. WAIT_START/WAIT_DONE stall self-loops |
| `cp_trig_ctx` | trigger accepted in IDLE vs **ignored while busy** (an RTC alarm landing mid-conversion) |
| `cp_full_check` | FIFO full vs room at the CHECK_FIFO decision |
| `cp_err` | sticky `err_fifo_full` set **and cleared** |
| `cp_cycle` | write→next cycle, drop→recovery |

Verilator's automatic `--coverage-fsm` is meant to extract state/arc coverage,
but it found nothing in this project's two-process FSMs (`fsm_state 0/0`), so
`fsm_cov`'s hand-written arcs are the FSM coverage. It also adds the *context*
bins that automatic FSM coverage couldn't express anyway.

**rtc_cov (rtc_control_2) — ARM IP**

| Coverpoint | Why |
|---|---|
| `cp_state`, `cp_arm` | every state; first arm vs re-arm; alarm serviced |
| `cp_offset` | alarm_offset 0, 1, short, mid, long, 0xFFFFFFFF (wrap) |
| `x_pt_reg_dir` | firmware passthrough read/write of each PL031 register |
| `cp_stall_state` | which arm-cycle phase a passthrough collided with (decision #2) |
| `cp_stall_len` | wait-state histogram (`excess` > 15 is worth a look) |
| `cp_pslverr` | must stay at 0 — PSLVERR forbidden (decision #2) |
| `cp_poll`, `cp_alarm_while_paused`, `cp_resume_pending` | pause/resume and service-on-resume |
| `cp_defer` | alarm pending while a passthrough owned the bus |
| `cg_reset` | warm reset (PRESETn only, counter must survive) vs power-on (decision #3) |

**wrapper_cov (adc_apb_wrapper_rev2) — ARM IP**

| Coverpoint | Why |
|---|---|
| `x_reg_dir` | every register read and written, incl. unmapped |
| `cp_trig_src`, `cp_manual_poll` | RTC vs manual vs simultaneous trigger; manual with polling off |
| `cp_status_fifo`, `cp_status_drop` | firmware actually observed empty/partial/full and the drop bit |
| `cp_pop_ctx` | MEASUREMENT_LO read that pops vs read while empty |
| `cp_conv_cal`, `cp_amux` | conversions with/without calibration, each mux input |
| `cp_clear_ctx` | FIFO clear while idle/partial/full/converting |
| `cp_wait`, `cp_b2b` | wait states seen at the top level; back-to-back transfers |

### 4.3 Running and reading the reports

```bash
make -C verif/cov free          # fifo + fsm + merged report   (no ARM IP)
make -C verif/cov all           # + rtc + wrapper               (ARM IP)
make -C verif/cov holes         # every unhit bin
```

Outputs (all in `verif/cov/`): `coverage_<name>.dat` per run, `merged.dat`,
`annotate/` (sources with uncovered lines marked), `build_<name>.log`,
`run_<name>.log`. `holes.py` prints:

```
coverpoint / cross                                        covered     pct
fifo_tb.dut.u_fifo_cov.cg.x_occ_op                          18/20     90.0%
      HOLE  ...
TOTAL (normal bins)                                         ...
```

A hole is a direct instruction for the next test: write stimulus that reaches it.

---

## 5. UVM on Verilator 5.052

### 5.1 Setup

UVM isn't shipped with Verilator. Clone the Accellera kit (e.g. to `/opt/uvm`)
and set `UVM_HOME`:

```bash
git clone --depth 1 --branch 2020.3.1 https://github.com/accellera-official/uvm-core /opt/uvm
export UVM_HOME=/opt/uvm
```

Compile flags (in `verilator_1core.mk`):

```
verilator --binary --timing +define+UVM_NO_DPI +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv  <your files>
```

* `--timing` — UVM is full of `#delay`, `@event`, `fork`, `wait`.
* `+define+UVM_NO_DPI` — skips UVM's C DPI helpers (regex, HDL backdoor). Only
  needed for `uvm_hdl_*` backdoor access and regex-based config lookups, which
  these benches don't use.
* `z3` must be installed: Verilator calls an SMT solver at runtime for
  `randomize()` with constraints.
* Tests are selected at **run time**: `+UVM_TESTNAME=fifo_smoke_test`, seed
  with `+verilator+seed+N` (no rebuild).

### 5.2 Build cost

Measured with one core, `-O0`, 20 output groups and ccache on:

| Build | Time | Peak memory |
|---|---|---|
| minimal "hello" UVM test | 5 m 42 s | ~0.6 GB per compile |
| FIFO UVM bench, first build | 22–24 min | ~0.6 GB |
| FIFO UVM bench, rebuild after a small edit | ~7.5 min | ~0.6 GB |
| whole-peripheral UVM bench | 18–22 min | ~0.6 GB |
| *(for contrast)* default `-j 1` with no `--output-groups` | killed at 3.5 GB+ | one 3.5 GB+ `g++` |
| *(for contrast)* `--output-groups 300` | ~2.5 h estimated | small, but ~2000 header re-parses |
| non-UVM coverage builds (`verif/cov`) | 10–20 s each | small |

Most of the time is compiling the UVM library itself. Practical consequences:

* **Changing the test or seed needs no rebuild**: `make run TEST=... SEED=...`.
* Changing any `.sv` file rebuilds the model. ccache makes repeats faster
  (~7 min vs ~22 min), but not instant.
* On a bigger machine `make JOBS=4 MEMCAP_KB=8000000` cuts this roughly 4×.

What UVM features were used and work: `uvm_test`/`env`/`agent`/`driver`/
`monitor`/`sequencer`/`sequence`, `uvm_subscriber`, `uvm_analysis_port`,
`` `uvm_analysis_imp_decl ``, `uvm_config_db` with virtual interfaces,
objections, `` `uvm_info/error/fatal ``, the report server's severity counts,
`+UVM_TESTNAME`, `randomize() with {...}`, class-embedded covergroups.

Expected, harmless messages: `NO_DPI_USED`, `NO_VISIT_CHECK`,
`UVM/COMP/NAMECHECK` (all from `UVM_NO_DPI`) and two `TIMESCALEMOD` warnings.

### 5.3 The benches

**APB agent (`uvm/apb/`)** — `apb_item` (addr, write, wdata, idle gap; response
rdata, slverr, **waits**), a driver that does SETUP→ACCESS and holds ACCESS until
`PREADY` (with a watchdog that fails the test if a stall exceeds 1000 cycles —
a hang detector for decision #2), a monitor that publishes every completed
transfer, and `apb_base_seq::wr()/rd()` helpers.

**FIFO bench (`uvm/fifo/`) — runs without ARM IP**

```
fifo_tb_top ── fifo_if ── fifo_apb_adc (+ bound fifo_cov)
     │
 fifo_full_test
   └ fifo_env
       ├ fifo_agent (sequencer, driver, monitor)
       ├ fifo_scoreboard   queue reference model: flags + read data every cycle
       └ fifo_coverage     transaction covergroup (uvm_subscriber)
```

`fifo_full_test` runs directed boundary scenarios (underflow, R+W at empty,
fill + overflow, R+W at full, clears at each level, drain) and then biased
random phases (fill-heavy / drain-heavy to force wrap-arounds) and an unbiased
soak. `fifo_smoke_test` is just 200 random cycles. Two coverage views are
reported: what the **stimulus** exercised (class covergroup) and what the
**design** did (bound `fifo_cov`).

**Sensing bench (`uvm/wrapper/`) — ARM IP**

```
sensing_tb_top ── apb_if ── adc_apb_wrapper_rev2 (+ all four bound models)
     │             sample_if (snoops FSM→FIFO pushes)
 sensing_full_test
   └ sensing_env
       ├ apb_agent
       ├ sample_monitor
       ├ sensing_scoreboard
       └ sensing_apb_cov
```

The scoreboard checks:

* RW registers read back what was written (register mirror);
* MEASUREMENT_HI reads 0, unmapped addresses read 0, STATUS reserved bits 0;
* **PSLVERR is never asserted** (decision #2);
* **end-to-end sample integrity**: every sample the FSM pushes is snooped, and
  MEASUREMENT_LO must return exactly those values in order, honouring drops
  (push while full) and clears.

Sequences: `reg_rw_seq`, `manual_sample_seq` (amux/cal variations),
`overflow_seq` (checks the drop bit), `rtc_passthru_seq` (hammers the PL031
registers while the RTC re-arms every second → collisions/wait states, plus
`RTCLR` time jump and `alarm_offset = 0`), `poll_toggle_seq` (pause/resume with
an alarm pending), `random_reg_seq`. `CLK1HZ` is sped up to one "second" every
64 PCLKs so alarms happen within a short sim.

---

## 6. Running the ARM-IP parts

1. Install Verilator **≥ 5.052** (older silently drops covergroups) and `z3`.
2. Install UVM (§5.1) and `export UVM_HOME=...`.
3. `export ARM_IP_LIBRARY_PATH=/path/to/nanosoc_arm_ip`
   (or set it in `nanosoc/env/dependency_env.sh`).
4. From `agriculture_soc_main/`:
   ```bash
   make -C RTC rand            # existing RTC stress TB (now rtc_control_2)
   make cov                    # all four coverage models, merged report
   make -C verif/cov holes
   make uvm-sensing            # full UVM bench on the real PL031
   ```
5. Expect the first `make uvm-sensing` to take a long time on one core (§5.2).
   Re-runs with a different test/seed don't rebuild: `make -C verif/uvm/wrapper run TEST=... SEED=...`.

If something fails to compile against the real PL031 but works with
`STUB_RTC=1`, the difference is in the PL031 port list / behaviour — the stub
follows the public PL031 register map, not ARM's RTL.

---

## 7. Results

### 7.0 Closure round (2026-11-15) — current numbers

Without the ARM IP: Verilator 5.052, one core, `STUB_RTC=1` (to be re-run with the real PL031). One
command: `make signoff STUB_RTC=1` (report `verif/cov/SIGNOFF_REPORT.txt`).

| Gate | Result |
|---|---|
| Block functional coverage, every bench merged with both UVM runs (`make -C verif/cov all gate`) | **640 / 640 goal bins (100 %)**, 0 waived, 24 must-never (`viol_*`) bins watched, 0 hit |
| Line + branch on the six RTL files (`make -C verif/cov code`, union over instances) | **100 % / 100 %**, no code waivers needed (C-1 closed by ROB-1, C-2/C-3 turned out unnecessary) |
| `uvm-sensing` on its own | 12124 checks / 0 errors, 95.9 % of its bins (the rest are FIFO crosses unreachable in the integrated design, e.g. a push while full), APB transaction coverage 100 % |
| `uvm-fifo` | 2132 / 0, 100 % |
| SVA | 43 assertions bound, each shown able to fail (`verif/sva_mut/MUTATION_REPORT.txt`) |

New in the closure round: `sar_cov.sv` (SAR ADC), closure coverpoints in
`rtc_cov.sv` / `wrapper_cov.sv`, and corrected models (W1/W2/W4, the
`cg_rtc_irq.cp_rise_source` semantics, `icr_wr` needs bit 0).

The tables below are the earlier (pre-closure) state, kept for history.

### 7.1 Existing testbenches + bound coverage models (`make -C verif/cov ...`)

| Run | Testbench verdict | Functional coverage | Main holes (what to add next) |
|---|---|---|---|
| `fifo` (fifo_apb_adc_rand_tb) | 140 passed / 0 failed | 87.8 % (36/41) | never writes `0x00`; never idles while non-empty (`*_x_idle` for one/mid/almost_full/full) |
| `fsm` (wrapper_control_seq_tb) | 19 / 0 | 89.7 % (26/29) | trigger never arrives during ENABLE / WRITE; WAIT_START never holds (the dummy ADC drops `valid` immediately — covered at wrapper level) |
| `rtc` (tb_rtc_control_rand, **stub**) | 236 / 0 | 57.9 % (44/76) | passthrough only ever *reads RTCDR*; no warm reset; `alarm_offset` 0 / mid / long / 0xFFFFFFFF never used; `during_enable` stall |
| `wrapper` (adc_apb_wrapper_rand_tb, **stub**) | **19 / 1** — see §8.1 | 66.5 % (137/205) | PLL / MEAS_HI / unmapped never accessed; most registers never *read back*; RTC registers never written; back-to-back APB |
| **merged** | | **75.6 % (155/205)** | |

### 7.2 UVM benches

| Bench | Verdict | Coverage |
|---|---|---|
| `uvm-fifo` (`fifo_full_test`) | **2132 checks, 0 errors**; 333 pushes, 314 pops, 128 overflow attempts, 157 underflow attempts | **100 %** (67/67: transaction + bound design coverage) |
| `uvm-sensing` (`sensing_full_test`, **stub**) | **1703 checks, 0 errors**; 27 samples checked end-to-end in order; 26 RTC accesses stalled (max 15 wait states), never PSLVERR | **82.3 %** (219/266) across all four bound models + APB transaction coverage |

The UVM benches close holes the directed/random TBs leave: e.g. `cg_wrap.x_reg_dir`
goes from 45 % (wrapper rand TB) to **100 %**, the RTC passthrough register cross
from 6 % to 56 %, and FIFO coverage from 87.8 % to 100 %.

### 7.3 Bugs found along the way

| Where | What | Status |
|---|---|---|
| `Wrapper/adc_apb_wrapper_rand_tb.v` (on main) | invariant `PREADY !== 1'b1` counts a failure, but `rtc_control_2` now *deliberately* holds PREADY low to stall colliding RTC accesses (decision #2). Coverage confirms the stalls happen (`cp_wait`, `cp_stall_state`). Its `collisions` metric counts PSLVERR denials, which can no longer occur, so it always reports 0. | **not changed** — see §8.1 |
| `RTC/tb_rtc_control_rand.v` | instantiated `rtc_control`, but main renamed that design to `rtc_control_2` | fixed |
| `RTC/Makefile`, top `makefile` | `rand`, `check`, `reset_rand` targets lost in the origin/main merge | restored |
| my own benches | directed "clear while full" step wasn't full; snoop monitor re-published stale items (Verilator `forever` variable gotcha) | fixed — they are why the scoreboards exist |

---

## 8. Limitations and next steps

### 8.1 Decide: the wrapper random TB's PREADY invariant

`adc_apb_wrapper_rand_tb.v` predates the wait-state change, so it will report
`1 FAILED` whenever a passthrough collision happens. That is probably also true on
the real PL031, because the stall comes from `rtc_control_2`'s arbiter, not from
the PL031. Suggested replacement:

```verilog
// PREADY may only drop for RTC-region accesses, and only for a bounded time
if (PSEL && PENABLE && !PREADY && ((PADDR & 12'hFE0) != 12'h200)) inv_fail = inv_fail + 1;
if (stall_cycles > 64) inv_fail = inv_fail + 1;   // count consecutive PREADY-low cycles
```

and change `cov_collision` to count transfers that saw wait states instead of
PSLVERR. Not applied because it changes a team test's pass criteria.

### 8.2 Still to do

1. **Run the ARM-IP rows on the real PL031** (`make cov`, `make uvm-sensing`) and
   replace the stub numbers in §7.
2. **Close the holes** listed in §7.1. Most are one-line additions to the
   existing sequences: write `0x00`/idle while non-empty (FIFO), triggers during
   ENABLE/WRITE (FSM), RTC register writes + warm reset + `alarm_offset` corner
   values (RTC), PLL / MEAS_HI / unmapped / read-back (wrapper).
3. **Back-to-back APB** (`cp_b2b`) is never hit because `apb_driver` always
   drops PSEL for a cycle between transfers. Add a "no idle" mode to the driver.
4. **`cp_pslverr` must stay at 0.** It is a normal bin on purpose (an illegal
   bin would abort the sim without saving coverage); treat a non-zero count as a
   failure when reviewing reports.
5. **Merge into `make verify`.** The UVM benches print the standard
   `=== NAME: N PASSED, M FAILED ===` line, so they can be added to
   `_run_free` / `_run_ip` once the build time is acceptable.
6. **Recheck on newer Verilator.** Several §3.2 rows (fixed-size bins, `with`,
   `binsof`, the `--coverage-line` interaction, per-coverpoint
   `get_coverage()`) are active development upstream.

---

## 9. Checklist

Work through these in order from `agriculture_soc_main/`. Each step lists what a
good result looks like, using the no-ARM-IP numbers from §7 as the baseline.

### 9.1 One-time setup

```bash
verilator --version          # must be >= 5.052 (older silently drops covergroups)
which z3                     # needed at runtime by randomize()
git clone --depth 1 --branch 2020.3.1 https://github.com/accellera-official/uvm-core /opt/uvm   # if not present
export UVM_HOME=/opt/uvm
export ARM_IP_LIBRARY_PATH=/path/to/nanosoc_arm_ip
```

Everything is single-core by default. Don't pass `-j` to make; the limits live
in `verif/verilator_1core.mk`.

### 9.2 No-ARM checks (should match §7 exactly)

| Command | Expect |
|---|---|
| `make cov-free` | `FIFO: 140 PASSED, 0 FAILED`, `FSM-SEQ: 19 PASSED, 0 FAILED`; FIFO 87.8 %, FSM 89.7 % |
| `make uvm-fifo` | `=== FIFO-UVM: 2132 PASSED, 0 FAILED ===`, 67/67 = 100 % (first build ~20+ min) |

### 9.3 ARM-IP checks (the new information)

| Command | Expect / compare against the stub numbers |
|---|---|
| `make -C RTC rand` | `RTC-RAND: N PASSED, 0 FAILED` (stub: 236/0) |
| `make -C verif/cov rtc` | coverage near 57.9 %; same holes as §7.1 |
| `make -C verif/cov wrapper` | **expect `1 FAILED`** from the PREADY invariant (§8.1) if any collision occurs |
| `make cov` | merged report; stub merged figure was 75.6 % |
| `make uvm-sensing` | `=== SENSING-UVM: N PASSED, 0 FAILED ===` (stub: 1703/0), ~82 % coverage |
| `make -C verif/cov holes` | the to-do list of uncovered bins |

Also check in the reports:

* `cg_rtc.cp_pslverr` must be **0/1 (a hole)**. Any hit means PSLVERR came back
  (the no-PSLVERR design decision is violated).
* `cg_rtc.cp_stall_len.excess` (> 15 wait states) should stay a hole; if hit,
  look at what the arm cycle was doing.
* Differences between stub and real-IP numbers point at PL031 behaviour the
  stub doesn't model (CDC timing, ID registers). They are not RTL bugs by default.

### 9.4 If something fails

| Symptom | Cause / fix |
|---|---|
| `ARM PL031 not found at ...` | `ARM_IP_LIBRARY_PATH` unset or wrong; or use `STUB_RTC=1` for a smoke run |
| build killed / `virtual memory exhausted` | raise `MEMCAP_KB=4500000`; keep `JOBS=1` on a small machine |
| UVM run ends at time 0 with `UVM_FATAL [RAND]` | a `dist` constraint hit the Verilator limit in §3.2 |
| `BADVLTPRAGMA` compile error | a comment line starts with the word "Verilator" (§3.2) |
| a covergroup bin reads 0 but you can see the event in the waveform | was it built with `--coverage-line`? Use the default (functional-only) build |
| an illegal bin aborts the run and there's no `coverage.dat` | expected Verilator behaviour (§3.3 item 1); the illegal value is a real design problem |
| `make run` shows old results after an edit | the build failed and you re-ran the old binary; check `build.log` |

### 9.5 Open decisions / follow-ups

1. **Wrapper random TB PREADY invariant (§8.1).** Update it to "PREADY low only
   for RTC-region accesses, bounded", or leave it as is? Not changed yet.
2. Close the coverage holes listed in §7.1 (mostly one-line sequence additions).
3. Decide whether to add the UVM benches to `make verify` once build time is
   acceptable (§8.2 item 5).

