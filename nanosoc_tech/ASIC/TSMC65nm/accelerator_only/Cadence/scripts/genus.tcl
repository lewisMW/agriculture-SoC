set_db init_lib_search_path $::env(PHYS_IP)/arm/tsmc/cln65lp/sc9_base_rvt/r0p0/lib/
set BASE_LIB sc9_cln65lp_base_rvt_ss_typical_max_1p08v_125c.lib
create_library_domain domain1
set_db [get_db library_domains domain1] .library "$BASE_LIB"

source $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/genus_flist.tcl
elaborate accelerator_subsystem

read_sdc $::env(SOCLABS_NANOSOC_TECH_DIR)/ASIC/accelerator_only/accel_constraints.sdc 

set_db delete_unloaded_insts false
set_db optimize_constant_1_flops false
set_db optimize_constant_0_flops false
set_db syn_generic_effort high
set_db syn_map_effort high

syn_generic
syn_map
syn_opt

report_area > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/accel/reports/syn_accel_area_784.rep
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/accel/reports/syn_accel_timing_784.rep
report_gates > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/accel/reports/syn_accel_gates_784.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/accel/reports/syn_accel_power_784.rep

write_hdl > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/accel/netlist/accel.v

