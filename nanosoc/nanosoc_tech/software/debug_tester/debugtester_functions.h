/*
 *-----------------------------------------------------------------------------
 * The confidential and proprietary information contained in this file may
 * only be used by a person authorised under and to the extent permitted
 * by a subsisting licensing agreement from Arm Limited or its affiliates.
 *
 *            (C) COPYRIGHT 2010-2013  Arm Limited or its affiliates.
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
// CMSDK Debug Tester Functions header file
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Function enumeration to allow access to debug tester functions
//

enum Function { FnSetInterfaceJTAG,
		FnSetInterfaceSW,
		FnDAPPowerUp,
		FnDAPPowerDown,
		FnGetTAPID,
		FnGetDPReg,
		FnGetAPReg,
		FnGetAPMem,
		FnSetAPMem,
		FnGetAPMemCSIDs,
		FnConnectWakeUnhalt,
		FnConnectCheckUnlockup,
		FnEnableHaltingDebug,
		FnDAPAccess,
		FnConfigTrace,
		FnCheckTrace
};
