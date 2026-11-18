/*
 * openframe.ld -- linker script for programs on nanosoc in the OpenFrame wrapper
 * with ChipFoundry's pre-hardened memories: 4 kbyte of instruction memory and
 * 1 kbyte of data memory. (The SoC Labs script, cmsdk_cm0.ld, assumes 64 kbyte
 * and 15 kbyte; a program linked with it runs here only because addresses wrap.)
 *
 * Use: add LINKER_SCRIPT=<this file> to the test program's make variables
 * (sim/run_gl_sim.sh does so with SMALL_SW=1). A program that does not fit is
 * a link error.
 *
 * Works with the startup code and C library the test programs are built with
 * (startup_CMSDK_CM0.s, newlib-nano): the symbols they use are defined here.
 * The startup file's own .stack and .heap sections only reserve space in the
 * SoC Labs script; here they are dropped, and the stack simply grows down from
 * the top of the data memory. STACK is what is kept free for it: the link fails
 * if data and bss leave less. There is no heap to speak of (what malloc gets is
 * the gap between bss and the stack's reserve).
 *
 * For another memory set change the two LENGTHs (the DFFRAM-compiler build has
 * 4 kbyte and 2 kbyte) and the boot ROM's OF_IMEM_BYTES (bootrom/Makefile).
 */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 0x1000   /* instruction memory, at 0 once REMAP is cleared */
    RAM   (rwx) : ORIGIN = 0x30000000, LENGTH = 0x400    /* data memory */
}
STACK = 0x180;

/* the C library's system-call stubs (_exit, _sbrk, ...) come from libnosys */
GROUP(libgcc.a libc.a libm.a libnosys.a)

ENTRY(Reset_Handler)

SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        KEEP(*(.init))
        KEEP(*(.fini))
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        *(.rodata*)
        KEEP(*(.eh_frame*))
    } > FLASH

    .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } > FLASH
    __exidx_start = .;
    .ARM.exidx : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) } > FLASH
    __exidx_end = .;

    . = ALIGN(4);
    __etext = .;

    .data : AT (__etext)
    {
        __data_start__ = .;
        *(vtable)
        *(.data*)
        . = ALIGN(4);
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(4);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(4);
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);
        KEEP(*(.jcr*))
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM

    .bss :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    __end__ = .;
    PROVIDE(end = .);

    /* the startup file's space reservations: not wanted (see above) */
    /DISCARD/ : { *(.stack*) *(.heap*) }

    __StackTop   = ORIGIN(RAM) + LENGTH(RAM);
    __StackLimit = __StackTop - STACK;
    __HeapBase   = __end__;
    __HeapLimit  = __StackLimit;
    PROVIDE(__stack = __StackTop);

    ASSERT(__etext + (__data_end__ - __data_start__) <= ORIGIN(FLASH) + LENGTH(FLASH),
           "the program (code, constants and initialised data) does not fit the instruction memory")
    ASSERT(__StackLimit >= __end__, "data and bss leave too little of the data memory for the stack")
}
