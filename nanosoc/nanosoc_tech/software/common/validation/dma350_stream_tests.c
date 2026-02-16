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
#include "CMSDK_driver.h"


#include "config_id.h"
#include <string.h>
#include <inttypes.h>
#include "dma_350_command_lib.h"

//Channel number defines
// Note: Please add more channels if DMA has more than 8 channels
#define CH0                     0
#define CH1                     1


// Note: Please modify the addresses according to the system memory map
#define COPY_ADDR_SRC_0        0x80000000
#define COPY_ADDR_SRC_1        0x80000100
#define COPY_ADDR_SRC_2        0x80000200
#define COPY_ADDR_DST_0        0x98000000
#define COPY_ADDR_DST_1        0x98000100
#define COPY_ADDR_DST_2        0x98000200


// Note: Please modify to the desired data size
#define DATA_SIZE               64
#define LARGE_DATA_SIZE         10000

#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))

#if defined ( __CC_ARM   )
__asm void          address_test_write(unsigned int addr, unsigned int wdata);
__asm unsigned int  address_test_read(unsigned int addr);
#else
      void          address_test_write(unsigned int addr, unsigned int wdata);
      unsigned int  address_test_read(unsigned int addr);
#endif

void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);

//typedef unsigned long int uintptr_t;
// Array for command with a Header + 5 modified registers
uint32_t LinkCmd[6];
// Variable to store the address of the above array
uintptr_t LinkCmd_adr = (uintptr_t) LinkCmd;

volatile int dma_done_irq_occurred;
volatile int dma_done_irq_expected;
volatile int dma_error_irq_occurred;
volatile int dma_error_irq_expected;
volatile int hardfault_occurred;
volatile int hardfault_expected;
volatile int temp_data;
volatile int current_channel;

uint8_t dma350_detect(void);
void delay(uint32_t t);
void SystemInitialization(void);
void DMAClearChIrq(uint32_t ch);
void DMA_Handler(void) __attribute__((interrupt));
void initialise_destination(unsigned int actual_addr);
uint8_t check_destination(unsigned int actual_addr);

int main(void) {

  // Get the number of channels and trigger interfaces
  uint32_t ch_num;
  uint32_t trig_in_num;
  uint32_t trig_out_num;
  uint32_t errors = 0;
  unsigned int actual_addr;
  hardfault_occurred = 0;
  hardfault_expected = 0;
    // Call Function for the testbench Specific Initialization
    // Note: Change to the system specific function for initialization
    SystemInitialization();

  printf("<--- DMA START --->\n");

  // Define structures for the tests
  // Note: Command and channel parameters can be modified to the desired settings

  // Set the DMA channel related parameters
  // Channel Priority is '0' - Lowest Priority
  // Cleaning DMA Channel registers at the end of the command is enabled
  // Reloading initial register values at the end of the command is disabled
  // STATUS_DONE status flag is asserted at the end of the command.
  // Automatic pause request at the end of the command is disabled
  // Maximum source and destination burst lengths sent by the DMA are 15+1=16 (Can be limited by FIFO size)
  AdaChannelSettingsType ch_settings = {
    .CHPRIO         = 0,
    .CLEARCMD       = 1,
    .REGRELOADTYPE  = RELOAD_DISABLED,
    .DONETYPE       = DONETYPE_EOF_CMD,
    .DONEPAUSEEN    = 0,
    .SRCMAXBURSTLEN = 15,
    .DESMAXBURSTLEN = 15
  };
  AdaChannelSettingsType ch_settings_no_burst = {
    .CHPRIO         = 0,
    .CLEARCMD       = 1,
    .REGRELOADTYPE  = RELOAD_DISABLED,
    .DONETYPE       = DONETYPE_EOF_CMD,
    .DONEPAUSEEN    = 0,
    .SRCMAXBURSTLEN = 0,
    .DESMAXBURSTLEN = 0
  };

  // Set the attributes of the read AXI transactions sent by the DMA
  // These settings affects the ARINNER[3:0], AWINNER[3:0], ARCACHE[3:0], AWCACHE[3:0] and AxDOMAIN[1:0] attributes
  // of the AXI transactions
  // This command uses Normal memory, Non-Cacheable, Bufferable, System-shareable AXI attributes
  // ARINNER[3:0] = 4'b0011, AWINNER[3:0] = 4'b0011, ARCACHE[3:0] = 4'b0011, AWCACHE[3:0] = 4'b0011, AxDOMAIN[1:0] = 2'b11
  // More information about the AXI attribute settings can be found in the TRM
  // The command uses non-secure, non-privileged AXI read transactions
  AdaChannelSrcAttrType ch_srcattr = {
    .SRCMEMATTRLO  = 4,
    .SRCMEMATTRHI  = 4,
    .SRCSHAREATTR  = 0,
    .SRCNONSECATTR = 1,
    .SRCPRIVATTR   = 0
  };

  // Set the attributes of the write AXI transactions sent by the DMA
  // These settings affects the ARINNER[3:0], AWINNER[3:0], ARCACHE[3:0], AWCACHE[3:0] and AxDOMAIN[1:0] attributes
  // of the AXI transactions
  // This command uses Normal memory, Non-Cacheable, Bufferable, System-shareable AXI attributes
  // ARINNER[3:0] = 4'b0011, AWINNER[3:0] = 4'b0011, ARCACHE[3:0] = 4'b0011, AWCACHE[3:0] = 4'b0011, AxDOMAIN[1:0] = 2'b11
  // More information about the AXI attribute settings can be found in the TRM
  // The command uses non-secure, non-privileged AXI write transactions
  AdaChannelDesAttrType ch_desattr = {
    .DESMEMATTRLO  = 4,
    .DESMEMATTRHI  = 4,
    .DESSHAREATTR  = 0,
    .DESNONSECATTR = 1,
    .DESPRIVATTR   = 0
  };

  // Set the attributes of the read AXI transactions used for the command link related transfers
  AdaChannelLinkAttrType ch_linkattr = {
    .LINKMEMATTRLO = 4,
    .LINKMEMATTRHI = 4,
    .LINKSHAREATTR = 0
  };


  AdaBaseCommandType str_command_base_0 = {
    .SRCADDR  = COPY_ADDR_SRC_0, // Read from M0 interface
    .DESADDR  = COPY_ADDR_DST_0, // Write to M1 interface
    .SRCXSIZE = DATA_SIZE,
    .DESXSIZE = DATA_SIZE,
    .TRANSIZE = BITS_32
  };
  AdaBaseCommandType str_command_base_1 = {
    .SRCADDR  = COPY_ADDR_SRC_1, // Read from M0 interface
    .DESADDR  = COPY_ADDR_DST_1, // Write to M1 interface
    .SRCXSIZE = DATA_SIZE,
    .DESXSIZE = DATA_SIZE,
    .TRANSIZE = BITS_32
  };  
  AdaBaseCommandType str_command_base_2 = {
    .SRCADDR  = COPY_ADDR_SRC_2, // Read from M0 interface
    .DESADDR  = COPY_ADDR_DST_2, // Write to M1 interface
    .SRCXSIZE = DATA_SIZE,
    .DESXSIZE = DATA_SIZE,
    .TRANSIZE = BITS_32
  };
  // Set the increment of source and destination addresses
  // The source and destination address increments are 1
  Ada1DIncrCommandType command_1d_incr = {
    .SRCXADDRINC = 1,           // Autoincrement by transaction size
    .DESXADDRINC = 1            // Autoincrement by transaction size
  };

  // Set the transfer types (2D and wrapping support)
  // The transaction type is 1D basic transfer
  AdaWrapCommandType command_1d_wrap = {
    .FILLVAL  = 0,
    .XTYPE    = OPTYPE_CONTINUE,
    .YTYPE    = OPTYPE_DISABLE
  };

  // Enable/disable the interupts of the channel
  // Error and done interrupts are enabled
  AdaIrqEnType ch_irqs = {
    .INTREN_DONE     = 1,
    .INTREN_ERR      = 1,
    .INTREN_DISABLED = 0,
    .INTREN_STOPPED  = 0
  };

  // Set stream type
  // Both stream in and out interfaces are used
  AdaStreamType command_stream = {
    .STREAMTYPE = IN_AND_OUT
  } ;


  if(dma350_detect()!=0){
    return 0;
  }

  //Initialize TCM
  printf("Initialize SRAM... ");
  actual_addr = str_command_base_0.SRCADDR;
  unsigned int test_data[str_command_base_0.SRCXSIZE];
  int j;
  for(j = 0; j < 64; j++){
    test_data[j] = j;
    address_test_write(actual_addr,test_data[j]);
    //printf("Written data: 0x%x to address 0x%x \n", test_data[j], actual_addr);
    actual_addr = actual_addr+4;
  }
  actual_addr = str_command_base_1.SRCADDR;
  for(j = 0; j < 64; j++){
    address_test_write(actual_addr,test_data[j]);
    //printf("Written data: 0x%x to address 0x%x \n", test_data[j], actual_addr);
    actual_addr = actual_addr+4;
  }
  actual_addr = str_command_base_2.SRCADDR;
  for(j = 0; j < 64; j++){
    address_test_write(actual_addr,test_data[j]);
    //printf("Written data: 0x%x to address 0x%x \n", test_data[j], actual_addr);
    actual_addr = actual_addr+4;
  }
  printf("done\n");


  //Get the configuration information
  ch_num = AdaGetChNum(SECURE);
  trig_in_num = AdaGetTrigInNum(SECURE);
  trig_out_num = AdaGetTrigOutNum(SECURE);

  //Display the config parameters read
  printf("Number of DMA channels: %d \n", ch_num);
  printf("Number of DMA trigger inputs: %d \n", trig_in_num);
  printf("Number of DMA trigger outputs: %d \n", trig_out_num);


  printf("---STARTING Stream interface tests---\n");
  __enable_irq();
  for (uint32_t ch=0; ch < ch_num; ch++) {
    current_channel=ch;
    //
    // Write all settings to the DMA registers
    AdaChannelInit(ch_settings, ch_srcattr, ch_desattr, ch, SECURE);
    Ada1DIncrCommand(str_command_base_0, command_1d_incr, ch, SECURE);
    AdaStreamInit(command_stream, ch, SECURE);
    AdaStreamEnable(1 ,ch, SECURE);
    AdaSetIntEn(ch_irqs, ch, SECURE);

    
    dma_done_irq_expected = 1;
    dma_done_irq_occurred = 0;
    NVIC_ClearPendingIRQ(DMA_IRQn);
    NVIC_EnableIRQ(DMA_IRQn);


    printf("DMA %d configured. Starting the transfer.\n", ch);


    // Start DMA operation and wait for done IRQ
    AdaEnable(ch, SECURE);
    __WFI();
    printf("Return from interrupt\n");
    
    //AdaClearChDone(ch, SECURE);
    printf("DMA transfer finished\n");

    if (check_destination(str_command_base_0.DESADDR)!=0){
      errors++;
    }
    else{
      printf("Passed\n");
    }

    initialise_destination(str_command_base_0.DESADDR);
    // Disable channel and stream
    AdaDisable(ch, SECURE);
    AdaStreamEnable(0 ,ch, SECURE);
  }




  NVIC_DisableIRQ(DMA_IRQn);
  __disable_irq();
  
  if(errors!=0){
    printf("\n** TEST FAILED **, Error code = (0x%x)\n",errors);
  } else {
    printf ("\n** TEST PASSED **\n");
  }

  UartEndSimulation();
  return 0;
}

// Setup all components in the system
void SystemInitialization(void){
  // Initialize the system. For example clock gating, PPU, SAU, security components, peripherals etc.
  // Note: This function should setup all system components
    // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit - DMA Test - revision $Revision: 371321 $\n");
}

uint8_t dma350_detect(void)
{
  uint8_t result;
  int volatile rdata;
  unsigned const int dma350_iidr = 0x3a00043b;
  puts("Detect if DMA350 controller is present...");
  hardfault_occurred = 0;
  hardfault_expected = 1;
  rdata = address_test_read(ADA_DMA_S_BASE+0xFC8);
  hardfault_expected = 0;
  result = hardfault_occurred ? 1 : (rdata!=dma350_iidr);
  if (result!=0) {
    puts("** TEST SKIPPED ** DMA controller is not present.\n");
    UartEndSimulation();
  }
  return(result);
}

void initialise_destination(unsigned int actual_addr)
{
  int j;
  for(j = 0; j < 64; j++){
    address_test_write(actual_addr,0);
    //printf("Written data: 0x%x to address 0x%x \n", test_data[j], actual_addr);
    actual_addr = actual_addr+4;
  }
}

uint8_t check_destination(unsigned int actual_addr)
{
  uint32_t mismatches=0;
  uint32_t value;
  int j;
  for(j = 0; j < 64; j++){
    if (address_test_read(actual_addr)!=j)
    {
      mismatches++;
    }
    //printf("Written data: 0x%x to address 0x%x \n", test_data[j], actual_addr);
    actual_addr = actual_addr+4;
  }
  return mismatches;
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

// Function for the Channel interrupt handlers
void DMAClearChIrq(uint32_t ch) {
  // Check the source of the interrupt and clear interrupts
  AdaStatType ST = AdaReadStatus(ch, SECURE);
  if (ST.STAT_DONE == 1) {
    AdaClearChDone(ch, SECURE);
  } else if (ST.STAT_ERR == 1) {
    AdaClearChError(ch, SECURE);
  } else if (ST.STAT_DISABLED == 1) {
    AdaClearChDisabled(ch, SECURE);
  } else if (ST.STAT_STOPPED == 1) {
    AdaClearChStopped(ch, SECURE);
  } else {
    printf("Unknown IRQ on CH%d!\n", ch);
  }
}

void DMA_Handler(void){ 
  __disable_irq();
  DMAClearChIrq(current_channel);
  dma_done_irq_occurred++;
  __enable_irq();
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

void delay(uint32_t t)
{
  int i;
  for (i=0;i<t;i++){
    __ISB();
    }
  return;
}
