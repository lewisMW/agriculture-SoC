/*
/*
 *-----------------------------------------------------------------------------
 * The confidential and proprietary information contained in this file may
 * only be used by a person authorised under and to the extent permitted
 * by a subsisting licensing agreement from ARM Limited or its affiliates.
 *
 *            (C) COPYRIGHT 2010-2013 ARM Limited or its affiliates.
 *                ALL RIGHTS RESERVED
 *
 * This entire notice must be reproduced on all copies of this file
 * and copies of this file may only be made by a person if such person is
 * permitted to do so under the terms of a subsisting license agreement
 * from ARM Limited or its affiliates.
 *
 *      SVN Information
 *
 *      Checked In          : $Date: 2017-07-25 15:10:13 +0100 (Tue, 25 Jul 2017) $
 *
 *      Revision            : $Revision: 368444 $
 *
 *      Release Information : Cortex-M0 DesignStart-r2p0-00rel0
 *-----------------------------------------------------------------------------
 */

#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#include "core_cm0.h"
#endif

#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#include "core_cm0plus.h"
#endif

#include <stdio.h>
#include <inttypes.h>

// This test checks you can write to the relevant wrapper writes.
// Consider splitting into several tests.
int main (void)
{
    // Pointer to GPIO register from memory map
    volatile unsigned int *GPIO_DATA = (unsigned int *)0x50000000;
    //Pointer to APB Bus from memory map 
    // TODO Check where it is.
    volatile unsigned int *APB_BUS = (unsigned int *)0x51000000;

    // Read the status register.
    volatile unsigned int *STATUS_REG_ADDR = APB_BUS + 0x1;
    volatile unsigned int status_reg_value = *STATUS_REG_ADDR;
    
    //Read the measured value.
    volatile unsigned int *FIFO_MEASUREMENT_ADDR = APB_BUS + 0x002;
    // 64 bit value on FIFO but read 32 bits at a time. To guarantee size should probably change to uint32 etc...
    uint32_t high_value = *FIFO_MEASUREMENT_ADDR;
    uint32_t low_value = *(FIFO_MEASUREMENT_ADDR+1);
    //TODO verify this operation is valid.
    uint64_t combined_value = (((uint64_t)high_value )<< 32) | low_value;

    while (1);

    return 0;
}


