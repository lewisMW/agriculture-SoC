/*
 * sensing_regmap_test.c - FW-1
 *
 * The sensing register map as the Cortex-M0 sees it: reset values, walking 1
 * on PLL_CONTROL / AMUX / RTC_ALARM_OFFSET, byte and halfword stores (STRB /
 * STRH) to every lane, writes to read-only and reads of write-only registers,
 * unmapped offsets, the 64 KB alias and the 0xA000_0000 EXP mirror, the RTC
 * alias at 0x6000_1200 (must NOT reach the PL031), and back-to-back loads and
 * stores from a tight loop. Expectations are the adopted register policy
 * (F5/F6 fixed): only strobed lanes change, single-bit controls act only when
 * lane 0 is strobed, FIFO_CLEAR acts on any lane, RTC sub-word writes are
 * dropped. A HardFault fails the test (none expected).
 * printf-free (16 k-word ROM).
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

#define R32(a)  (*(volatile uint32_t *)(a))
#define R16(a)  (*(volatile uint16_t *)(a))
#define R8(a)   (*(volatile uint8_t  *)(a))
#define BASE    SENSING_IP_REGS_BASE

static uint32_t merge(uint32_t old, uint32_t v, uint32_t off, uint32_t size)
{
    uint32_t m = (size == 4) ? 0xFFFFFFFFu : (((1u << (8u * size)) - 1u) << (8u * off));
    return (old & ~m) | (v & m);
}

static void store(uint32_t addr, uint32_t off, uint32_t size, uint32_t v)
{
    if (size == 1)      R8(addr + off)  = (uint8_t)(v >> (8u * off));
    else if (size == 2) R16(addr + off) = (uint16_t)(v >> (8u * off));
    else                R32(addr)       = v;
}

static const uint8_t ACC_OFF[7]  = {0, 1, 2, 3, 0, 2, 0};
static const uint8_t ACC_SIZE[7] = {1, 1, 1, 1, 2, 2, 4};

int main(void)
{
    uint32_t i, k, ok;
    UartStdOutInit();
    sp_str("sensing_regmap_test: start\n");

    /* ---- reset values (first accesses after boot) ---- */
    SC_CHECK((R32(BASE + 0x004) >> 6) == 0, "STATUS[31:6] reset 0");
    SC_CHECK(R32(BASE + 0x008) == 0,        "MEASUREMENT_HI reset 0");
    SC_CHECK(R32(BASE + 0x100) == 0,        "PLL_CONTROL reset 0");
    SC_CHECK(R32(BASE + 0x104) == 0,        "AMUX reset 0");
    SC_CHECK(R32(BASE + 0x10C) == 0,        "ADC_CAL reset 0");
    SC_CHECK(R32(BASE + 0x224) == 5,        "RTC_ALARM_OFFSET reset 5");
    SC_CHECK(R32(BASE + 0x228) == 1,        "RTC_CTRL reset 1 (polling on)");
    SC_CHECK(R32(BASE + 0x108) == 0,        "ADC_TRIGGER (WO) reads 0");
    SC_CHECK(R32(BASE + 0x220) == 0,        "FIFO_CLEAR (WO) reads 0");

    sensing_quiesce();                    /* polling off, nothing in flight */
    sensing_clear_fifo();

    /* ---- walking 1 / walking 0 ---- */
    {
        static const uint32_t regs[3] = {0x100, 0x104, 0x224};
        for (k = 0; k < 3; k++) {
            ok = 1;
            for (i = 0; i < 32; i++) {
                R32(BASE + regs[k]) = 1u << i;
                if (R32(BASE + regs[k]) != (1u << i)) ok = 0;
                R32(BASE + regs[k]) = ~(1u << i);
                if (R32(BASE + regs[k]) != ~(1u << i)) ok = 0;
            }
            SC_CHECK(ok, k == 0 ? "walking 1/0 PLL_CONTROL" : k == 1 ? "walking 1/0 AMUX" : "walking 1/0 RTC_ALARM_OFFSET");
            R32(BASE + regs[k]) = (k == 2) ? 5u : 0u;
        }
    }

    /* ---- STRB / STRH to every lane of the multi-byte registers ---- */
    {
        static const uint32_t regs[3] = {0x100, 0x104, 0x224};
        for (k = 0; k < 3; k++) {
            ok = 1;
            for (i = 0; i < 7; i++) {
                uint32_t base = (k == 2) ? 0x7u : 0x0F0F0F0Fu;
                R32(BASE + regs[k]) = base;
                store(BASE + regs[k], ACC_OFF[i], ACC_SIZE[i], 0xA5C35A3Cu);
                if (R32(BASE + regs[k]) != merge(base, 0xA5C35A3Cu, ACC_OFF[i], ACC_SIZE[i])) ok = 0;
            }
            SC_CHECK(ok, k == 0 ? "PLL_CONTROL: byte/half stores change only their lanes"
                        : k == 1 ? "AMUX: byte/half stores change only their lanes"
                                 : "RTC_ALARM_OFFSET: byte/half stores change only their lanes");
            R32(BASE + regs[k]) = (k == 2) ? 5u : 0u;
        }
    }
    /* single-bit controls: bit0 only with lane 0 strobed */
    ok = 1;
    for (i = 0; i < 7; i++) {
        R32(BASE + 0x10C) = 0;
        store(BASE + 0x10C, ACC_OFF[i], ACC_SIZE[i], 0xFFFFFFFFu);
        if (R32(BASE + 0x10C) != (ACC_OFF[i] == 0 ? 1u : 0u)) ok = 0;
    }
    R32(BASE + 0x10C) = 0;
    SC_CHECK(ok, "ADC_CAL: bit0 set only by a store that includes lane 0");
    ok = 1;
    for (i = 0; i < 7; i++) {
        R32(BASE + 0x228) = 0;
        store(BASE + 0x228, ACC_OFF[i], ACC_SIZE[i], 0xFFFFFFFFu);
        if (R32(BASE + 0x228) != (ACC_OFF[i] == 0 ? 1u : 0u)) ok = 0;
    }
    R32(BASE + 0x228) = 0;
    sensing_delay(SENSING_PARK_SETTLE);
    sensing_clear_fifo();
    SC_CHECK(ok, "RTC_CTRL: bit0 set only by a store that includes lane 0");
    /* ADC_TRIGGER: lane 0 with bit0 triggers, other lanes do not */
    ok = 1;
    for (i = 0; i < 7; i++) {
        sensing_clear_fifo();
        store(BASE + 0x108, ACC_OFF[i], ACC_SIZE[i], 0xFFFFFFFFu);
        if (ACC_OFF[i] == 0) { if (!sensing_wait_sample(4000)) ok = 0; }
        else { sensing_delay(400); if (!sensing_fifo_empty()) ok = 0; }
        sensing_wait_adc_idle();
    }
    SC_CHECK(ok, "ADC_TRIGGER: one sample only for stores including lane 0");
    /* FIFO_CLEAR: any lane */
    ok = 1;
    for (i = 0; i < 7; i++) {
        sensing_trigger_oneshot();
        if (!sensing_wait_sample(4000)) ok = 0;
        sensing_wait_adc_idle();
        store(BASE + 0x220, ACC_OFF[i], ACC_SIZE[i], 0);
        if (!sensing_fifo_empty()) ok = 0;
    }
    SC_CHECK(ok, "FIFO_CLEAR: a store to any lane flushes");

    /* ---- RO written / WO read ---- */
    R32(BASE + 0x004) = 0xFFFFFFFFu; R32(BASE + 0x008) = 0xFFFFFFFFu; R32(BASE + 0x00C) = 0xFFFFFFFFu;
    R8(BASE + 0x005) = 0xFF; R16(BASE + 0x00E) = 0xFFFF;
    SC_CHECK(sensing_fifo_empty(),           "writes to RO STATUS/MEASUREMENT neither push nor pop");
    SC_CHECK((R32(BASE + 0x004) >> 6) == 0,  "STATUS reserved bits still 0 after RO writes");
    SC_CHECK(R32(BASE + 0x008) == 0,         "MEASUREMENT_HI still 0 after RO writes");

    /* ---- unmapped offsets: read 0, writes ignored, no fault ---- */
    R32(BASE + 0x100) = 0xCAFEF00Du;
    {
        static const uint32_t un[5] = {0x000, 0x010, 0x110, 0x22C, 0xFFC};
        ok = 1;
        for (i = 0; i < 5; i++) {
            if (R32(BASE + un[i]) != 0) ok = 0;
            R32(BASE + un[i]) = 0xFFFFFFFFu;
            if (R32(BASE + un[i]) != 0) ok = 0;
        }
        SC_CHECK(ok, "unmapped 0x000/0x010/0x110/0x22C/0xFFC read 0 after writes");
    }
    SC_CHECK(R32(BASE + 0x100) == 0xCAFEF00Du, "unmapped writes left PLL_CONTROL alone");

    /* ---- aliases: 64 KB repeat and the EXP mirror reach the registers ---- */
    SC_CHECK(R32(0x60010100u) == 0xCAFEF00Du, "0x6001_0100 aliases PLL_CONTROL (64 KB repeat)");
    SC_CHECK(R32(0xA0000100u) == 0xCAFEF00Du, "0xA000_0100 (EXP mirror) reads PLL_CONTROL");
    SC_CHECK((R32(0x60010004u) >> 6) == 0 && (R32(0xA0000004u) >> 6) == 0, "STATUS through 0x6001_0004 and 0xA000_0004");
    R32(0xA0000104u) = 0x2;
    SC_CHECK(R32(BASE + 0x104) == 0x2, "write via 0xA000_0104 reached AMUX");
    R32(BASE + 0x104) = 0;
    /* RTC alias 0x6000_1200 must not reach the PL031 (F5) */
    {
        uint32_t mr0;
        SENSING_IP_REGS->rtc_mr = 0x12345678u;
        mr0 = SENSING_IP_REGS->rtc_mr;
        R32(0x60001204u) = 0x5A5A5A5Au;
        SC_CHECK(SENSING_IP_REGS->rtc_mr == mr0, "write to 0x6000_1204 does not change RTCMR");
        SC_CHECK(R32(0x60001200u) == 0, "read of 0x6000_1200 reads 0, not RTCDR");
        /* RTC sub-word writes are dropped */
        R8(BASE + 0x204) = 0x00; R16(BASE + 0x206) = 0x0000;
        SC_CHECK(SENSING_IP_REGS->rtc_mr == mr0, "byte/half stores to RTCMR are dropped");
        SENSING_IP_REGS->rtc_mr = 0xFFFFFF00u;
    }

    /* ---- back-to-back loads and stores from a tight loop ---- */
    {
        volatile uint32_t *p = &SENSING_IP_REGS->pll_control;
        volatile uint32_t *a = &SENSING_IP_REGS->amux;
        uint32_t acc = 0;
        for (i = 0; i < 256; i++) {
            *p = i; *a = ~i;
            acc += *p + *a;
            acc += SENSING_IP_REGS->rtc_dr & 0;        /* RTC passthrough in the same loop */
        }
        SC_CHECK(acc == 256u * 0xFFFFFFFFu, "tight-loop STR/LDR to PLL/AMUX/RTCDR: every read-back exact");
        *p = 0; *a = 0;
    }

    SENSING_IP_REGS->rtc_ctrl = RTC_CTRL_POLL_ENABLE;
    sc_finish("sensing_regmap_test");
    return 0;
}
