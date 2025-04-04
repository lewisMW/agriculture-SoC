// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vadc_apb_fifo_wrapper_tb__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vadc_apb_fifo_wrapper_tb::Vadc_apb_fifo_wrapper_tb(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vadc_apb_fifo_wrapper_tb__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vadc_apb_fifo_wrapper_tb::Vadc_apb_fifo_wrapper_tb(const char* _vcname__)
    : Vadc_apb_fifo_wrapper_tb(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vadc_apb_fifo_wrapper_tb::~Vadc_apb_fifo_wrapper_tb() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vadc_apb_fifo_wrapper_tb___024root___eval_debug_assertions(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
#endif  // VL_DEBUG
void Vadc_apb_fifo_wrapper_tb___024root___eval_static(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___eval_initial(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___eval_settle(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);
void Vadc_apb_fifo_wrapper_tb___024root___eval(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

void Vadc_apb_fifo_wrapper_tb::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vadc_apb_fifo_wrapper_tb::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vadc_apb_fifo_wrapper_tb___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vadc_apb_fifo_wrapper_tb___024root___eval_static(&(vlSymsp->TOP));
        Vadc_apb_fifo_wrapper_tb___024root___eval_initial(&(vlSymsp->TOP));
        Vadc_apb_fifo_wrapper_tb___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vadc_apb_fifo_wrapper_tb___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

void Vadc_apb_fifo_wrapper_tb::eval_end_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+eval_end_step Vadc_apb_fifo_wrapper_tb::eval_end_step\n"); );
#ifdef VM_TRACE
    // Tracing
    if (VL_UNLIKELY(vlSymsp->__Vm_dumping)) vlSymsp->_traceDump();
#endif  // VM_TRACE
}

//============================================================
// Events and timing
bool Vadc_apb_fifo_wrapper_tb::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty(); }

uint64_t Vadc_apb_fifo_wrapper_tb::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vadc_apb_fifo_wrapper_tb::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vadc_apb_fifo_wrapper_tb___024root___eval_final(Vadc_apb_fifo_wrapper_tb___024root* vlSelf);

VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb::final() {
    Vadc_apb_fifo_wrapper_tb___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vadc_apb_fifo_wrapper_tb::hierName() const { return vlSymsp->name(); }
const char* Vadc_apb_fifo_wrapper_tb::modelName() const { return "Vadc_apb_fifo_wrapper_tb"; }
unsigned Vadc_apb_fifo_wrapper_tb::threads() const { return 1; }
void Vadc_apb_fifo_wrapper_tb::prepareClone() const { contextp()->prepareClone(); }
void Vadc_apb_fifo_wrapper_tb::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vadc_apb_fifo_wrapper_tb::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vadc_apb_fifo_wrapper_tb___024root__trace_decl_types(VerilatedVcd* tracep);

void Vadc_apb_fifo_wrapper_tb___024root__trace_init_top(Vadc_apb_fifo_wrapper_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vadc_apb_fifo_wrapper_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadc_apb_fifo_wrapper_tb___024root*>(voidSelf);
    Vadc_apb_fifo_wrapper_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vadc_apb_fifo_wrapper_tb___024root__trace_decl_types(tracep);
    Vadc_apb_fifo_wrapper_tb___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb___024root__trace_register(Vadc_apb_fifo_wrapper_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vadc_apb_fifo_wrapper_tb::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vadc_apb_fifo_wrapper_tb::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vadc_apb_fifo_wrapper_tb___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
