/*
 *-----------------------------------------------------------------------------
 * clock_ctrl_test.c  -  the sensing peripheral's three clock registers:
 *   adc_clkdiv    (0x110)  system-clock cycles per half period of the ADC clock
 *   adc_samplediv (0x114)  the same while the ADC samples (0 = as adc_clkdiv)
 *   rtc_prescale  (0x22C)  system-clock cycles per half period of the RTC tick
 *
 * Checks their reset values and that they read back what was written, that a
 * conversion completes at several ADC clock settings and takes longer at the
 * slower ones and with a longer sampling phase, and that halving rtc_prescale
 * doubles the rate at which the RTC counts.
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

static int failures;

static void expect(int ok, const char *what)
{
    sp_str(ok ? "  ok:   " : "  FAIL: "); sp_str(what); sp_nl();
    if (!ok) failures++;
}

/* One manual conversion at the present settings: polls of the status register
 * until the sample is in the FIFO (0 = it never arrived). The FIFO is emptied. */
static uint32_t convert_polls(void)
{
    uint32_t n = 0;
    sensing_trigger_oneshot();
    while (sensing_fifo_empty() && n < 20000u) n++;
    if (n >= 20000u) return 0;
    (void)SENSING_IP_REGS->measurement_low;
    return n + 1u;
}

/* RTC counts over a fixed busy-wait, at the present rtc_prescale */
static uint32_t rtc_counts(uint32_t wait)
{
    uint32_t t0, t1;
    t0 = sensing_read_time();
    sensing_polling_disable();
    sensing_delay(wait);
    t1 = sensing_read_time();
    sensing_polling_disable();
    return t1 - t0;
}

int main(void)
{
    uint32_t p4, p2, p12, ps, c50, c25;

    UartStdOutInit();
    sp_str("clock_ctrl_test: start\n");

    /* reset values, before anything is written */
    expect(SENSING_IP_REGS->adc_clkdiv == 4u, "adc_clkdiv resets to 4");
    expect(SENSING_IP_REGS->adc_samplediv == 0u, "adc_samplediv resets to 0");
    sp_str("  rtc_prescale at reset: "); sp_dec(SENSING_IP_REGS->rtc_prescale); sp_nl();
    expect(SENSING_IP_REGS->rtc_prescale == SENSING_RTC_PRESCALE_RESET, "rtc_prescale resets to the value for the real clock");

    /* the fast tick, then no autonomous samples: only this test's triggers */
    SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
    sensing_polling_disable();
    sensing_delay(600u);                 /* a conversion already under way ends first */
    sensing_clear_fifo();

    /* read back */
    SENSING_IP_REGS->adc_clkdiv = 0x1ABu;
    expect(SENSING_IP_REGS->adc_clkdiv == 0xABu, "adc_clkdiv keeps 8 bits");
    SENSING_IP_REGS->adc_samplediv = 0x7Cu;
    expect(SENSING_IP_REGS->adc_samplediv == 0x7Cu, "adc_samplediv reads back");
    SENSING_IP_REGS->rtc_prescale = 0x89ABCDEFu;
    expect(SENSING_IP_REGS->rtc_prescale == 0x89ABCDEFu, "rtc_prescale keeps 32 bits");
    SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
    SENSING_IP_REGS->adc_samplediv = 0u;

    /* the ADC clock (changed only while the ADC is idle) */
    SENSING_IP_REGS->adc_clkdiv = 4u;   sensing_delay(200u); p4  = convert_polls();
    SENSING_IP_REGS->adc_clkdiv = 2u;   sensing_delay(200u); p2  = convert_polls();
    SENSING_IP_REGS->adc_clkdiv = 12u;  sensing_delay(600u); p12 = convert_polls();
    SENSING_IP_REGS->adc_clkdiv = 4u;   sensing_delay(600u);
    SENSING_IP_REGS->adc_samplediv = 60u;                    ps  = convert_polls();
    SENSING_IP_REGS->adc_samplediv = 0u; sensing_delay(600u);
    sp_str("  polls until the sample: clkdiv 2: "); sp_dec(p2); sp_str(", 4: "); sp_dec(p4);
    sp_str(", 12: "); sp_dec(p12); sp_str(", 4 with samplediv 60: "); sp_dec(ps); sp_nl();
    expect(p2 && p4 && p12 && ps, "a conversion completes at every setting");
    expect(p2 < p4 && p4 < p12, "a slower ADC clock makes the conversion longer");
    expect(ps > p4, "a longer sampling phase makes the conversion longer");
    expect(sensing_fifo_empty(), "no sample left over");

    /* the RTC tick */
    SENSING_IP_REGS->rtc_prescale = 50u;  sensing_delay(1500u);  c50 = rtc_counts(4000u);
    SENSING_IP_REGS->rtc_prescale = 25u;  sensing_delay(1500u);  c25 = rtc_counts(4000u);
    sp_str("  RTC counts in the same wait: prescale 50: "); sp_dec(c50); sp_str(", 25: "); sp_dec(c25); sp_nl();
    expect(c50 >= 20u, "the RTC counts at prescale 50");
    expect(c25 + 2u >= 2u * c50 && c25 <= 2u * c50 + 2u, "half the prescale, twice the rate");

    /* leave things as the other tests expect */
    SENSING_IP_REGS->rtc_prescale = SENSING_RTC_PRESCALE_FAST;
    sensing_polling_enable();

    if (failures == 0) sp_str("Test Passed!\n");
    else               sp_str("Test FAILED\n");
    UartEndSimulation();
    return 0;
}
