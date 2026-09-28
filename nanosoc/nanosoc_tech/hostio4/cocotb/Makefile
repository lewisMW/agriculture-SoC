##-----------------------------------------------------------------------------
## 4 channel 8-bit hostio transfer over 4-bit data bus
##
##  SoC Testbench
##
## A joint work commissioned on behalf of SoC Labs,
## under Arm Academic Access license.
##
## Contributors
##
## Design: David Flynn (dwflynn@soton.ac.uk)
##
## Packaging: Microsoft CoPilot AI agent support
##
## Copyright (c) 2024-6, SoC Labs (www.soclabs.org)
##-----------------------------------------------------------------------------

TOPLEVEL_LANG = verilog
SIM ?= modelsim
WAVES = 1
TOPLEVEL = cocotb_top
MODULE = test_hostio4_cocotb

#VERILOG_SOURCES =   ../soc_rtl/hostio4_controller.v   ../soc_rtl/hostio4_controller_fsm.v   ../soc_rtl/hostio4_controller_axis_rxport.v   ../soc_rtl/hostio4_controller_axis_txport.v   ../soc_rtl/hostio4_controller_sync.v   ../target_rtl/hostio4_target.v   ../target_rtl/hostio4_target_fsm.v   ../target_rtl/hostio4_target_axis_rxport.v   ../target_rtl/hostio4_target_axis_txport.v   ../target_rtl/hostio4_target_sync.v  ../tb/tb_hostio4_monitor.v  cocotb_top.sv
VERILOG_SOURCES =   ../soc_rtl/hostio4_controller.sv   ../soc_rtl/hostio4_controller_fsm.sv   ../soc_rtl/hostio4_controller_axis_rxport.sv   ../soc_rtl/hostio4_controller_axis_txport.sv   ../soc_rtl/hostio4_controller_sync.sv   ../target_rtl/hostio4_target.sv   ../target_rtl/hostio4_target_fsm.sv   ../target_rtl/hostio4_target_axis_rxport.sv   ../target_rtl/hostio4_target_axis_txport.sv   ../target_rtl/hostio4_target_sync.sv  ../tb/tb_hostio4_monitor.v  cocotb_top.sv

#EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim
