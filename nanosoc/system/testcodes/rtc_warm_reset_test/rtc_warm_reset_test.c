/*
 *-----------------------------------------------------------------------------
 * rtc_warm_reset_test.c  -  the RTC keeps the time through a system reset.
 *
 * The RTC, the divider that makes its tick and the tick's prescale register
 * (0x22C) are reset by the system's power-on reset only. A system reset (the
 * processor's or a debugger's SYSRESETREQ, the watchdog, lockup) resets the
 * rest of the sensing peripheral and leaves those three alone.
 *
 * First pass (SYSCON RSTINFO is 0: power-on): selects the fast tick, loads a
 * time, lets it count, and asks for a system reset.
 * Second pass (RSTINFO shows the system reset): the prescale register still
 * holds the fast value, and the time has gone on from where it was. A program
 * that found the reset values here would loop for ever; the first-pass check
 * of RSTINFO catches that as a failure instead.
 *
 * printf-free (sensing_print.h). Ends with "Test Passed!" or "Test FAILED".
 *-----------------------------------------------------------------------------
 */
#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#include "core_cm0.h"
#endif
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#include "core_cm0plus.h"
#endif

#include <stdint.h>
#include "uart_stdout.h"
#include "../sensing_ip.h"
#include "../sensing_driver.h"
#include "../sensing_print.h"

#define RTC_LOAD_VALUE 0x00002000u

static void finish(int ok)
{
    sp_str(ok ? "Test Passed!\n" : "Test FAILED\n");
    UartEndSimulation();
    for (;;) ;
}

int main(void)
{
    uint32_t rst = CMSDK_SYSCON->RSTINFO;
    uint32_t pre = SENSING_IP_REGS->rtc_prescale;
    uint32_t t0, t1;
    int ok = 1;

    UartStdOutInit();
    sp_str("rtc_warm_reset_test: start\n");

    if (rst == 0u) {
        /* first pass */
        if (pre != SENSING_RTC_PRESCALE_RESET) {
            sp_str("FAIL: rtc_prescale is not at its reset value after power-on: "); sp_dec(pre); sp_nl();
            finish(0);
        }
        SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
        sensing_set_time(RTC_LOAD_VALUE);
        sensing_delay(3000u);                           /* a few tens of ticks */
        t0 = sensing_read_time();
        sp_str("  first pass: time "); sp_hex(t0); sp_str(", asking for a system reset\n");
        if (t0 <= RTC_LOAD_VALUE) { sp_str("FAIL: the RTC did not count\n"); finish(0); }
        sensing_delay(2000u);                           /* let the last characters out */
        NVIC_SystemReset();
        for (;;) ;
    }

    /* second pass */
    sp_str("  second pass: RSTINFO "); sp_hex(rst); sp_str(", rtc_prescale "); sp_dec(pre); sp_nl();
    if ((rst & 1u) == 0u) { sp_str("  FAIL: RSTINFO does not show a system reset\n"); ok = 0; }
    if (pre != SENSING_RTC_PRESCALE_FAST) { sp_str("  FAIL: the system reset changed rtc_prescale\n"); ok = 0; }
    t0 = sensing_read_time();
    sensing_delay(3000u);
    t1 = sensing_read_time();
    sp_str("  time after the reset "); sp_hex(t0); sp_str(", then "); sp_hex(t1); sp_nl();
    if (t0 <= RTC_LOAD_VALUE || t0 > RTC_LOAD_VALUE + 0x1000u) { sp_str("  FAIL: the time was not kept\n"); ok = 0; }
    if (t1 <= t0) { sp_str("  FAIL: the RTC is not counting after the reset\n"); ok = 0; }
    if (ok) sp_str("  ok: the time was kept through the system reset and is still counting\n");
    finish(ok);
    return 0;
}
