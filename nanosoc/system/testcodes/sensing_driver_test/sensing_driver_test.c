/*
 *-----------------------------------------------------------------------------
 * sensing_driver_test.c  -  exercises the sensing_driver.h API.
 *
 * PASS/FAIL gates use the MANUAL-trigger FIFO path, which is deterministic and
 * does NOT depend on the RTC (so this test passes regardless of Task D). It
 * disables autonomous polling first so autonomous samples can't perturb the
 * FIFO counts. The RTC time helpers (read_time/set_time) are exercised too, but
 * reported as INFORMATIONAL — they only advance once Task D makes CLK1HZ tick;
 * either way they must return safely (no hang), which itself is a check.
 *
 * printf-free (sensing_print.h) so the image fits the 16k-word program memory.
 * Output -> logs/uart2.log.
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

#define FILL_N       4u    /* partial fill for the drain-count check */
#define FIFO_DEPTH   16u
#define OVERFILL_N   20u   /* > DEPTH -> reaches FULL and drops the extras */
#define CONV_SETTLE  600u  /* wait for one conversion + FIFO write (as fifo_drain_test) */

int main(void)
{
    int failures = 0;
    uint32_t n, t0, t1, t2;
    uint8_t buf[OVERFILL_N];

    UartStdOutInit();
    sp_str("sensing_driver_test: start\n");

    /* Exercise sensing_init, then pause autonomous polling so ONLY manual
     * triggers feed the FIFO (deterministic counts, RTC-independent). */
    sensing_init(5u, 0);            /* period 5s, no calibration, polling on */
    sensing_polling_disable();      /* Task A: no autonomous samples during the counts */
    sensing_clear_fifo();
    sensing_delay(CONV_SETTLE);

    if (!sensing_fifo_empty()) { sp_str("FAIL: FIFO not empty after clear\n"); failures++; }
    else                         sp_str("clear_fifo -> empty (ok)\n");

    /* --- manual trigger + drain: exact count --- */
    for (n = 0; n < FILL_N; n++) { sensing_trigger_oneshot(); sensing_delay(CONV_SETTLE); }
    n = sensing_fifo_drain(buf, sizeof buf);
    sp_str("trigger x"); sp_dec(FILL_N); sp_str(" -> drained "); sp_dec(n); sp_nl();
    if (n != FILL_N)            { sp_str("FAIL: drain count != triggers\n"); failures++; }
    else                          sp_str("trigger_oneshot + fifo_drain (ok)\n");
    if (!sensing_fifo_empty())  { sp_str("FAIL: FIFO not empty after drain\n"); failures++; }

    /* --- overflow: fill past DEPTH, expect FULL + drop flag, drain exactly 16 --- */
    sensing_clear_fifo();
    sensing_delay(CONV_SETTLE);
    for (n = 0; n < OVERFILL_N; n++) { sensing_trigger_oneshot(); sensing_delay(CONV_SETTLE); }
    if (!sensing_fifo_full())      { sp_str("FAIL: not FULL after overfill\n"); failures++; }
    else                             sp_str("fills to FULL (ok)\n");
    if (!sensing_sample_dropped()) { sp_str("FAIL: drop flag not set on overflow\n"); failures++; }
    else                             sp_str("sample_dropped flag set (ok)\n");
    n = sensing_fifo_drain(buf, sizeof buf);
    sp_str("drained "); sp_dec(n); sp_str(" (expect 16)\n");
    if (n != FIFO_DEPTH)           { sp_str("FAIL: expected 16 samples\n"); failures++; }

    /* --- RTC time helpers: must return safely; advance only once Task D is in. --- */
    sensing_clear_fifo();
    t0 = sensing_read_time();
    sensing_delay(20000u);
    t1 = sensing_read_time();
    sp_str("read_time: t0="); sp_hex(t0); sp_str(" t1="); sp_hex(t1);
    sp_str((t1 != t0) ? " (RTC advancing)\n"
                      : " (RTC not ticking yet - needs Task D; read_time returned safely)\n");

    sensing_set_time(0x00001000u);
    t2 = sensing_read_time();
    sp_str("after set_time(0x1000): "); sp_hex(t2);
    sp_str((t2 >= 0x00001000u) ? " (load reflected)\n" : " (RTC idle - informational)\n");

    /* Restore autonomous polling for anything that runs after. */
    sensing_polling_enable();

    if (failures == 0) sp_str("Test Passed!\n");
    else               sp_str("Test FAILED\n");
    UartEndSimulation();
    return 0;
}
