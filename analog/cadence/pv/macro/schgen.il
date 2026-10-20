; schgen.il -- build a schematic from a connection list (SKILL, batch).
;
;   m1SchBuild(lib cell insts pins)
;     insts: list of (name lib cell x y conns)  conns: (("term" "net") ...)
;            every symbol terminal must appear in conns
;     pins:  list of (name direction x y)       direction: "input" "output"
;                                               or "inputOutput"
; Each instance terminal gets a short wire stub carrying a net label, and
; each pin a stub with the same label, so connectivity is by name only.
; The schematic is checked (schCheck must report 0 errors) and saved, and a
; symbol is generated when the cell has none.

procedure(m1Stub(cv xy dir net)
  let((len p2 wires)
    len = 0.25
    p2 = case(dir
      ("left"  list(car(xy)-len cadr(xy)))
      ("right" list(car(xy)+len cadr(xy)))
      ("up"    list(car(xy) cadr(xy)+len))
      (t       list(car(xy) cadr(xy)-len)))
    wires = schCreateWire(cv "draw" "full" list(xy p2) 0.0625 0.0625 0.0)
    schCreateWireLabel(cv car(wires) p2 net "lowerLeft" "R0" "stick" 0.0625 nil)))

procedure(m1PinDir(inst xy)
  ; which side of the instance box the pin sits on -> stub direction
  let((b cx cy dx dy)
    b = inst~>bBox
    cx = (caar(b) + caadr(b)) / 2.0  cy = (cadar(b) + cadadr(b)) / 2.0
    dx = car(xy) - cx  dy = cadr(xy) - cy
    if(abs(dx) * (cadadr(b) - cadar(b)) >= abs(dy) * (caadr(b) - caar(b))
      then if(dx < 0 "left" "right")
      else if(dy < 0 "down" "up"))))

procedure(m1SchBuild(lib cell insts pins)
  let((cv res)
    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "w")
    unless(cv error("cannot open %s/%s/schematic for write" lib cell))
    foreach(spec insts
      let((name ilib icell x y conns master inst)
        name = nth(0 spec) ilib = nth(1 spec) icell = nth(2 spec)
        x = nth(3 spec) y = nth(4 spec) conns = nth(5 spec)
        master = dbOpenCellViewByType(ilib icell "symbol" nil "r")
        unless(master error("no symbol %s/%s" ilib icell))
        inst = dbCreateInst(cv master name x:y "R0")
        foreach(term master~>terminals
          let((net fig xy)
            net = cadr(assoc(term~>name conns))
            unless(net error("%s: terminal %s of %s/%s has no net" name term~>name ilib icell))
            fig = car(term~>pins)~>fig
            xy = dbTransformPoint(centerBox(fig~>bBox) inst~>transform)
            m1Stub(cv xy m1PinDir(inst xy) net)))
        ; conns naming a terminal the symbol lacks is a spec error too
        foreach(c conns
          unless(member(car(c) master~>terminals~>name)
            error("%s: %s/%s has no terminal %s" name ilib icell car(c))))))
    foreach(p pins
      let((name dir x y pm)
        name = nth(0 p) dir = nth(1 p) x = nth(2 p) y = nth(3 p)
        pm = dbOpenCellViewByType("basic" case(dir ("input" "ipin") ("output" "opin") (t "iopin")) "symbol" nil "r")
        schCreatePin(cv pm name dir nil x:y "R0")
        m1Stub(cv list(x y) if(dir == "output" "left" "right") name)))
    res = schCheck(cv)
    printf("SCHGEN %s/%s schCheck=%L\n" lib cell res)
    when(car(res) > 0
      foreach(m cv~>markers printf("SCHGEN marker: %s\n" m~>msg)))
    dbSave(cv)
    dbClose(cv)
    unless(ddGetObj(lib cell "symbol")
      schViewToView(lib cell lib cell "schematic" "symbol" "schSchemToPinList" "schPinListToSymbolGen")
      printf("SCHGEN %s/%s symbol generated\n" lib cell))
    car(res) == 0))

; m1SymAddPin(lib cell name from dx): give an existing symbol the terminal
; `name` as a copy of terminal `from`'s pin, stub and label, placed dx past
; the last pin in from's row (symbols generated at different times order
; their supply pins differently). schViewToView cannot overwrite an existing
; symbol in batch mode (it opens a modal dialog and the replay ends), so a
; pin added to a cell's schematic later reaches its symbol this way. Does
; nothing if the symbol has the terminal already; stops if the new pin would
; land on another pin.
procedure(m1SymAt(p c) abs(car(p) - car(c)) < 1e-4 && abs(cadr(p) - cadr(c)) < 1e-4)
procedure(m1SymAddPin(lib cell name from dx)
  let((cv f c b net nf lbl xmax sh)
    cv = dbOpenCellViewByType(lib cell "symbol" nil "a")
    unless(cv error("no symbol %s/%s" lib cell))
    if(dbFindTermByName(cv name) then
      printf("SCHGEN %s/%s symbol has %s already\n" lib cell name)
    else
      unless(dbFindTermByName(cv from) error("%s/%s symbol has no %s to copy" lib cell from))
      f = car(dbFindTermByName(cv from)~>pins)~>fig
      c = centerBox(f~>bBox)
      xmax = car(c)
      foreach(tm cv~>terminals foreach(p tm~>pins
        when(p~>fig && abs(cadr(centerBox(p~>fig~>bBox)) - cadr(c)) < 1e-4
          xmax = max(xmax car(centerBox(p~>fig~>bBox))))))
      sh = xmax + dx - car(c)
      b = list(caar(f~>bBox) + sh:cadar(f~>bBox) caadr(f~>bBox) + sh:cadadr(f~>bBox))
      foreach(tm cv~>terminals foreach(p tm~>pins
        when(p~>fig && dbGetTrueOverlaps(cv b list(p~>fig~>layerName p~>fig~>purpose)) &&
             caar(p~>fig~>bBox) < caadr(b) && caadr(p~>fig~>bBox) > caar(b) &&
             cadar(p~>fig~>bBox) < cadadr(b) && cadadr(p~>fig~>bBox) > cadar(b)
          error("%s/%s symbol: new pin %s would overlap pin %s" lib cell name tm~>name))))
      net = dbMakeNet(cv name)
      nf = dbCreateRect(cv list(f~>layerName f~>purpose) b)
      dbCreateTerm(net name "inputOutput")
      dbCreatePin(net nf name)
      foreach(s setof(x cv~>shapes x~>objType == "line" && exists(p x~>points m1SymAt(p c)))
        dbCreateLine(cv list(s~>layerName s~>purpose)
                     mapcar(lambda((p) list(car(p) + sh cadr(p))) s~>points)))
      lbl = car(setof(x cv~>shapes x~>objType == "label" && x~>theLabel == from))
      when(lbl
        dbCreateLabel(cv list(lbl~>layerName lbl~>purpose) list(car(lbl~>xy) + sh cadr(lbl~>xy))
                      name lbl~>justify lbl~>orient lbl~>font lbl~>height))
      dbSave(cv)
      printf("SCHGEN %s/%s symbol: added %s\n" lib cell name))
    printf("SCHGEN %s/symbol terminals %L\n" cell sort(cv~>terminals~>name 'alphalessp))
    dbClose(cv)))
