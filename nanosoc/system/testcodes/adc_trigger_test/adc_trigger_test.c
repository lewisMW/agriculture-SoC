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

#include "uart_stdout.h"

// #define ADC_STATUS_MASK 0b00000000000000000000000000001100
#include "sensing_ip.h"

int main (void)
{
    UartStdOutInit();
    //Pointer to APB Bus from memory map 
    // volatile unsigned int *APB_BUS = (unsigned int *)0x51000000;

    // Read the status register.
    // volatile unsigned int *STATUS_REG_ADDR = APB_BUS + 0x1;
    // volatile unsigned int status_reg_value = *STATUS_REG_ADDR;
    // volatile unsigned int adc_status = status_reg_value & ADC_STATUS_MASK;
    // adc_status = adc_status >> 2;
    
    if (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) != STATUS_FIFO_EMPTY) {
        printf("FIFO is not empty before ADC trigger!\n");
    }
    
    //Trigger the ADC
    // volatile unsigned int *ADC_TRIGGER_ADDR =  (uint8_t*) APB_BUS + 0x108;
    //?volatile unsigned int *ADC_TRIGGER_ADDR = APB_BUS + 0x102;
    SENSING_IP_REGS->adc_trigger = 1;

    const uint32_t TIMEOUT = 128;

    uint32_t i = 0;
    while (i < TIMEOUT) {
        // volatile unsigned int *STATUS_REG_ADDR = APB_BUS + 0x1;
        // volatile unsigned int status_reg_value = *STATUS_REG_ADDR;
        // adc_status = status_reg_value & ADC_STATUS_MASK;
        // adc_status = adc_status >> 2;
        if (GET_FIFO_STATUS(SENSING_IP_REGS->status_reg) == STATUS_FIFO_READY) {
            break;
        }
        i += 1;
    }

    //TODO MAKE THIS A PROPER ASSERTION.gs
    if (i >= TIMEOUT) {
        printf("FIFO did not acquire a new measurement!\n");
    } else {
        printf("Test Passed!\n");
    }
    UartEndSimulation();

    // while (1);

    return 0;
}

