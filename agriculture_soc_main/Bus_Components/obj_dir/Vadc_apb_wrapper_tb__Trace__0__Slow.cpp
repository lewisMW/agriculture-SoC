// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vadc_apb_wrapper_tb__Syms.h"


VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_init_sub__TOP__0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->pushPrefix("adc_apb_wrapper_tb", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+64,0,"ADDR_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+65,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+59,0,"PCLK",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"PRESETn",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"PSEL",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"PADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+4,0,"PENABLE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"PWRITE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+6,0,"PWDATA",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+10,0,"PRDATA",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+60,0,"PREADY",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+66,0,"PSLVERR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+7,0,"adc_data",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+9,0,"adc_data_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("uut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+64,0,"ADDR_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+65,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+59,0,"PCLK",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"PRESETn",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"PSEL",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+3,0,"PADDR",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+4,0,"PENABLE",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"PWRITE",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+6,0,"PWDATA",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+10,0,"PRDATA",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+60,0,"PREADY",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+66,0,"PSLVERR",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+7,0,"adc_data",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+9,0,"adc_data_valid",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+11,0,"pll_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"amux_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+13,0,"trig_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+14,0,"status_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+15,0,"adc_trig",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+16,0,"fifo_full",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"fifo_empty",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+18,0,"fifo_data_out",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+20,0,"fifo_rd_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+21,0,"fifo_rd_en_d",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+67,0,"STATUS_REG_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+68,0,"MEASUREMENT_HI_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+69,0,"MEASUREMENT_LO_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+70,0,"PLL_CONTROL_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+71,0,"AMUX_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+72,0,"ADC_TRIGGER_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+61,0,"read_enable",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+62,0,"write_enable",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+73,0,"analog_passthrough",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("adc_inst", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+65,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+14,0,"STATUS_REG_ADDR",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+22,0,"MEASUREMENT",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"PLL_CONTROL",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+13,0,"ADC_TRIGGER",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+73,0,"ANALOG_IN",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("amux_inst", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+74,0,"AMUX_INPUTS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+23,0,"INPUT_SEL",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+73,0,"ANALOG_PASSTHROUGH",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("fifo", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+75,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+76,0,"DEPTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+59,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"adc_wr_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+7,0,"adc_data",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+16,0,"fifo_full",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"apb_rd_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declQuad(c+18,0,"apb_rd_data",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 55,0);
    tracep->declBit(c+17,0,"fifo_empty",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+15,0,"fifo_clear",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("fifo_mem", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 16; ++i) {
        tracep->declQuad(c+24+i*2,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+0), 55,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+56,0,"wr_ptr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+57,0,"rd_ptr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+58,0,"count",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_init_top(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vadc_apb_wrapper_tb___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vadc_apb_wrapper_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vadc_apb_wrapper_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_register(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vadc_apb_wrapper_tb___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vadc_apb_wrapper_tb___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vadc_apb_wrapper_tb___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vadc_apb_wrapper_tb___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_const_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_const_0\n"); );
    // Init
    Vadc_apb_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vadc_apb_wrapper_tb___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_const_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_const_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+64,(0xcU),32);
    bufp->fullIData(oldp+65,(0x20U),32);
    bufp->fullBit(oldp+66,(0U));
    bufp->fullSData(oldp+67,(1U),12);
    bufp->fullSData(oldp+68,(2U),12);
    bufp->fullSData(oldp+69,(3U),12);
    bufp->fullSData(oldp+70,(0x100U),12);
    bufp->fullSData(oldp+71,(0x101U),12);
    bufp->fullSData(oldp+72,(0x102U),12);
    bufp->fullBit(oldp+73,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__analog_passthrough));
    bufp->fullIData(oldp+74,(4U),32);
    bufp->fullIData(oldp+75,(0x38U),32);
    bufp->fullIData(oldp+76,(0x10U),32);
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_full_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_full_0\n"); );
    // Init
    Vadc_apb_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vadc_apb_wrapper_tb___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vadc_apb_wrapper_tb___024root__trace_full_0_sub_0(Vadc_apb_wrapper_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vadc_apb_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vadc_apb_wrapper_tb___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelfRef.adc_apb_wrapper_tb__DOT__PRESETn));
    bufp->fullBit(oldp+2,(vlSelfRef.adc_apb_wrapper_tb__DOT__PSEL));
    bufp->fullSData(oldp+3,(vlSelfRef.adc_apb_wrapper_tb__DOT__PADDR),12);
    bufp->fullBit(oldp+4,(vlSelfRef.adc_apb_wrapper_tb__DOT__PENABLE));
    bufp->fullBit(oldp+5,(vlSelfRef.adc_apb_wrapper_tb__DOT__PWRITE));
    bufp->fullIData(oldp+6,(vlSelfRef.adc_apb_wrapper_tb__DOT__PWDATA),32);
    bufp->fullQData(oldp+7,(vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data),56);
    bufp->fullBit(oldp+9,(vlSelfRef.adc_apb_wrapper_tb__DOT__adc_data_valid));
    bufp->fullIData(oldp+10,(vlSelfRef.adc_apb_wrapper_tb__DOT__PRDATA),32);
    bufp->fullIData(oldp+11,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__pll_reg),32);
    bufp->fullIData(oldp+12,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__amux_reg),32);
    bufp->fullIData(oldp+13,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__trig_reg),32);
    bufp->fullIData(oldp+14,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__status_reg),32);
    bufp->fullBit(oldp+15,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__adc_trig));
    bufp->fullBit(oldp+16,((0x10U == (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
    bufp->fullBit(oldp+17,((0U == (IData)(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count))));
    bufp->fullQData(oldp+18,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_data_out),56);
    bufp->fullBit(oldp+20,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en));
    bufp->fullBit(oldp+21,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo_rd_en_d));
    bufp->fullIData(oldp+22,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__adc_inst__MEASUREMENT),32);
    bufp->fullCData(oldp+23,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__amux_inst__INPUT_SEL),2);
    bufp->fullQData(oldp+24,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[0]),56);
    bufp->fullQData(oldp+26,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[1]),56);
    bufp->fullQData(oldp+28,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[2]),56);
    bufp->fullQData(oldp+30,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[3]),56);
    bufp->fullQData(oldp+32,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[4]),56);
    bufp->fullQData(oldp+34,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[5]),56);
    bufp->fullQData(oldp+36,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[6]),56);
    bufp->fullQData(oldp+38,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[7]),56);
    bufp->fullQData(oldp+40,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[8]),56);
    bufp->fullQData(oldp+42,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[9]),56);
    bufp->fullQData(oldp+44,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[10]),56);
    bufp->fullQData(oldp+46,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[11]),56);
    bufp->fullQData(oldp+48,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[12]),56);
    bufp->fullQData(oldp+50,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[13]),56);
    bufp->fullQData(oldp+52,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[14]),56);
    bufp->fullQData(oldp+54,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__fifo_mem[15]),56);
    bufp->fullCData(oldp+56,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__wr_ptr),4);
    bufp->fullCData(oldp+57,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__rd_ptr),4);
    bufp->fullCData(oldp+58,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__fifo__DOT__count),5);
    bufp->fullBit(oldp+59,(vlSelfRef.adc_apb_wrapper_tb__DOT__PCLK));
    bufp->fullBit(oldp+60,(vlSelfRef.adc_apb_wrapper_tb__DOT__PREADY));
    bufp->fullBit(oldp+61,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__read_enable));
    bufp->fullBit(oldp+62,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT__write_enable));
    bufp->fullBit(oldp+63,(vlSelfRef.adc_apb_wrapper_tb__DOT__uut__DOT____Vcellinp__fifo__adc_wr_en));
}
