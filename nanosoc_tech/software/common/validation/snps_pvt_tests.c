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

int snps_pvt_ts_detect(void);
int snps_pvt_pd_detect(void);
int ts0_check_registers(void);
int pd0_check_registers(void);

#if defined ( __CC_ARM   )
__asm void          address_test_write(unsigned int addr, unsigned int wdata);
__asm unsigned int  address_test_read(unsigned int addr);
#else
      void          address_test_write(unsigned int addr, unsigned int wdata);
      unsigned int  address_test_read(unsigned int addr);
#endif
void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);
int                 APB_test_slave_Check(unsigned int offset);

/* Global variables */
volatile int hardfault_occurred;
volatile int hardfault_expected;
volatile int temp_data;
         int hardfault_verbose=0; // 0:Not displaying anything in hardfault handler

#define SNPS_PVT_BASE          (0x40021000UL)
#define SNPS_TS_0_BASE        (SNPS_PVT_BASE + 0x0000UL)
#define SNPS_TS_1_BASE        (SNPS_PVT_BASE + 0x0010UL)
#define SNPS_TS_2_BASE        (SNPS_PVT_BASE + 0x0020UL)
#define SNPS_TS_3_BASE        (SNPS_PVT_BASE + 0x0030UL)
#define SNPS_TS_4_BASE        (SNPS_PVT_BASE + 0x0040UL)
#define SNPS_TS_5_BASE        (SNPS_PVT_BASE + 0x0050UL)
#define SNPS_PD_0_BASE        (SNPS_PVT_BASE + 0x0060UL)
#define SNPS_VM_0_BASE        (SNPS_PVT_BASE + 0x0060UL)

int main (void)
{

  int err_code = 0;
  int data[64];
  int i;
  // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit");
  puts(" - Synopsys PVT test - revision $Revision: 371321 $\n");

  if(snps_pvt_pd_detect()==0) {
    err_code += pd0_check_registers();
  }

  printf("\n\n ************************************ \n\n");

  if((snps_pvt_ts_detect()==0)) {
    err_code += ts0_check_registers();
  }


  if (err_code==0) {
    printf ("\n** TEST PASSED **\n");
  } else {
    printf ("\n** TEST FAILED **, Error code = (0x%x)\n", err_code);
  }
  UartEndSimulation();
  return 0;
}

int ts0_check_registers(void)
{
  uint32_t ts0_reg;
  float temperature;
  float K=81.1;
  float Y=237.5;
  puts("Testing status read/write access \n");
  ts0_reg = address_test_read(SNPS_TS_0_BASE + 0x000);
  printf("Status after reset: 0x%08X \n", ts0_reg);
  ts0_reg = ts0_reg ^ 1;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  printf("Status register after enable: 0x%08X \n", ts0_reg);
  while(!(address_test_read(SNPS_TS_0_BASE)&0x10)){;}
  printf("TS reset released \n");
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  ts0_reg = ts0_reg ^ 2;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  printf("TS Run enabled \n");
  while(!(address_test_read(SNPS_TS_0_BASE)&0x1000000)){;}
  ts0_reg = address_test_read(SNPS_TS_0_BASE + 0x04);
  temperature = (ts0_reg*Y/4094) - K;

  printf("Temperature read data: 0x%08X = %f\n", ts0_reg,temperature);

  // Clear ready reg
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  ts0_reg = ts0_reg ^ 0x8;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  printf("Status register after clear ready: 0x%08X \n", ts0_reg);

  // Enable continuous running
  ts0_reg = ts0_reg ^ 0x4;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  printf("TS Run continuous enabled \n");

  while(!(address_test_read(SNPS_TS_0_BASE)&0x1000000)){;}
  ts0_reg = address_test_read(SNPS_TS_0_BASE + 0x04);
  temperature = (ts0_reg*Y/4094) - K;

  printf("Temperature 1 read data: 0x%08X = %f\n", ts0_reg,temperature);
  // Clear ready reg
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  ts0_reg = ts0_reg ^ 0x8;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  
  while(!(address_test_read(SNPS_TS_0_BASE)&0x1000000)){;}
  ts0_reg = address_test_read(SNPS_TS_0_BASE + 0x04);
  temperature = (ts0_reg*Y/4094) - K;

  printf("Temperature 2 read data: 0x%08X = %f\n", ts0_reg,temperature);

  // Clear ready and continuous read
  ts0_reg = address_test_read(SNPS_TS_0_BASE);
  ts0_reg = ts0_reg ^ 0xC;
  address_test_write(SNPS_TS_0_BASE, ts0_reg);
  ts0_reg = address_test_read(SNPS_TS_0_BASE);


  return 0;
}

int pd0_check_registers(void){
  uint32_t pd0_reg;
  uint32_t pd2_reg;
  float frequency;
  int prescaler = 32;
  int window_size = 63;
  float f_clk = 6;
  puts("Testing PD0 status read/write access \n");
  pd2_reg = address_test_read(SNPS_PD_0_BASE + 0x008);
  printf("Config regs after reset: 0x%08X \n", pd2_reg);

  // Enable PD
  pd0_reg = address_test_read(SNPS_PD_0_BASE);
  pd0_reg = pd0_reg ^ 1;
  address_test_write(SNPS_PD_0_BASE, pd0_reg);
  pd0_reg = address_test_read(SNPS_PD_0_BASE);
  printf("Status register after enable: 0x%08X \n", pd0_reg);
  while(!(address_test_read(SNPS_PD_0_BASE)&0x10)){;}
  printf("PD reset released \n");

  pd2_reg = pd2_reg ^ 0x1000000;
  address_test_write(SNPS_PD_0_BASE + 0x008, pd2_reg);
  pd2_reg = address_test_read(SNPS_PD_0_BASE + 0x008);
  printf("Config regs after config load: 0x%08X \n", pd2_reg);
  pd2_reg = pd2_reg ^ 0x1000000;
  address_test_write(SNPS_PD_0_BASE + 0x008, pd2_reg);

  pd0_reg = address_test_read(SNPS_PD_0_BASE);
  pd0_reg = pd0_reg ^ 2;
  address_test_write(SNPS_PD_0_BASE, pd0_reg);
  printf("PD Run enabled \n");
  while(!(address_test_read(SNPS_PD_0_BASE)&0x1000000)){;}
  pd0_reg = address_test_read(SNPS_PD_0_BASE + 0x04); // Read Data register
  frequency = pd0_reg * prescaler * f_clk / window_size;

  printf("PD read data: 0x%08X = %f \n", pd0_reg, frequency);
  // Clear ready reg
  pd0_reg = address_test_read(SNPS_PD_0_BASE);
  pd0_reg = pd0_reg ^ 0x8;
  address_test_write(SNPS_PD_0_BASE, pd0_reg);


  // Disable PD0
  pd0_reg = address_test_read(SNPS_PD_0_BASE);
  pd0_reg = pd0_reg ^ 1;
  address_test_write(SNPS_PD_0_BASE,pd0_reg);
  printf("Disabled PD0 \n");
  return 0;
}

int snps_pvt_ts_detect(void)
{
  int result;
  int volatile rdata;
  unsigned const int ts0_id     = 0x736E7473;
  puts("Detect if TS0 is present...");
  hardfault_occurred = 0;
  hardfault_expected = 1;
  rdata = address_test_read(SNPS_TS_0_BASE+ 0xC);
  printf("TS0 ID: 0x%08X\n", rdata);
  hardfault_expected = 0;
  result = hardfault_occurred? 1 : 0;
  hardfault_occurred = 0;
  result = rdata == ts0_id? 0: 1;
  if (result!=0) {
    puts("** TEST SKIPPED ** TS0 is not present.\n");
    UartEndSimulation();
  }
  return(result);
}

int snps_pvt_pd_detect(void)
{
  int result;
  int volatile rdata;
  unsigned const int pd0_id     = 0x736E7064;
  puts("Detect if PD0 is present...");
  hardfault_occurred = 0;
  hardfault_expected = 1;
  rdata = address_test_read(SNPS_PD_0_BASE+ 0xC);
  printf("PD0 ID: 0x%08X\n", rdata);
  hardfault_expected = 0;
  result = hardfault_occurred? 1 : 0;
  hardfault_occurred = 0;
  result = rdata == pd0_id? 0: 1;
  if (result!=0) {
    puts("** TEST SKIPPED ** PD0 is not present.\n");
    UartEndSimulation();
  }
  return(result);
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



