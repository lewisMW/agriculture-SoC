#-----------------------------------------------------------------------------
# SoCLabs SLCore M0 Flow Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

include $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/hal/makefile.hal_checks

QUICKSTART ?= no

# System Design Filelist
ifeq ($(QUICKSTART),yes)
	ARM_CORTEX_M0_DIR  ?= $(ARM_IP_LIBRARY_PATH)/latest/Cortex-M0-QS/Cortex-M0-logical
	DESIGN_VC          ?= $(SOCLABS_SLCOREM0_TECH_DIR)/flist/slcorem0_qs.flist
else
	ARM_CORTEX_M0_DIR  ?= $(ARM_IP_LIBRARY_PATH)/latest/Cortex-M0/logical
	DESIGN_VC          ?= $(SOCLABS_SLCOREM0_TECH_DIR)/flist/slcorem0.flist
endif

export ARM_CORTEX_M0_DIR

LINT_DIR = $(SOCLABS_PROJECT_DIR)/lint/slcorem0
LINT_INFO_DIR = $(SOCLABS_SLCOREM0_TECH_DIR)/hal

# Defines
DEFINES_VC  += +define+CORTEX_M0 +define+USE_TARMAC 

# Black Box for Lint
HAL_BLACK_BOX = -design_info $(LINT_INFO_DIR)/cortexm0_ip.bb

# Lint Waivers
HAL_WAIVE = -design_info $(LINT_INFO_DIR)/slcorem0_ip.waive

lint_xm:
	@rm -rf $(LINT_DIR) 
	@mkdir -p $(LINT_DIR)
	cd $(LINT_DIR); xrun -hal -f $(DESIGN_VC) +debug "-timescale 1ns/1ps" -top slcorem0 $(HAL_BLACK_BOX) $(HAL_WAIVE) $(LINT_NOCHECK)

