/*
 *-----------------------------------------------------------------------------
 * The confidential and proprietary information contained in this file may
 * only be used by a person authorised under and to the extent permitted
 * by a subsisting licensing agreement from Arm Limited or its affiliates.
 *
 *            (C) COPYRIGHT 2011-2013 Arm Limited or its affiliates.
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
//  CORTEX-M System Design Kit ROM Table Test
//
//==============================================================================
//
// This test checks that is it possible to locate the CORTEX-M0+ architected
// ROM table by following the CoreSight Component pointer from the DAP.
// The ID values found in any intermediate ROM tables are displayed.
//
// The test passes if it finds the CORTEX-M0+ ROM Table (and the CoreSight MTB-M0+
// ROM Table if MTB is included)
//
// If DBG is not included, this test skips.
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
#include "uart_stdout.h"   // for stdout
#include "mcu_debugtester_interface.h" // For definition of interface to the debug tester
#include "CMSDK_driver.h"  // For GPIO functions in debug tester communication

#include "config_id.h"     // Needed for ID and configuration values

#include "debugtester_functions.h"  // For communication between processor under test and the debug tester

#include "romtable_tests.h" // Defines known CS parts


//=====================================================================
// Global Variables
//=====================================================================

// Structure to store Component Address, CID, PID, reference count
typedef struct
{
  uint32_t address;  // Component Base Address
  uint32_t cid;      // CoreSight Component ID CID3:0
  uint32_t pid1;     // CoreSight Peripheral ID PID3:0
  uint32_t pid2;     // CoreSight Peripheral ID PID7:4
  uint8_t  jepid;    // Decoded PID: JEP Identity
  uint8_t  jepcont;  // Decoded PID: JEP Continuation code count
  uint16_t partnum;  // Decoded PID: Part Number
  uint8_t  revision; // Decoded PID: Part Revision
  uint8_t  revand;   // Decoded PID: Revision ECO
  uint8_t  custmod;  // Decoded PID: Customer Modification
  uint8_t  isarm;    // Part has ARM JEPID
  uint8_t  ciderror; // Error in the CID fields
  uint8_t  piderror; // Error in the PID fields
  uint32_t refcount; // Number of times referenced
  uint32_t romcount; // ROM Table Number
} CS_Type;

// Maximum number of components
#define COMPMAX 10

// Array to store all discovered CoreSight components
CS_Type Components[COMPMAX];

// Number of unique ROM tables found
uint32_t  NumRomTables = 0;

// error count
uint32_t Errors = 0;

//=====================================================================
// Function Prototypes
//=====================================================================
// Function to check CID, PID, part number of a component.
// If it is a ROM table, also scan through ROM table entries
void      FollowCoreSightPointer (uint32_t cs_pointer);

// Simple compare function and output error message if needed
uint32_t  CheckVal(char *name, uint32_t actual, uint32_t expected);
void      CheckHex(char *name, uint32_t actual, uint32_t expected);
void      CheckPresence(char *name, uint32_t actual, uint32_t expected);
void      InitComponentsList(void);
void      ReportResults(void);
CS_Type * FindComponent(uint32_t base_address);

// Compare the CID and PID based on Part Number
void      GetCoreSightIDs(CS_Type * comp_ptr);
void      CheckDisplayCID (CS_Type * comp_ptr);
void      CheckDisplayPID (CS_Type * comp_ptr);
void      DisplayDecodedPID (CS_Type * comp_ptr);
uint32_t  LookupARMCSPart(uint32_t);

//=====================================================================
// Main code
//=====================================================================

int main (void)
{
  // UART init
  UartStdOutInit();

  InitComponentsList();

  // Banner
  printf("%s - ROM Table Test\n\n", MCU_CPU_NAME);

  if(EXPECTED_DBG != 1)
    {
      puts("** TEST SKIPPED ** Core does not include DBG, skipping test\n");
      return 1;
    }
  else
    {
      EnableDebugTester();

      puts("\tROM Test is now ready\n");

      //
      // Initialise Debug Driver to correct protocol
      //
      if(EXPECTED_JTAGnSW)
	{
	  CallDebugTester(FnSetInterfaceJTAG);
	}
      else
	{
          if(CallDebugTester(FnSetInterfaceSW) != TEST_PASS)
	    {
	      puts("FAIL: Serial Wire Mode not set correctly\n");
	      Errors++;
	    }
	}

      // Turn on the DAP
      if(CallDebugTester(FnDAPPowerUp) != TEST_PASS)
	{
	  puts("Failed to power up the DAP\n");
	  Errors++;
	}
      else
	{
	  // Find BASE
	  DEBUGTESTERDATA[0] = 0xf8; // BASE

	  CallDebugTester(FnGetAPReg);
	  printf("----------\nDAP BASE entry is : 0x%08x", DEBUGTESTERDATA[0]);

#ifdef CORTEX_M3
	  // Enable Trace to make DWT, ITM and TPIU visible
	  CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
#endif
#ifdef CORTEX_M4
	  // Enable Trace to make DWT, ITM and TPIU visible
	  CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
#endif

	  // Start decoding
	  FollowCoreSightPointer(DEBUGTESTERDATA[0]);

	  puts("----------\n\n");
	}

      // Turn off DAP
      CallDebugTester(FnDAPPowerDown);

      // Report results
      ReportResults();
    }
  DisableDebugTester();
}


void FollowCoreSightPointer (uint32_t cs_pointer)
{
  //
  // Enter with a pointer to a CoreSight component
  //

  uint32_t base_addr = cs_pointer & 0xFFFFF000;
  uint32_t entry;
  uint32_t i;
  CS_Type * comp_ptr = NULL;


  // Check if pointer points to anything

  switch(cs_pointer & 0x3)
    {
    case 0x0:
      puts(" - Non Zero Entry not present, not in 32bit format\n");
      Errors++;
      break;

    case 0x1:
      puts(" - Entry marked as present but not in 32 bit format\n");
      Errors++;
      break;

    case 0x2:
      puts(" - Component not present\n");
      break;

    case 0x3:
      //
      // Component is present
      //
      printf(" - Component present at 0x%08x\n\nCoreSight ID of component at 0x%08x :\n\n",base_addr, base_addr);

      // Find or allocate space for this component in the Components array
      comp_ptr = FindComponent(base_addr);

      // Get CID and PID for the component
      GetCoreSightIDs(comp_ptr);

      // Detect duplicate entries here
      if(comp_ptr->refcount > 1)
	{
	  puts("** FAIL: This component is referenced more than once **\n");
	}

      // Check and Display CID
      CheckDisplayCID(comp_ptr);

      // Check and Display PID
      CheckDisplayPID(comp_ptr);

      //
      // If component is a ROM Table, iterate over its entries
      //
      if(comp_ptr->romcount)
	{
	  entry = 1; // Non zero initialisation value for loop
	  for(i = 0; entry > 0 ; i++)
	    {
	      // Get ROM Table Entry
	      DEBUGTESTERDATA[0] = base_addr + (i*4);
	      CallDebugTester(FnGetAPMem);
	      entry = DEBUGTESTERDATA[0];

	      printf("----------\nROM Table (%d) Entry %d at 0x%08x is : 0x%08x", comp_ptr->romcount, i, (base_addr + (i*4)), entry);

	      if(entry != 0)
		{
		  FollowCoreSightPointer(base_addr + entry);
		}
	      else
		{
		  puts(" - End of Table\n");
		}
	    }
	}
    }
}


void CheckDisplayCID (CS_Type * comp_ptr)
{
  // Display as raw byte values

  printf(" CID0: 0x%02x  CID1: 0x%02x  CID2: 0x%02x  CID3: 0x%02x",
        ( comp_ptr->cid        & 0xFF),
        ((comp_ptr->cid >>  8) & 0xFF),
        ((comp_ptr->cid >> 16) & 0xFF),
        ((comp_ptr->cid >> 24) & 0xFF));

  comp_ptr->ciderror = 0;

  switch(comp_ptr->cid)
    {
    case 0xB105100D:
      printf(" - ROM Table (%d)\n", comp_ptr->romcount);
      break;

    case 0xB105900D:
      puts(" - CoreSight Debug Component\n");
      break;

    case 0xB105E00D:
      puts(" - ARM Core Memory Component\n");
      break;

    case 0xB105F00D:
      puts(" - ARM Primecell\n");
      break;

    default:
      puts(" - Unknown\n** FAIL: Unknown Component ID **\n");
      comp_ptr->ciderror = 1;
    }
}


void CheckDisplayPID (CS_Type * comp_ptr)
{
  // Display as raw byte values

  printf(" PID0: 0x%02x  PID1: 0x%02x  PID2: 0x%02x  PID3: 0x%02x\n",
        ( comp_ptr->pid1        & 0xFF),
        ((comp_ptr->pid1 >>  8) & 0xFF),
        ((comp_ptr->pid1 >> 16) & 0xFF),
        ((comp_ptr->pid1 >> 24) & 0xFF));

  printf(" PID4: 0x%02x  PID5: 0x%02x  PID6: 0x%02x  PID7: 0x%02x",
        ( comp_ptr->pid2        & 0xFF),
        ((comp_ptr->pid2 >>  8) & 0xFF),
        ((comp_ptr->pid2 >> 16) & 0xFF),
        ((comp_ptr->pid2 >> 24) & 0xFF));

  comp_ptr->piderror = 0;

  //
  // Display description for known components
  //
  if(comp_ptr->isarm)
    {
      // ARM JEP ID
      LookupARMCSPart(comp_ptr->partnum);
    }
  else if((comp_ptr->jepid   == EXPECTED_CUST_JEP_ID) &&
	  (comp_ptr->jepcont == EXPECTED_CUST_JEP_CONT))
    {
      // Customer JEP ID
      puts(" - Customer Part\n");
      DisplayDecodedPID(comp_ptr);
      if (comp_ptr->jepid == 0)
	{
	  puts("** FAIL: Customer JEP ID shouldn't be zeroes or ARM's JEP ID! Please modify **\n");
	  comp_ptr->piderror = 1;
	}
    }
  else
    {
      // Unknown JEP ID
      puts(" - Unknown JEP ID code\n");
      DisplayDecodedPID(comp_ptr);
      puts("** FAIL: Unknown JEP ID code **\n");
      comp_ptr->piderror = 1;
    }
}


void DisplayDecodedPID (CS_Type * comp_ptr)
{
  printf("\n  JEP106 ID         [6:0] = 0x%02x\n", comp_ptr->jepid);
  printf(  "  JEP106 continuation     = 0x%x\n",   comp_ptr->jepcont);
  printf(  "  part number      [11:0] = 0x%03x\n", comp_ptr->partnum);
  printf(  "  revision          [3:0] = 0x%x\n",   comp_ptr->revision);
  printf(  "  revand            [3:0] = 0x%x\n",   comp_ptr->revand);
  printf(  "  customer modified [3:0] = 0x%x\n\n", comp_ptr->custmod);
}


//===========================================================================
// Generate error message if compare result does not match,
// also update error counter
//===========================================================================
uint32_t CheckVal(char *name, uint32_t actual, uint32_t expected)
{
  // Quiet check - Only call CheckHex if there is a mismatch
  if(actual != expected)
    {
      CheckHex(name, actual, expected);
      return 1; // Error
    }
  return 0;
}


void InitComponentsList(void)
{
  uint32_t index;
  for(index=0 ; index < COMPMAX ; index++)
    {
      Components[index].address = 0;
    }
}


void ReportResults(void)
{
  // Iterate through the list
  // Show errors where the same component is referenced by multiple paths
  // Show error if we don't find the expected components - Core, MTB, CTI

  uint32_t CIDErrors = 0;
  uint32_t PIDErrors = 0;
  uint32_t REFErrors = 0;

  uint32_t index;

  for(index=0 ; index < COMPMAX; index++)
    {
      if(Components[index].address)
	{
	  // Accumulate errors
	  CIDErrors +=  Components[index].ciderror;
	  PIDErrors +=  Components[index].piderror;
	  REFErrors += (Components[index].refcount > 1) ? 1 : 0;
	}
    }


  if(CIDErrors)
    {
      printf("** FAIL: There were %d errors found with Component ID values **\n", CIDErrors);
    }

  if(PIDErrors)
    {
      printf("** FAIL: There were %d errors found with Peripheral ID values **\n", PIDErrors);
    }

  if(REFErrors)
    {
      printf("** FAIL: %d components were referenced more than once **\n", REFErrors);
    }


  // Update global Errors count
  Errors += CIDErrors + PIDErrors + REFErrors;

  // Print final test result
  if (Errors == 0) {
     puts("** TEST PASSED **\n");
  } else {
     printf("** TEST FAILED ** with %d errors\n", Errors);
  }
}


void CheckPresence (char *name, uint32_t expected, uint32_t actual)
{
  if(expected && !actual)
    {
      printf("** FAIL: Did not find %s **\n", name);
      Errors++;
    }

  if(!expected && actual)
    {
      printf("** FAIL: Found unexpected %s **\n", name);
      Errors++;
    }
}


CS_Type * FindComponent (uint32_t base_address)
{
  uint32_t index = 0;
  CS_Type * comp_ptr = NULL;

  while((index < COMPMAX) && (comp_ptr == NULL))
    {
      if(Components[index].address == base_address)
	{
	  Components[index].refcount++;
	  comp_ptr = &Components[index];
	  index = COMPMAX;
	}
      else if(Components[index].address == 0)
	{
	  // New component
	  Components[index].address   = base_address;
	  Components[index].refcount  = 1;
	  comp_ptr = &Components[index];
	  index = COMPMAX;
	}
      else
	{
	  index++;
	}
    }

  if(comp_ptr == NULL)
    {
      puts("** ERROR - Found too many components, increase COMPMAX and try again **\n");
      Errors++;
    }

  return comp_ptr;
}


void GetCoreSightIDs(CS_Type * comp_ptr)
{
  // Only update the IDs if this is a new component
  if(comp_ptr->refcount == 1)
    {
      // Use DebugDriver to get CID and PID
      DEBUGTESTERDATA[0] = comp_ptr->address;
      CallDebugTester(FnGetAPMemCSIDs);
      comp_ptr->cid  = DEBUGTESTERDATA[0];
      comp_ptr->pid1 = DEBUGTESTERDATA[1];
      comp_ptr->pid2 = DEBUGTESTERDATA[2];


      // Decode PID information
      comp_ptr->jepid    = (comp_ptr->pid1 >> 12) & 0x7F;
      comp_ptr->jepcont  =  comp_ptr->pid2 & 0xF;
      comp_ptr->partnum  =  comp_ptr->pid1 & 0xFFF;
      comp_ptr->revision = (comp_ptr->pid1 >> 20) & 0xF;
      comp_ptr->revand   = (comp_ptr->pid1 >> 28) & 0xF;
      comp_ptr->custmod  = (comp_ptr->pid1 >> 24) & 0xF;

      // Check if the component is an ARM component
      comp_ptr->isarm = ((comp_ptr->jepid   == ARM_JEP_ID) &&
			 (comp_ptr->jepcont == ARM_JEP_CONT) ) ? 1 : 0;

      // If this is a ROM Table, update counter
      if(comp_ptr->cid == 0xB105100D)
	{
	  comp_ptr->romcount = ++NumRomTables;
	}
      else
	{
	  comp_ptr->romcount = 0;
	}
    }
}

void CheckHex(char *name, uint32_t actual, uint32_t expected)
{
  if(actual == expected)
    {
      printf("%s: 0x%x\t-\tPASS\n",
             name,
             actual);
    }
  else
    {
      printf("%s: Actual 0x%x\t(Expected 0x%x)\t-\tFAIL\n",
             name,
             actual,
             expected);
      Errors++;
    }
}


uint32_t LookupARMCSPart(uint32_t partnum)
{

  // Iterate over known parts, print string if found.
  // Return error if not found.

  uint32_t error, i;

  error = 1;

  for(i=0; i < NumARMCSParts; i++)
    {
      if(ARMCSParts[i].partnumber == partnum)
	{
	  error = 0;
	  printf(" - ARM %s\n", ARMCSParts[i].partname);
	  break;
	}
    }

  if(error)
    {
      puts(" - ARM, Unknown Partnumber\n");
    }
  return error;
}
