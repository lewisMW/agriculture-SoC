;; tbcmp_lib.il: per-cycle measurements for tb_comparator_parasitic Maestro outputs.
;; Timing matches tbcmp_stim.va: cycle k rises at (k+0.5)/fclk, falls at (k+0.5+duty)/fclk.
;; Decisions are read at the SAR sampling instant, tsu before the falling clock edge.
;; pol=+1 means "inp>inn gives outp high"; every function here reports through pol.

procedure( tbcmpTs(k fclk duty tsu)
  (float(k) + 0.5 + duty) / fclk - tsu )

;; +1 outp high, -1 outn high, 0 unresolved (outputs not at valid logic levels)
procedure( tbcmpDec(op on ts vcc pol)
  let( (vp vn)
    vp = value(op ts)
    vn = value(on ts)
    cond(
      ( vp > 0.7*vcc && vn < 0.3*vcc  pol )
      ( vn > 0.7*vcc && vp < 0.3*vcc  -pol )
      ( t 0 ))))

;; Transition statistics of an ascending stimulus: list(vth sigma) or nil if no transition.
;; lv = stimulus values, lp = P(decision=+1) at each value.
procedure( tbcmpTrans(lv lp)
  let( (sw sm ss v0 v1 p0 p1 dp vm dv vth var)
    sw = 0.0  sm = 0.0  ss = 0.0
    dv = abs(cadr(lv) - car(lv))
    for( pass 0 1
      let( ((vs lv) (ps lp))
        while( cdr(vs)
          v0 = car(vs)  v1 = cadr(vs)  p0 = car(ps)  p1 = cadr(ps)
          dp = p1 - p0
          vm = 0.5 * (v0 + v1)
          if( pass == 0 then
            sw = sw + dp
            sm = sm + dp * vm
          else
            ss = ss + dp * (vm - vth) * (vm - vth)
          )
          vs = cdr(vs)  ps = cdr(ps)
        )
        when( pass == 0 && abs(sw) > 1e-9  vth = sm / sw )
      )
    )
    when( abs(sw) > 1e-9
      var = ss / sw - dv * dv / 12.0
      list( vth  sqrt(max(var 0.0)) )
    )
  )
)

;; Build (lv lp) from cycles picked by procedure pick(j r) => k, for j<nsteps, r<nrep.
procedure( tbcmpCurve(op on fclk duty tsu vstart vstep nsteps nrep vcc pol pick)
  let( (lv lp n h k d)
    for( j 0 nsteps-1
      n = 0  h = 0
      for( r 0 nrep-1
        k = funcall(pick j r)
        d = tbcmpDec(op on tbcmpTs(k fclk duty tsu) vcc pol)
        n++
        when( d > 0  h++ )
      )
      lv = cons( vstart + vstep*j  lv )
      lp = cons( float(h)/n  lp )
    )
    list( reverse(lv)  reverse(lp) )
  )
)

procedure( tbcmpStair(op on fclk duty tsu vstart vstep nsteps nrep vcc pol)
  let( (c)
    c = tbcmpCurve(op on fclk duty tsu vstart vstep fix(nsteps) fix(nrep) vcc pol
                   lambda((j r) j*fix(nrep)+r))
    tbcmpTrans(car(c) cadr(c))
  )
)

;; Input-referred offset (V): differential input where the decision flips.
procedure( tbcmp_vos(op on fclk duty tsu vstart vstep nsteps nrep vcc pol)
  car(tbcmpStair(op on fclk duty tsu vstart vstep nsteps nrep vcc pol)) )

;; Input-referred noise sigma (V) from the width of the S-curve (needs transient noise, nrep>1).
procedure( tbcmp_sigma(op on fclk duty tsu vstart vstep nsteps nrep vcc pol)
  cadr(tbcmpStair(op on fclk duty tsu vstart vstep nsteps nrep vcc pol)) )

;; History dependence (mode 3): threshold after a + or - decision.
;; sel = 1 after +vagg, -1 after -vagg, 0 returns (after+) - (after-).
procedure( tbcmp_hist(op on fclk duty tsu vstart vstep nsteps vcc pol sel)
  let( (vp vm cp cm)
    cp = tbcmpCurve(op on fclk duty tsu vstart vstep fix(nsteps) 1 vcc pol lambda((j r) 4*j+1))
    cm = tbcmpCurve(op on fclk duty tsu vstart vstep fix(nsteps) 1 vcc pol lambda((j r) 4*j+3))
    vp = car(tbcmpTrans(car(cp) cadr(cp)))
    vm = car(tbcmpTrans(car(cm) cadr(cm)))
    cond(
      ( sel > 0  vp )
      ( sel < 0  vm )
      ( vp && vm  vp - vm )
    )
  )
)

;; Stimulus differential on cycle k, mirrors tbcmp_stim.va for modes 0, 1, 2.
procedure( tbcmpVin(k mode vd vstart vstep nrep)
  case( fix(mode)
    (1 vstart + vstep*(k/fix(nrep)))
    (2 if( evenp(k) then vd else -vd ))
    (t vd)
  )
)

;; Decision audit over ncyc cycles, skipping the first.
;; what: "wrong" | "unresolved" | "correct" (counts); vos = expected threshold.
procedure( tbcmp_count(op on fclk duty tsu mode vd vstart vstep nrep ncyc vos vcc pol what)
  let( (nw nu nc v d)
    nw = 0  nu = 0  nc = 0
    for( k 1 fix(ncyc)-1
      v = tbcmpVin(k mode vd vstart vstep nrep) - vos
      d = tbcmpDec(op on tbcmpTs(k fclk duty tsu) vcc pol)
      cond(
        ( d == 0            nu++ )
        ( d * v > 0.0       nc++ )
        ( t                 nw++ )
      )
    )
    cond(
      ( what == "wrong"       nw )
      ( what == "unresolved"  nu )
      ( t                     nc )
    )
  )
)
