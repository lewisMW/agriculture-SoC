#ifndef SENSING_CHECK_H
#define SENSING_CHECK_H
/*
 * sensing_check.h - pass/fail bookkeeping for the sensing firmware tests
 * (FW-1..FW-6). printf-free.
 *
 *   SC_CHECK(cond, "what")   counts a check; prints "FAIL: what" when false
 *   sc_finish("name")        prints the failed-check count and the final
 *                            "** TEST PASSED **" / "** TEST FAILED **" line,
 *                            then ends the simulation
 *   SENSING_COUNT_FAULTS     define before including to install a HardFault
 *                            handler that reports the fault and fails the test
 *                            (a fault is never expected in these tests)
 *
 * Timing helpers use the RTC: in the nanosoc simulation CLK1HZ = HCLK/100, so
 * one RTC second is 100 HCLK.
 */
#include <stdint.h>
#include "uart_stdout.h"
#include "sensing_ip.h"
#include "sensing_driver.h"
#include "sensing_print.h"

static volatile uint32_t sc_n_checks = 0;
static volatile uint32_t sc_n_fail   = 0;

static inline void sc_check(int cond, const char *what)
{
    sc_n_checks++;
    if (!cond) {
        sc_n_fail++;
        sp_str("FAIL: "); sp_str(what); sp_nl();
    }
}
#define SC_CHECK(c, what) sc_check((c) != 0, (what))

static inline void sc_finish(const char *name)
{
    sp_str(name); sp_str(": "); sp_dec(sc_n_checks); sp_str(" checks, ");
    sp_dec(sc_n_fail); sp_str(" failed\n");
    if (sc_n_fail == 0) sp_str("** TEST PASSED **\n");
    else                sp_str("** TEST FAILED **\n");
    UartEndSimulation();
}

#ifdef SENSING_COUNT_FAULTS
void HardFault_Handler(void)
{
    sp_str("\nHARDFAULT (expected 0)\n");
    sc_n_fail++;
    sc_finish("fault");
    for (;;) { }
}
#endif

/* Raw RTCDR read (passthrough; stalls, never faults). */
static inline uint32_t sc_rtc_now(void) { return SENSING_IP_REGS->rtc_dr; }

/* Wait for a sample within `secs` RTC seconds of now. Returns 1 if one came.
 * `secs` is measured on the RTC itself (a time jump restarts the measurement). */
static inline int sc_sample_within(uint32_t secs)
{
    uint32_t t0 = sc_rtc_now(), t, guard = 0;
    while (sensing_fifo_empty()) {
        t = sc_rtc_now();
        if (t < t0) t0 = t;                       /* RTCLR moved the clock back */
        if (t - t0 > secs) return 0;
        if (++guard > 200000u) return 0;          /* loop-count watchdog */
    }
    return 1;
}

/* Let `secs` RTC seconds pass. */
static inline void sc_wait_secs(uint32_t secs)
{
    uint32_t t0 = sc_rtc_now(), t, guard = 0;
    do {
        t = sc_rtc_now();
        if (t < t0) t0 = t;
        if (++guard > 400000u) return;
    } while (t - t0 < secs);
}

#endif /* SENSING_CHECK_H */
