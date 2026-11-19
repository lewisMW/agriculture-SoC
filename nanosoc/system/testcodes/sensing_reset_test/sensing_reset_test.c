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
    {
        /* Polling is on from reset (period 5 s), so samples arrive between the
         * reset and this check. On hardware (1 Hz) that is ~0 samples, but in
         * sim CLK1HZ_DIV=50 makes 1 s = 1 us and boot+UART output takes
         * >100 us, so the FIFO has already refilled (sim run 2026-11-18: status
         * 0x12 at the first read). Under nanosoc nPOR = HRESETn, so RTCDR is
         * seconds since THIS reset: bound the FIFO by the samples that could
         * have been taken since, instead of demanding it be empty. RTCDR is
         * read after the drain so a sample landing mid-drain is still covered. */
        int      dropped = (sensing_status() & STATUS_FIFO_DROP_MASK) != 0;
        uint32_t n       = sensing_fifo_drain(0, 32u);
        uint32_t secs    = sc_rtc_now();
        uint32_t max_n   = secs / 5u + 1u;
        sp_str("  RTC "); sp_dec(secs); sp_str(" s since reset, FIFO held ");
        sp_dec(n); sp_str(dropped ? ", drop set" : ", drop clear"); sp_nl();
        if (max_n > 16u)
            sp_str("  note: RTC tick refilled the FIFO before this check; empty/drop are bounds only\n");
        SC_CHECK(n <= max_n,                "FIFO holds only samples taken since reset");
        SC_CHECK(!dropped || max_n > 16u,   "drop flag clear (unless FIFO refilled since reset)");
    }
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
    /* Cold boot (RSTINFO is cleared only by PORESETn): initialise the retained
     * words WITHOUT reading them first. DMEM is not preloaded by nanosoc_tb, so
     * under iverilog an unwritten word reads X; branching on it sends the
     * Cortex-M0 PC to X and the sim hangs silently before the first print
     * (sim run 2026-11-17). Only read MAGIC after a reset we caused. */
    if ((CMSDK_SYSCON->RSTINFO & CMSDK_SYSCON_RSTINFO_SYSRESETREQ_Msk) == 0 || MAGIC != KEY) {
        MAGIC = KEY; PHASE = 0; FAILS = 0;
    }
    phase = PHASE;
    sp_str("sensing_reset_test: phase "); sp_dec(phase);
    sp_str(", RSTINFO "); sp_hex(CMSDK_SYSCON->RSTINFO); sp_nl();
    sc_n_fail = FAILS;

    if (phase == 0) {
        uint32_t polls = 200000u;
        dirty();
        /* Manual conversion, then reset mid-way. Autonomous sampling (on from
         * reset, period 1 s after dirty()) fills the FIFO during boot/UART
         * output; with the FIFO full the FSM goes CHECK_FIFO -> ERR_FULL and
         * never enables the ADC, so an unbounded wait for "running" spun
         * forever (sim run 2026-11-18, 7 h, status stuck at 0x32). Pause
         * polling, let any in-flight conversion finish, empty the FIFO, then
         * trigger - and bound the wait so a miss fails loudly. */
        sensing_quiesce();
        sensing_clear_fifo();
        sensing_trigger_oneshot();
        while (polls && GET_ADC_STATUS(sensing_status()) != STATUS_ADC_RUNNING) { polls--; }
        SC_CHECK(polls != 0, "one-shot conversion started before the reset");
        if (polls == 0) {
            sp_str("  status "); sp_hex(sensing_status()); sp_nl();
        }
        FAILS = sc_n_fail;
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
