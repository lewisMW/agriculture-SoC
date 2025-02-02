// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfifo_apb_adc_tb__Syms.h"


VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_init_sub__TOP__0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->pushPrefix("fifo_apb_adc_tb", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+47,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+48,0,"DEPTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+46,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"adc_wr_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+3,0,"adc_data",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+7,0,"fifo_full",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"apb_rd_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+8,0,"apb_rd_data",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+10,0,"fifo_empty",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"fifo_clear",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("dut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+47,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+48,0,"DEPTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+46,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"adc_wr_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+3,0,"adc_data",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+7,0,"fifo_full",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"apb_rd_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+8,0,"apb_rd_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+10,0,"fifo_empty",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"fifo_clear",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("fifo_mem", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 16; ++i) {
        tracep->declQuad(c+11+i*2,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+0), 55,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+43,0,"wr_ptr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+44,0,"rd_ptr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+45,0,"count",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_init_top(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vfifo_apb_adc_tb___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vfifo_apb_adc_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vfifo_apb_adc_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_register(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vfifo_apb_adc_tb___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vfifo_apb_adc_tb___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vfifo_apb_adc_tb___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vfifo_apb_adc_tb___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_const_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_const_0\n"); );
    // Init
    Vfifo_apb_adc_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfifo_apb_adc_tb___024root*>(voidSelf);
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vfifo_apb_adc_tb___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_const_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_const_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+47,(0x38U),32);
    bufp->fullIData(oldp+48,(0x10U),32);
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_full_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_full_0\n"); );
    // Init
    Vfifo_apb_adc_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfifo_apb_adc_tb___024root*>(voidSelf);
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vfifo_apb_adc_tb___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vfifo_apb_adc_tb___024root__trace_full_0_sub_0(Vfifo_apb_adc_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfifo_apb_adc_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfifo_apb_adc_tb___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelfRef.fifo_apb_adc_tb__DOT__rst_n));
    bufp->fullBit(oldp+2,(vlSelfRef.fifo_apb_adc_tb__DOT__adc_wr_en));
    bufp->fullQData(oldp+3,(vlSelfRef.fifo_apb_adc_tb__DOT__adc_data),56);
    bufp->fullBit(oldp+5,(vlSelfRef.fifo_apb_adc_tb__DOT__apb_rd_en));
    bufp->fullBit(oldp+6,(vlSelfRef.fifo_apb_adc_tb__DOT__fifo_clear));
    bufp->fullBit(oldp+7,((0x10U == (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))));
    bufp->fullQData(oldp+8,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem
                            [vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr]),56);
    bufp->fullBit(oldp+10,((0U == (IData)(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count))));
    bufp->fullQData(oldp+11,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[0]),56);
    bufp->fullQData(oldp+13,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[1]),56);
    bufp->fullQData(oldp+15,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[2]),56);
    bufp->fullQData(oldp+17,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[3]),56);
    bufp->fullQData(oldp+19,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[4]),56);
    bufp->fullQData(oldp+21,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[5]),56);
    bufp->fullQData(oldp+23,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[6]),56);
    bufp->fullQData(oldp+25,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[7]),56);
    bufp->fullQData(oldp+27,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[8]),56);
    bufp->fullQData(oldp+29,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[9]),56);
    bufp->fullQData(oldp+31,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[10]),56);
    bufp->fullQData(oldp+33,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[11]),56);
    bufp->fullQData(oldp+35,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[12]),56);
    bufp->fullQData(oldp+37,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[13]),56);
    bufp->fullQData(oldp+39,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[14]),56);
    bufp->fullQData(oldp+41,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__fifo_mem[15]),56);
    bufp->fullCData(oldp+43,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__wr_ptr),4);
    bufp->fullCData(oldp+44,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__rd_ptr),4);
    bufp->fullCData(oldp+45,(vlSelfRef.fifo_apb_adc_tb__DOT__dut__DOT__count),5);
    bufp->fullBit(oldp+46,(vlSelfRef.fifo_apb_adc_tb__DOT__clk));
}
