// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vrtc_control_tb__Syms.h"


VL_ATTR_COLD void Vrtc_control_tb___024root__trace_init_sub__TOP____024unit__0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_init_sub__TOP__0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->pushPrefix("$unit", VerilatedTracePrefixType::SCOPE_MODULE);
    Vrtc_control_tb___024root__trace_init_sub__TOP____024unit__0(vlSelf, tracep);
    tracep->popPrefix();
    tracep->pushPrefix("rtc_control_tb", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+39,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+40,0,"ADDR_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+27,0,"PCLK",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"PRESETn",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"PSEL",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"PENABLE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"PWRITE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+4,0,"PADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+5,0,"PWDATA",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+29,0,"PRDATA",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+11,0,"PREADY",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+41,0,"PSLVERR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"CLK1HZ",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+31,0,"nRTCRST",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+32,0,"nPOR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"RTCINTR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"rtc_trig",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"ctrl_read_time_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+12,0,"ctrl_time_value",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"ctrl_set_match_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+8,0,"ctrl_match_value",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+34,0,"ctrl_clear_intr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"ctrl_intr_flag",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+35,0,"test_mask_enable",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+9,0,"timeout_counter",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->declBus(c+10,0,"apb_write_extended__Vstatic__i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->pushPrefix("dut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+39,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+40,0,"ADDR_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+27,0,"PCLK",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"PRESETn",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"PSEL",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"PENABLE",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"PWRITE",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+4,0,"PADDR",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+5,0,"PWDATA",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+29,0,"PRDATA",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+11,0,"PREADY",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+41,0,"PSLVERR",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"CLK1HZ",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+31,0,"nRTCRST",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+32,0,"nPOR",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"RTCINTR",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"rtc_trig",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"ctrl_read_time_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+12,0,"ctrl_time_value",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"ctrl_set_match_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+8,0,"ctrl_match_value",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+34,0,"ctrl_clear_intr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"ctrl_intr_flag",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+35,0,"test_mask_enable",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+42,0,"ST_IDLE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+43,0,"ST_SETUP",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+44,0,"ST_WRITE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+45,0,"ST_READ",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+46,0,"ST_RESP",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+23,0,"state",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+36,0,"next_state",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+47,0,"ADDR_RTCDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+48,0,"ADDR_RTCMR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+49,0,"ADDR_RTCLR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+50,0,"ADDR_RTCCR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+51,0,"ADDR_RTCIMSC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+52,0,"ADDR_RTCRIS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+53,0,"ADDR_RTCMIS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+54,0,"ADDR_RTCICR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+13,0,"RTCLR_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+24,0,"RTCCR_enable",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+14,0,"RTCIMSC_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+25,0,"apb_clear_req",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+26,0,"RTCMR_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+15,0,"counter_sync",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+18,0,"rtc_counter_1hz",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+16,0,"load_req_latched",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+37,0,"load_req_1hz",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+19,0,"load_req_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"intr_flag",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+38,0,"clear_intr_req",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+21,0,"clear_intr_req_sync_ff",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+22,0,"clear_intr_req_sync",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"masked_intr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+17,0,"counter_sync_ff",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_init_sub__TOP____024unit__0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_init_sub__TOP____024unit__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBus(c+55,0,"PERIPHID0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+56,0,"PERIPHID1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+57,0,"PERIPHID2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+58,0,"PERIPHID3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+59,0,"PCELLID0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+60,0,"PCELLID1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+61,0,"PCELLID2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+62,0,"PCELLID3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+63,0,"PADDR_RTCDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+64,0,"PADDR_RTCMR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+65,0,"PADDR_RTCLR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+66,0,"PADDR_RTCCR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+67,0,"PADDR_RTCIMSC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+68,0,"PADDR_RTCRIS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+69,0,"PADDR_RTCMIS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+70,0,"PADDR_RTCICR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+71,0,"PADDR_RTCITCR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+72,0,"PADDR_RTCITOP",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+73,0,"PADDR_RTCTOFFSET",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+74,0,"PADDR_RTCTCOUNT",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+75,0,"PADDR_PERIPHID0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+76,0,"PADDR_PERIPHID1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+77,0,"PADDR_PERIPHID2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+78,0,"PADDR_PERIPHID3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+79,0,"PADDR_PRIMECELLID0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+80,0,"PADDR_PRIMECELLID1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+81,0,"PADDR_PRIMECELLID2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBus(c+82,0,"PADDR_PRIMECELLID3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_init_top(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vrtc_control_tb___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vrtc_control_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vrtc_control_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vrtc_control_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_register(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vrtc_control_tb___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vrtc_control_tb___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vrtc_control_tb___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vrtc_control_tb___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_const_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_const_0\n"); );
    // Init
    Vrtc_control_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vrtc_control_tb___024root*>(voidSelf);
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vrtc_control_tb___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_const_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_const_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+39,(0x20U),32);
    bufp->fullIData(oldp+40,(0xcU),32);
    bufp->fullBit(oldp+41,(0U));
    bufp->fullCData(oldp+42,(0U),3);
    bufp->fullCData(oldp+43,(1U),3);
    bufp->fullCData(oldp+44,(2U),3);
    bufp->fullCData(oldp+45,(3U),3);
    bufp->fullCData(oldp+46,(4U),3);
    bufp->fullSData(oldp+47,(0x200U),12);
    bufp->fullSData(oldp+48,(0x204U),12);
    bufp->fullSData(oldp+49,(0x208U),12);
    bufp->fullSData(oldp+50,(0x20cU),12);
    bufp->fullSData(oldp+51,(0x210U),12);
    bufp->fullSData(oldp+52,(0x214U),12);
    bufp->fullSData(oldp+53,(0x218U),12);
    bufp->fullSData(oldp+54,(0x21cU),12);
    bufp->fullCData(oldp+55,(0x31U),8);
    bufp->fullCData(oldp+56,(0x10U),8);
    bufp->fullCData(oldp+57,(4U),4);
    bufp->fullCData(oldp+58,(0U),8);
    bufp->fullCData(oldp+59,(0xdU),8);
    bufp->fullCData(oldp+60,(0xf0U),8);
    bufp->fullCData(oldp+61,(5U),8);
    bufp->fullCData(oldp+62,(0xb1U),8);
    bufp->fullSData(oldp+63,(0U),10);
    bufp->fullSData(oldp+64,(1U),10);
    bufp->fullSData(oldp+65,(2U),10);
    bufp->fullSData(oldp+66,(3U),10);
    bufp->fullSData(oldp+67,(4U),10);
    bufp->fullSData(oldp+68,(5U),10);
    bufp->fullSData(oldp+69,(6U),10);
    bufp->fullSData(oldp+70,(7U),10);
    bufp->fullSData(oldp+71,(0x20U),10);
    bufp->fullSData(oldp+72,(0x22U),10);
    bufp->fullSData(oldp+73,(0x23U),10);
    bufp->fullSData(oldp+74,(0x24U),10);
    bufp->fullSData(oldp+75,(0x3f8U),10);
    bufp->fullSData(oldp+76,(0x3f9U),10);
    bufp->fullSData(oldp+77,(0x3faU),10);
    bufp->fullSData(oldp+78,(0x3fbU),10);
    bufp->fullSData(oldp+79,(0x3fcU),10);
    bufp->fullSData(oldp+80,(0x3fdU),10);
    bufp->fullSData(oldp+81,(0x3feU),10);
    bufp->fullSData(oldp+82,(0x3ffU),10);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_full_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_full_0\n"); );
    // Init
    Vrtc_control_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vrtc_control_tb___024root*>(voidSelf);
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vrtc_control_tb___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_full_0_sub_0(Vrtc_control_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vrtc_control_tb___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelfRef.rtc_control_tb__DOT__PSEL));
    bufp->fullBit(oldp+2,(vlSelfRef.rtc_control_tb__DOT__PENABLE));
    bufp->fullBit(oldp+3,(vlSelfRef.rtc_control_tb__DOT__PWRITE));
    bufp->fullSData(oldp+4,(vlSelfRef.rtc_control_tb__DOT__PADDR),12);
    bufp->fullIData(oldp+5,(vlSelfRef.rtc_control_tb__DOT__PWDATA),32);
    bufp->fullBit(oldp+6,(vlSelfRef.rtc_control_tb__DOT__ctrl_read_time_en));
    bufp->fullBit(oldp+7,(vlSelfRef.rtc_control_tb__DOT__ctrl_set_match_en));
    bufp->fullIData(oldp+8,(vlSelfRef.rtc_control_tb__DOT__ctrl_match_value),32);
    bufp->fullIData(oldp+9,(vlSelfRef.rtc_control_tb__DOT__timeout_counter),32);
    bufp->fullIData(oldp+10,(vlSelfRef.rtc_control_tb__DOT__apb_write_extended__Vstatic__i),32);
    bufp->fullBit(oldp+11,(vlSelfRef.rtc_control_tb__DOT__PREADY));
    bufp->fullIData(oldp+12,(vlSelfRef.rtc_control_tb__DOT__ctrl_time_value),32);
    bufp->fullIData(oldp+13,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCLR_reg),32);
    bufp->fullBit(oldp+14,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg));
    bufp->fullIData(oldp+15,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync),32);
    bufp->fullBit(oldp+16,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_latched));
    bufp->fullIData(oldp+17,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__counter_sync_ff),32);
    bufp->fullIData(oldp+18,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__rtc_counter_1hz),32);
    bufp->fullBit(oldp+19,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_ack));
    bufp->fullBit(oldp+20,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag));
    bufp->fullBit(oldp+21,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync_ff));
    bufp->fullBit(oldp+22,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__clear_intr_req_sync));
    bufp->fullCData(oldp+23,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__state),3);
    bufp->fullBit(oldp+24,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCCR_enable));
    bufp->fullBit(oldp+25,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req));
    bufp->fullIData(oldp+26,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCMR_reg),32);
    bufp->fullBit(oldp+27,(vlSelfRef.rtc_control_tb__DOT__PCLK));
    bufp->fullBit(oldp+28,(vlSelfRef.rtc_control_tb__DOT__PRESETn));
    bufp->fullIData(oldp+29,(vlSelfRef.rtc_control_tb__DOT__PRDATA),32);
    bufp->fullBit(oldp+30,(vlSelfRef.rtc_control_tb__DOT__CLK1HZ));
    bufp->fullBit(oldp+31,(vlSelfRef.rtc_control_tb__DOT__nRTCRST));
    bufp->fullBit(oldp+32,(vlSelfRef.rtc_control_tb__DOT__nPOR));
    bufp->fullBit(oldp+33,(((IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__RTCIMSC_reg) 
                            & (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__intr_flag))));
    bufp->fullBit(oldp+34,(vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr));
    bufp->fullBit(oldp+35,(vlSelfRef.rtc_control_tb__DOT__test_mask_enable));
    bufp->fullCData(oldp+36,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__next_state),3);
    bufp->fullBit(oldp+37,(vlSelfRef.rtc_control_tb__DOT__dut__DOT__load_req_1hz));
    bufp->fullBit(oldp+38,(((IData)(vlSelfRef.rtc_control_tb__DOT__ctrl_clear_intr) 
                            | (IData)(vlSelfRef.rtc_control_tb__DOT__dut__DOT__apb_clear_req))));
}
