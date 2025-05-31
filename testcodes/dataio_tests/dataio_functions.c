//-----------------------------------------------------------------------------
// customised Cortex-M0 'nanosoc' controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2025 SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

#include "CMSDK_CM0.h"

#define DATA_UART  ((CMSDK_UART_TypeDef   *) CMSDK_UART1_BASE   )

#define UART_STATE_TXFULL CMSDK_UART_STATE_TXBF_Msk
#define UART_STATE_RXFULL CMSDK_UART_STATE_RXBF_Msk

#define UART_CTRL_TXEN         CMSDK_UART_CTRL_TXEN_Msk
#define UART_CTRL_RXEN         CMSDK_UART_CTRL_RXEN_Msk
#define UART_CTRL_TXRXEN       (CMSDK_UART_CTRL_TXEN_Msk + CMSDK_UART_CTRL_RXEN_Msk)
#define UART_CTRL_TXIRQEN      (CMSDK_UART_CTRL_TXIRQEN_Msk + UART_CTRL_TXRXEN)
#define UART_CTRL_RXIRQEN      (CMSDK_UART_CTRL_RXIRQEN_Msk + UART_CTRL_TXRXEN)


unsigned int DataIO_enable(void) {
//  DATA_UART->CTRL    = 0x00;             // re-initialise/flush
  DATA_UART->CTRL    = UART_CTRL_TXRXEN; // enble TX and RX
  return(0);
}

unsigned int DataIO_init(void) {
  DATA_UART->CTRL    = 0x00;             // re-initialise/flush
  DATA_UART->CTRL    = UART_CTRL_TXRXEN; // enble TX and RX
  return(0);
}

// Output ready check
unsigned int DataIO_putc_ready(void) {
  return((DATA_UART->STATE & UART_STATE_TXFULL) == 0); // ready if TXBUF empty
}

// Output Busy check
unsigned int DataIO_putc_busy(void) {
  return((DATA_UART->STATE & UART_STATE_TXFULL) != 0); // busy if TXBUF full
}

// Output a character
unsigned char DataIO_putc(unsigned char my_ch) {
  while (DataIO_putc_busy()) ; // busy wait
  DATA_UART->DATA = my_ch; // output the character
  return (my_ch);
}


// Output a (zero-terminated) string
void DataIO_puts(unsigned char * mytext) {
  unsigned char string_ch;
  do {
    string_ch = *mytext;
    if (string_ch != (char) 0x0) {
      DataIO_putc(string_ch);  // Normal data
      }
    *mytext++;
  } while (string_ch != 0);
  return;
}

// Input ready check
unsigned int DataIO_getc_ready(void) {
  return((DATA_UART->STATE & UART_STATE_RXFULL) != 0); // ready if RXBUF set
}


// Input Busy check
unsigned int DataIO_getc_busy(void) {
  return((DATA_UART->STATE & UART_STATE_RXFULL) == 0); // busy if RXBUF not set
}

// Input a character
unsigned char DataIO_getc(void) {
  while (DataIO_getc_busy()) ; // busy wait
  return (DATA_UART->DATA);
}
