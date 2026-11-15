/*
 * sensing_cal_test.c - FW-6
 *
 * ADC_CAL = 1, one manual trigger (a calibration conversion, which returns
 * 0x00), then normal samples. Build the simulation with +define+SENSING_CHECK
 * (EXTRA_DEFINES): the wrapper's plausibility checker then prints
 * "SENSING_CHECK FAIL" for a stuck/railed/jumping converter; the runner must
 * find none in the log. NOTE the open analog bug ADC-CAL (calibration has the
 * wrong polarity and ends on a trim rail): the calibration itself still
 * returns 0x00 and the following samples may be offset - the plausibility band
 * is loose, so this test is expected to pass, but its sample values are worth
 * reading when ADC-CAL is fixed.
 */
#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#include "core_cm0.h"
#endif
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#include "core_cm0plus.h"
#endif
#include <stdint.h>
#define SENSING_COUNT_FAULTS
#include "../sensing_check.h"

int main(void)
{
    uint32_t i, s, ok;
    UartStdOutInit();
    sp_str("sensing_cal_test: start\n");
    sensing_quiesce();
    sensing_clear_fifo();
    /* settle: one ordinary sample, so the ADC is idle with no conversion in flight */
    sensing_trigger_oneshot();
    SC_CHECK(sensing_wait_sample(20000), "warm-up sample");
    sensing_wait_adc_idle();
    sensing_delay(400);
    sensing_clear_fifo();

    SENSING_IP_REGS->adc_cal = ADC_CAL_ENABLE;
    sensing_trigger_oneshot();
    SC_CHECK(sensing_wait_sample(40000), "calibration conversion completes");
    s = SENSING_IP_REGS->measurement_low;
    sp_str_hex_nl("calibration sample ", s);
    SC_CHECK(s == 0u, "calibration sample reads 0x00");
    SENSING_IP_REGS->adc_cal = 0u;

    ok = 1;
    for (i = 0; i < 12; i++) {
        sensing_wait_adc_idle();
        sensing_delay(400);
        sensing_trigger_oneshot();
        if (!sensing_wait_sample(20000)) { ok = 0; break; }
        s = SENSING_IP_REGS->measurement_low;
        sp_str_hex_nl("sample ", s);
        if (s > 0xFFu) ok = 0;
    }
    SC_CHECK(ok, "12 normal samples after calibration (8-bit, zero-extended)");
    sp_str("(check the log for SENSING_CHECK FAIL lines: expected none)\n");
    sensing_init(5, 0);
    sc_finish("sensing_cal_test");
    return 0;
}
