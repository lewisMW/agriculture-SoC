#-----------------------------------------------------------------------------
# SoCLabs SLDMA-230 Flow Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

include $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/hal/makefile.hal_checks

LINT_DIR = $(SOCLABS_PROJECT_DIR)/lint/sldma230
LINT_INFO_DIR = $(SOCLABS_SLDMA230_TECH_DIR)/hal

# Core Design Filelist
DESIGN_VC   ?= $(SOCLABS_SLDMA230_TECH_DIR)/flist/sldma230.flist

# Defines
DEFINES_VC  += +define+CORTEX_M0 +define+USE_TARMAC 

# Black Box for Lint
HAL_BLACK_BOX = -design_info $(LINT_INFO_DIR)/pl230_ip.bb

# Lint Waivers
HAL_WAIVE = -design_info $(LINT_INFO_DIR)/sldma230_ip.waive

lint_xm:
	@rm -rf $(LINT_DIR) 
	@mkdir -p $(LINT_DIR)
	cd $(LINT_DIR); xrun -hal -f $(DESIGN_VC) +debug "-timescale 1ns/1ps" -top sldma230 $(HAL_BLACK_BOX) $(HAL_WAIVE) $(LINT_NOCHECK)

