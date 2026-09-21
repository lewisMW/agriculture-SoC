/*
 *-----------------------------------------------------------------------------
 * rtc_time_test.c
 *
 * End-to-end firmware test of the RTC passthrough path (register region
 * 0x200-0x21C). Verifies that firmware can read the live timestamp and load a
 * known time through the wrapper's address-translated passthrough:
 *
 *   1. Read rtc_dr (RTCDR) — the live count is reachable.
 *   2. Load a known value via rtc_lr (RTCLR).
 *   3. Read rtc_dr back — it reflects the loaded time (>= the value written).
 *
 * The autonomous RTC only grants its APB bus to firmware while parked in
 * WAITING/IDLE; a collision with an arm cycle returns PSLVERR. On Cortex-M0
 * that surfaces as a bus fault with no recovery handler wired yet (see HANDOFF
 * "interrupt routing" gap), so this test first pushes the poll period very high
 * (rtc_alarm_offset) to make re-arm collisions astronomically unlikely, then
 * does its accesses while the RTC sits in WAITING.
 *
 * NOTE: this leans on the RTC being parked. If a future change makes arm cycles
 * frequent, add a HardFault-based retry (HANDOFF Task 2, sensing_read_time).
 *
 * PREREQUISITE (NanoSoC): accelerator_subsystem.v must wire CLK1HZ + nPOR into
 * the sensor_wrapper (currently unconnected — see VERIFICATION.md). Without that
 * the RTC counter never runs and this test cannot pass under NanoSoC.
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
#include "../sensing_print.h"   /* printf-free output: keeps image within 16k-word memory */

#define RTC_LOAD_VALUE   0x00001000u

static void settle(void)
{
    volatile uint32_t i;
    for (i = 0; i < 2000; i++) { __asm volatile ("nop"); }
}

int main(void)
{
    int failures = 0;
    uint32_t t1, t2;

    UartStdOutInit();
    sp_str("rtc_time_test: start\n");

    /* Park the RTC: a huge poll period means it arms once then stays in
     * WAITING, so passthrough accesses below are granted. */
    SENSING_IP_REGS->rtc_alarm_offset = 0x0FFFFFFFu;
    settle();

    /* 1. Read the live time */
    t1 = SENSING_IP_REGS->rtc_dr;
    sp_str("RTCDR (initial) = "); sp_hex(t1); sp_nl();

    /* 2. Load a known time via RTCLR (only reachable through passthrough) */
    SENSING_IP_REGS->rtc_lr = RTC_LOAD_VALUE;
    settle();

    /* 3. Read it back — should reflect the loaded value (>= it, counter may
     *    have ticked on). */
    t2 = SENSING_IP_REGS->rtc_dr;
    sp_str("RTCDR (after load "); sp_hex(RTC_LOAD_VALUE); sp_str(") = "); sp_hex(t2); sp_nl();

    if (t2 < RTC_LOAD_VALUE) {
        sp_str("FAIL: RTCDR did not reflect the loaded time\n");
        failures++;
    } else {
        sp_str("RTC load/read via passthrough works (ok)\n");
    }

    if (failures == 0)
        sp_str("Test Passed!\n");
    else
        sp_str("Test FAILED\n");

    UartEndSimulation();
    return 0;
}
