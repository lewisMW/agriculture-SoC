// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vadc_apb_fifo_wrapper_tb__Syms.h"


void Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0_sub_0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0\n"); );
    // Init
    Vadc_apb_fifo_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_fifo_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0_sub_0(Vadc_apb_fifo_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U] 
                     | vlSelfRef.__Vm_traceActivity
                     [2U]))) {
        bufp->chgBit(oldp+0,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn));
        bufp->chgBit(oldp+1,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PSEL));
        bufp->chgSData(oldp+2,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PADDR),12);
        bufp->chgBit(oldp+3,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PENABLE));
        bufp->chgBit(oldp+4,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWRITE));
        bufp->chgIData(oldp+5,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PWDATA),32);
        bufp->chgBit(oldp+6,((1U & (~ (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRESETn)))));
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[3U])) {
        bufp->chgIData(oldp+7,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PRDATA),32);
        bufp->chgIData(oldp+8,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg),32);
        bufp->chgBit(oldp+9,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_trig));
        bufp->chgBit(oldp+10,((0x10U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
        bufp->chgBit(oldp+11,((0U == (IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
        bufp->chgQData(oldp+12,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_data_out),56);
        bufp->chgBit(oldp+14,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en));
        bufp->chgBit(oldp+15,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d));
        bufp->chgQData(oldp+16,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_generated),56);
        bufp->chgBit(oldp+18,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_data_valid_out));
        bufp->chgQData(oldp+19,((QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__status_reg))),56);
        bufp->chgBit(oldp+21,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en));
        bufp->chgQData(oldp+22,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[0]),56);
        bufp->chgQData(oldp+24,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[1]),56);
        bufp->chgQData(oldp+26,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[2]),56);
        bufp->chgQData(oldp+28,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[3]),56);
        bufp->chgQData(oldp+30,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[4]),56);
        bufp->chgQData(oldp+32,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[5]),56);
        bufp->chgQData(oldp+34,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[6]),56);
        bufp->chgQData(oldp+36,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[7]),56);
        bufp->chgQData(oldp+38,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[8]),56);
        bufp->chgQData(oldp+40,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[9]),56);
        bufp->chgQData(oldp+42,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[10]),56);
        bufp->chgQData(oldp+44,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[11]),56);
        bufp->chgQData(oldp+46,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[12]),56);
        bufp->chgQData(oldp+48,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[13]),56);
        bufp->chgQData(oldp+50,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[14]),56);
        bufp->chgQData(oldp+52,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[15]),56);
        bufp->chgCData(oldp+54,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr),4);
        bufp->chgCData(oldp+55,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr),4);
        bufp->chgCData(oldp+56,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__fifo__DOT__count),5);
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[4U])) {
        bufp->chgIData(oldp+57,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__pll_reg),32);
        bufp->chgIData(oldp+58,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__amux_reg),32);
        bufp->chgIData(oldp+59,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg),32);
        bufp->chgQData(oldp+60,((QData)((IData)(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__trig_reg))),56);
        bufp->chgCData(oldp+62,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL),2);
    }
    bufp->chgBit(oldp+63,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PCLK));
    bufp->chgBit(oldp+64,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__PREADY));
    bufp->chgBit(oldp+65,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__read_enable));
    bufp->chgBit(oldp+66,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__write_enable));
    bufp->chgQData(oldp+67,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ADC_TRIGGER_PREV),56);
    bufp->chgQData(oldp+69,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__STATUS_REG_ADDR_PREV),56);
    bufp->chgQData(oldp+71,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__MEASUREMENT_PREV),56);
    bufp->chgBit(oldp+73,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__ANALOG_IN_PREV));
    bufp->chgIData(oldp+74,(vlSelfRef.adc_apb_fifo_wrapper_tb__DOT__uut__DOT__adc_inst__DOT__seed),32);
}

void Vadc_apb_fifo_wrapper_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_fifo_wrapper_tb___024root__trace_cleanup\n"); );
    // Init
    Vadc_apb_fifo_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_fifo_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[4U] = 0U;
}
