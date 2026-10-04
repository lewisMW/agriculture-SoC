#-----------------------------------------------------------------------------
# ASIC Flow gate synthesis script for Cadence Genus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# run: genus -f 1_synthesis.tcl
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# David Flynn (d.w.flynn@soton.ac.uk)
# Srimanth Tenneti
#
# Copyright (C) 2025, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu 8

source ../scripts/config.tcl

## -- Setup libraries -- ##
set_db init_lib_search_path $lib_search_path_list
create_library_domain domain1
set_db -verbose [get_db library_domains domain1] .library $syn_lib_list
check_library > $LOG_DIR/syn_lib_check.log

## -- Read in RTL and elaborate top level
source $hdl_file_list
read_hdl -define POWER_PINS $top_level_hdl
elaborate $block_name

## -- Load power intent for top and accelerator power domains -- ##
read_power_intent -module $block_name ../inputs/${block_name}.upf

## -- Uncomment if you want to preserve hierarchy -- ##
#set_db auto_ungroup none

## -- Apply power intent and check library and CPF -- ##
apply_power_intent
check_cpf -detail -license lpgxl > $LOG_DIR/syn_cpf_check.log
commit_power_intent

## -- Preserve power pad instances / macros from optimization -- ##
set_dont_touch [get_cells -hierarchical -filter {name =~ "uPAD*"}]

check_power_structure -detail -license lpgxl > $LOG_DIR/syn_pow_check.log

## -- Read constraints -- ##
read_sdc $constraints_file

## -- Setup DFT -- ##
if {$DFT == 1} {
    source ../scripts/dft_setup.tcl
}

## -- Synthesis -- ##
set_db syn_generic_effort high
set_db syn_map_effort high

syn_generic
syn_map

if {$DFT == 1} {
    convert_to_scan
    connect_scan_chains
}

syn_opt

## -- Report Final -- ##
report_area > $REPORT_DIR/syn_area.rep
report_timing > $REPORT_DIR/syn_timing.rep
report_gates > $REPORT_DIR/syn_gates.rep
report_power > $REPORT_DIR/syn_power.rep

write_hdl > $OUT_DIR/${block_name}_gate.v
write_hdl -pg > $OUT_DIR/${block_name}_gate_power.v
write_power_intent -cpf -design $block_name -base_name $OUT_DIR/${block_name}_gate
write_power_intent -design $block_name -base_name $OUT_DIR/${block_name}_gate

write_sdf -timescale ns > $OUT_DIR/${block_name}_gate.sdf

write_do_lec -revised_design $OUT_DIR/${block_name}_gate.v -no_lp -top ${block_name} -logfile $LOG_DIR/lec.log > lec.dofile  

if {$DFT == 1} {
    report_scan_chains > $OUT_DIR/${block_name}_scan_chains_44pin.rep
    report_scan_setup > $OUT_DIR/${block_name}_scan_setup_44pin.rep
    report_scan_registers > $OUT_DIR/${block_name}_scan_registers_44pin.rep
    write_dft_abstract_model > $OUT_DIR/${block_name}_dft_abstract_model_44pin
    write_dft_atpg_other_vendor -mentor > $OUT_DIR/${block_name}_atpg_44pin
    write_scandef > $OUT_DIR/$block_name.def
}

write_sdc > $OUT_DIR/${block_name}_syn.sdc

write_db ${block_name}_syn_session

exit