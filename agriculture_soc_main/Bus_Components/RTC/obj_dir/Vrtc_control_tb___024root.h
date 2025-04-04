// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vrtc_control_tb.h for the primary calling header

#ifndef VERILATED_VRTC_CONTROL_TB___024ROOT_H_
#define VERILATED_VRTC_CONTROL_TB___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vrtc_control_tb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vrtc_control_tb___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ rtc_control_tb__DOT__PCLK;
    CData/*0:0*/ rtc_control_tb__DOT__PRESETn;
    CData/*0:0*/ rtc_control_tb__DOT__CLK1HZ;
    CData/*0:0*/ rtc_control_tb__DOT__nRTCRST;
    CData/*0:0*/ rtc_control_tb__DOT__PSEL;
    CData/*0:0*/ rtc_control_tb__DOT__PENABLE;
    CData/*0:0*/ rtc_control_tb__DOT__PWRITE;
    CData/*0:0*/ rtc_control_tb__DOT__PREADY;
    CData/*0:0*/ rtc_control_tb__DOT__nPOR;
    CData/*0:0*/ rtc_control_tb__DOT__ctrl_read_time_en;
    CData/*0:0*/ rtc_control_tb__DOT__ctrl_set_match_en;
    CData/*0:0*/ rtc_control_tb__DOT__ctrl_clear_intr;
    CData/*0:0*/ rtc_control_tb__DOT__test_mask_enable;
    CData/*2:0*/ rtc_control_tb__DOT__dut__DOT__state;
    CData/*2:0*/ rtc_control_tb__DOT__dut__DOT__next_state;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__RTCCR_enable;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__apb_clear_req;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__load_req_latched;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__load_req_1hz;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__load_req_ack;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__intr_flag;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff;
    CData/*0:0*/ rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync;
    CData/*0:0*/ __Vdly__rtc_control_tb__DOT__dut__DOT__load_req_ack;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rtc_control_tb__DOT__PCLK__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rtc_control_tb__DOT__PRESETn__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rtc_control_tb__DOT__CLK1HZ__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rtc_control_tb__DOT__nRTCRST__0;
    CData/*0:0*/ __VactContinue;
    SData/*11:0*/ rtc_control_tb__DOT__PADDR;
    IData/*31:0*/ rtc_control_tb__DOT__PWDATA;
    IData/*31:0*/ rtc_control_tb__DOT__PRDATA;
    IData/*31:0*/ rtc_control_tb__DOT__ctrl_time_value;
    IData/*31:0*/ rtc_control_tb__DOT__ctrl_match_value;
    IData/*31:0*/ rtc_control_tb__DOT__timeout_counter;
    IData/*31:0*/ rtc_control_tb__DOT__apb_write_extended__Vstatic__i;
    IData/*31:0*/ rtc_control_tb__DOT__dut__DOT__RTCLR_reg;
    IData/*31:0*/ rtc_control_tb__DOT__dut__DOT__RTCMR_reg;
    IData/*31:0*/ rtc_control_tb__DOT__dut__DOT__counter_sync;
    IData/*31:0*/ rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz;
    IData/*31:0*/ rtc_control_tb__DOT__dut__DOT__counter_sync_ff;
    IData/*31:0*/ __Vdly__rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*0:0*/, 6> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h11424186__0;
    VlTriggerScheduler __VtrigSched_h79186ef2__0;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<6> __VactTriggered;
    VlTriggerVec<6> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vrtc_control_tb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vrtc_control_tb___024root(Vrtc_control_tb__Syms* symsp, const char* v__name);
    ~Vrtc_control_tb___024root();
    VL_UNCOPYABLE(Vrtc_control_tb___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
