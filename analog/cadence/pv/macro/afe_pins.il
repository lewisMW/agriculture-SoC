; afe_pins.il -- dump a macro's outline and pin shapes for export_macro.py
; (called by export_macro.sh):
;   PINS_CELL=sar_afe PINS_OUT=<file> virtuoso -nograph -replay afe_pins.il
;
;   SIZE <x0> <y0> <x1> <y1>                    PR boundary
;   PIN <term> <direction> <layer> x0 y0 x1 y1    one line per pin shape
;   EXTENT <layer> x0 y0 x1 y1                    bbox of all shapes on the
;                                                 layer, whole hierarchy
; met5 is the one layer the macro uses only in one region (the comparator's
; clock and the switches' supply runs), so the LEF obstructs met5 there only
; and the chip's met5 stripes can cross the rest of the macro.
procedure(apUnion(a b)
  cond((!a b) (!b a)
       (t list(min(caar(a) caar(b)):min(cadar(a) cadar(b))
               max(caadr(a) caadr(b)):max(cadadr(a) cadadr(b))))))
procedure(apExtent(cv layer xf)
  let((box)
    box = nil
    foreach(s cv~>shapes
      when(s~>layerName == layer && s~>bBox && !member(s~>objType '("label" "textDisplay"))
        box = apUnion(box dbTransformBBox(s~>bBox xf))))
    foreach(v cv~>vias        ; a via's bbox is its pads; count vias with a pad on the layer
      when(member(layer list(v~>viaHeader~>viaDef~>layer1Name v~>viaHeader~>viaDef~>layer2Name))
        box = apUnion(box dbTransformBBox(v~>bBox xf))))
    foreach(i cv~>instances
      when(i~>master
        box = apUnion(box apExtent(i~>master layer dbConcatTransform(i~>transform xf)))))
    box))
let((cell cv out b n e)
  cell = getShellEnvVar("PINS_CELL") || "sar_afe"
  cv = dbOpenCellViewByType("sar_adc" cell "layout" nil "r")
  unless(cv error("no sar_adc/%s layout" cell))
  unless(cv~>prBoundary error("%s has no PR boundary (rerun afe_lay.il)" cell))
  out = outfile(getShellEnvVar("PINS_OUT"))
  b = cv~>prBoundary~>bBox
  fprintf(out "SIZE %.4f %.4f %.4f %.4f\n" caar(b) cadar(b) caadr(b) cadadr(b))
  n = 0
  foreach(tm cv~>terminals
    foreach(p tm~>pins
      let((f fb)
        f = p~>fig
        when(f && f~>purpose == "pin"
          fb = f~>bBox
          fprintf(out "PIN %s %s %s %.4f %.4f %.4f %.4f\n" tm~>name tm~>direction
                  f~>layerName caar(fb) cadar(fb) caadr(fb) cadadr(fb))
          n++))))
  e = apExtent(cv "met5" list(0:0 "R0" 1.0))
  when(e
    fprintf(out "EXTENT met5 %.4f %.4f %.4f %.4f\n" caar(e) cadar(e) caadr(e) cadadr(e)))
  close(out)
  printf("AFEPINS %d pin shapes, %d terminals, met5 extent %L\n" n length(cv~>terminals) e)
  dbClose(cv))
exit()
