#-----------------------------------------------------------------------------
# SoC Labs Simulation script for system level verification
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright  2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

#!/usr/bin/env bash
set -x
# Get simulation name from name of script
SIM_NAME=`basename -s .sh "$0"`

# Directory to put simulation files
SIM_DIR=$SOCLABS_PROJECT_DIR/simulate/sim/$SIM_NAME

# Create Directory to put simulation files
mkdir -p $SIM_DIR
cd $SOCLABS_PROJECT_DIR/simulate/sim/$SIM_NAME

# Compile Simulation
# Call makefile in NanoSoC Repo with options
echo ${2}
make -C $SOCLABS_NANOSOC_TECH_DIR run_iverilog \
    SIM_DIR=$SIM_DIR \
    ACCELERATOR=yes \
    ${@:2}

