// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vrtc_control_tb.h for the primary calling header

#include "Vrtc_control_tb__pch.h"
#include "Vrtc_control_tb__Syms.h"
#include "Vrtc_control_tb___024root.h"

void Vrtc_control_tb___024root___ctor_var_reset(Vrtc_control_tb___024root* vlSelf);

Vrtc_control_tb___024root::Vrtc_control_tb___024root(Vrtc_control_tb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vrtc_control_tb___024root___ctor_var_reset(this);
}

void Vrtc_control_tb___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vrtc_control_tb___024root::~Vrtc_control_tb___024root() {
}
