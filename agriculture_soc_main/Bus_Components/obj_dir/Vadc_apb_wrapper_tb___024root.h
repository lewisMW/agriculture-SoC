// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vadc_apb_wrapper_tb.h for the primary calling header

#ifndef VERILATED_VADC_APB_WRAPPER_TB___024ROOT_H_
#define VERILATED_VADC_APB_WRAPPER_TB___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vadc_apb_wrapper_tb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vadc_apb_wrapper_tb___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PCLK;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PRESETn;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PSEL;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PENABLE;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PWRITE;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__PREADY;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__adc_data_valid;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__adc_trig;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__read_enable;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__write_enable;
    CData/*0:0*/ adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en;
    CData/*1:0*/ adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL;
    CData/*3:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr;
    CData/*3:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr;
    CData/*4:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PCLK__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__PRESETn__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough__0;
    CData/*1:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL__0;
    CData/*0:0*/ __VactDidInit;
    CData/*0:0*/ __VactContinue;
    SData/*11:0*/ adc_apb_wrapper_tb__DOT__PADDR;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__PWDATA;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__PRDATA;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__amux_reg;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__status_reg;
    IData/*31:0*/ adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT;
    IData/*31:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__status_reg__0;
    IData/*31:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT__0;
    IData/*31:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg__0;
    IData/*31:0*/ __Vtrigprevexpr___TOP__adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg__0;
    IData/*31:0*/ __VactIterCount;
    QData/*55:0*/ adc_apb_wrapper_tb__DOT__adc_data;
    QData/*55:0*/ adc_apb_wrapper_tb__DOT__uut__DOT__fifo_data_out;
    VlUnpacked<QData/*55:0*/, 16> adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h51b743e5__0;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<9> __VactTriggered;
    VlTriggerVec<9> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vadc_apb_wrapper_tb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vadc_apb_wrapper_tb___024root(Vadc_apb_wrapper_tb__Syms* symsp, const char* v__name);
    ~Vadc_apb_wrapper_tb___024root();
    VL_UNCOPYABLE(Vadc_apb_wrapper_tb___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
