##############################################################################################################
#####  
#####                                       Pegasus LVS COMPARISON
#####  
#####  Version                       :   23.26-s005
#####  NVN Run Start                 :   Sat Aug 29 16:30:15 2026
#####  ERC Summary File              :   Comparator.sum
#####  Extraction Report File        :   Comparator.rep
#####  Comparison Report File        :   Comparator.rep.cls
#####  Top Cell                      :   Comparator  <vs>  Comparator
#####  
#####                                :      @     @
#####                                :       @   @ 
#####                                :        @ @  
#####  Run Result                    :     MISMATCH
#####                                :        @ @  
#####                                :       @   @ 
#####                                :      @     @
#####  
#####  Run Summary                   :   [ERROR] Connectivity Mismatches
#####                                :   [WARN]  Top Cell Has Extra Pins
#####                                :   [INFO]  ERC Results: Empty
#####                                :   [INFO]  Extraction Clean
#####  
#####  Layout Design                 :   sky130_analog_lib Comparator layout
#####  Schematic File                :   /home/admin/git/agriculture-SoC/analog/cadence/sky130/SoC/sky130_analog_lib/Comparator/LVS/Comparator.cdl (cdl)
#####  Rules File                    :   /home/admin/git/agriculture-SoC/analog/cadence/sky130/SoC/sky130_analog_lib/Comparator/LVS/.config.rul
#####                                :   /home/admin/Documents/PDKs/sky130_release_0.1.0/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl
#####  Pin Swap File                 :   Comparator.rep.cps
#####  
#####  Extraction CPU Time           :   0h 0m 1s - (1s)
#####  Extraction Exec Time          :   0h 0m 2s - (2s)
#####  Extraction Peak Memory Usage  :   25.00MB
#####  NVN CPU Time                  :   0h 0m 0s - (0s)                 
#####  NVN Exec Time                 :   0h 0m 1s - (1s)                 
#####  NVN Peak Memory Usage         :   254.01MB
#####  LVS Total CPU Time            :   0h 0m 1s - (1s)                 
#####  LVS Total Exec Time           :   0h 0m 3s - (3s)                 
#####  LVS Total Peak Memory Usage   :   254.01MB
#####  
##############################################################################################################


##############################################################################################################
#
#                                            CELL MATCH STATISTICS                                            
#
##############################################################################################################

Cell Statistic Descriptions                  | Count
---------------------------------------------+----------
Cells matched                                |         0
Cells expanded                               |         0
Cells not run                                |         0
Cells which mismatch                         |         1
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

              |    Initial Pins    |    Compare Pins     |              | 
Cell          |   lay   :   sch    |   lay   :    sch    | Status       | Detail
--------------+---------+----------+---------+-----------+--------------+-------------------------------------
Comparator    |      *0 :       17 |      *0 :        11 | mismatch     | fatal pin mismatches, extra pins


##############################################################################################################
#
#                                                  LVS RULES                                                  
#
##############################################################################################################

Command Line LVS Rule Values
----------------------------

    layout_primary                          Comparator {-top_cell Comparator}
    schematic_primary                       Comparator {-source_top_cell Comparator}

LVS Rules Given in the Rules File
---------------------------------

    lvs_abort                               -softchk                               no  
    lvs_abort                               -supply_error                          no  
    layout_path                             /home/admin/git/agriculture-SoC/analog/cadence/sky130/SoC/sky130_analog_lib/Comparator/LVS/Comparator.gds.gz
    layout_format                           gdsii
    layout_primary                          TOPCELL
    schematic_path                          /home/admin/git/agriculture-SoC/analog/cadence/sky130/SoC/sky130_analog_lib/Comparator/LVS/Comparator.cdl
    schematic_format                        cdl
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
    lvs_report_file                         Comparator.rep
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
    layout_primary                          Comparator
    lvs_recognize_gates                     -none
    virtual_connect                         no  -report


##############################################################################################################
#
#                                               CELL COMPARISON                                               
#
##############################################################################################################

                              ##################################################
                              #                                                #
                              #       ------->>> $ MISMATCH $ <<<-------       #
                              #                                                #
                              #          Comparator  <vs>  Comparator          #
                              #                                                #
                              #            CONNECTIVITY MISMATCHES             #
                              #                   EXTRA PINS                   #
                              #                                                #
                              ##################################################

+===[Comparator]==============================================================================================
|                                                 STATISTICS                                                  
+=============================================================================================================


                        |     Original      |      Reduced      |     Unmatched     
Cell                    |   lay   :   sch   |   lay   :   sch   |   lay   :   sch
------------------------+---------+---------+---------+---------+---------+---------
(MP [4 pins], -)        |         :         |         :         |         :         
 (MP(PFET_01V8), -)     |      *6 :       0 |      *6 :       0 |      *6 :        0
(MN [4 pins], -)        |         :         |         :         |         :         
 (MN(NFET_01V8), -)     |     *38 :       0 |     *15 :       0 |     *15 :        0
(-, Trim [7 pins])      |         :         |         :         |         :         
 (-, Trim())            |      *0 :       2 |      *0 :       2 |      *0 :        2
------------------------+---------+---------+---------+---------+---------+---------
Total                   |      44 :       2 |      21 :       2 |      21 :        2
========================+=========+=========+=========+=========+=========+=========
Pins                    |         :         |      *0 :      11 |      *0 :       11
Nets                    |         :         |     *32 :       2 |       0 :        0
========================+=========+=========+=========+=========+=========+=========

+===[Comparator]==============================================================================================
|                                      DEVICES REMOVED DURING REDUCTION                                       
+=============================================================================================================


                        |     Parallel      |      Series       |     Deleted Nets     
Cell                    |   lay   :   sch   |   lay   :   sch   |    lay    :   sch
------------------------+---------+---------+---------+---------+-----------+----------
(MN [4 pins], -)        |         :         |         :         |           :          
 (MN(NFET_01V8), -)     |      23 :       - |       - :       - |         0 :         0
------------------------+---------+---------+---------+---------+-----------+----------

+===[Comparator]==============================================================================================
|                                                 EXTRA PINS                                                  
+=============================================================================================================

Side     | Pins
---------+------------------------------
Sch      | Out_N Out_P Clk Vdd Vn Vp


+===[Comparator]==============================================================================================
|                                               MISMATCHED NETS                                               
+=============================================================================================================
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Vss
==================================+======================(mn 1)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trimb<0>
==================================+======================(mn 2)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trimb<1>
==================================+======================(mn 3)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trimb<2>
==================================+======================(mn 4)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trimb<3>
==================================+======================(mn 5)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trimb<4>
==================================+======================(mn 6)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trima<0>
==================================+======================(mn 7)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trima<1>
==================================+======================(mn 8)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trima<2>
==================================+======================(mn 9)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trima<3>
==================================+=====================(mn 10)
                                                               
                                                               
Layout Net: ** missing net **     | Schematic Pin: Trima<4>
==================================+=====================(mn 11)


+===[Comparator]==============================================================================================
|                                            MISMATCHED INSTANCES                                             
+=============================================================================================================
                                                                                        
                                                                                        
Layout Inst : ** missing inst **               | Schematic Inst : XI1
Layout Model:                                  | Schematic Model: Trim
===============================================+==================================(mi 1)
                                                                                        
                                                                                        
Layout Inst : ** missing inst **               | Schematic Inst : XI0
Layout Model:                                  | Schematic Model: Trim
===============================================+==================================(mi 2)
                                                                                        
                                                                                        
Layout Inst : X42/M0 @(7.395,5.865)            | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 3)
                                                                                        
                                                                                        
Layout Inst : X43/M0 @(8.505,5.865)            | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 4)
                                                                                        
                                                                                        
Layout Inst : X44/M1 @(9.050,1.700)            | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 5)
                                                                                        
                                                                                        
Layout Inst : X45/X50/M0 @(-10.665,8.620)      | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 6)
                                                                                        
                                                                                        
Layout Inst : X45/X51/M0 @(-10.665,7.130)      | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 7)
                                                                                        
                                                                                        
Layout Inst : X45/X52/M0 @(-10.665,10.690)     | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 8)
                                                                                        
                                                                                        
Layout Inst : X45/X49/M6 @(-10.665,2.160)      | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+==================================(mi 9)
                                                                                        
                                                                                        
Layout Inst : X45/X53/M3 @(-10.665,12.180)     | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 10)
                                                                                        
                                                                                        
Layout Inst : X46/X50/M0 @(28.420,8.620)       | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 11)
                                                                                        
                                                                                        
Layout Inst : X46/X51/M0 @(28.420,7.130)       | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 12)
                                                                                        
                                                                                        
Layout Inst : X46/X52/M0 @(28.420,10.690)      | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 13)
                                                                                        
                                                                                        
Layout Inst : X46/X49/M6 @(28.420,2.160)       | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 14)
                                                                                        
                                                                                        
Layout Inst : X46/X53/M3 @(28.420,12.180)      | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 15)
                                                                                        
                                                                                        
Layout Inst : X47/M0 @(9.315,4.865)            | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 16)
                                                                                        
                                                                                        
Layout Inst : X48/M0 @(10.425,4.865)           | Schematic Inst : ** missing inst **
Layout Model: MN(NFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 17)
                                                                                        
                                                                                        
Layout Inst : X49/M0 @(2.495,12.065)           | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 18)
                                                                                        
                                                                                        
Layout Inst : X50/M0 @(4.905,12.065)           | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 19)
                                                                                        
                                                                                        
Layout Inst : X51/M0 @(7.695,12.065)           | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 20)
                                                                                        
                                                                                        
Layout Inst : X52/M0 @(10.105,12.065)          | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 21)
                                                                                        
                                                                                        
Layout Inst : X53/M0 @(12.895,12.065)          | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 22)
                                                                                        
                                                                                        
Layout Inst : X54/M0 @(15.305,12.065)          | Schematic Inst : ** missing inst **
Layout Model: MP(PFET_01V8)                    | Schematic Model: 
===============================================+=================================(mi 23)


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++ 11 out of 11 pins were unmatched. 
++++++ Further matching above this cell is disabled. 
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

##############################################################################################################
#
#                                                END OF REPORT                                                
#
##############################################################################################################

