set_individual_pin_constraints -ports {P0[3] P0[2] P0[1] P0[0]} -sides 1
set_individual_pin_constraints -ports {P1[3] P1[2] P1[1] P1[0]} -sides 3
set_individual_pin_constraints -ports {CLK TEST VDD VDDIO VDDACC} -sides 2
set_individual_pin_constraints -ports {NRST VSS VSSIO SWDIO SWDCK} -sides 4

place_pins -self