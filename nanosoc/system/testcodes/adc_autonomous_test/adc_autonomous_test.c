/*
 *-----------------------------------------------------------------------------
 * adc_autonomous_test.c  (INSTRUMENTED diagnostic, printf-free / small binary)
 *
 * WHY printf-free: printf with %-format specifiers pulls in newlib vfprintf,
 * which bloats the image to ~42k words and OVERFLOWS the 16384-word program
 * memory (cmsdk_fpga_rom range [0:16383]) -> the image is truncated and the CPU
 * runs garbage (this is why adc_autonomous_test / fifo_drain_test "run forever"
 * with no output, while adc_trigger_test, which only uses plain-string printf
 * folded to puts, fits and works). Here we output via UartPutc only, so the
 * binary stays small and actually runs.
 *
 * Output goes to logs/uart2.log (the terminal shows the FT1248/ADP tube garble,
 * which is expected framing noise, not our text).
 *
 * Phase 1 — is the RTC ticking? PARK the RTC (huge alarm_offset) so it arms once
 *   then sits in WAITING and never re-arms, making the rtc_dr passthrough read
 *   collision-free (a PSLVERR would HardFault the CPU with no handler). Read
 *   rtc_dr twice: advancing => CLK1HZ+nPOR wired (Task D worked); stuck => not.
 * Phase 2 — autonomous sampling: short period, poll ONLY status_reg (never
 *   PSLVERRs), bounded so it ends fast either way and flushes the log.
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
#include "../sensing_print.h"   /* sp_str / sp_hex / sp_dec / sp_nl (printf-free) */

#define PARK_OFFSET    0x0FFFFFFFu
#define ALARM_PERIOD   2u
#define POLL_TIMEOUT   60000u

static void settle(volatile uint32_t n) { while (n--) { __asm volatile("nop"); } }

int main(void)
{
    int failures = 0;
    uint32_t drained = 0;
    uint32_t t0, t1, s, polls;

    UartStdOutInit();
    sp_str("adc_autonomous_test: start\n");

    /* ---- Phase 1: park RTC, then check the counter advances --------------- */
    SENSING_IP_REGS->rtc_alarm_offset = PARK_OFFSET;
    settle(8000u);
    t0 = SENSING_IP_REGS->rtc_dr;
    settle(8000u);
    t1 = SENSING_IP_REGS->rtc_dr;
    sp_str("RTC counter: t0="); sp_hex(t0);
    sp_str(" t1="); sp_hex(t1);
    sp_str((t1 != t0) ? " (advancing - RTC alive)\n" : " (STUCK - CLK1HZ/nPOR not wired!)\n");
    if (t1 == t0) {
        sp_str("FAIL: RTC counter not advancing -> Task D wiring not effective.\n");
        UartEndSimulation();
        return 0;
    }

    /* ---- Phase 2: autonomous sampling (status-only polling) --------------- */
    SENSING_IP_REGS->fifo_clear = 1;
    SENSING_IP_REGS->rtc_alarm_offset = ALARM_PERIOD;
    sp_str("Armed autonomous polling (period=2s). Waiting for sample...\n");

    polls = 0;
    while (polls < POLL_TIMEOUT) {
        s = SENSING_IP_REGS->status_reg;
        if (GET_FIFO_STATUS(s) != STATUS_FIFO_EMPTY) break;
        polls++;
    }
    if (polls >= POLL_TIMEOUT) {
        sp_str("FAIL: RTC ticks but no autonomous sample. last status="); sp_hex(s); sp_nl();
        UartEndSimulation();
        return 0;
    }
    sp_str("First autonomous sample acquired (ok)\n");

    while (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY) {
        volatile uint32_t d = SENSING_IP_REGS->measurement_low;
        (void)d;
        if (++drained > 32u) break;
    }
    sp_str("Drained "); sp_dec(drained); sp_str(" sample(s)\n");

    polls = 0;
    while (polls < POLL_TIMEOUT) {
        if (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY) break;
        polls++;
    }
    if (polls >= POLL_TIMEOUT) {
        sp_str("FAIL: RTC did not re-arm (no second sample)\n");
        failures++;
    } else {
        sp_str("Second autonomous sample acquired - RTC re-armed (ok)\n");
    }

    sp_str(failures == 0 ? "Test Passed!\n" : "Test FAILED\n");
    UartEndSimulation();
    return 0;
}
