#-----------------------------------------------------------------------------
# NanoSoC CocoTB Simulation Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
# Copyright cocotb contributors
# Licensed under the Revised BSD License, see LICENSE for details.
# SPDX-License-Identifier: BSD-3-Clause

# Simulator to Run
SIM ?= questa

# Python Install to Use
PYTHON_BIN = /usr/bin/python3.8

TOPLEVEL_LANG ?= verilog

ifneq ($(TOPLEVEL_LANG),verilog)

all:
	@echo "Skipping test due to TOPLEVEL_LANG=$(TOPLEVEL_LANG) not being verilog"
clean::

else

TOPLEVEL := nanosoc_tb

EXTRA_ARGS += +define+CORTEX_M0
EXTRA_ARGS += +define+COCOTB_SIM

ACCELERATOR ?= yes

ifeq ($(ACCELERATOR),yes)
	EXTRA_ARGS += +define+ACCELERATOR_SUBSYSTEM
endif

include $(SOCLABS_PROJECT_DIR)/simulate/sim/cocotb/makefile.flist

include $(shell cocotb-config --makefiles)/Makefile.sim

endif
