set SC /opt/pdk/sky130A/libs.ref/sky130_fd_sc_hd
set M $::env(MACRO_OUT)
create_library_set -name tt -timing [list $SC/lib/sky130_fd_sc_hd__tt_025C_1v80.lib \
  $M/sar_afe__tt_025C_1v80.lib $M/sar_afe_b__tt_025C_1v80.lib $M/sar_afe_r__tt_025C_1v80.lib]
create_timing_condition -name tc_tt -library_sets [list tt]
create_rc_corner -name rc
create_delay_corner -name dc_tt -timing_condition tc_tt -rc_corner rc
create_constraint_mode -name cm -sdc_files [list smoke.sdc]
create_analysis_view -name av -constraint_mode cm -delay_corner dc_tt
set_analysis_view -setup [list av] -hold [list av]
