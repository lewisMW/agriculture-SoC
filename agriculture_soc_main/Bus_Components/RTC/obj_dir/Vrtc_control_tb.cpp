// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vrtc_control_tb__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vrtc_control_tb::Vrtc_control_tb(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vrtc_control_tb__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vrtc_control_tb::Vrtc_control_tb(const char* _vcname__)
    : Vrtc_control_tb(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vrtc_control_tb::~Vrtc_control_tb() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vrtc_control_tb___024root___eval_debug_assertions(Vrtc_control_tb___024root* vlSelf);
#endif  // VL_DEBUG
void Vrtc_control_tb___024root___eval_static(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___eval_initial(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___eval_settle(Vrtc_control_tb___024root* vlSelf);
void Vrtc_control_tb___024root___eval(Vrtc_control_tb___024root* vlSelf);

void Vrtc_control_tb::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vrtc_control_tb::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vrtc_control_tb___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vrtc_control_tb___024root___eval_static(&(vlSymsp->TOP));
        Vrtc_control_tb___024root___eval_initial(&(vlSymsp->TOP));
        Vrtc_control_tb___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vrtc_control_tb___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

void Vrtc_control_tb::eval_end_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+eval_end_step Vrtc_control_tb::eval_end_step\n"); );
#ifdef VM_TRACE
    // Tracing
    if (VL_UNLIKELY(vlSymsp->__Vm_dumping)) vlSymsp->_traceDump();
#endif  // VM_TRACE
}

//============================================================
// Events and timing
bool Vrtc_control_tb::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty(); }

uint64_t Vrtc_control_tb::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vrtc_control_tb::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vrtc_control_tb___024root___eval_final(Vrtc_control_tb___024root* vlSelf);

VL_ATTR_COLD void Vrtc_control_tb::final() {
    Vrtc_control_tb___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vrtc_control_tb::hierName() const { return vlSymsp->name(); }
const char* Vrtc_control_tb::modelName() const { return "Vrtc_control_tb"; }
unsigned Vrtc_control_tb::threads() const { return 1; }
void Vrtc_control_tb::prepareClone() const { contextp()->prepareClone(); }
void Vrtc_control_tb::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vrtc_control_tb::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vrtc_control_tb___024root__trace_decl_types(VerilatedVcd* tracep);

void Vrtc_control_tb___024root__trace_init_top(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vrtc_control_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vrtc_control_tb___024root*>(voidSelf);
    Vrtc_control_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vrtc_control_tb___024root__trace_decl_types(tracep);
    Vrtc_control_tb___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vrtc_control_tb___024root__trace_register(Vrtc_control_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vrtc_control_tb::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vrtc_control_tb::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vrtc_control_tb___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
