/*
 * sensing_reset_test.c - FW-5
 *
 * NVIC_SystemReset() mid-conversion and during a (likely) stalled RTC
 * passthrough access; the phase is tracked through sysctrl RSTINFO and three
 * words of SRAM outside the linker's 15 KB RAM region (cmsdk_cm0.ld uses
 * 0x3000_0000-0x3000_3BFF; the C start-up never touches 0x3000_3FF0).
 * After each reboot: all sensing registers at reset values, FIFO empty, and
 * sampling restarts. If the simulation cannot reboot into the image the test
 * never reaches its second phase: the runner times out, and FW-5 is then an
 * FPGA-only test (report it as such).
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

/* retained across a system reset (SRAM is not cleared by a warm reset) */
#define PHASE    (*(volatile uint32_t *)0x30003FF0u)
#define MAGIC    (*(volatile uint32_t *)0x30003FF4u)
#define FAILS    (*(volatile uint32_t *)0x30003FF8u)
#define KEY      0x5E5E0000u

static void check_reset_state(const char *when)
{
    sp_str("after reset "); sp_str(when); sp_nl();
    SC_CHECK(SENSING_IP_REGS->pll_control == 0,       "PLL_CONTROL back at 0");
    SC_CHECK(SENSING_IP_REGS->amux == 0,              "AMUX back at 0");
    SC_CHECK(SENSING_IP_REGS->adc_cal == 0,           "ADC_CAL back at 0");
    SC_CHECK(SENSING_IP_REGS->rtc_alarm_offset == 5,  "RTC_ALARM_OFFSET back at 5");
    SC_CHECK(SENSING_IP_REGS->rtc_ctrl == 1,          "RTC_CTRL back at 1");
    SC_CHECK(sensing_fifo_empty(),                    "FIFO empty");
    SC_CHECK((sensing_status() & STATUS_FIFO_DROP_MASK) == 0, "drop flag clear");
    sensing_init(1, 0);
    SC_CHECK(sc_sample_within(6), "sampling restarts");
}

static void dirty(void)
{
    SENSING_IP_REGS->pll_control = 0x1234u;
    SENSING_IP_REGS->amux = 3u;
    SENSING_IP_REGS->adc_cal = 1u;
    SENSING_IP_REGS->rtc_alarm_offset = 1u;
}

int main(void)
{
    uint32_t phase;
    UartStdOutInit();
    if (MAGIC != KEY) { MAGIC = KEY; PHASE = 0; FAILS = 0; }
    phase = PHASE;
    sp_str("sensing_reset_test: phase "); sp_dec(phase);
    sp_str(", RSTINFO "); sp_hex(CMSDK_SYSCON->RSTINFO); sp_nl();
    sc_n_fail = FAILS;

    if (phase == 0) {
        dirty();
        SENSING_IP_REGS->rtc_ctrl = 0;            /* manual conversion, then reset mid-way */
        sensing_trigger_oneshot();
        while (GET_ADC_STATUS(sensing_status()) != STATUS_ADC_RUNNING) { }
        PHASE = 1;
        CMSDK_SYSCON->RSTINFO = 0x7u;             /* clear (write 1 to clear) */
        NVIC_SystemReset();
    } else if (phase == 1) {
        SC_CHECK((CMSDK_SYSCON->RSTINFO & CMSDK_SYSCON_RSTINFO_SYSRESETREQ_Msk) != 0, "RSTINFO records SYSRESETREQ");
        check_reset_state("mid-conversion");
        dirty();
        SENSING_IP_REGS->rtc_alarm_offset = 1u;   /* frequent arm cycles to stall into */
        PHASE = 2;
        FAILS = sc_n_fail;
        CMSDK_SYSCON->RSTINFO = 0x7u;
        {
            uint32_t i;
            for (i = 0; i < 37u; i++) (void)SENSING_IP_REGS->rtc_dr;
        }
        NVIC_SystemReset();                       /* right after a burst of passthrough reads */
    } else if (phase == 2) {
        check_reset_state("during RTC passthrough traffic");
        PHASE = 3;
        MAGIC = 0;
        SENSING_IP_REGS->rtc_alarm_offset = 5u;
        sc_finish("sensing_reset_test");
    } else {
        sp_str("unexpected phase\n");
        sc_n_fail++;
        MAGIC = 0;
        sc_finish("sensing_reset_test");
    }
    for (;;) { }
}
