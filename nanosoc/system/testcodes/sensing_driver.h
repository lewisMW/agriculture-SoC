#ifndef SENSING_DRIVER_H
#define SENSING_DRIVER_H
/*
 * sensing_driver.h - small firmware driver for the agriculture sensing peripheral.
 *
 * Header-only (all static inline) so no makefile change is needed: the testcode
 * build only compiles $(TESTNAME).c, so a separate .c would never be linked.
 * Unused inlines are dropped by the compiler. printf-free (see sensing_print.h),
 * so it stays within the 16k-word program memory.
 *
 * Usage:
 *     #include "../sensing_ip.h"
 *     #include "../sensing_driver.h"
 *     sensing_init(5, 0);                 // 5s poll period, no calibration
 *     uint8_t buf[16];
 *     uint32_t n = sensing_fifo_drain(buf, 16);
 *     uint32_t t = sensing_read_time();   // fault-safe live RTC time
 *
 * RTC passthrough (now fault-safe): reads/writes of the RTC region
 * (rtc_dr/rtc_lr/... at 0x200-0x21C) go through rtc_control_2's passthrough. If an
 * access collides with an autonomous arm cycle it is now STALLED (APB wait
 * states, PREADY held low) until the RTC FSM parks, then completes normally -
 * it no longer returns PSLVERR. So an unguarded RTC access can no longer fault
 * or hang the CPU (see pslverr_test). The time helpers below
 * still PAUSE autonomous polling first (rtc_ctrl bit0 = 0) before touching the
 * RTC: this is now DEFENSIVE only, and it also avoids the few-cycle wait-state
 * latency by parking the FSM in WAITING (bus always granted) up front. The
 * caller's polling state is restored afterwards: if polling was paused (e.g.
 * by sensing_quiesce) it stays paused. Wrapper-local registers
 * (status/measurement/trigger/fifo_clear/alarm_offset/adc_cal/rtc_ctrl) never
 * stall and are accessed directly.
 *
 * Production images should also install the HardFault backstop in
 * sensing_fault.h (a controlled reset instead of the weak dead-loop handler) to
 * recover from any OTHER unexpected bus fault.
 */
#include <stdint.h>
#include "sensing_ip.h"

/* Cycles to wait after disabling polling for the RTC FSM to reach WAITING
 * (parked) before a passthrough access. One arm cycle is ~12 PCLK; this is
 * comfortably longer. */
#ifndef SENSING_PARK_SETTLE
#define SENSING_PARK_SETTLE  300u
#endif

static inline void sensing_delay(volatile uint32_t n)
{
    while (n--) { __asm volatile("nop"); }
}

/* ---- configuration ------------------------------------------------------- */

/* Set the autonomous poll period (RTC seconds) and calibration path, and make
 * sure autonomous polling is enabled. A new period is armed at once (FIX-1):
 * the next sample comes within period_s + 1 RTC seconds of this call, even if
 * a much longer period was armed before. (Before FIX-1 it applied only after
 * the currently armed alarm fired; firmware had to write RTCMR to shorten it.)
 * Period 0 is treated as 1. */
static inline void sensing_init(uint32_t period_s, int calibrate)
{
    SENSING_IP_REGS->rtc_alarm_offset = period_s;
    SENSING_IP_REGS->adc_cal          = calibrate ? ADC_CAL_ENABLE : 0u;
    SENSING_IP_REGS->rtc_ctrl         = RTC_CTRL_POLL_ENABLE;
}

/* Pause / resume autonomous RTC-driven sampling (Task A, rtc_ctrl @0x228).
 * While paused the RTC counter keeps running and passthrough reads are safe. */
static inline void sensing_polling_disable(void) { SENSING_IP_REGS->rtc_ctrl = 0u; }
static inline void sensing_polling_enable(void)  { SENSING_IP_REGS->rtc_ctrl = RTC_CTRL_POLL_ENABLE; }

/* ---- RTC time (fault-safe via pause/resume) ------------------------------ */

/* Pause polling and let the RTC FSM park; returns the previous rtc_ctrl value
 * for sensing_rtc_unpark(). */
static inline uint32_t sensing_rtc_park(void)
{
    uint32_t prev = SENSING_IP_REGS->rtc_ctrl & RTC_CTRL_POLL_ENABLE;
    sensing_polling_disable();
    sensing_delay(SENSING_PARK_SETTLE);
    return prev;
}

/* Restore the polling state saved by sensing_rtc_park(). */
static inline void sensing_rtc_unpark(uint32_t prev) { SENSING_IP_REGS->rtc_ctrl = prev; }

/* Read the live RTC timestamp. Leaves autonomous polling as it found it. */
static inline uint32_t sensing_read_time(void)
{
    uint32_t t, prev = sensing_rtc_park();
    t = SENSING_IP_REGS->rtc_dr;
    sensing_rtc_unpark(prev);
    return t;
}

/* Load a known RTC time (RTCLR). Also resets the counter's reference. Leaves
 * autonomous polling as it found it. */
static inline void sensing_set_time(uint32_t v)
{
    uint32_t prev = sensing_rtc_park();
    SENSING_IP_REGS->rtc_lr = v;
    sensing_rtc_unpark(prev);
}

/* ---- sampling ------------------------------------------------------------ */

static inline void sensing_trigger_oneshot(void) { SENSING_IP_REGS->adc_trigger = ADC_TRIGGER_ONESHOT; }
static inline void sensing_clear_fifo(void)       { SENSING_IP_REGS->fifo_clear  = 1u; }

/* ---- status -------------------------------------------------------------- */

static inline uint32_t sensing_status(void)   { return SENSING_IP_REGS->status_reg; }
static inline int sensing_fifo_empty(void)    { return GET_FIFO_STATUS(sensing_status()) == STATUS_FIFO_EMPTY; }
static inline int sensing_fifo_full(void)     { return GET_FIFO_STATUS(sensing_status()) == STATUS_FIFO_FULL; }
static inline int sensing_sample_dropped(void){ return (sensing_status() & STATUS_FIFO_DROP_MASK) != 0; }
static inline int sensing_rtc_intr(void)      { return (sensing_status() & STATUS_RTC_INTR_MASK) != 0; }
/* STATUS[6] (FIX-2): the last conversion timed out (dead ADC); no sample was
 * written. Sticky until the next sample is written. */
static inline int sensing_adc_timed_out(void) { return (sensing_status() & STATUS_ADC_TIMEOUT_MASK) != 0; }

/* Wait until the ADC is idle (STATUS[3:2] != running). Bounded by the
 * hardware: the sampling FSM gives up on a conversion after its timeout
 * (FIX-2, 85680 PCLK at the default parameters) and drops adc_en. */
static inline void sensing_wait_adc_idle(void)
{
    while (GET_ADC_STATUS(sensing_status()) == STATUS_ADC_RUNNING) { }
}

/* Results of sensing_trigger_wait(). */
#define SENSING_SAMPLE_OK       1   /* a sample was written to the FIFO */
#define SENSING_SAMPLE_TIMEOUT  0   /* the conversion timed out (STATUS[6]); no sample */
#define SENSING_SAMPLE_DROPPED (-1) /* the FIFO was full; no conversion was started */

/* Manual one-shot conversion, waited to completion. Returns SENSING_SAMPLE_OK,
 * SENSING_SAMPLE_TIMEOUT or SENSING_SAMPLE_DROPPED. A trigger that finds the
 * FIFO full starts no conversion and writes no sample; the FIFO-drop flag
 * (STATUS[4]) then reads 1 (it is set when a trigger finds the FIFO full and
 * cleared when one finds room, so it always describes the latest trigger), and
 * is checked first. Otherwise STATUS[6] tells a timed-out conversion from a
 * written sample (a written sample clears it). Pause autonomous polling first
 * (sensing_quiesce) if an autonomous trigger must not land in between. The
 * settle lets the trigger reach the ADC. */
static inline int sensing_trigger_wait(void)
{
    sensing_trigger_oneshot();
    sensing_delay(SENSING_PARK_SETTLE);
    sensing_wait_adc_idle();
    if (sensing_sample_dropped()) return SENSING_SAMPLE_DROPPED;
    return sensing_adc_timed_out() ? SENSING_SAMPLE_TIMEOUT : SENSING_SAMPLE_OK;
}

/* Stop autonomous sampling and wait out any conversion already in flight, so
 * a following clear/count sees no stray sample. Pausing only blocks NEW alarms;
 * a conversion started just before it still completes and pushes a sample.
 * The settle lets a trigger already in the FSM pipeline reach the ADC first. */
static inline void sensing_quiesce(void)
{
    sensing_polling_disable();
    sensing_delay(SENSING_PARK_SETTLE);
    sensing_wait_adc_idle();
}

/* ---- draining ------------------------------------------------------------ */

/* Pop up to `max` samples into `buf` (buf may be NULL to just discard). Each
 * measurement_low read pops one FIFO entry. Returns the count popped. */
static inline uint32_t sensing_fifo_drain(uint8_t *buf, uint32_t max)
{
    uint32_t n = 0;
    while (n < max && !sensing_fifo_empty()) {
        uint32_t s = SENSING_IP_REGS->measurement_low;
        if (buf) buf[n] = (uint8_t)s;
        n++;
    }
    return n;
}

/* Bounded poll until a sample is available. Returns 1 on data, 0 on timeout.
 * (WFI/sleep between samples needs an interrupt routed to the NVIC — not wired
 * yet, so this polls.) */
static inline int sensing_wait_sample(uint32_t timeout_polls)
{
    while (timeout_polls--) {
        if (!sensing_fifo_empty()) return 1;
    }
    return 0;
}

#endif /* SENSING_DRIVER_H */
