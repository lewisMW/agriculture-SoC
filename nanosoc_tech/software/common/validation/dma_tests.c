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
  A simple test to check the connectivity of the DMA-230 including
  interrupt and done signals
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

#include "config_id.h"

#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))
volatile int dma_done_irq_occurred;
volatile int dma_done_irq_expected;
volatile int dma_error_irq_occurred;
volatile int dma_error_irq_expected;

int  pl230_dma_detect(void);
int  ID_Check(const unsigned int id_array[], unsigned int offset);
void dma_memory_copy (unsigned int src, unsigned int dest, unsigned int size, unsigned int num);
void dma_data_struct_init(void);
void dma_pl230_init(void);
int  dma_simple_test(void);
int  dma_interrupt_test(void);
int  dma_event_test(void);
void delay(void);

                              /* Maximum to 32 DMA channel */
#define MAX_NUM_OF_DMA_CHANNELS   32
                              /* SRAM in example system is 64K bytes */
//#define RAM_ADDRESS_MAX       0x3000FFFF
#define RAM_ADDRESS_MAX       0x80000FFF

typedef struct /* 4 words */
{
  volatile unsigned long SrcEndPointer;
  volatile unsigned long DestEndPointer;
  volatile unsigned long Control;
  volatile unsigned long unused;
} pl230_dma_channel_data;


typedef struct /* 8 words per channel */
{ /* only one channel in the example uDMA setup */
  volatile pl230_dma_channel_data Primary[MAX_NUM_OF_DMA_CHANNELS];
  volatile pl230_dma_channel_data Alternate[MAX_NUM_OF_DMA_CHANNELS];
} pl230_dma_data_structure;

pl230_dma_data_structure *dma_data;

volatile unsigned int source_data_array[4];  /* Data array for memory DMA test */
volatile unsigned int dest_data_array[4];    /* Data array for memory DMA test */

#if defined ( __CC_ARM   )
__asm unsigned int  address_test_read(unsigned int addr);
#else
      unsigned int  address_test_read(unsigned int addr);
#endif

void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);

/* Global variables */
volatile int hardfault_occurred;
volatile int hardfault_expected;
volatile int temp_data;
int main (void)
{
  int result=0;
  temp_data=0;
  hardfault_occurred = 0;
  hardfault_expected = 0;

  // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit - DMA Test - revision $Revision: 371321 $\n");


  if (pl230_dma_detect()!=0) {
    return 0; /* Quit test if DMA is not present */
  }

  dma_done_irq_expected = 0;
  dma_done_irq_occurred = 0;
  dma_error_irq_expected = 0;
  dma_error_irq_occurred = 0;
  dma_data_struct_init();
  dma_pl230_init();
  result += dma_simple_test();
  result += dma_interrupt_test();
  result += dma_event_test();
  if (result==0) {
    printf ("\n** TEST PASSED **\n");
  } else {
    printf ("\n** TEST FAILED **, Error code = (0x%x)\n", result);
  }
  UartEndSimulation();
  return 0;
}

/* --------------------------------------------------------------- */
/*  Detect if DMA controller is present or not                     */
/* --------------------------------------------------------------- */

int pl230_dma_detect(void)
{
  int result;
  int volatile rdata; /* dummy variable for read data in bus fault testing */
  unsigned const int pl230_id[12] = {
                                 0x30, 0xB2, 0x0B, 0x00,
                                 0x0D, 0xF0, 0x05, 0xB1};
  puts("Detect if DMA controller is present...");
  hardfault_occurred = 0;
  hardfault_expected = 1;
  rdata = address_test_read(CMSDK_PL230_BASE+ 0xFE0);
  hardfault_expected = 0;
  result = hardfault_occurred ? 1 : ID_Check(&pl230_id[0], CMSDK_PL230_BASE);
  hardfault_occurred = 0;
  if (result!=0) {
    puts("** TEST SKIPPED ** DMA controller is not present.\n");
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
    test_addr = offset + 4*i + 0xFE0;
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

/* --------------------------------------------------------------- */
/*  Initialize DMA data structure                                  */
/* --------------------------------------------------------------- */
void dma_data_struct_init(void)
{
  int          i;   /* loop counter */
  unsigned int ptr;

  int          ch_num;         /* number of channels */
  unsigned int blksize;        /* Size of DMA data structure in bytes */
  unsigned int blkmask;        /* address mask */


  ch_num  = (((CMSDK_DMA->DMA_STATUS) >> 16) & 0x1F)+1;
  blksize = ch_num * 32;
  if      (ch_num > 16) blkmask = 0x3FF; /* 17 to 32 */
  else if (ch_num > 8)  blkmask = 0x1FF; /*  9 to 16 */
  else if (ch_num > 4)  blkmask = 0x0FF; /*  5 to 8 */
  else if (ch_num > 2)  blkmask = 0x07F; /*  3 to 4 */
  else if (ch_num > 1)  blkmask = 0x07F; /*       2 */
  else                  blkmask = 0x03F; /*       1 */

  /* Create DMA data structure in RAM after stack
  In the linker script, a 1KB memory stack above stack is reserved
  so we can use this space for putting the DMA data structure.
  */

//  ptr     = HW32_REG(0);                     /* Read Top of Stack */
  ptr     = 0x80000000;              /* DMA memory bank */

  /* the DMA data structure must be aligned to the size of the data structure */
  if ((ptr & blkmask) != 0x0)
    ptr     = (ptr + blksize) & ~blkmask;

  if ((ptr + blksize) > (RAM_ADDRESS_MAX + 1)) {
    puts ("ERROR : Not enough RAM space for DMA data structure.");
    UartEndSimulation();
    }

  /* Set pointer to the reserved space */
  dma_data = (pl230_dma_data_structure *) ptr;
  ptr = (unsigned int) &dma_data->Primary->SrcEndPointer;

  printf ("dma structure block address = %x\n", ptr);

  for (i=0; i<1; i++) {
    dma_data->Primary->SrcEndPointer  = 0;
    dma_data->Primary->DestEndPointer = 0;
    dma_data->Primary->Control        = 0;
    dma_data->Alternate->SrcEndPointer  = 0;
    dma_data->Alternate->DestEndPointer = 0;
    dma_data->Alternate->Control        = 0;
    }

  return;
}

/* --------------------------------------------------------------- */
/*  Initialize DMA PL230                                           */
/* --------------------------------------------------------------- */
void dma_pl230_init(void)
{
  unsigned int current_state;
  puts ("Initialize PL230");
  current_state = CMSDK_DMA->DMA_STATUS;
  printf ("- # of channels allowed : %d\n",(((current_state) >> 16) & 0x1F)+1);
  /* Debugging printfs: */
  /*printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));*/
  /*printf ("- Current master enable : %x\n",(((current_state) >> 0)  & 0x1));*/

  /* Wait until current DMA complete */
  current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  if (!((current_state==0) || (current_state==0x8) || (current_state==0x9))) {
    puts ("- wait for DMA IDLE/STALLED/DONE");
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
    printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));

    }
  while (!((current_state==0) || (current_state==0x8) || (current_state==0x9))){
    /* Wait if not IDLE/STALLED/DONE */
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
    printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));
    }
  CMSDK_DMA->DMA_CFG = 0; /* Disable DMA controller for initialization */
  CMSDK_DMA->CTRL_BASE_PTR = (unsigned int) &dma_data->Primary->SrcEndPointer;
                           /* Set DMA data structure address */
  CMSDK_DMA->CHNL_ENABLE_CLR = 0xFFFFFFFF; /* Disable all channels */
  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */
  CMSDK_DMA->DMA_CFG = 1;              /* Enable DMA controller */

  return;
}

/* --------------------------------------------------------------- */
/*  DMA memory copy                                                */
/* --------------------------------------------------------------- */
void dma_memory_copy (unsigned int src, unsigned int dest, unsigned int size, unsigned int num)
{
  unsigned long src_end_pointer =  src + ((1<<size)*(num-1));
  unsigned long dst_end_pointer = dest + ((1<<size)*(num-1));
  unsigned long control         = (size << 30) |  /* dst_inc */
                                  (size << 28) |  /* dst_size */
                                  (size << 26) |  /* src_inc */
                                  (size << 24) |  /* src_size */
                                  (size << 21) |  /* dst_prot_ctrl - HPROT[3:1] */
                                  (size << 18) |  /* src_prot_ctrl - HPROT[3:1] */
//                                  (0    << 14) |  /* R_power */
                                  (4    << 14) |  /* R_power set for up to 16 transfers */
                                  ((num-1)<< 4) | /* n_minus_1 */
                                  (0    <<  3) |  /* next_useburst */
                                  (2    <<  0) ;  /* cycle_ctrl - auto */

  /* By default the PL230 is little-endian; if the processor is configured
   * big-endian then the configuration data that is written to memory must be
   * byte-swapped before being written.  This is also true if the processor is
   * little-endian and the PL230 is big-endian.
   * Remove the __REV usage if the processor and PL230 are configured with the
   * same endianness
   * */
  dma_data->Primary->SrcEndPointer  = (EXPECTED_BE) ? __REV(src_end_pointer) : (src_end_pointer);
  dma_data->Primary->DestEndPointer = (EXPECTED_BE) ? __REV(dst_end_pointer) : (dst_end_pointer);
  dma_data->Primary->Control        = (EXPECTED_BE) ? __REV(control        ) : (control        );
  /* Debugging printfs: */
  /*printf ("SrcEndPointer  = %x\n", dma_data->Primary->SrcEndPointer);*/
  /*printf ("DestEndPointer = %x\n", dma_data->Primary->DestEndPointer);*/

  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */
  CMSDK_DMA->CHNL_SW_REQUEST = (1<<0); /* request channel 0 DMA */

  return;
}

/* --------------------------------------------------------------- */
/*  Simple software DMA test                                       */
/* --------------------------------------------------------------- */
int dma_simple_test(void)
{
  int return_val=0;
  int err_code=0;
  int i;
  unsigned int current_state;


  puts("uDMA simple test");
  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */

  /* setup data for DMA */
  for (i=0;i<4;i++) {
    source_data_array[i] = i;
    dest_data_array[i]   = 0;
  }

  dma_memory_copy ((unsigned int) &source_data_array[0],(unsigned int) &dest_data_array[0], 2, 4);
  do { /* Wait until PL230 DMA controller return to idle state */
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  } while (current_state!=0);

  for (i=0;i<4;i++) {
    /* Debugging printf: */
    /*printf (" - dest[i] = %x\n", dest_data_array[i]);*/
    if (dest_data_array[i]!= i){
      printf ("ERROR:dest_data_array[%d], expected %x, actual %x\n", i, i, dest_data_array[i]);
      err_code |= (1<<i);
    }
  }

// then as 16 byte transfers
  dma_memory_copy ((unsigned int) &source_data_array[0],(unsigned int) &dest_data_array[0], 0, 16);
  do { /* Wait until PL230 DMA controller return to idle state */
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  } while (current_state!=0);

  for (i=0;i<4;i++) {
    /* Debugging printf: */
    /*printf (" - dest[i] = %x\n", dest_data_array[i]);*/
    if (dest_data_array[i]!= i){
      printf ("ERROR:dest_data_array[%d], expected %x, actual %x\n", i, i, dest_data_array[i]);
      err_code |= (1<<i);
    }
  }

  /* Generate return value */
  if (err_code != 0) {
    printf ("ERROR : simple DMA failed (0x%x)\n", err_code);
    return_val=1;
  } else {
    puts ("-Passed");
  }

  return(return_val);
}
/* --------------------------------------------------------------- */
/*  Simple DMA interrupt test                                      */
/* --------------------------------------------------------------- */
int dma_interrupt_test(void)
{
  int return_val=0;
  int err_code=0;
  int i;
  unsigned int current_state;


  puts("DMA interrupt test");
  puts("- DMA done");

  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */

  /* setup data for DMA */
  for (i=0;i<4;i++) {
    source_data_array[i] = i;
    dest_data_array[i]   = 0;
  }

  dma_done_irq_expected = 1;
  dma_done_irq_occurred = 0;
  NVIC_ClearPendingIRQ(DMA_IRQn);
  NVIC_EnableIRQ(DMA_IRQn);

  dma_memory_copy ((unsigned int) &source_data_array[0],(unsigned int) &dest_data_array[0], 2, 4);
  delay();
  /* Can't guarantee that there is sleep support, so use a polling loop */
  do { /* Wait until PL230 DMA controller return to idle state */
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  } while (current_state!=0);

  for (i=0;i<4;i++) {
    /* Debugging printf: */
    /*printf (" - dest[i] = %x\n", dest_data_array[i]);*/
    if (dest_data_array[i]!= i){
      printf ("ERROR:dest_data_array[%d], expected %x, actual %x\n", i, i, dest_data_array[i]);
      err_code |= (1<<i);
    }
  }

  if (dma_done_irq_occurred==0){
    puts ("ERROR: DMA done IRQ missing");
    err_code |= (1<<4);
  }

  puts("- DMA err");
  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */

  /* setup data for DMA */
  for (i=0;i<4;i++) {
    source_data_array[i] = i;
    dest_data_array[i]   = 0;
  }

  dma_error_irq_expected = 1;
  dma_error_irq_occurred = 0;
  NVIC_ClearPendingIRQ(DMA_IRQn);
  NVIC_EnableIRQ(DMA_IRQn);

  /* Generate DMA transfer to invalid memory location */
  dma_memory_copy ((unsigned int) &source_data_array[0],0xEF000000, 2, 4);
  delay();
  /* Can't guarantee that there is sleep support, so use a polling loop */
  do { /* Wait until PL230 DMA controller return to idle state */
    current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  } while (current_state!=0);

  if (dma_error_irq_occurred==0){
    puts ("ERROR: DMA err IRQ missing");
    err_code |= (1<<5);
  }


  /* Clear up */
  dma_done_irq_expected = 0;
  dma_done_irq_occurred = 0;
  dma_error_irq_expected = 0;
  dma_error_irq_occurred = 0;
  NVIC_DisableIRQ(DMA_IRQn);

  /* Generate return value */
  if (err_code != 0) {
    printf ("ERROR : DMA done interrupt failed (0x%x)\n", err_code);
    return_val=1;
  } else {
    puts ("-Passed");
  }

  return(return_val);
}

/* --------------------------------------------------------------- */
/*  DMA event test                                                 */
/* --------------------------------------------------------------- */
int dma_event_test(void)
{
  int return_val=0;
  int err_code=0;
  int i;
  unsigned int current_state;


  puts("DMA event test");
  puts("- DMA done event to RXEV");

  CMSDK_DMA->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */

  /* setup data for DMA */
  for (i=0;i<4;i++) {
    source_data_array[i] = i;
    dest_data_array[i]   = 0;
  }

  dma_done_irq_expected = 1;
  dma_done_irq_occurred = 0;
  NVIC_ClearPendingIRQ(DMA_IRQn);
  NVIC_DisableIRQ(DMA_IRQn);

  /* Clear event register - by setting event with SEV and then clear it with WFE */
  __SEV();
  __WFE(); /* First WFE will not enter sleep because of previous event */

  dma_memory_copy ((unsigned int) &source_data_array[0],(unsigned int) &dest_data_array[0], 2, 4);
  __WFE(); /* This will cause the processor to enter sleep */

  /* Processor woken up */
  current_state = (CMSDK_DMA->DMA_STATUS >> 4)  & 0xF;
  if (current_state!=0) {
    puts ("ERROR: DMA status should be IDLE after wake up");
    err_code |= (1<<5);
  }

  for (i=0;i<4;i++) {
    /*printf (" - dest[i] = %x\n", dest_data_array[i]);*/
    if (dest_data_array[i]!= i){
      printf ("ERROR:dest_data_array[%d], expected %x, actual %x\n", i, i, dest_data_array[i]);
      err_code |= (1<<i);
    }
  }

  /* Generate return value */
  if (err_code != 0) {
    printf ("ERROR : DMA event failed (0x%x)\n", err_code);
    return_val=1;
  } else {
    puts ("-Passed");
  }

  return(return_val);
}

/* --------------------------------------------------------------- */
/*  DMA interrupt handlers                                         */
/* --------------------------------------------------------------- */

void DMA_Handler(void)
{
if ((CMSDK_DMA->ERR_CLR & 1) != 0)  {
  /* DMA interrupt is caused by DMA error */
  dma_error_irq_occurred ++;
  CMSDK_DMA->ERR_CLR = 1; /* Clear dma_err */
  if (dma_error_irq_expected==0) {
    puts ("ERROR : Unexpected DMA error interrupt occurred.\n");
    UartEndSimulation();
    while (1);
    }
  }
else {
  // DMA interrupt is caused by DMA done
  dma_done_irq_occurred ++;
  if (dma_done_irq_expected==0) {
    puts ("ERROR : Unexpected DMA done interrupt occurred.\n");
    UartEndSimulation();
    while (1);
    }
  }
}

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
  puts ("[Hard Fault Handler]");
  if (hardfault_expected==0) {
    puts ("ERROR : Unexpected HardFault interrupt occurred.\n");
    UartEndSimulation();
    while (1);
    }
  stacked_r0  = ((unsigned long) hardfault_args[0]);
  stacked_pc  = ((unsigned long) hardfault_args[6]);
  printf(" - Stacked R0 : 0x%x\n", stacked_r0);
  printf(" - Stacked PC : 0x%x\n", stacked_pc);
  /* Modify R0 to a valid address */
  hardfault_args[0] = (unsigned long) &temp_data;

  return;
}


void delay(void)
{
  int i;
  for (i=0;i<5;i++){
    __ISB();
    }
  return;
}

