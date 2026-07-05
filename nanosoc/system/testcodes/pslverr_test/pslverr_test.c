/*
 *-----------------------------------------------------------------------------
 * pslverr_test.c  -  hang-safety probe for the RTC passthrough
 *
 * PRE-MANUFACTURE SAFETY TEST. Goal: prove that an RTC passthrough access that
 * collides with an autonomous arm cycle (which returns PSLVERR) cannot hang the
 * device forever.
 *
 * Background: rtc_control grants its internal APB bus to firmware only while the
 * RTC FSM is parked (IDLE/WAITING). A firmware read of the RTC region
 * (rtc_dr/rtc_lr/... 0x200-0x21C) that lands during an arm cycle gets PSLVERR.
 * The cmsdk_ahb_to_apb bridge turns an APB error into an AHB error response, and
 * on Cortex-M0 that is a HardFault. The CMSDK default HardFault_Handler is `b .`
 * (an infinite loop) -> the device would HANG FOREVER. The sensing driver avoids
 * this by pausing autonomous polling before any RTC access (sensing_read_time).
 *
 * This test deliberately does the UNSAFE thing to observe the behaviour:
 *   1. Confirm the RTC is ticking (needs Task D CLK1HZ/nPOR). If not, SKIP.
 *   2. Set the shortest poll period so the FSM re-arms almost continuously.
 *   3. Hammer RAW rtc_dr reads (NO pause) so many land during an arm cycle.
 *
 * We override the weak HardFault_Handler so that IF a collision faults, we
 * REPORT it and END the sim (instead of dead-looping) -> the test itself never
 * hangs, and its output tells us which behaviour is real:
 *   - "PSLVERR_TEST: FAIL (hang risk confirmed)"  -> PSLVERR faults the CPU; an
 *      unguarded RTC access CAN hang -> firmware MUST pause polling (driver does),
 *      and a HardFault handler should be wired before manufacture.
 *   - "PSLVERR_TEST: PASS (no hang)"              -> PSLVERR does not fault here;
 *      the bus error is absorbed. The driver's pause is then belt-and-suspenders.
 *
 * printf-free (image must fit the 16k-word program memory).
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

#define N_COLLIDE   4000u   /* raw unguarded reads to attempt */

/* Shared with the fault handler so it can report progress at fault time. */
volatile uint32_t g_reads = 0;
volatile uint32_t g_sink  = 0;

/*
 * Strong override of the weak startup HardFault_Handler. Reaching here means a
 * bus fault occurred (the collision faulted the CPU). With the default handler
 * this would be `b .` forever. We report and end the sim so the test terminates.
 * We do NOT return (returning re-runs the faulting instruction -> refault loop).
 */
void HardFault_Handler(void)
{
    sp_str("\nHARDFAULT after "); sp_dec(g_reads);
    sp_str(" raw RTC reads -> an unguarded RTC access CAN hang the device.\n");
    sp_str("PSLVERR_TEST: FAIL (hang risk confirmed)\n");
    UartEndSimulation();
    for (;;) { }
}

int main(void)
{
    uint32_t t0, t1, i;

    UartStdOutInit();
    sp_str("pslverr_test: start\n");

    /* 1. RTC must be ticking to create arm-cycle collisions. Use the driver's
     *    fault-safe (pause-based) read for this liveness check. */
    t0 = sensing_read_time();
    sensing_delay(20000u);
    t1 = sensing_read_time();
    sp_str("RTC alive check: t0="); sp_hex(t0); sp_str(" t1="); sp_hex(t1); sp_nl();
    if (t1 == t0) {
        sp_str("SKIP: RTC not ticking (CLK1HZ/nPOR) - cannot provoke a collision. Fix Task D first.\n");
        sp_str("PSLVERR_TEST: SKIPPED\n");
        UartEndSimulation();
        return 0;
    }

    /* 2. Shortest poll period -> the FSM re-arms almost continuously, so it owns
     *    the internal APB bus a large fraction of the time. */
    SENSING_IP_REGS->rtc_ctrl         = RTC_CTRL_POLL_ENABLE;
    SENSING_IP_REGS->rtc_alarm_offset = 1u;
    sensing_delay(2000u);

    /* 3. Hammer RAW rtc_dr reads with NO pause. Some will land during an arm
     *    cycle -> PSLVERR. If PSLVERR faults, HardFault_Handler fires above. */
    sp_str("Hammering "); sp_dec(N_COLLIDE);
    sp_str(" unguarded raw RTC reads to force collisions...\n");
    for (i = 0; i < N_COLLIDE; i++) {
        g_reads = i;
        g_sink  = SENSING_IP_REGS->rtc_dr;   /* raw passthrough read; may PSLVERR */
    }

    /* Reached here => no collision faulted/hung the CPU. */
    sp_str("Completed all "); sp_dec(N_COLLIDE);
    sp_str(" unguarded RTC reads, no fault/hang.\n");
    sp_str("=> PSLVERR does not fault the CPU in this config; driver pause is belt-and-suspenders.\n");
    sp_str("PSLVERR_TEST: PASS (no hang)\n");
    UartEndSimulation();
    return 0;
}
