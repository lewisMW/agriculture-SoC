#-----------------------------------------------------------------------------
# MegaSoC Top-Level Makefile 
# - Includes other Makefiles in flow directory
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Flynn (d.w.flynn@soton.ac.uk)
# Daniel Newbrook (d.newbrook@soton.ac.uk)
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

#-------------------------------------
# - Commonly Overloaded Variables
#-------------------------------------
# Name of test directory - Default Test is Hello World
TESTNAME   ?= hello

# Simulator type (mti/vcs/xm)
SIMULATOR   = mti

# Is an accelerator subsystem present in the design?
ACCELERATOR ?= yes

#-------------------------------------
# - Directory Setups
#-------------------------------------
# Directory of Testcodes
TESTCODES_DIR    := $(SOCLABS_MEGASOC_TECH_DIR)/testcodes

# Project System Directory
FPGA_IMP_DIR     := $(SOCLABS_PROJECT_DIR)/imp/fpga
PROJ_SYS_DIR     := $(SOCLABS_PROJECT_DIR)/system
PROJ_SW_DIR      ?= $(PROJ_SYS_DIR)/testcodes

# Directory to put simulation files
SIM_TOP_DIR ?= $(SOCLABS_PROJECT_DIR)/simulate/sim
SIM_DIR      = $(SIM_TOP_DIR)/$(TESTNAME)

config_dma_axi:
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/generate --config ./config/cfg_dma_axi.yaml --output ./src/
config_dma_ahb:
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/generate --config ./config/cfg_dma_ahb.yaml --output ./src/
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/PL417-BU-50000-r0p1-00rel0/xhb500/logical/generate --config ./config/cfg_xhb_axi_to_ahb.cfg --output ./src/
config_dma_ahb_small:
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/generate --config ./config/cfg_dma_ahb_small.yaml --output ./src/
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/PL417-BU-50000-r0p1-00rel0/xhb500/logical/generate --config ./config/cfg_xhb_axi_to_ahb.cfg --output ./src/
config_dma_ahb_big:
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/generate --config ./config/cfg_dma_ahb_big.yaml --output ./src/
	@$(ARM_IP_LIBRARY_PATH)/DMA-350/CG096-r0p0-00rel0/PL417-BU-50000-r0p1-00rel0/xhb500/logical/generate --config ./config/cfg_xhb_axi_to_ahb_big.cfg --output ./src/

clean_ip:
	@rm -rf ./src/*