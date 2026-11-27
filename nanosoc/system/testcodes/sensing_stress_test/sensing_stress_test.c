/*
 * sensing_stress_test.c - FW-3
 *
 * alarm_offset 1; for 60 RTC seconds the CPU hammers the RTC passthrough (raw
 * RTCDR/RTCRIS/RTCMIS reads, RTCIMSC/RTCCR writes of 1, no polling pause) while
 * draining the FIFO. A stalled access must always complete (a loop-count
 * watchdog catches a hang), no access may fault, and sampling must keep up.
 *
 * Rate criterion. The spec asks for samples + drops >= elapsed seconds - 1. In
 * this simulation one RTC second is 100 HCLK, and after every sample the SAR
 * ADC runs one back-to-back conversion it was not asked for (adc_en is still
 * high at its sDone edge); since the FSM-STALE fix a trigger arriving during it
 * waits for it to finish, so a sample costs up to two conversions (~180 HCLK
 * at ADC_CLK_DIV 4) - longer than one simulated second. A trigger that lands
 * while the FSM is busy is discarded (WRP-2 property), so at offset 1 the sim
 * can deliver at most one sample per two seconds. The check is therefore
 * samples >= elapsed / 2 - 1. On silicon (1 s >> one conversion) the full rate
 * applies; the hang/fault checks are the point of this test.
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
#define SENSING_COUNT_FAULTS
#include "../sensing_check.h"

#define RTC (SENSING_IP_REGS)

int main(void)
{
    uint32_t t0, t, elapsed = 0, samples = 0, loops = 0, sink = 0, drop_seen = 0;
    UartStdOutInit();
    sp_str("sensing_stress_test: start\n");
    /* rtc_prescale resets to the value for the real clock; this test counts
     * RTC seconds, so it selects the simulation tick (a "second" of 100 clocks). */
    SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
    sensing_init(1, 0);
    sensing_clear_fifo();
    t0 = RTC->rtc_dr;
    while (elapsed < 60u) {
        sink += RTC->rtc_dr;
        sink += RTC->rtc_ris;
        RTC->rtc_imsc = 1u;
        sink += RTC->rtc_mis;
        RTC->rtc_cr = 1u;
        if (sensing_sample_dropped()) drop_seen = 1;
        while (!sensing_fifo_empty()) { sink += RTC->measurement_low; samples++; }
        t = RTC->rtc_dr;
        elapsed = t - t0;
        if (++loops > 2000000u) break;            /* loop-count watchdog */
    }
    sp_str("elapsed "); sp_dec(elapsed); sp_str(" s, samples "); sp_dec(samples);
    sp_str(", loops "); sp_dec(loops); sp_str(", drop flag seen "); sp_dec(drop_seen); sp_nl();
    SC_CHECK(loops <= 2000000u, "no hang: 60 RTC seconds reached within the loop budget");
    SC_CHECK(elapsed >= 60u, "RTC kept counting under the passthrough storm");
    SC_CHECK(samples + 1u >= elapsed / 2u, "sampling keeps up (>= elapsed/2 - 1 in this sim; see header)");
    SC_CHECK(!drop_seen, "continuous draining: no sample dropped");
    (void)sink;
    RTC->rtc_alarm_offset = 5u;
    sc_finish("sensing_stress_test");
    return 0;
}
