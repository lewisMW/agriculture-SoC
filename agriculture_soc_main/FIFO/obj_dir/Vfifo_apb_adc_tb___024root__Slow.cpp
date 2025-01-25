// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfifo_apb_adc_tb.h for the primary calling header

#include "Vfifo_apb_adc_tb__pch.h"
#include "Vfifo_apb_adc_tb__Syms.h"
#include "Vfifo_apb_adc_tb___024root.h"

void Vfifo_apb_adc_tb___024root___ctor_var_reset(Vfifo_apb_adc_tb___024root* vlSelf);

Vfifo_apb_adc_tb___024root::Vfifo_apb_adc_tb___024root(Vfifo_apb_adc_tb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfifo_apb_adc_tb___024root___ctor_var_reset(this);
}

void Vfifo_apb_adc_tb___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfifo_apb_adc_tb___024root::~Vfifo_apb_adc_tb___024root() {
}
