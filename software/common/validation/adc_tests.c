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

/*
  A simple test to check the operation of APB slave multiplexer
*/


#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#endif

#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#endif

#ifdef CORTEX_M3
#include "CMSDK_CM3.h"
#endif

#ifdef CORTEX_M4
#include "CMSDK_CM4.h"
#endif

#include <stdio.h>
#include "uart_stdout.h"

#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))
#define HW16_REG(ADDRESS)  (*((volatile unsigned short *)(ADDRESS)))
#define HW8_REG(ADDRESS)   (*((volatile unsigned char  *)(ADDRESS)))

int adc_detect(void);
int adc_check_clk_div(void);
#if defined ( __CC_ARM   )
__asm void          address_test_write(unsigned int addr, unsigned int wdata);
__asm unsigned int  address_test_read(unsigned int addr);
#else
      void          address_test_write(unsigned int addr, unsigned int wdata);
      unsigned int  address_test_read(unsigned int addr);
#endif
void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);
int  ID_Check(const unsigned int id_array[], unsigned int offset);
int                 APB_test_slave_Check(unsigned int offset);

/* Global variables */
volatile int hardfault_occurred;
volatile int hardfault_expected;
volatile int temp_data;
         int hardfault_verbose=0; // 0:Not displaying anything in hardfault handler

#define SL_ADC_BASE          (0x40020000UL)
#define SL_ADC_0_BASE        (SL_ADC_BASE + 0x0000UL)

int main (void)
{

  int err_code = 0;
  int data[64];
  int i;
  // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit");
  puts(" - ADC test - revision $Revision: 371321 $\n");

  if(adc_detect()!=0) {
    return 0; // Quit test if ADC not present
  }
  err_code += adc_check_clk_div();
  address_test_write(SL_ADC_0_BASE + 0x00C, 0x01);
  printf("Enable ADC... \n");
  printf("Read ADC Data: \n");
  for (i =0; i<64; i++){
    while(!address_test_read(SL_ADC_0_BASE+0x004)){;}
    data[i]=address_test_read(SL_ADC_0_BASE);
  }

  for (i =0; i<64; i++){
    printf("0x%02x \n",data[i]);
  }

  if (err_code==0) {
    printf ("\n** TEST PASSED **\n");
  } else {
    printf ("\n** TEST FAILED **, Error code = (0x%x)\n", err_code);
  }
  UartEndSimulation();
  return 0;
}

int adc_check_clk_div(void)
{
  int clk_div_actual;

  puts("Testing Clock Divider read/write access \n");
  clk_div_actual = address_test_read(SL_ADC_0_BASE + 0x008);
  printf("Clock divider after reset: %d\n", clk_div_actual);
  address_test_write(SL_ADC_0_BASE + 0x008, 0x5E);
  printf("Clock divider set to: 0x5E\n");
  clk_div_actual = address_test_read(SL_ADC_0_BASE + 0x008);
  printf("Clock divider set read: 0x%02X\n", clk_div_actual);
  if(clk_div_actual!=0x320)
  {
    return 1;
  }
  else{
    return 0;
  }
}

int adc_detect(void)
{
  int result;
  int volatile rdata;
  unsigned const int adc_id[16]     = {0x53, 0x4C, 0x00, 0x61, 0x64, 0x63, 0x00, 0x08};
  puts("Detect if ADC is present...");
  hardfault_occurred = 0;
  hardfault_expected = 1;
  rdata = address_test_read(SL_ADC_0_BASE+ 0xFE0);
  hardfault_expected = 0;
  result = hardfault_occurred ? 1 : ID_Check(&adc_id[0], SL_ADC_0_BASE);
  hardfault_occurred = 0;
  if (result!=0) {
    puts("** TEST SKIPPED ** ADC is not present.\n");
    UartEndSimulation();
  }
  return(result);
}


int ID_Check(const unsigned int id_array[], unsigned int offset)
{
int i;
unsigned long expected_val, actual_val;
unsigned long compare_mask;
int           mismatch = 0;
unsigned long test_addr;

  /* Check the peripheral ID and component ID */
  for (i=0;i<8;i++) {
    test_addr = offset + 4*i + 0xFC0;
    expected_val = id_array[i];
    actual_val   = HW32_REG(test_addr);

    /* create mask to ignore version numbers */
    if (i==2) { compare_mask = 0xF0;}  // mask out version field
    else      { compare_mask = 0x00;}  // compare whole value

    if ((expected_val & (~compare_mask)) != (actual_val & (~compare_mask))) {
      printf ("Difference found: %x, expected %x, actual %x\n", test_addr, expected_val, actual_val);
      mismatch++;
      }

    } // end_for
return (mismatch);
}

#if defined ( __CC_ARM   )
/* Test function for write - for ARM / Keil */
__asm void address_test_write(unsigned int addr, unsigned int wdata)
{
  STR    R1,[R0]
  DSB    ; Ensure bus fault occurred before leaving this subroutine
  BX     LR
}

#else
/* Test function for write - for gcc */
void address_test_write(unsigned int addr, unsigned int wdata) __attribute__((naked));
void address_test_write(unsigned int addr, unsigned int wdata)
{
  __asm("  str   r1,[r0]\n"
        "  dsb          \n"
        "  bx    lr     \n"
  );
}
#endif

/* Test function for read */
#if defined ( __CC_ARM   )
/* Test function for read - for ARM / Keil */
__asm unsigned int address_test_read(unsigned int addr)
{
  LDR    R1,[R0]
  DSB    ; Ensure bus fault occurred before leaving this subroutine
  MOVS   R0, R1
  BX     LR
}
#else
/* Test function for read - for gcc */
unsigned int  address_test_read(unsigned int addr) __attribute__((naked));
unsigned int  address_test_read(unsigned int addr)
{
  __asm("  ldr   r1,[r0]\n"
        "  dsb          \n"
        "  movs  r0, r1 \n"
        "  bx    lr     \n"
  );
}
#endif


#if defined ( __CC_ARM   )
/* ARM or Keil toolchain */
__asm void HardFault_Handler(void)
{
  MOVS   r0, #4
  MOV    r1, LR
  TST    r0, r1
  BEQ    stacking_used_MSP
  MRS    R0, PSP ; // first parameter - stacking was using PSP
  B      get_LR_and_branch
stacking_used_MSP
  MRS    R0, MSP ; // first parameter - stacking was using MSP
get_LR_and_branch
  MOV    R1, LR  ; // second parameter is LR current value
  LDR    R2,=__cpp(HardFault_Handler_c)
  BX     R2
  ALIGN
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
        "  ldr    r1,=HardFault_Handler_c  \n"
        "  bx     r1\n"
        "stacking_used_MSP:\n"
        "  mrs    r0,msp\n" /*  first parameter - stacking was using PSP */
        "  ldr    r1,=HardFault_Handler_c  \n"
        "  bx     r1\n"
        ".pool\n" );
}

#endif
/* C part of the fault handler - common between ARM / Keil /gcc */
void HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value)
{
  unsigned int stacked_pc;
  unsigned int stacked_r0;
  hardfault_occurred++;
  if (hardfault_verbose) puts ("[Hard Fault Handler]");
  if (hardfault_expected==0) {
    puts ("ERROR : Unexpected HardFault interrupt occurred.\n");
    UartEndSimulation();
    while (1);
    }
  stacked_r0  = ((unsigned long) hardfault_args[0]);
  stacked_pc  = ((unsigned long) hardfault_args[6]);
  if (hardfault_verbose)  printf(" - Stacked R0 : 0x%x\n", stacked_r0);
  if (hardfault_verbose)  printf(" - Stacked PC : 0x%x\n", stacked_pc);
  /* Modify R0 to a valid address */
  hardfault_args[0] = (unsigned long) &temp_data;

  return;
}



