/*
 *-----------------------------------------------------------------------------
 * adc_autonomous_test.c  -  end-to-end autonomous RTC -> FSM -> FIFO test.
 *
 * The intended operating mode: the RTC alarm drives sampling autonomously (no
 * manual trigger); the CPU just polls/drains. Uses the sensing driver.
 *
 *   1. Confirm the RTC is ticking (driver's fault-safe read - it pauses polling
 *      via rtc_ctrl so the rtc_dr passthrough read can't collide/PSLVERR; it does
 *      NOT park with a huge alarm_offset, which would stop autonomous re-arming).
 *   2. Set a short poll period, clear the FIFO, wait for an autonomous sample.
 *   3. Drain, then confirm the RTC re-arms with a second autonomous sample.
 *
 * printf-free (sensing_print.h) so the image fits the 16k-word program memory.
 * Output -> logs/uart2.log (terminal shows the FT1248/ADP tube garble; ignore it).
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

#define ALARM_PERIOD   2u
#define POLL_TIMEOUT   60000u   /* bounded; breaks early on success */

int main(void)
{
    int failures = 0;
    uint32_t t0, t1, n;
    uint8_t buf[16];

    UartStdOutInit();
    sp_str("adc_autonomous_test: start\n");

    /* 1. RTC liveness - fault-safe reads (driver pauses polling; no huge offset) */
    t0 = sensing_read_time();
    sensing_delay(20000u);
    t1 = sensing_read_time();
    sp_str("RTC counter: t0="); sp_hex(t0); sp_str(" t1="); sp_hex(t1);
    sp_str((t1 > t0) ? " (advancing - RTC alive)\n" : " (STUCK - CLK1HZ/nPOR not wired!)\n");
    if (t1 <= t0) {
        sp_str("FAIL: RTC not advancing -> Task D wiring not effective.\n");
        UartEndSimulation();
        return 0;
    }

    /* 2. Autonomous sampling: short period, clear, wait for a sample. */
    sensing_init(ALARM_PERIOD, 0);
    sensing_clear_fifo();
    sp_str("Armed autonomous polling (period=2s). Waiting for sample...\n");
    if (!sensing_wait_sample(POLL_TIMEOUT)) {
        sp_str("FAIL: no autonomous sample. status="); sp_hex(sensing_status()); sp_nl();
        UartEndSimulation();
        return 0;
    }
    sp_str("First autonomous sample acquired (ok)\n");

    n = sensing_fifo_drain(buf, sizeof buf);
    sp_str("Drained "); sp_dec(n); sp_str(" sample(s) from first burst\n");

    /* 3. Confirm the RTC re-arms: wait for a second autonomous sample. */
    sensing_clear_fifo();
    if (!sensing_wait_sample(POLL_TIMEOUT)) {
        sp_str("FAIL: RTC did not re-arm (no second autonomous sample)\n");
        failures++;
    } else {
        sp_str("Second autonomous sample acquired - RTC re-armed (ok)\n");
    }

    sp_str(failures == 0 ? "Test Passed!\n" : "Test FAILED\n");
    UartEndSimulation();
    return 0;
}
