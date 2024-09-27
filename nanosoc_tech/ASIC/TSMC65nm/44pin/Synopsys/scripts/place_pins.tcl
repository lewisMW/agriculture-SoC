set_individual_pin_constraints -ports {P0[15] P0[14] P0[13] P0[12] P0[11] P0[10] P0[9] P0[8] P0[7] P0[6] P0[5] P0[4] P0[3] P0[2] P0[1] P0[0]} -sides 1
set_individual_pin_constraints -ports {P1[15] P1[14] P1[13] P1[12] P1[11] P1[10] P1[9] P1[8] P1[7] P1[6] P1[5] P1[4] P1[3] P1[2] P1[1] P1[0]} -sides 3
set_individual_pin_constraints -ports {CLK TEST VDD VDDIO VDDACC} -sides 2
set_individual_pin_constraints -ports {NRST VSS VSSIO SWDIO SWDCK} -sides 4

place_pins -self