// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vrtc_control_tb.h for the primary calling header

#include "Vrtc_control_tb__pch.h"
#include "Vrtc_control_tb__Syms.h"
#include "Vrtc_control_tb___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__act(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vrtc_control_tb___024root___eval_triggers__act(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.rtc_control_tb__DOT__PCLK) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PCLK__0))));
    vlSelfRef.__VactTriggered.set(1U, ((~ (IData)(vlSelfRef.rtc_control_tb__DOT__PRESETn)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0)));
    vlSelfRef.__VactTriggered.set(2U, ((IData)(vlSelfRef.rtc_control_tb__DOT__CLK1HZ) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__CLK1HZ__0))));
    vlSelfRef.__VactTriggered.set(3U, ((~ (IData)(vlSelfRef.rtc_control_tb__DOT__nRTCRST)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__nRTCRST__0)));
    vlSelfRef.__VactTriggered.set(4U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__VactTriggered.set(5U, ((IData)(vlSelfRef.rtc_control_tb__DOT__PRESETn) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0))));
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PCLK__0 
        = vlSelfRef.rtc_control_tb__DOT__PCLK;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0 
        = vlSelfRef.rtc_control_tb__DOT__PRESETn;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__CLK1HZ__0 
        = vlSelfRef.rtc_control_tb__DOT__CLK1HZ;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__nRTCRST__0 
        = vlSelfRef.rtc_control_tb__DOT__nRTCRST;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vrtc_control_tb___024root___dump_triggers__act(vlSelf);
    }
#endif
}
