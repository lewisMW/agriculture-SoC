#include "CMSDK_CM0.h"
#include <string.h>
#include "uart_stdout.h"
#include <stdio.h>

#include "dataio_functions.h"


int main(void) {
  unsigned char ch;
  char         tx_buf[20];
  unsigned int tx_count;
  unsigned int rx_count;
  unsigned int value;
  unsigned int end_of_record ;
  unsigned int end_of_data ;
////  FILE *datain, *dataout;
  
  UartStdOutInit();
  printf("Data Channel CSV Reader/Writer (ASC binary -> Hex) tests\n");

  DataIO_init();

  end_of_data = 0;
  do { // record at a time 
    tx_count = 0;
    rx_count = 0;
    value    = 0;
    end_of_record = 0;
    do { // rx process CSV entry
      if (DataIO_getc_ready()) {
        ch = DataIO_getc();
        if  (ch == '0') { value = (value << 1);      rx_count++; }
        if  (ch == '1') { value = (value << 1) + 1;  rx_count++; }
        if  (ch == ',')  end_of_record = 1;
        if ((ch == '\n') || (ch == '\r')) end_of_record = 1;
        if ((ch == '\n') || (ch == '\r')) end_of_data = (rx_count == 0) ? 1 : 0;
        }
    } while ((rx_count <= 16) && (end_of_record == 0));
    if (rx_count > 0) {
      if (ch == ',')
        printf(","); // ',' per CSV record
      else
        printf(".\n"); // newline delimiter

      if (ch == ',')
        sprintf(tx_buf,"%04x,", value);
      else
        sprintf(tx_buf,"%04x\n", value);

      tx_buf[5]=0; // string zero terminate
      
      DataIO_puts((unsigned char*) tx_buf);
//      do { /*tx process */
//        if (DataIO_putc_ready()) {
//          DataIO_putc(tx_buf[tx_count++]);
//         }
//      } while (tx_count < 5);
    }
  } while (end_of_data == 0); // outer record loop
  
  printf("** DATA FILE PROCESSING ** TEST PASSED **\n");
  
////  dataout = fopen("dataout","w");
////  printf("file handle =,%08x\n",dataout);
////  fputc(127, dataout);
////  fclose(dataout);
  
  UartEndSimulation();
  return 0;

}
