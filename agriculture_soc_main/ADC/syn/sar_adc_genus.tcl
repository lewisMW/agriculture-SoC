#-----------------------------------------------------------------------------
# sar_adc_genus.tcl -- synthesise sar_adc on its own (Genus 22.1)
#
# sky130_fd_sc_hd at tt_025C_1v80 plus ONE corner of the sar_afe macro .lib,
# constrained by sar_adc_top.sdc (which sources ../sar_adc.sdc). It checks
# that the macro resolves to its .lib cell, that no latch is inferred, that
# the comparator latch's loop is broken, check_timing_intent, and the timing
# at the chip's PCLK (30 ns).
#
# On the Cadence box, from an empty run directory:
#   genus -no_gui -batch -files <repo>/agriculture_soc_main/ADC/syn/sar_adc_genus.tcl
# Reports go to ./reports (summary.rpt first), the netlist and SDC to ./outputs.
#-----------------------------------------------------------------------------
set REPO [file normalize [file join [file dirname [info script]] .. .. ..]]
if {![info exists ::env(ACCELERATOR_DIR)]} { set ::env(ACCELERATOR_DIR) $REPO/agriculture_soc_main }
set PDK /opt/pdk/sky130A
file mkdir reports outputs

set_db init_lib_search_path [list $PDK/libs.ref/sky130_fd_sc_hd/lib $REPO/ASIC_ours/macros/sar_afe]
read_libs [list sky130_fd_sc_hd__tt_025C_1v80.lib sar_afe__tt_025C_1v80.lib]
set_db use_scan_seqs_for_non_dft false      ;# as ASIC_ours' 1_synthesis.tcl without DFT

read_hdl [list \
    $REPO/agriculture_soc_main/ADC/sar_adc.v \
    $REPO/agriculture_soc_main/ADC/sar_comp_latch.v \
    $REPO/analog/cadence/sar_adc/sarlogic/functional/verilog.v]
elaborate sar_adc
check_design -unresolved > reports/check_design_unresolved.rpt
read_sdc $REPO/agriculture_soc_main/ADC/syn/sar_adc_top.sdc

syn_generic
syn_map
syn_opt

# ---- reports -----------------------------------------------------------------
check_design -all                       > reports/check_design.rpt
check_timing_intent -verbose            > reports/check_timing_intent.rpt
report_clocks                           > reports/clocks.rpt
report_clocks -generated               >> reports/clocks.rpt
report_qor                              > reports/qor.rpt
report_timing -max_paths 10             > reports/timing.rpt
report_timing -through [get_pins u_afe/outn] > reports/timing_comparator_outn.rpt
report_timing -through [get_pins u_afe/outp] > reports/timing_comparator_outp.rpt
report_timing -from [get_clocks clk] -to [get_clocks sar_clk] -max_paths 3 > reports/timing_pclk_to_sar.rpt
report_timing -from [get_clocks sar_clk] -to [get_clocks clk] -max_paths 3 > reports/timing_sar_to_pclk.rpt
report_timing -from [get_clocks sar_clk] -to [get_clocks sar_clk] -max_paths 3 > reports/timing_sar_internal.rpt
report_area                             > reports/area.rpt
report_gates                            > reports/gates.rpt
write_hdl                               > outputs/sar_adc_gate.v
write_sdc                               > outputs/sar_adc_syn.sdc

# ---- summary -------------------------------------------------------------------
set fh [open reports/summary.rpt w]
set afe [get_db insts u_afe]
puts $fh "u_afe: lib_cell [get_db $afe .lib_cell.name], is_macro [get_db $afe .is_macro], preserve [get_db $afe .preserve]"
puts $fh "u_latch: preserve [get_db [get_db hinsts u_latch] .preserve]; cells [get_db [get_db insts u_latch/*] .name] = [get_db [get_db insts u_latch/*] .lib_cell.base_name]"
set seq [get_db insts -if {.is_sequential == true}]
set lat [get_db insts -if {.is_latch == true}]
puts $fh "sequential cells [llength $seq], of which latches [llength $lat]: [get_db $lat .name]"
set cells {}
foreach i $seq { lappend cells [get_db $i .lib_cell.base_name] }
foreach c [lsort -unique $cells] { puts $fh "  [format %4d [llength [lsearch -all $cells $c]]] x $c" }
puts $fh "loop breakers: [llength [get_db insts -if {.name == *cdn_loop_breaker*}]]"
foreach c [get_db clocks] { puts $fh "clock [get_db $c .base_name]: period [get_db $c .period] ps, waveform [get_db $c .waveform]" }
close $fh
exit
