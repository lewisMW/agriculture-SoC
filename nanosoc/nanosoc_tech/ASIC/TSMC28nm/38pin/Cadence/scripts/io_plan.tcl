#-----------------------------------------------------------------------------
# NanoSoC IO plan for PnR in cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------


deleteIoFiller -cell PFILLER5_G
deleteIoFiller -cell PFILLER0005_G


loadIoFile ../scripts/nanosoc_io_plan.io

addIoFiller -cell PFILLER5_G -prefix FILLER 
addIoFiller -cell PFILLER05_G -prefix FILLER 
addIoFiller -cell PFILLER0005_G -prefix FILLER 