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
//      Checked In          : $Date: 2013-01-18 17:35:18 +0000 (Fri, 18 Jan 2013) $
//
//      Revision            : $Revision: 234195 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//-----------------------------------------------------------------------------
//

//
// Definition of CMSDK example MCU to the Debug Tester
//
#ifdef CORTEX_M0
#include "CMSDK_CM0.h"

#else
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"

#else
#ifdef CORTEX_M3
#include "CMSDK_CM3.h"

#else
#ifdef CORTEX_M4
#include "CMSDK_CM4.h"

#endif
#endif
#endif
#endif

#include <stdio.h>
#include "uart_stdout.h"   // for stdout
#include "CMSDK_driver.h"
#include "config_id.h" // general defines such as test_pass


// Functions used by tests that communicate with the Debug Tester
extern void EnableDebugTester(void);
extern void DisableDebugTester(void);
extern uint32_t CallDebugTester(uint32_t);
extern void StartDebugTester(uint32_t);
extern uint32_t CheckDebugTester(void);


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

// CMSDK example MCU's view of the memory shared with the debugtester
// (4 words above stack top)
// This macro uses the SP value from the vector table as stacktop
// The stacktop cannot be set to the top of the memory.
#define DEBUGTESTERDATA ((volatile uint32_t *) *((uint32_t *) 0x0))

