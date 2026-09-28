#-----------------------------------------------------------------------------
# ASIC Flow formality checks
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: fm_shell -f 6_formality_signoff.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

source ../scripts/config.tcl
set_host_options -max_cores 8

# Pessimistic analysis mode on constant registers
#set verification_assume_reg_init none
#
## Enable identification of clock gating in the design
#set_app_var verification_clock_gate_edge_analysis true
#
## Account for inversions across register boundaries
#set_app_var verification_inversion_push true
#
## Restore these values to defaults if using synopsys_auto_setup mode
#set_app_var verification_set_undriven_signals "BINARY:X"
#set_app_var verification_verify_directly_undriven_output true
#
#set_app_var hdlin_ignore_full_case true
#set_app_var hdlin_do_inout_port_fixup true
# Switch off the signature analysis
#set_app_var signature_analysis_match_compare_points false
#set_app_var signature_analysis_match_datapath false
#set_app_var signature_analysis_match_hierarchy false

# Increase number of failing points before halting verification (0 = unlimited)
#set_app_var verification_failing_point_limit 0

set hdlin_allow_partial_pg_netlist true

#set_app_var verification_allow_hardware_x_semantics auto  
#set_app_var verification_propagate_const_reg_x false 

set_mismatch_message_filter -warn FMR_ELAB-147
set_mismatch_message_filter -warn FMR_ELAB-058
set_svf $OUT_DIR/impl.svf



source $file_formality_list
read_verilog -r $top_level_verilog

foreach ref_lib $formality_ref_libs_list {
    read_db -r $ref_lib
}
set_top $block_name
#load_upf -r ../scripts/${block_name}.upf

# -----------------------------------------------------------------------------------
# Read in the Implementation Design ( -> i )
# -----------------------------------------------------------------------------------
foreach imp_lib $formality_imp_libs_list {
    read_db -i $imp_lib
}
read_verilog -i $OUT_DIR/${block_name}_gate.v
set_top $block_name
#load_upf -i ../outputs/impl.upf

set_compare_rule r:/WORK/${block_name} -from {gen_rar.} -to {}
set_compare_rule i:/WORK/${block_name} -from {gen_rar.} -to {}

set_compare_rule r:/WORK/${block_name} -from {gen_non_rar.} -to {}
set_compare_rule i:/WORK/${block_name} -from {gen_non_rar.} -to {}

# -----------------------------------------------------------------------------------
# Identify the mode of clock gating if used in the design
# -----------------------------------------------------------------------------------

set_app_var verification_clock_gate_hold_mode low

set_reference_design  r:/WORK/${block_name}
set_implementation_design  i:/WORK/${block_name}


match

report_matched_points         > $REPORT_DIR/lec_${block_name}.matched.fm
report_unmatched_points -status unread > $REPORT_DIR/lec_${block_name}.unread.fm
report_unmatched_points       > $REPORT_DIR/lec_${block_name}.unmatched.fm

# Report setup status after matching
report_setup_status

# -----------------------------------------------------------------------------------
# Verify the design
# -----------------------------------------------------------------------------------
verify

report_passing_points         > $REPORT_DIR/lec_${block_name}.passed.fm
report_failing_points         > $REPORT_DIR/lec_${block_name}.failed.fm
report_aborted_points         > $REPORT_DIR/lec_${block_name}.aborted.fm
report_constants              > $REPORT_DIR/lec_${block_name}.constants.fm
report_loops                  > $REPORT_DIR/lec_${block_name}.loops.fm
report_undriven_nets          > $REPORT_DIR/lec_${block_name}.undriven_nets.fm
report_multidriven_nets       > $REPORT_DIR/lec_${block_name}.multidriven_nets.fm
report_guidance -summary      > $REPORT_DIR/lec_${block_name}.svf_guidance.summary
report_guidance -to             $REPORT_DIR/lec_${block_name}.svf_guidance.txt
report_libraries -defects all > $REPORT_DIR/lec_${block_name}.defects.fm


analyze_points -all > $REPORT_DIR/lec_${block_name}.analysis_results
save_session -replace ${block_name}_formal_equivalence

# -----------------------------------------------------------------------------
# Report logical equivalence status
# -----------------------------------------------------------------------------

report_status

# -----------------------------------------------------------------------------
# Report message summary and quit
# -----------------------------------------------------------------------------

print_message_info

exit