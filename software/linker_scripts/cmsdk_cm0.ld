INCLUDE "lib-nosys.ld"

MEMORY
{
  FLASH (rx) : ORIGIN = 0x0,        LENGTH = 0x8000  /* 32K */
  RAM (rwx)  : ORIGIN = 0x8000,     LENGTH = 0x8000  /* 32K */
}

INCLUDE "sections.ld"
