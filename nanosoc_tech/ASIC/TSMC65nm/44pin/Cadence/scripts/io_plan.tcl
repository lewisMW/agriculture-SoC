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


delete_io_fillers -cell PCORNER
delete_io_fillers -cell PFILLER20
delete_io_fillers -cell PFILLER10
delete_io_fillers -cell PFILLER5
delete_io_fillers -cell PFILLER1
delete_io_fillers -cell PFILLER05
delete_io_fillers -cell PFILLER0005


read_io_file nanosoc_io_plan.io

add_io_fillers -cells PCORNER -prefix CORNER -side n -from 880 -to 1000
add_io_fillers -cells PCORNER -prefix CORNER -side e -from 0 -to 120
add_io_fillers -cells PCORNER -prefix CORNER -side s -from 0 -to 120
add_io_fillers -cells PCORNER -prefix CORNER -side w -from 1380 -to 1500

add_io_fillers -cells PFILLER20 -prefix FILLER -side n
add_io_fillers -cells PFILLER20 -prefix FILLER -side e
add_io_fillers -cells PFILLER20 -prefix FILLER -side s 
add_io_fillers -cells PFILLER20 -prefix FILLER -side w 

add_io_fillers -cells PFILLER10 -prefix FILLER -side n
add_io_fillers -cells PFILLER10 -prefix FILLER -side e
add_io_fillers -cells PFILLER10 -prefix FILLER -side s 
add_io_fillers -cells PFILLER10 -prefix FILLER -side w 

add_io_fillers -cells PFILLER5 -prefix FILLER -side n
add_io_fillers -cells PFILLER5 -prefix FILLER -side e
add_io_fillers -cells PFILLER5 -prefix FILLER -side s 
add_io_fillers -cells PFILLER5 -prefix FILLER -side w 

add_io_fillers -cells PFILLER1 -prefix FILLER -side n
add_io_fillers -cells PFILLER1 -prefix FILLER -side e
add_io_fillers -cells PFILLER1 -prefix FILLER -side s 
add_io_fillers -cells PFILLER1 -prefix FILLER -side w 

add_io_fillers -cells PFILLER05 -prefix FILLER -side n
add_io_fillers -cells PFILLER05 -prefix FILLER -side e
add_io_fillers -cells PFILLER05 -prefix FILLER -side s 
add_io_fillers -cells PFILLER05 -prefix FILLER -side w 

add_io_fillers -cells PFILLER0005 -prefix FILLER -side n
add_io_fillers -cells PFILLER0005 -prefix FILLER -side e
add_io_fillers -cells PFILLER0005 -prefix FILLER -side s 
add_io_fillers -cells PFILLER0005 -prefix FILLER -side w 