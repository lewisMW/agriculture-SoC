set topMetalLayer 8;
set RDLMetal AP;
set RDLVia RV;
remove_antenna_rules

define_antenna_layer_rule \
  -mode 4 \
  -layer "$RDLMetal" \
  -ratio 2000 \
  -diode_ratio {0.000025 0 8000 30000}

define_antenna_rule \
  -mode 1 \
  -diode_mode 4 \
  -metal_ratio 0 \
  -cut_ratio 20

define_antenna_layer_rule  \
            -mode 1 \
            -layer "M$topMetalLayer" \
            -ratio 5000 \
            -diode_ratio {0.000025 0 8000 50000}

define_antenna_layer_rule  \
            -mode 1 \
            -layer "$RDLVia" \
            -ratio 200 \
            -diode_ratio {0.000025 0 83 400}

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule  \
    -mode 1 \
    -layer "VIA$i" \
    -ratio 20 \
    -diode_ratio {0.000025 0 210 900}
}

define_antenna_rule  \
  -mode 2 \
  -diode_mode 4 \
  -metal_ratio 0 \
  -cut_ratio 0

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule  \
    -mode 2 \
    -layer "M$i" \
    -ratio 5000 \
    -diode_ratio {0.000025 0 456 43000}
}

define_antenna_layer_rule  \
    -mode 2 \
    -layer "M$topMetalLayer" \
    -ratio 5000 \
    -diode_ratio {0.000025 0 8000 50000}

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule  \
    -mode 2 \
    -layer "VIA$i" \
    -ratio 900 \
    -diode_ratio {0.000025 0 210 900}
}

##### Routing Option Related to Antenna Fixing #####
set_parameter -name doAntennaConx -value 4 -module droute

redirect -tee -file ../reports/antenna_rules.rpt {report_antenna_rules}


set_ignored_layers -min_routing_layer M2  
