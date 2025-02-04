// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vadc_apb_wrapper_tb.h for the primary calling header

#include "Vadc_apb_wrapper_tb__pch.h"
#include "Vadc_apb_wrapper_tb__Syms.h"
#include "Vadc_apb_wrapper_tb___024root.h"

void Vadc_apb_wrapper_tb___024root___ctor_var_reset(Vadc_apb_wrapper_tb___024root* vlSelf);

Vadc_apb_wrapper_tb___024root::Vadc_apb_wrapper_tb___024root(Vadc_apb_wrapper_tb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vadc_apb_wrapper_tb___024root___ctor_var_reset(this);
}

void Vadc_apb_wrapper_tb___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vadc_apb_wrapper_tb___024root::~Vadc_apb_wrapper_tb___024root() {
}
