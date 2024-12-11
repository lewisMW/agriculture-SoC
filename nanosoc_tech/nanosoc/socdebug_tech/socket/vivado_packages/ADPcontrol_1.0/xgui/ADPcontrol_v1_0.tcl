# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.PROMPT_CHAR { PARAM_VALUE.PROMPT_CHAR } {
	# Procedure called to update PROMPT_CHAR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PROMPT_CHAR { PARAM_VALUE.PROMPT_CHAR } {
	# Procedure called to validate PROMPT_CHAR
	return true
}


proc update_MODELPARAM_VALUE.PROMPT_CHAR { MODELPARAM_VALUE.PROMPT_CHAR PARAM_VALUE.PROMPT_CHAR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PROMPT_CHAR}] ${MODELPARAM_VALUE.PROMPT_CHAR}
}

