// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfifo_apb_adc_tb.h for the primary calling header

#ifndef VERILATED_VFIFO_APB_ADC_TB___024ROOT_H_
#define VERILATED_VFIFO_APB_ADC_TB___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vfifo_apb_adc_tb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfifo_apb_adc_tb___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ fifo_apb_adc_tb__DOT__clk;
    CData/*0:0*/ fifo_apb_adc_tb__DOT__rst_n;
    CData/*0:0*/ fifo_apb_adc_tb__DOT__adc_wr_en;
    CData/*0:0*/ fifo_apb_adc_tb__DOT__apb_rd_en;
    CData/*0:0*/ fifo_apb_adc_tb__DOT__fifo_clear;
    CData/*3:0*/ fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr;
    CData/*3:0*/ fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr;
    CData/*4:0*/ fifo_apb_adc_tb__DOT__dut__DOT__count;
    CData/*0:0*/ __Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__fifo_apb_adc_tb__DOT__rst_n__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    QData/*55:0*/ fifo_apb_adc_tb__DOT__adc_data;
    VlUnpacked<QData/*55:0*/, 16> fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_hc1487057__0;
    VlTriggerScheduler __VtrigSched_hc1487016__0;
    VlTriggerVec<4> __VactTriggered;
    VlTriggerVec<4> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfifo_apb_adc_tb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfifo_apb_adc_tb___024root(Vfifo_apb_adc_tb__Syms* symsp, const char* v__name);
    ~Vfifo_apb_adc_tb___024root();
    VL_UNCOPYABLE(Vfifo_apb_adc_tb___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
