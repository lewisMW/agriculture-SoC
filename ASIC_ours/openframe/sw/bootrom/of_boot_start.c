/*
 * of_boot_start.c -- vector table and reset entry of the OpenFrame boot ROM.
 * The ROM uses no interrupts; an exception stops in a loop. The stack is the
 * top of the data memory's first kilobyte (of_boot.ld), which every memory
 * configuration has; the word at the bottom of that memory is left alone
 * (of_boot.c reads it).
 */
#include <stdint.h>

extern int main(void);
extern uint32_t __stack_top;

void Reset_Handler(void)   { main(); for (;;) ; }
void Default_Handler(void) { for (;;) ; }

__attribute__((section(".vectors"), used))
void (* const of_boot_vectors[16])(void) = {
    (void (*)(void))&__stack_top,   /* initial stack pointer */
    Reset_Handler,
    Default_Handler,                /* NMI */
    Default_Handler,                /* HardFault */
    0, 0, 0, 0, 0, 0, 0,
    Default_Handler,                /* SVCall */
    0, 0,
    Default_Handler,                /* PendSV */
    Default_Handler                 /* SysTick */
};
