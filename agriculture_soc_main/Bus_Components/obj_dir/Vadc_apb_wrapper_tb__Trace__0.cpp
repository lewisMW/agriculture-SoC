// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vadc_apb_wrapper_tb__Syms.h"


void Vadc_apb_wrapper_tb___024root__trace_chg_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vadc_apb_wrapper_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_chg_0\n"); );
    // Init
    Vadc_apb_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vadc_apb_wrapper_tb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vadc_apb_wrapper_tb___024root__trace_chg_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U] 
                     | vlSelfRef.__Vm_traceActivity
                     [2U]))) {
        bufp->chgBit(oldp+0,(vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn));
        bufp->chgBit(oldp+1,(vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL));
        bufp->chgSData(oldp+2,(vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR),12);
        bufp->chgBit(oldp+3,(vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE));
        bufp->chgBit(oldp+4,(vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE));
        bufp->chgIData(oldp+5,(vlSelfRef.adc_apb_wrapper_tb__DOT__PWDATA),32);
        bufp->chgQData(oldp+6,(vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data),56);
        bufp->chgBit(oldp+8,(vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid));
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[3U])) {
        bufp->chgIData(oldp+9,(vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA),32);
        bufp->chgIData(oldp+10,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg),32);
        bufp->chgIData(oldp+11,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__amux_reg),32);
        bufp->chgIData(oldp+12,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg),32);
        bufp->chgIData(oldp+13,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__status_reg),32);
        bufp->chgBit(oldp+14,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__adc_trig));
        bufp->chgBit(oldp+15,((0x10U == (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
        bufp->chgBit(oldp+16,((0U == (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
        bufp->chgQData(oldp+17,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_data_out),56);
        bufp->chgBit(oldp+19,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en));
        bufp->chgBit(oldp+20,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d));
        bufp->chgIData(oldp+21,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT),32);
        bufp->chgCData(oldp+22,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL),2);
        bufp->chgQData(oldp+23,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[0]),56);
        bufp->chgQData(oldp+25,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[1]),56);
        bufp->chgQData(oldp+27,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[2]),56);
        bufp->chgQData(oldp+29,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[3]),56);
        bufp->chgQData(oldp+31,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[4]),56);
        bufp->chgQData(oldp+33,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[5]),56);
        bufp->chgQData(oldp+35,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[6]),56);
        bufp->chgQData(oldp+37,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[7]),56);
        bufp->chgQData(oldp+39,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[8]),56);
        bufp->chgQData(oldp+41,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[9]),56);
        bufp->chgQData(oldp+43,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[10]),56);
        bufp->chgQData(oldp+45,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[11]),56);
        bufp->chgQData(oldp+47,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[12]),56);
        bufp->chgQData(oldp+49,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[13]),56);
        bufp->chgQData(oldp+51,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[14]),56);
        bufp->chgQData(oldp+53,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[15]),56);
        bufp->chgCData(oldp+55,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr),4);
        bufp->chgCData(oldp+56,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr),4);
        bufp->chgCData(oldp+57,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count),5);
    }
    bufp->chgBit(oldp+58,(vlSelfRef.adc_apb_wrapper_tb__DOT__PCLK));
    bufp->chgBit(oldp+59,(vlSelfRef.adc_apb_wrapper_tb__DOT__PREADY));
    bufp->chgBit(oldp+60,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__read_enable));
    bufp->chgBit(oldp+61,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__write_enable));
    bufp->chgBit(oldp+62,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en));
}

void Vadc_apb_wrapper_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_cleanup\n"); );
    // Init
    Vadc_apb_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
