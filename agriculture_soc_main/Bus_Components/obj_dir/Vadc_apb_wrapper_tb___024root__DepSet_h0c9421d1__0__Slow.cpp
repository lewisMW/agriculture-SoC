// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vadc_apb_wrapper_tb.h for the primary calling header

#include "Vadc_apb_wrapper_tb__pch.h"
#include "Vadc_apb_wrapper_tb___024root.h"

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___eval_static(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_static\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___eval_final(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_final\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___dump_triggers__stl(Vadc_apb_wrapper_tb___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vadc_apb_wrapper_tb___024root___eval_phase__stl(Vadc_apb_wrapper_tb___024root* vlSelf);

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___eval_settle(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_settle\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vadc_apb_wrapper_tb___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("adc_apb_wrapper_tb.v", 5, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vadc_apb_wrapper_tb___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___dump_triggers__stl(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___dump_triggers__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___stl_sequent__TOP__0(Vadc_apb_wrapper_tb___024root* vlSelf);
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root____Vm_traceActivitySetAll(Vadc_apb_wrapper_tb___024root* vlSelf);

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___eval_stl(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vadc_apb_wrapper_tb___024root___stl_sequent__TOP__0(vlSelf);
        Vadc_apb_wrapper_tb___024root____Vm_traceActivitySetAll(vlSelf);
    }
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___stl_sequent__TOP__0(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___stl_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL 
        = (3U & vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__amux_reg);
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__read_enable 
        = ((~ (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE)) 
           & (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL));
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en 
        = ((0x10U != (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count)) 
           & (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid));
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_data_out 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem
        [vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr];
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT 
        = (IData)((vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem
                   [vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr] 
                   >> 0x18U));
    vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__write_enable 
        = ((IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL) 
           & ((IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE) 
              & (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE)));
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___eval_triggers__stl(Vadc_apb_wrapper_tb___024root* vlSelf);

VL_ATTR_COLD bool Vadc_apb_wrapper_tb___024root___eval_phase__stl(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_phase__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vadc_apb_wrapper_tb___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vadc_apb_wrapper_tb___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___dump_triggers__act(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___dump_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge adc_apb_wrapper_tb.PCLK)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(negedge adc_apb_wrapper_tb.PRESETn)\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @([changed] adc_apb_wrapper_tb.uut.status_reg)\n");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 3 is active: @([changed] adc_apb_wrapper_tb.uut.__Vcellinp__adc_inst__MEASUREMENT)\n");
    }
    if ((0x10ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 4 is active: @([changed] adc_apb_wrapper_tb.uut.pll_reg)\n");
    }
    if ((0x20ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 5 is active: @([changed] adc_apb_wrapper_tb.uut.trig_reg)\n");
    }
    if ((0x40ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 6 is active: @([changed] adc_apb_wrapper_tb.uut.analog_passthrough)\n");
    }
    if ((0x80ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 7 is active: @([changed] adc_apb_wrapper_tb.uut.__Vcellinp__amux_inst__INPUT_SEL)\n");
    }
    if ((0x100ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 8 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___dump_triggers__nba(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___dump_triggers__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge adc_apb_wrapper_tb.PCLK)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(negedge adc_apb_wrapper_tb.PRESETn)\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @([changed] adc_apb_wrapper_tb.uut.status_reg)\n");
    }
    if ((8ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 3 is active: @([changed] adc_apb_wrapper_tb.uut.__Vcellinp__adc_inst__MEASUREMENT)\n");
    }
    if ((0x10ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 4 is active: @([changed] adc_apb_wrapper_tb.uut.pll_reg)\n");
    }
    if ((0x20ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 5 is active: @([changed] adc_apb_wrapper_tb.uut.trig_reg)\n");
    }
    if ((0x40ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 6 is active: @([changed] adc_apb_wrapper_tb.uut.analog_passthrough)\n");
    }
    if ((0x80ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 7 is active: @([changed] adc_apb_wrapper_tb.uut.__Vcellinp__amux_inst__INPUT_SEL)\n");
    }
    if ((0x100ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 8 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root____Vm_traceActivitySetAll(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root____Vm_traceActivitySetAll\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vm_traceActivity[0U] = 1U;
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.__Vm_traceActivity[3U] = 1U;
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___ctor_var_reset(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___ctor_var_reset\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->adc_apb_wrapper_tb__DOT__PCLK = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__PRESETn = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__PSEL = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__PADDR = VL_RAND_RESET_I(12);
    vlSelf->adc_apb_wrapper_tb__DOT__PENABLE = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__PWRITE = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__PWDATA = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__PRDATA = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__PREADY = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__adc_data = VL_RAND_RESET_Q(56);
    vlSelf->adc_apb_wrapper_tb__DOT__adc_data_valid = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__amux_reg = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__status_reg = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__adc_trig = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo_data_out = VL_RAND_RESET_Q(56);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__read_enable = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__write_enable = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough = VL_RAND_RESET_I(1);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT = VL_RAND_RESET_I(32);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL = VL_RAND_RESET_I(2);
    for (int __Vi0 = 0; __Vi0 < 16; ++__Vi0) {
        vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[__Vi0] = VL_RAND_RESET_Q(56);
    }
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr = VL_RAND_RESET_I(4);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr = VL_RAND_RESET_I(4);
    vlSelf->adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count = VL_RAND_RESET_I(5);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PCLK__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PRESETn__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__status_reg__0 = VL_RAND_RESET_I(32);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT__0 = VL_RAND_RESET_I(32);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg__0 = VL_RAND_RESET_I(32);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg__0 = VL_RAND_RESET_I(32);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL__0 = VL_RAND_RESET_I(2);
    vlSelf->__VactDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
