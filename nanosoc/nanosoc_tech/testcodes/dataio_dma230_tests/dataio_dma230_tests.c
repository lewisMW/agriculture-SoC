#include "CMSDK_CM0.h"
#include <string.h>
#include "uart_stdout.h"
#include <stdio.h>

#include "dataio_functions.h"

#include "dma_pl230_driver.h"
#include "dma_pl230_driver.c"

#define CSV_RECORD_LEN  (16+1)
#define CSV_RECORD_COUNT  (5)

static volatile dma_pl230_channel_data dataio_ip_chain[2];
static volatile dma_pl230_channel_data dataio_op_chain[2];

int  pl230_dma_detect(void);
int  ID_Check(const unsigned int id_array[], unsigned int offset);

// associate DMA channel numbers
#define DMA_CHAN_DATAIO_IP (3)
#define DMA_CHAN_DATAIO_OP (2)
#define DATA_UART  ((CMSDK_UART_TypeDef   *) CMSDK_UART1_BASE   )

void dataio_ip_driver_dma8( uint32_t nbytes, uint8_t *input)
{
    int c = DMA_CHAN_DATAIO_IP;

// program DMA transfers as single chains

    dataio_ip_chain[0].SrcEndPointer = DMA_PL230_PTR_END(&(DATA_UART->DATA),PL230_XFER_B,1);
    dataio_ip_chain[0].DstEndPointer = DMA_PL230_PTR_END(input,PL230_XFER_B,nbytes);
    dataio_ip_chain[0].Control       = DMA_PL230_CTRL_SRCFIX(PL230_CTRL_CYCLE_BASIC,PL230_XFER_B,nbytes,PL230_CTRL_RPWR_1);

    dma_pl230_table->Primary[c].SrcEndPointer = DMA_PL230_PTR_END(&(dataio_ip_chain[0].SrcEndPointer), PL230_XFER_W, (1*4));
    dma_pl230_table->Primary[c].DstEndPointer = DMA_PL230_PTR_END(&(dma_pl230_table->Alternate[c]), PL230_XFER_W, (1*4));
    dma_pl230_table->Primary[c].Control       = DMA_PL230_CTRL_DSTFIX(PL230_CTRL_CYCLE_DEV_CHAIN_PRI,PL230_XFER_W,(1*4),PL230_CTRL_RPWR_4);

    // enable DMA controller channels
    DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
    dma_pl230_init(1<<DMA_CHAN_DATAIO_IP);

    // test to ensure output DMA has started
    while (!(dma_pl230_channel_active(1<<DMA_CHAN_DATAIO_IP)))
      ;
    while (dma_pl230_channel_active(1<<DMA_CHAN_DATAIO_IP))
      ;
    DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
    dma_pl230_init(0); // none active
    return;
}

void dataio_op_driver_dma8( uint32_t nbytes, uint8_t *result)
{
    int c = DMA_CHAN_DATAIO_OP;
// program DMA transfers as single chains

    dataio_op_chain[0].SrcEndPointer = DMA_PL230_PTR_END(result,PL230_XFER_B,nbytes);
    dataio_op_chain[0].DstEndPointer = DMA_PL230_PTR_END(&(DATA_UART->DATA),PL230_XFER_B,1);
    dataio_op_chain[0].Control       = DMA_PL230_CTRL_DSTFIX(PL230_CTRL_CYCLE_BASIC,PL230_XFER_B,nbytes,PL230_CTRL_RPWR_1);

    dma_pl230_table->Primary[c].SrcEndPointer = DMA_PL230_PTR_END(&(dataio_op_chain[0].SrcEndPointer), PL230_XFER_W,(1*4));
    dma_pl230_table->Primary[c].DstEndPointer = DMA_PL230_PTR_END(&(dma_pl230_table->Alternate[c]), PL230_XFER_W,(1*4));
    dma_pl230_table->Primary[c].Control       = DMA_PL230_CTRL_DSTFIX(PL230_CTRL_CYCLE_DEV_CHAIN_PRI,PL230_XFER_W,(1*4),PL230_CTRL_RPWR_4);

    // enable DMA controller channels
    DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
    dma_pl230_init(1<<DMA_CHAN_DATAIO_OP);

    // test to ensure output DMA has started
    while (!(dma_pl230_channel_active(1<<DMA_CHAN_DATAIO_OP)))
      ;
    while (dma_pl230_channel_active(1<<DMA_CHAN_DATAIO_OP))
      ;
    DMA_PL230_DMAC->DMA_CFG = 0; /* Disable DMA controller for initialization */
    dma_pl230_init(0); // none active
    return;
}


int main(void) {
  unsigned char ch;
  char         rx_buf[20];
  char         tx_buf[20];
  char *       p;
  unsigned int rx_record_len;
  unsigned int rx_record_count;
  unsigned int rx_count;
  unsigned int value;
  unsigned int end_of_record ;
  unsigned int end_of_data ;

  UartStdOutInit();
  printf("Data Channel CSV Reader/Writer using DMA230 (ASC binary -> Hex) tests\n");

// Reset DMA table structures
  dma_pl230_data_struct_init(); // initialize

  DataIO_enable();
  CMSDK_GPIO1->DATAOUT |= 0x0c; // enable DRQ signals
  end_of_data = 0;
  rx_record_len = CSV_RECORD_LEN - 1; // due to soft reset in testbench!
  rx_record_count = CSV_RECORD_COUNT; // due to soft reset in testbench!

  do { // record at a time
    dataio_ip_driver_dma8(rx_record_len, (uint8_t *)rx_buf);
    rx_count = 0;
    value    = 0;
    end_of_record = 0;
    rx_record_len = CSV_RECORD_LEN;
    p = rx_buf;
    do { // parse process CSV entry
        ch = *p++;
        if  (ch == '0') { value = (value << 1);      rx_count++; }
        if  (ch == '1') { value = (value << 1) + 1;  rx_count++; }
        if  (ch == ',')  end_of_record = 1;
        if ((ch == '\n') || (ch == '\r')) end_of_record = 1;
//        if ((ch == '\n') || (ch == '\r')) end_of_data = (rx_count == 0) ? 1 : 0;
    } while ((rx_count <= 16) && (end_of_record == 0) );
    if (ch == '\n') end_of_data = (rx_record_count-- > 1) ? 0 : 1 ;
    if (rx_count > 0) {
      if (ch == ',')
        printf(","); // ',' per CSV record
      else
        printf(".\n"); // newline delimiter

      if (ch == ',')
        sprintf(tx_buf,"0x%04x,", value);
      else
        sprintf(tx_buf,"0x%04x\n", value);

      tx_buf[8]=0; // string zero terminate
      dataio_op_driver_dma8(7, (uint8_t *)tx_buf);
    }
  } while (end_of_data == 0); // outer record loop

  printf("** DATA FILE PROCESSING ** TEST PASSED **\n");

  UartEndSimulation();
  return 0;

}
