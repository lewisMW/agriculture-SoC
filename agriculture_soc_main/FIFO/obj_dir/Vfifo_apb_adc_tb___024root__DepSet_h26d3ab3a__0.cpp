// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfifo_apb_adc_tb.h for the primary calling header

#include "Vfifo_apb_adc_tb__pch.h"
#include "Vfifo_apb_adc_tb___024root.h"

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root___eval_initial__TOP(Vfifo_apb_adc_tb___024root* vlSelf);
VlCoroutine Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__0(Vfifo_apb_adc_tb___024root* vlSelf);
VlCoroutine Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__1(Vfifo_apb_adc_tb___024root* vlSelf);

void Vfifo_apb_adc_tb___024root___eval_initial(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_initial\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vfifo_apb_adc_tb___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__clk__0 
        = vlSelfRef.fifo_apb_adc_tb__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__rst_n__0 
        = vlSelfRef.fifo_apb_adc_tb__DOT__rst_n;
}

VL_INLINE_OPT VlCoroutine Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__0(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.fifo_apb_adc_tb__DOT__clk = 0U;
    vlSelfRef.fifo_apb_adc_tb__DOT__rst_n = 0U;
    vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 0U;
    vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 0ULL;
    vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 0U;
    vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "fifo_apb_adc_tb.v", 
                                         218);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.fifo_apb_adc_tb__DOT__rst_n = 1U;
    VL_WRITEF_NX("FIFO \345\244\215\344\275\215\345\256\214\346\210\220\n\345\274\200\345\247\213\345\206\231\345\205\245 FIFO...\n",0);
    co_await vlSelfRef.__VtrigSched_hc1487057__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         224);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 1U;
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 
            (0xffffffffffffffULL & VL_RANDOM_Q());
        VL_WRITEF_NX("\345\206\231\345\205\245\346\225\260\346\215\256: %x\n",0,
                     56,vlSelfRef.fifo_apb_adc_tb__DOT__adc_data);
    }
    co_await vlSelfRef.__VtrigSched_hc1487057__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         224);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 1U;
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 
            (0xffffffffffffffULL & VL_RANDOM_Q());
        VL_WRITEF_NX("\345\206\231\345\205\245\346\225\260\346\215\256: %x\n",0,
                     56,vlSelfRef.fifo_apb_adc_tb__DOT__adc_data);
    }
    co_await vlSelfRef.__VtrigSched_hc1487057__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         224);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 1U;
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 
            (0xffffffffffffffULL & VL_RANDOM_Q());
        VL_WRITEF_NX("\345\206\231\345\205\245\346\225\260\346\215\256: %x\n",0,
                     56,vlSelfRef.fifo_apb_adc_tb__DOT__adc_data);
    }
    co_await vlSelfRef.__VtrigSched_hc1487057__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         224);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 1U;
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 
            (0xffffffffffffffULL & VL_RANDOM_Q());
        VL_WRITEF_NX("\345\206\231\345\205\245\346\225\260\346\215\256: %x\n",0,
                     56,vlSelfRef.fifo_apb_adc_tb__DOT__adc_data);
    }
    co_await vlSelfRef.__VtrigSched_hc1487057__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         224);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 1U;
        vlSelfRef.fifo_apb_adc_tb__DOT__adc_data = 
            (0xffffffffffffffULL & VL_RANDOM_Q());
        VL_WRITEF_NX("\345\206\231\345\205\245\346\225\260\346\215\256: %x\n",0,
                     56,vlSelfRef.fifo_apb_adc_tb__DOT__adc_data);
    }
    vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "fifo_apb_adc_tb.v", 
                                         234);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("\345\274\200\345\247\213\350\257\273\345\217\226 FIFO...\n",0);
    co_await vlSelfRef.__VtrigSched_hc1487016__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         237);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 1U;
        VL_WRITEF_NX("read_data: %x\n",0,56,vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                     [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]);
    }
    co_await vlSelfRef.__VtrigSched_hc1487016__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         237);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 1U;
        VL_WRITEF_NX("read_data: %x\n",0,56,vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                     [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]);
    }
    co_await vlSelfRef.__VtrigSched_hc1487016__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         237);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 1U;
        VL_WRITEF_NX("read_data: %x\n",0,56,vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                     [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]);
    }
    co_await vlSelfRef.__VtrigSched_hc1487016__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         237);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 1U;
        VL_WRITEF_NX("read_data: %x\n",0,56,vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                     [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]);
    }
    co_await vlSelfRef.__VtrigSched_hc1487016__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge fifo_apb_adc_tb.clk)", 
                                                         "fifo_apb_adc_tb.v", 
                                                         237);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    if (VL_UNLIKELY((0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 1U;
        VL_WRITEF_NX("read_data: %x\n",0,56,vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                     [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]);
    }
    vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x4e20ULL, 
                                         nullptr, "fifo_apb_adc_tb.v", 
                                         246);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("\346\270\205\347\251\272 FIFO...\n",0);
    vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x2710ULL, 
                                         nullptr, "fifo_apb_adc_tb.v", 
                                         249);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear = 0U;
    if (VL_UNLIKELY((0U == (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
        VL_WRITEF_NX("FIFO \346\270\205\347\251\272\346\210\220\345\212\237\357\274\201\n",0);
    }
    co_await vlSelfRef.__VdlySched.delay(0xc350ULL, 
                                         nullptr, "fifo_apb_adc_tb.v", 
                                         254);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("\344\273\277\347\234\237\347\273\223\346\235\237\n",0);
    VL_FINISH_MT("fifo_apb_adc_tb.v", 256, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

VL_INLINE_OPT VlCoroutine Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__1(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_initial__TOP__Vtiming__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (1U) {
        co_await vlSelfRef.__VdlySched.delay(0x1388ULL, 
                                             nullptr, 
                                             "fifo_apb_adc_tb.v", 
                                             200);
        vlSelfRef.fifo_apb_adc_tb__DOT__clk = (1U & 
                                               (~ (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__clk)));
    }
}

void Vfifo_apb_adc_tb___024root___eval_act(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vfifo_apb_adc_tb___024root___nba_sequent__TOP__0(Vfifo_apb_adc_tb___024root* vlSelf);

void Vfifo_apb_adc_tb___024root___eval_nba(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vfifo_apb_adc_tb___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
}

VL_INLINE_OPT void Vfifo_apb_adc_tb___024root___nba_sequent__TOP__0(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*3:0*/ __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr;
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr = 0;
    CData/*3:0*/ __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr;
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr = 0;
    CData/*4:0*/ __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count;
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count = 0;
    QData/*55:0*/ __VdlyVal__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0;
    __VdlyVal__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 = 0;
    CData/*3:0*/ __VdlyDim0__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0;
    __VdlyDim0__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0;
    __VdlySet__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 = 0;
    // Body
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count = vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count;
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr 
        = vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr;
    __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr 
        = vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr;
    __VdlySet__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 = 0U;
    if ((1U & ((~ (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__rst_n)) 
               | (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear)))) {
        __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count = 0U;
        __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr = 0U;
        __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr = 0U;
    } else {
        __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count 
            = (0x1fU & ((2U == (((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en) 
                                 << 1U) | (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en)))
                         ? ((IData)(1U) + (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))
                         : ((1U == (((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en) 
                                     << 1U) | (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en)))
                             ? ((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count) 
                                - (IData)(1U)) : (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))));
        if (((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en) 
             & (0U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
            __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr 
                = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr)));
        }
        if (((IData)(vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en) 
             & (0x10U != (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count)))) {
            __VdlyVal__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 
                = vlSelfRef.fifo_apb_adc_tb__DOT__adc_data;
            __VdlyDim0__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 
                = vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr;
            __VdlySet__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0 = 1U;
            __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr 
                = (0xfU & ((IData)(1U) + (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr)));
        }
    }
    vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr 
        = __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr;
    vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr 
        = __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr;
    vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count 
        = __Vdly__fifo_apb_adc_tb__DOT__dut__DOT__count;
    if (__VdlySet__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0) {
        vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[__VdlyDim0__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0] 
            = __VdlyVal__fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem__v0;
    }
}

void Vfifo_apb_adc_tb___024root___timing_resume(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___timing_resume\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_hc1487057__0.resume(
                                                   "@(posedge fifo_apb_adc_tb.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_hc1487016__0.resume(
                                                   "@(negedge fifo_apb_adc_tb.clk)");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vfifo_apb_adc_tb___024root___timing_commit(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___timing_commit\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (1ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_hc1487057__0.commit(
                                                   "@(posedge fifo_apb_adc_tb.clk)");
    }
    if ((! (8ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_hc1487016__0.commit(
                                                   "@(negedge fifo_apb_adc_tb.clk)");
    }
}

void Vfifo_apb_adc_tb___024root___eval_triggers__act(Vfifo_apb_adc_tb___024root* vlSelf);

bool Vfifo_apb_adc_tb___024root___eval_phase__act(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<4> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vfifo_apb_adc_tb___024root___eval_triggers__act(vlSelf);
    Vfifo_apb_adc_tb___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vfifo_apb_adc_tb___024root___timing_resume(vlSelf);
        Vfifo_apb_adc_tb___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vfifo_apb_adc_tb___024root___eval_phase__nba(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vfifo_apb_adc_tb___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfifo_apb_adc_tb___024root___dump_triggers__nba(Vfifo_apb_adc_tb___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vfifo_apb_adc_tb___024root___dump_triggers__act(Vfifo_apb_adc_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vfifo_apb_adc_tb___024root___eval(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval\n"); );
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
            Vfifo_apb_adc_tb___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("fifo_apb_adc_tb.v", 167, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vfifo_apb_adc_tb___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("fifo_apb_adc_tb.v", 167, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vfifo_apb_adc_tb___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vfifo_apb_adc_tb___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vfifo_apb_adc_tb___024root___eval_debug_assertions(Vfifo_apb_adc_tb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
