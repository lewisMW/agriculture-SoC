#include "CMSDK_CM0.h"
#include <string.h>
#include "uart_stdout.h"
#include <stdio.h>

volatile int stdin_irq_occurred;

int main(void) {
 unsigned char ch;
    UartStdOutInit();
    printf("ADP dummy test\n");
    while ((ch=UartGetc()) !=  'X')
        printf("'%c'\n", ch);
    printf("** ADP TEST PASSED **\n");
    UartEndSimulation();
    return 0;

}
	
/* --------------------------------------------------------------- */
/*  Interrupt handlers                                         */
/* --------------------------------------------------------------- */


void EXP0_Handler(void)
{
  // AES128 interrupt is caused by Key buffer empty IRQ
  stdin_irq_occurred ++;
//  AES128->IRQ_MSK_CLR = AES128_KEY_REQ_BIT;
  if (stdin_irq_occurred==0) {
    puts ("ERROR : Unexpected STDIN interrupt occurred.\n");
    UartEndSimulation();
    while (1);
    }
}
