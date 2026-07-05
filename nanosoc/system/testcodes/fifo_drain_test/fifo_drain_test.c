/*
 *-----------------------------------------------------------------------------
 * fifo_drain_test.c
 *
 * End-to-end firmware test of the sensing peripheral's FIFO path, driven by
 * manual one-shot triggers (deterministic — no dependence on the RTC/CLK1HZ
 * rate). Exercises the properties from VERIFICATION.md that the directed RTL
 * wrapper test cannot reach from software:
 *
 *   1. Fill the 16-deep FIFO with 16 manual samples  -> status reads FULL.
 *   2. One more trigger while full is dropped         -> STATUS_FIFO_DROP set,
 *                                                        still FULL (no corruption).
 *   3. Drain via measurement_low reads                -> exactly 16 samples pop,
 *                                                        FIFO ends EMPTY.
 *
 * Prints "Test Passed!" only if every check holds. Matches the harness style of
 * adc_trigger_test.c (UART stdout, UartEndSimulation).
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

#define FIFO_DEPTH   16

/* Busy-wait long enough for one ADC conversion + FIFO write to complete.
 * A conversion is ~15 PCLK cycles; this loop is comfortably longer. */
static void settle(void)
{
    volatile uint32_t i;
    for (i = 0; i < 600; i++) { __asm volatile ("nop"); }
}

int main(void)
{
    int failures = 0;
    uint32_t status;
    uint32_t drained;
    int i;

    UartStdOutInit();
    printf("fifo_drain_test: start\n");

    /* Start clean */
    SENSING_IP_REGS->fifo_clear = 1;
    settle();
    status = SENSING_IP_REGS->status_reg;
    if (GET_FIFO_STATUS(status) != STATUS_FIFO_EMPTY) {
        printf("FAIL: FIFO not empty after clear (status=0x%08x)\n", (unsigned)status);
        failures++;
    }

    /* 1. Fill the FIFO with DEPTH manual samples */
    for (i = 0; i < FIFO_DEPTH; i++) {
        SENSING_IP_REGS->adc_trigger = ADC_TRIGGER_ONESHOT;
        settle();
    }
    status = SENSING_IP_REGS->status_reg;
    if (GET_FIFO_STATUS(status) != STATUS_FIFO_FULL) {
        printf("FAIL: FIFO not FULL after %d samples (status=0x%08x)\n",
               FIFO_DEPTH, (unsigned)status);
        failures++;
    } else {
        printf("FIFO full after %d samples (ok)\n", FIFO_DEPTH);
    }

    /* 2. Overflow attempt: one more trigger must be dropped, flag set */
    SENSING_IP_REGS->adc_trigger = ADC_TRIGGER_ONESHOT;
    settle();
    status = SENSING_IP_REGS->status_reg;
    if ((status & STATUS_FIFO_DROP_MASK) == 0) {
        printf("FAIL: drop flag not set on overflow (status=0x%08x)\n", (unsigned)status);
        failures++;
    } else {
        printf("Overflow correctly dropped, drop flag set (ok)\n");
    }
    if (GET_FIFO_STATUS(status) != STATUS_FIFO_FULL) {
        printf("FAIL: FIFO not FULL after dropped overflow (status=0x%08x)\n", (unsigned)status);
        failures++;
    }

    /* 3. Drain and count. Each measurement_low read pops one entry. */
    drained = 0;
    while (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY) {
        volatile uint32_t sample = SENSING_IP_REGS->measurement_low;
        (void)sample;
        drained++;
        settle();                       /* let status settle after the pop */
        if (drained > FIFO_DEPTH + 4) {  /* safety net against a stuck flag */
            printf("FAIL: drain did not terminate (drained=%u)\n", (unsigned)drained);
            failures++;
            break;
        }
    }
    printf("Drained %u samples\n", (unsigned)drained);
    if (drained != FIFO_DEPTH) {
        printf("FAIL: expected %d samples, got %u\n", FIFO_DEPTH, (unsigned)drained);
        failures++;
    }

    if (failures == 0)
        printf("Test Passed!\n");
    else
        printf("Test FAILED: %d check(s) failed\n", failures);

    UartEndSimulation();
    return 0;
}
