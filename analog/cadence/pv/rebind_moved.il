; rebind_moved.il -- after copying Erick's cells from sky130_analog_lib into
; sar_adc (Comparator -> comparator_core, Trim -> trim; the MOM caps keep
; their names), point every reference at the sar_adc copies, then
; Check-and-Save each schematic so `si` netlists it (OSSHNL-109 otherwise).
;
;   virtuoso -nograph -replay rebind_moved.il -log rebind_moved.log
; (from a dir whose cds.lib includes analog/cadence/cds.lib)
let((map cells nfix)
  map = list(
    list("Comparator"        "comparator_core")
    list("Trim"              "trim")
    list("sarct__trim_array" "sarct__trim_array")
    list("sarcta__C0"        "sarcta__C0"))
  cells = '("sarcta__C0" "sarct__trim_array" "trim" "comparator_core")
  foreach(cell cells
    foreach(view '("symbol" "layout" "schematic")
      let((cv)
        cv = dbOpenCellViewByType("sar_adc" cell view nil "a")
        if(!cv then printf("NOVIEW sar_adc/%s/%s\n" cell view)
        else
          nfix = 0
          foreach(ih cv~>instHeaders
            let((hit)
              hit = assoc(ih~>cellName map)
              when(ih~>libName == "sky130_analog_lib" && hit
                printf("REBIND %s/%s: %s/%s/%s -> sar_adc/%s/%s\n" cell view
                  ih~>libName ih~>cellName ih~>viewName cadr(hit) ih~>viewName)
                dbSetInstHeaderMasterName(ih "sar_adc" cadr(hit) ih~>viewName)
                nfix++)))
          foreach(ih cv~>instHeaders
            printf("HDR %s/%s: %s/%s/%s master=%L\n" cell view
              ih~>libName ih~>cellName ih~>viewName (ih~>master != nil)))
          when(view == "schematic"
            printf("SCHCHECK %s: %L\n" cell schCheck(cv)))
          printf("SAVE %s/%s fixed=%d -> %L\n" cell view nfix dbSave(cv))
          dbClose(cv))))))
exit()
