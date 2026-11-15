;; tbcmp_setup.il: builds the comparator verification suite in a Maestro view.
;; Usage from the CIW:  load("<...>/verif_comparator/tbcmp_setup.il")  then  tbcmpSetup()
;; Optional: tbcmpSetup(?lib "other_lib").  Repoint tests with tbcmpSetView(view [tests]).

tbcmpDir = "/home/admin/Documents/Erick_dev_git_copy/agriculture-SoC/analog/cadence/verif_comparator"
tbcmpModel = "/home/admin/Documents/PDKs/sky130_release_0.1.0/models/sky130.lib.spice"
tbcmpSess = nil

;; ---------- expression helpers ----------
procedure( VV(n) sprintf(nil "VAR(\"%s\")" n) )
tbcmpOP = "VT(\"/outp\")"
tbcmpON = "VT(\"/outn\")"
tbcmpCK = "VT(\"/clk\")"
tbcmpDI = strcat("abs(" tbcmpOP "-" tbcmpON ")")
tbcmpVH = strcat(VV("vcc") "/2")

procedure( TR(k) sprintf(nil "(%g/%s)" float(k)+0.5 VV("fclk")) )
procedure( TF(k) sprintf(nil "((%g+%s)/%s)" float(k)+0.5 VV("duty") VV("fclk")) )
procedure( TS(k) sprintf(nil "(%s-%s)" TF(k) VV("tsu")) )
procedure( TCQ(k)
  sprintf(nil "delay(?wf1 %s ?value1 %s ?edge1 \"rising\" ?nth1 %d ?wf2 %s ?value2 %s ?edge2 \"rising\" ?nth2 %d)"
          tbcmpCK tbcmpVH k+1 tbcmpDI tbcmpVH k+1) )
procedure( TREC(k)
  sprintf(nil "delay(?wf1 %s ?value1 %s ?edge1 \"falling\" ?nth1 %d ?wf2 %s ?value2 0.1*%s ?edge2 \"falling\" ?nth2 %d)"
          tbcmpCK tbcmpVH k+1 tbcmpDI VV("vcc") k+1) )
procedure( DEC(k)
  sprintf(nil "tbcmpDec(%s %s %s %s %s)" tbcmpOP tbcmpON TS(k) VV("vcc") VV("pol")) )
procedure( NODE(n k) sprintf(nil "value(VT(\"%s\") (%s-1e-9))/%s" n TR(k) VV("vcc")) )
procedure( EINT(a b)
  sprintf(nil "integ(-%s*IT(\"/V0/PLUS\") %s %s)" VV("vcc") a b) )

tbcmpTIME = strcat(VV("fclk") " " VV("duty") " " VV("tsu"))
tbcmpSTAIR = strcat(tbcmpOP " " tbcmpON " " tbcmpTIME " " VV("vstart") " " VV("vstep") " "
                    VV("nsteps") " " VV("nrep") " " VV("vcc") " " VV("pol"))
tbcmpVOS = strcat("tbcmp_vos(" tbcmpSTAIR ")")
tbcmpSIG = strcat("tbcmp_sigma(" tbcmpSTAIR ")")
procedure( HIST(sel)
  sprintf(nil "tbcmp_hist(%s %s %s %s %s %s %s %s %d)" tbcmpOP tbcmpON tbcmpTIME
          VV("vstart") VV("vstep") VV("nsteps") VV("vcc") VV("pol") sel) )
procedure( COUNT(what)
  sprintf(nil "tbcmp_count(%s %s %s %s %s %s %s %s %s %s %s \"%s\")" tbcmpOP tbcmpON tbcmpTIME
          VV("mode") VV("vd") VV("vstart") VV("vstep") VV("nrep") VV("ncyc") VV("vos")
          strcat(VV("vcc") " " VV("pol")) what) )
tbcmpEOUT = list("E_cycle" strcat(EINT(TF(4) TF(14)) "/10"))

;; Nominal values. Everything is a design variable so any of them can be swept.
tbcmpDefaults = '(
  ("vcc" "1.8") ("vcm" "0.9") ("vd" "10m") ("fclk" "1M") ("duty" "0.5")
  ("tr" "100p") ("tf" "100p") ("trim_a" "8") ("trim_b" "8") ("rs" "1")
  ("ccdac" "9.3p") ("cload" "10f") ("mode" "0") ("vstart" "-30m") ("vstep" "1m")
  ("nsteps" "61") ("nrep" "1") ("vagg" "300m") ("tsu" "0.5n") ("pol" "-1")
  ("vos" "0") ("ncyc" "20") ("tstop" "(ncyc+1)/fclk") )

;; Stair stimulus, for tests that extract offset. tstop covers nsteps*nrep cycles.
tbcmpSTAIRV = '(("mode" "1") ("ncyc" "nsteps*nrep"))

;; ---------- test table: (name  vars  outputs  specs [analysisOptions]) ----------
;; outputs: (name expr [evalType]); specs: (output key value)
procedure( tbcmpTests()
  let( (vcm7 trim31)
    vcm7 = "0.3 0.5 0.7 0.9 1.1 1.3 1.5"
    trim31 = "0:1:31"
    list(
      ;; 1 (was sar_adc_tb_comparator_parasitic_1). pol=+1: checks the SAR's required polarity.
      list("Basic_op" '(("mode" "2") ("vd" "5m 20m 100m") ("pol" "1") ("ncyc" "8"))
        list(list("dec_pos" DEC(2)) list("dec_neg" DEC(3)) list("n_correct" COUNT("correct"))
             list("n_wrong" COUNT("wrong")) list("n_unres" COUNT("unresolved")))
        '(("dec_pos" ?gt "0.5") ("dec_neg" ?lt "-0.5") ("n_wrong" ?lt "1") ("n_unres" ?lt "1")))
      ;; 2
      list("Reset_op" '(("vd" "100m") ("ncyc" "6"))
        list(list("outp_rst" NODE("/outp" 3)) list("outn_rst" NODE("/outn" 3))
             list("net2_rst" NODE("/I0/XCORE/net2" 3)) list("net3_rst" NODE("/I0/XCORE/net3" 3))
             list("t_reset" TREC(2))
             list("t_reset_frac" sprintf(nil "%s*%s/(1-%s)" TREC(2) VV("fclk") VV("duty"))))
        '(("outp_rst" ?gt "0.95") ("outn_rst" ?gt "0.95") ("net2_rst" ?gt "0.9") ("net3_rst" ?gt "0.9")
          ("t_reset_frac" ?lt "0.5")))
      ;; 3 (was Off_set)
      list("Off_set" append('(("vstart" "-30m") ("vstep" "0.25m") ("nsteps" "241")) tbcmpSTAIRV)
        list(list("Vos" tbcmpVOS))
        '(("Vos" ?range "-5m 5m")))
      ;; 4 (was Input_ref_noise). Center vstart on Vos from Off_set.
      list("Input_ref_noise" append('(("vstart" "-3m") ("vstep" "0.25m") ("nsteps" "25") ("nrep" "20") ("fclk" "5M")) tbcmpSTAIRV)
        list(list("Vos_noisy" tbcmpVOS) list("sigma_n" tbcmpSIG))
        '(("sigma_n" ?lt "1.75m"))
        '(("tranNoise" "Transient Noise") ("noisefmax" "5G") ("noisefmin" "50k") ("noiseseed" "1")))
      ;; 5 (was Decision_delay)
      list("Decision_delay" '(("vd" "-100m -10m -1m 1m 3m 10m 30m 100m 300m") ("ncyc" "6"))
        list(list("t_cq" TCQ(3))
             list("t_cq_frac" sprintf(nil "%s/(%s/%s-%s)" TCQ(3) VV("duty") VV("fclk") VV("tsu"))))
        '(("t_cq_frac" ?lt "1")))
      ;; 6 (was Metastability). vos = Off_set result (schematic, tt: -125u); the 1 uV steps straddle it.
      list("Metastability" append('(("vos" "-125u") ("vstart" "vos-50u") ("vstep" "1u") ("nsteps" "101") ("fclk" "1M 5M 20M")) tbcmpSTAIRV)
        list(list("n_wrong" COUNT("wrong")) list("n_unres" COUNT("unresolved")) list("n_correct" COUNT("correct"))
             list("t_cq_worst" TCQ(50)))
        '(("n_unres" ?lt "1")))
      ;; 7
      list("Common_mode" append(list(list("vcm" vcm7)) tbcmpSTAIRV)
        list(list("Vos" tbcmpVOS) list("t_cq" TCQ(3)) list("n_wrong" COUNT("wrong")) list("n_unres" COUNT("unresolved")))
        '(("Vos" ?range "-5m 5m") ("n_unres" ?lt "1")))
      ;; 8. rs=1G leaves inp/inn floating on ccdac, as during SAR conversion.
      list("Kickback" '(("vd" "1m 100m") ("rs" "1G") ("ccdac" "9.3p 1p 100f") ("ncyc" "8"))
        list(list("kick_inp" sprintf(nil "peakToPeak(clip(VT(\"/inp\") %s %s))" TR(5) TR(6)))
             list("kick_inn" sprintf(nil "peakToPeak(clip(VT(\"/inn\") %s %s))" TR(5) TR(6)))
             list("kick_diff" sprintf(nil "peakToPeak(clip((VT(\"/inp\")-VT(\"/inn\")) %s %s))" TR(5) TR(6)))
             list("resid_diff" sprintf(nil "value(VT(\"/inp\")-VT(\"/inn\") %s)-value(VT(\"/inp\")-VT(\"/inn\") %s)" TR(6) TR(5))))
        '(("kick_diff" ?lt "3.5m")))
      ;; 9
      list("Power_energy" '(("mode" "2") ("vd" "1m 10m 100m") ("ncyc" "16"))
        list(tbcmpEOUT
             list("P_avg" strcat(EINT(TF(4) TF(14)) "/10*" VV("fclk")))
             list("E_eval" strcat(EINT(TR(5) TF(5))))
             list("E_reset" strcat(EINT(TF(5) TR(6)))))
        nil)
      ;; 10. Every test cycle is preceded by a +vagg or -vagg decision.
      list("History_dep" '(("mode" "3") ("vstart" "-10m") ("vstep" "0.25m") ("nsteps" "81") ("ncyc" "324"))
        list(list("Vth_after_pos" HIST(1)) list("Vth_after_neg" HIST(-1)) list("dVth_hist" HIST(0)))
        '(("dVth_hist" ?range "-1m 1m")))
      ;; 11: one test per clock parameter
      list("Clk_freq" '(("mode" "2") ("ncyc" "8") ("fclk" "1M 2M 5M 10M 20M 50M 100M"))
        tbcmpClkOuts() tbcmpClkSpecs())
      list("Clk_edge" '(("mode" "2") ("ncyc" "8") ("tr" "50p 200p 1n 5n") ("tf" "tr"))
        tbcmpClkOuts() tbcmpClkSpecs())
      list("Clk_duty" '(("mode" "2") ("ncyc" "8") ("duty" "0.2 0.3 0.4 0.5 0.6 0.7 0.8"))
        tbcmpClkOuts() tbcmpClkSpecs())
      list("Clk_reset" '(("mode" "2") ("ncyc" "8") ("t_rst" "1n 2n 5n 10n 50n 200n 500n") ("t_eval" "500n")
                         ("fclk" "1/(t_eval+t_rst)") ("duty" "t_eval/(t_eval+t_rst)"))
        tbcmpClkOuts() tbcmpClkSpecs())
      ;; 12
      list("Output_compat" '(("mode" "2") ("vd" "10m") ("ncyc" "8") ("cload" "5f 10f 50f"))
        list(list("V_high" sprintf(nil "max(value(%s %s) value(%s %s))/%s" tbcmpOP TS(3) tbcmpON TS(3) VV("vcc")))
             list("V_low" sprintf(nil "min(value(%s %s) value(%s %s))/%s" tbcmpOP TS(3) tbcmpON TS(3) VV("vcc")))
             list("V_peak" sprintf(nil "max(ymax(clip(%s %s %s)) ymax(clip(%s %s %s)))/%s" tbcmpOP TR(2) TR(4) tbcmpON TR(2) TR(4) VV("vcc")))
             list("V_undershoot" sprintf(nil "min(ymin(clip(%s %s %s)) ymin(clip(%s %s %s)))/%s" tbcmpOP TR(2) TR(4) tbcmpON TR(2) TR(4) VV("vcc")))
             list("t_cq" TCQ(3))
             list("setup_margin" sprintf(nil "%s/%s-%s-%s" VV("duty") VV("fclk") VV("tsu") TCQ(3)))
             list("hold_t_after_clk" TREC(2))
             list("n_unres" COUNT("unresolved")))
        '(("V_high" ?gt "0.9") ("V_low" ?lt "0.1") ("V_peak" ?lt "1.1") ("V_undershoot" ?gt "-0.1")
          ("setup_margin" ?gt "0") ("n_unres" ?lt "1")))
      ;; 13: the only test with the PVT corners enabled
      list("PVT" tbcmpSTAIRV
        list(list("Vos" tbcmpVOS) list("t_cq" TCQ(3)) list("n_wrong" COUNT("wrong")) list("n_unres" COUNT("unresolved"))
             tbcmpEOUT)
        '(("Vos" ?range "-5m 5m") ("n_unres" ?lt "1")))
      ;; 14: run in Monte Carlo Sampling mode with only this test enabled
      list("MC_mismatch" append('(("vstart" "-60m") ("vstep" "1m") ("nsteps" "121")) tbcmpSTAIRV)
        list(list("Vos" tbcmpVOS) list("t_cq" TCQ(3)) tbcmpEOUT)
        nil nil list(strcat(tbcmpDir "/tbcmp_mc.scs")))
      ;; 15
      list("Trim_a" append(list(list("trim_a" trim31)) tbcmpSTAIRV)
        list(list("Vos" tbcmpVOS) list("t_cq" TCQ(3)) tbcmpEOUT) nil)
      list("Trim_b" append(list(list("trim_b" trim31)) tbcmpSTAIRV)
        list(list("Vos" tbcmpVOS) list("t_cq" TCQ(3)) tbcmpEOUT) nil)
    )
  )
)
procedure( tbcmpClkOuts()
  list(list("t_cq" TCQ(3))
       list("t_cq_frac" sprintf(nil "%s/(%s/%s-%s)" TCQ(3) VV("duty") VV("fclk") VV("tsu")))
       list("n_correct" COUNT("correct"))
       list("n_unres" COUNT("unresolved"))
       list("n_wrong" COUNT("wrong"))) )
procedure( tbcmpClkSpecs() '(("n_wrong" ?lt "1") ("n_unres" ?lt "1")) )

;; ---------- post-layout tests: reuse the outputs of the critical schematic tests ----------
tbcmpPex = '("Basic_op" "Off_set" "Decision_delay" "Kickback" "Power_energy")

procedure( tbcmpBuild(tn vars outs specs lib view opts defs)
  let( ()
    unless( maeCreateTest(tn ?lib lib ?cell "tb_comparator_parasitic" ?view view ?simulator "spectre" ?session tbcmpSess)
      error("maeCreateTest failed for %s" tn))
    maeSetEnvOption(tn ?session tbcmpSess
      ?options list(
        list("modelFiles" list(list(tbcmpModel "tt")))
        list("definitionFiles" append(list(strcat(tbcmpDir "/tbcmp_stim.scs")) defs))))
    maeSetAnalysis(tn "tran" ?enable t ?session tbcmpSess
      ?options append(list(list("stop" "VAR(\"tstop\")") list("errpreset" "moderate")) opts))
    maeSetSimOption(tn ?session tbcmpSess
      ?options '(("reltol" "1e-5") ("vabstol" "1e-6") ("iabstol" "1e-12") ("gmin" "1e-12")))
    foreach( v tbcmpDefaults
      maeSetVar(car(v) cadr(v) ?typeName "test" ?typeValue list(tn) ?session tbcmpSess))
    foreach( v vars
      maeSetVar(car(v) cadr(v) ?typeName "test" ?typeValue list(tn) ?session tbcmpSess))
    foreach( o outs
      maeAddOutput(car(o) tn ?outputType or(caddr(o) "point") ?expr cadr(o) ?session tbcmpSess))
    foreach( s specs
      if( cadr(s) == '?range then
        maeSetSpec(car(s) tn ?range parseString(caddr(s)) ?session tbcmpSess)
      else
        apply('maeSetSpec append(list(car(s) tn) append(cdr(s) list(?session tbcmpSess))))
      ))
  )
)

;; Exclude the old stimulus instance from the netlist.
procedure( tbcmpPatchSchematic(lib)
  let( (cv inst)
    cv = dbOpenCellViewByType(lib "tb_comparator_parasitic" "schematic" nil "a")
    unless( cv  error("cannot open schematic for edit: clear the stale lock (see README)"))
    inst = dbFindAnyInstByName(cv "I11")
    unless( inst  error("instance I11 not found"))
    dbReplaceProp(inst "nlAction" "string" "ignore")
    schCheck(cv)
    dbSave(cv)
    dbClose(cv)
    t
  )
)

procedure( tbcmpSetup( @key (lib "sar_adc") (patch t) )
  let( (src bak exist)
    src = ddGetObj(lib "tb_comparator_parasitic" "maestro")~>readPath
    bak = strcat(tbcmpDir "/backup_maestro_" lib)
    unless( isDir(bak)
      unless( system(sprintf(nil "mkdir -p %s && cp -rp %s/maestro.sdb %s/active.state %s/namedStimuli %s/" bak src src src bak)) == 0
        error("backup failed: nothing changed")))
    when( patch  tbcmpPatchSchematic(lib) )
    load(strcat(tbcmpDir "/tbcmp_lib.il"))
    tbcmpSess = maeOpenSetup(lib "tb_comparator_parasitic" "maestro" ?mode "a")
    unless( tbcmpSess  error("cannot open maestro view for writing"))
    exist = maeGetSetup(?session tbcmpSess)
    ;; Recreated rather than edited: their graphical stimuli drive inp/inn directly,
    ;; which would short out the CDAC and source models.
    foreach( tn exist  maeDeleteTest(tn ?session tbcmpSess))
    foreach( d tbcmpTests()
      tbcmpBuild(car(d) cadr(d) caddr(d) cadddr(d) lib "schematic" nth(4 d) nth(5 d)) )
    foreach( d setof(x tbcmpTests() member(car(x) tbcmpPex))
      tbcmpBuild(strcat("PEX_" car(d)) cadr(d)
                 setof(o caddr(d) !rexMatchp("I0/XCORE" cadr(o)))
                 setof(s cadddr(d) !rexMatchp("net[23]" car(s)))
                 lib "config_pex" nth(4 d) nth(5 d)) )
    maeLoadCorners(strcat(tbcmpDir "/tbcmp_corners.sdb") ?operation "overwrite" ?session tbcmpSess)
    tbcmpCornersOnlyFor("PVT")
    maeSetRunOption("Monte Carlo Sampling" "mcnumpoints" "200" ?session tbcmpSess)
    maeSetRunOption("Monte Carlo Sampling" "mcmethod" "mismatch" ?session tbcmpSess)
    ;; One test enabled to start; enable the one you want to run.
    maeEnableTests(?testNames maeGetSetup(?session tbcmpSess) ?enable nil ?session tbcmpSess)
    maeEnableTests(?testNames '("Basic_op") ?enable t ?session tbcmpSess)
    maeSaveSetup(?session tbcmpSess)
    printf("tbcmpSetup: %d tests saved in %s\n" length(maeGetSetup(?session tbcmpSess)) lib)
    tbcmpSess
  )
)

procedure( tbcmpCornersOnlyFor(test)
  let( ((others setof(x maeGetSetup(?session tbcmpSess) x != test)))
    foreach( c setof(x maeGetSetup(?typeName "corners" ?session tbcmpSess) !member(x '("Nominal" "_default")))
      maeSetCorner(c ?enableTests list(test) ?disableTests others ?session tbcmpSess))
  )
)

;; Switch tests between views, e.g. tbcmpSetView("config_pex" '("Off_set")) or "schematic".
procedure( tbcmpSetView(view @optional tests)
  foreach( tn or(tests maeGetSetup(?session tbcmpSess))
    maeSetDesign(tn "sar_adc" "tb_comparator_parasitic" view ?session tbcmpSess))
  maeSaveSetup(?session tbcmpSess)
)
