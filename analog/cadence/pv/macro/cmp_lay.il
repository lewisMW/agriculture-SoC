; cmp_lay.il -- generate sar_adc/comparator/layout: Erick's comparator_core
; under the lowercase interface of the behavioural comparator. Same mapping
; as the comparator schematic (afe_sch.il): outp <- Out_N, outn <- Out_P
; (latch polarity), trima <- Trimb, trimb <- Trima (trim side). Each wrapper
; pin is drawn on the core's own pin shape, so the wrapper adds no metal.
;
;   virtuoso -nograph -replay cmp_lay.il -log cmp_lay.log
let((cv core inst map n)
  core = dbOpenCellViewByType("sar_adc" "comparator_core" "layout" nil "r")
  unless(core error("no comparator_core layout"))
  cv = dbOpenCellViewByType("sar_adc" "comparator" "layout" "maskLayout" "w")
  inst = dbCreateInst(cv core "XCORE" 0:0 "R0")
  map = list(list("vp" "Vp" "input") list("vn" "Vn" "input") list("clk" "Clk" "input")
             list("vdd" "Vdd" "inputOutput") list("vss" "Vss" "inputOutput")
             list("outp" "Out_N" "output") list("outn" "Out_P" "output"))
  for(i 0 4
    map = append(map list(
      list(sprintf(nil "trima<%d>" i) sprintf(nil "Trimb<%d>" i) "input")
      list(sprintf(nil "trimb<%d>" i) sprintf(nil "Trima<%d>" i) "input"))))
  n = 0
  foreach(m map
    let((name cterm net)
      name = nth(0 m)
      cterm = dbFindTermByName(core nth(1 m))
      unless(cterm error("comparator_core has no terminal %s" nth(1 m)))
      net = dbMakeNet(cv name)
      dbCreateTerm(net name nth(2 m))
      foreach(p cterm~>pins
        let((fig b lpp r)
          fig = p~>fig
          b = dbTransformBBox(fig~>bBox inst~>transform)
          r = dbCreateRect(cv list(fig~>layerName "pin") b)
          dbCreatePin(net r)
          dbCreateRect(cv list(fig~>layerName "drawing") b)
          dbCreateLabel(cv list(fig~>layerName "pin") centerBox(b) name "centerCenter" "R0" "roman" 0.1)
          n++))))
  printf("CMPLAY pins=%d bbox=%L\n" n cv~>bBox)
  dbSave(cv) dbClose(cv))
exit()
