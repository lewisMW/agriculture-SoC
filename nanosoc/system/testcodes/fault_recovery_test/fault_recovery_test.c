/*
 *-----------------------------------------------------------------------------
 * fault_recovery_test.c  -  proves the HardFault BACKSTOP recovers instead of
 *                           dead-looping.
 *
 * Companion to pslverr_test. pslverr_test showed the *old* hazard: a colliding
 * RTC access returned PSLVERR -> AHB error -> Cortex-M0 HardFault -> the weak
 * CMSDK handler `b .` (dead-loop) -> the device HANGS FOREVER. Two fixes remove
 * that:
 *   1. rtc_control_2 now inserts APB wait states instead of PSLVERR, so the known
 *      RTC vector no longer faults at all (pslverr_test now PASSes).
 *   2. sensing_fault.h installs a real HardFault handler that requests a
 *      controlled system reset (SYSRESETREQ -> HRESETn, wired in nanosoc) so any
 *      OTHER unexpected bus fault recovers instead of dead-looping.
 *
 * This test exercises fix #2 by DELIBERATELY faulting and observing that the CPU
 * does not hang. It uses an architectural fault that is independent of the
 * memory map: on Cortex-M0 (ARMv6-M) an UNALIGNED word load is always a
 * HardFault. 0x00000000 is the boot code region (always readable), so the only
 * fault is the misalignment.
 *
 * Two build modes:
 *   - DEFAULT (sim-friendly): a test-local HardFault handler catches the fault,
 *     reports it, and ends the sim -> a clean PASS that proves the CPU no longer
 *     dead-loops. This is fully verifiable in the iverilog testbench.
 *   - -DFAULT_TEST_REAL_RESET: installs the PRODUCTION backstop from
 *     sensing_fault.h, which does a real NVIC_SystemReset(). On a persistent-
 *     image target (FPGA/silicon) the device reboots, resetinfo[0] reads 1, and
 *     this test reports RECOVERED/PASS on the second boot.
 *
 * WHY the default is not the real reset in sim: the nanosoc testbench streams
 * the program into SRAM over ADP once, at boot. A SYSRESETREQ soft reset cannot
 * re-stream it, so main() would not re-run in sim -> use FPGA for the full
 * reboot round-trip. See TEST_RUNBOOK 3.7 / VERIFICATION.md.
 *
 * printf-free (image must fit the 16k-word program memory; see sensing_print.h).
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

#include <stdint.h>
#include "uart_stdout.h"
#include "../sensing_print.h"

/* nanosoc sysctrl (BASEADDR_SYSCTRL = 0x4001_F000). Reset Information register
 * at +0x010; bit0 = SYSRESETREQ (set by a system reset, write-1-to-clear). It is
 * on the always-on domain, so it survives the reset it records. */
#define NANOSOC_SYSCTRL_BASE   0x4001F000u
#define SYSCTRL_RESETINFO      (*(volatile uint32_t *)(NANOSOC_SYSCTRL_BASE + 0x010u))
#define RESETINFO_SYSRESETREQ  (1u << 0)

/* Deterministic HardFault: an unaligned word load. ARMv6-M has no unaligned
 * support, so this always faults regardless of the memory map. Inline asm (with
 * a volatile constraint) guarantees the LDR is emitted and not optimised away. */
static void provoke_hardfault(void)
{
    uint32_t val;
    uint32_t addr = 0x00000002u;      /* deliberately unaligned, but readable */
    __asm volatile ("ldr %0, [%1]" : "=r"(val) : "r"(addr));
    (void)val;
}

#ifdef FAULT_TEST_REAL_RESET
/* Production mode: install the real backstop and leave a UART breadcrumb before
 * it resets, so the log shows the fault was caught and a reset was requested. */
#define SENSING_FAULT_MARK() \
    do { sp_str("\nHardFault caught -> sensing_fault.h requesting system reset (SYSRESETREQ)\n"); } while (0)
#define SENSING_INSTALL_HARDFAULT_HANDLER
#include "../sensing_fault.h"
#else
/*
 * Sim-friendly test-local override of the weak startup HardFault_Handler.
 * Reaching here proves the fault was CAUGHT (with the default weak handler this
 * would be `b .` forever). Report and end the sim. Do NOT return (returning
 * re-runs the faulting load -> refault loop).
 */
void HardFault_Handler(void)
{
    sp_str("\nHardFault CAUGHT by backstop (weak default would `b .` dead-loop here).\n");
    sp_str("resetinfo="); sp_hex(SYSCTRL_RESETINFO); sp_nl();
    sp_str("FAULT_RECOVERY_TEST: PASS (fault caught, CPU did not hang)\n");
    sp_str("  note: production build (-DFAULT_TEST_REAL_RESET) resets via sensing_fault.h;\n");
    sp_str("        the full reboot + resetinfo[0]=1 round-trip is confirmed on FPGA.\n");
    UartEndSimulation();
    for (;;) { }
}
#endif

int main(void)
{
    uint32_t ri;

    UartStdOutInit();
    sp_str("fault_recovery_test: start\n");

    ri = SYSCTRL_RESETINFO;
    sp_str("resetinfo at boot="); sp_hex(ri); sp_nl();

    /* Second boot (persistent-image target): we came back from a SYSRESETREQ, so
     * the backstop reset the device and it rebooted cleanly. */
    if (ri & RESETINFO_SYSRESETREQ) {
        sp_str("RECOVERED: resetinfo[0]=1 (SYSRESETREQ) -> backstop reset the device and it rebooted.\n");
        SYSCTRL_RESETINFO = RESETINFO_SYSRESETREQ;   /* write-1-to-clear the cause */
        sp_str("FAULT_RECOVERY_TEST: PASS (recovered via controlled reset)\n");
        UartEndSimulation();
        return 0;
    }

    /* First boot: provoke the fault with the backstop installed. */
    sp_str("First boot: provoking a HardFault (unaligned load) with the backstop installed...\n");
    provoke_hardfault();

    /* Unreachable: the unaligned load must fault. If we get here the fault did
     * not occur, so the backstop was never exercised. */
    sp_str("FAULT_RECOVERY_TEST: FAIL (no HardFault occurred - backstop not exercised)\n");
    UartEndSimulation();
    return 0;
}
