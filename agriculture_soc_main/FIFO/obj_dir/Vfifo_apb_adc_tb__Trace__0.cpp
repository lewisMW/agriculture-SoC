// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfifo_apb_adc_tb__Syms.h"


void Vfifo_apb_adc_tb___024root__trace_chg_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vfifo_apb_adc_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_chg_0\n"); );
    // Init
    Vfifo_apb_adc_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfifo_apb_adc_tb___024root*>(voidSelf);
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vfifo_apb_adc_tb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vfifo_apb_adc_tb___024root__trace_chg_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U] 
                     | vlSelfRef.__Vm_traceActivity
                     [2U]))) {
        bufp->chgBit(oldp+0,(vlSelfRef.fifo_apb_adc_tb__DOT__rst_n));
        bufp->chgBit(oldp+1,(vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en));
        bufp->chgQData(oldp+2,(vlSelfRef.fifo_apb_adc_tb__DOT__adc_data),56);
        bufp->chgBit(oldp+4,(vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en));
        bufp->chgBit(oldp+5,(vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear));
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[3U])) {
        bufp->chgBit(oldp+6,((0x10U == (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))));
        bufp->chgQData(oldp+7,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                               [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]),56);
        bufp->chgBit(oldp+9,((0U == (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))));
        bufp->chgQData(oldp+10,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[0]),56);
        bufp->chgQData(oldp+12,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[1]),56);
        bufp->chgQData(oldp+14,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[2]),56);
        bufp->chgQData(oldp+16,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[3]),56);
        bufp->chgQData(oldp+18,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[4]),56);
        bufp->chgQData(oldp+20,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[5]),56);
        bufp->chgQData(oldp+22,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[6]),56);
        bufp->chgQData(oldp+24,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[7]),56);
        bufp->chgQData(oldp+26,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[8]),56);
        bufp->chgQData(oldp+28,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[9]),56);
        bufp->chgQData(oldp+30,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[10]),56);
        bufp->chgQData(oldp+32,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[11]),56);
        bufp->chgQData(oldp+34,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[12]),56);
        bufp->chgQData(oldp+36,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[13]),56);
        bufp->chgQData(oldp+38,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[14]),56);
        bufp->chgQData(oldp+40,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[15]),56);
        bufp->chgCData(oldp+42,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr),4);
        bufp->chgCData(oldp+43,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr),4);
        bufp->chgCData(oldp+44,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count),5);
    }
    bufp->chgBit(oldp+45,(vlSelfRef.fifo_apb_adc_tb__DOT__clk));
}

void Vfifo_apb_adc_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_cleanup\n"); );
    // Init
    Vfifo_apb_adc_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfifo_apb_adc_tb___024root*>(voidSelf);
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
