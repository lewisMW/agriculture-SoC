##############################################################################################################
#####  
#####                                       Pegasus LVS COMPARISON
#####  
#####  Version                       :   24.11-s021
#####  NVN Run Start                 :   Fri Jul 31 20:32:07 2026
#####  Comparison Report File        :   inverter.rep.cls
#####  Top Cell                      :   inverter  <vs>  inverter
#####  
#####  Run Result                    :   MATCH
#####  
#####  Layout Design                 :   sky130_analog_lib inverter layout
#####  Schematic File                :   /home/hee/projects/agriculture-SoC/analog/cadence/pegasus_runs/Inverter/inverter.cdl (cdl)
#####  Rules File                    :   /home/hee/cadence/lib/sky130_release_0.1.0/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl
#####  Pin Swap File                 :   inverter.rep.cps
#####  
#####  NVN CPU Time                  :   0h 0m 0s - (0s)                 
#####  NVN Exec Time                 :   0h 0m 1s - (1s)                 
#####  NVN Peak Memory Usage         :   270.61MB
#####  
##############################################################################################################


##############################################################################################################
#
#                                            CELL MATCH STATISTICS                                            
#
##############################################################################################################

Cell Statistic Descriptions                  | Count
---------------------------------------------+----------
Cells matched                                |         1
Cells expanded                               |         0
Cells not run                                |         0
Cells which mismatch                         |         0
---------------------------------------------+----------
Total                                        |         1


Cell Statistic Detail                        | Count
---------------------------------------------+----------
Cells with parameter mismatches              |         0
Cells with mismatched instance subtypes      |         0
Cells that have been blackboxed              |         0


##############################################################################################################
#
#                                             CELL MATCH SUMMARY                                              
#
##############################################################################################################

             |     Initial Pins     |     Compare Pins     |            | 
Cell         |   lay    :    sch    |   lay    :    sch    | Status     | Detail
-------------+----------+-----------+----------+-----------+------------+-----------
inverter     |        4 :         4 |        4 :         4 | match      | 


##############################################################################################################
#
#                                                  LVS RULES                                                  
#
##############################################################################################################

Command Line LVS Rule Values
----------------------------

    layout_primary                          inverter {-top_cell inverter}
    schematic_primary                       inverter {-source_top_cell inverter}

LVS Rules Given in the Rules File
---------------------------------

    lvs_abort                               -softchk                               no  
    lvs_abort                               -supply_error                          no  
    layout_path                             /home/hee/projects/agriculture-SoC/analog/cadence/pegasus_runs/Inverter/LVS/inverter.gds.gz
    layout_format                           gdsii
    layout_primary                          TOPCELL
    schematic_path                          /home/hee/projects/agriculture-SoC/analog/cadence/pegasus_runs/Inverter/inverter.cdl
                                            cdl
    lvs_delete_cell_pin                     cap_vpp_02p4x04p6_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x06p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x11p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x21p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x41p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p9x06p1_m1m2m3m4_shieldl1_fingercap2 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_shieldpo_floatm3 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_noshield_o2 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_05p9x05p9_m1m2m3m4_shieldl1_wafflecap b -source
    lvs_delete_cell_pin                     cap_vpp_06p8x06p1_l1m1m2m3_shieldpom4 b -source
    lvs_delete_cell_pin                     cap_vpp_06p8x06p1_m1m2m3_shieldl1m4 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_l1m1m2_shieldpo_floatm3 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p3x11p3_m1m2m3m4_shieldl1_wafflecap b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3m4_shieldm5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3m4_shieldpom5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3_shieldm4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3_shieldpom4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2_shieldpom3 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3m4_shieldl1m5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3m4_shieldm5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m4_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_noshield top -source
    lvs_black_box                           cap_vpp_02p4x04p6_m1m2_noshield -black
    lvs_black_box                           cap_vpp_02p7x06p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x11p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x21p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x41p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p9x06p1_m1m2m3m4_shieldl1_fingercap2 -black
    lvs_black_box                           cap_vpp_04p4x04p6_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_04p4x04p6_l1m1m2_shieldpo_floatm3 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_noshield -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_noshield_o2 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_05p9x05p9_m1m2m3m4_shieldl1_wafflecap -black
    lvs_black_box                           cap_vpp_06p8x06p1_l1m1m2m3_shieldpom4 -black
    lvs_black_box                           cap_vpp_06p8x06p1_m1m2m3_shieldl1m4 -black
    lvs_black_box                           cap_vpp_08p6x07p8_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_08p6x07p8_l1m1m2_shieldpo_floatm3 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2_noshield -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_11p3x11p3_m1m2m3m4_shieldl1_wafflecap -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3m4_shieldm5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3m4_shieldpom5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3_shieldm4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3_shieldpom4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2_shieldpom3 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3m4_shieldl1m5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3m4_shieldm5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2_noshield -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m4_noshield -black
                                             
    lvs_cdn_flow_options                    -cdl_use_scale
    lvs_ignore_ports                        no  
    lvs_find_shorts                         no  
    lvs_break_ambig_max                     32
    lvs_reduce_split_gates                  no  
    lvs_recognize_gates                     -none
    lvs_reduce                              no  -series_mos
    lvs_reduce                              yes -parallel_mos
    lvs_reduce_device                       MN ( nfet_20v0 ) -parallel ...
    lvs_reduce_device                       MN ( nfet_20v0_zvt ) -parallel ...
    lvs_reduce_device                       MP ( pfet_20v0 ) -parallel ...
    lvs_reduce_device                       Q -parallel yes ...
    lvs_expand_cell_on_error                no  
    lvs_check_property                      D ( diode_pd2nw_05v5 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_hvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_hvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_lvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_lvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_11v0 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_11v0 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_lvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_lvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_nvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_nvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_11v0 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_11v0 ) p p -tolerance 1
    lvs_check_property                      MN ( nfet_20v0 ) w w
    lvs_check_property                      MN ( nfet_20v0 ) l l
    lvs_check_property                      MN ( nfet_20v0_zvt ) w w
    lvs_check_property                      MN ( nfet_20v0_zvt ) l l
    lvs_check_property                      MP ( pfet_20v0 ) w w
    lvs_check_property                      MP ( pfet_20v0 ) l l
    lvs_check_property                      Q EA EA -tolerance 0
    lvs_check_property                      Q M M -tolerance 0
    lvs_check_property                      MP L l
    lvs_check_property                      MP W w
    lvs_check_property                      MN L l
    lvs_check_property                      MN W w
    lvs_check_property                      R W W
    lvs_check_property                      R L L
    lvs_check_property                      C L L
    lvs_check_property                      C W W
    lvs_report_file                         inverter.rep
    lvs_report_max                          50 -mismatched_net_limit 100 
    lvs_short_equivalent_nodes              yes
    virtual_connect                         no  -colon
    virtual_connect                         yes -semicolon_as_colon
    virtual_connect                         no  -report
    virtual_connect                         -depth primary
    text_depth                              -primary

Default LVS Rule Values
-----------------------

    lvs_abort                               -check_device_for_property_rule no
    lvs_abort                               -missing_hcell no
    lvs_abort                               -erc_error yes
    lvs_abort                               -inconsistent_reduction yes
    layout_case_sensitive                   no
    // layout_cpf_file                       
    // schematic_cpf_file                    
    schematic_case_sensitive                no
    schematic_format                        cdl
    // hcell_file                            
    // hcell                                 
    // lvs_exclude_hcell                     
    // lvs_gen_hcells                        
    // lvs_delete_cell                       
    lvs_push_devices                        yes
    lvs_push_devices_properties             no
    lvs_netlist                             yes -substrate_comment
    lvs_netlist                             yes -box_contents
    lvs_netlist                             yes -unnamed_box_pins
    lvs_netlist                             no -allow_inconsistent_model
    lvs_netlist                             yes -properties_comment
    // lvs_write_netlist                     
    // lvs_write_netlist_reduced             
    // lvs_interposer                        
    lvs_spice                               yes -allow_floating_pins
    lvs_spice                               yes -allow_duplicate_subcircuit_names
    lvs_spice                               no  -conditional_ldd
    lvs_spice                               no  -prefer_pins
    lvs_spice                               no  -override_globals
    lvs_spice                               no  -redefine_param
    lvs_spice                               no  -replicate_devices
    lvs_spice                               no  -replicate_devices_enhanced
    lvs_spice                               yes -slash_is_space
    lvs_spice                               yes -keep_back_slash
    lvs_spice                               no  -allow_unquoted_strings
    lvs_spice                               no  -allow_inline_parameters
    lvs_spice                               no  -calculate_mos_area
    lvs_spice                               no  -strict_wl
    lvs_spice                               no  -cull_primitive_subcircuits
    lvs_spice                               no  -ignore_option_scale
    lvs_spice                               no  -show_neg_param_warning
    lvs_spice                               no  -scale_x_parameters
    lvs_spice                               yes -strict_subckts_order
    lvs_spice                               no  -ignore_higher_include_for_inst_master
    lvs_spice                               no  -ignore_black_box_connect
    // lvs_spice_option                      
    lvs_reverse_wl                          no
    // lvs_spice_multiplier_name             
                                             
    lvs_compare_case                        no
    lvs_cname                               no  -cell
    lvs_cname                               yes -pin
    lvs_cname                               yes -net
    lvs_cname                               no  -instance
    lvs_non_user_name                       -port "^[0-9]+$"
    lvs_non_user_name                       -net  "^[0-9]+$"
    // lvs_non_user_name                    -instance 
    lvs_out_of_range_exclude_zero           no
    // lvs_group_models                      
    lvs_strict_subtypes                     no
    lvs_exact_subtypes                      no
    lvs_preserve_box_ports                  no
    // lvs_cpoint                            
    // lvs_power_name                        
    // lvs_ground_name                       
    // lvs_cell_list                         
    // lvs_device_type                       
    lvs_auto_pin_swap                       yes -swap_threshold 4000000
    lvs_swap_non_cpoint_pins                yes
    // lvs_swap_pins                         
    lvs_all_cap_pins_swappable              no
    lvs_builtin_device_pin_swap             yes
    // lvs_join_nets                         
    lvs_compare_port_names                  no
    lvs_global_sigs_are_ports               yes
    lvs_discard_pins                        no
    lvs_filter                              no  -bipolar
    lvs_filter                              no  -capacitors
    lvs_filter                              no  -diodes
    lvs_filter                              no  -mos
    lvs_filter                              no  -resistors
    // lvs_filter_option                     
    // lvs_filter_device                     
    // lvs_filter_device_keep_net            
    lvs_reduction_priority                  -parallel
    lvs_derive_logic                        yes -sram
    lvs_derive_logic                        no  -dram
    lvs_derive_logic                        no  -rom
    // lvs_recognize_gates_tolerance         
    lvs_reduce                              yes -parallel_bipolar
    lvs_reduce                              yes -parallel_caps
    lvs_reduce                              yes -series_caps
    lvs_reduce                              yes -parallel_diodes
    lvs_reduce                              no  -series_diodes
    lvs_reduce                              yes -parallel_resistors
    lvs_reduce                              yes -series_resistors
    // lvs_reduce_do_not_merge               
    lvs_expand_on_device_climbing           no
    lvs_expand_unbalanced_cells             yes
    // lvs_check_all_properties_by_name      
    // lvs_property_map                      
    // lvs_transfer_property                 
    lvs_warn_max                            50
    lvs_inconsistent_reduction_threshold    1000000
    // lvs_report_opt                        
    lvs_report_units                        yes
    lvs_keep_data                           no
    lvs_keep_source_cells                   no
    lvs_create_match_db                     no
    // lvs_map_device                        
    unit                                    -length u
    unit                                    -resistance ohm
    unit                                    -capacitance pf
    lvs_verilog_bus_map_by_position         no
    lvs_verilog_keep_backslash              no
    lvs_verilog_detect_buses                no
    lvs_do_not_normalize                    no
    // lvs_generic_device                    
    input_scale                             1000
    virtual_connect                         no  -colon
    virtual_connect                         yes -semicolon_as_colon
    // virtual_connect                      -name 
    virtual_connect                         no -report
    virtual_connect                         no -incremental
    lvs_preserve_parameterized_cells        no
    lvs_check_color                         no
    // lvs_schematic_color_path              
    // lvs_assign_conflict_layer             
    // lvs_conflict_layer_check             
    lvs_check_color_label                   no
    // lvs_preserve_cells                    
    port                                    -depth -primary
    lvs_high_shorts_max                     10000000

Effective LVS Rule Values
-------------------------

    lvs_swap_non_cpoint_pins                yes -unbound_pin_threshold 10000
    layout_primary                          inverter
    lvs_recognize_gates                     -none
    virtual_connect                         no  -report


##############################################################################################################
#
#                                               CELL COMPARISON                                               
#
##############################################################################################################

                              +------------------------------------------------+
                              |                                                |
                              |        ------->>>   MATCH   <<<-------         |
                              |                                                |
                              |            inverter  <vs>  inverter            |
                              |                                                |
                              |                                                |
                              +------------------------------------------------+

+===[inverter]================================================================================================
|                                                 STATISTICS                                                  
+=============================================================================================================


                   |     Original      |     Reduced      
Cell               |   lay   :   sch   |   lay   :  sch
-------------------+---------+---------+---------+--------
MP [4 pins]        |         :         |         :        
 MP(PFET_01V8)     |       1 :       1 |       1 :       1
MN [4 pins]        |         :         |         :        
 MN(NFET_01V8)     |       1 :       1 |       1 :       1
-------------------+---------+---------+---------+--------
Total              |       2 :       2 |       2 :       2
===================+=========+=========+=========+========
Pins               |         :         |       4 :       4
Nets               |         :         |       0 :       0
===================+=========+=========+=========+========

+===[inverter]================================================================================================
|                                           INITIAL CORRESPONDENCES                                           
+=============================================================================================================

Type     | Name
---------+-------------------
Pin      | GND IN OUT VDD


##############################################################################################################
#
#                                                END OF REPORT                                                
#
##############################################################################################################

