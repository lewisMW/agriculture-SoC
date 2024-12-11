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

//==============================================================================
//
// CORTEX-M System Design Kit Debug Test
//
//==============================================================================


// If DBG is present, this test checks:
//
// ID value check
//
//   -  Check some ID registers like CPUID, BASEADDRESS,
//
// WFI SLEEPDEEP, Debugger Wakeup
//
//   - Check when processor in deep sleep mode, the debugger can wakeup
//     the processor
//
// DAP Access
//
//   - The test uses the debug tester to read and write to memory using
//     Word, Halfword and Byte accesses.
//
//
// LOCKUP
//
//   - The test enters the architected lock-up state by accessing faulting
//     memory from within the HardFault handler. The debug tester checks
//     that lockup has been entered and checks that the LOCKUP pin has been
//     driven by reading the example MCU internal debug register.
//
//


#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#include "core_cm0.h"

#else
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#include "core_cm0plus.h"

#else
#ifdef CORTEX_M3
#include "CMSDK_CM3.h"
#include "core_cm3.h"

#else
#ifdef CORTEX_M4
#include "CMSDK_CM4.h"
#include "core_cm4.h"

#endif
#endif
#endif
#endif

#include <stdio.h>
#include "uart_stdout.h"
#include "mcu_debugtester_interface.h" // For definition of interface to the debug tester
#include "CMSDK_driver.h"


#include "config_id.h"
#include "debug_tests.h"
#include "debugtester_functions.h"


///////////////////////////////////////////////////////////////////////
// Global Variables to track test progress
///////////////////////////////////////////////////////////////////////

uint32_t Errors = 0;
volatile uint32_t ExpectHardFault = 0;
uint32_t HardFaultTaken = 0;

typedef void (* FuncPtr)(void);


///////////////////////////////////////////////////////////////////////
//Function prototype
///////////////////////////////////////////////////////////////////////
void HardFault_Handler(void);


///////////////////////////////////////////////////////////////////////
//Main code
///////////////////////////////////////////////////////////////////////

int main (void)
{

  // UART init
  UartStdOutInit();

  // This test requires DBG to be present.
  // If EXPECTED_DBG indicates that DBG is not present, this test will
  // PASS to allow a clean test run.

  printf("%s - Debug Test\n", MCU_CPU_NAME);

  if(EXPECTED_DBG != 1)
    {
      puts("EXPECTED_DBG parameter set to 0\n** TEST SKIPPED **\n");
      UartEndSimulation();   // stop simulation
      return 1;
    }
  else
    {

      EnableDebugTester();

      puts("Debug Test is now enabled\n");

      /////////////////////////////////////////////////////////////////////////////
      // Initialise debug tester to correct protocol
      /////////////////////////////////////////////////////////////////////////////
      //DAP must be power down when setting the interface mode

      puts("Setting debug interface mode\n");
      if(EXPECTED_JTAGnSW)
        {
          CallDebugTester(FnSetInterfaceJTAG);
        }
      else
        {
          CallDebugTester(FnSetInterfaceSW);
        }

      puts("Debug Test interface set successfully\n");


      /////////////////////////////////////////////////////////////////////////////
      // Check DAP powerup
      /////////////////////////////////////////////////////////////////////////////
      puts("Checking DAP powerup:\n");
      if (CallDebugTester (FnDAPPowerUp) == TEST_PASS )
        {
	  puts("\tPASS\n");
        }
      else
        {
	  Errors++;
	  puts("\tFAIL\n");
        }


      /////////////////////////////////////////////////////////////////////////////
      // Check CPU ID
      /////////////////////////////////////////////////////////////////////////////
      puts("Checking CPU ID:\n");

      // Write CPUID address to stacktop
      DEBUGTESTERDATA[0] = 0xE000ED00;

      // Call GetAPMem()
      if( CallDebugTester(FnGetAPMem) == TEST_PASS )
	{
	  // Check returned value matches expected CPU ID

	  if(DEBUGTESTERDATA[0] == MCU_CPU_ID_VALUE)
	    {
	      puts("\tPASS\n");
	    }
	  else
	    {
	      Errors++;
	      printf("\tFAIL - Expected %x, got %x\n", MCU_CPU_ID_VALUE, DEBUGTESTERDATA[0]);
	    }
	}
      else
	{
	  Errors++;
	  puts("\tFAIL\n");
	}


      if (EXPECTED_SIMPLE_CHECK)
	{
	  //Above check is enough
	}
      else
	{
	  //Complex check start here

	  /////////////////////////////////////////////////////////////////////////////
	  // Check DP ID
	  /////////////////////////////////////////////////////////////////////////////
	  puts("Checking DP ID:\n");

	  DEBUGTESTERDATA[0] = 0x0; //DPIDR

	  if (CallDebugTester (FnGetDPReg) == TEST_PASS )
	    {
	      if(DEBUGTESTERDATA[0] == MCU_DP_IDR_VALUE)
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  printf("\tFAIL - Expected %x, got %x\n", MCU_DP_IDR_VALUE, DEBUGTESTERDATA[0]);
		}
	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }

	  /////////////////////////////////////////////////////////////////////////////
	  // Check AP ID
	  /////////////////////////////////////////////////////////////////////////////

	  puts("Checking AP ID:\n");

	  DEBUGTESTERDATA[0] = 0xFC; //APIDR

	  if (CallDebugTester (FnGetAPReg) == TEST_PASS )
	    {
	      if(DEBUGTESTERDATA[0] == MCU_AP_IDR_VALUE)
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  printf("\tFAIL - Expected %x, got %x\n", MCU_AP_IDR_VALUE, DEBUGTESTERDATA[0]);
		}
	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }


	  /////////////////////////////////////////////////////////////////////////////
	  // Check BASE
	  /////////////////////////////////////////////////////////////////////////////
	  puts("Checking BASE:\n");

	  DEBUGTESTERDATA[0] = 0xF8; //APBASE

	  if (CallDebugTester (FnGetAPReg) == TEST_PASS )
	    {
	      if(DEBUGTESTERDATA[0] == MCU_AP_BASE_VALUE)
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  printf("\tFAIL - Expected %x, got %x\n", MCU_AP_BASE_VALUE, DEBUGTESTERDATA[0]);
		}
	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }


	  /////////////////////////////////////////////////////////////////////////////
	  // WFI SLEEPDEEP, Debugger Wakeup
	  /////////////////////////////////////////////////////////////////////////////
	  puts("WFI SLEEPDEEP, Debugger Wakeup:\n");
	  // Clear data value
	  DEBUGTESTERDATA[0] = 0;
	  // Ensure we SLEEPDEEP - SLEEPDEEP should be set
	  SET_SLEEP_DEEP();

	  // Wakeup will be due to the debugger
	  StartDebugTester(FnConnectWakeUnhalt);

	  // Wait For Interrupt loop
	  while(DEBUGTESTERDATA[0] == 0)
	    {
	      __WFI();
	      __ISB();
	    }

	  if(CheckDebugTester() == TEST_PASS)
	    {
	      puts("\tPASS\n");
	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }


	  /////////////////////////////////////////////////////////////////////////////
	  // DAP Access
	  //
	  // Check Word, Halfword and Byte accesses to memory
	  // via the DAP, using the debug tester.
	  /////////////////////////////////////////////////////////////////////////////

	  puts("DAP Access:\n");

	  DEBUGTESTERDATA[0] = 0;

	  if( CallDebugTester(FnDAPAccess) == TEST_PASS )
	    {
	      // Check returned value from debug tester
	      puts("DAP Access: Test pass, checking returned values ....\n");
	      printf("After testing: DEBUGTESTERDATA[0] == %x :\n",DEBUGTESTERDATA[0] );
	      puts("\tWORD: ");

	      if( (DEBUGTESTERDATA[0]) & 0x1 )
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  puts("\tFAIL\n");
		}

	      puts("\tHALFWORD: ");

	      if( (DEBUGTESTERDATA[0]) & 0x2 )
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  puts("\tFAIL\n");
		}

	      puts("\tBYTE: ");

	      if( (DEBUGTESTERDATA[0]) & 0x4 )
		{
		  puts("\tPASS\n");
		}
	      else
		{
		  Errors++;
		  puts("\tFAIL\n");
		}

	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }

	  // Clear data value
	  DEBUGTESTERDATA[0] = 0;


	  /////////////////////////////////////////////////////////////////////////////
	  // LOCKUP
	  //
	  // Create LOCKUP scenario by accessing faulting instruction within the HardFault Handler
	  // We enter the HardFault Handler by accessing faulting instruction
	  // The debugger will check for lockup before allowing execution to resume.
	  /////////////////////////////////////////////////////////////////////////////

	  // Set up memory locations pointed to by FaultFunction
	  // to contain instruction code that will cause a hardware fault
	  //

	  // HardwareFault is generated by accessing the undefined instruction
	  // so we can generate a fault like this:
	  // xxxxx (0xf123) // non-exist instruction like 0xf123
	  // BX LR (0x4770) //

	  //
	  // Set up a faulting version and a non faulting version.
	  // The debugger will copy the non-faulting version over the
	  // faulting version to enable the MCU to return to the function
	  // without incurring further faults.
	  //

	  // Little Endian Encodings:
	  // FAULTLOAD 0xf123     //Non-exist instruction 0xf123
	  // NONFAULT  0x0000     //NOP
	  // RETURN    0x4770     //BX LR

	  if(EXPECTED_BE)
	    {
	      // Non Faulting
	      DEBUGTESTERDATA[2] = 0x00007047;
	      // Faulting
	      DEBUGTESTERDATA[3] = 0x23f17047;
	    }
	  else
	    {
	      // Non Faulting
	      DEBUGTESTERDATA[2] = 0x47700000;
	      // Faulting
	      DEBUGTESTERDATA[3] = 0x4770f123;
	    }


	  puts("LOCKUP:\n");

	  ExpectHardFault = 1;


	  // Start Debug Tester function that will get us out of Lockup
	  StartDebugTester(FnConnectCheckUnlockup);

          while(HardFaultTaken == 0)
	    {
	      ((FuncPtr) ( 1+(uint32_t)(&(DEBUGTESTERDATA[3]))) ) ();
	    }

	  printf("HardFaultTaken = %x\n", HardFaultTaken);

	  // Get here if we took HardFault -> LOCKUP -> Debugger returned us

	  if( (CheckDebugTester() == TEST_PASS) && HardFaultTaken)
	    {
	      puts("\tPASS\n");
	    }
	  else
	    {
	      Errors++;
	      puts("\tFAIL\n");
	    }

	  //Complex check end here
	}

      /////////////////////////////////////////////////////////////////////////////
      // Check DAP powerdown
      /////////////////////////////////////////////////////////////////////////////
      puts("Checking DAP power down:\n");
      if (CallDebugTester (FnDAPPowerDown) == TEST_PASS )
	{
	  puts("\tPASS\n");
	}
      else
	{
	  Errors++;
	  puts("\tFAIL\n");
	}


      //Print final test result
      if (Errors == 0) {
	puts("** TEST PASSED **\n");
      } else {
	printf("** TEST FAILED ** with Error code:%d\n", Errors);
      }

      DisableDebugTester();

      return Errors;
    }
}



/////////////////////////////////////////////////////////////////////////////
// Hardware Fault Handlers
/////////////////////////////////////////////////////////////////////////////
void HardFault_Handler(void)
{
  // The HardFault Handler is used for testing LOCKUP in this test

  if(ExpectHardFault == 1)
    {
      // Tell main() that we took the HardFault
      HardFaultTaken = 1;

      // Access the undefined instruction to take core into LOCKUP
      ((FuncPtr) (1+(uint32_t)(&(DEBUGTESTERDATA[3])))) (); //Branch to the undefined instruction address
                                                            //with the LSB of the instruction to be 1
    }
  else
    {
      // Not expecting a fault
      puts("Unexpected HardFault - FAIL\n");
    }
}
