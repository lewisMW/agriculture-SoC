// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vrtc_control_tb.h for the primary calling header

#include "Vrtc_control_tb__pch.h"
#include "Vrtc_control_tb___024root.h"

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_static(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_static\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_final(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_final\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__stl(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vrtc_control_tb___024root___eval_phase__stl(Vrtc_control_tb___024root* vlSelf);

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_settle(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_settle\n"); );
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
            Vrtc_control_tb___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("rtc_control_tb.v", 3, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vrtc_control_tb___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__stl(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___dump_triggers__stl\n"); );
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

void Vrtc_control_tb___024root___act_comb__TOP__0(Vrtc_control_tb___024root* vlSelf);

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_stl(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vrtc_control_tb___024root___act_comb__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_triggers__stl(Vrtc_control_tb___024root* vlSelf);

VL_ATTR_COLD bool Vrtc_control_tb___024root___eval_phase__stl(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_phase__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vrtc_control_tb___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vrtc_control_tb___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__act(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___dump_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge rtc_control_tb.PCLK)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(negedge rtc_control_tb.PRESETn)\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(posedge rtc_control_tb.CLK1HZ)\n");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 3 is active: @(negedge rtc_control_tb.nRTCRST)\n");
    }
    if ((0x10ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 4 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((0x20ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 5 is active: @(posedge rtc_control_tb.PRESETn)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__nba(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___dump_triggers__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge rtc_control_tb.PCLK)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(negedge rtc_control_tb.PRESETn)\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(posedge rtc_control_tb.CLK1HZ)\n");
    }
    if ((8ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 3 is active: @(negedge rtc_control_tb.nRTCRST)\n");
    }
    if ((0x10ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 4 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((0x20ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 5 is active: @(posedge rtc_control_tb.PRESETn)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vrtc_control_tb___024root___ctor_var_reset(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___ctor_var_reset\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->rtc_control_tb__DOT__PCLK = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__PRESETn = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__PSEL = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__PENABLE = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__PWRITE = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__PADDR = VL_RAND_RESET_I(12);
    vlSelf->rtc_control_tb__DOT__PWDATA = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__PRDATA = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__PREADY = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__CLK1HZ = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__nRTCRST = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__nPOR = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__ctrl_read_time_en = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__ctrl_time_value = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__ctrl_set_match_en = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__ctrl_match_value = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__ctrl_clear_intr = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__test_mask_enable = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__timeout_counter = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__apb_write_extended__Vstatic__i = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__dut__DOT__state = VL_RAND_RESET_I(3);
    vlSelf->rtc_control_tb__DOT__dut__DOT__next_state = VL_RAND_RESET_I(3);
    vlSelf->rtc_control_tb__DOT__dut__DOT__RTCLR_reg = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__dut__DOT__RTCCR_enable = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__apb_clear_req = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__RTCMR_reg = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__dut__DOT__counter_sync = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz = VL_RAND_RESET_I(32);
    vlSelf->rtc_control_tb__DOT__dut__DOT__load_req_latched = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__load_req_1hz = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__load_req_ack = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__intr_flag = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync = VL_RAND_RESET_I(1);
    vlSelf->rtc_control_tb__DOT__dut__DOT__counter_sync_ff = VL_RAND_RESET_I(32);
    vlSelf->__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz = VL_RAND_RESET_I(32);
    vlSelf->__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PCLK__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rtc_control_tb__DOT__CLK1HZ__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rtc_control_tb__DOT__nRTCRST__0 = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 6; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
