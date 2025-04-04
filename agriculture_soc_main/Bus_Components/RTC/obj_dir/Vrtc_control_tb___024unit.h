// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vrtc_control_tb.h for the primary calling header

#ifndef VERILATED_VRTC_CONTROL_TB___024UNIT_H_
#define VERILATED_VRTC_CONTROL_TB___024UNIT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vrtc_control_tb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vrtc_control_tb___024unit final : public VerilatedModule {
  public:

    // INTERNAL VARIABLES
    Vrtc_control_tb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vrtc_control_tb___024unit(Vrtc_control_tb__Syms* symsp, const char* v__name);
    ~Vrtc_control_tb___024unit();
    VL_UNCOPYABLE(Vrtc_control_tb___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
