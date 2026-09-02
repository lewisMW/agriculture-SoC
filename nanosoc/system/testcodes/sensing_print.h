#ifndef SENSING_PRINT_H
#define SENSING_PRINT_H
/*
 * sensing_print.h - tiny printf-free output helpers for the sensing testcodes.
 *
 * WHY: printf() with %-format specifiers drags in newlib vfprintf, which bloats
 * the image past the 16384-word program memory (cmsdk_fpga_rom [0:16383]) so it
 * is truncated and the CPU runs garbage. (adc_trigger_test only used plain-string
 * printf, folded to puts, so it stayed small and worked; the format-using tests
 * did not.) These helpers emit straight to the UART via UartPutc, so tests keep
 * clean readable output with a small footprint. Output lands in logs/uart2.log.
 *
 * Usage: #include "../sensing_print.h"  then  sp_str("x="); sp_hex(v); sp_nl();
 * All static-inline so unused ones are dropped; safe to include in every test.
 */
#include <stdint.h>
#include "uart_stdout.h"   /* UartPutc */

static inline void sp_str(const char *s) { while (*s) UartPutc((unsigned char)*s++); }
static inline void sp_ch(char c)         { UartPutc((unsigned char)c); }
static inline void sp_nl(void)           { UartPutc('\n'); }

static inline void sp_hex(uint32_t v)
{
    int i;
    sp_str("0x");
    for (i = 28; i >= 0; i -= 4) {
        unsigned d = (v >> i) & 0xF;
        UartPutc((unsigned char)(d < 10 ? ('0' + d) : ('A' + d - 10)));
    }
}

static inline void sp_dec(uint32_t v)
{
    char b[11];
    int i = 0;
    if (v == 0) { UartPutc('0'); return; }
    while (v) { b[i++] = (char)('0' + (v % 10)); v /= 10; }
    while (i--) UartPutc((unsigned char)b[i]);
}

/* Convenience: "<label><hex value>\n" */
static inline void sp_str_hex_nl(const char *label, uint32_t v)
{
    sp_str(label); sp_hex(v); sp_nl();
}

#endif /* SENSING_PRINT_H */
