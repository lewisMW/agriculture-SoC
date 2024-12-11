#//-----------------------------------------------------------------------------
#// PnR Flow script for Synopsys ICC2
#// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#//
#// Contributorss
#//
#// Daniel Newbrook (d.newbrook@soton.ac.uk)
#//
#// Copyright � 2021-3, SoC Labs (www.soclabs.org)
#//-----------------------------------------------------------------------------


set design_name nanosoc_chip_pads

# Edit these for your environment
set PHYS_IP_DIR /research/AAA/phys_ip_library
set MEM_DIR /home/dwn1c21/SoC-Labs/accelerator-project/memories
set IO_BACKEND_DIR /home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Backend/lef
set IO_FRONTEND_DIR /home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a

set_app_var link_library  [list $PHYS_IP_DIR/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/db/sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.db $MEM_DIR/bootrom/rom_via_ss_1p08v_1p08v_125c.db $MEM_DIR/rf/rf_sp_hdf_ss_1p08v_1p08v_125c.db $IO_FRONTEND_DIR/tpdn65lpnv2od3wc.db]
create_lib tsmc65lp -technology $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/milkyway/1p9m_6x2z/sc12_tech.tf -ref_libs [list $PHYS_IP_DIR/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/lef/sc12_cln65lp_base_rvt.lef $MEM_DIR/rf/rf_sp_hdf.lef $MEM_DIR/bootrom/rom_via.lef $IO_BACKEND_DIR/tpbn65v_9lm.lef $IO_BACKEND_DIR/tpdn65lpnv2od3_9lm.lef]

read_parasitic_tech -name typical -tlup $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/typical.tluplus -layermap $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/tluplus.map
read_parasitic_tech -name rcbest -tlup $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/rcbest.tluplus -layermap $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/tluplus.map
read_parasitic_tech -name rcworst -tlup $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/rcworst.tluplus -layermap $PHYS_IP_DIR/arm/tsmc/cln65lp/arm_tech/r2p0/synopsys_tluplus/1p9m_6x2z/tluplus.map


read_verilog -library tsmc65lp -design nanosoc_chip_pads -top nanosoc_chip_pads $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads.vp
read_def $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/Synopsys/nanosoc_chip_pads.def
link_block

create_cell {PAD_CORNER_NE PAD_CORNER_SE PAD_CORNER_SW PAD_CORNER_NW} PCORNER

initialize_floorplan -side_length {1500 1500} -core_offset {150}
create_io_ring -name main_io
explore_logic_hierarchy -organize

# Place IO pins
source place_pins.tcl

# Power domains TOP ACCEL and MEM
create_power_domain TOP 
create_power_domain ACCEL  -elements {u_nanosoc_chip/u_system/u_ss_expansion/u_region_exp/u_ss_accelerator}
#VDD
create_supply_port VDD
create_supply_net VDD -domain TOP
connect_supply_net VDD -ports VDD

#VSS
create_supply_port VSS 
create_supply_net VSS -domain TOP
create_supply_net VSS -domain ACCEL -reuse
connect_supply_net VSS -ports VSS

#VDDACC
create_supply_port VDDACC 
create_supply_net VDDACC -domain ACCEL
connect_supply_net VDDACC -ports VDDACC


#IO Supplies
create_supply_port VDDIO -domain TOP
connect_supply_net VDDIO -ports VDDIO

set_domain_supply_net TOP -primary_power_net VDD -primary_ground_net VSS
set_domain_supply_net ACCEL -primary_power_net VDDACC -primary_ground_net VSS
# Create voltage and power region for accelerator
create_voltage_area -power_domains ACCEL -power VDDACC -ground VSS -nwell VDDACC -pwell VSS -region {{{150 1050} {1100 1650}}} -name VA_ACCEL -cells [get_cells -physical_context -hierarchical \
-regexp u_nanosoc_chip/u_system/u_ss_expansion/u_region_exp/u_ss_accelerator/.*]
create_pg_region {pg_ACCEL} -voltage_area VA_ACCEL -expand {0 10}

create_pg_region {pg_TOP} -voltage_area DEFAULT_VA 


set_parasitic_parameters -early_spec rcbest -early_temperature -40 -late_spec rcworst -late_temperature 125
current_corner default
set_operating_conditions -max_library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c -max ss_typical_max_1p08v_125c -min_library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c -min ss_typical_max_1p08v_125c
current_corner default
set_parasitic_parameters -early_spec rcbest -early_temperature -40 -late_spec rcworst -late_temperature 125
current_corner default
set_operating_conditions -max_library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c -max ss_typical_max_1p08v_125c -min_library sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c -min ss_typical_max_1p08v_125c
current_mode default
set_voltage 1.08 -corner [current_corner] -object_list [get_supply_nets VDD]
set_voltage 1.08 -corner [current_corner] -object_list [get_supply_nets VDDACC]
set_voltage 3.00 -corner [current_corner] -object_list [get_supply_nets VDDIO]
set_voltage 0.00 -corner [current_corner] -object_list [get_supply_nets VSS]

add_port_state VSS -state {on 0.0}
add_port_state VDD -state {on 1.08}
add_port_state VDDACC -state {on 1.08}
add_port_state VDDIO -state {on 3.0}
create_pst ao_pst -supplies {VSS VDD VDDACC VDDIO}
add_pst_state ao -pst ao_pst -state {on on on on}

commit_upf

set_app_options -list {opt.timing.effort {medium}}
set_app_options -list {clock_opt.place.effort {high}}
set_app_options -list {place_opt.flow.clock_aware_placement {true}}
set_app_options -list {place_opt.final_place.effort {high}}

read_sdc $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/ASIC/constraints.sdc
update_timing



change_selection [explore_logic_hierarchy -create_module_boundary]
explore_logic_hierarchy -place

#Place and fix memories with boundary
source place_memories.tcl

change_selection [explore_logic_hierarchy -create_module_boundary]
explore_logic_hierarchy -place

#Create power ring and straps
source power_plan.tcl

#Start Placement
create_placement 
legalize_placement -cells [get_cells *]

save_lib -all

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/1pre_opt_placement_timing.rep
check_mv_design > check_mv_design.log

report_utilization -of_objects [get_voltage_areas {DEFAULT_VA}] > check_util_default_va.log
report_utilization -of_objects [get_voltage_areas {VA_ACCEL}] > check_util_va_accel.log


place_opt
save_lib -all

update_timing -full
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/2post_opt_placement_timing.rep

check_clock_trees -clocks clk
synthesize_clock_trees -clocks clk
clock_opt
update_timing -full
report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/3post_clock_opt_placement_timing.rep
save_lib -all

#Start Routing
route_auto
update_timing -full

report_timing > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/final_timing.rep
report_power > $::env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/reports/final_power.rep
save_lib -all
exit
