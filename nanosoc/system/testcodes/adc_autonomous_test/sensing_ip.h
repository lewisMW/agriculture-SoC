#ifndef SENSING_IP_H
#define SENSING_IP_H

#include <stdint.h>

#define SENSING_IP_REGS_BASE        (0x60000000)

typedef struct 
{
    volatile uint32_t RESERVED0;         // 0x000 - (unused or reserved)
    volatile uint32_t status_reg;        // 0x004
    volatile uint32_t measurement_high;  // 0x008
    volatile uint32_t measurement_low;   // 0x00C
    volatile uint32_t RESERVED1[60];     // 0x010 padding to 0x100
    volatile uint32_t pll_control;       // 0x100
    volatile uint32_t amux;              // 0x104
    volatile uint32_t adc_trigger;       // 0x108 - bit0=1 -> manual one-shot sample
    volatile uint32_t adc_cal;           // 0x10C - bit0=1 -> next conversion calibrates
    volatile uint32_t RESERVED2[60];     // 0x110 padding to 0x200
    volatile uint32_t rtc_dr;            // 0x200 - RTC Data Register
    volatile uint32_t rtc_mr;            // 0x204 - RTC Match Register
    volatile uint32_t rtc_lr;            // 0x208 - RTC Load Register
    volatile uint32_t rtc_cr;            // 0x20C - RTC Control Register
    volatile uint32_t rtc_imsc;          // 0x210 - RTC Interrupt Mask Set or Clear
    volatile uint32_t rtc_ris;           // 0x214 - RTC Raw Interrupt Status
    volatile uint32_t rtc_mis;           // 0x218 - RTC Masked Interrupt Status
    volatile uint32_t rtc_icr;           // 0x21C - RTC Interrupt Clear Register
    volatile uint32_t fifo_clear;        // 0x220 - Clear FIFO Register (any write flushes)
    volatile uint32_t rtc_alarm_offset;  // 0x224 - polling period in RTC seconds
} sensing_ip_regs_t;
#define SENSING_IP_REGS ((volatile sensing_ip_regs_t *) SENSING_IP_REGS_BASE)


// STATUS_REG
#define STATUS_FIFO_MASK      0x03
#define STATUS_ADC_MASK       0x0C
#define STATUS_ADC_SHIFT      2
#define STATUS_FIFO_DROP_MASK 0x10   // [4] last sample dropped (FIFO was full)
#define STATUS_RTC_INTR_MASK  0x20   // [5] RTC interrupt pending

#define STATUS_FIFO_EMPTY     0x00
#define STATUS_FIFO_READY     0x01
#define STATUS_FIFO_FULL      0x02

#define STATUS_ADC_IDLE       0x00
#define STATUS_ADC_RUNNING    0x01

// ADC_CAL
#define ADC_CAL_ENABLE        0x01

// ADC_TRIGGER
#define ADC_TRIGGER_ONESHOT   0x01

#define GET_FIFO_STATUS(status_reg)    ((status_reg) & STATUS_FIFO_MASK)
#define GET_ADC_STATUS(status_reg)     (((status_reg) & STATUS_ADC_MASK) >> STATUS_ADC_SHIFT)

#endif // SENSING_IP_H