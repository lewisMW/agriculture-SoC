#-----------------------------------------------------------------------------
# sar_adc.sdc -- timing constraints of the SAR ADC (agriculture_soc_main/ADC/sar_adc.v)
#
# A fragment: source it from the chip constraints AFTER the master clock (the
# clock at sar_adc's clk: PCLK = HCLK) has been created. For the nanosoc chip,
# add one line to ASIC_ours/Cadence/inputs/constraints.sdc, after its
# create_clock commands (ACCELERATOR_DIR comes from env/dependency_env.sh):
#
#     source $::env(ACCELERATOR_DIR)/ADC/sar_adc.sdc
#
# The defaults below match that file and the nanosoc chip. To override one,
# set it before sourcing:
#   SAR_ADC_INST     hierarchical path of the sar_adc instance; "" when sar_adc
#                    is the top (default: found from its sar_afe macro, below)
#   SAR_ADC_MASTER   name of the clock at sar_adc/clk   (default $EXTCLK, else clk)
#   SAR_ADC_SOURCE   port that clock is defined on      (default CLK, the chip pin)
#   SAR_ADC_PERIOD   its period in ns                   (default $EXTCLK_PERIOD, else 30)
#   SAR_ADC_CLK_DIV  sar_adc's CLK_DIV                  (default 4, as
#                    adc_apb_wrapper_rev2's ADC_CLK_DIV)
#
# Genus reads this file on the RTL, Innovus on the synthesised netlist, where
# Genus may have flattened levels above or at the sar_adc instance (it names a
# flattened child <parent>_<child>). So by default the instance is found from
# its sar_afe macro, the only one in the chip: the prefix of every object
# below is the macro's name minus its final "u_afe", e.g.
#   RTL:      .../sensor_wrapper/u_adc/
#   netlist:  .../sensor_wrapper_u_adc_    (both levels flattened), or
#             .../sensor_wrapper_u_adc/    (u_adc kept, ungroup_ok false)
# The latch keeps its own level because it is dont_touch. The file stops with
# an error if an object is missing, rather than leaving the ADC unconstrained.
#
# Nothing here constrains the analog pins vinp/vinn: they have no timing arcs.
#-----------------------------------------------------------------------------

if {![info exists SAR_ADC_MASTER]} {
    if {[info exists EXTCLK]} { set SAR_ADC_MASTER $EXTCLK } else { set SAR_ADC_MASTER clk }
}
if {![info exists SAR_ADC_SOURCE]} { set SAR_ADC_SOURCE CLK }
if {![info exists SAR_ADC_PERIOD]} {
    if {[info exists EXTCLK_PERIOD]} { set SAR_ADC_PERIOD $EXTCLK_PERIOD } else { set SAR_ADC_PERIOD 30.0 }
}
if {![info exists SAR_ADC_CLK_DIV]} { set SAR_ADC_CLK_DIV 4 }

if {[info exists SAR_ADC_INST]} {
    if {$SAR_ADC_INST eq ""} { set sar_adc_p "" } else { set sar_adc_p "${SAR_ADC_INST}/" }
} else {
    set sar_adc_m [get_cells -quiet -hierarchical -filter "ref_name == sar_afe"]
    if {[sizeof_collection $sar_adc_m] != 1} {
        error "sar_adc.sdc: expected one sar_afe instance, found [sizeof_collection $sar_adc_m]; set SAR_ADC_INST"
    }
    set sar_adc_m [get_object_name $sar_adc_m]
    if {![string match *u_afe $sar_adc_m]} {
        error "sar_adc.sdc: the sar_afe instance is $sar_adc_m, not <sar_adc>/u_afe; set SAR_ADC_INST"
    }
    set sar_adc_p [string range $sar_adc_m 0 end-5]
}

# ---- objects ---------------------------------------------------------------
set sar_adc_afe [get_cells -quiet ${sar_adc_p}u_afe]
set sar_adc_lat [get_cells -quiet ${sar_adc_p}u_latch]
set sar_adc_nq  [get_cells -quiet ${sar_adc_p}u_latch/u_nand_q]
set sar_adc_nqn [get_cells -quiet ${sar_adc_p}u_latch/u_nand_qn]
set sar_adc_q   [get_pins  -quiet ${sar_adc_p}sar_clk_reg/Q]
if {[sizeof_collection $sar_adc_q] == 0} {
    set sar_adc_q [get_pins -quiet ${sar_adc_p}sar_clk_reg/q]    ;# Genus, before mapping
}
foreach {sar_adc_what sar_adc_obj} [list u_afe $sar_adc_afe u_latch $sar_adc_lat \
        u_latch/u_nand_q $sar_adc_nq u_latch/u_nand_qn $sar_adc_nqn sar_clk_reg/Q $sar_adc_q] {
    if {[sizeof_collection $sar_adc_obj] == 0} {
        error "sar_adc.sdc: ${sar_adc_p}${sar_adc_what} not found (sar_adc prefix '${sar_adc_p}')"
    }
}

# ---- clocks ----------------------------------------------------------------
# sar_clk: sar_clk_reg toggles every CLK_DIV master cycles on the master's
# FALLING edge, so it rises on master edge 2 (edge 1 = the first rising edge)
# and falls 2*CLK_DIV edges later. Being a divided master it is a related
# clock, and every sar_clk edge sits half a master period from the
# master-domain logic.
set sar_adc_n [expr {2 * $SAR_ADC_CLK_DIV}]
create_generated_clock -name sar_clk -source [get_ports $SAR_ADC_SOURCE] \
    -edges [list 2 [expr {2 + $sar_adc_n}] [expr {2 + 2 * $sar_adc_n}]] $sar_adc_q

# sar_clkc: the comparator clock, clkc = ~sar_clk & en_co_clk (sarlogic), an
# inverted, gated sar_clk. Defined on the macro's clk pin because the gate
# that drives it has a synthesis-generated name. The enable changes just after
# sar_clk rises, while ~sar_clk is low, so clkc cannot glitch.
create_generated_clock -name sar_clkc -source $sar_adc_q -divide_by 1 -invert \
    [get_pins ${sar_adc_p}u_afe/clk]

# ---- comparator -> latch -> sarlogic ----------------------------------------
# The .lib's combinational clk -> outp/outn arcs model the comparator: on the
# rising edge of clkc (the falling edge of sar_clk) one output falls (the
# decision, 1.0 ns typical), on the falling edge both rise (reset). The
# decision goes through the NAND latch into sarlogic's flops (dig_result,
# cal_count), which capture it on the next rising edge of sar_clk: a
# half-period path launched by sar_clkc. Stopping the clock at outp/outn makes
# that a data path, so no clock reaches the flops' data pins.
set_sense -type clock -stop_propagation -clocks [get_clocks sar_clkc] \
    [get_pins [list ${sar_adc_p}u_afe/outp ${sar_adc_p}u_afe/outn]]

# Break the latch's loop at u_nand_qn B -> Y (q -> qn). Both decisions stay
# timed to q: outn -> u_nand_q A -> Y, and outp -> u_nand_qn A -> Y ->
# u_nand_q B -> Y.
set_disable_timing -from B -to Y $sar_adc_nqn

# The latch must stay exactly two NANDs, and the macro is a hard block.
set_dont_touch $sar_adc_afe
set_dont_touch $sar_adc_lat
set_dont_touch $sar_adc_nq
set_dont_touch $sar_adc_nqn

# ---- clock-domain crossings --------------------------------------------------
# Master -> sar_clk: en, cal and rstn into sarlogic. Timed as they are: half a
# master period, the setup the falling-edge divider leaves them.
#
# sar_clk -> master: valid and result into adc_apb_wrapper_rev2. valid goes
# through a 3-flop synchroniser, and result is captured on the synchronised
# rising edge, at least 2 master periods after the sar_clk edge that changed
# both; result then holds for at least 10 sar_clk periods. The functional
# budget is therefore 2 master periods, and the first synchroniser flop
# tolerates metastability by design. One master period of set_max_delay
# replaces the half-period check of the clock relationship: well inside that
# budget, still a bound that keeps P&R from stretching the paths, and valid if
# sar_clk is ever made asynchronous to the master. sar_adc's valid and result
# are the only sar_clk-launched paths into the master domain.
set_max_delay $SAR_ADC_PERIOD -from [get_clocks sar_clk] -to [get_clocks $SAR_ADC_MASTER]
