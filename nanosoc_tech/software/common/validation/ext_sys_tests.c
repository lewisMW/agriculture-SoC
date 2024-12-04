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
  A simple test to check the operation of components instantiated in the
  extended example subsystem.
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

#if defined ( __CC_ARM   )
__asm void          address_test_write(unsigned int addr, unsigned int wdata);
__asm unsigned int  address_test_read(unsigned int addr);
#else
      void          address_test_write(unsigned int addr, unsigned int wdata);
      unsigned int  address_test_read(unsigned int addr);
#endif
void                HardFault_Handler_c(unsigned int * hardfault_args, unsigned lr_value);

/* Macros for word, half word and byte */
#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))
#define HW16_REG(ADDRESS)  (*((volatile unsigned short *)(ADDRESS)))
#define HW8_REG(ADDRESS)   (*((volatile unsigned char  *)(ADDRESS)))

#define ADDR_BASE_APB4_EG_SLAVE_1 0x50000000
#define ADDR_BASE_APB4_EG_SLAVE_2 0x52000000
#define ADDR_BASE_APB3_EG_SLAVE   0x50001000
#define ADDR_BASE_AHB_EG_SLAVE    0x50020000
#define ADDR_BASE_AHB_TB_SLAVE_1  0x50002000
#define ADDR_BASE_AHB_TB_SLAVE_2  0x51010000
#define ADDR_BASE_AHB_TB_SLAVE_3  0x52002000

/* Function definition */
int check_apb4_eg_slave(unsigned long base_addr);
int check_apb3_eg_slave(unsigned long base_addr);
int check_ahb_eg_slave(unsigned long base_addr);
int check_ahb_tb_slave(unsigned long base_addr);
int check_default_slave(unsigned long base_addr);

/* Global variables */
volatile int hardfault_occurred;
volatile int hardfault_expected;
volatile int temp_data;
volatile int probe_ext_eg_sys=0; /* Set to 1 for memory map probing */

// -----------------------------------------------------------
// Start of main program
// -----------------------------------------------------------

int main (void)
{
  int result=0;
  unsigned int dummy; /* dummy variable for memory probing */

  // UART init
  UartStdOutInit();

  // Test banner message and revision number
  puts("\nCortex Microcontroller System Design Kit - Extended Subsystem Test - revision $Revision: 371321 $\n");

  probe_ext_eg_sys = 1; /* Probe to see if extended subsystem is included */
  /* If extended subsystem is included, the following read will be carried out,
  otherwise an error response will be received and enter hard fault */
  dummy = HW32_REG(ADDR_BASE_APB4_EG_SLAVE_1 + 0xFE0);

  probe_ext_eg_sys = 0; /* Example system exist, continue operation */

  temp_data=0;

  // Test access to APB4 Example Slave
  result |= check_apb4_eg_slave(ADDR_BASE_APB4_EG_SLAVE_1);
  result |= check_apb4_eg_slave(ADDR_BASE_APB4_EG_SLAVE_2);

  // Test access to APB3 Example Slave
  result |= check_apb3_eg_slave(ADDR_BASE_APB3_EG_SLAVE);

  // Test access to AHB Example Slave
  result |= check_ahb_eg_slave(ADDR_BASE_AHB_EG_SLAVE);

  // Test access to AHB Trickbox Slave
  result |= check_ahb_tb_slave(ADDR_BASE_AHB_TB_SLAVE_1);
  result |= check_ahb_tb_slave(ADDR_BASE_AHB_TB_SLAVE_3);

  // Test access to Default slave
  puts ("Checking AHB Default slave");
  result |= check_default_slave(0x52020000);
  result |= check_default_slave(0x68000000);

  /* clean up */
  hardfault_expected = 0;

  if (result==0) {
    printf ("\n** TEST PASSED **\n");
  } else {
    printf ("\n** TEST FAILED **, Error code = (0x%x)\n", result);
  }
  UartEndSimulation();
  return 0;
}
// -----------------------------------------------------------
// Check the access to APB4 example slave
// -----------------------------------------------------------
int check_apb4_eg_slave(unsigned long base_addr)
{
  const char apb4_id[12] = {0x04, 0x00, 0x00, 0x00,
                            0x19, 0xB8, 0x1B, 0x00,
                            0x0D, 0xF0, 0x05, 0xB1};
  int return_val=0;
  int err_code=0;
  int i;

  puts ("Checking APB4 Example slave");
  // -------------------------
  puts ("- check ID values");
  for (i=0; i<12; i++) {
    if (HW32_REG(base_addr + 0xFD0 + 4*i) != apb4_id[i]) {
      printf ("    ID [%d] ERROR : expected %x, actual %x\n", i, apb4_id[i], HW32_REG(base_addr + 0xFD0 + 4*i));
      err_code = err_code | 0x1;
      }
    }
  // -------------------------
  puts ("- initial data values");
  for (i=0; i<4; i++) {
    printf ("    Data[%d] = %x\n", i, HW32_REG(base_addr + 4*i));
    }

  puts ("- check R/W in word size");

  HW32_REG(base_addr      ) = 0x12345678;
  HW32_REG(base_addr +0x04) = 0x55CC33AA;
  HW32_REG(base_addr +0x08) = 0xFF008765;
  HW32_REG(base_addr +0x0C) = 0x99AABCDE;

  if (HW32_REG(base_addr      ) != 0x12345678) {err_code |= (1<<2); puts("    ERROR @ Data0");}
  if (HW32_REG(base_addr +0x04) != 0x55CC33AA) {err_code |= (1<<2); puts("    ERROR @ Data1");}
  if (HW32_REG(base_addr +0x08) != 0xFF008765) {err_code |= (1<<2); puts("    ERROR @ Data2");}
  if (HW32_REG(base_addr +0x0C) != 0x99AABCDE) {err_code |= (1<<2); puts("    ERROR @ Data3");}


  puts ("- check R/W in halfword size");

  HW16_REG(base_addr      ) = 0xA987;
  HW16_REG(base_addr +0x02) = 0xEDCB;
  HW16_REG(base_addr +0x04) = 0xCC55;
  HW16_REG(base_addr +0x06) = 0xAA33;
  HW16_REG(base_addr +0x08) = 0x789A;
  HW16_REG(base_addr +0x0A) = 0x00FF;
  HW16_REG(base_addr +0x0C) = 0x4321;
  HW16_REG(base_addr +0x0E) = 0x6655;

  if (HW16_REG(base_addr      ) != 0xA987) {err_code |= (1<<3); puts("    ERROR @ Data0");}
  if (HW16_REG(base_addr +0x02) != 0xEDCB) {err_code |= (1<<3); puts("    ERROR @ Data1");}
  if (HW16_REG(base_addr +0x04) != 0xCC55) {err_code |= (1<<3); puts("    ERROR @ Data2");}
  if (HW16_REG(base_addr +0x06) != 0xAA33) {err_code |= (1<<3); puts("    ERROR @ Data3");}
  if (HW16_REG(base_addr +0x08) != 0x789A) {err_code |= (1<<3); puts("    ERROR @ Data4");}
  if (HW16_REG(base_addr +0x0A) != 0x00FF) {err_code |= (1<<3); puts("    ERROR @ Data5");}
  if (HW16_REG(base_addr +0x0C) != 0x4321) {err_code |= (1<<3); puts("    ERROR @ Data6");}
  if (HW16_REG(base_addr +0x0E) != 0x6655) {err_code |= (1<<3); puts("    ERROR @ Data7");}

  puts ("- check R/W in byte size");

  HW8_REG(base_addr      ) = 0xA9;  // swap upper and lower byte
  HW8_REG(base_addr +0x01) = 0x87;
  HW8_REG(base_addr +0x02) = 0xED;
  HW8_REG(base_addr +0x03) = 0xCB;
  HW8_REG(base_addr +0x04) = 0xCC;
  HW8_REG(base_addr +0x05) = 0x55;
  HW8_REG(base_addr +0x06) = 0xAA;
  HW8_REG(base_addr +0x07) = 0x33;
  HW8_REG(base_addr +0x08) = 0x78;
  HW8_REG(base_addr +0x09) = 0x9A;
  HW8_REG(base_addr +0x0A) = 0x00;
  HW8_REG(base_addr +0x0B) = 0xFF;
  HW8_REG(base_addr +0x0C) = 0x43;
  HW8_REG(base_addr +0x0D) = 0x21;
  HW8_REG(base_addr +0x0E) = 0x66;
  HW8_REG(base_addr +0x0F) = 0x55;

  if (HW8_REG(base_addr      ) != 0xA9) {err_code |= (1<<4); puts("    ERROR @ Data0");}
  if (HW8_REG(base_addr +0x01) != 0x87) {err_code |= (1<<4); puts("    ERROR @ Data1");}
  if (HW8_REG(base_addr +0x02) != 0xED) {err_code |= (1<<4); puts("    ERROR @ Data2");}
  if (HW8_REG(base_addr +0x03) != 0xCB) {err_code |= (1<<4); puts("    ERROR @ Data3");}
  if (HW8_REG(base_addr +0x04) != 0xCC) {err_code |= (1<<4); puts("    ERROR @ Data4");}
  if (HW8_REG(base_addr +0x05) != 0x55) {err_code |= (1<<4); puts("    ERROR @ Data5");}
  if (HW8_REG(base_addr +0x06) != 0xAA) {err_code |= (1<<4); puts("    ERROR @ Data6");}
  if (HW8_REG(base_addr +0x07) != 0x33) {err_code |= (1<<4); puts("    ERROR @ Data7");}
  if (HW8_REG(base_addr +0x08) != 0x78) {err_code |= (1<<4); puts("    ERROR @ Data8");}
  if (HW8_REG(base_addr +0x09) != 0x9A) {err_code |= (1<<4); puts("    ERROR @ Data9");}
  if (HW8_REG(base_addr +0x0A) != 0x00) {err_code |= (1<<4); puts("    ERROR @ DataA");}
  if (HW8_REG(base_addr +0x0B) != 0xFF) {err_code |= (1<<4); puts("    ERROR @ DataB");}
  if (HW8_REG(base_addr +0x0C) != 0x43) {err_code |= (1<<4); puts("    ERROR @ DataC");}
  if (HW8_REG(base_addr +0x0D) != 0x21) {err_code |= (1<<4); puts("    ERROR @ DataD");}
  if (HW8_REG(base_addr +0x0E) != 0x66) {err_code |= (1<<4); puts("    ERROR @ DataE");}
  if (HW8_REG(base_addr +0x0F) != 0x55) {err_code |= (1<<4); puts("    ERROR @ DataF");}

  if (err_code != 0) {
    printf ("ERROR : APB4 eg slave access failed (0x%x)\n", err_code);
    return_val=1;

    err_code = 0;
    }
  return(return_val);

}
// -----------------------------------------------------------
// Check the access to APB3 example slave
// -----------------------------------------------------------
int check_apb3_eg_slave(unsigned long base_addr)
{
  const char apb3_id[12] = {0x04, 0x00, 0x00, 0x00,
                            0x18, 0xB8, 0x1B, 0x00,
                            0x0D, 0xF0, 0x05, 0xB1};
  int return_val=0;
  int err_code=0;
  int i;

  puts ("Checking APB3 Example slave");
  // -------------------------
  puts ("- check ID values");
  for (i=0; i<12; i++) {
    if (HW32_REG(base_addr + 0xFD0 + 4*i) != apb3_id[i]) {
      printf ("    ID [%d] ERROR : expected %x, actual %x\n", i, apb3_id[i], HW32_REG(base_addr + 0xFD0 + 4*i));
      err_code = err_code | 0x1;
      }
    }
  // -------------------------
  puts ("- initial data values");
  for (i=0; i<4; i++) {
    printf ("    Data[%d] = %x\n", i, HW32_REG(ADDR_BASE_APB3_EG_SLAVE + 4*i));
    }

  puts ("- check R/W in word size");

  HW32_REG(base_addr      ) = 0x12345678;
  HW32_REG(base_addr +0x04) = 0x55CC33AA;
  HW32_REG(base_addr +0x08) = 0xFF008765;
  HW32_REG(base_addr +0x0C) = 0x99AABCDE;

  if (HW32_REG(base_addr      ) != 0x12345678) {err_code |= (1<<2); puts("    ERROR @ Data0");}
  if (HW32_REG(base_addr +0x04) != 0x55CC33AA) {err_code |= (1<<2); puts("    ERROR @ Data1");}
  if (HW32_REG(base_addr +0x08) != 0xFF008765) {err_code |= (1<<2); puts("    ERROR @ Data2");}
  if (HW32_REG(base_addr +0x0C) != 0x99AABCDE) {err_code |= (1<<2); puts("    ERROR @ Data3");}



  if (err_code != 0) {
    printf ("ERROR : APB3 eg slave access failed (0x%x)\n", err_code);
    return_val=1;
    err_code = 0;
    }
  return(return_val);

}
// -----------------------------------------------------------
// Check the access to AHB example slave
// -----------------------------------------------------------
int check_ahb_eg_slave(unsigned long base_addr)
{
  const char ahb_id[12] = {0x04, 0x00, 0x00, 0x00,
                           0x17, 0xB8, 0x1B, 0x00,
                           0x0D, 0xF0, 0x05, 0xB1};
  int return_val=0;
  int err_code=0;
  int i;

  puts ("Checking AHB Example slave");
  // -------------------------
  puts ("- check ID values");
  for (i=0; i<12; i++) {
    if (HW32_REG(base_addr + 0xFD0 + 4*i) != ahb_id[i]) {
      printf ("    ID [%d] ERROR : expected %x, actual %x\n", i, ahb_id[i], HW32_REG(base_addr + 0xFD0 + 4*i));
      err_code = err_code | 0x1;
      }
    }
  // -------------------------
  puts ("- initial data values");
  for (i=0; i<4; i++) {
    printf ("    Data[%d] = %x\n", i, HW32_REG(ADDR_BASE_AHB_EG_SLAVE + 4*i));
    }

  puts ("- check R/W in word size");

  HW32_REG(base_addr      ) = 0x12345678;
  HW32_REG(base_addr +0x04) = 0x55CC33AA;
  HW32_REG(base_addr +0x08) = 0xFF008765;
  HW32_REG(base_addr +0x0C) = 0x99AABCDE;

  if (HW32_REG(base_addr      ) != 0x12345678) {err_code |= (1<<2); puts("    ERROR @ Data0");}
  if (HW32_REG(base_addr +0x04) != 0x55CC33AA) {err_code |= (1<<2); puts("    ERROR @ Data1");}
  if (HW32_REG(base_addr +0x08) != 0xFF008765) {err_code |= (1<<2); puts("    ERROR @ Data2");}
  if (HW32_REG(base_addr +0x0C) != 0x99AABCDE) {err_code |= (1<<2); puts("    ERROR @ Data3");}


  puts ("- check R/W in halfword size");

  HW16_REG(base_addr      ) = 0xA987;
  HW16_REG(base_addr +0x02) = 0xEDCB;
  HW16_REG(base_addr +0x04) = 0xCC55;
  HW16_REG(base_addr +0x06) = 0xAA33;
  HW16_REG(base_addr +0x08) = 0x789A;
  HW16_REG(base_addr +0x0A) = 0x00FF;
  HW16_REG(base_addr +0x0C) = 0x4321;
  HW16_REG(base_addr +0x0E) = 0x6655;

  if (HW16_REG(base_addr      ) != 0xA987) {err_code |= (1<<3); puts("     ERROR @ Data0");}
  if (HW16_REG(base_addr +0x02) != 0xEDCB) {err_code |= (1<<3); puts("     ERROR @ Data1");}
  if (HW16_REG(base_addr +0x04) != 0xCC55) {err_code |= (1<<3); puts("     ERROR @ Data2");}
  if (HW16_REG(base_addr +0x06) != 0xAA33) {err_code |= (1<<3); puts("     ERROR @ Data3");}
  if (HW16_REG(base_addr +0x08) != 0x789A) {err_code |= (1<<3); puts("     ERROR @ Data4");}
  if (HW16_REG(base_addr +0x0A) != 0x00FF) {err_code |= (1<<3); puts("     ERROR @ Data5");}
  if (HW16_REG(base_addr +0x0C) != 0x4321) {err_code |= (1<<3); puts("     ERROR @ Data6");}
  if (HW16_REG(base_addr +0x0E) != 0x6655) {err_code |= (1<<3); puts("     ERROR @ Data7");}

  puts ("- check R/W in byte size");

  HW8_REG(base_addr     ) = 0xA9;  // swap upper and lower byte
  HW8_REG(base_addr +0x01) = 0x87;
  HW8_REG(base_addr +0x02) = 0xED;
  HW8_REG(base_addr +0x03) = 0xCB;
  HW8_REG(base_addr +0x04) = 0xCC;
  HW8_REG(base_addr +0x05) = 0x55;
  HW8_REG(base_addr +0x06) = 0xAA;
  HW8_REG(base_addr +0x07) = 0x33;
  HW8_REG(base_addr +0x08) = 0x78;
  HW8_REG(base_addr +0x09) = 0x9A;
  HW8_REG(base_addr +0x0A) = 0x00;
  HW8_REG(base_addr +0x0B) = 0xFF;
  HW8_REG(base_addr +0x0C) = 0x43;
  HW8_REG(base_addr +0x0D) = 0x21;
  HW8_REG(base_addr +0x0E) = 0x66;
  HW8_REG(base_addr +0x0F) = 0x55;

  if (HW8_REG(base_addr      ) != 0xA9) {err_code |= (1<<4); puts("    ERROR @ Data0");}
  if (HW8_REG(base_addr +0x01) != 0x87) {err_code |= (1<<4); puts("    ERROR @ Data1");}
  if (HW8_REG(base_addr +0x02) != 0xED) {err_code |= (1<<4); puts("    ERROR @ Data2");}
  if (HW8_REG(base_addr +0x03) != 0xCB) {err_code |= (1<<4); puts("    ERROR @ Data3");}
  if (HW8_REG(base_addr +0x04) != 0xCC) {err_code |= (1<<4); puts("    ERROR @ Data4");}
  if (HW8_REG(base_addr +0x05) != 0x55) {err_code |= (1<<4); puts("    ERROR @ Data5");}
  if (HW8_REG(base_addr +0x06) != 0xAA) {err_code |= (1<<4); puts("    ERROR @ Data6");}
  if (HW8_REG(base_addr +0x07) != 0x33) {err_code |= (1<<4); puts("    ERROR @ Data7");}
  if (HW8_REG(base_addr +0x08) != 0x78) {err_code |= (1<<4); puts("    ERROR @ Data8");}
  if (HW8_REG(base_addr +0x09) != 0x9A) {err_code |= (1<<4); puts("    ERROR @ Data9");}
  if (HW8_REG(base_addr +0x0A) != 0x00) {err_code |= (1<<4); puts("    ERROR @ DataA");}
  if (HW8_REG(base_addr +0x0B) != 0xFF) {err_code |= (1<<4); puts("    ERROR @ DataB");}
  if (HW8_REG(base_addr +0x0C) != 0x43) {err_code |= (1<<4); puts("    ERROR @ DataC");}
  if (HW8_REG(base_addr +0x0D) != 0x21) {err_code |= (1<<4); puts("    ERROR @ DataD");}
  if (HW8_REG(base_addr +0x0E) != 0x66) {err_code |= (1<<4); puts("    ERROR @ DataE");}
  if (HW8_REG(base_addr +0x0F) != 0x55) {err_code |= (1<<4); puts("    ERROR @ DataF");}

  if (err_code != 0) {
    printf ("ERROR : AHB eg slave access failed (0x%x)\n", err_code);
    return_val=1;
    err_code = 0;
    }
  return(return_val);

}

// -----------------------------------------------------------
// Check the access to AHB trickbox slave
// -----------------------------------------------------------
int check_ahb_tb_slave(unsigned long base_addr)
{
  int return_val=0;
  int err_code=0;
  int i;

  puts ("Checking AHB Trickbox slave");

  // First four words are the same data registers with different wait states
  puts ("- check R/W in word size");
  HW32_REG(base_addr      ) = 0x12345678;
  if (HW32_REG(base_addr      ) != 0x12345678) {err_code |= (1<<0); puts("    ERROR @ Data0");}
  HW32_REG(base_addr +0x04) = 0x55CC33AA;
  if (HW32_REG(base_addr +0x04) != 0x55CC33AA) {err_code |= (1<<0); puts("    ERROR @ Data1");}
  HW32_REG(base_addr +0x08) = 0xFF008765;
  if (HW32_REG(base_addr +0x08) != 0xFF008765) {err_code |= (1<<0); puts("    ERROR @ Data2");}
  HW32_REG(base_addr +0x0C) = 0x99AABCDE;
  if (HW32_REG(base_addr +0x0C) != 0x99AABCDE) {err_code |= (1<<0); puts("    ERROR @ Data3");}

  puts ("- check R/W in half word size");
  HW16_REG(base_addr      ) = 0xA987;
  if (HW16_REG(base_addr      ) != 0xA987) {err_code |= (1<<1); puts("    ERROR @ Data0");}
  HW16_REG(base_addr +0x02) = 0xEDCB;
  if (HW16_REG(base_addr +0x02) != 0xEDCB) {err_code |= (1<<1); puts("    ERROR @ Data1");}
  HW16_REG(base_addr +0x04) = 0xCC55;
  if (HW16_REG(base_addr +0x04) != 0xCC55) {err_code |= (1<<1); puts("    ERROR @ Data2");}
  HW16_REG(base_addr +0x06) = 0xAA33;
  if (HW16_REG(base_addr +0x06) != 0xAA33) {err_code |= (1<<1); puts("    ERROR @ Data3");}
  HW16_REG(base_addr +0x08) = 0x789A;
  if (HW16_REG(base_addr +0x08) != 0x789A) {err_code |= (1<<1); puts("    ERROR @ Data4");}
  HW16_REG(base_addr +0x0A) = 0x00FF;
  if (HW16_REG(base_addr +0x0A) != 0x00FF) {err_code |= (1<<1); puts("    ERROR @ Data5");}
  HW16_REG(base_addr +0x0C) = 0x4321;
  if (HW16_REG(base_addr +0x0C) != 0x4321) {err_code |= (1<<1); puts("    ERROR @ Data6");}
  HW16_REG(base_addr +0x0E) = 0x6655;
  if (HW16_REG(base_addr +0x0E) != 0x6655) {err_code |= (1<<1); puts("    ERROR @ Data7");}

  puts ("- check R/W in byte size");
  HW8_REG(base_addr     ) = 0xA9;  // swap upper and lower byte
  if (HW8_REG(base_addr      ) != 0xA9) {err_code |= (1<<2); puts("    ERROR @ Data0");}
  HW8_REG(base_addr +0x01) = 0x87;
  if (HW8_REG(base_addr +0x01) != 0x87) {err_code |= (1<<2); puts("    ERROR @ Data1");}
  HW8_REG(base_addr +0x02) = 0xED;
  if (HW8_REG(base_addr +0x02) != 0xED) {err_code |= (1<<2); puts("    ERROR @ Data2");}
  HW8_REG(base_addr +0x03) = 0xCB;
  if (HW8_REG(base_addr +0x03) != 0xCB) {err_code |= (1<<2); puts("    ERROR @ Data3");}
  HW8_REG(base_addr +0x04) = 0xCC;
  if (HW8_REG(base_addr +0x04) != 0xCC) {err_code |= (1<<2); puts("    ERROR @ Data4");}
  HW8_REG(base_addr +0x05) = 0x55;
  if (HW8_REG(base_addr +0x05) != 0x55) {err_code |= (1<<2); puts("    ERROR @ Data5");}
  HW8_REG(base_addr +0x06) = 0xAA;
  if (HW8_REG(base_addr +0x06) != 0xAA) {err_code |= (1<<2); puts("    ERROR @ Data6");}
  HW8_REG(base_addr +0x07) = 0x33;
  if (HW8_REG(base_addr +0x07) != 0x33) {err_code |= (1<<2); puts("    ERROR @ Data7");}
  HW8_REG(base_addr +0x08) = 0x78;
  if (HW8_REG(base_addr +0x08) != 0x78) {err_code |= (1<<2); puts("    ERROR @ Data8");}
  HW8_REG(base_addr +0x09) = 0x9A;
  if (HW8_REG(base_addr +0x09) != 0x9A) {err_code |= (1<<2); puts("    ERROR @ Data9");}
  HW8_REG(base_addr +0x0A) = 0x00;
  if (HW8_REG(base_addr +0x0A) != 0x00) {err_code |= (1<<2); puts("    ERROR @ DataA");}
  HW8_REG(base_addr +0x0B) = 0xFF;
  if (HW8_REG(base_addr +0x0B) != 0xFF) {err_code |= (1<<2); puts("    ERROR @ DataB");}
  HW8_REG(base_addr +0x0C) = 0x43;
  if (HW8_REG(base_addr +0x0C) != 0x43) {err_code |= (1<<2); puts("    ERROR @ DataC");}
  HW8_REG(base_addr +0x0D) = 0x21;
  if (HW8_REG(base_addr +0x0D) != 0x21) {err_code |= (1<<2); puts("    ERROR @ DataD");}
  HW8_REG(base_addr +0x0E) = 0x66;
  if (HW8_REG(base_addr +0x0E) != 0x66) {err_code |= (1<<2); puts("    ERROR @ DataE");}
  HW8_REG(base_addr +0x0F) = 0x55;
  if (HW8_REG(base_addr +0x0F) != 0x55) {err_code |= (1<<2); puts("    ERROR @ DataF");}


  puts ("- check read to 0x010 to 0x0FF");
  // address 0x010 to 0x0FF returns HADDR[7:0]
  //
  for (i=0x10;i<0x40;i=i+4){  // Higher address values will result in time out
    if (HW32_REG(base_addr + i) != i) {
      err_code |= (1<<3);
      printf ("  ERROR: %x, return %x\n", i, HW32_REG(base_addr + i));
      }
    }

  // address 0x040 and above results in timeout
  // Note:to reduce simulation time not all addresses are tested
  puts ("- offset 0x040 and above results in timeout");
  for (i=0x40;i<0xFF;i=i+28){  // Higher address values will result in time out
    hardfault_occurred = 0;
    hardfault_expected = 1;
    temp_data = address_test_read(base_addr + i);

    if (hardfault_occurred ==0) {
      err_code |= (1<<4);
      puts ("ERROR: Expected timeout did not take place");
      }
    }

  puts ("- offset 0x100 and above results in error response/timeout");

  // address 0x104 to 0x1FF  results in error response
  // Note:to reduce simulation time not all addresses are tested
  for (i=0x104;i<0x180;i=i+20){  // Higher address values will result in time out
    hardfault_occurred = 0;
    hardfault_expected = 1;
    temp_data = address_test_read(base_addr + i);

    if (hardfault_occurred ==0) {
      err_code |= (1<<5);
      puts ("ERROR: Expected timeout did not take place");
      }
    }

  hardfault_occurred = 0; // reset variables
  hardfault_expected = 0;


  if (err_code != 0) {
    printf ("ERROR : AHB trickbox slave access failed (0x%x)\n", err_code);
    return_val=1;
    err_code = 0;
    }
  return(return_val);

}
// -----------------------------------------------------------
// Check the access to AHB default slave
// -----------------------------------------------------------
int check_default_slave(unsigned long base_addr)
{
  int return_val=0;
  int err_code=0;

  temp_data=0;
  hardfault_occurred = 0;
  hardfault_expected = 1;

  printf ("- test R/W to %x\n",base_addr);
  address_test_write(base_addr, 0x3456789A);
  if (hardfault_occurred==0) {err_code |= (1<<2);}
  hardfault_occurred = 0;

  temp_data = address_test_read(base_addr);
  if (hardfault_occurred==0) {err_code |= (1<<3);}
  hardfault_occurred = 0;

  hardfault_occurred = 0; // reset variables
  hardfault_expected = 0;


  if (err_code != 0) {
    puts ("ERROR : AHB default slave access failed");
    return_val=1;
    err_code = 0;
    }
  return(return_val);

}

// -----------------------------------------------------------
// Functions to handle read/write test with 16-bit memory
// access instruction for bus fault testing.
// -----------------------------------------------------------

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

// -----------------------------------------------------------
// Hard fault handler
// Divided into two halves:
//   - assembly part to extract stack frame starting location
//   - C handler part to carry out processing and checks
// -----------------------------------------------------------

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
  if (probe_ext_eg_sys==1) {
    puts (" - Extended Example System not available.\n - INCLUDE_EXT_SUBSYSTEM variable in rtl_sim/makefile is set to 0\nTest skipped.");
    UartEndSimulation();
    return;
    }
  puts ("[Hard Fault Handler]");
  if (hardfault_expected==0) {
    puts ("ERROR : Unexpected HardFault interrupt occurred.\n");
    UartEndSimulation();
    return;
    }
  stacked_r0  = ((unsigned long) hardfault_args[0]);
  stacked_pc  = ((unsigned long) hardfault_args[6]);
  printf(" - Stacked R0 : 0x%x\n", stacked_r0);
  printf(" - Stacked PC : 0x%x\n", stacked_pc);
  /* Modify R0 to a valid address */
  hardfault_args[0] = (unsigned long) &temp_data;

  return;
}


