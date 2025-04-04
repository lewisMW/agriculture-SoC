// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vrtc_control_tb.h for the primary calling header

#include "Vrtc_control_tb__pch.h"
#include "Vrtc_control_tb__Syms.h"
#include "Vrtc_control_tb___024root.h"

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_initial__TOP(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial__TOP\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlWide<3>/*95:0*/ __Vtemp_1;
    // Body
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = 0U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en = 0U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en = 0U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_match_value = 0U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr = 0U;
    vlSelfRef.rtc_control_tb__DOT__test_mask_enable = 1U;
    __Vtemp_1[0U] = 0x2e766364U;
    __Vtemp_1[1U] = 0x666f726dU;
    __Vtemp_1[2U] = 0x77617665U;
    vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(3, __Vtemp_1));
    vlSymsp->_traceDumpOpen();
    vlSymsp->_traceDumpOpen();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__stl(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_triggers__stl(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_triggers__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered.set(0U, (IData)(vlSelfRef.__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vrtc_control_tb___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
