#-----------------------------------------------------------------------------
# NanoSoC IO plan for PnR in cadence Innovus
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# Daniel Newbrook (d.newbrook@soton.ac.uk)
#
# Copyright (C) 2021-6, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

floorPlan -flip f -site GF018hv5v_green_sc9 -d 5000 5000 135.0 135 135 135


deleteIoFiller -cell gf180mcu_fd_io__cor
deleteIoFiller -cell gf180mcu_fd_io__fill10
deleteIoFiller -cell gf180mcu_fd_io__fill5
deleteIoFiller -cell gf180mcu_fd_io__fill1

loadIoFile ../scripts/nanosoc_io_plan.io

addIoFiller -cell gf180mcu_fd_io__fill10 -prefix FILLER -side n
addIoFiller -cell gf180mcu_fd_io__fill10 -prefix FILLER -side e
addIoFiller -cell gf180mcu_fd_io__fill10 -prefix FILLER -side s 
addIoFiller -cell gf180mcu_fd_io__fill10 -prefix FILLER -side w 

addIoFiller -cell gf180mcu_fd_io__fill5 -prefix FILLER -side n
addIoFiller -cell gf180mcu_fd_io__fill5 -prefix FILLER -side e
addIoFiller -cell gf180mcu_fd_io__fill5 -prefix FILLER -side s 
addIoFiller -cell gf180mcu_fd_io__fill5 -prefix FILLER -side w 

addIoFiller -cell gf180mcu_fd_io__fill1 -prefix FILLER -side n
addIoFiller -cell gf180mcu_fd_io__fill1 -prefix FILLER -side e
addIoFiller -cell gf180mcu_fd_io__fill1 -prefix FILLER -side s 
addIoFiller -cell gf180mcu_fd_io__fill1 -prefix FILLER -side w 

