// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vadc_apb_fifo_wrapper_tb.h for the primary calling header

#include "Vadc_apb_fifo_wrapper_tb__pch.h"
#include "Vadc_apb_fifo_wrapper_tb___024root.h"

VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
VlCoroutine Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
VlCoroutine Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__1(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

void Vadc_apb_fifo_wrapper_tb___024root___eval_initial(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_initial\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_fifo_wrapper_tb__DOT__PCLK__0 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PCLK;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_fifo_wrapper_tb__DOT__PRESETn__0 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn;
    vlSelfRef.__Vtrigprevexpr___TOP__adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL__0 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL;
}

VL_INLINE_OPT VlCoroutine Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_initial__TOP__Vtiming__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PCLK = 0U;
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0x1388ULL, 
                                             nullptr, 
                                             "adc_apb_fifo_wrapper_tb.v", 
                                             41);
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PCLK 
            = (1U & (~ (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PCLK)));
    }
}

void Vadc_apb_fifo_wrapper_tb___024root___act_comb__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

void Vadc_apb_fifo_wrapper_tb___024root___eval_act(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((9ULL & vlSelfRef.__VactTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___act_comb__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___act_comb__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___act_comb__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__read_enable 
        = ((~ (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWRITE)) 
           & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PSEL));
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable 
        = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PSEL) 
           & ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PENABLE) 
              & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWRITE)));
}

void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__1(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__2(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__3(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__1(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

void Vadc_apb_fifo_wrapper_tb___024root___eval_nba(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__1(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__2(vlSelf);
    }
    if ((9ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__0(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__3(vlSelf);
        vlSelfRef.__Vm_traceActivity[4U] = 1U;
    }
    if ((9ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__1(vlSelf);
    }
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    VL_WRITEF_NX("INPUT_SEL = %x\n",0,2,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL);
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__1(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg = 0;
    CData/*3:0*/ __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr = 0;
    CData/*3:0*/ __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr = 0;
    CData/*4:0*/ __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count = 0;
    QData/*55:0*/ __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV = 0;
    QData/*55:0*/ __VdlyVal__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0;
    __VdlyVal__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 = 0;
    CData/*3:0*/ __VdlyDim0__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0;
    __VdlyDim0__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0;
    __VdlySet__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 = 0;
    // Body
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr;
    __VdlySet__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 = 0U;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr;
    __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg;
    if ((1U & ((~ (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn)) 
               | (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_trig)))) {
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr = 0U;
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count = 0U;
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr = 0U;
    } else {
        if (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en) 
             & (0x10U != (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count)))) {
            __VdlyVal__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated;
            __VdlyDim0__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr;
            __VdlySet__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0 = 1U;
            __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr 
                = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr)));
        }
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count 
            = (0x1fU & ((2U == (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en) 
                                 << 1U) | (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en)))
                         ? ((IData)(1U) + (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))
                         : ((1U == (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en) 
                                     << 1U) | (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en)))
                             ? ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count) 
                                - (IData)(1U)) : (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
        if (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en) 
             & (0U != (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count)))) {
            __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr 
                = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr)));
        }
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr 
        = __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr;
    if (__VdlySet__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0) {
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[__VdlyDim0__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0] 
            = __VdlyVal__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem__v0;
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr 
        = __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr;
    if (vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) {
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg 
            = ((0xfffffffcU & __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg) 
               | ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d)
                   ? ((0U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))
                       ? 0U : 1U) : ((0U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))
                                      ? 0U : ((0x10U 
                                               == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))
                                               ? 2U
                                               : 1U))));
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg 
            = ((3U & __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg) 
               | (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out)
                    ? 1U : 0U) << 2U));
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRDATA 
            = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__read_enable)
                ? ((1U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))
                    ? vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg
                    : ((2U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))
                        ? (IData)((vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_data_out 
                                   >> 0x18U)) : ((3U 
                                                  == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))
                                                  ? 
                                                 (0xffffffU 
                                                  & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_data_out))
                                                  : 0U)))
                : 0U);
    } else {
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg = 0U;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRDATA = 0U;
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_data_out 
        = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem
        [vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr];
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_trig 
        = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) 
           && (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
                & (0x102U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))) 
               && (1U & vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWDATA)));
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d 
        = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) 
           & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en));
    if (vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) {
        if (VL_UNLIKELY(((QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg)) 
                         != vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__STATUS_REG_ADDR_PREV))) {
            VL_WRITEF_NX("STATUS_REG_ADDR = %x\n",0,
                         56,(QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg)));
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__STATUS_REG_ADDR_PREV 
                = (QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg));
        }
        if (VL_UNLIKELY((vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated 
                         != vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__MEASUREMENT_PREV))) {
            VL_WRITEF_NX("MEASUREMENT = %x\n",0,56,
                         vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated);
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__MEASUREMENT_PREV 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated;
        }
        if (VL_UNLIKELY(((QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg)) 
                         != vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV))) {
            VL_WRITEF_NX("ADC_TRIGGER = %x\n",0,56,
                         (QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg)));
            __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV 
                = (QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg));
        }
        if (VL_UNLIKELY(((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__analog_passthrough) 
                         != (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ANALOG_IN_PREV)))) {
            VL_WRITEF_NX("ANALOG_IN = %x\n",0,1,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__analog_passthrough);
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ANALOG_IN_PREV 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__analog_passthrough;
        }
        if (VL_UNLIKELY(((0U != vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg) 
                         & (~ (IData)((0U != vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV)))))) {
            VL_WRITEF_NX("ADC_TRIGGER rising edge detected. New MEASUREMENT = %x\n",0,
                         56,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated);
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out = 1U;
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated 
                = (QData)((IData)(VL_URANDOM_SEEDED_II(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__seed)));
        } else {
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out = 0U;
        }
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV 
            = (QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg));
    } else {
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated = 0ULL;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out = 0U;
        __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV = 0ULL;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__STATUS_REG_ADDR_PREV = 0ULL;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__MEASUREMENT_PREV = 0ULL;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ANALOG_IN_PREV = 0U;
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg 
        = __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg;
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV 
        = __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV;
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en 
        = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) 
           && (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__read_enable) 
                & (3U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))) 
               & (0U != (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count 
        = __Vdly__adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count;
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en 
        = ((0x10U != (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count)) 
           & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out));
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__2(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__2\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
                     & (0x100U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))))) {
        VL_WRITEF_NX("PLL_CONTROL: %x\n",0,32,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__pll_reg);
    }
    if (VL_UNLIKELY(((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
                     & (0x101U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))))) {
        VL_WRITEF_NX("AMUX: %x\n",0,32,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__amux_reg);
    }
    if (VL_UNLIKELY(((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
                     & (0x102U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR))))) {
        VL_WRITEF_NX("ADC_TRIGGER: %x\n",0,32,vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg);
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PREADY = 1U;
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__read_enable 
        = ((~ (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWRITE)) 
           & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PSEL));
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__3(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_sequent__TOP__3\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn) {
        if (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
             & (0x100U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR)))) {
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__pll_reg 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWDATA;
        }
        if (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
             & (0x101U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR)))) {
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__amux_reg 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWDATA;
        }
        if (((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable) 
             & (0x102U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR)))) {
            vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg 
                = vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWDATA;
        }
    } else {
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__pll_reg = 0U;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__amux_reg = 0U;
        vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg = 0U;
    }
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL 
        = (3U & vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__amux_reg);
}

VL_INLINE_OPT void Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__1(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___nba_comb__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable 
        = ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PSEL) 
           & ((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PENABLE) 
              & (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWRITE)));
}

void Vadc_apb_fifo_wrapper_tb___024root___timing_resume(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___timing_resume\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h7fe39f9b__0.resume(
                                                   "@(posedge adc_apb_fifo_wrapper_tb.PCLK)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vadc_apb_fifo_wrapper_tb___024root___timing_commit(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___timing_commit\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (1ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h7fe39f9b__0.commit(
                                                   "@(posedge adc_apb_fifo_wrapper_tb.PCLK)");
    }
}

void Vadc_apb_fifo_wrapper_tb___024root___eval_triggers__act(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

bool Vadc_apb_fifo_wrapper_tb___024root___eval_phase__act(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<4> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vadc_apb_fifo_wrapper_tb___024root___eval_triggers__act(vlSelf);
    Vadc_apb_fifo_wrapper_tb___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vadc_apb_fifo_wrapper_tb___024root___timing_resume(vlSelf);
        Vadc_apb_fifo_wrapper_tb___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vadc_apb_fifo_wrapper_tb___024root___eval_phase__nba(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vadc_apb_fifo_wrapper_tb___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb___024root___dump_triggers__nba(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb___024root___dump_triggers__act(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vadc_apb_fifo_wrapper_tb___024root___eval(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval\n"); );
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
            Vadc_apb_fifo_wrapper_tb___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("adc_apb_fifo_wrapper_tb.v", 5, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vadc_apb_fifo_wrapper_tb___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("adc_apb_fifo_wrapper_tb.v", 5, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vadc_apb_fifo_wrapper_tb___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vadc_apb_fifo_wrapper_tb___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vadc_apb_fifo_wrapper_tb___024root___eval_debug_assertions(Vadc_apb_fifo_wrapper_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
