#-----------------------------------------------------------------------------
# SoCLabs SoCDebug Flow Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

include $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/hal/makefile.hal_checks

LINT_DIR = $(SOCLABS_PROJECT_DIR)/lint/socdebug
LINT_INFO_DIR = $(SOCLABS_SOCDEBUG_TECH_DIR)/hal

# Core Design Filelist
DESIGN_VC   ?= $(SOCLABS_SOCDEBUG_TECH_DIR)/flist/socdebug.flist

# Defines
DEFINES_VC  += +define+CORTEX_M0 +define+USE_TARMAC 

# Lint Waivers
HAL_WAIVE = -design_info $(LINT_INFO_DIR)/socdebug_controller_ip.waive

HAL_TOP = socdebug_ahb

lint_xm:
	@rm -rf $(LINT_DIR) 
	@mkdir -p $(LINT_DIR)
	cd $(LINT_DIR); xrun -hal -f $(DESIGN_VC) +debug "-timescale 1ns/1ps" -top $(HAL_TOP) $(HAL_WAIVE) $(LINT_NOCHECK)

