
.namespace []
.sub "_block11"  :anon :subid("10_1307045668.86952")
.annotate 'line', 0
    .const 'Sub' $P14 = "11_1307045668.86952" 
    capture_lex $P14
.annotate 'line', 1
    $P0 = find_dynamic_lex "$*CTXSAVE"
    if null $P0 goto ctxsave_done
    $I0 = can $P0, "ctxsave"
    unless $I0 goto ctxsave_done
    $P0."ctxsave"()
  ctxsave_done:
.annotate 'line', 3
    .const 'Sub' $P14 = "11_1307045668.86952" 
    capture_lex $P14
    $P19 = $P14()
.annotate 'line', 1
    .return ($P19)
    .const 'Sub' $P21 = "13_1307045668.86952" 
    .return ($P21)
.end


.namespace []
.sub "" :load :init :subid("post14") :outer("10_1307045668.86952")
.annotate 'line', 0
    .const 'Sub' $P12 = "10_1307045668.86952" 
    .local pmc block
    set block, $P12
    $P24 = get_root_global ["parrot"], "P6metaclass"
    $P24."new_class"("POST::Ops", "POST::Node" :named("parent"))
.end


.namespace ["POST";"Ops"]
.sub "_block13"  :subid("11_1307045668.86952") :outer("10_1307045668.86952")
.annotate 'line', 3
    $P0 = find_dynamic_lex "$*CTXSAVE"
    if null $P0 goto ctxsave_done
    $I0 = can $P0, "ctxsave"
    unless $I0 goto ctxsave_done
    $P0."ctxsave"()
  ctxsave_done:
    .return ()
    .const 'Sub' $P16 = "12_1307045668.86952" 
    .return ($P16)
.end


.namespace ["POST";"Ops"]
.sub "_block15" :load :anon :subid("12_1307045668.86952")
.annotate 'line', 3
    .const 'Sub' $P17 = "11_1307045668.86952" 
    $P18 = $P17()
    .return ($P18)
.end


.namespace []
.sub "_block20" :load :anon :subid("13_1307045668.86952")
.annotate 'line', 1
    .const 'Sub' $P22 = "10_1307045668.86952" 
    $P23 = $P22()
    .return ($P23)
.end

