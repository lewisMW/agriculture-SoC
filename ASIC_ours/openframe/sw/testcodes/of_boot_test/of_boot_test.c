/*
 * of_boot_test.c -- the boot ROM's choice between the flash and the instruction
 * memory (../../bootrom/of_boot.c), for a simulation that starts this program
 * from the flash (sim/run_gl_sim.sh with FLASH=boot).
 *
 * First pass, after power-on: the ROM has copied the program from the flash.
 * The program changes one word of its own image in the instruction memory (the
 * constant "stamp" below) and asks for a system reset.
 * Second pass: the ROM must have started the program without copying it again,
 * because the reset was the system's own (SYSCON RSTINFO): the changed word is
 * still there. A debugger that loads a program and resets relies on this.
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

#define STAMP_FRESH   0x11111111u
#define STAMP_CHANGED 0x22222222u

/* Part of the image: in the flash, and from there in the instruction memory.
 * Not declared volatile: the compiler would then keep it with the writable data,
 * in the data memory. It is read through a pointer to volatile instead. */
static const uint32_t stamp_word __attribute__((used, section(".rodata.of_stamp"))) = STAMP_FRESH;
#define stamp (*(const volatile uint32_t *)&stamp_word)

static void ps(const char *s) { while (*s) UartPutc((unsigned char)*s++); }

static void end(int ok)
{
    ps(ok ? "** TEST PASSED **\n" : "** TEST FAILED **\n");
    UartEndSimulation();
    for (;;) ;
}

int main(void)
{
    /* the same word through the instruction memory's own address, where it can be written */
    volatile uint32_t *alias = (volatile uint32_t *)(0x20000000u + (uint32_t)&stamp_word);
    uint32_t rst = CMSDK_SYSCON->RSTINFO;
    volatile uint32_t i;

    UartStdOutInit();
    ps("of_boot_test: start\n");
    if ((uint32_t)&stamp_word >= 0x1000u) { ps("FAIL: the stamp is not in the instruction memory\n"); end(0); }

    if (stamp == STAMP_FRESH) {
        if (rst != 0u) {
            ps("FAIL: the ROM copied the program from the flash again after a system reset\n");
            end(0);
        }
        ps("first pass: fresh from the flash; changing the image and asking for a reset\n");
        *alias = STAMP_CHANGED;
        if (stamp != STAMP_CHANGED) { ps("FAIL: the instruction memory did not take the write\n"); end(0); }
        for (i = 0; i < 2000u; i++) ;           /* let the last characters out */
        NVIC_SystemReset();
        for (;;) ;
    }
    if (stamp == STAMP_CHANGED) {
        if (rst & 1u) {
            ps("second pass: the image is as the first pass left it, and RSTINFO shows the system reset\n");
            end(1);
        }
        ps("FAIL: the image was kept, but RSTINFO does not show a system reset\n");
        end(0);
    }
    ps("FAIL: the stamp is neither value\n");
    end(0);
    return 0;
}
