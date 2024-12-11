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

 UART functions for retargetting

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


#define CLKFREQ    240000000
#define BAUDRATE   38400
#define BAUDCLKDIV (CLKFREQ / BAUDRATE)

void UartStdOutInit(void)
{
  CMSDK_UART2->CTRL    = 0x00;       // disable whie reprogramming
  CMSDK_UART2->BAUDDIV = BAUDCLKDIV; // (240MHz/BAUDRATE) in 16.4 format
  CMSDK_UART2->CTRL    = 0x01;       // TX, standard UART2
  CMSDK_USRT2->BAUDDIV =    3;       // (prescaler value)
  CMSDK_USRT2->CTRL    = 0x03;       // RX+TX, FT1248 USRT
  CMSDK_GPIO1->ALTFUNCSET = (1<<5);  // UART2 mapped to GP1[5,4]
  return;
}

void Uart2StdOutInit(void)
{
// ensure full character shift before reprogramming UART2
  CMSDK_DUALTIMER->Timer1Load = (11 * BAUDCLKDIV); // 10+1 x baud tick clock
  CMSDK_DUALTIMER->Timer1BGLoad = (10 * BAUDCLKDIV); // 10 x baud tick clock
  CMSDK_DUALTIMER->Timer1IntClr = 1;
  CMSDK_DUALTIMER->Timer1Control = 0xC3; // enable, periodic, 32-bit
  while ((CMSDK_DUALTIMER->Timer1RIS & 1)== 0) ; // wait until any UART character time
// reinitialize UART2
///  CMSDK_UART2->CTRL    = 0x00;       // disable whie reprogramming
///  CMSDK_UART2->BAUDDIV = BAUDCLKDIV; // (240MHz/BAUDRATE) in 16.4 format
///  CMSDK_UART2->CTRL    = 0x01;       // RX+TX, standard UART2
  CMSDK_GPIO1->ALTFUNCSET = (1<<5);  // UART2 mapped to GP1[5,4]
  CMSDK_USRT2->CTRL    = 0x00;       // RX+TX, FT1248 USRT disabled
  CMSDK_USRT2->BAUDDIV = 0x30;       // (prescaler low value)
  CMSDK_USRT2->CTRL    = 0x03;       // RX+TX, FT1248 USRT disabled
  return;
}

// Output a character
unsigned char UartPutc(unsigned char my_ch)
{
  if ((CMSDK_USRT2->CTRL & 1)==0) {
    while (CMSDK_UART2->STATE & 1); // Wait if Transmit Holding register full
    CMSDK_UART2->DATA = my_ch; // write to transmit holding register
    CMSDK_USRT2->DATA = my_ch; // (also write to transmit holding register)
  } else {
    while (CMSDK_USRT2->STATE & 1); // Wait if Transmit Holding register full
    CMSDK_USRT2->DATA = my_ch; // write to transmit holding register
  }
  return (my_ch);
}
// Get a character
unsigned char UartGetc(void)
{
  while (((CMSDK_UART2->STATE & 2)==0) & ((CMSDK_USRT2->STATE & 2)==0));
  if ((CMSDK_UART2->STATE & 2)==2) return (CMSDK_UART2->DATA);
  if ((CMSDK_USRT2->STATE & 2)==2) return (CMSDK_USRT2->DATA);
}

void UartEndSimulation(void)
{
  UartPutc((char) 0x4); // End of simulation
  while(1);
}

