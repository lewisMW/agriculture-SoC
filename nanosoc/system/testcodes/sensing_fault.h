#ifndef SENSING_FAULT_H
#define SENSING_FAULT_H
/*
 * sensing_fault.h - production HardFault backstop for the sensing node.
 *
 * The CMSDK startup installs only a WEAK HardFault_Handler that dead-loops
 * (`b .`), so any unexpected bus fault would HANG the device forever (see
 * pslverr_test / TEST_RUNBOOK §3.5). The known RTC hang vector is already gone
 * at the source: rtc_control_2 now inserts APB wait states instead of returning
 * PSLVERR when a passthrough access collides with an autonomous arm cycle, so an
 * unguarded RTC read can no longer fault the CPU. This handler is the *backstop*
 * for any OTHER unexpected bus fault: instead of hanging, it requests a
 * controlled system reset (SYSRESETREQ -> HRESETn, wired through the core /
 * reset controller in nanosoc) so the node reboots to a known-good state. The
 * reset cause is latched in the sysctrl resetinfo register (bit 0), so post-reset
 * firmware can tell it recovered from a fault rather than powered on cleanly.
 *
 * Recovery choice: a controlled reset is the safe generic policy for an
 * unattended sensor node - a fault means the program state is suspect, so
 * restarting beats continuing with corrupted state. (Cortex-M0 has no fault
 * status registers, so there is nothing to inspect and selectively recover.)
 *
 * OPT-IN, so it never clashes with tests that install their own handler
 * (e.g. pslverr_test, aes128_tests_dma230). In PRODUCTION firmware, before the
 * include:
 *     #define SENSING_INSTALL_HARDFAULT_HANDLER
 *     #include "../sensing_fault.h"
 * Exactly one compiled translation unit may define the macro - the testcode
 * build only compiles TESTNAME.c, so that holds. printf-free (fault context).
 */
#include <stdint.h>

#ifdef SENSING_INSTALL_HARDFAULT_HANDLER

#ifdef CORTEX_M0
#include "CMSDK_CM0.h"
#include "core_cm0.h"
#endif
#ifdef CORTEX_M0PLUS
#include "CMSDK_CM0plus.h"
#include "core_cm0plus.h"
#endif

/* Firmware may define SENSING_FAULT_MARK() to leave a breadcrumb (a UART byte, a
 * GPIO toggle, a marker written to a retained register, ...) before the reset.
 * Keep it tiny and non-blocking - we are in fault exception context. Default:
 * nothing. */
#ifndef SENSING_FAULT_MARK
#define SENSING_FAULT_MARK()  ((void)0)
#endif

/*
 * Strong override of the weak startup HardFault_Handler. Never returns
 * (returning would re-run the faulting instruction -> refault loop). Requests a
 * system reset so the device recovers instead of dead-looping forever.
 */
void HardFault_Handler(void)
{
    SENSING_FAULT_MARK();
    NVIC_SystemReset();          /* SYSRESETREQ -> HRESETn; does not return */
    for (;;) { }                 /* fallback if SYSRESETREQ is not wired */
}

#endif /* SENSING_INSTALL_HARDFAULT_HANDLER */
#endif /* SENSING_FAULT_H */
