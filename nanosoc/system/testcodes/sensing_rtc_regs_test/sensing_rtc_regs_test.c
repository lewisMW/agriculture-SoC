/*
 * sensing_rtc_regs_test.c - FW-2
 *
 * All 8 PL031 registers through the passthrough (raw accesses: collisions with
 * an arm cycle stall, never fault), RTCLR forwards and backwards, firmware
 * tampering with RTCMR / RTCIMSC / RTCICR, alarm_offset 0 and 1, and a pause
 * with the alarm pending (STATUS[5]). After every disturbance a new sample must
 * appear within offset + 2 RTC seconds (offset + 3 for offsets 0 and 1: in this
 * simulation one RTC second is 100 HCLK, about one SAR conversion, so the
 * conversion itself is a visible fraction of a second). Time must be monotonic
 * except right after an RTCLR write.
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

static uint32_t g_period = 2;

static void expect_sample(const char *what)
{
    uint32_t slack = (g_period <= 1) ? 3u : 2u;
    sensing_clear_fifo();
    SC_CHECK(sc_sample_within(g_period + slack), what);
}

static void set_period(uint32_t p)
{
    RTC->rtc_alarm_offset = p;
    g_period = (p == 0) ? 1 : p;
    /* the new offset applies from the next arm: let one sample happen first */
    sensing_clear_fifo();
    (void)sc_sample_within(g_period + 8);
}

int main(void)
{
    uint32_t t0, t1, i, mono;
    UartStdOutInit();
    sp_str("sensing_rtc_regs_test: start\n");

    sensing_init(2, 0);
    sc_wait_secs(3);

    /* ---- every PL031 register through the passthrough ---- */
    t0 = RTC->rtc_dr;
    sc_wait_secs(2);
    t1 = RTC->rtc_dr;
    SC_CHECK(t1 > t0, "RTCDR advances");
    SC_CHECK((RTC->rtc_cr & 1u) == 1u, "RTCCR.start = 1 (set by the controller)");
    SC_CHECK((RTC->rtc_imsc & 1u) == 1u, "RTCIMSC = 1 (set by the controller)");
    SC_CHECK((RTC->rtc_mis & 1u) == ((RTC->rtc_ris & RTC->rtc_imsc) & 1u), "RTCMIS = RTCRIS & RTCIMSC");
    (void)RTC->rtc_icr;                          /* WO: read completes */
    RTC->rtc_cr = 1u;                            /* writing 1 again: no effect */
    RTC->rtc_ris = 1u; RTC->rtc_mis = 1u;        /* RO: writes complete, ignored */
    RTC->rtc_dr = 0u;                            /* RO */
    SC_CHECK(RTC->rtc_dr >= t1, "write to read-only RTCDR ignored");
    expect_sample("sampling continues after touching every register");

    /* ---- RTCLR forwards / backwards ---- */
    RTC->rtc_lr = 100000u;
    SC_CHECK(RTC->rtc_lr == 100000u, "RTCLR reads back the loaded value");
    SC_CHECK(RTC->rtc_dr >= 100000u && RTC->rtc_dr < 100010u, "RTCLR forward load visible in RTCDR");
    expect_sample("sample within offset + 2 s after RTCLR forward (past the armed target)");
    RTC->rtc_lr = 50u;
    SC_CHECK(RTC->rtc_dr < 60u, "RTCLR backward load visible in RTCDR");
    expect_sample("sample within offset + 2 s after RTCLR backward (target far ahead)");

    /* ---- tampering ---- */
    RTC->rtc_mr = RTC->rtc_dr - 5u;
    expect_sample("sample after firmware writes RTCMR in the past");
    RTC->rtc_mr = RTC->rtc_dr + 100000u;
    expect_sample("sample after firmware writes RTCMR far in the future");
    RTC->rtc_imsc = 0u;
    expect_sample("sample with RTCIMSC = 0 (watchdog path)");
    sc_wait_secs(g_period + 2);
    SC_CHECK((RTC->rtc_imsc & 1u) == 1u, "the controller re-enabled RTCIMSC on its next arm");
    for (i = 0; i < 20; i++) RTC->rtc_icr = 1u;   /* clears whatever is pending, repeatedly */
    expect_sample("sample after repeated firmware RTCICR writes");

    /* ---- offset 0 and 1 ---- */
    set_period(0);
    for (i = 0; i < 4; i++) expect_sample("offset 0 (clamped to 1): samples keep coming");
    set_period(1);
    for (i = 0; i < 4; i++) expect_sample("offset 1: samples keep coming");
    set_period(2);

    /* ---- pause with the alarm pending ---- */
    sensing_quiesce();
    sensing_clear_fifo();
    sc_wait_secs(g_period + 2);                   /* the armed alarm fires while paused */
    SC_CHECK((sensing_status() & STATUS_RTC_INTR_MASK) != 0, "STATUS[5] reads 1: alarm pending while paused");
    SC_CHECK(sensing_fifo_empty(), "no autonomous sample while paused");
    sensing_polling_enable();
    SC_CHECK(sc_sample_within(2), "resume services the pending alarm at once");
    sc_wait_secs(1);
    SC_CHECK((sensing_status() & STATUS_RTC_INTR_MASK) == 0, "STATUS[5] clears once serviced");

    /* ---- monotonic time without RTCLR ---- */
    mono = 1; t0 = RTC->rtc_dr;
    for (i = 0; i < 300; i++) { t1 = RTC->rtc_dr; if (t1 < t0) mono = 0; t0 = t1; }
    SC_CHECK(mono, "RTCDR never goes backwards without an RTCLR write");

    RTC->rtc_alarm_offset = 5u;
    sc_finish("sensing_rtc_regs_test");
    return 0;
}
