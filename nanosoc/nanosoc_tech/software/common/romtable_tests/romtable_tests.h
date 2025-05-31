/*
 *-----------------------------------------------------------------------------
 * The confidential and proprietary information contained in this file may
 * only be used by a person authorised under and to the extent permitted
 * by a subsisting licensing agreement from Arm Limited or its affiliates.
 *
 *            (C) COPYRIGHT 2013  Arm Limited or its affiliates.
 *                ALL RIGHTS RESERVED
 *
 * This entire notice must be reproduced on all copies of this file
 * and copies of this file may only be made by a person if such person is
 * permitted to do so under the terms of a subsisting license agreement
 * from Arm Limited or its affiliates.
 *
 *      SVN Information
 *
 *      Checked In          : $Date: 2012-05-31 12:12:02 +0100 (Thu, 31 May 2012) $
 *
 *      Revision            : $Revision: 210765 $
 *
 *      Release Information : Cortex-M System Design Kit-r1p1-00rel0
 *-----------------------------------------------------------------------------
 */

////////////////////////////////////////////////////////////////////////////////
//
// CMSDK romtable tests header file
//
////////////////////////////////////////////////////////////////////////////////

// Partnumber is {PID1[3:0], PID0[7:0]}


struct CoreSightPart {
  uint32_t partnumber;
  char * partname;
};

struct CoreSightPart ARMCSParts[] = {

  // v6M Architected Parts
  {0x008, "v6M System Control Space (SCS)"},
  {0x00A, "v6M Data Watchpoint and Trace (DWT)"},
  {0x00B, "v6M Breakpoint Unit (BPU)"},

  // Cortex-M0
  {0x471, "Cortex-M0 Processor"},
  {0x4C2, "Cortex-M0 CoreSight Integration Level"},

  // Cortex-M0+
  {0x4C0, "Cortex-M0+ Processor"},
  {0x4C1, "Cortex-M0+ CoreSight Integration Level"},
  {0x9A6, "Cortex-M0+ Cross Trigger Interface (CTI)"},
  {0x932, "CoreSight MTB-M0+"},

  // Cortex-M1
  {0x470, "Cortex-M1 Processor"},

  // v7M Architected Parts
  {0x000, "v7M System Control Space (SCS)"},
  {0x00C, "v7MF System Control Space (SCS)"},
  {0x001, "v7M Instrumentation Trace Macrocell (ITM)"},
  {0x002, "v7M Data Watchpoint and Trace (DWT)"},
  {0x003, "v7M FlashPatch and Breakpoint (FPB)"},

  // Cortex-M3
  {0x4C3, "Cortex-M3 Processor"},
  {0x4C5, "Cortex-M3 CoreSight Integration Level"},
  {0x923, "Cortex-M3 TPIU"},
  {0x924, "Cortex-M3 ETM"},

  // Cortex-M4
  {0x4C4, "Cortex-M4 Processor"},
  {0x4C6, "Cortex-M4 CoreSight Integration Level"},
  {0x925, "Cortex-M4 ETM"},
  {0x9A1, "Cortex-M4 TPIU"},

  // Generic CoreSight Parts
  {0x906, "CoreSight Cross Trigger Interface (CTI)"},

};

#define NumARMCSParts (sizeof ARMCSParts / sizeof ARMCSParts[0])
