if { $synopsys_program_name == "icc_shell" } {
  set lib [current_mw_lib] ;
  remove_antenna_rules $lib
} else {
  set lib [current_lib]
  remove_antenna_rules -library $lib
}

set topMetalLayer 9;
set RDLMetal AP;
set RDLVia RV;

##### Single metal layer sidewall area rule #####
define_antenna_rule $lib \
  -mode 4 \
  -diode_mode 4 \
  -metal_ratio 0 \
  -cut_ratio 0

define_antenna_layer_rule $lib \
  -mode 4 \
  -layer "$RDLMetal" \
  -ratio 2000 \
  -diode_ratio {0.000025 0 8000 30000}
 
##### Single metal/via layer area rule #####
define_antenna_rule $lib \
  -mode 1 \
  -diode_mode 4 \
  -metal_ratio 0 \
  -cut_ratio 20

define_antenna_layer_rule $lib \
            -mode 1 \
            -layer "M$topMetalLayer" \
            -ratio 5000 \
            -diode_ratio {0.000025 0 8000 50000}

define_antenna_layer_rule $lib \
            -mode 1 \
            -layer "$RDLVia" \
            -ratio 200 \
            -diode_ratio {0.000025 0 83 400}

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule $lib \
    -mode 1 \
    -layer "VIA$i" \
    -ratio 20 \
    -diode_ratio {0.000025 0 210 900}
}

##### Cumulative metal/via layer area rule #####
define_antenna_rule $lib \
  -mode 2 \
  -diode_mode 4 \
  -metal_ratio 0 \
  -cut_ratio 0

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule $lib \
    -mode 2 \
    -layer "M$i" \
    -ratio 5000 \
    -diode_ratio {0.000025 0 456 43000}
}

define_antenna_layer_rule $lib \
    -mode 2 \
    -layer "M$topMetalLayer" \
    -ratio 5000 \
    -diode_ratio {0.000025 0 8000 50000}

for {set i 1} {$i < $topMetalLayer} {incr i} {
  define_antenna_layer_rule $lib \
    -mode 2 \
    -layer "VIA$i" \
    -ratio 900 \
    -diode_ratio {0.000025 0 210 900}
}

##### Routing Option Related to Antenna Fixing #####
set_parameter -name doAntennaConx -value 4 -module droute

redirect -tee -file ../reports/antenna_rules.rpt {report_antenna_rules}


set_ignored_layers -min_routing_layer M2  

create_routing_rule width_and_spacing_rules \
    -default_reference_rule \
    -widths   [list M1 0.05 M2 0.05 M3 0.15 M4 0.15 M5 0.15 M6 0.15 M7 0.15 M8 0.5 M9 2 AP 2] \
    -spacings [list M1 0.05 M2 0.05 M3 0.10 M4 0.15 M5 0.15 M6 0.15 M7 0.15 M8 0.5 M9 1 AP 2]

create_routing_rule {NDR1} -default_reference_rule  -multiplier_width 2 -multiplier_spacing 2
set_clock_routing_rules -rules NDR1 -clocks {clk swdclk} -min_routing_layer M2 -max_routing_layer M5

