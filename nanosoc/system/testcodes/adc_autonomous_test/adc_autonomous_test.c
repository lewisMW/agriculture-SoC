/*
 *-----------------------------------------------------------------------------
 * adc_autonomous_test.c
 *
 * End-to-end firmware test of the INTENDED operating mode: the RTC alarm drives
 * the sampling FSM autonomously (no manual trigger), the CPU just polls/drains.
 * This is the path adc_trigger_test does NOT cover (that one uses the manual
 * 0x108 trigger).
 *
 *   1. Clear the FIFO.
 *   2. Set a short poll period (rtc_alarm_offset) so the alarm fires quickly.
 *   3. Poll status until an autonomous sample appears (RTC alarm -> FSM -> FIFO).
 *   4. Confirm the RTC re-arms: wait for a SECOND autonomous sample.
 *   5. Drain and report.
 *
 * PREREQUISITE (NanoSoC): accelerator_subsystem.v must wire CLK1HZ + nPOR into
 * the sensor_wrapper (currently unconnected — see VERIFICATION.md). Without that
 * the RTC never ticks and no autonomous sample ever arrives (this test will
 * report the timeout FAIL). Works once CLK1HZ/nPOR are driven.
 *
 * SIM-TIME CAVEAT: how fast this completes depends on the CLK1HZ rate in the
 * NanoSoC integration (alarm_offset is in RTC "seconds" = CLK1HZ periods). The
 * timeout below is generous; if it times out, lower ALARM_PERIOD or check that
 * CLK1HZ is toggling fast enough in the testbench. A timeout prints a clear
 * FAIL rather than hanging.
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

#include <stdio.h>
#include <stdint.h>
#include "uart_stdout.h"
#include "sensing_ip.h"

#define ALARM_PERIOD   2u          /* RTC seconds between autonomous samples */
#define POLL_TIMEOUT   2000000u    /* max status polls before giving up      */

/* Poll status until the FIFO reports data, or timeout. Returns 1 on data. */
static int wait_for_sample(void)
{
    uint32_t polls = 0;
    while (polls < POLL_TIMEOUT) {
        if (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY)
            return 1;
        polls++;
    }
    return 0;
}

int main(void)
{
    int failures = 0;
    uint32_t drained = 0;

    UartStdOutInit();
    printf("adc_autonomous_test: start\n");

    /* 1. Clean slate */
    SENSING_IP_REGS->fifo_clear = 1;

    /* 2. Short poll period -> RTC alarm fires soon and re-arms each cycle */
    SENSING_IP_REGS->rtc_alarm_offset = ALARM_PERIOD;
    printf("Armed autonomous polling, period = %u RTC-seconds\n", (unsigned)ALARM_PERIOD);

    /* 3. First autonomous sample */
    if (!wait_for_sample()) {
        printf("FAIL: no autonomous sample within timeout (check CLK1HZ rate)\n");
        UartEndSimulation();
        return 0;
    }
    printf("First autonomous sample acquired (ok)\n");

    /* 4. Drain what we have, then confirm the alarm re-arms with a 2nd sample */
    while (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY) {
        volatile uint32_t s = SENSING_IP_REGS->measurement_low;
        (void)s;
        drained++;
        if (drained > 32u) break;   /* safety */
    }
    printf("Drained %u sample(s) from first burst\n", (unsigned)drained);

    if (!wait_for_sample()) {
        printf("FAIL: RTC did not re-arm (no second autonomous sample)\n");
        failures++;
    } else {
        printf("Second autonomous sample acquired — RTC re-armed (ok)\n");
    }

    if (failures == 0)
        printf("Test Passed!\n");
    else
        printf("Test FAILED: %d check(s) failed\n", failures);

    UartEndSimulation();
    return 0;
}
