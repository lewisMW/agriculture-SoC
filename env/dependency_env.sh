#-----------------------------------------------------------------------------
# SoC Labs Dependency Repository Environment Setup Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright  2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
#!/bin/bash

#-----------------------------------------------------------------------------
# Technologies
#-----------------------------------------------------------------------------

export ARM_IP_LIBRARY_PATH="/Users/lewismw/Documents/SoCs"
# MAKE SURE to not have a forward slash or space at the end of the above line!!!

# Accelerator Engine -- Add Your Accelerator Environment Variable HERE!
export ACCELERATOR_DIR="$SOCLABS_PROJECT_DIR/secworks-aes"

# Accelerator Wrapper
export SOCLABS_WRAPPER_TECH_DIR="$SOCLABS_PROJECT_DIR/accelerator_wrapper_tech"

# NanoSoC
export SOCLABS_NANOSOC_TECH_DIR="$SOCLABS_PROJECT_DIR/nanosoc_tech"

# SoCDebug
export SOCLABS_SOCDEBUG_TECH_DIR="$SOCLABS_PROJECT_DIR/nanosoc_tech/nanosoc/socdebug_tech"

# SLCore-M0
export SOCLABS_SLCOREM0_TECH_DIR="$SOCLABS_PROJECT_DIR/nanosoc_tech/nanosoc/slcorem0_tech"

# SLDMA-230
export SOCLABS_SLDMA230_TECH_DIR="$SOCLABS_PROJECT_DIR/nanosoc_tech/nanosoc/sldma230_tech"
export SOCLABS_SLDMA350_TECH_DIR="$SOCLABS_PROJECT_DIR/nanosoc_tech/nanosoc/sldma350_tech"

# Primtives
export SOCLABS_PRIMITIVES_TECH_DIR="$SOCLABS_PROJECT_DIR/rtl_primitives_tech"

# FPGA Libraries
export SOCLABS_FPGA_LIB_TECH_DIR="$SOCLABS_PROJECT_DIR/fpga_lib_tech"

# ASIC Libraries
export SOCLABS_ASIC_LIB_TECH_DIR="$SOCLABS_PROJECT_DIR/asic_lib_tech"

# Generic Libraries
export SOCLABS_GENERIC_LIB_TECH_DIR="$SOCLABS_PROJECT_DIR/generic_lib_tech"

#-----------------------------------------------------------------------------
# Flows
#-----------------------------------------------------------------------------

# SoCTools - Toolkit of scripts related to SoCLabs projects
export SOCLABS_SOCTOOLS_FLOW_DIR="$SOCLABS_PROJECT_DIR/soctools_flow"

# CHIPKIT - Register Generation
export SOCLABS_CHIPKIT_FLOW_DIR="$SOCLABS_SOCTOOLS_FLOW_DIR/tools/chipkit_flow"
