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
    UartStdOutInit();
    //Pointer to APB Bus from memory map 
    //Write to PLL Control register
    SENSING_IP_REGS->pll_control = 0x0000023;
    printf("This is the READ FIFO SIMPLE TEST\n");

    // Set analog mux control
    SENSING_IP_REGS->amux = 0x4a;

    //SET ADC TRIGGEr
    //Setting LSB to 1 should start ADC conversion.
    SENSING_IP_REGS->adc_trigger = 0x1;

    SENSING_IP_REGS->amux = 0x4a;
    
    SENSING_IP_REGS->adc_trigger = 0x0;



    // Pointer to GPIO register from memory map
    // volatile unsigned int *GPIO_DATA = (unsigned int *)0x50000000;
    //Pointer to APB Bus from memory map 
    // TODO Check where it is.
 
    volatile unsigned int status_reg_value = SENSING_IP_REGS->status_reg;
    // printf("Status Register Value: %u\n", status_reg_value);


    // Do a write to make waveforms more obvious.
    SENSING_IP_REGS->amux = 0x4a;

    
    //FIFO READ
    // uint64_t combined_value = (((uint64_t) )<< 32) | low_value;
    volatile uint32_t measurement_high = SENSING_IP_REGS->measurement_high;
    volatile uint32_t measurement_low = SENSING_IP_REGS->measurement_low;
    uint64_t  measurement_value = ((uint64_t)measurement_high << 32) | measurement_low;
    // printf("Measurement Value: %llu\n", measurement_value);
    UartEndSimulation();

    return 0;
}

