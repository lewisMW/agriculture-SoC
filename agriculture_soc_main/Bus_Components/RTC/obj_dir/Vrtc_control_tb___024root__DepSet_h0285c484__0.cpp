// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vrtc_control_tb.h for the primary calling header

#include "Vrtc_control_tb__pch.h"
#include "Vrtc_control_tb___024root.h"

VL_ATTR_COLD void Vrtc_control_tb___024root___eval_initial__TOP(Vrtc_control_tb___024root* vlSelf);
VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__0(Vrtc_control_tb___024root* vlSelf);
VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__1(Vrtc_control_tb___024root* vlSelf);
VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__2(Vrtc_control_tb___024root* vlSelf);
VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__3(Vrtc_control_tb___024root* vlSelf);

void Vrtc_control_tb___024root___eval_initial(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vrtc_control_tb___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__2(vlSelf);
    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__3(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PCLK__0 
        = vlSelfRef.rtc_control_tb__DOT__PCLK;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0 
        = vlSelfRef.rtc_control_tb__DOT__PRESETn;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__CLK1HZ__0 
        = vlSelfRef.rtc_control_tb__DOT__CLK1HZ;
    vlSelfRef.__Vtrigprevexpr___TOP__rtc_control_tb__DOT__nRTCRST__0 
        = vlSelfRef.rtc_control_tb__DOT__nRTCRST;
}

VL_INLINE_OPT VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__0(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rtc_control_tb__DOT__PCLK = 0U;
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0x1388ULL, 
                                             nullptr, 
                                             "rtc_control_tb.v", 
                                             79);
        vlSelfRef.rtc_control_tb__DOT__PCLK = (1U & 
                                               (~ (IData)(vlSelfRef.rtc_control_tb__DOT__PCLK)));
    }
}

VL_INLINE_OPT VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__1(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rtc_control_tb__DOT__CLK1HZ = 0U;
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0xc350ULL, 
                                             nullptr, 
                                             "rtc_control_tb.v", 
                                             85);
        vlSelfRef.rtc_control_tb__DOT__CLK1HZ = (1U 
                                                 & (~ (IData)(vlSelfRef.rtc_control_tb__DOT__CLK1HZ)));
    }
}

VL_INLINE_OPT VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__2(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__2\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rtc_control_tb__DOT__PRESETn = 0U;
    vlSelfRef.rtc_control_tb__DOT__nRTCRST = 0U;
    vlSelfRef.rtc_control_tb__DOT__nPOR = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         95);
    vlSelfRef.rtc_control_tb__DOT__PRESETn = 1U;
    vlSelfRef.rtc_control_tb__DOT__nRTCRST = 1U;
    vlSelfRef.rtc_control_tb__DOT__nPOR = 1U;
}

VL_INLINE_OPT VlCoroutine Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__3(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_initial__TOP__Vtiming__3\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    SData/*11:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr = 0;
    IData/*31:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__0__data;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__0__data = 0;
    SData/*11:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr = 0;
    IData/*31:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__1__data;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__1__data = 0;
    SData/*11:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr = 0;
    IData/*31:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__2__data;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__2__data = 0;
    SData/*11:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr = 0;
    IData/*31:0*/ __Vtask_rtc_control_tb__DOT__apb_write_extended__3__data;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__3__data = 0;
    SData/*11:0*/ __Vtask_rtc_control_tb__DOT__apb_read__4__addr;
    __Vtask_rtc_control_tb__DOT__apb_read__4__addr = 0;
    // Body
    co_await vlSelfRef.__VtrigSched_h11424186__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PRESETn)", 
                                                         "rtc_control_tb.v", 
                                                         193);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x7530ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         194);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__0__data = 0x64U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr = 0x208U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         146);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE start: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__0__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 1U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = __Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = __Vtask_rtc_control_tb__DOT__apb_write_extended__0__data;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         153);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 2U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 3U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 4U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 5U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 6U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 7U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 8U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 9U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xaU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xbU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xcU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xdU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xeU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xfU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x10U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x11U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x12U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x13U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x14U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE done: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__0__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__0__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    co_await vlSelfRef.__VdlySched.delay(0xf4240ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         198);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__1__data = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr = 0x20cU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         146);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE start: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__1__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 1U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = __Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = __Vtask_rtc_control_tb__DOT__apb_write_extended__1__data;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         153);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 2U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 3U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 4U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 5U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 6U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 7U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 8U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 9U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xaU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xbU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xcU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xdU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xeU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xfU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x10U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x11U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x12U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x13U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x14U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE done: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__1__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__1__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    co_await vlSelfRef.__VdlySched.delay(0xf4240ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         202);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__2__data = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr = 0x210U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         146);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE start: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__2__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 1U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = __Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = __Vtask_rtc_control_tb__DOT__apb_write_extended__2__data;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         153);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 2U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 3U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 4U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 5U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 6U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 7U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 8U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 9U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xaU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xbU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xcU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xdU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xeU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xfU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x10U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x11U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x12U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x13U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x14U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE done: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__2__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__2__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    co_await vlSelfRef.__VdlySched.delay(0xf4240ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         206);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x2dc6c0ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         209);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("CU: Request read current RTC time at time %t\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         214);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en = 0U;
    VL_WRITEF_NX("CU: RTC time = %10# at time %t\n",0,
                 32,vlSelfRef.rtc_control_tb__DOT__ctrl_time_value,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en = 1U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_match_value 
        = ((IData)(0xaU) + vlSelfRef.rtc_control_tb__DOT__ctrl_time_value);
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         221);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en = 0U;
    VL_WRITEF_NX("CU: Set match value = %10# at time %t\n",0,
                 32,vlSelfRef.rtc_control_tb__DOT__ctrl_match_value,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__timeout_counter = 0U;
    while (((~ ((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg) 
                & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag))) 
            & VL_GTS_III(32, 0x3e8U, vlSelfRef.rtc_control_tb__DOT__timeout_counter))) {
        co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge rtc_control_tb.PCLK)", 
                                                             "rtc_control_tb.v", 
                                                             228);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        vlSelfRef.rtc_control_tb__DOT__timeout_counter 
            = ((IData)(1U) + vlSelfRef.rtc_control_tb__DOT__timeout_counter);
    }
    if (VL_LTES_III(32, 0x3e8U, vlSelfRef.rtc_control_tb__DOT__timeout_counter)) {
        VL_WRITEF_NX("Timeout waiting for RTC interrupt at time %t\n",0,
                     64,VL_TIME_UNITED_Q(1000),-9);
    } else {
        VL_WRITEF_NX("RTC Interrupt triggered at time %t, CU RTC time = %10#\n",0,
                     64,VL_TIME_UNITED_Q(1000),-9,32,
                     vlSelfRef.rtc_control_tb__DOT__ctrl_time_value);
    }
    __Vtask_rtc_control_tb__DOT__apb_write_extended__3__data = 1U;
    __Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr = 0x21cU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         146);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE start: addr=0x%03x, data=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__3__data,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 1U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = __Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = __Vtask_rtc_control_tb__DOT__apb_write_extended__3__data;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         153);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 2U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 3U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 4U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 5U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 6U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 7U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 8U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 9U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xaU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xbU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xcU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xdU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xeU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0xfU;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x10U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x11U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x12U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x13U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         158);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i = 0x14U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    VL_WRITEF_NX("TB: APB EXTENDED WRITE done: addr=0x%03x, data=0x%08x, time=%t\nInterrupt cleared at time %t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_write_extended__3__addr,
                 32,__Vtask_rtc_control_tb__DOT__apb_write_extended__3__data,
                 64,VL_TIME_UNITED_Q(1000),-9,64,VL_TIME_UNITED_Q(1000),
                 -9);
    __Vtask_rtc_control_tb__DOT__apb_read__4__addr = 0x200U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         172);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: APB READ start: addr=0x%03x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_read__4__addr,
                 64,VL_TIME_UNITED_Q(1000),-9);
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PWRITE = 0U;
    vlSelfRef.rtc_control_tb__DOT__PADDR = __Vtask_rtc_control_tb__DOT__apb_read__4__addr;
    vlSelfRef.rtc_control_tb__DOT__PWDATA = 0U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         179);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 1U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h79186ef2__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge rtc_control_tb.PCLK)", 
                                                         "rtc_control_tb.v", 
                                                         182);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.rtc_control_tb__DOT__PSEL = 0U;
    vlSelfRef.rtc_control_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("TB: APB READ done: addr=0x%03x, PRDATA=0x%08x, time=%t\n",0,
                 12,__Vtask_rtc_control_tb__DOT__apb_read__4__addr,
                 32,vlSelfRef.rtc_control_tb__DOT__PRDATA,
                 64,VL_TIME_UNITED_Q(1000),-9);
    co_await vlSelfRef.__VdlySched.delay(0x7a120ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         242);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("TB: Final read RTCDR => 0x%08x at time %t\n",0,
                 32,vlSelfRef.rtc_control_tb__DOT__PRDATA,
                 64,VL_TIME_UNITED_Q(1000),-9);
    co_await vlSelfRef.__VdlySched.delay(0x1e8480ULL, 
                                         nullptr, "rtc_control_tb.v", 
                                         246);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_FINISH_MT("rtc_control_tb.v", 247, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

void Vrtc_control_tb___024root___act_comb__TOP__0(Vrtc_control_tb___024root* vlSelf);

void Vrtc_control_tb___024root___eval_act(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x31ULL & vlSelfRef.__VactTriggered.word(0U))) {
        Vrtc_control_tb___024root___act_comb__TOP__0(vlSelf);
    }
}

extern const VlUnpacked<CData/*2:0*/, 64> Vrtc_control_tb__ConstPool__TABLE_h98eafea8_0;

VL_INLINE_OPT void Vrtc_control_tb___024root___act_comb__TOP__0(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___act_comb__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*5:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    // Body
    __Vtableidx1 = (((IData)(vlSelfRef.rtc_control_tb__DOT__PWRITE) 
                     << 5U) | (((IData)(vlSelfRef.rtc_control_tb__DOT__PENABLE) 
                                << 4U) | (((IData)(vlSelfRef.rtc_control_tb__DOT__PSEL) 
                                           << 3U) | (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state))));
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__next_state 
        = Vrtc_control_tb__ConstPool__TABLE_h98eafea8_0
        [__Vtableidx1];
    vlSelfRef.rtc_control_tb__DOT__PRDATA = 0U;
    if (((3U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)) 
         | (4U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)))) {
        vlSelfRef.rtc_control_tb__DOT__PRDATA = (((
                                                   ((((((0x200U 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR)) 
                                                        | (0x204U 
                                                           == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                       | (0x208U 
                                                          == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                      | (0x20cU 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                     | (0x210U 
                                                        == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                    | (0x214U 
                                                       == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                   | (0x218U 
                                                      == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                  | (0x21cU 
                                                     == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR)))
                                                  ? 
                                                 ((0x200U 
                                                   == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                   ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync
                                                   : 
                                                  ((0x204U 
                                                    == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                    ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg
                                                    : 
                                                   ((0x208U 
                                                     == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                     ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg
                                                     : 
                                                    ((0x20cU 
                                                      == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                      ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable)
                                                      : 
                                                     ((0x210U 
                                                       == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                       ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg)
                                                       : 
                                                      ((0x214U 
                                                        == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                        ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag)
                                                        : 
                                                       ((0x218U 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                         ? 
                                                        ((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag) 
                                                         & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg))
                                                         : 0U)))))))
                                                  : 0U);
    }
}

void Vrtc_control_tb___024root___nba_sequent__TOP__0(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_sequent__TOP__1(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_sequent__TOP__2(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_sequent__TOP__3(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_sequent__TOP__4(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_comb__TOP__0(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___nba_comb__TOP__1(Vrtc_control_tb___024root* vlSelf);

void Vrtc_control_tb___024root___eval_nba(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0xcULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_sequent__TOP__1(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_sequent__TOP__2(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
    if ((0xcULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_sequent__TOP__3(vlSelf);
        vlSelfRef.__Vm_traceActivity[4U] = 1U;
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_sequent__TOP__4(vlSelf);
        vlSelfRef.__Vm_traceActivity[5U] = 1U;
    }
    if ((0x33ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_comb__TOP__0(vlSelf);
    }
    if ((0x3fULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vrtc_control_tb___024root___nba_comb__TOP__1(vlSelf);
    }
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_sequent__TOP__0(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack 
        = vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_ack;
    vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz 
        = vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz;
    if (vlSelfRef.rtc_control_tb__DOT__nRTCRST) {
        if (((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable) 
             | (IData)(vlSelfRef.rtc_control_tb__DOT__test_mask_enable))) {
            if (vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_1hz) {
                vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack = 1U;
                vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz 
                    = vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg;
            } else {
                vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack = 0U;
                vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz 
                    = ((IData)(1U) + vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz);
            }
        }
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_1hz 
            = vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched;
    } else {
        vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack = 0U;
        vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_1hz = 0U;
    }
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_sequent__TOP__1(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_sequent__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY((0ULL == VL_MODDIV_QQQ(64, (QData)(VL_TIME_UNITED_Q(1000)), 0x1f4ULL)))) {
        VL_WRITEF_NX("Time: %t, CU RTC = %10#, Intr = %b\n",0,
                     64,VL_TIME_UNITED_Q(1000),-9,32,
                     vlSelfRef.rtc_control_tb__DOT__ctrl_time_value,
                     1,((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg) 
                        & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag)));
    }
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_sequent__TOP__2(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_sequent__TOP__2\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.rtc_control_tb__DOT__PRESETn) {
        vlSelfRef.rtc_control_tb__DOT__PREADY = ((2U 
                                                  == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)) 
                                                 | (3U 
                                                    == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)));
        if ((2U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state))) {
            if ((0x208U == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg 
                    = vlSelfRef.rtc_control_tb__DOT__PWDATA;
            }
            if ((0x208U != (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                if ((0x20cU != (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                    if ((0x210U == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                        vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg 
                            = (1U & vlSelfRef.rtc_control_tb__DOT__PWDATA);
                    }
                }
            }
        }
        if (((2U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)) 
             & (0x208U == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR)))) {
            vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched = 1U;
        } else if (vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_ack) {
            vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched = 0U;
        }
        if (vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en) {
            vlSelfRef.rtc_control_tb__DOT__ctrl_time_value 
                = vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync;
        }
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync 
            = vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync_ff;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync_ff 
            = vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz;
    } else {
        vlSelfRef.rtc_control_tb__DOT__PREADY = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched = 0U;
        vlSelfRef.rtc_control_tb__DOT__ctrl_time_value = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync_ff = 0U;
    }
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_sequent__TOP__3(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_sequent__TOP__3\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_ack 
        = vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack;
    if (vlSelfRef.rtc_control_tb__DOT__nRTCRST) {
        if (((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable) 
             | (IData)(vlSelfRef.rtc_control_tb__DOT__test_mask_enable))) {
            if (vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync) {
                vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag = 0U;
            } else if ((vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz 
                        == vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg)) {
                vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag = 1U;
            }
        }
    } else {
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag = 0U;
    }
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz 
        = vlSelfRef.__Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz;
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync 
        = ((IData)(vlSelfRef.rtc_control_tb__DOT__nRTCRST) 
           && (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff));
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff 
        = ((IData)(vlSelfRef.rtc_control_tb__DOT__nRTCRST) 
           && ((IData)(vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr) 
               | (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req)));
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_sequent__TOP__4(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_sequent__TOP__4\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.rtc_control_tb__DOT__PRESETn) {
        if (vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en) {
            vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg 
                = vlSelfRef.rtc_control_tb__DOT__ctrl_match_value;
        }
        if ((2U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state))) {
            if ((0x208U != (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                if ((0x20cU == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                    vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable 
                        = (1U & vlSelfRef.rtc_control_tb__DOT__PWDATA);
                }
                if ((0x20cU != (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                    if ((0x210U != (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                        if ((0x21cU == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) {
                            if ((1U & vlSelfRef.rtc_control_tb__DOT__PWDATA)) {
                                vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req = 1U;
                            }
                        }
                    }
                }
            }
        } else {
            vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req = 0U;
        }
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__state 
            = vlSelfRef.rtc_control_tb__DOT__dut__DOT__next_state;
    } else {
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req = 0U;
        vlSelfRef.rtc_control_tb__DOT__dut__DOT__state = 0U;
    }
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_comb__TOP__0(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_comb__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*5:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    // Body
    __Vtableidx1 = (((IData)(vlSelfRef.rtc_control_tb__DOT__PWRITE) 
                     << 5U) | (((IData)(vlSelfRef.rtc_control_tb__DOT__PENABLE) 
                                << 4U) | (((IData)(vlSelfRef.rtc_control_tb__DOT__PSEL) 
                                           << 3U) | (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state))));
    vlSelfRef.rtc_control_tb__DOT__dut__DOT__next_state 
        = Vrtc_control_tb__ConstPool__TABLE_h98eafea8_0
        [__Vtableidx1];
}

VL_INLINE_OPT void Vrtc_control_tb___024root___nba_comb__TOP__1(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___nba_comb__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rtc_control_tb__DOT__PRDATA = 0U;
    if (((3U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)) 
         | (4U == (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state)))) {
        vlSelfRef.rtc_control_tb__DOT__PRDATA = (((
                                                   ((((((0x200U 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR)) 
                                                        | (0x204U 
                                                           == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                       | (0x208U 
                                                          == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                      | (0x20cU 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                     | (0x210U 
                                                        == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                    | (0x214U 
                                                       == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                   | (0x218U 
                                                      == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))) 
                                                  | (0x21cU 
                                                     == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR)))
                                                  ? 
                                                 ((0x200U 
                                                   == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                   ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync
                                                   : 
                                                  ((0x204U 
                                                    == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                    ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg
                                                    : 
                                                   ((0x208U 
                                                     == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                     ? vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg
                                                     : 
                                                    ((0x20cU 
                                                      == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                      ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable)
                                                      : 
                                                     ((0x210U 
                                                       == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                       ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg)
                                                       : 
                                                      ((0x214U 
                                                        == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                        ? (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag)
                                                        : 
                                                       ((0x218U 
                                                         == (IData)(vlSelfRef.rtc_control_tb__DOT__PADDR))
                                                         ? 
                                                        ((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag) 
                                                         & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg))
                                                         : 0U)))))))
                                                  : 0U);
    }
}

void Vrtc_control_tb___024root___timing_resume(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___timing_resume\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0x20ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h11424186__0.resume(
                                                   "@(posedge rtc_control_tb.PRESETn)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h79186ef2__0.resume(
                                                   "@(posedge rtc_control_tb.PCLK)");
    }
    if ((0x10ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vrtc_control_tb___024root___timing_commit(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___timing_commit\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (0x20ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h11424186__0.commit(
                                                   "@(posedge rtc_control_tb.PRESETn)");
    }
    if ((! (1ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h79186ef2__0.commit(
                                                   "@(posedge rtc_control_tb.PCLK)");
    }
}

void Vrtc_control_tb___024root___eval_triggers__act(Vrtc_control_tb___024root* vlSelf);

bool Vrtc_control_tb___024root___eval_phase__act(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<6> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vrtc_control_tb___024root___eval_triggers__act(vlSelf);
    Vrtc_control_tb___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vrtc_control_tb___024root___timing_resume(vlSelf);
        Vrtc_control_tb___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vrtc_control_tb___024root___eval_phase__nba(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vrtc_control_tb___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__nba(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vrtc_control_tb___024root___dump_triggers__act(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vrtc_control_tb___024root___eval(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vrtc_control_tb___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("rtc_control_tb.v", 3, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vrtc_control_tb___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("rtc_control_tb.v", 3, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vrtc_control_tb___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vrtc_control_tb___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vrtc_control_tb___024root___eval_debug_assertions(Vrtc_control_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
