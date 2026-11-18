/*
 *-----------------------------------------------------------------------------
 * sensing_irq_test.c  -  the sensing peripheral's interrupt.
 *   irq_enable (0x118)  [0] interrupt while the FIFO holds a sample
 *                       [1] interrupt while the FIFO is full
 * The interrupt is the processor's interrupt 11 (EXP0_Handler). It is level:
 * reading the samples out of the FIFO makes it fall.
 *
 * Checks that the register resets to 0 and reads back, that nothing interrupts
 * while both enables are 0, that with bit 0 set each conversion wakes the
 * processor from WFI exactly once, and that with only bit 1 set the interrupt
 * comes when the FIFO fills and not before.
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

#define CONV_SETTLE 600u    /* wait for one conversion and its FIFO write */
#define FIFO_DEPTH  16u

static int failures;
static volatile uint32_t irq_count;     /* times the handler ran */
static volatile uint32_t irq_status;    /* the status register as the handler found it */
static volatile uint32_t irq_sample;    /* the sample it read */

/* Reads one sample: that pops the FIFO, and the interrupt falls if it was the
 * last one (bit 0) or the FIFO is no longer full (bit 1). */
void EXP0_Handler(void)
{
    irq_status = SENSING_IP_REGS->status_reg;
    irq_sample = SENSING_IP_REGS->measurement_low & 0xFFu;
    irq_count++;
}

static void expect(int ok, const char *what)
{
    sp_str(ok ? "  ok:   " : "  FAIL: "); sp_str(what); sp_nl();
    if (!ok) failures++;
}

/* Sleep until the handler has run once more. The check and the WFI are made with
 * interrupts masked, so an interrupt that arrives between them still wakes the
 * processor. A missing interrupt hangs here; the testbench's timeout reports it. */
static void sleep_until_irq(uint32_t before)
{
    __disable_irq();
    while (irq_count == before) {
        __WFI();
        __enable_irq();
        __disable_irq();
    }
    __enable_irq();
}

int main(void)
{
    uint32_t n, before;

    UartStdOutInit();
    sp_str("sensing_irq_test: start\n");

    expect(SENSING_IP_REGS->irq_enable == 0u, "irq_enable resets to 0");
    SENSING_IP_REGS->irq_enable = 0xFFFFFFFFu;
    expect(SENSING_IP_REGS->irq_enable == 3u, "irq_enable holds two bits");
    SENSING_IP_REGS->irq_enable = 0u;

    /* only this test's triggers feed the FIFO */
    sensing_polling_disable();
    sensing_delay(CONV_SETTLE);
    sensing_clear_fifo();
    NVIC_ClearPendingIRQ((IRQn_Type)SENSING_IRQn);
    NVIC_EnableIRQ((IRQn_Type)SENSING_IRQn);

    /* 1: both enables 0: a sample arrives and nothing interrupts */
    sensing_trigger_oneshot();
    sensing_delay(CONV_SETTLE);
    expect(!sensing_fifo_empty(), "a sample is in the FIFO");
    expect(irq_count == 0u, "no interrupt while irq_enable is 0");

    /* 2: bit 0, with that sample still waiting: the interrupt comes at once */
    SENSING_IP_REGS->irq_enable = SENSING_IRQ_SAMPLE_READY;
    sensing_delay(20u);
    expect(irq_count == 1u, "enabling with a sample waiting interrupts once");
    expect(GET_FIFO_STATUS(irq_status) == STATUS_FIFO_READY, "the handler found the FIFO holding a sample");
    expect(sensing_fifo_empty(), "the handler emptied the FIFO");

    /* 3: three conversions, asleep until each interrupt */
    for (n = 0; n < 3u; n++) {
        before = irq_count;
        sensing_trigger_oneshot();
        sleep_until_irq(before);
    }
    sensing_delay(CONV_SETTLE);
    expect(irq_count == 4u, "one interrupt for each of three conversions");
    expect(sensing_fifo_empty(), "the FIFO is empty afterwards");
    expect(NVIC_GetPendingIRQ((IRQn_Type)SENSING_IRQn) == 0u, "the interrupt is not left pending");
    sp_str("  last sample read in the handler: "); sp_hex(irq_sample); sp_nl();

    /* 4: bit 1 only: the interrupt waits until the FIFO is full */
    SENSING_IP_REGS->irq_enable = SENSING_IRQ_FIFO_FULL;
    before = irq_count;
    for (n = 0; n < FIFO_DEPTH - 1u; n++) { sensing_trigger_oneshot(); sensing_delay(CONV_SETTLE); }
    expect(irq_count == before, "no interrupt with one place left in the FIFO");
    sensing_trigger_oneshot();
    sleep_until_irq(before);
    sensing_delay(20u);
    expect(irq_count == before + 1u, "one interrupt when the FIFO fills");
    expect(GET_FIFO_STATUS(irq_status) == STATUS_FIFO_FULL, "the handler found the FIFO full");
    expect(!sensing_fifo_empty() && !sensing_fifo_full(), "after one read it is neither full nor empty");

    /* leave things as the other tests expect */
    SENSING_IP_REGS->irq_enable = 0u;
    NVIC_DisableIRQ((IRQn_Type)SENSING_IRQn);
    sensing_clear_fifo();
    sensing_polling_enable();

    if (failures == 0) sp_str("Test Passed!\n");
    else               sp_str("Test FAILED\n");
    UartEndSimulation();
    return 0;
}
