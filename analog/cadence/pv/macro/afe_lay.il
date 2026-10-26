; afe_lay.il -- generate the ADC analog macro layout: sar_adc/sar_afe and its
; placement variants.
;
; Run (batch) from a dir whose cds.lib includes analog/cadence/cds.lib:
;   AFE_VARIANT=l virtuoso -nograph -replay afe_lay.il -log afe_lay.log
;
; AFE_VARIANT  cell        analog inputs   digital pins   for a macro at the chip's
;   l          sar_afe     left edge       right edge     bottom-left
;   r          sar_afe_r   right edge      left edge      bottom-right
;   b          sar_afe_b   bottom edge     top edge       bottom, mid-chip
; r is l mirrored and b is l rotated by 90 degrees, so all three have the
; same internal layout. Only their edge pins and supply straps differ: b's
; digital pins are met2, and its supply straps run along its top and bottom
; edges.
;
; Floorplan of l (um, origin bottom-left):
;   - two of Hee's cdac_8b (carray_8b, 9 bit-driver inverters and Jaime's
;     bootstrapped switch; LVS-clean on its own), stacked: N at the bottom
;     (R0) and P above it mirrored (MX), so both cells' vin/vout corners face
;     a 12 um gap in the middle and their supply pins face the macro's top
;     and bottom edges;
;   - vinp/vinn come in on met3 from the left edge, straight to each cdac's
;     vin corner;
;   - to the right of the cdacs: the vout risers, then Erick's comparator
;     (rotated, inputs facing the cdacs) level with the gap;
;   - every digital pin is a met3 stub on the right edge, on the
;     sky130_fd_sc_hd met3 tracks: each cdac's ctl pins (on its right edge)
;     run straight across, ctlp above the comparator and ctln below it, as
;     does sample; the comparator's signals are in the middle;
;   - supplies are eight full-height met4 straps, from each edge inward vss,
;     vdda, vref, vdd. vref is the CDAC reference (the bit-driver inverters),
;     vdda the sampling switches, vdd the comparator. Below N and above P a
;     met3 bus per supply joins its left and right straps, and each cdac's
;     supply pins (vref, vdda, vssa on its outer edge) drop onto those buses;
;     vssa is tied to vss. met5 carries only the comparator's clock.
; Pin positions of the leaf cells are read from their layouts.

let((cv tf variant cellName G W H wC hC xA xR yB yP gc xVt xK xBs oxC oyC xO xJ
     cdac cmp wM2 wM3 wM4 rows straps)

; ---------------------------------------------------------------- helpers --
; Shapes are drawn in the frame of variant l, clipped to the macro outline,
; and mapped to the variant by G.
procedure(afeBox(x0 y0 x1 y1)
  dbTransformBBox(list(max(min(x0 x1) 0.0):max(min(y0 y1) 0.0)
                       min(max(x0 x1) W):min(max(y0 y1) H)) G))
procedure(afeRect(lay x0 y0 x1 y1)
  dbCreateRect(cv list(lay "drawing") afeBox(x0 y0 x1 y1)))
procedure(afeH(lay y x0 x1 w)    ; horizontal wire, centre line y
  afeRect(lay min(x0 x1) - w/2 y - w/2 max(x0 x1) + w/2 y + w/2))
procedure(afeV(lay x y0 y1 w)    ; vertical wire, centre line x
  afeRect(lay x - w/2 min(y0 y1) - w/2 x + w/2 max(y0 y1) + w/2))
procedure(afeVia(name x y)
  dbCreateVia(cv techFindViaDefByName(tf name) dbTransformPoint(x:y G) "R0" nil))
; via stack between metal levels (1 = met1 ... 5 = met5)
procedure(afeStack(from to x y)
  let((names)
    names = '("M1M2_C" "M2M3_C" "M3M4_C" "M4M5_C")
    for(i from to - 1 afeVia(nth(i - 1 names) x y))
    ; a stack passing through met3 leaves only its two via pads on met3,
    ; under the 0.24 um2 minimum area (CDR.m3.6): add a landing patch
    when(from <= 2 && to >= 4 afeRect("met3" x - 0.3 y - 0.3 x + 0.3 y + 0.3))))
; a pin on a box already in macro coordinates
procedure(afePinM(name lay b dir @optional pinName)
  let((net fig)
    net = dbMakeNet(cv name)
    fig = dbCreateRect(cv list(lay "pin") b)
    unless(net~>term dbCreateTerm(net name dir))
    dbCreatePin(net fig pinName || name)
    dbCreateLabel(cv list(lay "pin") centerBox(b) name "centerCenter" "R0" "roman" 0.2)
    dbCreateRect(cv list(lay "drawing") b)))
; digital pin at the l frame's right edge, on a met3 track y that already
; runs to the edge. b turns that edge into its top edge, where the routing
; layer is met2: step down to a met2 stub there.
procedure(afeEdgePin(name y dir)
  if(variant == "b" then
    afeVia("M2M3_C" W - 1.0 y)
    afeRect("met2" W - 1.15 y - 0.15 W y + 0.15)
    afePinM(name "met2" afeBox(W - 0.6 y - 0.15 W y + 0.15) dir)
  else
    afePinM(name "met3" afeBox(W - 0.6 y - 0.2 W y + 0.2) dir)))
; analog input pin at the l frame's left edge (met3)
procedure(afeAnalogPin(name y)
  afePinM(name "met3" afeBox(0.0 y - 0.2 0.6 y + 0.2) "input"))
; full-height supply strap of the l frame (b: full-width, top and bottom)
procedure(afeStrap(name x0 x1 side)
  afePinM(name "met4" afeBox(x0 0.0 x1 H) "inputOutput" strcat(name "_" side)))
procedure(afeInst(lib cell name x y orient)
  let((xf)
    xf = dbConcatTransform(list(x:y orient 1.0) G)
    dbCreateInst(cv dbOpenCellViewByType(lib cell "layout" nil "r") name car(xf) cadr(xf))))
; bbox, in the l frame, of each pin of terminal `name` of master placed at xf
procedure(afePins(master xf name)
  let((tm)
    tm = dbFindTermByName(master name)
    unless(tm && tm~>pins error("%s/%s has no pin %s" master~>libName master~>cellName name))
    mapcar(lambda((p) dbTransformBBox(p~>fig~>bBox xf)) tm~>pins)))
; pin centres, snapped to the 5 nm manufacturing grid (x.1b)
procedure(afeSnap(v) round(v / 0.005) * 0.005)
procedure(afeCx(b) afeSnap((caar(b) + caadr(b)) / 2.0))
procedure(afeCy(b) afeSnap((cadar(b) + cadadr(b)) / 2.0))
; met3 tracks of sky130_fd_sc_hd (pitch 0.68, offset 0.34)
procedure(afeTrk(y) afeSnap(0.34 + 0.68 * round((y - 0.34) / 0.68)))
; met2 jog at x from y0 to y1 between an M1M2 and an M2M3 via: one 0.4 um
; rectangle over both via pads. A plain 0.3 um wire leaves 10-50 nm notches
; against the pads when the jog is short and the variant is rotated (b: the
; vias keep their R0 orientation), CDR.m2.2.
procedure(afeJog(x y0 y1)
  afeRect("met2" x - 0.2 min(y0 y1) - 0.2 x + 0.2 max(y0 y1) + 0.2))

; -------------------------------------------------------------- geometry --
variant = lowerCase(getShellEnvVar("AFE_VARIANT") || "l")
cellName = cond((variant == "l" "sar_afe") (variant == "r" "sar_afe_r")
                (variant == "b" "sar_afe_b") (t error("AFE_VARIANT must be l, r or b")))
wM2 = 0.3  wM3 = 0.4  wM4 = 0.4
cdac = dbOpenCellViewByType("sar_adc" "cdac_8b" "layout" nil "r")
cmp = dbOpenCellViewByType("sar_adc" "comparator" "layout" nil "r")
unless(cdac && cmp error("missing cdac_8b or comparator layout"))
unless(caar(cdac~>bBox) == 0.0 && cadar(cdac~>bBox) == 0.0
  error("cdac_8b's bbox must start at its origin, got %L" cdac~>bBox))
wC = caadr(cdac~>bBox)  hC = cadadr(cdac~>bBox)    ; 180.19 x 199.661 (20 Oct)

; l frame. Columns: 23 um of straps, 2 um, the cdacs, the vout risers and
; the ctl/sample via column, the comparator column, the right-hand straps.
; Rows: four supply buses, N, the gap, P, four supply buses.
xA = 25.0                          ; cdacs' left edge
xR = xA + wC                       ; cdacs' right edge (their ctl/sample/vout pins)
yB = 9.0                           ; N cdac bottom
yP = afeSnap(yB + 2.0 * hC + 12.0) ; P cdac top (its MX origin)
gc = afeSnap((yB + yP) / 2.0)      ; centre of the gap between the cdacs
xK = xR + 1.0                      ; ctl/sample vias (met1 -> met2 -> met3)
xVt = xR + 1.5                     ; vout risers (met2)
xBs = xR + 4.5                     ; left edge of the comparator column
oxC = xBs + 1.5 + 17.63            ; comparator (R90: x -> oxC - y, y -> oyC + x)
oyC = afeSnap(gc - (30.926 - 13.141) / 2.0)
xO = oxC + 2.0                     ; comparator output risers (met2)
xJ = oxC + 5.5                     ; sample: N joins P here (met2)
W = 260.0
H = afeSnap(yP + 9.0)
unless(W - 23.0 > xJ + 1.5 error("macro too narrow: right straps at %g, sample join at %g" W - 23.0 xJ))
straps = list(list("vss" 1.0 5.0) list("vdda" 7.0 11.0) list("vref" 13.0 17.0) list("vdd" 19.0 23.0))

; the transform from the l frame to the variant
G = cond((variant == "l" list(0:0 "R0" 1.0))
         (variant == "r" list(W:0 "MY" 1.0))
         (variant == "b" list(H:0 "R90" 1.0)))

cv = dbOpenCellViewByType("sar_adc" cellName "layout" "maskLayout" "w")
tf = techGetTechFile(cv)
unless(tf error("no tech file"))

; ------------------------------------------------------------- placement --
afeInst("sar_adc" "cdac_8b" "XCN" xA yB "R0")
afeInst("sar_adc" "cdac_8b" "XCP" xA yP "MX")
afeInst("sar_adc" "comparator" "XCMP" oxC oyC "R90")

; per cdac: suffix, its l-frame transform, its outer edge, and the side its
; supply buses lie on (-1 = below N, +1 = above P)
rows = list(list("n" list(xA:yB "R0" 1.0) yB -1.0)
            list("p" list(xA:yP "MX" 1.0) yP 1.0))

; ----------------------------------------------------- cdac bottom plates --
; each ctl pin (met1, on the cdac's right edge) leaves on met1 to xK, steps to
; its own met3 track and runs to the right edge. ctl_dum goes to the
; right-hand vss strap instead (sar.vams drives ctl_dum = 0). The pins are
; at least 1.34 um apart, so their tracks are at least two apart.
foreach(r rows
  let((sfx xf)
    sfx = nth(0 r) xf = nth(1 r)
    foreach(nm '("ctl_dum" "ctl<0>" "ctl<1>" "ctl<2>" "ctl<3>" "ctl<4>" "ctl<5>" "ctl<6>" "ctl<7>")
      let((b y yt)
        b = car(afePins(cdac xf nm))
        y = afeCy(b)  yt = afeTrk(y)
        afeH("met1" y caar(b) xK 0.15)
        afeVia("M1M2_C" xK y)
        afeJog(xK y yt)
        afeVia("M2M3_C" xK yt)
        if(nm == "ctl_dum" then
          afeH("met3" yt xK W - 3.0 wM3)
          afeVia("M3M4_C" W - 3.0 yt)            ; onto the vss strap
        else
          afeH("met3" yt xK W wM3)
          afeEdgePin(sprintf(nil "ctl%s<%s>" sfx substring(nm 5 1)) yt "input"))))))

; ---------------------------------------------------------------- sample --
; each cdac's sample pin (met1, right edge, the switch enable) leaves on met1
; to xK and runs on its own met3 track to xJ; N joins P there on met2, and
; P's track carries on to the right edge as the pin.
let((tp tn)
  foreach(r rows
    let((b y yt)
      b = car(afePins(cdac nth(1 r) "sample"))
      y = afeCy(b)  yt = afeTrk(y)
      afeH("met1" y caar(b) xK 0.3)
      afeVia("M1M2_C" xK y)
      afeJog(xK y yt)
      afeVia("M2M3_C" xK yt)
      if(nth(0 r) == "p" then tp = yt else tn = yt)))
  afeH("met3" tp xK W wM3)
  afeEdgePin("sample" tp "input")
  afeH("met3" tn xK xJ wM3)
  afeVia("M2M3_C" xJ tn)
  afeV("met2" xJ tn tp wM2)
  afeVia("M2M3_C" xJ tp))

; ------------------------------------------------------------------ vout --
; each cdac's vout pin (met1, its right-hand gap corner: the top plate) leaves
; on met1 to xVt, climbs (P) / drops (N) on met2 to the level of the
; comparator input (vp for P, vn for N), and reaches it on met3 then met2.
foreach(s list(list(list(xA:yP "MX" 1.0) "vp") list(list(xA:yB "R0" 1.0) "vn"))
  let((xf cpin b y bc yc)
    xf = car(s) cpin = cadr(s)
    b = car(afePins(cdac xf "vout"))
    y = afeCy(b)
    afeH("met1" y caar(b) xVt 0.6)
    afeVia("M1M2_C" xVt y)
    bc = car(afePins(cmp list(oxC:oyC "R90" 1.0) cpin))
    yc = afeCy(bc)
    afeV("met2" xVt y yc wM2)
    afeVia("M2M3_C" xVt yc)
    afeH("met3" yc xVt xBs + 1.1 wM3)
    afeVia("M2M3_C" xBs + 1.1 yc)
    afeH("met2" yc afeCx(bc) xBs + 1.1 wM2)))

; ------------------------------------------------------------------- vin --
; met3 from the left edge to just short of the cdac, down to met1, and onto
; the cdac's vin pin (met1, its left-hand gap corner)
foreach(s list(list("vinp" list(xA:yP "MX" 1.0)) list("vinn" list(xA:yB "R0" 1.0)))
  let((nm b y)
    nm = car(s)
    b = car(afePins(cdac cadr(s) "vin"))
    y = afeCy(b)
    afeRect("met3" 0.0 y - wM3/2 xA - 0.7 y + wM3/2)
    afeStack(1 3 xA - 1.0 y)
    afeH("met1" y xA - 1.0 caadr(b) 0.6)
    afeAnalogPin(nm y)))

; ------------------------------------------------------------ comparator --
let((xf)
  xf = list(oxC:oyC "R90" 1.0)
  ; outputs: the core's met2 strips reach the comparator's right side;
  ; extend on met2, step to the track, met3 to the right edge
  foreach(nm '("outp" "outn")
    let((b y yt)
      b = car(afePins(cmp xf nm)) y = afeCy(b) yt = afeTrk(y)
      afeH("met2" y caadr(b) - 0.1 xO wM2)
      afeV("met2" xO y yt wM2)
      afeVia("M2M3_C" xO yt)
      afeH("met3" yt xO W wM3)
      afeEdgePin(nm yt "output")))
  ; clk: the core's met5 stripe(s), extended right, stacked down to met3
  let((bs5 y yt)
    bs5 = afePins(cmp xf "clk")
    y = afeCy(car(bs5)) yt = afeTrk(y)
    foreach(b bs5 afeRect("met5" caar(b) cadar(b) oxC + 3.81 cadadr(b)))
    afeVia("M4M5_C" oxC + 3.01 y)  afeVia("M3M4_C" oxC + 3.01 y)
    afeV("met3" oxC + 3.01 y yt wM3)
    afeH("met3" yt oxC + 3.01 W wM3)
    afeEdgePin("clk" yt "input"))
  ; trims: trima on the comparator's upper side, trimb on its lower side;
  ; each pin climbs/drops on met2 to its own met3 track, then right
  foreach(s list(list("trima" 1.0) list("trimb" -1.0))
    let((nm sg)
      nm = car(s) sg = cadr(s)
      for(i 0 4
        let((b x y yt)
          b = car(afePins(cmp xf sprintf(nil "%s<%d>" nm i)))
          x = afeCx(b) y = afeCy(b)
          yt = afeTrk(y + sg * (1.0 + 1.36 * i))
          afeVia("M1M2_C" x y)
          afeV("met2" x y yt wM2)
          afeVia("M2M3_C" x yt)
          afeH("met3" yt x W wM3)
          afeEdgePin(sprintf(nil "%s<%d>" nm i) yt "input")))))
  ; vss: the core's vss strip (met1, right side) -> met3 -> vss strap
  let((b y)
    b = car(afePins(cmp xf "vss"))
    y = afeSnap(cadar(b) + 0.6)
    afeRect("met1" caar(b) y - 0.4 oxC + 1.81 y + 0.4)
    afeStack(1 3 oxC + 1.51 y)
    afeH("met3" y oxC + 1.51 W - 3.0 wM3)
    afeVia("M3M4_C" W - 3.0 y))
  ; vdd: a stack on the core's vdd bar at the spot used before 12 Oct
  ; (comparator (10.57, 14.305)), met4 over the comparator (it has no met3
  ; or met4) to the innermost right-hand strap, vdd
  let((p)
    p = dbTransformPoint(10.57:14.305 xf)
    afeStack(1 4 car(p) cadr(p))
    afeH("met4" cadr(p) car(p) W - 21.0 1.0)))

; -------------------------------------------------------------- supplies --
; met4 straps, full height, from each edge inward vss, vdda, vref, vdd
foreach(s straps
  afeStrap(car(s) cadr(s) caddr(s) "l")
  afeStrap(car(s) W - caddr(s) W - cadr(s) "r"))
; below N and above P, one met3 bus per supply (1 um wide, 2 um pitch, vref
; nearest the cdac) joins that supply's left and right straps, three vias
; into each strap
foreach(r rows
  let((y0 sg k)
    y0 = nth(2 r) sg = nth(3 r) k = 1
    foreach(nm '("vref" "vdda" "vdd" "vss")
      let((st yb)
        st = assoc(nm straps)
        yb = y0 + sg * 2.0 * k
        afeH("met3" yb cadr(st) W - cadr(st) 1.0)
        foreach(x0 list(cadr(st) W - caddr(st))
          for(j 1 3 afeVia("M3M4_C" x0 + j yb)))
        k++))))
; each cdac's vref and vdda pins (met1, its outer edge) run on met1 to their
; bus and stack up to it; its vssa pin (met2, outer corner) runs on met2 to
; the vss bus. The cdac grounds its bit drivers, switch and array on vssa.
foreach(r rows
  let((xf y0 sg)
    xf = nth(1 r) y0 = nth(2 r) sg = nth(3 r)
    foreach(s list(list("vref" 1) list("vdda" 2))
      let((b x yb)
        b = car(afePins(cdac xf car(s)))
        x = afeCx(b)  yb = y0 + sg * 2.0 * cadr(s)
        afeV("met1" x afeCy(b) yb 1.0)
        afeStack(1 3 x yb)))
    let((b x yb)
      b = car(afePins(cdac xf "vssa"))
      x = afeCx(b)  yb = y0 + sg * 8.0
      afeV("met2" x afeCy(b) yb 1.0)
      afeVia("M2M3_C" x yb))))

; the macro outline for P&R (LEF SIZE): the PR boundary
let((b)
  b = afeBox(0.0 0.0 W H)
  dbCreatePRBoundary(cv list(caar(b):cadar(b) caadr(b):cadar(b) caadr(b):cadadr(b) caar(b):cadadr(b))))
printf("AFELAY %s: %d instances, %d shapes, bbox %L, prBoundary %L\n" cellName
       length(cv~>instances) length(cv~>shapes) cv~>bBox cv~>prBoundary~>bBox)
dbSave(cv)
dbClose(cv)
dbClose(cdac) dbClose(cmp)
)
exit()
