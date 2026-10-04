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
#include <stdint.h>
#include "uart_stdout.h"

#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))
#define HW16_REG(ADDRESS)  (*((volatile unsigned short *)(ADDRESS)))
#define HW8_REG(ADDRESS)   (*((volatile unsigned char  *)(ADDRESS)))


typedef struct {
  volatile uint32_t RUN_CTRL:8;
  volatile uint32_t CLK_DIV:8;
  volatile uint32_t FAULTn:8;
  volatile uint32_t READY:8;

  volatile uint32_t DATA:16;
  volatile uint32_t REG0_ACK:8;
  volatile uint32_t REG2_ACK:8;

  volatile uint32_t CONFIG1:8;
  volatile uint32_t CONFIG2:8;
  volatile uint32_t CONFIG3:8;
  volatile uint32_t LD_CFG:8;

  volatile uint32_t ID:32;
} snps_pd_TypeDef;

enum{
  PD_CHAIN_NONE = 0,
  PD_CHAIN_BUILT_IN = 6,
  PD_CHAIN_LVT = 1,
  PD_CHAIN_SVT = 3,
  PD_CHAIN_HVT = 5,
  PD_CHAIN_THICK_OX = 7
};

enum{
  PD_PRE_16 = 0,
  PD_PRE_32 = 1,
  PD_PRE_64 = 2,
  PD_PRE_4 = 3
};

enum{
  PD_W_255 = 0,
  PD_W_127 = 1,
  PD_W_63 = 2,
  PD_W_31 = 3
};

uint8_t snps_pd_prescaler=16;
uint8_t snps_pd_window=255;
float snps_pd_fclk = 4.5454545;
extern uint32_t SystemCoreClock;     /*!< System Clock Frequency (Core Clock)  */


typedef struct {
  volatile uint32_t RUN_CTRL:8;
  volatile uint32_t CLK_DIV:8;
  volatile uint32_t RESETn:8;
  volatile uint32_t READY:8;

  volatile uint32_t DATA:16;
  volatile uint32_t REG0_ACK:8;
  volatile uint32_t REG2_ACK:8;

  volatile uint32_t CAL:8;
  volatile uint32_t SIG_EN:8;
  volatile uint32_t TM_AN:16;

  volatile uint32_t ID:32;
} snps_ts_TypeDef;

const float SNPS_TS_K = 81.1;
const float SNPS_TS_Y = 237.5;

int snps_pvt_ts_detect(void);
int snps_pvt_pd_detect(void);
int ts0_check_registers(void);
int pd0_check_registers(void);

void snps_pvt_ts_enable(void);
void snps_pvt_ts_run(void);
void snps_pvt_ts_clr_ready(void);
void snps_pvt_ts_disable(void);

void snps_pvt_pd_ld_config(uint8_t chain, uint8_t pre, uint8_t window);
void snps_pvt_pd_set_clk_div(uint8_t clk_div);

void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);

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

#define SNPS_PD   ((snps_pd_TypeDef *) SNPS_PD_0_BASE)
#define SNPS_TS_0 ((snps_ts_TypeDef *) SNPS_TS_0_BASE)


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
  uint16_t data;
  int i;
  float temperature;

  printf("Testing status read/write access \n");
  printf("CTRL after reset: 0x%x \n", SNPS_TS_0->RUN_CTRL);

  printf("Enable TS clock and power up \n");
  snps_pvt_ts_enable();

  printf("TS Run once \n");
  snps_pvt_ts_run();

  printf("Wait for conversion \n");
  while(SNPS_TS_0->READY==0){;}
  snps_pvt_ts_clr_ready();

  data = SNPS_TS_0->DATA;
  temperature = (data*SNPS_TS_Y/4094) - SNPS_TS_K;

  printf("Temperature read data: 0x%08X = %f\n", data,temperature);


  snps_pvt_ts_disable();
  return 0;
}

int pd0_check_registers(void){
  uint32_t pd0_reg;
  uint32_t pd2_reg;
  uint8_t pd_run_ctrl;

  float frequency;

  puts("Testing PD0 reg read access \n");

  printf("Config1 after reset: 0x%08X \n", SNPS_PD->CONFIG1);
  printf("Config2 after reset: 0x%08X \n", SNPS_PD->CONFIG2);
  printf("Config3 after reset: 0x%08X \n", SNPS_PD->CONFIG3);

  // Enable PD
  printf("Enable Clock...\n");
  snps_pvt_pd_set_clk_div(0x0A);
  SNPS_PD->RUN_CTRL = 2;

  printf("Load defaults...\n");
  SNPS_PD->LD_CFG=1;
  while(SNPS_PD->REG2_ACK==0){;}
  while(SNPS_PD->REG2_ACK!=0){;}
  
  SNPS_PD->LD_CFG=0;
  while(SNPS_PD->REG2_ACK==0){;}
  while(SNPS_PD->REG2_ACK!=0){;}

  printf("Run once...\n");
  pd_run_ctrl = SNPS_PD->RUN_CTRL;
  pd_run_ctrl = pd_run_ctrl ^ 1;
  SNPS_PD->RUN_CTRL = pd_run_ctrl;
  while(SNPS_PD->REG0_ACK==0){;}
  while(SNPS_PD->REG0_ACK!=0){;}
  printf("2\n");
  pd_run_ctrl = SNPS_PD->RUN_CTRL;
  pd_run_ctrl = pd_run_ctrl ^ 1;
  SNPS_PD->RUN_CTRL = pd_run_ctrl;
  while(SNPS_PD->REG0_ACK==0){;}
  while(SNPS_PD->REG0_ACK!=0){;}

  printf("Wait for conversion...\n");
  while(SNPS_PD->READY==0){;}

  
  pd0_reg = SNPS_PD->DATA; // Read Data register
  frequency = pd0_reg * snps_pd_prescaler * snps_pd_fclk / snps_pd_window;

  printf("PD read data: 0x%08X = %f \n", pd0_reg, frequency);
  // Clear ready reg
  pd_run_ctrl = SNPS_PD->RUN_CTRL;
  pd_run_ctrl = pd_run_ctrl ^ 0x8;
  SNPS_PD->RUN_CTRL = pd_run_ctrl;

  // Disable PD0
  SNPS_PD->RUN_CTRL = 0;
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
  rdata = SNPS_TS_0->ID;
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
  rdata = SNPS_PD->ID;
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


void snps_pvt_ts_enable(void){
  int i;
  // Set enable bit high
  SNPS_TS_0->RUN_CTRL = 2;
  // Wait for enable acknowledgment
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}
  // Wait 50us for power up
  for(i=0;i<3000;i++){;}
  // Release reset
  SNPS_TS_0->RESETn=1;
  // Wait for reset acknowledgement
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}

  return;
}
void snps_pvt_ts_run(void){
  // Set run register
  SNPS_TS_0->RUN_CTRL = 3;
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}
  // Clear run register
  SNPS_TS_0->RUN_CTRL = 2;
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}
  return;
}

void snps_pvt_ts_clr_ready(void){
  SNPS_TS_0->RUN_CTRL = SNPS_TS_0->RUN_CTRL | (1<<3);
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}
  SNPS_TS_0->RUN_CTRL = SNPS_TS_0->RUN_CTRL & 7;
  while((SNPS_TS_0->REG0_ACK)==0){;}
  while((SNPS_TS_0->REG0_ACK)==1){;}
  return;
}

void snps_pvt_ts_disable(void){
  // Set reset
  SNPS_TS_0->RESETn=0;
  // Enable set to 0
  SNPS_TS_0->RUN_CTRL = 0;
  return;
}

void snps_pvt_pd_ld_config(uint8_t chain, uint8_t pre, uint8_t window){
  // Set config registers
  SNPS_PD->CONFIG2 = chain << 5;
  SNPS_PD->CONFIG3 = (window << 4) + pre;
  // Set load config
  SNPS_PD->LD_CFG=1;
  // Wait for acknowledgement
  while(SNPS_PD->REG2_ACK==0){;}
  while(SNPS_PD->REG2_ACK!=0){;}
  // Set load config 0
  SNPS_PD->LD_CFG=0;
  // Wait for acknowledgement
  while(SNPS_PD->REG2_ACK==0){;}
  while(SNPS_PD->REG2_ACK!=0){;}

  // Update global variables
  switch (pre) {
    case 0:
      snps_pd_prescaler = 16;
      break;
    case 1:
      snps_pd_prescaler = 32;
      break;
    case 2:
      snps_pd_prescaler = 64;
      break;
    case 3:
      snps_pd_prescaler = 4;
      break;
  }

  switch (window) {
    case 0:
      snps_pd_window = 255;
      break;
    case 1:
      snps_pd_window = 127;
      break;
    case 2:
      snps_pd_window = 63;
      break;
    case 3:
      snps_pd_window = 31;
      break;
    }
  return;
}

void snps_pvt_pd_set_clk_div(uint8_t clk_div){
  SNPS_PD->CLK_DIV=clk_div; // 240MHz / 
  snps_pd_fclk = SystemCoreClock / clk_div;
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



