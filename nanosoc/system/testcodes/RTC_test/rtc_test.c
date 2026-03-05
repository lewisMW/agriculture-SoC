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
#include "uart_stdout.h"

int main (void)
{
    //Pointer to APB Bus from memory map 
    // volatile unsigned int *APB_BUS = (unsigned int *)0x51000000;
    UartStdOutInit();
    //Gonna start with just reading to the rtc
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;

    SENSING_IP_REGS->rtc_cr = 0x1;
    volatile uint32_t current_count = SENSING_IP_REGS->rtc_dr;
    SENSING_IP_REGS->amux = current_count;

    //Todo test can set control register
    //then test can do raw interrupt status
    //
    

    printf("Measurement Value\n");
    UartEndSimulation();
    return 0;
}

