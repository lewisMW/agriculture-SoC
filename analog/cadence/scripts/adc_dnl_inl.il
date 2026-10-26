;; adc_dnl_inl.il -- code-density (histogram) DNL/INL for the 8-bit SAR ADC
;;
;; Load once in the CIW:   load("scripts/adc_dnl_inl.il")
;; Then run after a ramp simulation of tb_sar:
;;   adcDnlInl()                                   ; latest Maestro run, 41 ms ramp
;;   adcDnlInl(?tStop 10.0005m)                    ; for a 10 ms ramp
;;   adcDnlInl(?resDir "/path/to/psf" ?plot nil)   ; other run, numbers only
;;
;; Method: sample result<7:0> once per conversion (mid-period), histogram the
;; codes, DNL(k) = hits(k)/avg - 1 and INL(k) = sum of DNL(1..k), using codes
;; 1..254 (end codes 0 and 255 also collect over-range samples).
;; The ViVA histo() bars are triangles of base 1, so integ() gives half the hits.

procedure(adcDnlInl(@key
    (resDir "/root/simulation/sar_adc/tb_sar/maestro/results/maestro/ExplorerRun.0/1/sar_adc_tb_sar_adc_1/psf")
    (bus "/result<7:0>")
    (tStart 20.5e-6)       ; middle of the first conversion after start-up
    (tStop 41.0005e-3)     ; last mid-conversion point inside the ramp
    (tStep 10e-6)          ; conversion period (10 clock cycles at 1 MHz)
    (plot t))
  let((code smp hits avg dnl inl missing win)
    openResults(resDir)
    selectResult('tran)
    code = awvDigital2Analog(getData(bus ?result "tran") 255 0 "vhi" ?mode "busvalue" ?outWaveType "zeroT")
    smp  = sample(code tStart tStop "linear" tStep)
    hits = histo(smp 256 -0.5 255.5)
    avg  = 2*integ(hits 0.5 254.5)/254
    dnl  = sample(hits 1 254 "linear" 1)/avg - 1
    inl  = lshift(sample(2*iinteg(clip(hits 0.5 254.5))/avg - (xval(clip(hits 0.5 254.5)) - 0.5)
                         1.5 254.5 "linear" 1) 0.5)
    missing = nil
    for(k 1 254 when(value(hits k) == 0 missing = cons(k missing)))
    missing = reverse(missing)

    printf("\nADC DNL/INL  (%s)\n" resDir)
    printf("  conversions used : %d  (%g s to %g s)\n" round((tStop-tStart)/tStep)+1 tStart tStop)
    printf("  hits per code    : %.2f  %s\n" avg if(avg < 8 "<- too few, use a slower ramp (>= 16)" ""))
    printf("  DNL              : %.3f .. %.3f LSB  (resolution ~%.2f LSB)\n" ymin(dnl) ymax(dnl) 1.0/avg)
    printf("  INL              : %.3f .. %.3f LSB\n" ymin(inl) ymax(inl))
    printf("  missing codes    : %d %L\n\n" length(missing) missing)

    when(plot
      win = newWindow()
      plot(smp ?expr list("code per conversion"))
      addSubwindow()
      plot(clip(hits 0.5 254.5) ?expr list("hits per code"))
      addSubwindow()
      plot(dnl ?expr list("DNL (LSB)"))
      addSubwindow()
      plot(inl ?expr list("INL (LSB)")))

    list(nil 'code smp 'hits hits 'dnl dnl 'inl inl 'avg avg 'missing missing)))
