INCLUDE "lib-nosys.ld"

MEMORY
{
  FLASH (rx) : ORIGIN = 0x0,        LENGTH = 0x10000  /* 64K */
  RAM (rwx)  : ORIGIN = 0x20000, LENGTH = 0x10000  /* 64K */
}

INCLUDE "sections.ld"
