// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfifo_apb_adc_tb.h for the primary calling header

#include "Vfifo_apb_adc_tb__pch.h"
#include "Vfifo_apb_adc_tb__Syms.h"
#include "Vfifo_apb_adc_tb___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfifo_apb_adc_tb___024root___dump_triggers__act(Vfifo_apb_adc_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vfifo_apb_adc_tb___024root___eval_triggers__act(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__clk) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__clk__0))));
    vlSelfRef.__VactTriggered.set(1U, ((~ (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__rst_n)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__rst_n__0)));
    vlSelfRef.__VactTriggered.set(2U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__VactTriggered.set(3U, ((~ (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__clk)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__clk__0)));
    vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__clk__0 
        = vlSelfRef.fifo_apb_adc_tb__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__rst_n__0 
        = vlSelfRef.fifo_apb_adc_tb__DOT__rst_n;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfifo_apb_adc_tb___024root___dump_triggers__act(vlSelf);
    }
#endif
}
