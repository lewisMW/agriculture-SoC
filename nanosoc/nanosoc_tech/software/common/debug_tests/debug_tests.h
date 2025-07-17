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

//==============================================================================
// Cortex-M0/M0+ Debug test header File
//==============================================================================

#define TEST_PASS 0
#define TEST_FAIL 1

//Test command sequence definition
#define  DBG_ESCAPE          0x1B
#define  DBG_CONNECT_ENABLE  0x11
#define  DBG_CONNECT_DISABLE 0x12
#define  DBG_SIM_STOP        0x4


// GPIO0 bit allocation
//
// CM0_MCU GPIO0 --------------------------------------  Debug Tester
//
// GPIO[7] 7 <----------------------------------------< Running
// GPIO[6] 6 <----------------------------------------< Error
// GPIO[5] 5 >----------------------------------------> Function Strobe
// GPIO[4] 4 >----------------------------------------> Function Select bit 4
// GPIO[3] 3 >----------------------------------------> Function Select bit 3
// GPIO[2] 2 >----------------------------------------> Function Select bit 2
// GPIO[1] 1 >----------------------------------------> Function Select bit 1
// GPIO[0] 0 >----------------------------------------> Function Select bit 0
#define   DEBUG_BIT_LOC            0           //GPIO[0] is the ls bit of Function Select
#define   DEBUG_CMD                0x3f        //GPIO [5:0]
#define   DEBUG_STROBE             0x20        //GPIO [5]
#define   DEBUG_ERROR              0x40        //GPIO [6]
#define   DEBUG_RUNNING            0x80        //GPIO [7]


// CM0 MCU's view of the memory shared with the debugtester
// (4 words above stack top)
// This macro uses the SP value from the vector table as stacktop
// The stacktop can not be set to the top of the memory.
#define DEBUGTESTERDATA ((volatile uint32_t *) *((uint32_t *) 0x0))


// A convenient way to access the AHB Default Slave
// (1st word above top of RAM)
#define AHBDEFAULTSLAVE ((volatile uint32_t *) ((uint32_t) 0x40020000))


//Function definition
// Ensure we SLEEPDEEP - SLEEPDEEP should be set
// SCR[2] = SLEEPDEEP
#define  SET_SLEEP_DEEP()  SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk

