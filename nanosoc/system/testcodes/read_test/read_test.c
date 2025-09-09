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
#include <stdint.h>

// #define ADC_STATUS_MASK 0b00000000000000000000000000001100
#include "sensing_ip.h"

int main (void)
{
    //Pointer to APB Bus from memory map 
    // volatile unsigned int *APB_BUS = (unsigned int *)0x51000000;

    // Read the status register.
    // Read using raw number and then reread using the macro.
    volatile unsigned int status_reg_value = SENSING_IP_REGS->status_reg;
    status_reg_value = GET_ADC_STATUS(SENSING_IP_REGS->status_reg);
    printf("ADC Status: %u\n", status_reg_value);

    //Read the FIFO status
    volatile unsigned int fifo_status = GET_FIFO_STATUS(SENSING_IP_REG->status_reg);
    printf("FIFO Status: %u\n", fifo_status);

    //Read measured value
    volatile uint32_t measurement_high = SENSING_IP_REGS->measurement_high;
    volatile uint32_t measurement_low = SENSING_IP_REGS->measurement_low;
    uint64_t  measurement_value = ((uint64_t)measurement_high << 32) | measurement_low;
    printf("Measurement Value: %llu\n", measurement_value);

    return 0;
}

