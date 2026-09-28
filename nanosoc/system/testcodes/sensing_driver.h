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
 * or hang the CPU (see pslverr_test / TEST_RUNBOOK §3.5). The time helpers below
 * still PAUSE autonomous polling first (rtc_ctrl bit0 = 0) before touching the
 * RTC: this is now DEFENSIVE only, and it also avoids the few-cycle wait-state
 * latency by parking the FSM in WAITING (bus always granted) up front. Polling
 * is resumed afterwards. Wrapper-local registers
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
 * sure autonomous polling is enabled. */
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

/* Read the live RTC timestamp without risking a PSLVERR bus fault. */
static inline uint32_t sensing_read_time(void)
{
    uint32_t t;
    sensing_polling_disable();
    sensing_delay(SENSING_PARK_SETTLE);
    t = SENSING_IP_REGS->rtc_dr;
    sensing_polling_enable();
    return t;
}

/* Load a known RTC time (RTCLR). Also resets the counter's reference. */
static inline void sensing_set_time(uint32_t v)
{
    sensing_polling_disable();
    sensing_delay(SENSING_PARK_SETTLE);
    SENSING_IP_REGS->rtc_lr = v;
    sensing_polling_enable();
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
 * yet, HANDOFF gap — so this polls.) */
static inline int sensing_wait_sample(uint32_t timeout_polls)
{
    while (timeout_polls--) {
        if (!sensing_fifo_empty()) return 1;
    }
    return 0;
}

#endif /* SENSING_DRIVER_H */
