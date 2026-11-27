/*
 * sensing_sleep_poll_test.c - FW-4
 *
 * The CPU sleeps in WFI and is woken by CMSDK TIMER0 (the sensing peripheral
 * has no interrupt yet, so a timer stands in for the
 * sleep-until-sample flow). alarm_offset 2; the timer wakes the CPU every
 * ~3 RTC seconds for 10 cycles. While asleep the RTC + sampling FSM keep
 * filling the FIFO on their own: the FIFO count must have grown at every wake,
 * and every drained batch must be non-empty. Hits cg_lp.cp_sample_asleep.
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

#define WAKE_HCLK  320u              /* ~3.2 RTC seconds (1 s = 100 HCLK in sim) */

static volatile uint32_t g_wakes = 0;

void TIMER0_Handler(void)
{
    CMSDK_TIMER0->INTCLEAR = 1u;
    g_wakes++;
}

int main(void)
{
    uint32_t cyc, n, empty_batches = 0, total = 0;
    UartStdOutInit();
    sp_str("sensing_sleep_poll_test: start\n");
    /* rtc_prescale resets to the value for the real clock; this test counts
     * RTC seconds, so it selects the simulation tick (a "second" of 100 clocks). */
    SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
    sensing_init(2, 0);
    sensing_clear_fifo();

    CMSDK_TIMER0->CTRL   = 0;
    CMSDK_TIMER0->VALUE  = WAKE_HCLK;
    CMSDK_TIMER0->RELOAD = WAKE_HCLK;
    CMSDK_TIMER0->INTCLEAR = 1u;
    NVIC_ClearPendingIRQ(TIMER0_IRQn);
    NVIC_EnableIRQ(TIMER0_IRQn);
    CMSDK_TIMER0->CTRL = CMSDK_TIMER_CTRL_IRQEN_Msk | CMSDK_TIMER_CTRL_EN_Msk;

    for (cyc = 0; cyc < 10u; cyc++) {
        uint32_t w0 = g_wakes;
        while (g_wakes == w0) __WFI();            /* asleep until the timer fires */
        n = sensing_fifo_drain(0, 16);
        total += n;
        if (n == 0) empty_batches++;
        sp_str("wake "); sp_dec(cyc); sp_str(": "); sp_dec(n); sp_str(" samples\n");
    }
    CMSDK_TIMER0->CTRL = 0;
    NVIC_DisableIRQ(TIMER0_IRQn);

    SC_CHECK(g_wakes >= 10u, "10 timer wake-ups from WFI");
    SC_CHECK(empty_batches == 0u, "every wake found new samples taken while asleep");
    SC_CHECK(total >= 10u, "at least one sample per sleep period");
    SENSING_IP_REGS->rtc_alarm_offset = 5u;
    sc_finish("sensing_sleep_poll_test");
    return 0;
}
