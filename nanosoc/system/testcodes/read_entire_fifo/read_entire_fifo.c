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

//TODO THIS ISN't FINISHED

volatile unsigned int get_fifo_status(volatile unsigned int *APB_BUS_ADDR);
uint64_t get_FIFO_value(volatile unsigned int* FIFO_MEASUREMENT_ADDR);

int main (void)
{
    //Pointer to APB Bus from memory map 
    //Write to PLL Control register
    SENSING_IP_REGS->pll_control = 0x0000023;

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
    // uint64_t combined_value = (((uint64_t)high_value )<< 32) | low_value;
    volatile uint32_t measurement_high = SENSING_IP_REGS->measurement_high;
    volatile uint32_t measurement_low = SENSING_IP_REGS->measurement_low;
    uint64_t  measurement_value = ((uint64_t) measurement_high << 32) | measurement_low;
    // printf("Measurement Value: %llu\n", measurement_value);
 
    // Pointer to GPIO register from memory map
    // volatile unsigned int *GPIO_DATA = (unsigned int *)0x50000000;
    //Pointer to APB Bus from memory map 
    // TODO Check where it is.
    volatile unsigned int *APB_BUS = (unsigned int *)0x51000000;

    // Read the status register.
    volatile unsigned int *STATUS_REG_ADDR = APB_BUS + 0x1;
    // volatile unsigned int status_reg_value = *STATUS_REG_ADDR;

    // Do a write to make waveforms more obvious.
    // volatile unsigned int *ANALOG_MUX_ADDR = (uint8_t*) APB_BUS + 0x104;
    // *ANALOG_MUX_ADDR = 0x4a;
    SENSING_IP_REGS->amux = 0x4a;
    
    //FIFO measurement address
    volatile unsigned int *FIFO_MEASUREMENT_ADDR = APB_BUS + 0x002;
 
    int i = 0;
    //Wait until fifo is full or at the least has some measurements.
    volatile unsigned int *ADC_TRIGGER_ADDR = SENSING_IP_REGS->adc_trigger;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0; 
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;
    SENSING_IP_REGS->adc_trigger = 0x1;
    SENSING_IP_REGS->adc_trigger = 0x0;   
        //Setting LSB to 1 should start ADC conversion.
  
        
    // while (i < 3) {
    //     volatile unsigned int *ADC_TRIGGER_ADDR = (uint8_t*) APB_BUS + 0x108;
    //     //Setting LSB to 1 should start ADC conversion.
    //     *ADC_TRIGGER_ADDR = 0x1;
    //     i = i+1;
    // }
    // //Was giving an error, commented it out and added back in and it worked?
    // // Keep going until fifo becomes empty. 
    // // Could add some sort of timeout check if required.
    measurement_high = SENSING_IP_REGS->measurement_high;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_value = ((uint64_t) measurement_high << 32) | measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    // *ANALOG_MUX_ADDR = 0x4a;
    SENSING_IP_REGS->amux = 0x4a;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    measurement_low = SENSING_IP_REGS->measurement_low;
    

    

    status_reg_value = *STATUS_REG_ADDR;
    // while(status_reg_value & FIFO_STATUS_MASK != 0b00) {
    //     volatile uint32_t high_value = *FIFO_MEASUREMENT_ADDR;
    //     volatile uint32_t low_value = *(FIFO_MEASUREMENT_ADDR+1);
    // //TODO verify this operation is valid.
    //     volatile uint64_t combined_value = (((uint64_t)high_value )<< 32) | low_value;
    //     // uint64_t fifo_value = get_FIFO_value(FIFO_MEASUREMENT_ADDR);
    //     // printf("%d\n", fifo_value);
    //     // i = i+1;
    //       status_reg_value = *STATUS_REG_ADDR;
    // }


    return 0;
}

//NOTE: If ever change map this function has to be rewritten. Magic number isn't great.
volatile unsigned int get_fifo_status(volatile unsigned int *APB_BUS_ADDR) {
    volatile unsigned int *STATUS_REG_ADDR = APB_BUS_ADDR + 0x1;
    volatile unsigned int status_reg_value = *STATUS_REG_ADDR;
    // return status_reg_value & FIFO_STATUS_MASK; //TODO Fix this
    return status_reg_value;
}

uint64_t get_FIFO_value(volatile unsigned int* FIFO_MEASUREMENT_ADDR) {
        uint32_t high_value = *FIFO_MEASUREMENT_ADDR;
    uint32_t low_value = *(FIFO_MEASUREMENT_ADDR+1);
    //TODO verify this operation is valid.
    uint64_t combined_value = (((uint64_t)high_value )<< 32) | low_value;
}

