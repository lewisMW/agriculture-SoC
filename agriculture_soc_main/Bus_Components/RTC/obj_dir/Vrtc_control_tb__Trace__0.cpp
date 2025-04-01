// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vrtc_control_tb__Syms.h"


void Vrtc_control_tb___024root__trace_chg_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vrtc_control_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_chg_0\n"); );
    // Init
    Vrtc_control_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vrtc_control_tb___024root*>(voidSelf);
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vrtc_control_tb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vrtc_control_tb___024root__trace_chg_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U] 
                     | vlSelfRef.__Vm_traceActivity
                     [2U]))) {
        bufp->chgBit(oldp+0,(vlSelfRef.rtc_control_tb__DOT__PSEL));
        bufp->chgBit(oldp+1,(vlSelfRef.rtc_control_tb__DOT__PENABLE));
        bufp->chgBit(oldp+2,(vlSelfRef.rtc_control_tb__DOT__PWRITE));
        bufp->chgSData(oldp+3,(vlSelfRef.rtc_control_tb__DOT__PADDR),12);
        bufp->chgIData(oldp+4,(vlSelfRef.rtc_control_tb__DOT__PWDATA),32);
        bufp->chgBit(oldp+5,(vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en));
        bufp->chgBit(oldp+6,(vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en));
        bufp->chgIData(oldp+7,(vlSelfRef.rtc_control_tb__DOT__ctrl_match_value),32);
        bufp->chgIData(oldp+8,(vlSelfRef.rtc_control_tb__DOT__timeout_counter),32);
        bufp->chgIData(oldp+9,(vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i),32);
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[3U])) {
        bufp->chgBit(oldp+10,(vlSelfRef.rtc_control_tb__DOT__PREADY));
        bufp->chgIData(oldp+11,(vlSelfRef.rtc_control_tb__DOT__ctrl_time_value),32);
        bufp->chgIData(oldp+12,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg),32);
        bufp->chgBit(oldp+13,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg));
        bufp->chgIData(oldp+14,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync),32);
        bufp->chgBit(oldp+15,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched));
        bufp->chgIData(oldp+16,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync_ff),32);
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[4U])) {
        bufp->chgIData(oldp+17,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz),32);
        bufp->chgBit(oldp+18,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_ack));
        bufp->chgBit(oldp+19,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag));
        bufp->chgBit(oldp+20,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff));
        bufp->chgBit(oldp+21,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync));
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[5U])) {
        bufp->chgCData(oldp+22,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state),3);
        bufp->chgBit(oldp+23,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable));
        bufp->chgBit(oldp+24,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req));
        bufp->chgIData(oldp+25,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg),32);
    }
    bufp->chgBit(oldp+26,(vlSelfRef.rtc_control_tb__DOT__PCLK));
    bufp->chgBit(oldp+27,(vlSelfRef.rtc_control_tb__DOT__PRESETn));
    bufp->chgIData(oldp+28,(vlSelfRef.rtc_control_tb__DOT__PRDATA),32);
    bufp->chgBit(oldp+29,(vlSelfRef.rtc_control_tb__DOT__CLK1HZ));
    bufp->chgBit(oldp+30,(vlSelfRef.rtc_control_tb__DOT__nRTCRST));
    bufp->chgBit(oldp+31,(vlSelfRef.rtc_control_tb__DOT__nPOR));
    bufp->chgBit(oldp+32,(((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg) 
                           & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag))));
    bufp->chgBit(oldp+33,(vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr));
    bufp->chgBit(oldp+34,(vlSelfRef.rtc_control_tb__DOT__test_mask_enable));
    bufp->chgCData(oldp+35,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__next_state),3);
    bufp->chgBit(oldp+36,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_1hz));
    bufp->chgBit(oldp+37,(((IData)(vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr) 
                           | (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req))));
}

void Vrtc_control_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_cleanup\n"); );
    // Init
    Vrtc_control_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vrtc_control_tb___024root*>(voidSelf);
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[4U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[5U] = 0U;
}
