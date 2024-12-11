#include <stdio.h>
#include <string.h>
#include "dma_pl230_driver.h"

#define DEBUG_PRINTF(...) do {} while(0); 
//#define cpu_to_be32(__x) __x
//#define be32_to_cpu(__x) __x

#ifdef __cplusplus
extern "C" {
#endif

static int g_dma_pl230_initialised = 0;

static dma_pl230_data_structure priv_dma __attribute__((aligned(256)));
//
dma_pl230_data_structure *dma_pl230_table = &priv_dma; 

/* --------------------------------------------------------------- */
/*  Initialize DMA data structure                                  */
/* --------------------------------------------------------------- */
void dma_pl230_data_struct_init(void)
{
  int          i;   /* loop counter */

//  printf ("dma structure block address = %x\n", dma_pl230_table);
  for (i=0; i<MAX_NUM_OF_DMA_CHANNELS; i++) {
    dma_pl230_table->Primary[i].SrcEndPointer   = 0;
    dma_pl230_table->Primary[i].DstEndPointer   = 0;
    dma_pl230_table->Primary[i].Control         = 0;
    dma_pl230_table->Alternate[i].SrcEndPointer = 0;
    dma_pl230_table->Alternate[i].DstEndPointer = 0;
    dma_pl230_table->Alternate[i].Control       = 0;
    }
  g_dma_pl230_initialised = 1;
  return;
}

void dma_pl230_data_struct_init_dbg(void)
{
  int          i;   /* loop counter */
  unsigned int ptr;

  int          ch_num;         /* number of channels */
  unsigned int blksize;        /* Size of DMA data structure in bytes */
  unsigned int blkmask;        /* address mask */


  ch_num  = (((DMA_PL230_DMAC->DMA_STATUS) >> 16) & 0x1F)+1;
  blksize = ch_num * 32;
  if      (ch_num > 16) blkmask = 0x3FF; /* 17 to 32 */
  else if (ch_num > 8)  blkmask = 0x1FF; /*  9 to 16 */
  else if (ch_num > 4)  blkmask = 0x0FF; /*  5 to 8 */
  else if (ch_num > 2)  blkmask = 0x07F; /*  3 to 4 */
  else if (ch_num > 1)  blkmask = 0x03F; /*       2 */
  else                  blkmask = 0x01F; /*       1 */


  /* Create DMA data structure in RAM after stack
  In the linker script, a 1KB memory stack above stack is reserved
  so we can use this space for putting the DMA data structure.
  */

//  ptr     = HW32_REG(0);                     /* Read Top of Stack */
  ptr     = (0x80000000); // force for now as no reserved RAM available
  
  /* the DMA data structure must be aligned to the size of the data structure */
  if ((ptr & blkmask) != 0x0)
    ptr     = (ptr + blksize) & ~blkmask;

///  if ((ptr + blksize) > (RAM_ADDRESS_MAX + 1)) {
///    puts ("ERROR : Not enough RAM space for DMA data structure.");
///    UartEndSimulation();
///    }

  /* Set pointer to the reserved space */
  dma_pl230_table = (dma_pl230_data_structure *) ptr;
  ptr = (unsigned long) &(dma_pl230_table->Primary[0].SrcEndPointer);

  printf ("dma structure block address = %x\n", ptr);

  for (i=0; i<MAX_NUM_OF_DMA_CHANNELS; i++) {
    dma_pl230_table->Primary[i].SrcEndPointer   = 0;
    dma_pl230_table->Primary[i].DstEndPointer   = 0;
    dma_pl230_table->Primary[i].Control         = 0;
    dma_pl230_table->Alternate[i].SrcEndPointer = 0;
    dma_pl230_table->Alternate[i].DstEndPointer = 0;
    dma_pl230_table->Alternate[i].Control       = 0;
    }
  g_dma_pl230_initialised = 1;
  return;
}
/* --------------------------------------------------------------- */
/*  Initialize DMA PL230                                           */
/* --------------------------------------------------------------- */
void dma_pl230_init_dbg(unsigned int chan_mask)
{
  unsigned int current_state;
  puts ("Initialize PL230");
  current_state = DMA_PL230_DMAC->DMA_STATUS;
  printf ("- # of channels allowed : %d\n",(((current_state) >> 16) & 0x1F)+1);
  /* Debugging printfs: */
  printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));
  printf ("- Current master enable : %x\n",(((current_state) >> 0)  & 0x1));

  /* Wait until current DMA complete */
  current_state = (DMA_PL230_DMAC->DMA_STATUS >> 4)  & 0xF;
  if (!((current_state==0) || (current_state==0x8) || (current_state==0x9))) {
    puts ("- wait for DMA IDLE/STALLED/DONE");
    current_state = (DMA_PL230_DMAC->DMA_STATUS >> 4)  & 0xF;
    printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));

    }
  while (!((current_state==0) || (current_state==0x8) || (current_state==0x9))){
    /* Wait if not IDLE/STALLED/DONE */
    current_state = (DMA_PL230_DMAC->DMA_STATUS >> 4)  & 0xF;
    printf ("- Current status        : %x\n",(((current_state) >> 4)  & 0xF));
    }
  DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
  DMA_PL230_DMAC->CTRL_BASE_PTR = (unsigned long) &(dma_pl230_table->Primary->SrcEndPointer);
                           /* Set DMA data structure address */
  DMA_PL230_DMAC->CHNL_ENABLE_CLR = 0xFFFFFFFF; /* Disable all channels */
  DMA_PL230_DMAC->CHNL_PRI_ALT_CLR = ((1<<MAX_NUM_OF_DMA_CHANNELS)-1); /* Disable all alt channels */
  DMA_PL230_DMAC->CHNL_ENABLE_SET = (chan_mask & ((1<<MAX_NUM_OF_DMA_CHANNELS)-1)); /* Enable channel */
  DMA_PL230_DMAC->CHNL_USEBURST_SET = (chan_mask & ((1<<MAX_NUM_OF_DMA_CHANNELS)-1)); /* Enable bursts */
  if (chan_mask)
    DMA_PL230_DMAC->DMA_CFG = 1;              /* Enable DMA controller if enabled channel*/
  return;
}

void dma_pl230_init(unsigned int chan_mask)
{
  unsigned int current_state;
  if (g_dma_pl230_initialised ==0)
    dma_pl230_data_struct_init();
  /* Wait until current DMA complete */
  current_state = (DMA_PL230_DMAC->DMA_STATUS >> 4)  & 0xF;
  while (!((current_state==0) || (current_state==0x8) || (current_state==0x9))){
    /* Wait if not IDLE/STALLED/DONE */
    puts ("- wait for DMA IDLE/STALLED/DONE");
    current_state = (DMA_PL230_DMAC->DMA_STATUS >> 4)  & 0xF;
    }
  DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
  DMA_PL230_DMAC->CTRL_BASE_PTR = (unsigned long) &(dma_pl230_table->Primary->SrcEndPointer);
                           /* Set DMA data structure address */
  DMA_PL230_DMAC->CHNL_ENABLE_CLR  = ((1<<MAX_NUM_OF_DMA_CHANNELS)-1); /* Disable all channels */
  DMA_PL230_DMAC->CHNL_PRI_ALT_CLR = ((1<<MAX_NUM_OF_DMA_CHANNELS)-1); /* Disable all alt channels */
  DMA_PL230_DMAC->CHNL_ENABLE_SET  = (chan_mask & ((1<<MAX_NUM_OF_DMA_CHANNELS)-1)); /* Enable channel */
  DMA_PL230_DMAC->CHNL_USEBURST_SET = (chan_mask & ((1<<MAX_NUM_OF_DMA_CHANNELS)-1)); /* Enable bursts */
  g_dma_pl230_initialised = 2;
  if (chan_mask)
    DMA_PL230_DMAC->DMA_CFG = 1;              /* Enable DMA controller if enabled channel*/
  return;
}

unsigned int dma_pl230_channel_active(unsigned int chan_mask)
{
  return(DMA_PL230_DMAC->CHNL_ENABLE_SET & chan_mask & ((1<<MAX_NUM_OF_DMA_CHANNELS)-1)); /* Enabled channels */
}

#ifdef __cplusplus
}
#endif
