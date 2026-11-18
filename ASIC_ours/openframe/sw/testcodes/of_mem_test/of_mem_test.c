/*
 * of_mem_test.c -- write and read traffic for the three data memories of the
 * OpenFrame build, for the gate-level simulation with the memory blocks as
 * their gate netlists (sim/run_gl_sim.sh, MEM_GATES=1).
 *
 * The other test programs barely write memory: a few words of stack. This one
 * puts every kind of write through each block (word, the four byte lanes one at
 * a time, the two halfwords) and reads everything back, on
 *   the expansion memory at 0x80000000 (EXPRAM_L), first 512 bytes,
 *   the expansion memory at 0x90000000 (EXPRAM_H), first 512 bytes,
 *   the data memory, 0x30000100 to 0x300001FF: between this program's own data
 *   (at the bottom) and its stack at the top of the 1 kbyte data memory
 *   (../../openframe.ld puts it there; with the SoC Labs linker script it is
 *   at 0x30003C00, which a 1 kbyte memory also sees at its top, the address
 *   wrapping). Both are checked first; build small (SMALL_SW=1).
 * 512 bytes is the size of the smallest configuration of the expansion
 * memories; the RTL's default memories are larger and behave the same here.
 *
 * It also writes the instruction memory, through its address at 0x20000000. On
 * the chip that memory is RAM and a program gets into it by writes over the
 * host link; the gate-level simulation deposits the program instead, so this is
 * the only traffic through that memory's write path. Two ranges:
 *   0x20000040 to 0x200000BF, the 32 interrupt vectors, which this program does
 *   not use (no interrupt is enabled): saved, tested, restored;
 *   0x20000C00 to 0x20000FFF, the top quarter of a 4 kbyte instruction memory,
 *   above the program (checked first).
 * Where the instruction memory takes no writes (a ROM model), the program
 * prints "imem: not writable here" and goes on without failing, so a run on
 * the netlist must show the two "imem ... ok" lines.
 *
 * Prints through UartPutc only. Ends with "** TEST PASSED **" or
 * "** TEST FAILED **", the lines the testbench scripts look for.
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

static void ps(const char *s) { while (*s) UartPutc((unsigned char)*s++); }

static void ph(uint32_t v)
{
    int i;
    ps("0x");
    for (i = 28; i >= 0; i -= 4) UartPutc((unsigned char)"0123456789ABCDEF"[(v >> i) & 15u]);
}

/* a different word for every address and seed, without a multiply */
static uint32_t pat(uint32_t a, uint32_t seed)
{
    uint32_t v = a ^ seed;
    v ^= v << 13; v ^= v >> 17; v ^= v << 5;
    return v;
}

static int failures;

static void bad(const char *what, uint32_t addr, uint32_t got, uint32_t want)
{
    failures++;
    if (failures <= 8) {
        ps("FAIL "); ps(what); ps(" at "); ph(addr); ps(": read "); ph(got); ps(", expected "); ph(want); ps("\n");
    }
}

static void region(const char *name, uint32_t base, uint32_t words)
{
    volatile uint32_t *w  = (volatile uint32_t *)base;
    volatile uint16_t *h  = (volatile uint16_t *)base;
    volatile uint8_t  *b  = (volatile uint8_t  *)base;
    uint32_t i, x, r;
    int before = failures;

    /* 1: words up, read back up */
    for (i = 0; i < words; i++) w[i] = pat(base + 4u * i, 0x1234ABCDu);
    for (i = 0; i < words; i++) {
        x = pat(base + 4u * i, 0x1234ABCDu); r = w[i];
        if (r != x) bad("word", base + 4u * i, r, x);
    }
    /* 2: the inverse, one byte lane at a time (lanes 3, 1, 0, 2), read back down */
    for (i = 0; i < words; i++) {
        x = ~pat(base + 4u * i, 0x1234ABCDu);
        b[4u * i + 3u] = (uint8_t)(x >> 24);
        b[4u * i + 1u] = (uint8_t)(x >> 8);
        b[4u * i + 0u] = (uint8_t)x;
        b[4u * i + 2u] = (uint8_t)(x >> 16);
    }
    for (i = words; i-- > 0u; ) {
        x = ~pat(base + 4u * i, 0x1234ABCDu); r = w[i];
        if (r != x) bad("bytes", base + 4u * i, r, x);
    }
    /* 3: halfwords (upper, then lower), each read straight back, then as words */
    for (i = 0; i < words; i++) {
        x = pat(base + 4u * i, 0x0F1E2D3Cu);
        h[2u * i + 1u] = (uint16_t)(x >> 16);
        r = h[2u * i + 1u];
        if (r != (x >> 16)) bad("halfword", base + 4u * i + 2u, r, x >> 16);
        h[2u * i] = (uint16_t)x;
    }
    for (i = 0; i < words; i++) {
        x = pat(base + 4u * i, 0x0F1E2D3Cu); r = w[i];
        if (r != x) bad("halves", base + 4u * i, r, x);
    }
    /* 4: a write, then at once a read of the word before it and of the word itself */
    for (i = 1; i < words; i++) {
        x = pat(base + 4u * i, 0x55AA33CCu);
        w[i] = x;
        r = w[i - 1u];
        if (i > 1u && r != pat(base + 4u * (i - 1u), 0x55AA33CCu)) bad("neighbour", base + 4u * (i - 1u), r, pat(base + 4u * (i - 1u), 0x55AA33CCu));
        r = w[i];
        if (r != x) bad("same word", base + 4u * i, r, x);
    }
    ps(name); ps((failures == before) ? ": ok\n" : ": FAILED\n");
}

extern char __end__;        /* end of this program's data, from the linker script */
extern char __etext, __data_start__, __data_end__;

static void imem(void)
{
    volatile uint32_t *alias = (volatile uint32_t *)0x20000040u;   /* the interrupt vectors, as RAM */
    volatile uint32_t *boot  = (volatile uint32_t *)0x00000040u;   /* the same words where the CPU fetches them */
    uint32_t image_end = (uint32_t)&__etext + ((uint32_t)&__data_end__ - (uint32_t)&__data_start__);
    uint32_t save[32];
    uint32_t i, v;

    v = alias[0];
    alias[0] = ~v;
    if (alias[0] == v) { ps("imem: not writable here (a ROM model), skipped\n"); return; }
    alias[0] = v;

    for (i = 0; i < 32u; i++) save[i] = boot[i];
    region("imem low 0x20000040, 32 words", 0x20000040u, 32u);
    for (i = 0; i < 32u; i++) alias[i] = save[i];
    for (i = 0; i < 32u; i++) { v = boot[i]; if (v != save[i]) bad("vector restore", 0x40u + 4u * i, v, save[i]); }

    if (image_end <= 0xC00u)
        region("imem high 0x20000C00, 256 words", 0x20000C00u, 256u);
    else {
        failures++;
        ps("FAIL: the program ends at "); ph(image_end); ps(", inside the instruction-memory range under test\n");
    }
}

int main(void)
{
    volatile uint32_t marker = 0;
    uint32_t sp_in_1k = (uint32_t)&marker & 0x3FFu;     /* where a 1 kbyte memory holds the stack */

    UartStdOutInit();
    ps("of_mem_test: start\n");

    region("expram_l 0x80000000, 128 words", 0x80000000u, 128u);
    region("expram_h 0x90000000, 128 words", 0x90000000u, 128u);
    if ((uint32_t)&__end__ <= 0x30000100u && sp_in_1k >= 0x280u)
        region("dmem 0x30000100, 64 words", 0x30000100u, 64u);
    else {
        failures++;
        ps("FAIL: data ends at "); ph((uint32_t)&__end__); ps(" and the stack is at "); ph((uint32_t)&marker);
        ps(": no room for the data-memory range under test (build with SMALL_SW=1)\n");
    }

    imem();

    if (failures == 0) ps("** TEST PASSED **\n");
    else { ps("failures: "); ph((uint32_t)failures); ps("\n** TEST FAILED **\n"); }
    UartEndSimulation();
    return 0;
}
