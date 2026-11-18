/* of_boot.ld -- the OpenFrame boot ROM: code and constants at 0x10000000 (where
 * the ROM is; it is also seen at 0 until REMAP is cleared), stack at the top of
 * the first kilobyte of the data memory. Initialised data is not supported:
 * nothing copies it. LENGTH of ROM is 4 << BOOTROM_ADDRW bytes. */
MEMORY
{
    ROM (rx) : ORIGIN = 0x10000000, LENGTH = 0x800
    RAM (rw) : ORIGIN = 0x30000000, LENGTH = 0x400
}
ENTRY(Reset_Handler)
SECTIONS
{
    .text :
    {
        KEEP(*(.vectors))
        *(.text*)
        *(.rodata*)
        . = ALIGN(4);
    } > ROM
    .data : { *(.data*) } > RAM AT > ROM
    .bss (NOLOAD) : { *(.bss*) *(COMMON) } > RAM
    __stack_top = ORIGIN(RAM) + LENGTH(RAM);
    ASSERT(SIZEOF(.data) == 0, "the boot ROM has no initialised data")
    /DISCARD/ : { *(.ARM.exidx*) *(.ARM.attributes) *(.comment) }
}
