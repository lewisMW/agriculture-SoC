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

// IO enable
extern unsigned int DataIO_enable(void);
extern unsigned int DataIO_init(void);

// Output ready check
extern unsigned char DataIO_putc_ready(void);

// Output busy check
extern unsigned int DataIO_putc_busy(void);

// Output a character
extern unsigned char DataIO_putc(unsigned char my_ch);

// DataIO string output
extern void DataIO_puts(unsigned char * mytext);

// Input ready check
extern unsigned int DataIO_getc_ready(void);

// Input busy check
extern unsigned int DataIO_getc_busy(void);

// Input a character
extern unsigned char DataIO_getc(void);

/* example usage

#include "CMSDK_CM0.h"
#include <string.h>
#include "uart_stdout.h"
#include <stdio.h>

#include "DataIO_functions.h"

int main(void) {
  unsigned char ch;
  char tx_buf[32];
  
  
  UartStdOutInit(); // console channel init
  printf("Data Channel CSV Reader/Writer (ASC binary -> Hex) tests\n");
  DataIO_init();  // datachannel init
    do { // rx process CSV entry
      if (DataIO_getc_ready()) {
        ch = DataIO_Getc();
        // ...
      }
    
    DataIO_puts((unsigned char*) tx_buf);
    
    do { // tx process
      if (DataIO_putc_ready()) {
        DataIO_putc(tx_buf[<i>]);
      }

*/


