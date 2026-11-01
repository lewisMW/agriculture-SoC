; afe_sch.il -- schematics for sar_adc/comparator (wrapper) and sar_adc/sar_afe.
; Run from a dir whose cds.lib includes analog/cadence/cds.lib:
;   virtuoso -nograph -replay afe_sch.il -log afe_sch.log
load(strcat(getShellEnvVar("MACRO_DIR") "/schgen.il"))

; ---------------------------------------------------------------------------
; sar_adc/comparator: the lowercase interface of the behavioural comparator,
; implemented by Erick's comparator_core. Two deliberate crossings:
;   - output polarity: the core's latch pulls the WINNER low, so vp > vn
;     gives Out_P = 0. The SAR (sr_latch/sarlogic) and the behavioural model
;     expect outp = 1, hence outp <- Out_N, outn <- Out_P. (The AMS netlist
;     carried this same cross as a hand-written wrapper since 4 Aug.)
;   - trim side: the behavioural model's trima lowers the effective vp.
;     Extra cap on a branch's drain node slows that branch, so the trim that
;     lowers vp must load net3 (the Vp transistor's drain) -- that is the
;     core's Trimb array. Hence trima <- Trimb, trimb <- Trima.
; ---------------------------------------------------------------------------
m1SchBuild("sar_adc" "comparator"
  list(
    list("XCORE" "sar_adc" "comparator_core" 0.0 0.0
      list(list("Vp" "vp") list("Vn" "vn") list("Clk" "clk")
           list("Vdd" "vdd") list("Vss" "vss")
           list("Out_P" "outn") list("Out_N" "outp")
           list("Trima<4:0>" "trimb<4:0>") list("Trimb<4:0>" "trima<4:0>"))))
  list(
    list("vp" "input" -2.0 0.5) list("vn" "input" -2.0 0.0)
    list("clk" "input" -2.0 -0.5)
    list("trima<4:0>" "input" -2.0 -1.0) list("trimb<4:0>" "input" -2.0 -1.5)
    list("outp" "output" 4.5 0.5) list("outn" "output" 4.5 0.0)
    list("vdd" "inputOutput" -2.0 1.5) list("vss" "inputOutput" -2.0 -2.0)))

; ---------------------------------------------------------------------------
; sar_adc/sar_afe: the ADC analog front end (the hard macro), and its
; placement variants sar_afe_r and sar_afe_b (same circuit, see afe_lay.il).
;   2 x cdac_8b + comparator
; cdac_8b is Hee's: carray_8b + 9 bit-driver inverters + Jaime's bootstrap
; switch, LVS-clean on its own (20 Oct). Its bit drivers run from vref, the
; CDAC reference, and its switch from vdda; both come out as macro pins, so
; the reference can be decoupled on its own. vssa is tied to vss: both
; grounds sit on the one p-substrate. That is the analog content of
; sar/verilogams (cdacp, cdacn, comp); sr_latch and sarlogic stay digital.
; The dummy inverter's input ctl_dum is tied to vss (sar.vams drives
; ctl_dum = 1'b0).
; ---------------------------------------------------------------------------
let((insts)
  insts = nil
  foreach(sfx '("p" "n")
    insts = cons(list(strcat("XC" upperCase(sfx)) "sar_adc" "cdac_8b"
      if(sfx == "p" 0.0 40.0) 0.0
      list(list("vin" strcat("vin" sfx)) list("vout" strcat("vtop" sfx))
           list("ctl<7:0>" strcat("ctl" sfx "<7:0>")) list("ctl_dum" "vss")
           list("sample" "sample") list("vdda" "vdda") list("vref" "vref")
           list("vssa" "vss"))) insts))
  insts = cons(list("XCMP" "sar_adc" "comparator" 20.0 30.0
    list(list("vp" "vtopp") list("vn" "vtopn") list("outp" "outp") list("outn" "outn")
         list("clk" "clk") list("trima<4:0>" "trima<4:0>") list("trimb<4:0>" "trimb<4:0>")
         list("vdd" "vdd") list("vss" "vss"))) insts)
  foreach(cell '("sar_afe" "sar_afe_r" "sar_afe_b")
    m1SchBuild("sar_adc" cell reverse(insts)
      list(
        list("vinp" "input" -4.0 6.0) list("vinn" "input" -4.0 5.0)
        list("sample" "input" -4.0 4.0) list("clk" "input" -4.0 3.0)
        list("ctlp<7:0>" "input" -4.0 2.0) list("ctln<7:0>" "input" -4.0 1.0)
        list("trima<4:0>" "input" -4.0 0.0) list("trimb<4:0>" "input" -4.0 -1.0)
        list("outp" "output" 80.0 6.0) list("outn" "output" 80.0 5.0)
        list("vdd" "inputOutput" -4.0 -2.0) list("vdda" "inputOutput" -4.0 -3.0)
        list("vref" "inputOutput" -4.0 -3.5) list("vss" "inputOutput" -4.0 -4.0))))
  ; m1SchBuild makes a symbol only for a new cell. The existing symbols get
  ; the supply pins added since, each next to the one before it: vdda (18 Oct)
  ; after vdd, vref (20 Oct) after vdda.
  foreach(cell '("sar_afe" "sar_afe_r" "sar_afe_b")
    m1SymAddPin("sar_adc" cell "vdda" "vdd" 0.125)
    m1SymAddPin("sar_adc" cell "vref" "vdda" 0.125)))
exit()
