/*
 * of_boot.c -- boot ROM of nanosoc in the OpenFrame wrapper.
 *
 * At reset the ROM is at address 0 (REMAP). This program
 *   1. sets up the two character channels as the SoC Labs boot loader does (the
 *      stream port USRT2, which is the host link; UART2's transmitter on P1[5]
 *      when the mode strap P1[7] is high), UART2 at 38,400 baud for OF_CLK_HZ.
 *      Messages go to the stream port and, when UART2 is on, to UART2 too (the
 *      board's USB serial port). The stream port stops taking characters when
 *      no host is connected: a character that has waited STREAM_WAIT polls is
 *      dropped, and the stream port is then left alone, so that the chip
 *      starts on its own;
 *   2. copies a program from the board's SPI flash into the instruction memory,
 *      if the flash holds one (the header below) and nothing says not to;
 *   3. clears REMAP, which puts the instruction memory at address 0, and starts
 *      the program there, as the SoC Labs boot loader does.
 *
 * The flash is the development board's (GPIO 39-42, 36, 37), read through port
 * pins: P1[8] CSB, P1[9] CLK, P1[10] IO0 (to the flash), P1[11] IO1 (from it),
 * P1[13]/P1[14] IO2/IO3 (held high: write-protect and hold are active low).
 * Plain SPI, mode 0, commands 0xAB (wake from power-down) and 0x03 (read).
 *
 * Flash contents, from address 0, words little-endian (mkflashimg.py):
 *   +0   0x434F534E  ("NSOC")
 *   +4   n           image length in bytes: a multiple of 4, 8 .. OF_IMEM_BYTES
 *   +8   sum         the 32-bit sum of the image's words
 *   +12  ~n          the length again, inverted
 *   +16  the image: what goes to 0x20000000 (vector table first)
 *
 * The copy is skipped
 *   - after a reset the system itself asked for (SYSCON RSTINFO not 0: a
 *     debugger's or the program's SYSRESETREQ, the watchdog, lockup): the
 *     instruction memory still holds its program, which a debugger may just
 *     have loaded;
 *   - when the first word of the data memory, 0x30000000, is OF_BOOT_SKIP:
 *     a host that uploads a program over the host link resets the system with
 *     ADP's reset bit, which RSTINFO does not record. It writes that word as
 *     well, before it lets the reset go, so that its program is the one that
 *     starts. Memory powers up with arbitrary contents, which match this
 *     word once in four thousand million times.
 * A header that is not there (a blank flash reads all ones) leaves things as
 * they are: the ROM starts whatever the instruction memory holds, as before.
 * A header that is there with a wrong sum stops here, with a message: the
 * instruction memory has then been overwritten with something incomplete.
 *
 * No C library, no initialised data: see of_boot.ld and of_boot_start.c.
 */
#include <stdint.h>
#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#endif
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#endif

#ifndef OF_CLK_HZ
#define OF_CLK_HZ 10000000u         /* the development board's oscillator */
#endif
#ifndef OF_IMEM_BYTES
#define OF_IMEM_BYTES 4096u         /* size of the instruction memory */
#endif
#define OF_BOOT_MAGIC 0x434F534Eu
#define OF_BOOT_SKIP  0x50494B53u   /* "SKIP" */
#define IMEM_BASE     0x20000000u
#define DMEM_BASE     0x30000000u

/* ---------------------------------------------------------------- messages */
#define CH_STREAM   1u          /* the stream port takes characters */
#define CH_UART2    2u          /* UART2 is on */
#define STREAM_WAIT 20000u      /* polls of a full stream port before giving it up */

/* returns the channels in use (no variables outside the stack: nothing has
 * initialised memory, and the data memory's first word is not this program's) */
static uint32_t stdio_init(void)
{
    uint32_t ch = CH_STREAM;

    if (CMSDK_GPIO1->DATA & 0x80u) {            /* strap high: FT1248 + UART2 */
        CMSDK_UART2->CTRL    = 0;
        CMSDK_UART2->BAUDDIV = OF_CLK_HZ / 38400u;
        CMSDK_UART2->CTRL    = CMSDK_UART_CTRL_TXEN_Msk;
        CMSDK_GPIO1->ALTFUNCSET = (1u << 5);    /* P1[5] is UART2's TXD */
        if ((CMSDK_UART2->STATE & 1u) == 0) CMSDK_UART2->DATA = '~';
        ch |= CH_UART2;
    } else {
        CMSDK_UART1->CTRL = 0;                  /* HOSTIO4 */
    }
    CMSDK_USRT2->CTRL    = 0;
    CMSDK_USRT2->CTRL    = CMSDK_UART_CTRL_TXEN_Msk | CMSDK_UART_CTRL_RXEN_Msk;
    CMSDK_USRT2->BAUDDIV = 0xF0;
    if ((CMSDK_USRT2->STATE & 1u) == 0) CMSDK_USRT2->DATA = '#';
    return ch;
}

/* one string to the channels in use; returns them, without the stream port if it stalled */
static uint32_t say(uint32_t ch, const char *s)
{
    uint32_t c, n;

    while ((c = (unsigned char)*s++) != 0) {
        if (ch & CH_UART2) {
            while (CMSDK_UART2->STATE & 1u) ;   /* a UART always empties */
            CMSDK_UART2->DATA = c;
        }
        if (ch & CH_STREAM) {
            for (n = 0; (CMSDK_USRT2->STATE & 1u) && n < STREAM_WAIT; n++) ;
            if (n < STREAM_WAIT) CMSDK_USRT2->DATA = c;
            else ch &= ~CH_STREAM;              /* no host is taking them */
        }
    }
    return ch;
}

/* ------------------------------------------------------------------- flash */
#define FL_CSB  (1u << 8)
#define FL_CLK  (1u << 9)
#define FL_DI   (1u << 10)      /* IO0, to the flash */
#define FL_DO   (1u << 11)      /* IO1, from the flash */
#define FL_IO2  (1u << 13)
#define FL_IO3  (1u << 14)
#define FL_OUTS (FL_CSB | FL_CLK | FL_DI | FL_IO2 | FL_IO3)
/* write the port-1 output bits that m selects (bits 15:8), and no others */
#define P1_SET(m, v) (CMSDK_GPIO1->UB_MASKED[(m) >> 8] = (v))

/* Shift n bits out (most significant first) and n bits in. Each bit: clock low
 * with the data bit (the flash puts its next bit out on this edge), clock high
 * (the flash takes ours), then read the flash's bit, which by then has been
 * stable for long enough to have come through the port's input synchroniser. */
static uint32_t fl_shift(uint32_t out, uint32_t n)
{
    uint32_t in = 0;
    while (n--) {
        P1_SET(FL_CLK | FL_DI, ((out >> n) & 1u) ? FL_DI : 0u);
        P1_SET(FL_CLK, FL_CLK);
        __asm volatile ("nop");
        in = (in << 1) | ((CMSDK_GPIO1->DATA >> 11) & 1u);
    }
    return in;
}

static uint32_t fl_word(void) { return __builtin_bswap32(fl_shift(0, 32)); }

static void fl_deselect(void) { P1_SET(FL_CSB | FL_CLK, FL_CSB); }
static void fl_select(void)   { P1_SET(FL_CSB | FL_CLK, 0u); }

/* 1: a program was copied; 0: no image in the flash; -1: image with a wrong sum */
static int flash_load(void)
{
    volatile uint32_t *dst = (volatile uint32_t *)IMEM_BASE;
    uint32_t n, sum, w, acc = 0, i;
    int r = 0;

    P1_SET(FL_OUTS, FL_CSB | FL_IO2 | FL_IO3);  /* levels first, then drive */
    CMSDK_GPIO1->OUTENABLESET = FL_OUTS;

    fl_select(); (void)fl_shift(0xABu, 8); fl_deselect();   /* wake the flash */
    for (i = 0; i < 64u; i++) __asm volatile ("nop");       /* its wake-up time */

    fl_select();
    (void)fl_shift(0x03000000u, 32);                        /* read from address 0 */
    w   = fl_word();
    n   = fl_word();
    sum = fl_word();
    if (w == OF_BOOT_MAGIC && fl_word() == ~n && n >= 8u && n <= OF_IMEM_BYTES && (n & 3u) == 0) {
        for (i = 0; i < n / 4u; i++) { w = fl_word(); dst[i] = w; acc += w; }
        r = (acc == sum) ? 1 : -1;
    }
    fl_deselect();
    CMSDK_GPIO1->OUTENABLECLR = FL_OUTS;                        /* the pins are inputs again */
    return r;
}

/* ------------------------------------------------------------------- start */
/* the program's stack pointer and entry point are its first two words */
static void __attribute__((naked, noreturn)) start_program(void)
{
    __asm volatile ("movs r0, #0\n"
                    "ldr  r1, [r0]\n"
                    "mov  sp, r1\n"
                    "ldr  r1, [r0, #4]\n"
                    "bx   r1\n");
}

int main(void)
{
    uint32_t ch;
    int r;

    ch = stdio_init();
    ch = say(ch, "\nnanosoc OpenFrame boot\n");

    if (CMSDK_SYSCON->REMAP == 0) {             /* not running as the boot ROM */
        (void)say(ch, "!REMAP!\n\004");         /* the last character ends a simulation */
        for (;;) ;
    }

    if (CMSDK_SYSCON->RSTINFO != 0)
        ch = say(ch, "flash: skipped, warm reset\n");
    else if (*(volatile uint32_t *)DMEM_BASE == OF_BOOT_SKIP)
        ch = say(ch, "flash: skipped, host\n");
    else {
        r = flash_load();
        if (r == 0) ch = say(ch, "flash: no image\n");
        else if (r > 0) ch = say(ch, "flash: loaded\n");
        else {
            (void)say(ch, "flash: BAD SUM, stopped\n");
            for (;;) ;
        }
    }

    (void)say(ch, "REMAP->IMEM0\n");
    CMSDK_SYSCON->REMAP = 0;
    __asm volatile ("dsb\nisb\n");
    start_program();
}
