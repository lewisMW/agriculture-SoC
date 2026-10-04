#!/usr/bin/env python3
"""
Firmware-free bring-up tool for the sensing peripheral on the ZCU104.

Uses the ADP debug master to read/write the sensing IP's APB registers at
0x6000_0000 directly over the M0's system bus — no firmware image needed, the
Cortex-M0 can sit parked in the bootloader the whole time. This is the fastest
way to prove the hardware (wrapper, FSM, FIFO, RTC) is alive on the board.

Run on the board, as root, inside the pynq venv, after loading the overlay:
    python3 sensing_regs.py status          # decode the status register
    python3 sensing_regs.py time            # RTC seconds counter (read twice!)
    python3 sensing_regs.py settime 0       # write RTCLR via passthrough
    python3 sensing_regs.py trigger         # manual one-shot ADC sample
    python3 sensing_regs.py drain           # pop + print every FIFO sample
    python3 sensing_regs.py clear           # flush the FIFO
    python3 sensing_regs.py poll off        # rtc_ctrl=0: pause autonomous sampling
    python3 sensing_regs.py poll on         # rtc_ctrl=1: resume
    python3 sensing_regs.py period 2        # rtc_alarm_offset = 2 s
    python3 sensing_regs.py peek 0x224      # raw read of any offset
    python3 sensing_regs.py poke 0x104 1    # raw write (e.g. select AMUX ch 1)

Register map (source of truth: Wrapper/adc_apb_wrapper_rev1.v localparams and
nanosoc/system/testcodes/sensing_ip.h — keep all three in sync):
    0x004 status RO   0x008 meas_hi RO   0x00C meas_lo RO (read POPS the FIFO)
    0x100 pll RW      0x104 amux RW      0x108 trigger WO   0x10C cal RW
    0x200-0x21C PL031 passthrough (0x200=RTCDR ... 0x208=RTCLR)
    0x220 fifo_clear WO   0x224 rtc_alarm_offset RW   0x228 rtc_ctrl RW (bit0)
"""
import argparse
import sys
from time import sleep

from nanosoc_adp import ADP

BASE = 0x60000000

STATUS = 0x004
MEAS_HI = 0x008
MEAS_LO = 0x00C          # reading this pops one sample off the FIFO
AMUX = 0x104
TRIGGER = 0x108
RTC_DR = 0x200           # PL031 RTCDR: current time, seconds
RTC_LR = 0x208           # PL031 RTCLR: load register (set time)
FIFO_CLEAR = 0x220
ALARM_OFFSET = 0x224
RTC_CTRL = 0x228         # bit0 = autonomous-polling enable (reset = 1)

FIFO_NAMES = {0: "EMPTY", 1: "READY (has samples)", 2: "FULL"}


def decode_status(v):
    fifo = v & 0x3
    adc = (v >> 2) & 0x3
    print("status = 0x%08X" % v)
    print("  [1:0] FIFO      : %d (%s)" % (fifo, FIFO_NAMES.get(fifo, "?")))
    print("  [3:2] ADC       : %d (%s)" % (adc, "converting" if adc == 1 else "idle"))
    print("  [4]   drop flag : %d (last autonomous sample %s)"
          % ((v >> 4) & 1, "DROPPED - FIFO was full" if (v >> 4) & 1 else "kept"))
    print("  [5]   RTC intr  : %d" % ((v >> 5) & 1))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cmd", choices=["status", "time", "settime", "trigger", "drain",
                                    "clear", "poll", "period", "peek", "poke"])
    ap.add_argument("args", nargs="*")
    ap.add_argument("--max", type=int, default=64, help="drain: max samples to pop")
    a = ap.parse_args()

    adp = ADP()
    adp.read(512, timeout=0.3)   # discard any queued stdout/banner
    adp.monitor_enter()

    rd = lambda off: adp.read_word(BASE + off)
    wr = lambda off, val: adp.write_word(BASE + off, val)

    if a.cmd == "status":
        decode_status(rd(STATUS))

    elif a.cmd == "time":
        t0 = rd(RTC_DR)
        print("RTCDR = %d s" % t0)
        print("waiting 2 s ...")
        sleep(2.0)
        t1 = rd(RTC_DR)
        print("RTCDR = %d s  (delta %d)" % (t1, t1 - t0))
        if t1 == t0:
            print("WARNING: time is not advancing. If this build predates the "
                  "CLK1HZ_DIV synthesis fix (accelerator_subsystem.v), the RTC "
                  "tick is wrong/dead — see DEBUGGING.md §6.")

    elif a.cmd == "settime":
        wr(RTC_LR, int(a.args[0], 0))
        print("RTCLR <= %s; RTCDR now %d" % (a.args[0], rd(RTC_DR)))

    elif a.cmd == "trigger":
        wr(TRIGGER, 1)
        sleep(0.1)
        decode_status(rd(STATUS))
        print("(if FIFO went READY, `drain` to see the sample)")

    elif a.cmd == "drain":
        n = 0
        while (rd(STATUS) & 0x3) != 0 and n < a.max:
            print("sample[%d] = 0x%02X" % (n, rd(MEAS_LO) & 0xFF))
            n += 1
        print("%d sample(s) drained; FIFO now %s"
              % (n, FIFO_NAMES.get(rd(STATUS) & 0x3, "?")))

    elif a.cmd == "clear":
        wr(FIFO_CLEAR, 1)
        print("FIFO cleared")

    elif a.cmd == "poll":
        on = a.args[0].lower() in ("on", "1", "true")
        wr(RTC_CTRL, 1 if on else 0)
        print("autonomous polling %s (rtc_ctrl=%d)" % ("ENABLED" if on else "PAUSED", on))

    elif a.cmd == "period":
        wr(ALARM_OFFSET, int(a.args[0], 0))
        print("rtc_alarm_offset <= %s s (takes effect after the NEXT alarm fires)"
              % a.args[0])

    elif a.cmd == "peek":
        off = int(a.args[0], 0)
        print("[0x%08X] = 0x%08X" % (BASE + off, rd(off)))

    elif a.cmd == "poke":
        off, val = int(a.args[0], 0), int(a.args[1], 0)
        wr(off, val)
        print("[0x%08X] <= 0x%08X" % (BASE + off, val))

    adp.monitor_exit()
    return 0


if __name__ == "__main__":
    sys.exit(main())
