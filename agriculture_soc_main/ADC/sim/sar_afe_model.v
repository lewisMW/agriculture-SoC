`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// sar_afe_model.v -- SIMULATION ONLY. Never list it in a synthesis filelist:
// Genus takes the sar_afe cell from ASIC_ours/macros/sar_afe/*.lib.
//
// Behavioural Verilog model of the sar_afe hard macro (two bootstrapped
// sampling switches, two 8-bit CDACs with their bit-driver inverters, and the
// clocked comparator), for plain-digital RTL simulation of sar_adc. Same port
// list as ASIC_ours/macros/sar_afe/sar_afe.v (the macro's port list).
//
// Not compiled in the AMS flow (SAR_AMS): there sar_afe is the Verilog-AMS
// view or the SPICE netlist bound by the amsd file.
//
// Input. Digital wires cannot carry a voltage, so vinp/vinn are ignored and
// the model makes its own input. Defaults match sar_ams_shim (differential
// sine, VCM 0.9 V, +/-0.4 V per side, 5 kHz), so the SENSING_CHECK bounds in
// adc_apb_wrapper_rev2 apply unchanged. Parameters set the defaults, plusargs
// override them at time 0, and a testbench may write the variables below
// hierarchically at any time (e.g. dut.u_afe.vdc = 0.1):
//   +sar_afe_mode=<n>     0 sine (default), 1 ramp (sawtooth), 2 dc,
//                         3 external: the testbench drives vext_p/vext_n
//   +sar_afe_vcm=<V>      common mode                      (0.9)
//   +sar_afe_vamp=<V>     sine amplitude per side          (0.4)
//   +sar_afe_fin=<Hz>     sine frequency                   (5e3)
//   +sar_afe_vdc=<V>      dc mode: vinp - vinn             (0)
//   +sar_afe_ramp_lo=<V>, +sar_afe_ramp_hi=<V>, +sar_afe_ramp_t=<s>
//                         ramp mode: vinp - vinn from lo to hi in t, repeating
//                                                          (-1.8, 1.8, 1e-3)
//                         (ramp_t0, the start time in s, is set hierarchically)
//   +sar_afe_vos=<V>      comparator offset, added to the vinp side (0)
//   +sar_afe_cpar=<x>     top-plate parasitic / CDAC capacitance  (0)
//   +sar_afe_verbose      print every comparator decision
//
// CDAC (charge redistribution). Each side has binary caps 1..128 Cu plus a
// 1 Cu dummy (256 Cu in all), top plates at the comparator inputs. While
// sample is high the top plate tracks its input and bottom plate k sits at
// VREF*(1 - ctl[k]) (the bit drivers are inverters; the dummy's driver input
// is tied low). When sample falls the top-plate charge is held, so
//     vtop = vin(sampled) + VREF * (ctl_sampled - ctl) / (256 * (1 + CPAR))
// with the 8-bit codes taken as unsigned integers. With sarlogic's codes
// (ctlp = D | mask, ctln = ~ctlp, ctlp = 0x80 while sampling) and CPAR = 0,
// the result is the largest code D below
//     x = 128 + 128 * (vinp - vinn + VOS - (trima - trimb)*VTRIM_LSB) / VREF
// i.e. floor(x) clamped to 0..255; the reset trim (trima 16, trimb 15) gives
// a -5 mV offset.
//
// Comparator. Mirrors the AMS behavioural comparator's trim convention:
//     vinp side wins  <=>  vtop_p + VOS - trima*VTRIM_LSB > vtop_n - trimb*VTRIM_LSB
// so raising trima lowers the vinp side. Its outputs follow the macro's
// latch: both HIGH while clk is low (TRST after the falling edge); on the
// rising edge ONE output falls after TDEC: outn when the vinp side wins
// (bit = 1), outp otherwise. These are the .lib's clk -> outp/outn arcs
// (decision 1.0 ns, reset 0.3 ns).
// -----------------------------------------------------------------------------
`ifndef SAR_AMS
module sar_afe #(
    parameter integer MODE      = 0,
    parameter real    VREF      = 1.8,     // CDAC reference = bit-driver supply
    parameter real    VCM       = 0.9,
    parameter real    VAMP      = 0.4,
    parameter real    FIN_HZ    = 5.0e3,
    parameter real    VDC       = 0.0,
    parameter real    RAMP_LO   = -1.8,
    parameter real    RAMP_HI   = 1.8,
    parameter real    RAMP_T    = 1.0e-3,
    parameter real    VOS       = 0.0,
    parameter real    VTRIM_LSB = 5.0e-3,  // per trim code, as the AMS behavioural comparator
    parameter real    CPAR      = 0.0,
    parameter real    TDEC      = 1.0,     // ns, clk rise -> one output falls
    parameter real    TRST      = 0.3      // ns, clk fall -> both outputs high
)(
`ifdef USE_POWER_PINS
    inout  wire       vdd,
    inout  wire       vss,
    inout  wire       vdda,
    inout  wire       vref,
`endif
    input  wire       vinp,     // ignored (see "Input")
    input  wire       vinn,     // ignored
    input  wire       sample,
    input  wire       clk,
    input  wire [7:0] ctlp,
    input  wire [7:0] ctln,
    input  wire [4:0] trima,
    input  wire [4:0] trimb,
    output reg        outp,
    output reg        outn
);

    // ---- configuration (see the header) -------------------------------------
    integer mode;
    real    vref, vcm, vamp, fin_hz, vdc, ramp_lo, ramp_hi, ramp_t, ramp_t0;
    real    vos, vtrim_lsb, cpar, tdec, trst;
    reg     verbose;
    real    vext_p, vext_n;      // mode 3: driven by the testbench

    // ---- state, readable by testbenches -------------------------------------
    real    vsp, vsn;            // input held on each side when sample fell
    reg [7:0] csp, csn;          // ctlp/ctln while sampling
    real    vtp, vtn;            // comparator inputs at the last decision
    reg     dec;                 // last decision: 1 = vinp side won (bit 1)
    integer n_samples, n_decisions;
    reg     sample_q;

    initial begin
        mode = MODE;   vref = VREF;    vcm = VCM;         vamp = VAMP;
        fin_hz = FIN_HZ; vdc = VDC;    ramp_lo = RAMP_LO; ramp_hi = RAMP_HI;
        ramp_t = RAMP_T; ramp_t0 = 0.0; vos = VOS; vtrim_lsb = VTRIM_LSB; cpar = CPAR;
        tdec = TDEC;   trst = TRST;
        vext_p = VCM;  vext_n = VCM;
        vsp = VCM;     vsn = VCM;      vtp = VCM;  vtn = VCM;
        csp = 8'h80;   csn = 8'h7f;    dec = 1'b0;
        n_samples = 0; n_decisions = 0; sample_q = 1'b0;
        verbose = $test$plusargs("sar_afe_verbose");
        if ($value$plusargs("sar_afe_mode=%d",    mode))    ;
        if ($value$plusargs("sar_afe_vcm=%f",     vcm))     ;
        if ($value$plusargs("sar_afe_vamp=%f",    vamp))    ;
        if ($value$plusargs("sar_afe_fin=%f",     fin_hz))  ;
        if ($value$plusargs("sar_afe_vdc=%f",     vdc))     ;
        if ($value$plusargs("sar_afe_ramp_lo=%f", ramp_lo)) ;
        if ($value$plusargs("sar_afe_ramp_hi=%f", ramp_hi)) ;
        if ($value$plusargs("sar_afe_ramp_t=%f",  ramp_t))  ;
        if ($value$plusargs("sar_afe_vos=%f",     vos))     ;
        if ($value$plusargs("sar_afe_cpar=%f",    cpar))    ;
        outp = 1'b1;   outn = 1'b1;
        $display("sar_afe_model: behavioural sar_afe (%m): mode=%0d vcm=%.3f vamp=%.3f fin=%.1f Hz vdc=%.4f vos=%.4f vref=%.3f cpar=%.3f",
                 mode, vcm, vamp, fin_hz, vdc, vos, vref, cpar);
    end

    // ---- input source --------------------------------------------------------
    function real vdiff_at;                // vinp - vinn at time t (s)
        input real t;
        real x;
        begin
            case (mode)
                0: vdiff_at = 2.0 * vamp * $sin(6.283185307179586 * fin_hz * t);
                1: begin
                       x = (t - ramp_t0) / ramp_t;
                       x = x - $floor(x);
                       vdiff_at = ramp_lo + (ramp_hi - ramp_lo) * x;
                   end
                2: vdiff_at = vdc;
                default: vdiff_at = vext_p - vext_n;
            endcase
        end
    endfunction

    function real vin_p;
        input real t;
        begin vin_p = (mode == 3) ? vext_p : vcm + 0.5 * vdiff_at(t); end
    endfunction

    function real vin_n;
        input real t;
        begin vin_n = (mode == 3) ? vext_n : vcm - 0.5 * vdiff_at(t); end
    endfunction

    // ---- CDAC ------------------------------------------------------------------
    // Held top-plate voltage for a sampled input vs, sampled code cs, code c.
    function real vtop;
        input real      vs;
        input [7:0]     cs;
        input [7:0]     c;
        integer         ics, ic;
        begin
            ics = {24'd0, cs};             // integers: (cs - c) must not wrap at 8 bits
            ic  = {24'd0, c};
            vtop = vs + vref * (ics - ic) / (256.0 * (1.0 + cpar));
        end
    endfunction

    // Bottom-plate state while the switches are closed.
    always @(sample or ctlp or ctln)
        if (sample === 1'b1) begin
            csp = ctlp;
            csn = ctln;
        end

    // Switches open: hold the input on both top plates.
    always @(sample) begin
        if (sample === 1'b0 && sample_q === 1'b1) begin
            vsp = vin_p($realtime * 1.0e-9);
            vsn = vin_n($realtime * 1.0e-9);
            n_samples = n_samples + 1;
        end
        sample_q = sample;
    end

    // ---- comparator ----------------------------------------------------------
    always @(posedge clk) begin
        if (sample === 1'b1) begin         // switches closed: compare the inputs
            vtp = vin_p($realtime * 1.0e-9);
            vtn = vin_n($realtime * 1.0e-9);
        end else begin
            vtp = vtop(vsp, csp, ctlp);
            vtn = vtop(vsn, csn, ctln);
        end
        dec = (vtp + vos - trima * vtrim_lsb) > (vtn - trimb * vtrim_lsb);
        n_decisions = n_decisions + 1;
        if (verbose)
            $display("sar_afe_model %0t: ctlp=%02h trima=%02h vtp=%.4f vtn=%.4f -> %0d",
                     $time, ctlp, trima, vtp, vtn, dec);
        if (dec) outn <= #(tdec) 1'b0;
        else     outp <= #(tdec) 1'b0;
    end

    always @(negedge clk) begin            // reset: both outputs high
        outp <= #(trst) 1'b1;
        outn <= #(trst) 1'b1;
    end

endmodule
`endif // SAR_AMS
