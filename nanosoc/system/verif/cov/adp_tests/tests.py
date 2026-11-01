#!/usr/bin/env python3
"""tests.py - system-level ADP tests closing the coverage_plan.md gaps that the
debug controller (a real AHB master) can reach without the Cortex-M0.

    python3 tests.py              run every test (single core, one at a time)
    python3 tests.py sens_ahb     run one test

Every test checks responses (data, OKAY/ERROR, poll results); see adptest.py.
ARM IP stand-ins in the harness (AHB-to-APB bridge, slave muxes, default slave,
SRAM bridges, CMSDK peripherals, PL031): checks only assert what the AMBA/CMSDK
specs and the SoCLabs RTL define, so the tests run unchanged against the real
IP - all results must be re-measured there (coverage_plan.md, "needs re-run").
"""
import sys
from adptest import AdpTest, main

S = 0x60000000                      # sensing peripheral (EXP region)
STATUS, MEAS_HI, MEAS_LO = S + 0x004, S + 0x008, S + 0x00C
PLL, AMUX, TRIG, CAL = S + 0x100, S + 0x104, S + 0x108, S + 0x10C
RTCDR, RTCMR, RTCLR, RTCCR = S + 0x200, S + 0x204, S + 0x208, S + 0x20C
RTCIMSC, RTCRIS, RTCMIS, RTCICR = S + 0x210, S + 0x214, S + 0x218, S + 0x21C
FCLR, ALARM, RTCCTRL = S + 0x220, S + 0x224, S + 0x228
SYSCTRL = 0x4001F000


def fifo_empty(t, desc):
    t.rd(STATUS, mask=0x3, expect=0x0, desc=desc)


def wait_sample(t, desc, bug=None, count=0xFFF):
    t.wait_until(STATUS, 0x3, 0x1, count=count, desc=desc, bug=bug)


# -----------------------------------------------------------------------------
def sens_ahb():
    t = AdpTest("sens_ahb", "sensing peripheral register interface over AHB")
    # First accesses after the prologue's debugger reset ("C 201"): reset values.
    t.rd(STATUS, check=lambda v, c: (v >> 6) == 0, desc="STATUS[31:6] read 0 after reset")
    t.rd(MEAS_HI, expect=0, desc="MEAS_HI reset value 0")
    t.rd(MEAS_LO, mask=0xFFFFFF00, expect=0, desc="MEAS_LO is an 8-bit sample, zero-extended")
    for a, v, n in [(PLL, 0, "PLL_CONTROL"), (AMUX, 0, "AMUX"), (TRIG, 0, "ADC_TRIGGER (WO)"),
                    (CAL, 0, "ADC_CAL"), (FCLR, 0, "FIFO_CLEAR (WO)"), (ALARM, 5, "RTC_ALARM_OFFSET"),
                    (RTCCTRL, 1, "RTC_CTRL")]:
        t.rd(a, expect=v, desc="%s reset value %d" % (n, v))
    t.rd(RTCDR, desc="RTCDR readable (OKAY) after reset")
    # deterministic from here: autonomous polling off, FIFO empty
    t.wr(RTCCTRL, 0, desc="RTC_CTRL write OKAY")
    t.spin(0x80)
    t.wr(FCLR, 1)
    fifo_empty(t, "FIFO empty after FIFO_CLEAR")
    # word write / read-back; byte and halfword reads return the addressed lane
    t.wr(PLL, 0x11223344)
    t.rd(PLL, expect=0x11223344, desc="PLL_CONTROL word write/read-back")
    t.A(PLL); t.R(4, size=1, expect=[0x44, 0x33, 0x22, 0x11], desc="PLL byte reads return the addressed lane")
    t.A(PLL); t.R(2, size=2, expect=[0x3344, 0x1122], desc="PLL halfword reads return the addressed half")
    t.A(ALARM); t.R(1, size=1, expect=0x05, desc="RTC_ALARM_OFFSET byte read")
    t.A(STATUS); t.R(2, size=2, check=lambda v, c: True, desc="STATUS halfword reads OKAY")
    # sub-word writes: AMBA APB4 - only the strobed byte lanes may change (F6)
    t.wr(PLL + 1, 0xAA, size=1)
    t.rd(PLL, expect=0x1122AA44, desc="byte write to PLL lane 1 changes only that byte", bug="F6")
    t.wr(PLL, 0x11223344); t.wr(PLL + 2, 0xBBCC, size=2)
    t.rd(PLL, expect=0xBBCC3344, desc="halfword write to PLL[31:16] changes only that half", bug="F6")
    t.wr(PLL, 0x11223344); t.wr(PLL, 0xDD, size=1)
    t.rd(PLL, expect=0x112233DD, desc="byte write to PLL lane 0 changes only that byte", bug="F6")
    t.wr(PLL, 0x11223344); t.wr(PLL, 0x5566, size=2)
    t.rd(PLL, expect=0x11225566, desc="halfword write to PLL[15:0] changes only that half", bug="F6")
    t.wr(AMUX, 0x2); t.wr(AMUX + 3, 0xFF, size=1)
    t.rd(AMUX, expect=0xFF000002, desc="byte write to AMUX lane 3 keeps the input select", bug="F6")
    t.wr(AMUX, 0)
    t.wr(CAL, 1); t.wr(CAL + 1, 0x00, size=1)
    t.rd(CAL, expect=1, desc="byte write to ADC_CAL lane 1 leaves CAL set", bug="F6")
    t.wr(CAL, 0)
    t.wr(ALARM, 5); t.wr(ALARM + 1, 0x01, size=1)
    t.rd(ALARM, expect=0x105, desc="byte write to RTC_ALARM_OFFSET lane 1 keeps lane 0", bug="F6")
    t.wr(ALARM, 5)
    t.wr(RTCCTRL, 1); t.wr(RTCCTRL + 2, 0x0000, size=2)
    t.rd(RTCCTRL, expect=1, desc="halfword write to RTC_CTRL[31:16] leaves polling enabled", bug="F6")
    t.wr(RTCCTRL, 0)
    t.spin(0x80)
    t.wr(FCLR, 1)
    # ADC_TRIGGER / FIFO_CLEAR with sub-word writes
    t.wr(TRIG, 0x01, size=1)
    wait_sample(t, "byte write of 1 to ADC_TRIGGER lane 0 takes one sample")
    t.wr(FCLR, 0x01, size=1)
    fifo_empty(t, "byte write to FIFO_CLEAR flushes the FIFO")
    t.wr(TRIG, 1)
    wait_sample(t, "word write of 1 to ADC_TRIGGER takes one sample")
    t.wr(FCLR + 2, 0x0000, size=2)
    fifo_empty(t, "halfword write to FIFO_CLEAR[31:16] flushes the FIFO ('any write')")
    t.wr(TRIG + 2, 0x0001, size=2)
    t.spin(0x80)
    t.rd(STATUS, mask=0x3, expect=0x0,
         desc="halfword write to ADC_TRIGGER[31:16] does not trigger (bit0 not strobed)", bug="F6")
    t.wr(FCLR, 1)
    t.wr(TRIG + 1, 0x01, size=1)
    t.spin(0x80)
    t.rd(STATUS, mask=0x3, expect=0x0, desc="byte write to ADC_TRIGGER lane 1 does not trigger", bug="F6")
    t.wr(FCLR, 1)
    # reserved offsets inside the 4 KB decode: read 0, write ignored, never ERROR
    t.wr(PLL, 0xCAFEF00D); t.wr(AMUX, 0x1); t.wr(CAL, 0x1); t.wr(ALARM, 7)
    for off in (0x000, 0x010, 0x0FC, 0x110, 0x1FC, 0x22C, 0x800, 0xFFC):
        t.rd(S + off, expect=0, desc="reserved offset 0x%03x reads 0 (OKAY)" % off)
        t.wr(S + off, 0xFFFFFFFF, desc="reserved offset 0x%03x write OKAY" % off)
    t.wr(S + 0x011, 0xFF, size=1)
    t.wr(S + 0x112, 0xFFFF, size=2)
    t.rd(PLL, expect=0xCAFEF00D, desc="reserved writes left PLL_CONTROL unchanged")
    t.rd(AMUX, expect=0x1, desc="reserved writes left AMUX unchanged")
    t.rd(CAL, expect=0x1, desc="reserved writes left ADC_CAL unchanged")
    t.rd(ALARM, expect=7, desc="reserved writes left RTC_ALARM_OFFSET unchanged")
    t.rd(RTCCTRL, expect=0, desc="reserved writes left RTC_CTRL unchanged")
    fifo_empty(t, "reserved writes neither triggered nor pushed")
    # wrong-direction accesses
    t.wr(STATUS, 0xFFFFFFFF, desc="write to RO STATUS is OKAY")
    t.wr(MEAS_HI, 0xFFFFFFFF, desc="write to RO MEAS_HI is OKAY")
    t.wr(MEAS_LO, 0xFFFFFFFF, desc="write to RO MEAS_LO is OKAY")
    fifo_empty(t, "writes to RO registers do not push")
    t.rd(STATUS, mask=0xFFFFFFC0, expect=0, desc="writes to RO STATUS do not stick")
    t.rd(TRIG, expect=0, desc="ADC_TRIGGER (WO) reads 0")
    t.rd(FCLR, expect=0, desc="FIFO_CLEAR (WO) reads 0")
    # reserved bits
    t.wr(CAL, 0xFFFFFFFE); t.rd(CAL, expect=0, desc="ADC_CAL: reserved bits read 0 (bit0 written 0)")
    t.wr(CAL, 0xFFFFFFFF); t.rd(CAL, expect=1, desc="ADC_CAL: reserved bits read 0 (bit0 written 1)")
    t.wr(CAL, 0)
    t.wr(RTCCTRL, 0xFFFFFFFE); t.rd(RTCCTRL, expect=0, desc="RTC_CTRL: reserved bits read 0")
    t.wr(TRIG, 0xFFFFFFFE); t.wr(TRIG, 0x00000000)
    t.spin(0x80)
    fifo_empty(t, "ADC_TRIGGER writes with bit0=0 do not trigger")
    # manual sample: zero-extended data, read pops
    t.wr(TRIG, 0xFFFFFFFF)
    wait_sample(t, "ADC_TRIGGER bit0=1 (reserved bits set) takes one sample")
    t.rd(MEAS_LO, mask=0xFFFFFF00, expect=0, desc="sample read is zero-extended")
    fifo_empty(t, "reading MEAS_LO popped the only sample")
    t.rd(MEAS_LO, mask=0xFFFFFF00, expect=0, desc="MEAS_LO read on an empty FIFO is OKAY")
    fifo_empty(t, "MEAS_LO read on an empty FIFO does not underflow")
    # address aliasing (F5): 16-bit PADDR -> peripheral repeats every 64 KB;
    # EXP decode also maps 0xA000_0000-0xDFFF_FFFF here.
    t.rd(S + 0x10224, expect=7, desc="0x6001_0224 aliases RTC_ALARM_OFFSET (64 KB repeat, F5)")
    t.rd(0x7FFF0224, expect=7, desc="0x7FFF_0224 aliases RTC_ALARM_OFFSET (64 KB repeat, F5)")
    t.rd(0xA0000224, expect=7, desc="0xA000_0224 (EXP mirror) reads RTC_ALARM_OFFSET (F5)")
    t.wr(0xDFFF0104, 0x3, desc="write via 0xDFFF_0104 mirror is OKAY")
    t.rd(AMUX, expect=0x3, desc="write via the 0xDFFF_0104 mirror reached AMUX (F5)")
    t.wr(0x60010104, 0x2, size=1)
    t.rd(AMUX, mask=0xFF, expect=0x2, desc="byte write via 0x6001_0104 alias reached AMUX (F5)")
    t.rd(S + 0x1004, expect=0, desc="0x6000_1004 (above 4 KB) reads 0 - other registers do not alias")
    t.rd(S + 0x1224, expect=0, desc="0x6000_1224 reads 0 - RTC_ALARM_OFFSET does not alias")
    t.wr(S + 0x1104, 0x0); t.rd(AMUX, mask=0xFF, expect=0x2, desc="write to 0x6000_1104 does not reach AMUX")
    t.rd(RTCMR, capture="mr0")
    t.wr(S + 0x1204, 0x5A5A5A5A)
    t.rd(RTCMR, check=lambda v, c: v == c["mr0"],
         desc="write to 0x6000_1204 must not change PL031 RTCMR (all other aliases are unmapped)", bug="F5")
    t.rd(S + 0x1200, expect=0, desc="read of 0x6000_1200 must read 0 like every other alias", bug="F5")
    t.wr(S + 0x1200, 0x0, desc="write to 0x6000_1200 (RTCDR alias) is OKAY")
    t.wr(AMUX + 2, 0x00, size=1)       # byte lane 2 strobe
    # F6 fixed: a lane-2 byte write must leave the input select (lane 0) alone
    t.rd(AMUX, mask=0x3, expect=0x2, desc="byte write to AMUX lane 2 completes and keeps the input select")
    t.wr(RTCMR, 0xFFFFFF00)        # park the alarm far away again
    t.wr(AMUX, 0); t.wr(PLL, 0); t.wr(ALARM, 5)
    t.wr(RTCCTRL, 1, desc="RTC_CTRL re-enabled")
    return t


# -----------------------------------------------------------------------------
def arm(t, offset, at=10000):
    """Make the controller arm with `offset` using only bus accesses: pause,
    load a known time, point RTCMR 2 s ahead, wait for the match, set the
    offset, resume -> one serviced sample, re-arm at time + offset."""
    t.wr(RTCCTRL, 0)
    t.spin(0x40)
    # one ADP command line takes ~20 RTC seconds in this harness (CLK1HZ =
    # HCLK/100), so the match is placed 300 s after the load
    t.wr(RTCLR, at)
    t.wr(RTCICR, 1)
    t.wr(RTCMR, at + 300)
    t.wait_until(RTCRIS, 0x1, 0x1, desc="firmware RTCMR match raises RTCRIS (polling paused)")
    t.wr(ALARM, offset)
    t.wr(FCLR, 1)
    t.wr(RTCCTRL, 1)
    # >= 1 sample: with short offsets the FIFO may already be full by the time
    # the next ADP command executes (~20 RTC seconds per command line)
    t.rd(STATUS, mask=0x3, check=lambda v, c: v != 0, desc="resume services the pending alarm (FIFO not empty)")
    t.rd(RTCRIS, mask=1, expect=0, desc="service cleared RTCRIS")
    t.rd(RTCMR, check=lambda v, c, o=offset, a=at: ((v - o - (a + 300)) & 0xFFFFFFFF) < 2000,
         desc="re-armed RTCMR = RTC time at arm + offset %d" % offset)
    t.wr(FCLR, 1)


def sens_rtc():
    t = AdpTest("sens_rtc", "PL031 passthrough, RTC alarm hazards (RTC boundary - re-run with real PL031)",
                max_cycles=4000000)
    # access while the counter is still in reset: straight after a debugger reset
    t.debug_reset()
    t.rd(RTCDR, desc="RTCDR read straight after a reset completes OKAY")
    t.wr(RTCCTRL, 0)
    t.spin(0x40)
    t.rd(RTCCR, mask=1, expect=1, desc="RTCCR.start = 1 (counter enabled by the controller)")
    t.rd(RTCIMSC, mask=1, expect=1, desc="RTCIMSC = 1 (alarm unmasked by the controller)")
    t.rd(RTCRIS, capture="ris"); t.rd(RTCMIS, capture="mis")
    t.post(lambda c: (c["mis"] & 1) == (c["ris"] & 1), "RTCMIS = RTCRIS & RTCIMSC")
    t.rd(RTCICR, desc="RTCICR (WO) read OKAY")
    t.rd(RTCLR, desc="RTCLR read OKAY")
    t.wr(RTCLR, 1000)
    t.rd(RTCDR, check=lambda v, c: 1000 <= v <= 1100, desc="RTCLR load is visible in RTCDR")
    t.rd(RTCLR, expect=1000, desc="RTCLR reads back the last value written (PL031 TRM)")
    t.wr(RTCDR, 0xFFFFFFFF)
    t.rd(RTCDR, check=lambda v, c: 1000 <= v <= 1200, desc="write to read-only RTCDR is ignored")
    for v in (0x0, 0x1, 0xFFFFFFFF, 0x12345678):
        t.wr(RTCMR, v)
        t.rd(RTCMR, expect=v, desc="RTCMR write/read-back 0x%08x" % v)
    t.wr(RTCCR, 0)
    t.rd(RTCCR, mask=1, expect=1, desc="RTCCR write 0 does not stop the counter (PL031 TRM)")
    t.wr(RTCIMSC, 0)
    t.rd(RTCIMSC, mask=1, expect=0, desc="RTCIMSC write 0 read-back")
    t.rd(RTCMIS, mask=1, expect=0, desc="RTCMIS = 0 while masked")
    t.wr(RTCIMSC, 1)
    t.rd(RTCIMSC, mask=1, expect=1, desc="RTCIMSC write 1 read-back")
    t.wr(RTCRIS, 1, desc="write to read-only RTCRIS is OKAY")
    t.wr(RTCMIS, 1, desc="write to read-only RTCMIS is OKAY")
    # firmware match while paused, held pending for a long time
    t.wr(RTCLR, 2000); t.wr(RTCICR, 1); t.wr(RTCMR, 2300)
    t.wait_until(RTCRIS, 1, 1, desc="firmware RTCMR match raises RTCRIS while paused")
    t.rd(RTCMIS, mask=1, expect=1, desc="RTCMIS set for the unmasked match")
    t.rd(STATUS, mask=0x20, expect=0x20, desc="STATUS[5] mirrors the pending RTC interrupt")
    t.wr(FCLR, 1)
    t.spin(0xFFF)
    t.spin(0xFFF)
    fifo_empty(t, "no autonomous sample while paused, even with the alarm pending")
    t.wr(RTCCTRL, 1)
    wait_sample(t, "resume services the pending alarm: one sample")
    t.rd(RTCRIS, mask=1, expect=0, desc="servicing cleared RTCRIS")
    t.rd(STATUS, mask=0x20, expect=0x00, desc="STATUS[5] clears with the interrupt")
    # short pause: interrupt pending for only a few ADP commands, then resume
    t.wr(RTCCTRL, 0)
    t.wr(RTCLR, 3000); t.wr(RTCICR, 1); t.wr(RTCMR, 3200)
    t.wait_until(RTCRIS, 1, 1, desc="match while paused (short hold)")
    t.wr(RTCCTRL, 1)
    t.rd(RTCRIS, mask=1, expect=0, desc="short-hold alarm serviced on resume")
    # passthrough reads colliding with arm cycles (alarm every 2 s): wait states, never ERROR
    arm(t, 2)
    for _ in range(40):
        t.rd(RTCDR, desc="RTCDR read during autonomous polling (offset 2) is OKAY")
    # a burst of back-to-back-ish passthrough reads (ADP poll loop, mask 0 never
    # matches value 1) - lands on many arm cycles; must complete, never ERROR
    t.poll(RTCDR, 0x0, 0x1, count=0x800, expect_match=False,
           desc="2048 polled RTCDR reads across arm cycles complete (no hang)")
    t.rd(RTCDR, desc="RTCDR read after the poll burst is OKAY")
    # alarm_offset classes (F8)
    arm(t, 12)
    wait_sample(t, "offset 12: the alarm fires", count=0xFFF)
    arm(t, 0)
    t.spin(0xFFF)
    t.rd(STATUS, mask=0x3, check=lambda v, c: v != 0,
         desc="offset 0: autonomous sampling must not stop (alarm armed at 'now')", bug="F8-OFFSET0")
    arm(t, 1)
    t.spin(0x800)
    t.rd(STATUS, mask=0x3, check=lambda v, c: v != 0,
         desc="offset 1: autonomous sampling continues", bug="F8-OFFSET1")
    arm(t, 0xFFFFFFFF)
    t.spin(0x800)
    fifo_empty(t, "offset 0xFFFFFFFF: no sample (alarm armed one second in the past = 2^32-1 s)")
    # firmware sets the clock forward via RTCLR while polling (offset 3)
    arm(t, 3)
    wait_sample(t, "offset 3: the alarm fires")
    t.wr(RTCLR, 50000)
    t.wr(FCLR, 1)
    t.spin(0xFFF)
    t.rd(STATUS, mask=0x3, check=lambda v, c: v != 0,
         desc="autonomous sampling continues after RTCLR sets the clock forward", bug="RTCLR-FWD")
    arm(t, 5)
    wait_sample(t, "firmware re-arm (pause, RTCMR, resume) restores autonomous sampling")
    return t


# -----------------------------------------------------------------------------
REGIONS = [  # (name, base, readable OK, writable OK, RAM)
    ("zero page (REMAP=1: bootrom)", 0x00000000, True, None, False),
    ("BOOTROM_0", 0x10000000, True, None, False),
    ("IMEM_0", 0x20000000, True, True, True),
    ("DMEM_0", 0x30000000, True, True, True),
    ("EXPRAM_L", 0x80000000, True, True, True),
    ("EXPRAM_H", 0x90000000, True, True, True),
]


def bus_debug():
    t = AdpTest("bus_debug", "debugger (ADP) master: every region x dir x size, error responses")
    # RAM regions: word/half/byte writes and reads, lane placement
    for name, base, _, _, ram in REGIONS:
        if not ram:
            continue
        a = base + 0x100
        t.wr(a, 0x11223344, desc="%s word write OKAY" % name)
        t.wr(a + 1, 0xAA, size=1, desc="%s byte write OKAY" % name)
        t.wr(a + 2, 0xBBCC, size=2, desc="%s halfword write OKAY" % name)
        t.rd(a, expect=0xBBCCAA44, desc="%s byte/halfword writes update only their lanes" % name)
        t.A(a); t.R(4, size=1, expect=[0x44, 0xAA, 0xCC, 0xBB], desc="%s byte reads" % name)
        t.A(a); t.R(2, size=2, expect=[0xAA44, 0xBBCC], desc="%s halfword reads" % name)
    # ROMs: reads OK in every size; writes do not change the contents
    for name, base in (("BOOTROM_0", 0x10000000), ("zero page (bootrom)", 0x00000000)):
        t.rd(base, capture="rom0_%x" % base, desc="%s word read OKAY" % name)
        t.A(base); t.R(1, size=2, desc="%s halfword read OKAY" % name)
        t.A(base); t.R(1, size=1, desc="%s byte read OKAY" % name)
    t.post(lambda c: c["rom0_0"] == c["rom0_10000000"], "0x0000_0000 reads the bootrom while REMAP=1")
    t.wr(0x10000000, 0xFFFFFFFF, err=None)
    t.rd(0x10000000, check=lambda v, c: v == c["rom0_10000000"], desc="write to BOOTROM_0 does not change it")
    t.wr(0x00000004, 0x0000, size=2, err=None)
    t.wr(0x00000006, 0x00, size=1, err=None)
    # sensing region: canonical, 64 KB alias, 0xA-0xD mirror; all sizes, both directions
    for base in (0x60000000, 0x60010000, 0x7FFF0000, 0xA0000000, 0xDFFF0000):
        t.rd(base + 0x224, desc="EXP 0x%08x word read OKAY" % (base + 0x224))
        t.A(base + 0x224); t.R(1, size=2, desc="EXP 0x%08x halfword read OKAY" % (base + 0x224))
        t.A(base + 0x224); t.R(1, size=1, desc="EXP 0x%08x byte read OKAY" % (base + 0x224))
        t.wr(base + 0x100, 0x0, desc="EXP 0x%08x word write OKAY" % (base + 0x100))
        t.wr(base + 0x100, 0x0, size=2, desc="EXP 0x%08x halfword write OKAY" % (base + 0x100))
        t.wr(base + 0x100, 0x0, size=1, desc="EXP 0x%08x byte write OKAY" % (base + 0x100))
    # SYSIO: APB subsystem, GPIO0/1, sysctrl, default-slave holes
    for a, n in ((0x40000000, "APB timer0"), (0x40010000, "GPIO0"), (0x40011000, "GPIO1"),
                 (SYSCTRL, "sysctrl")):
        t.rd(a, desc="%s word read OKAY" % n)
        t.A(a); t.R(1, size=2, desc="%s halfword read OKAY" % n)
        t.A(a); t.R(1, size=1, desc="%s byte read OKAY" % n)
    for a in (0x40010000, 0x40011000):
        t.wr(a + 0x10, 0x0, desc="GPIO 0x%08x word write OKAY" % a)
        t.wr(a + 0x10, 0x0, size=2, desc="GPIO 0x%08x halfword write OKAY" % a)
        t.wr(a + 0x10, 0x0, size=1, desc="GPIO 0x%08x byte write OKAY" % a)
    # default slave: every unmapped hole answers ERROR in every size and direction
    for a, n in ((0x40012000, "SYSIO hole 0x4001_2000"), (0x4001E000, "SYSIO hole 0x4001_E000"),
                 (0x40020000, "SYSIO hole 0x4002_0000"), (0x5FFFF000, "SYSIO hole 0x5FFF_F000"),
                 (0xE0000000, "0xE000_0000 (PPB from the debugger)"), (0xEFFFFFFC, "0xEFFF_FFFC"),
                 (0xF0040000, "0xF004_0000 above SYSTABLE"), (0xFFFFFFFC, "0xFFFF_FFFC")):
        t.rd(a, err=True, desc="%s word read -> ERROR" % n)
        t.A(a); t.R(1, size=2, err=True, desc="%s halfword read -> ERROR" % n)
        t.A(a); t.R(1, size=1, err=True, desc="%s byte read -> ERROR" % n)
        t.wr(a, 0x0, err=True, desc="%s word write -> ERROR" % n)
        t.wr(a, 0x0, size=2, err=True, desc="%s halfword write -> ERROR" % n)
        t.wr(a, 0x0, size=1, err=True, desc="%s byte write -> ERROR" % n)
        # the master recovers: next transfer after an ERROR is OKAY
        t.rd(0x20000100, expect=0xBBCCAA44, desc="first transfer after the %s ERROR is OKAY with correct data" % n)
    # SYSTABLE (ROM table): reads OK in every size, writes don't change it
    t.rd(0xF0000000, capture="st0", desc="SYSTABLE word read OKAY")
    t.A(0xF0000000); t.R(1, size=2, desc="SYSTABLE halfword read OKAY")
    t.A(0xF0000000); t.R(1, size=1, desc="SYSTABLE byte read OKAY")
    t.rd(0xF003FFFC, desc="SYSTABLE top word (0xF003_FFFC) read OKAY")
    t.wr(0xF0000000, 0xFFFFFFFF, err=None)
    t.wr(0xF0000000, 0xFFFF, size=2, err=None)
    t.wr(0xF0000000, 0xFF, size=1, err=None)
    t.rd(0xF0000000, check=lambda v, c: v == c["st0"], desc="writes to SYSTABLE do not change it")
    # REMAP: with REMAP=0 the zero page is IMEM (debugger view), back to bootrom with REMAP=1
    t.wr(0x20000000, 0x600DF00D)
    t.wr(SYSCTRL, 0, desc="sysctrl REMAP=0 write OKAY")
    t.rd(0x00000000, expect=0x600DF00D, desc="REMAP=0: 0x0000_0000 reads IMEM")
    t.wr(0x00000004, 0x0BADBEEF, desc="REMAP=0: write to 0x0000_0004 is OKAY")
    t.rd(0x20000004, expect=0x0BADBEEF, desc="REMAP=0: write via 0x0 landed in IMEM")
    t.A(0x0); t.R(1, size=2, expect=0xF00D, desc="REMAP=0: halfword read of IMEM via 0x0")
    t.A(0x0); t.R(1, size=1, expect=0x0D, desc="REMAP=0: byte read of IMEM via 0x0")
    t.wr(SYSCTRL, 1, desc="sysctrl REMAP=1 write OKAY")
    t.rd(0x00000000, check=lambda v, c: v == c["rom0_10000000"], desc="REMAP=1: 0x0000_0000 reads the bootrom again")
    return t


# -----------------------------------------------------------------------------
def sysio_apb():
    t = AdpTest("sysio_apb", "SYSIO APB subsystem: every slot x dir x size, PSLVERR slots")
    # slot -> expected bus error. 3/7/9/10: unused ports tied PSLVERR=1 in
    # nanosoc_sysio_apb_ss; 12/13/15: DMA/unused external ports, no DMA (F14).
    slots = {0: "timer0", 1: "timer1", 2: "dualtimer", 3: "unused3", 4: "usrt0", 5: "usrt1",
             6: "uart2", 7: "unused7", 8: "watchdog", 9: "unused9", 10: "unused10",
             11: "test_slave", 12: "dmac1 (absent)", 13: "ext13 (unused)", 14: "debug usrt",
             15: "dmac0 (absent)"}
    errs = {3, 7, 9, 10, 12, 13, 15}
    for n, name in slots.items():
        a = 0x40000000 + (n << 12)
        e = n in errs
        what = "ERROR" if e else "OKAY"
        t.rd(a, err=e, desc="APB slot %d %s: read -> %s" % (n, name, what))
        # offset 0 writes of 0 are harmless on every CMSDK peripheral
        # (timer CTRL, dualtimer LOAD, UART DATA, watchdog LOAD)
        t.wr(a, 0x0, err=e, desc="APB slot %d %s: word write -> %s" % (n, name, what))
        t.wr(a, 0x0, size=2, err=e, desc="APB slot %d %s: halfword write -> %s" % (n, name, what))
        t.wr(a, 0x0, size=1, err=e, desc="APB slot %d %s: byte write -> %s" % (n, name, what))
        t.wr(a + 1, 0x0, size=1, err=e)
        t.wr(a + 2, 0x0, size=2, err=e)
        t.A(a); t.R(1, size=1, err=e)
        t.A(a); t.R(1, size=2, err=e)
        # recovery after a PSLVERR-generated ERROR
        t.rd(ALARM, check=lambda v, c: True, desc="transfer after APB slot %d access is OKAY" % n)
    # SYSIO default slave holes
    for a in (0x40012000, 0x40018000, 0x4001EFFC, 0x40020000, 0x50000000):
        t.rd(a, err=True, desc="SYSIO default slave 0x%08x read -> ERROR" % a)
        t.wr(a, 0x0, err=True, desc="SYSIO default slave 0x%08x write -> ERROR" % a)
    return t


# -----------------------------------------------------------------------------
def sysctrl():
    t = AdpTest("sysctrl", "system control registers (0x4001_F000)")
    # first reads after the prologue's debugger reset: reset values
    t.rd(SYSCTRL + 0x000, expect=1, desc="REMAP reset value 1")
    t.rd(SYSCTRL + 0x004, expect=0, desc="PMUENABLE reset value 0")
    t.rd(SYSCTRL + 0x008, expect=0, desc="LOCKUPRESET reset value 0")
    t.rd(SYSCTRL + 0x010, mask=0xFFFFFFF8, expect=0, desc="RESETINFO[31:3] read 0")
    t.rd(SYSCTRL + 0x010, mask=0x7, expect=0,
         desc="RESETINFO = 0 after a debugger reset (debugger reset is not a recorded cause, F21)")
    # control bits written 0 and 1, reserved bits, sizes
    for off, n, rv in ((0x004, "PMUENABLE", 0), (0x008, "LOCKUPRESET", 0), (0x000, "REMAP", 1)):
        a = SYSCTRL + off
        t.wr(a, 1); t.rd(a, expect=1, desc="%s write 1 read-back" % n)
        t.wr(a, 0); t.rd(a, expect=0, desc="%s write 0 read-back" % n)
        t.wr(a, 0xFFFFFFFF); t.rd(a, expect=1, desc="%s reserved bits read 0" % n)
        t.wr(a + 1, 0x00, size=1)
        t.rd(a, expect=1, desc="%s byte write to lane 1 has no effect (bit0 is lane 0)" % n)
        t.wr(a + 2, 0x0000, size=2)
        t.rd(a, expect=1, desc="%s halfword write to [31:16] has no effect" % n)
        t.wr(a, 0x00, size=1)
        t.rd(a, expect=0, desc="%s byte write to lane 0 takes effect" % n)
        t.wr(a, 0x0001, size=2)
        t.A(a); t.R(1, size=1, expect=1, desc="%s byte read" % n)
        t.A(a); t.R(1, size=2, expect=1, desc="%s halfword read" % n)
        t.wr(a, rv)
    # RESETINFO: write-1-to-clear; nothing set (no CPU) -> writes leave it 0
    t.wr(SYSCTRL + 0x010, 0x7)
    t.rd(SYSCTRL + 0x010, expect=0, desc="RESETINFO W1C write with nothing pending reads 0")
    t.wr(SYSCTRL + 0x010, 0x0)
    t.A(SYSCTRL + 0x010); t.R(1, size=1, expect=0, desc="RESETINFO byte read")
    t.A(SYSCTRL + 0x010); t.R(1, size=2, expect=0, desc="RESETINFO halfword read")
    # reserved space: reads 0, writes ignored, never ERROR
    for off in (0x00C, 0x014, 0x018, 0x01C, 0x020, 0x800, 0xFBC, 0xFC0, 0xFCC):
        t.rd(SYSCTRL + off, expect=0, desc="sysctrl reserved 0x%03x reads 0" % off)
        t.wr(SYSCTRL + off, 0xFFFFFFFF, desc="sysctrl reserved 0x%03x write OKAY" % off)
        t.A(SYSCTRL + off); t.R(1, size=1, expect=0)
        t.wr(SYSCTRL + off, 0xFF, size=1)
        t.wr(SYSCTRL + off, 0xFFFF, size=2)
    t.rd(SYSCTRL + 0x000, expect=1, desc="reserved writes left REMAP unchanged")
    t.rd(SYSCTRL + 0x004, expect=0, desc="reserved writes left PMUENABLE unchanged")
    t.rd(SYSCTRL + 0x008, expect=0, desc="reserved writes left LOCKUPRESET unchanged")
    # identification registers (nanosoc_sysctrl localparams)
    ids = [(0xFD0, 0x04), (0xFD4, 0x00), (0xFD8, 0x00), (0xFDC, 0x00), (0xFE0, 0x26), (0xFE4, 0xB8),
           (0xFE8, 0x1B), (0xFF0, 0x0D), (0xFF4, 0xF0), (0xFF8, 0x05), (0xFFC, 0xB1)]
    for off, v in ids:
        t.rd(SYSCTRL + off, expect=v, desc="sysctrl ID register 0x%03x = 0x%02x" % (off, v))
    t.rd(SYSCTRL + 0xFEC, mask=0xFFFFFF0F, expect=0, desc="sysctrl PID3 = {ECOREVNUM, 0}")
    t.A(SYSCTRL + 0xFE0); t.R(1, size=1, expect=0x26, desc="PID0 byte read")
    t.A(SYSCTRL + 0xFE4); t.R(1, size=2, expect=0xB8, desc="PID1 halfword read")
    t.A(SYSCTRL + 0xFF0); t.R(1, size=2, expect=0x0D, desc="CID0 halfword read")
    t.wr(SYSCTRL + 0xFE0, 0xFFFFFFFF, desc="write to PID0 OKAY")
    t.wr(SYSCTRL + 0xFF0, 0xFF, size=1)
    t.wr(SYSCTRL + 0xFF4, 0xFFFF, size=2)
    t.rd(SYSCTRL + 0xFE0, expect=0x26, desc="PID0 is read-only")
    t.rd(SYSCTRL + 0xFF0, expect=0x0D, desc="CID0 is read-only")
    # PMU enabled + lockup reset armed state, then back to reset state
    t.wr(SYSCTRL + 0x004, 1); t.wr(SYSCTRL + 0x008, 1)
    t.rd(SYSCTRL + 0x004, expect=1, desc="PMUENABLE and LOCKUPRESET both set")
    t.wr(SYSCTRL + 0x000, 0)
    t.rd(SYSCTRL + 0x000, expect=0, desc="REMAP=0 with PMU/LOCKUPRESET set")
    t.wr(SYSCTRL + 0x004, 0); t.wr(SYSCTRL + 0x008, 0); t.wr(SYSCTRL + 0x000, 1)
    # warm (debugger) reset restores the reset values
    t.wr(SYSCTRL + 0x008, 1); t.wr(SYSCTRL + 0x000, 0)
    t.debug_reset()
    t.rd(SYSCTRL + 0x000, expect=1, desc="debugger reset restores REMAP=1")
    t.rd(SYSCTRL + 0x008, expect=0, desc="debugger reset restores LOCKUPRESET=0")
    return t


# -----------------------------------------------------------------------------
MEMS = [  # name, base, physical bytes, ROM
    ("BOOTROM_0", 0x10000000, 1024, True),
    ("IMEM_0", 0x20000000, 16384, False),
    ("DMEM_0", 0x30000000, 16384, False),
    ("EXPRAM_L", 0x80000000, 16384, False),
    ("EXPRAM_H", 0x90000000, 16384, False),
    ("SYSTABLE", 0xF0000000, 4096, True),
]


def mem():
    t = AdpTest("mem", "memories and ROM table: first/last/middle word, alias above physical size")
    for name, base, phys, rom in MEMS:
        last = base + phys - 4
        mid = base + phys // 2
        if not rom:
            t.wr(base, 0xF1F2F3F4, desc="%s first word write" % name)
            t.wr(last, 0x1A2B3C4D, desc="%s last physical word write" % name)
            t.wr(mid, 0x55AA55AA)
            t.rd(base, expect=0xF1F2F3F4, desc="%s first word read-back" % name)
            t.rd(last, expect=0x1A2B3C4D, desc="%s last physical word read-back" % name)
            t.rd(mid, expect=0x55AA55AA, desc="%s middle word read-back" % name)
            # above the physical size the 256 MB window wraps onto the array
            t.rd(base + phys, expect=0xF1F2F3F4, desc="%s +%d B aliases the first word" % (name, phys))
            t.rd(base + 2 * phys - 4, expect=0x1A2B3C4D, desc="%s alias of the last word" % name)
            t.wr(base + phys + 8, 0x0BEEF0CC, desc="%s write through the alias" % name)
            t.rd(base + 8, expect=0x0BEEF0CC, desc="%s alias write lands in the array" % name)
            t.wr(last + 3, 0x9E, size=1); t.wr(last, 0x7788, size=2)
            t.rd(last, expect=0x9E2B7788, desc="%s byte/halfword writes at the last word" % name)
            t.A(last); t.R(2, size=2, expect=[0x7788, 0x9E2B], desc="%s halfword reads at the last word" % name)
        else:
            t.rd(base, capture="%s_first" % name, desc="%s first word read" % name)
            t.rd(last, capture="%s_last" % name, desc="%s last physical word read" % name)
            t.rd(mid, desc="%s middle word read" % name)
            t.A(last); t.R(1, size=1, desc="%s byte read" % name)
            t.A(last); t.R(1, size=2, desc="%s halfword read" % name)
            if name == "BOOTROM_0":
                # finding F2: word_addr is HADDR[10:2] against a 256-word ROM
                t.rd(base + phys, capture="%s_alias" % name, desc="%s +1 KB (inside the 2 KB window) read OKAY" % name)
                t.post(lambda c: c["BOOTROM_0_alias"] == c["BOOTROM_0_first"],
                       "BOOTROM_0 upper 1 KB of the window aliases the ROM (F2)")
            else:
                t.rd(base + phys, desc="%s above its 4 KB read OKAY" % name)
            t.wr(base, 0x0, err=None)
            t.wr(last, 0x0, size=2, err=None)
            t.wr(mid, 0x0, size=1, err=None)
            t.rd(base, check=lambda v, c, k="%s_first" % name: v == c[k], desc="%s unchanged by writes" % name)
            t.rd(last, check=lambda v, c, k="%s_last" % name: v == c[k], desc="%s last word unchanged by writes" % name)
    return t


# -----------------------------------------------------------------------------
def adp_cmds():
    t = AdpTest("adp_cmds", "ADP commands: M/V/P/F/U, malformed and empty lines, GPO/GPI")
    # fill 4 words with a value, read them back
    t.A(0x20000200)
    t.raw("V 0x13579bdf", ["V"], desc="V sets the match/fill value", check=lambda v, c: v == 0x13579BDF)
    t.raw("F 0x00000004", ["F"], desc="F fills 4 words")
    t.A(0x20000200)
    t.R(4, expect=[0x13579BDF] * 4, desc="filled words read back")
    # M / V / P: poll for a value that is there, and for one that is not
    t.A(0x20000200)
    t.raw("M 0x0000ffff", ["M"], desc="M sets the poll mask", check=lambda v, c: v == 0xFFFF)
    t.raw("M", ["M"], desc="M without parameter reports the mask", check=lambda v, c: v == 0xFFFF)
    t.raw("V 0x00009bdf", ["V"], desc="V sets the poll value")
    t.raw("V", ["V"], desc="V without parameter reports the value")
    t.raw("P 0x0010", ["P"], err=False, desc="P finds a matching value")
    t.raw("V 0x00001111", ["V"])
    t.raw("P 0x0010", ["P"], err=True, desc="P reports '!' when the count runs out")
    t.raw("P 0x0000", ["P"], desc="P with count 0 echoes")
    # malformed / unknown / empty lines
    t.lines.append("")
    t.lines.append("   ")
    t.raw("Z 1234", [], desc=None)
    t.raw("Q", [], desc=None)
    t.raw("A", ["A"], desc="A without parameter reports the address", check=lambda v, c: v == 0x20000200)
    # control / GPO: report, set, clear, overwrite (bits other than bit0 = reset)
    t.raw("C", ["C"], desc="C reports GPO/GPI")
    t.raw("C 0x00000204", ["C"], desc="C 2xx sets GPO bits", check=lambda v, c: ((v >> 16) & 0x04) == 0x04)
    t.raw("C 0x00000104", ["C"], desc="C 1xx clears GPO bits", check=lambda v, c: ((v >> 16) & 0x04) == 0)
    t.raw("C 0x00000300", ["C"], desc="C 3xx overwrites GPO", check=lambda v, c: ((v >> 16) & 0xFF) == 0)
    t.raw("C 0x00000400", ["C"], desc="C 4xx just reports")
    # S: status / STDIN (no firmware consumer: the byte is not accepted)
    t.raw("S", ["S"], desc="S reports status")
    # U: binary upload of 4 bytes, then read back
    t.A(0x20000300)
    t.raw("U 0x00000004", ["U"], desc="U accepts a 4-byte upload")
    t.lines.append("wxyz")
    t.A(0x20000300)
    t.R(1, expect=0x7A797877, desc="uploaded bytes landed in memory")
    t.lines.append("x")      # lower-case exit -> leaves ADP, ESC re-enters
    t.lines.append("\x1b")
    t.A(0x20000300)
    t.R(1, expect=0x7A797877, desc="ADP usable again after exit + ESC")
    return t


# -----------------------------------------------------------------------------
def _after_pin_reset(t, n):
    t.rd(PLL, expect=0, desc="pin reset %d: sensing PLL_CONTROL back to reset value" % n)
    t.rd(ALARM, expect=5, desc="pin reset %d: RTC_ALARM_OFFSET back to 5" % n)
    t.rd(RTCCTRL, expect=1, desc="pin reset %d: RTC_CTRL back to 1 (polling on)" % n)
    t.rd(SYSCTRL + 0x000, expect=1, desc="pin reset %d: sysctrl REMAP back to 1" % n)
    t.rd(SYSCTRL + 0x008, expect=0, desc="pin reset %d: sysctrl LOCKUPRESET back to 0" % n)
    t.rd(SYSCTRL + 0x010, mask=0x7, expect=0,
         desc="pin reset %d: RESETINFO = 0 (the pin is not a recorded cause, F21)" % n)
    t.rd(0x20000400, expect=0xA5A50000 | n, desc="pin reset %d: IMEM contents survive" % n)
    t.rd(RTCDR, check=lambda v, c: v < 5000,
         desc="pin reset %d: RTC count restarted (nPOR = HRESETn in nanosoc, F9)" % n)
    t.rd(0x00000000, check=lambda v, c: True, desc="pin reset %d: zero page readable (bootrom)" % n)


def reset_pin():
    # spin(0xFFFF) ~ 400k cycles; the first starts ~40k cycles in and is cut
    # short by pulse 1 (2 cycles, < 4) at 300k; the second runs ~420k-820k and is
    # cut by pulse 2 (40 cycles) at 620k.
    t = AdpTest("reset_pin", "NRST pin pulsed mid-run (short and long pulse)", max_cycles=2600000,
                plusargs="+nrst_at=300000 +nrst_len=2 +nrst2_at=620000 +nrst2_len=40")
    for n in (1, 2):
        t.wr(PLL, 0x12345678)
        t.wr(ALARM, 9)
        t.wr(SYSCTRL + 0x008, 1)
        t.wr(SYSCTRL + 0x000, 0)
        t.wr(0x20000400, 0xA5A50000 | n)
        t.rd(PLL, expect=0x12345678, desc="before pin reset %d: PLL_CONTROL set" % n)
        t.wr(RTCLR, 100000)
        t.long_spin()
        t.resync(n)
        _after_pin_reset(t, n)
    return t


def ft1248():
    t = AdpTest("ft1248", "debug access over the FT1248 path (P1[7] strap = 1)", max_cycles=6000000,
                plusargs="+ft1248")
    t.rd(ALARM, expect=5, desc="FT1248: sensing RTC_ALARM_OFFSET reset value")
    t.wr(PLL, 0x5A5AA5A5)
    t.rd(PLL, expect=0x5A5AA5A5, desc="FT1248: word write/read-back through the debugger")
    t.wr(0x20000500, 0x01234567)
    t.A(0x20000500); t.R(4, size=1, expect=[0x67, 0x45, 0x23, 0x01], desc="FT1248: byte reads of IMEM")
    t.rd(0xE0000000, err=True, desc="FT1248: bus error reported over FT1248")
    t.rd(SYSCTRL + 0xFE0, expect=0x26, desc="FT1248: sysctrl PID0")
    t.raw("C", ["C"], desc="FT1248: C reports GPO/GPI")
    t.wr(PLL, 0)
    return t


TESTS = {
    "sens_ahb": sens_ahb,
    "sens_rtc": sens_rtc,
    "bus_debug": bus_debug,
    "sysio_apb": sysio_apb,
    "sysctrl": sysctrl,
    "mem": mem,
    "adp_cmds": adp_cmds,
    "reset_pin": reset_pin,
    "ft1248": ft1248,
}

if __name__ == "__main__":
    sys.exit(main(TESTS))
