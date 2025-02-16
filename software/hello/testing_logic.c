
#include <stdio.h>

#define ADC_STATUS_MASK 0b00000000000000000000000000001100

// This test checks you can write to the relevant wrapper writes.
// Consider splitting into several tests.
// This file is to test the logic of the testing is correct before simulating on the processor.
int main ()
{
    // Pointer to GPIO register from memory map
    volatile unsigned int APB_BUS[0x2] = {0};
    *(APB_BUS + 0x1) = 4;

    // Read the status register.
    volatile unsigned int *STATUS_REG_ADDR = APB_BUS + 0x1;
    printf("APB_BUS ADDR: %p, STATUS REG ADDRES %p\n", APB_BUS, STATUS_REG_ADDR);
    unsigned int status_reg_value = *STATUS_REG_ADDR;
      printf("ADC_STATUS %d\n", status_reg_value);
    unsigned int adc_status = status_reg_value & ADC_STATUS_MASK;
    printf("ADC_STATUS %d\n", adc_status);
    adc_status = adc_status >> 2;
    printf("ADC_STATUS %d\n", adc_status);



    return 0;
}


