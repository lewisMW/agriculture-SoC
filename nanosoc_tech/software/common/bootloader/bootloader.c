//-----------------------------------------------------------------------------
// customised Cortex-M0 'nanosoc' controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//-----------------------------------------------------------------------------
//

//
//  Simple boot loader
//  - display a message that the boot loader is running
//  - clear remap control (user flash accessible from address 0x0)
//  - execute program from user flash
//

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

void UartStdOutInit(void)
{
  CMSDK_UART2->CTRL    = 0x00; // re-init
  CMSDK_UART2->BAUDDIV = 6250; //(240MHz/384000) in 16.4 format
  CMSDK_UART2->CTRL    = 0x01; //TX, UART2
  CMSDK_USRT2->CTRL    = 0x00; //re-init
  CMSDK_USRT2->CTRL    = 0x03; //RX+TX, FT1248 USRT
  CMSDK_GPIO1->ALTFUNCSET = (1<<5);
  if ((CMSDK_USRT2->STATE & 1)==0) CMSDK_USRT2->DATA    = 0x23; // write 8'b01000011 / "#"
  if ((CMSDK_UART2->STATE & 1)==0) CMSDK_UART2->DATA    = 0x7e; // write 8'b01111110 / "~"
  return;
}

// Output a character
unsigned char UartPutc(unsigned char my_ch)
{
//  while ((CMSDK_UART2->STATE & 1)); // Wait if Transmit Holding register is full
//  CMSDK_UART2->DATA = my_ch; // write to transmit holding register
//  return (my_ch);
  while (((CMSDK_USRT2->STATE & 1)==1) && ((CMSDK_UART2->STATE & 1)==1)); // Wait if both Transmit Holding registers full
  if ((CMSDK_USRT2->STATE & 1)==0) CMSDK_USRT2->DATA = my_ch; // write to transmit holding register
  return (my_ch);
}
// Uart string output
void UartPuts(unsigned char * mytext)
{
  unsigned char CurrChar;
  do {
    CurrChar = *mytext;
    if (CurrChar != (char) 0x0) {
      UartPutc(CurrChar);  // Normal data
      }
    *mytext++;
  } while (CurrChar != 0);
  return;
}
#if defined ( __CC_ARM   )
/* ARM RVDS or Keil MDK */
__asm void FlashLoader_ASM(void)
{
   MOVS  R0,#0
   LDR   R1,[R0]     ; Get initial MSP value
   MOV   SP, R1
   LDR   R1,[R0, #4] ; Get initial PC value
   BX    R1
}

#else
/* ARM GCC */
void FlashLoader_ASM(void) __attribute__((naked));
void FlashLoader_ASM(void)
{
   __asm("    movs  r0,#0\n"
         "    ldr   r1,[r0]\n"     /* Get initial MSP value */
         "    mov   sp, r1\n"
         "    ldr   r1,[r0, #4]\n" /* Get initial PC value */
         "    bx    r1\n");
}

#endif

void FlashLoader(void)
{
  if (CMSDK_SYSCON->REMAP==0) {
    /* Remap is already cleared. Something has gone wrong.
    Likely that the user is trying to run bootloader as a test,
     which is not what this program is for.
    */
    UartPuts("!REMAP!\n");
    UartPutc(0x4); // Terminate simulation
    while (1);
    }
  UartPuts("REMAP->IMEM0\n"); // CMSDK boot loader\n");
  CMSDK_SYSCON->REMAP = 0;  // Clear remap
  __DSB();
  __ISB();

  FlashLoader_ASM();
};

int main (void)
{
  // UART init
  UartStdOutInit();

  UartPuts("\nSoCLabs NanoSoC ARM-CM0+ADP+FT1+U38400 20240110\n");
//  UartPuts("\nSoCLabs NanoSoC\n");
  FlashLoader();
  return 0;
}

