/*
 *-----------------------------------------------------------------------------
 * The confidential and proprietary information contained in this file may
 * only be used by a person authorised under and to the extent permitted
 * by a subsisting licensing agreement from Arm Limited or its affiliates.
 *
 *            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
 *                ALL RIGHTS RESERVED
 *
 * This entire notice must be reproduced on all copies of this file
 * and copies of this file may only be made by a person if such person is
 * permitted to do so under the terms of a subsisting license agreement
 * from Arm Limited or its affiliates.
 *
 *      SVN Information
 *
 *      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
 *
 *      Revision            : $Revision: 371321 $
 *
 *      Release Information : Cortex-M System Design Kit-r1p1-00rel0
 *-----------------------------------------------------------------------------
 */
/* A simple program to test the bitband wrapper for Cortex-M0 and
  Cortex-M0+ */

#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#endif

#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#endif

#include <stdio.h>

#include "uart_stdout.h"

/* Macros for word, half word and byte */
#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))
#define HW16_REG(ADDRESS)  (*((volatile unsigned short *)(ADDRESS)))
#define HW8_REG(ADDRESS)   (*((volatile unsigned char  *)(ADDRESS)))

#define SRAM_BITBAND_ADDR     0x20000000
#define SRAM_BITBAND_ALIAS    0x22000000
#define PERIPH_BITBAND_ADDR   0x40000000
#define PERIPH_BITBAND_ALIAS  0x42000000

volatile unsigned int  sram_array[20];

/* Tick to make sure variables are placed after test ram area */
#define probing_state sram_array[16]
#define hf_expected   sram_array[17]
#define hf_occurred   sram_array[18]

void ProbeBitBandAddr(void);
int SRamBitBandTest(void);
int PeripheralBitBandTest(void);
int EndianCheck(void);
int error_test(void);

int main (void)
{
  int result=0;

  probing_state = 0;
  hf_expected   = 0;
  hf_occurred   = 0;

  // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit - Bitband Test - revision $Revision: 371321 $\n");

  /* Probe Bit band alias address to see if bitband has been implemented */
  ProbeBitBandAddr();

  /* Test bitband access to SRAM */
  if (SRamBitBandTest()) result |= 1;

  /* Test bitband access to peripheral */
  if (PeripheralBitBandTest()) result |= 1;

  if (error_test()) result |= 1;

  if (result==0) {
    printf ("\n** TEST PASSED **\n");
    } else {
    printf ("\n** TEST FAILED **, Error code = (0x%x)\n", result);
    }
  UartEndSimulation();
  return 0;
}

void ProbeBitBandAddr(void)
{
  probing_state = 1;
  /* Access first address in bit-band alias. If bus fault occurred
  it means bitband feature is not available. */
  HW32_REG(SRAM_BITBAND_ALIAS) = 0;
  puts ("- no error in SRAM bitband alias access\n");
  puts ("  continue test...\n");
  probing_state = 0;
  sram_array[0] = 0; /* Dummy access to make sure sram_array won't get optimized away */
  return;
}


int SRamBitBandTest(void)
{
const unsigned int testdata[4] = { 0x55AA33CC, 0xBADF00D, 0xC0FFEE, 0x12345678};
      unsigned int readdata;    /* read back value - packed */
      unsigned int i,j;         /* loop counters */
      unsigned int t1, t2;      /* temp value */
      unsigned int err_code;    /* error code */
      unsigned int verbose_level = 0;

  err_code = 0;

  /* Store data in SRAM */
  HW32_REG(SRAM_BITBAND_ADDR    ) = testdata[0];
  HW32_REG(SRAM_BITBAND_ADDR+0x4) = testdata[1];
  HW32_REG(SRAM_BITBAND_ADDR+0x8) = testdata[2];
  HW32_REG(SRAM_BITBAND_ADDR+0xC) = testdata[3];

  puts ("SRAM bitband");
  puts (" - Read bitband alias,");
  for (i=0;i<4;i++) {
    readdata=0;

    /* Read each bit in the word via bit band alias and reconstruct the 32-bit value */
    j=32;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW32_REG(SRAM_BITBAND_ALIAS + 4*j + 0x80*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<1;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=testdata[i]){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",testdata[i],readdata );
      err_code |= 1<<2;
      }
    }    /* end for */

  puts (" - toggle each bit by write to bit band alias");
  for (i=0;i<4;i++) {
    readdata=0;

    /* Toggle each bit in the words via bit band alias and read the 32-bit value afterwards*/
    j=32;
    while(j>0) {
      j--;
      t1 = HW32_REG(SRAM_BITBAND_ALIAS + 4*j + 0x80*i);
      /* Toggle bit and check bit band read data should be 0 or 1 */
      if      (t1==1) HW32_REG(SRAM_BITBAND_ALIAS + 4*j + 0x80*i) = 0;
      else if (t1==0) HW32_REG(SRAM_BITBAND_ALIAS + 4*j + 0x80*i) = 1;
      else  {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<3;
        }
      }  /* end while */
    /* read whole word */
    readdata = HW32_REG(SRAM_BITBAND_ADDR + 4*i);
    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=(~testdata[i])){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(~testdata[i]),readdata );
      err_code |= 1<<4;
      }
    }    /* end for */


  puts (" - Read bitband alias by halfword size,");
  for (i=0;i<8;i++) {
    readdata=0;

    /* Read each bit in the word via bit band alias and reconstruct the 32-bit value */
    j=16;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW16_REG(SRAM_BITBAND_ALIAS + 4*j + 0x40*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<5;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);

    if (readdata!=(HW16_REG(SRAM_BITBAND_ADDR+2*i))){ /* Note : data has been inverted */
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(~testdata[i]),readdata );
      err_code |= 1<<6;
      }
    }    /* end for */


  puts (" - toggle each bit by write to bit band alias, halfword size");
  for (i=0;i<8;i++) {
    readdata=0;

    /* Toggle each bit in the words via bit band alias and read the 32-bit value afterwards*/
    t2 = HW16_REG(SRAM_BITBAND_ADDR+2*i); /* Current value */
    j=16;
    while(j>0) {
      j--;
      t1 = HW16_REG(SRAM_BITBAND_ALIAS + 4*j + 0x40*i);
      /* Toggle bit and check bit band read data should be 0 or 1 */
      if      (t1==1) HW16_REG(SRAM_BITBAND_ALIAS + 4*j + 0x40*i) = 0;
      else if (t1==0) HW16_REG(SRAM_BITBAND_ALIAS + 4*j + 0x40*i) = 1;
      else  {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<7;
        }
      }  /* end while */

    /* read halfword */
    readdata = HW16_REG(SRAM_BITBAND_ADDR + 2*i);
    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);

    if (readdata!=((~t2) & 0xFFFF)){ /* Check data has been inverted */
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",((~t2) & 0xFFFF),readdata );
      err_code |= 1<<8;
      }
    }    /* end for */


  puts (" - Read bitband alias by byte size,");
  for (i=0;i<16;i++) {
    readdata=0;

    /* Read each bit in the word via bit band alias and reconstruct the 32-bit value */
    j=8;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW8_REG(SRAM_BITBAND_ALIAS + 4*j + 0x20*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<5;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);

    if (readdata!=(HW8_REG(SRAM_BITBAND_ADDR + i))){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(HW8_REG(SRAM_BITBAND_ADDR + i)),readdata );
      err_code |= 1<<6;
      }
    }    /* end for */


  puts (" - toggle each bit by write to bit band alias, byte size");
  for (i=0;i<16;i++) {
    readdata=0;

    /* Toggle each bit in the words via bit band alias and read the 32-bit value afterwards*/
    t2 = HW8_REG(SRAM_BITBAND_ADDR+i); /* Current value */
    j=8;
    while(j>0) {
      j--;
      t1 = HW8_REG(SRAM_BITBAND_ALIAS + 4*j + 0x20*i);
      /* Toggle bit and check bit band read data should be 0 or 1 */
      if      (t1==1) HW8_REG(SRAM_BITBAND_ALIAS + 4*j + 0x20*i) = 0;
      else if (t1==0) HW8_REG(SRAM_BITBAND_ALIAS + 4*j + 0x20*i) = 1;
      else  {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<7;
        }
      }  /* end while */
    /* read whole word */
    readdata = HW8_REG(SRAM_BITBAND_ADDR + i);
    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=((~t2) & 0xFF)){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",((~t2) & 0xFF),readdata );
      err_code |= 1<<8;
      }
    }    /* end for */


  puts ("  Test done\n");
  return err_code;
}

int PeripheralBitBandTest(void)
{

const unsigned int testdata[2] = { 0x31241456, 0x92745722};
      unsigned int readdata;    /* read back value - packed */
      unsigned int i,j;         /* loop counters */
      unsigned int t1;          /* temp value */
      unsigned int err_code;    /* error code */
      unsigned int verbose_level = 0;

  /* Note :
  Timer 0 is located in 0x40000000, with ctrl, value, reload and ID registers
  CTRL       : 0x40000000               (not used here)
  VALUE      : 0x40000004               (use for bit toggle later)
  RELOAD     : 0x40000008               (use for bit toggle later)
  ...
  PID 4 to 7 : 0x40000FE0 to 0x40000FEC (not used here).
  PID 0 to 3 : 0x40000FE0 to 0x40000FEC (not used here).
  CID 0 to 3 : 0x40000FF0 to 0x40000FFC (use for read test).
   */
  err_code = 0;
  puts ("Peripheral bitband");
  puts (" - Read bitband alias, word");

  /* Read timer 0 CID registers with bit band alias */
  for (i=0;i<4;i++) {
    readdata=0;

    /* Read each bit in the word via bit band alias and reconstruct the 32-bit value */
    j=32;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW32_REG(PERIPH_BITBAND_ALIAS + (0xFF0*0x20) + 4*j + 0x80*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<1;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=(HW32_REG(PERIPH_BITBAND_ADDR +0xFF0 + 4 * i))){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(HW32_REG(PERIPH_BITBAND_ADDR + 0xFF0 + 4 * i)),readdata );
      err_code |= 1<<2;
      }
    }    /* end for */

  puts (" - Read bitband alias, half word");
  /* Read timer 0 CID registers with bit band alias, half word */
  for (i=0;i<8;i++) {
    readdata=0;

    /* Read each bit in the halfword via bit band alias and reconstruct the 16-bit value */
    j=16;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW16_REG(PERIPH_BITBAND_ALIAS + (0xFF0*0x20) + 4*j + 0x40*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<3;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=(HW16_REG(PERIPH_BITBAND_ADDR + 0xFF0 + 2 * i))){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(HW16_REG(PERIPH_BITBAND_ADDR + 0xFF0 + 2 * i)),readdata );
      err_code |= 1<<4;
      }
    }    /* end for */

  puts (" - Read bitband alias, byte");
  /* Read timer 0 CID registers with bit band alias, half word */
  for (i=0;i<16;i++) {
    readdata=0;

    /* Read each bit in the word via bit band alias and reconstruct the 8-bit value */
    j=8;
    while(j>0) {
      j--;
      readdata = readdata << 1; /* Shift */
      t1 = HW8_REG(PERIPH_BITBAND_ALIAS + (0xFF0*0x20) + 4*j + 0x20*i);
      /* Check bit band read data should be 0 or 1 */
      if ((t1|0x1)!=1) {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<5;
        }
      /* merge 32-bit word with previous read data */
      if (t1!=0) readdata += 1; /* Set LSB */
      }  /* end while */

    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=(HW8_REG(PERIPH_BITBAND_ADDR+0xFF0 + i))){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(HW8_REG(PERIPH_BITBAND_ADDR+0xFF0 + i)),readdata );
      err_code |= 1<<6;
      }
    }    /* end for */

  /* CMSDK_TIMER0->VALUE (0x40000004) and CMSDK_TIMER0->RELOAD (0x40000008)
  registers are 32-bit read/write registers which we can use them
  for bit-band tests */

  CMSDK_TIMER0->VALUE  = testdata[0];
  CMSDK_TIMER0->RELOAD = testdata[1];

  puts (" - toggle each bit by write to bit band alias, word size");
  for (i=0;i<2;i++) {
    readdata=0;

    /* Toggle each bit in the words via bit band alias and read the 32-bit value afterwards*/
    j=32;
    while(j>0) {
      j--;
      t1 = HW32_REG(PERIPH_BITBAND_ALIAS + (0x004*0x20)+ 4*j + 0x80*i);
      /* Toggle bit and check bit band read data should be 0 or 1 */
      if      (t1==1) HW32_REG(PERIPH_BITBAND_ALIAS + (0x004*0x20) + 4*j + 0x80*i) = 0;
      else if (t1==0) HW32_REG(PERIPH_BITBAND_ALIAS + (0x004*0x20) + 4*j + 0x80*i) = 1;
      else  {
        puts("ERROR: bitband read should only return 0 or 1");
        printf ("Got %x, i=%d, j=%d\n", t1, i, j);
        err_code |= 1<<7;
        }
      }  /* end while */
    /* read whole word */
    readdata = HW32_REG(PERIPH_BITBAND_ADDR + 0x4 + 4*i);
    if (verbose_level!=0) printf ("  readdata %d = %x\n", i, readdata);
    if (readdata!=(~testdata[i])){
      puts("ERROR: Value mismatch");
      printf ("Expect %x, actual = %x\n",(~testdata[i]),readdata );
      err_code |= 1<<8;
      }
    }    /* end for */


  puts ("  Test done\n");
  return err_code;
}

int EndianCheck(void)
{
      unsigned int err_code = 0;    /* error code */
      unsigned int t1;              /* temp value */
const unsigned int testdata[2] = { 0x31241456, 0x92745722};
               int i;               /* loop counter */

  puts ("Checking endian characteristic");
  for (i = 0;i<2; i++){
    HW32_REG(SRAM_BITBAND_ADDR) = testdata[i];
    t1 = HW16_REG(SRAM_BITBAND_ADDR) | (HW16_REG(SRAM_BITBAND_ADDR + 0x2) << 16);
    if (t1 != testdata[i]) {
      err_code = 1;
      printf ("Write 32-bit word %x, read 2x 16-bit halfword %x.\n",testdata[i], t1 );
      }
    }
  for (i = 0;i<2; i++){
    HW32_REG(SRAM_BITBAND_ADDR) = testdata[i];
    t1 = HW8_REG(SRAM_BITBAND_ADDR    )        | (HW8_REG(SRAM_BITBAND_ADDR + 0x1) << 8) |
        (HW8_REG(SRAM_BITBAND_ADDR+0x2) << 16) | (HW8_REG(SRAM_BITBAND_ADDR + 0x3) << 24);
    if (t1 != testdata[i]) {
      err_code = 1;
      printf ("Write 32-bit word %x, read 4x 8-bit byte %x.\n", testdata[i], t1);
      }
    }
  if (err_code != 0) {
    puts ("The memory system does not fully compliant to endianess,");
    puts ("some tests procedures will be skipped.\n");
    }
  return err_code;
}

int error_test(void)
{

  unsigned int err_code;        /* error code */
  unsigned int t1;              /* temp value for bus fault test */
  unsigned int testaddr;        /* temp value */

  err_code = 0;
  puts ("Bus fault test");
  puts (" - read error");
  hf_expected = 1;
  hf_occurred = 0;
  testaddr = SRAM_BITBAND_ALIAS + (0x100000 - 1)*32; // Address to be tested
  printf ("  test address = %x\n", testaddr);
  t1 = HW32_REG(testaddr);

  /* Bus fault should be triggered */
  __ISB(); /* delay */
  __ISB(); /* delay */
  __ISB(); /* delay */

  if (hf_occurred!=1) {
    printf ("Expect 1 fault, actual %d\n", hf_occurred);
    err_code = 1;
    }

  puts (" - write error");
  hf_expected = 1;
  hf_occurred = 0;

  HW32_REG(testaddr)=0;

  /* Bus fault should be triggered */
  __ISB(); /* delay */
  __ISB(); /* delay */
  __ISB(); /* delay */

  if (hf_occurred!=1) {
    printf ("Expect 1 fault, actual %d\n", hf_occurred);
    err_code = 1;
    }

  /* End of test, clear hf_expected */
  hf_expected = 0;

  puts ("  Test done\n");
  return err_code;

}

/* Hard fault handler - would be triggered in probing state if
  bitband feature is not implemented */

void HF_Handler_main(unsigned int * hf_args)
{
  if (probing_state==1) {
    /* Bus fault while probing */
    puts ("Bus fault while probing bitband alias\n");
    puts ("** TEST SKIPPED ** Bitband feature not available\n");
    UartEndSimulation();
    }
  if (hf_expected==1) {
    puts ("Expected Bus fault\n");
    hf_occurred ++;
    /* Increment stacked PC */
    hf_args[6] = hf_args[6] + 2;
    }
  else {
    puts ("Unexpected Bus fault\n");
    UartEndSimulation();
    }
  return;
}

#if defined ( __CC_ARM   )
/* ARM or Keil toolchain */
__asm void HardFault_Handler(void)
{
  MOVS   r0, #4
  MOV    r1, LR
  TST    r0, r1
  BEQ    stacking_used_MSP
  MRS    R0, PSP ; first parameter - stacking was using PSP
  LDR    R1,=__cpp(HF_Handler_main)
  BX     R1
stacking_used_MSP
  MRS    R0, MSP ; first parameter - stacking was using MSP
  LDR    R1,=__cpp(HF_Handler_main)
  BX     R1
}
#else
/* gcc toolchain */
void HardFault_Handler(void) __attribute__((naked));
void HardFault_Handler(void)
{
  __asm("  movs   r0,#4\n"
        "  mov    r1,lr\n"
        "  tst    r0,r1\n"
        "  beq    stacking_used_MSP\n"
        "  mrs    r0,psp\n" /*  first parameter - stacking was using PSP */
        "  ldr    r1,=HF_Handler_main  \n"
        "  bx     r1\n"
        "stacking_used_MSP:\n"
        "  mrs    r0,msp\n" /*  first parameter - stacking was using PSP */
        "  ldr    r1,=HF_Handler_main  \n"
        "  bx     r1\n"
        ".pool\n" );
}
#endif

