// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vadc_apb_wrapper_tb.h for the primary calling header

#include "Vadc_apb_wrapper_tb__pch.h"
#include "Vadc_apb_wrapper_tb__Syms.h"
#include "Vadc_apb_wrapper_tb___024root.h"

VL_INLINE_OPT VlCoroutine Vadc_apb_wrapper_tb___024root___eval_initial__TOP__Vtiming__1(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    SData/*11:0*/ __Vtask_adc_apb_wrapper_tb__DOT__apb_read__0__addr;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__0__addr = 0;
    SData/*11:0*/ __Vtask_adc_apb_wrapper_tb__DOT__apb_read__1__addr;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__1__addr = 0;
    SData/*11:0*/ __Vtask_adc_apb_wrapper_tb__DOT__apb_read__2__addr;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__2__addr = 0;
    SData/*11:0*/ __Vtask_adc_apb_wrapper_tb__DOT__apb_read__3__addr;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__3__addr = 0;
    SData/*11:0*/ __Vtask_adc_apb_wrapper_tb__DOT__apb_read__4__addr;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__4__addr = 0;
    VlWide<3>/*95:0*/ __Vtemp_1;
    // Body
    __Vtemp_1[0U] = 0x2e766364U;
    __Vtemp_1[1U] = 0x666f726dU;
    __Vtemp_1[2U] = 0x77617665U;
    vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(3, __Vtemp_1));
    vlSymsp->_traceDumpOpen();
    vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWDATA = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data = 0ULL;
    vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "adc_apb_wrapper_tb.v", 
                                         96);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn = 1U;
    VL_WRITEF_NX("System Reset Completed at time %0t\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9);
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__0__addr = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         52);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = __Vtask_adc_apb_wrapper_tb__DOT__apb_read__0__addr;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("At time %0t: [APB READ] Addr = 0x%x, Data = 0x%x\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,12,(IData)(__Vtask_adc_apb_wrapper_tb__DOT__apb_read__0__addr),
                 32,vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA);
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         104);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data = 0x123456789abcdeULL;
    vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         107);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid = 0U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         109);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__1__addr = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         52);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = __Vtask_adc_apb_wrapper_tb__DOT__apb_read__1__addr;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("At time %0t: [APB READ] Addr = 0x%x, Data = 0x%x\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,12,(IData)(__Vtask_adc_apb_wrapper_tb__DOT__apb_read__1__addr),
                 32,vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA);
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__2__addr = 2U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         52);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = __Vtask_adc_apb_wrapper_tb__DOT__apb_read__2__addr;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("At time %0t: [APB READ] Addr = 0x%x, Data = 0x%x\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,12,(IData)(__Vtask_adc_apb_wrapper_tb__DOT__apb_read__2__addr),
                 32,vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA);
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__3__addr = 3U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         52);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = __Vtask_adc_apb_wrapper_tb__DOT__apb_read__3__addr;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("At time %0t: [APB READ] Addr = 0x%x, Data = 0x%x\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,12,(IData)(__Vtask_adc_apb_wrapper_tb__DOT__apb_read__3__addr),
                 32,vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA);
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         121);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_adc_apb_wrapper_tb__DOT__apb_read__4__addr = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         52);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR = __Vtask_adc_apb_wrapper_tb__DOT__apb_read__4__addr;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 1U;
    co_await vlSelfRef.__VtrigSched_h51b743e5__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge adc_apb_wrapper_tb.PCLK)", 
                                                         "adc_apb_wrapper_tb.v", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL = 0U;
    vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE = 0U;
    VL_WRITEF_NX("At time %0t: [APB READ] Addr = 0x%x, Data = 0x%x\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9,12,(IData)(__Vtask_adc_apb_wrapper_tb__DOT__apb_read__4__addr),
                 32,vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA);
    co_await vlSelfRef.__VdlySched.delay(0xc350ULL, 
                                         nullptr, "adc_apb_wrapper_tb.v", 
                                         127);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("Simulation Completed at time %0t\n",0,
                 64,VL_TIME_UNITED_Q(1000),-9);
    VL_FINISH_MT("adc_apb_wrapper_tb.v", 129, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root___dump_triggers__act(Vadc_apb_wrapper_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vadc_apb_wrapper_tb___024root___eval_triggers__act(Vadc_apb_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root___eval_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.set(0U, ((IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PCLK) 
                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PCLK__0))));
    vlSelfRef.__VactTriggered.set(1U, ((~ (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn)) 
                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PRESETn__0)));
    vlSelfRef.__VactTriggered.set(2U, (vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__status_reg 
                                       != vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__status_reg__0));
    vlSelfRef.__VactTriggered.set(3U, (vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT 
                                       != vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT__0));
    vlSelfRef.__VactTriggered.set(4U, (vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg 
                                       != vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg__0));
    vlSelfRef.__VactTriggered.set(5U, (vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg 
                                       != vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg__0));
    vlSelfRef.__VactTriggered.set(6U, ((IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough) 
                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough__0)));
    vlSelfRef.__VactTriggered.set(7U, ((IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL) 
                                       != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL__0)));
    vlSelfRef.__VactTriggered.set(8U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PCLK__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__PCLK;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PRESETn__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__status_reg__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__status_reg;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL__0 
        = vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL;
    if (VL_UNLIKELY((1U & (~ (IData)(vlSelfRef.__VactDidInit))))) {
        vlSelfRef.__VactDidInit = 1U;
        vlSelfRef.__VactTriggered.set(2U, 1U);
        vlSelfRef.__VactTriggered.set(3U, 1U);
        vlSelfRef.__VactTriggered.set(4U, 1U);
        vlSelfRef.__VactTriggered.set(5U, 1U);
        vlSelfRef.__VactTriggered.set(6U, 1U);
        vlSelfRef.__VactTriggered.set(7U, 1U);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vadc_apb_wrapper_tb___024root___dump_triggers__act(vlSelf);
    }
#endif
}
